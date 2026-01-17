import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusinessEditPage extends StatefulWidget {
  final String businessId;

  const BusinessEditPage({super.key, required this.businessId});

  @override
  State<BusinessEditPage> createState() => _BusinessEditPageState();
}

class _BusinessEditPageState extends State<BusinessEditPage> {
  final CollectionReference businesses =
  FirebaseFirestore.instance.collection('businesses');

  final _formKey = GlobalKey<FormState>();
  final Color primaryRed = const Color(0xFFF63C3C);
  bool isLoading = true;

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController phoneController;

  List<String> imageUrls = [];
  List<XFile> newImages = [];

  LatLng? location;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    phoneController = TextEditingController();
    _loadBusiness();
  }

  void _loadBusiness() async {
    final doc = await businesses.doc(widget.businessId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        nameController.text = data['name'] ?? '';
        descriptionController.text = data['description'] ?? '';
        phoneController.text = data['phone'] ?? '';

        final loc = data['location'] as Map<String, dynamic>?;
        if (loc != null && loc['lat'] != null && loc['lng'] != null) {
          location = LatLng(loc['lat'], loc['lng']);
        } else {
          location = const LatLng(33.8938, 35.5018);
        }

        imageUrls = List<String>.from(data['images'] ?? []);
        isLoading = false;
      });
    }
  }

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.red.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
  );

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked != null) {
      setState(() {
        newImages.addAll(picked);
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      newImages.removeAt(index);
    });
  }

  Future<void> _uploadImagesToStorage() async {
    final userId = widget.businessId;

    for (var image in newImages) {
      try {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final ref =
        FirebaseStorage.instance.ref().child('business_images/$userId/$fileName');
        await ref.putFile(File(image.path));
      } catch (e) {
        debugPrint('Error uploading image: $e');
      }
    }
  }

  Future<void> _saveBusiness() async {
    if (!_formKey.currentState!.validate() || location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields and select location')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => isLoading = true);

    try {
      await _uploadImagesToStorage();

      final locMap = {
        'lat': location!.latitude,
        'lng': location!.longitude,
      };

      await businesses.doc(widget.businessId).update({
        'name': nameController.text,
        'description': descriptionController.text,
        'phone': phoneController.text,
        'location': locMap,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Edit Business', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryRed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: nameController,
                decoration: _input('Business Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: descriptionController,
                decoration: _input('Description'),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: phoneController,
                decoration: _input('Phone Number'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),

              // Map
              SizedBox(
                height: 260,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Listener(
                    onPointerMove: (_) {},
                    child: GoogleMap(
                      initialCameraPosition:
                      CameraPosition(target: location!, zoom: 16),
                      onMapCreated: (c) => _mapController = c,
                      markers: {
                        Marker(
                          markerId: const MarkerId('business_marker'),
                          position: location!,
                          draggable: true,
                          onDragEnd: (newPos) {
                            setState(() {
                              location = newPos;
                            });
                          },
                        ),
                      },
                      onTap: (pos) => setState(() => location = pos),
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer()),
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Images
              if (imageUrls.isNotEmpty || newImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...imageUrls.map(
                            (url) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.network(url, width: 100, fit: BoxFit.cover),
                        ),
                      ),
                      ...newImages.asMap().entries.map(
                            (entry) {
                          final idx = entry.key;
                          final img = entry.value;
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.file(File(img.path),
                                    width: 100, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeNewImage(idx),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.close,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text('Upload Images',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: primaryRed,padding: EdgeInsets.symmetric(horizontal: 122)),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saveBusiness,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 130),
                ),
                child: const Text('Save Changes',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
