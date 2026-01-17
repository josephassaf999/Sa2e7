import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    _loadBusiness();
  }

  Future<void> _loadBusiness() async {
    try {
      final doc = await businesses.doc(widget.businessId).get();
      if (doc.exists) {
        setState(() {
          businessData = doc.data() as Map<String, dynamic>?;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Business not found")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget _buildField(String fieldName, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$fieldName: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(String phoneNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () async {
          final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
          if (await canLaunchUrl(launchUri)) {
            await launchUrl(launchUri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cannot launch phone dialer")),
            );
          }
        },
        child: Row(
          children: [
            const Text(
              "Phone: ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              phoneNumber,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline),
            ),
          ],
        ),
      ),
    );
  }

  void _openImageViewer(List<dynamic> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Center(
                  child: Image.network(
                    images[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (businessData == null) {
      return const Scaffold(
        body: Center(child: Text("Business not found")),
      );
    }

    final name = businessData!['name'] ?? '';
    final description = businessData!['description'] ?? '';
    final phoneNumber = businessData!['phone'] ?? '';
    final category = businessData!['category'] ?? 'Uncategorized';
    final images = businessData!['images'] ?? [];

    final locationMap = businessData!['location'] as Map<String, dynamic>?;
    final hasLocation = locationMap != null &&
        locationMap['lat'] != null &&
        locationMap['lng'] != null;
    final LatLng businessLatLng = hasLocation
        ? LatLng(locationMap['lat'], locationMap['lng'])
        : const LatLng(0, 0);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(name, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFF63C3C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images gallery
            if (images.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final imgUrl = images[index];
                    return GestureDetector(
                      onTap: () => _openImageViewer(images, index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(imgUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(child: Text("No Images")),
              ),

            const SizedBox(height: 16),

            // Name & Category
            Text(
              name,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              category,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Description
            _buildField("Description", description),

            // Phone field
            if (phoneNumber.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPhoneField(phoneNumber),
            ],

            // Map
            if (hasLocation) ...[
              const SizedBox(height: 16),
              const Text(
                "Location:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: businessLatLng,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('business_marker'),
                      position: businessLatLng,
                      infoWindow: InfoWindow(
                        title: name,
                        snippet: locationMap['address'] ?? '',
                      ),
                    )
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  liteModeEnabled: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
