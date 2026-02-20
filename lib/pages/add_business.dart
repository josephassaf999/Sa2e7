// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sa2e7/core/services/add_business_service.dart';
import 'package:sa2e7/core/utils/add_business_utils.dart';

class AddBusinessPage extends StatefulWidget {
  const AddBusinessPage({super.key});

  @override
  State<AddBusinessPage> createState() => _AddBusinessPageState();
}

class _AddBusinessPageState extends State<AddBusinessPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController menuController = TextEditingController();

  String selectedCategory = "All";
  List<File> selectedImages = [];
  LatLng? selectedLocation;
  GoogleMapController? _mapController;
  bool isLoading = false;

  late Map<String, Map<String, TimeOfDay?>> openingHours;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    openingHours = AddBusinessUIUtils.initializeOpeningHours();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    instagramController.dispose();
    menuController.dispose();
    super.dispose();
  }

  Future<void> pickTime(String day, bool isOpen) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        openingHours[day]![isOpen ? "open" : "close"] = picked;
      });
    }
  }

  Future<void> pickImages() async {
    final List<XFile> files = await _picker.pickMultiImage(imageQuality: 80);

    if (files.isNotEmpty) {
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

  void pickLocation(LatLng position) {
    setState(() {
      selectedLocation = position;
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
  }

  Future<void> saveBusiness() async {
    if (!_formKey.currentState!.validate() ||
        selectedLocation == null ||
        selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AddBusinessUIConstants.fillAllFieldsError),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Upload images
      final imageUrls = await AddBusinessService.uploadImages(selectedImages);

      // Convert opening hours
      final hoursToSave = AddBusinessUIUtils.convertOpeningHours(openingHours);

      // Save business to Firestore
      await AddBusinessService.saveBusiness(
        name: nameController.text,
        description: descriptionController.text,
        phone: phoneController.text,
        instagram: instagramController.text,
        menuLink: menuController.text,
        category: selectedCategory,
        location: selectedLocation!,
        imageUrls: imageUrls,
        openingHours: hoursToSave,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AddBusinessUIConstants.businessAddedSuccess),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AddBusinessUIConstants.primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AddBusinessUIConstants.appTitle,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: AddBusinessUIUtils.inputDecoration(
                          AddBusinessUIConstants.businessNameLabel,
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? AddBusinessUIConstants.requiredFieldError
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: AddBusinessUIUtils.inputDecoration(
                          AddBusinessUIConstants.descriptionLabel,
                        ),
                        maxLines: 3,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? AddBusinessUIConstants.requiredFieldError
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phoneController,
                        decoration: AddBusinessUIUtils.inputDecoration(
                          AddBusinessUIConstants.phoneLabel,
                        ),
                        keyboardType: TextInputType.phone,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? AddBusinessUIConstants.requiredFieldError
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: instagramController,
                        decoration: AddBusinessUIUtils.inputDecoration(
                          AddBusinessUIConstants.instagramLabel,
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: menuController,
                        decoration: AddBusinessUIUtils.inputDecoration(
                          AddBusinessUIConstants.menuLabel,
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: AddBusinessUIUtils.inputDecoration(
                          AddBusinessUIConstants.categoryLabel,
                        ),
                        value: selectedCategory,
                        items:
                            AddBusinessUIConstants.categories
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => selectedCategory = val!),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        AddBusinessUIConstants.openingHoursLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...AddBusinessUIConstants.weekdays.map((day) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(day),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => pickTime(day, true),
                                  child: Text(
                                    AddBusinessUIUtils.formatTime(
                                      openingHours[day]!["open"],
                                    ),
                                  ),
                                ),
                                const Text(" - "),
                                TextButton(
                                  onPressed: () => pickTime(day, false),
                                  child: Text(
                                    AddBusinessUIUtils.formatTime(
                                      openingHours[day]!["close"],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
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
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                            onTap: pickLocation,
                            onMapCreated: (c) => _mapController = c,
                            markers:
                                selectedLocation == null
                                    ? {}
                                    : {
                                      Marker(
                                        markerId: const MarkerId('business'),
                                        position: selectedLocation!,
                                      ),
                                    },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                                        child: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: pickImages,
                        icon: const Icon(Icons.upload, color: Colors.white),
                        label: const Text(
                          AddBusinessUIConstants.uploadImagesLabel,
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AddBusinessUIConstants.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: saveBusiness,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AddBusinessUIConstants.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          AddBusinessUIConstants.addBusinessLabel,
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
