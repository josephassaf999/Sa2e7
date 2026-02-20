// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map.dart';
import 'package:sa2e7/core/widgets/review_dialog.dart';
import 'package:sa2e7/core/utils/business_utils.dart';
import 'package:sa2e7/core/services/business_service.dart';

class BusinessDetailsPage extends StatefulWidget {
  final String businessId;

  const BusinessDetailsPage({super.key, required this.businessId});

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  Map<String, dynamic>? businessData;
  bool isLoading = true;
  double? distanceInKm;
  bool isFavorite = false;
  int _currentImageIndex = 0;
  final PageController _imagePageController = PageController();

  final Color primaryRed = const Color(0xFFD7141A);
  final Color primaryGreen = const Color(0xFF006B3C);

  @override
  void initState() {
    super.initState();
    _loadBusiness();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Future<void> _loadBusiness() async {
    businessData = await BusinessService.loadBusiness(widget.businessId);
    if (businessData != null) {
      distanceInKm = await BusinessService.calculateDistance(
        businessData!['location'],
      );
      isFavorite = await BusinessService.checkIfFavorite(widget.businessId);
    }
  }

  // ─── TOGGLE FAVORITE ──────────────────────────────────────────────────────────
  Future<void> _toggleFavorite() async {
    try {
      await BusinessService.toggleFavorite(widget.businessId);
      setState(() => isFavorite = !isFavorite);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // ─── LAUNCH URL ──────────────────────────────────────────────────────────────
  Future<void> _launchExternal(String url) async {
    if (!await BusinessService.launchExternalUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Could not open link.")));
      }
    }
  }

  // ─── SHARE ───────────────────────────────────────────────────────────────────
  Future<void> _shareBusiness(String name, String description) async {
    await BusinessService.shareBusiness(name, description);
  }

  Future<void> _submitReview(double rating, String text) async {
    try {
      await BusinessService.submitReview(widget.businessId, rating, text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Review submitted! Thank you."),
            backgroundColor: Color(0xFF006B3C),
          ),
        );
      }
      _loadBusiness();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // ─── ADD REVIEW DIALOG ───────────────────────────────────────────────────────
  void _showAddReviewDialog() {
    ReviewDialog.show(
      context: context,
      primaryRed: primaryRed,
      onSubmit: (rating, text) => _submitReview(rating, text),
    );
  }

  // Extract LatLng from GeoPoint or Map {lat, lng}
  LatLng? _extractLatLng(dynamic rawLocation) {
    if (rawLocation == null) return null;
    if (rawLocation is GeoPoint) {
      return LatLng(rawLocation.latitude, rawLocation.longitude);
    }
    if (rawLocation is Map) {
      final lat = rawLocation['lat'];
      final lng = rawLocation['lng'];
      if (lat != null && lng != null) {
        return LatLng((lat as num).toDouble(), (lng as num).toDouble());
      }
    }
    return null;
  }

  // ─── SECTION TITLE ───────────────────────────────────────────────────────────
  Widget _sectionTitle(String title) =>
      BusinessUIUtils.sectionTitle(title, primaryRed);

  // ─── RATING STARS ────────────────────────────────────────────────────────────
  Widget _buildRatingStars(double rating, {double size = 18}) =>
      BusinessUIUtils.buildRatingStars(rating, size: size);

  // ─── OPENING HOURS ───────────────────────────────────────────────────────────
  Widget _buildOpeningHours(Map<String, dynamic> hours) =>
      BusinessUIUtils.buildOpeningHours(hours, primaryRed);

  // ─── ACTION BUTTON ───────────────────────────────────────────────────────────
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    bool filled = false,
  }) => BusinessUIUtils.actionButton(
    icon: icon,
    label: label,
    onTap: onTap,
    color: color ?? primaryRed,
    filled: filled,
  );

  // ─── FORMAT DATE ───────────────────────────────────────────────────────────────
  String _formatDate(DateTime date) => BusinessUIUtils.formatDate(date);

  // ─── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: primaryRed),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (businessData == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryRed,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text("Business not found.")),
      );
    }

    final name = businessData!['name'] ?? '';
    final description = businessData!['description'] ?? '';
    final phone = (businessData!['phone'] ?? '').toString();
    final category = businessData!['category'] ?? '';
    final instagramRaw = (businessData!['instagram'] ?? '').toString();
    final menuLink = (businessData!['menuLink'] ?? '').toString();
    final images = List<String>.from(businessData!['images'] ?? []);
    final openingHours = businessData!['openingHours'] as Map<String, dynamic>?;
    final avgRating = (businessData!['avgRating'] ?? 0.0).toDouble();
    final numRatings = businessData!['numRatings'] ?? 0;

    // FIX: handle both GeoPoint and Map {lat, lng}
    final LatLng? businessLatLng = _extractLatLng(businessData!['location']);

    // Fix Instagram URL
    String instagramUrl = '';
    if (instagramRaw.isNotEmpty) {
      instagramUrl =
          instagramRaw.startsWith('http')
              ? instagramRaw
              : 'https://instagram.com/$instagramRaw';
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── HERO IMAGE SLIVER APP BAR ──────────────────────────────────────
          SliverAppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            expandedHeight: 280,
            pinned: true,
            backgroundColor: primaryRed,
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: _toggleFavorite,
                tooltip:
                    isFavorite ? 'Remove from favorites' : 'Add to favorites',
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareBusiness(name, description),
                tooltip: 'Share',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
              background:
                  images.isNotEmpty
                      ? Stack(
                        children: [
                          PageView.builder(
                            controller: _imagePageController,
                            itemCount: images.length,
                            onPageChanged:
                                (i) => setState(() => _currentImageIndex = i),
                            itemBuilder: (context, index) {
                              return Image.network(
                                images[index],
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const ColoredBox(
                                      color: Color(0xFFE0E0E0),
                                      child: Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                              );
                            },
                          ),
                          // Image counter dots
                          if (images.length > 1)
                            Positioned(
                              bottom: 50,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(images.length, (i) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: _currentImageIndex == i ? 20 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color:
                                          _currentImageIndex == i
                                              ? Colors.white
                                              : Colors.white54,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          // Dark gradient at bottom for title readability
                          const Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 80,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black54, Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      : const ColoredBox(
                        color: Color(0xFFE0E0E0),
                        child: Center(
                          child: Icon(
                            Icons.store,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      ),
            ),
          ),

          // ── BODY CONTENT ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Distance row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryRed.withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: primaryRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (distanceInKm != null)
                        Row(
                          children: [
                            Icon(
                              Icons.near_me,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${distanceInKm!.toStringAsFixed(1)} km away",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick Rating Preview
                  if (numRatings > 0)
                    Row(
                      children: [
                        _buildRatingStars(avgRating),
                        const SizedBox(width: 8),
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "($numRatings reviews)",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                  // ── DESCRIPTION ─────────────────────────────────────────
                  _sectionTitle("About"),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  // ── ACTION BUTTONS ───────────────────────────────────────
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (businessLatLng != null)
                        _actionButton(
                          icon: Icons.directions,
                          label: "Directions",
                          filled: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => GoogleMapPage(
                                      destination: businessLatLng,
                                      destinationData: businessData!,
                                      destinationId: widget.businessId,
                                    ),
                              ),
                            );
                          },
                        ),
                      if (phone.isNotEmpty)
                        _actionButton(
                          icon: Icons.phone,
                          label: "Call",
                          color: primaryGreen,
                          onTap: () => _launchExternal("tel:$phone"),
                        ),
                      if (instagramUrl.isNotEmpty)
                        _actionButton(
                          icon: Icons.camera_alt_outlined,
                          label: "Instagram",
                          onTap: () => _launchExternal(instagramUrl),
                        ),
                      if (menuLink.isNotEmpty)
                        _actionButton(
                          icon: Icons.menu_book_outlined,
                          label: "Menu",
                          onTap: () => _launchExternal(menuLink),
                        ),
                    ],
                  ),

                  // ── OPENING HOURS ────────────────────────────────────────
                  if (openingHours != null && openingHours.isNotEmpty) ...[
                    _sectionTitle("Opening Hours"),
                    _buildOpeningHours(openingHours),
                  ],

                  // ── CONTACT INFO ─────────────────────────────────────────
                  if (phone.isNotEmpty) ...[
                    _sectionTitle("Contact"),
                    GestureDetector(
                      onTap: () => _launchExternal("tel:$phone"),
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: phone));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Phone number copied!")),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 18,
                            color: primaryGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            phone,
                            style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "(long press to copy)",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── LOCATION MAP ─────────────────────────────────────────
                  if (businessLatLng != null) ...[
                    _sectionTitle("Location"),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 200,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: businessLatLng,
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('business'),
                              position: businessLatLng,
                            ),
                          },
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          liteModeEnabled: true,
                        ),
                      ),
                    ),
                  ],

                  // ── RATINGS & REVIEWS ────────────────────────────────────
                  _sectionTitle("Ratings & Reviews"),

                  // Overall rating display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRatingStars(avgRating, size: 22),
                            const SizedBox(height: 4),
                            Text(
                              numRatings == 0
                                  ? "No reviews yet"
                                  : "Based on $numRatings review${numRatings == 1 ? '' : 's'}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showAddReviewDialog,
                      icon: Icon(Icons.edit_outlined, color: primaryRed),
                      label: Text(
                        "Write a Review",
                        style: TextStyle(color: primaryRed),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryRed.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Reviews stream
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('businesses')
                            .doc(widget.businessId)
                            .collection('reviews')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.reviews_outlined,
                                  size: 40,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "No reviews yet. Be the first!",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final review =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;
                          final rating = (review['rating'] ?? 0.0).toDouble();
                          final text = review['text'] as String? ?? '';
                          final userName =
                              review['userName'] as String? ?? 'Anonymous';
                          final timestamp = review['timestamp'] as Timestamp?;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: primaryRed.withOpacity(
                                        0.12,
                                      ),
                                      child: Text(
                                        userName.isNotEmpty
                                            ? userName[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: primaryRed,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (timestamp != null)
                                            Text(
                                              _formatDate(timestamp.toDate()),
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 11,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    _buildRatingStars(rating, size: 15),
                                  ],
                                ),
                                if (text.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
