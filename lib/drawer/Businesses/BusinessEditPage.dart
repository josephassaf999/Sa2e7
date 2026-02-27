import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sa2e7/core/services/business_edit_service.dart';
import 'package:sa2e7/core/utils/business_edit_utils.dart';

class BusinessEditPage extends StatefulWidget {
  final String businessId;

  const BusinessEditPage({super.key, required this.businessId});

  @override
  State<BusinessEditPage> createState() => _BusinessEditPageState();
}

class _BusinessEditPageState extends State<BusinessEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;

  // Text controllers
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController phoneController;
  late TextEditingController instagramController;
  late TextEditingController menuController;

  // Category
  String selectedCategory = BusinessEditUIConstants.defaultCategory;

  // Opening hours
  late Map<String, Map<String, TimeOfDay?>> openingHours;

  // Images
  List<String> imageUrls = [];
  List<XFile> newImages = [];

  // Location
  LatLng? location;

  // ─── INIT ──────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    phoneController = TextEditingController();
    instagramController = TextEditingController();
    menuController = TextEditingController();
    openingHours = BusinessEditUIUtils.initializeOpeningHours();
    _loadBusiness();
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

  // ─── LOAD ──────────────────────────────────────────────────────────────────
  Future<void> _loadBusiness() async {
    try {
      final data = await BusinessEditService.loadBusiness(widget.businessId);
      if (data == null) {
        setState(() => isLoading = false);
        return;
      }

      nameController.text = data['name'] ?? '';
      descriptionController.text = data['description'] ?? '';
      phoneController.text = data['phone'] ?? '';
      instagramController.text = data['instagram'] ?? '';
      menuController.text = data['menuLink'] ?? '';

      final cat = data['category'] ?? BusinessEditUIConstants.defaultCategory;
      selectedCategory =
          BusinessEditUIConstants.categories.contains(cat)
              ? cat
              : BusinessEditUIConstants.defaultCategory;

      location = BusinessEditUIUtils.parseLocation(data['location']);

      // Opening hours
      final rawHours = data['openingHours'];
      if (rawHours is Map) {
        for (final day in openingHours.keys) {
          final times = rawHours[day];
          if (times is Map) {
            openingHours[day]!['open'] = BusinessEditUIUtils.parseTime(
              times['open'],
            );
            openingHours[day]!['close'] = BusinessEditUIUtils.parseTime(
              times['close'],
            );
          }
        }
      }

      imageUrls = List<String>.from(data['images'] ?? []);

      setState(() => isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading: $e')));
        Navigator.pop(context);
      }
    }
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────
  Future<void> _pickTime(String day, bool isOpen) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          openingHours[day]![isOpen ? 'open' : 'close'] ??
          TimeOfDay(hour: isOpen ? 9 : 22, minute: 0),
    );
    if (picked != null) {
      setState(() => openingHours[day]![isOpen ? 'open' : 'close'] = picked);
    }
  }

  // ─── IMAGES ────────────────────────────────────────────────────────────────
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) setState(() => newImages.addAll(picked));
  }

  void _removeExistingImage(int index) =>
      setState(() => imageUrls.removeAt(index));

  void _removeNewImage(int index) => setState(() => newImages.removeAt(index));

  // ─── SAVE ──────────────────────────────────────────────────────────────────
  Future<void> _saveBusiness() async {
    if (!_formKey.currentState!.validate() || location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and set a location.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Upload new images
      final newUrls = await BusinessEditService.uploadNewImages(
        widget.businessId,
        newImages,
      );
      final allImages = [...imageUrls, ...newUrls];

      // Convert opening hours to save format
      final hoursToSave = BusinessEditUIUtils.convertOpeningHours(openingHours);

      // Save to Firestore
      await BusinessEditService.saveBusiness(
        businessId: widget.businessId,
        name: nameController.text,
        description: descriptionController.text,
        phone: phoneController.text,
        instagram: instagramController.text,
        menuLink: menuController.text,
        category: selectedCategory,
        location: location!,
        allImages: allImages,
        openingHours: hoursToSave,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business updated successfully!'),
            backgroundColor: Color(0xFF006B3C),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    const primaryRed = Color(0xFFF63C3C);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit Business',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryRed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── BASIC INFO ────────────────────────────────────────────
              BusinessEditUIUtils.sectionLabel('Basic Info'),

              TextFormField(
                controller: nameController,
                decoration: BusinessEditUIUtils.inputDecoration(
                  'Business Name',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: descriptionController,
                decoration: BusinessEditUIUtils.inputDecoration('Description'),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: phoneController,
                decoration: BusinessEditUIUtils.inputDecoration('Phone Number'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: instagramController,
                decoration: BusinessEditUIUtils.inputDecoration(
                  'Instagram Link (optional)',
                  hint: 'username or full URL',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: menuController,
                decoration: BusinessEditUIUtils.inputDecoration(
                  'Menu Link (optional)',
                  hint: 'https://...',
                ),
                keyboardType: TextInputType.url,
              ),

              // ── CATEGORY ─────────────────────────────────────────────
              BusinessEditUIUtils.sectionLabel('Category'),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: BusinessEditUIUtils.inputDecoration('Category'),
                items:
                    BusinessEditUIConstants.categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
              ),

              // ── OPENING HOURS ─────────────────────────────────────────
              BusinessEditUIUtils.sectionLabel('Opening Hours'),

              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  children:
                      openingHours.keys.map((day) {
                        final open = openingHours[day]!['open'];
                        final close = openingHours[day]!['close'];
                        return Row(
                          children: [
                            SizedBox(
                              width: 96,
                              child: Text(
                                day,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _pickTime(day, true),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              child: Text(
                                BusinessEditUIUtils.formatTime(open),
                                style: TextStyle(
                                  color:
                                      open != null ? primaryRed : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Text(
                              '–',
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextButton(
                              onPressed: () => _pickTime(day, false),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              child: Text(
                                BusinessEditUIUtils.formatTime(close),
                                style: TextStyle(
                                  color:
                                      close != null ? primaryRed : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (open != null || close != null)
                              GestureDetector(
                                onTap:
                                    () => setState(() {
                                      openingHours[day]!['open'] = null;
                                      openingHours[day]!['close'] = null;
                                    }),
                                child: Icon(
                                  Icons.clear,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                ),
              ),

              // ── LOCATION ──────────────────────────────────────────────
              BusinessEditUIUtils.sectionLabel('Location'),

              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 260,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: location!,
                      zoom: 16,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('business_marker'),
                        position: location!,
                        draggable: true,
                        onDragEnd: (pos) => setState(() => location = pos),
                      ),
                    },
                    onTap: (pos) => setState(() => location = pos),
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Tap the map or drag the pin to adjust.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

              // ── IMAGES ────────────────────────────────────────────────
              BusinessEditUIUtils.sectionLabel('Images'),

              if (imageUrls.isNotEmpty || newImages.isNotEmpty)
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...imageUrls.asMap().entries.map((entry) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: entry.value,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Container(
                                        color: Colors.grey.shade300,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.error_outline),
                                      ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => _removeExistingImage(entry.key),
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
                      }),
                      ...newImages.asMap().entries.map((entry) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(File(entry.value.path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => _removeNewImage(entry.key),
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
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: primaryRed,
                  ),
                  label: const Text(
                    'Add Images',
                    style: TextStyle(color: primaryRed),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryRed.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              // ── SAVE ──────────────────────────────────────────────────
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveBusiness,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
