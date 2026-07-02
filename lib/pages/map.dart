import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sa2e7/core/services/map_service.dart';
import 'package:sa2e7/core/utils/map_utils.dart';
import 'package:sa2e7/core/widgets/business_info_card.dart';

class GoogleMapPage extends StatefulWidget {
  /// Optional: pass a business to auto-select and draw route on open
  final LatLng? destination;
  final Map<String, dynamic>? destinationData;
  final String? destinationId;

  const GoogleMapPage({
    super.key,
    this.destination,
    this.destinationData,
    this.destinationId,
  });

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  bool _locationGranted = false;

  Marker? _selectedMarker;
  Map<String, dynamic>? _selectedBusiness;

  final Set<Marker> _markers = {};
  final List<LatLng> _polylineCoordinates = [];

  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final currentLoc = await MapService.initLocation();
    if (currentLoc == null) return;

    setState(() {
      _locationGranted = true;
      _currentLocation = currentLoc;
    });

    // Auto-select destination if
    // provided
    if (widget.destination != null &&
        widget.destinationData != null &&
        widget.destinationId != null) {
      _onMarkerTapped(
        widget.destinationId!,
        widget.destinationData!,
        widget.destination!,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      _drawRoute();
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!mounted) return;
    if (_mapController != null) {
      _mapController?.dispose();
    }
    _mapController = controller;
    if (_currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14),
      );
    }
  }

  void _onMarkerTapped(
    String businessId,
    Map<String, dynamic> business,
    LatLng position,
  ) {
    if (_currentLocation == null) return;

    final distance = MapService.calculateDistance(_currentLocation!, position);
    final eta = MapService.calculateETA(distance);
    final displayHours = MapService.getTodayOpeningHours(
      business['openingHours'],
    );

    setState(() {
      _selectedBusiness = MapUIUtils.buildBusinessInfo(
        businessId: businessId,
        business: business,
        distance: distance,
        eta: eta,
        displayHours: displayHours,
      );

      _polylineCoordinates.clear();
      _markers.removeWhere((m) => m.markerId.value == 'selected_marker');

      _selectedMarker = Marker(
        markerId: const MarkerId('selected_marker'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
      _markers.add(_selectedMarker!);

      _mapController?.animateCamera(CameraUpdate.newLatLng(position));
    });
  }

  void _deselectBusiness() {
    setState(() {
      _selectedBusiness = null;
      _polylineCoordinates.clear();
      _markers.removeWhere((m) => m.markerId.value == 'selected_marker');
      _selectedMarker = null;
    });
  }

  Future<void> _drawRoute() async {
    if (_selectedMarker == null || _currentLocation == null) return;

    try {
      final routePoints = await MapService.getRoute(
        _currentLocation!,
        _selectedMarker!.position,
      );

      if (routePoints.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(MapUIConstants.unableToGetRoute)),
          );
        }
        return;
      }

      setState(() {
        _polylineCoordinates.clear();
        _polylineCoordinates.addAll(routePoints);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(MapUIConstants.unableToGetRoute)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_locationGranted || _currentLocation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MapUIConstants.primaryRed,
        title: const Text(
          MapUIConstants.mapTitle,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MapUIConstants.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = MapUIConstants.categories[index];
                final isSelected = selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: MapUIConstants.primaryRed,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  onSelected: (_) => setState(() => selectedCategory = cat),
                );
              },
            ),
          ),

          // Map
          Expanded(
            child: Stack(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('businesses')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final businessDocs = snapshot.data!.docs;
                    final Set<Marker> businessMarkers =
                        businessDocs
                            .map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final loc = data['location'];

                              // Handle both GeoPoint and Map {lat,lng}
                              LatLng? position;
                              if (loc is GeoPoint) {
                                position = LatLng(loc.latitude, loc.longitude);
                              } else if (loc is Map &&
                                  loc['lat'] != null &&
                                  loc['lng'] != null) {
                                position = LatLng(
                                  (loc['lat'] as num).toDouble(),
                                  (loc['lng'] as num).toDouble(),
                                );
                              }
                              if (position == null) return null;

                              final category = data['category'] ?? 'All';
                              if (selectedCategory != 'All' &&
                                  category != selectedCategory) {
                                return null;
                              }

                              return Marker(
                                markerId: MarkerId(doc.id),
                                position: position,
                                onTap:
                                    () => _onMarkerTapped(
                                      doc.id,
                                      data,
                                      position!,
                                    ),
                                infoWindow: InfoWindow(
                                  title: data['name'] ?? 'Business',
                                  snippet: category,
                                ),
                              );
                            })
                            .whereType<Marker>()
                            .toSet();

                    final allMarkers = {...businessMarkers};
                    if (_selectedMarker != null) {
                      allMarkers.add(_selectedMarker!);
                    }

                    return GoogleMap(
                      key: ValueKey(_currentLocation.toString()),
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _currentLocation!,
                        zoom: 14,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: allMarkers,
                      polylines: {
                        if (_polylineCoordinates.isNotEmpty)
                          Polyline(
                            polylineId: const PolylineId('route'),
                            color: Colors.blue,
                            width: 5,
                            points: _polylineCoordinates,
                          ),
                      },
                    );
                  },
                ),

                // Bottom Card
                if (_selectedBusiness != null)
                  BusinessInfoCard(
                    business: _selectedBusiness!,
                    onClose: _deselectBusiness,
                    onNavigate: _drawRoute,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
