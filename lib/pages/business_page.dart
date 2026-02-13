import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class BusinessDetailsPage extends StatefulWidget {
  final String businessId;

  const BusinessDetailsPage({super.key, required this.businessId});

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  final CollectionReference businesses =
  FirebaseFirestore.instance.collection('businesses');

  Map<String, dynamic>? businessData;
  bool isLoading = true;
  double? distanceInKm;

  @override
  void initState() {
    super.initState();
    _loadBusiness();
  }

  Future<void> _loadBusiness() async {
    try {
      final doc = await businesses.doc(widget.businessId).get();
      if (!doc.exists) {
        setState(() => isLoading = false);
        return;
      }

      businessData = doc.data() as Map<String, dynamic>;
      await _calculateDistance();
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  /// ---------------- DISTANCE ----------------
  Future<void> _calculateDistance() async {
    final GeoPoint? geoPoint = businessData?['location'];
    if (geoPoint == null) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();

    double meters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      geoPoint.latitude,
      geoPoint.longitude,
    );

    distanceInKm = meters / 1000;
  }

  /// ---------------- SAFE LAUNCH ----------------
  Future<void> _launchExternal(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// ---------------- SECTION TITLE ----------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOpeningHours(Map<String, dynamic>? hours) {
    if (hours == null) return const SizedBox();

    return Column(
      children: hours.entries.map((entry) {
        final open = entry.value['open'] ?? '--:--';
        final close = entry.value['close'] ?? '--:--';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.key),
              Text("$open - $close"),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (businessData == null) {
      return const Scaffold(
          body: Center(child: Text("Business not found")));
    }

    final name = businessData!['name'] ?? '';
    final description = businessData!['description'] ?? '';
    final phone = businessData!['phone'] ?? '';
    final category = businessData!['category'] ?? '';
    final instagramRaw = businessData!['instagram'] ?? '';
    final images = businessData!['images'] ?? [];
    final GeoPoint? geoPoint = businessData!['location'];
    final openingHours =
    businessData!['openingHours'] as Map<String, dynamic>?;

    final LatLng businessLatLng = geoPoint != null
        ? LatLng(geoPoint.latitude, geoPoint.longitude)
        : const LatLng(0, 0);

    /// Fix Instagram link automatically
    String instagramUrl = "";
    if (instagramRaw.isNotEmpty) {
      if (instagramRaw.startsWith("http")) {
        instagramUrl = instagramRaw;
      } else {
        instagramUrl = "https://instagram.com/$instagramRaw";
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [

          /// ---------------- HERO IMAGE ----------------
          SliverAppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFFF63C3C),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: const TextStyle(color: Colors.white),
              ),
              background: images.isNotEmpty
                  ? PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index],
                    fit: BoxFit.cover,
                  );
                },
              )
                  : Container(color: Colors.grey[300]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    /// Category + Distance
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(category,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16)),
                        if (distanceInKm != null)
                          Text(
                            "${distanceInKm!.toStringAsFixed(1)} km away",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),

                    _sectionTitle("Description"),
                    Text(description),

                    const SizedBox(height: 20),

                    /// ---------------- ACTION BUTTONS ----------------
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [

                        if (geoPoint != null)
                          ElevatedButton.icon(
                            onPressed: () => _launchExternal(
                                "https://www.google.com/maps/dir/?api=1&destination=${geoPoint.latitude},${geoPoint.longitude}"),
                            icon: const Icon(Icons.directions, color: Colors.white),
                            label: const Text("Directions",
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFFF63C3C)),
                          ),

                        if (geoPoint != null)
                          OutlinedButton.icon(
                            onPressed: () => _launchExternal(
                                "https://www.google.com/maps/search/?api=1&query=${geoPoint.latitude},${geoPoint.longitude}"),
                            icon: const Icon(Icons.map),
                            label: const Text("Open in Maps"),
                          ),

                        if (instagramUrl.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () =>
                                _launchExternal(instagramUrl),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Instagram"),
                          ),

                        if (phone.isNotEmpty)
                          OutlinedButton.icon(
                            onPressed: () => _launchExternal("tel:$phone"),
                            icon: const Icon(Icons.phone),
                            label: const Text("Call"),
                          ),
                      ],
                    ),

                    /// ---------------- PHONE TEXT ----------------
                    if (phone.isNotEmpty) ...[
                      _sectionTitle("Phone"),
                      Text(phone),
                    ],

                    /// ---------------- OPENING HOURS ----------------
                    if (openingHours != null) ...[
                      _sectionTitle("Opening Hours"),
                      _buildOpeningHours(openingHours),
                    ],

                    /// ---------------- MAP PREVIEW ----------------
                    if (geoPoint != null) ...[
                      _sectionTitle("Location"),
                      SizedBox(
                        height: 200,
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(12),
                          child: GoogleMap(
                            initialCameraPosition:
                            CameraPosition(
                              target: businessLatLng,
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId:
                                const MarkerId('business'),
                                position:
                                businessLatLng,
                              )
                            },
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled:
                            false,
                            liteModeEnabled: true,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
