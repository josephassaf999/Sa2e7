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
  final CollectionReference businesses = FirebaseFirestore.instance.collection(
    'businesses',
  );

  final _formKey = GlobalKey<FormState>();
  final Color primaryRed = const Color(0xFFF63C3C);
  bool isLoading = true;

  // Text controllers
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController phoneController;
  late TextEditingController instagramController;
  late TextEditingController menuController;

  // Category
  String selectedCategory = 'All';
  final List<String> categories = [
    'All',
    'Night Life',
    'Historical',
    'Beach',
    'Food',
    'Cave',
  ];

  // Opening hours
  Map<String, Map<String, TimeOfDay?>> openingHours = {
    'Monday': {'open': null, 'close': null},
    'Tuesday': {'open': null, 'close': null},
    'Wednesday': {'open': null, 'close': null},
    'Thursday': {'open': null, 'close': null},
    'Friday': {'open': null, 'close': null},
    'Saturday': {'open': null, 'close': null},
    'Sunday': {'open': null, 'close': null},
  };

  // Images
  List<String> imageUrls = [];
  List<XFile> newImages = [];

  // Location
  LatLng? location;
  GoogleMapController? _mapController;

  // ─── INIT ──────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    phoneController = TextEditingController();
    instagramController = TextEditingController();
    menuController = TextEditingController();
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
    final doc = await businesses.doc(widget.businessId).get();
    if (!doc.exists) {
      setState(() => isLoading = false);
      return;
    }

    final data = doc.data() as Map<String, dynamic>;

    nameController.text = data['name'] ?? '';
    descriptionController.text = data['description'] ?? '';
    phoneController.text = data['phone'] ?? '';
    instagramController.text = data['instagram'] ?? '';
    menuController.text = data['menuLink'] ?? '';

    final cat = data['category'] ?? 'All';
    selectedCategory = categories.contains(cat) ? cat : 'All';

    // Handle both GeoPoint (add_business) and Map {lat,lng} (old edit_business)
    final rawLoc = data['location'];
    if (rawLoc is GeoPoint) {
      location = LatLng(rawLoc.latitude, rawLoc.longitude);
    } else if (rawLoc is Map &&
        rawLoc['lat'] != null &&
        rawLoc['lng'] != null) {
      location = LatLng(
        (rawLoc['lat'] as num).toDouble(),
        (rawLoc['lng'] as num).toDouble(),
      );
    } else {
      location = const LatLng(33.8938, 35.5018);
    }

    // Opening hours
    final rawHours = data['openingHours'];
    if (rawHours is Map) {
      for (final day in openingHours.keys) {
        final times = rawHours[day];
        if (times is Map) {
          openingHours[day]!['open'] = _parseTime(times['open']);
          openingHours[day]!['close'] = _parseTime(times['close']);
        }
      }
    }

    imageUrls = List<String>.from(data['images'] ?? []);

    setState(() => isLoading = false);
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────
  TimeOfDay? _parseTime(dynamic raw) {
    if (raw == null || raw.toString() == '--:--') return null;
    final parts = raw.toString().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '--:--';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

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

  InputDecoration _input(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: Colors.red.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
  );

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: primaryRed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
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

  Future<List<String>> _uploadNewImages() async {
    final List<String> urls = [];
    for (final image in newImages) {
      try {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final ref = FirebaseStorage.instance.ref().child(
          'business_images/${widget.businessId}/$fileName',
        );
        await ref.putFile(File(image.path));
        urls.add(await ref.getDownloadURL());
      } catch (e) {
        debugPrint('Image upload error: $e');
      }
    }
    return urls;
  }

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
      final newUrls = await _uploadNewImages();
      final allImages = [...imageUrls, ...newUrls];

      final Map<String, Map<String, String?>> hoursToSave = {};
      for (final entry in openingHours.entries) {
        hoursToSave[entry.key] = {
          'open': _formatTime(entry.value['open']),
          'close': _formatTime(entry.value['close']),
        };
      }

      await businesses.doc(widget.businessId).update({
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'phone': phoneController.text.trim(),
        'instagram': instagramController.text.trim(),
        'menuLink': menuController.text.trim(),
        'category': selectedCategory,
        'location': GeoPoint(location!.latitude, location!.longitude),
        'images': allImages,
        'openingHours': hoursToSave,
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
              _sectionLabel('Basic Info'),

              TextFormField(
                controller: nameController,
                decoration: _input('Business Name'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: descriptionController,
                decoration: _input('Description'),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: phoneController,
                decoration: _input('Phone Number'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: instagramController,
                decoration: _input(
                  'Instagram Link (optional)',
                  hint: 'username or full URL',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: menuController,
                decoration: _input('Menu Link (optional)', hint: 'https://...'),
                keyboardType: TextInputType.url,
              ),

              // ── CATEGORY ─────────────────────────────────────────────
              _sectionLabel('Category'),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: _input('Category'),
                items:
                    categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
              ),

              // ── OPENING HOURS ─────────────────────────────────────────
              _sectionLabel('Opening Hours'),

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
                                _formatTime(open),
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
                                _formatTime(close),
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
              _sectionLabel('Location'),

              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 260,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: location!,
                      zoom: 16,
                    ),
                    onMapCreated: (c) => _mapController = c,
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
              _sectionLabel('Images'),

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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(entry.value),
                                  fit: BoxFit.cover,
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
                  icon: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: primaryRed,
                  ),
                  label: Text(
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
