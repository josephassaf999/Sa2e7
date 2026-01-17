import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AddBusinessPage extends StatefulWidget {
  const AddBusinessPage({super.key});

  @override
  State<AddBusinessPage> createState() => _AddBusinessPageState();
}

class _AddBusinessPageState extends State<AddBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryRed = const Color(0xFFF63C3C);

  String businessName = '';
  String description = '';
  String phoneNumber = '';
  String instagramLink = '';
  String selectedCategory = "All"; // default category
  final List<String> categories = ["All","Night Life", "Historical", "Beach", "Food", "Cave"];

  List<File> selectedImages = [];
  List<String> uploadedImageUrls = [];

  LatLng? selectedLocation;
  GoogleMapController? _mapController;

  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  /// ---------------- OPENING HOURS ----------------
  Map<String, Map<String, TimeOfDay?>> openingHours = {
    "Monday": {"open": null, "close": null},
    "Tuesday": {"open": null, "close": null},
    "Wednesday": {"open": null, "close": null},
    "Thursday": {"open": null, "close": null},
    "Friday": {"open": null, "close": null},
    "Saturday": {"open": null, "close": null},
    "Sunday": {"open": null, "close": null},
  };

  Future<void> pickTime(String day, bool isOpen) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        openingHours[day]![isOpen ? "open" : "close"] = picked;
      });
    }
  }

  String formatTime(TimeOfDay? t) {
    if (t == null) return "--:--";
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  /* ---------------- IMAGE PICKING ---------------- */
  Future<void> pickImages() async {
    final List<XFile>? files =
    await _picker.pickMultiImage(imageQuality: 80);

    if (files != null && files.isNotEmpty) {
      setState(() {
        selectedImages.addAll(files.map((e) => File(e.path)));
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  /* ---------------- IMAGE UPLOAD ---------------- */
  Future<void> uploadImages() async {
    uploadedImageUrls.clear();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw 'Not logged in';

    for (int i = 0; i < selectedImages.length; i++) {
      final file = selectedImages[i];

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final ref = FirebaseStorage.instance.ref(fileName); // Root of Storage

      try {
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedImageUrls.add(downloadUrl);

        print('Uploaded: $downloadUrl');
      } catch (e) {
        print('UPLOAD FAILED → $e');
        rethrow;
      }
    }
  }

  /* ---------------- MAP ---------------- */
  void pickLocation(LatLng position) {
    setState(() {
      selectedLocation = position;
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, 16),
    );
  }

  /* ---------------- SAVE BUSINESS ---------------- */
  Future<void> saveBusiness() async {
    if (!_formKey.currentState!.validate() || selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all required fields and select location')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';

      // Upload images
      if (selectedImages.isNotEmpty) {
        await uploadImages();
      }

      // Prepare opening hours in string format
      Map<String, Map<String, String?>> hoursToSave = {};
      openingHours.forEach((day, times) {
        hoursToSave[day] = {
          "open": times["open"] != null ? formatTime(times["open"]) : null,
          "close": times["close"] != null ? formatTime(times["close"]) : null,
        };
      });

      // Save to Firestore
      await FirebaseFirestore.instance.collection('businesses').add({
        'name': businessName,
        'description': description,
        'phone': phoneNumber,
        'instagram': instagramLink,
        'category': selectedCategory,
        'location': {
          'lat': selectedLocation!.latitude,
          'lng': selectedLocation!.longitude,
        },
        'images': uploadedImageUrls,
        'openingHours': hoursToSave,
        'ownerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business added successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /* ---------------- UI ---------------- */
  InputDecoration inputDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.red.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Add Business', style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Business Name
              TextFormField(
                decoration: inputDecoration('Business Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => businessName = v!,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                decoration: inputDecoration('Description'),
                maxLines: 3,
                onSaved: (v) => description = v ?? '',
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                decoration: inputDecoration('Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => phoneNumber = v!,
              ),
              const SizedBox(height: 16),

              // Instagram
              TextFormField(
                decoration: inputDecoration('Instagram Link'),
                keyboardType: TextInputType.url,
                onSaved: (v) => instagramLink = v ?? '',
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: inputDecoration('Category'),
                value: selectedCategory,
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
              ),
              const SizedBox(height: 20),

              // Opening Hours Picker
              const Text("Opening Hours", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...openingHours.keys.map((day) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(day),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => pickTime(day, true),
                          child: Text(formatTime(openingHours[day]!["open"])),
                        ),
                        const Text(" - "),
                        TextButton(
                          onPressed: () => pickTime(day, false),
                          child: Text(formatTime(openingHours[day]!["close"])),
                        ),
                      ],
                    )
                  ],
                );
              }).toList(),
              const SizedBox(height: 16),

              // Map
              SizedBox(
                height: 260,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(33.8938, 35.5018),
                      zoom: 12,
                    ),
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                    },
                    onTap: pickLocation,
                    onMapCreated: (c) => _mapController = c,
                    markers: selectedLocation == null
                        ? {}
                        : {
                      Marker(
                        markerId: const MarkerId('business'),
                        position: selectedLocation!,
                      )
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Image Preview
              if (selectedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(selectedImages[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => removeImage(index),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),

              // Upload Images Button
              ElevatedButton.icon(
                onPressed: pickImages,
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text('Upload Images', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 30),

              // Add Business Button
              ElevatedButton(
                onPressed: saveBusiness,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Add Business',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
