import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

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
  final PolylinePoints _polylinePoints = PolylinePoints();

  static const Color primaryRed = Color(0xFFF63C3C);
  static const String googleApiKey = 'AIzaSyAYFRlXlNKavwP1G4ZcvD7lzI5jfXI6zfk';

  // Category filter
  String selectedCategory = "All";
  final List<String> categories = ["All","Night Life", "Historical", "Beach", "Food", "Cave"];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  /* ---------------- LOCATION ---------------- */
  Future<void> _initLocation() async {
    final permission = await Permission.location.request();
    if (!permission.isGranted) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _locationGranted = true;
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14),
      );
    }
  }

  /* ---------------- SELECT BUSINESS ---------------- */
  void _onMarkerTapped(Map<String, dynamic> business, LatLng position) {
    if (_currentLocation == null) return;

    final distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      position.latitude,
      position.longitude,
    );

    final eta = Duration(
      seconds: (distance / (50 * 1000 / 3600)).round(),
    );

    setState(() {
      _selectedBusiness = {
        ...business,
        'distance': distance,
        'eta': eta,
      };

      _polylineCoordinates.clear();
      _markers.removeWhere((m) => m.markerId.value == 'selected_marker');

      _selectedMarker = Marker(
        markerId: const MarkerId('selected_marker'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
      _markers.add(_selectedMarker!);

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(position),
      );
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

  /* ---------------- DRAW ROUTE ---------------- */
  Future<void> _drawRoute() async {
    if (_selectedMarker == null || _currentLocation == null) return;

    try {
      final result = await _polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
          ),
          destination: PointLatLng(
            _selectedMarker!.position.latitude,
            _selectedMarker!.position.longitude,
          ),
          mode: TravelMode.driving,
        ),
        googleApiKey: googleApiKey,
      );

      if (result.points.isEmpty) return;

      _polylineCoordinates.clear();
      for (final point in result.points) {
        _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get route')),
      );
    }
  }

  /* ---------------- UI ---------------- */
  @override
  Widget build(BuildContext context) {
    if (!_locationGranted || _currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRed,
        title: const Text('Map', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: primaryRed,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
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
                  stream: FirebaseFirestore.instance.collection('businesses').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final businessDocs = snapshot.data!.docs;
                    final Set<Marker> businessMarkers = businessDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final loc = data['location'];
                      if (loc == null) return null;

                      // Filter by category
                      final category = data['category'] ?? 'All';
                      if (selectedCategory != 'All' && category != selectedCategory) return null;

                      return Marker(
                        markerId: MarkerId(doc.id),
                        position: LatLng(loc['lat'], loc['lng']),
                        onTap: () => _onMarkerTapped(data, LatLng(loc['lat'], loc['lng'])),
                        infoWindow: InfoWindow(
                          title: data['name'] ?? 'Business',
                          snippet: category,
                        ),
                      );
                    }).whereType<Marker>().toSet();

                    final allMarkers = {...businessMarkers};
                    if (_selectedMarker != null) allMarkers.add(_selectedMarker!);

                    return GoogleMap(
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 300),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedBusiness!['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: _deselectBusiness,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Category
                              if (_selectedBusiness!['category'] != null)
                                Row(
                                  children: [
                                    const Icon(Icons.category, size: 20, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(_selectedBusiness!['category']),
                                  ],
                                ),

                              // Hours
                              if (_selectedBusiness!['openingHours'] != null)
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 20, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(_selectedBusiness!['openingHours']),
                                  ],
                                ),

                              // Rating
                              if (_selectedBusiness!['avgRating'] != null)
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 20, color: Colors.amber),
                                    const SizedBox(width: 6),
                                    Text('${_selectedBusiness!['avgRating']} ⭐'),
                                  ],
                                ),

                              // Distance & ETA
                              if (_selectedBusiness!['distance'] != null &&
                                  _selectedBusiness!['eta'] != null)
                                Row(
                                  children: [
                                    const Icon(Icons.directions, size: 20, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${(_selectedBusiness!['distance'] / 1000).toStringAsFixed(2)} km, '
                                          '${_selectedBusiness!['eta'].inMinutes} min',
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 12),

                              // Buttons row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _drawRoute,
                                    icon: const Icon(Icons.navigation, color: Colors.white),
                                    label: const Text("Navigate",style: TextStyle(color: Colors.white),),
                                    style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                                  ),
                                  if (_selectedBusiness!['phone'] != null)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        final Uri launchUri = Uri(
                                          scheme: 'tel',
                                          path: _selectedBusiness!['phone'],
                                        );
                                        launchUrl(launchUri);
                                      },
                                      icon: const Icon(Icons.phone, color: Colors.white),
                                      label: const Text("Call",style: TextStyle(color: Colors.white),),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
