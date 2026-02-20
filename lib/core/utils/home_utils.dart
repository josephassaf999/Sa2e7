import 'package:flutter/material.dart';

/// UI utilities and constants for HomePage
class HomeUIConstants {
  // Colors
  static const Color primaryRed = Color(0xFFD7141A);
  static const Color primaryGreen = Color(0xFF006B3C);
  static const Color accentWhite = Colors.white;

  // Categories
  static const List<String> categories = [
    "All",
    "Night Life",
    "Historical",
    "Beach",
    "Food",
    "Cave",
  ];

  // String constants
  static const String appTitle = "Sa2e7";
  static const String discoverText = "Discover Lebanon";
  static const String activitiesLabel = "Activities";
  static const String noBusinessesFound = "No businesses found.";
  static const String addBusinessLabel = "Add Your Business";
}

/// UI builders for HomePage components
class HomeUIUtils {
  // ─── HERO SECTION ────────────────────────────────────────────────────────────
  static Widget buildHeroSection({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
            image: AssetImage('assets/image/lebhero.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: const Text(
            HomeUIConstants.discoverText,
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.white70,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ─── CATEGORY FILTER ─────────────────────────────────────────────────────────
  static Widget buildCategoryFilter({
    required String selectedCategory,
    required Function(String) onCategoryChanged,
  }) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: HomeUIConstants.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = HomeUIConstants.categories[index];
          final isSelected = selectedCategory == category;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            selectedColor: HomeUIConstants.primaryRed,
            backgroundColor: Colors.grey.shade200,
            labelStyle: TextStyle(
              color: isSelected ? HomeUIConstants.accentWhite : Colors.black,
            ),
            onSelected: (_) => onCategoryChanged(category),
          );
        },
      ),
    );
  }

  // ─── BUSINESS CARD ───────────────────────────────────────────────────────────
  static Widget buildBusinessCard({
    required String businessId,
    required String name,
    required String category,
    required String imageUrl,
    required bool isFavorite,
    required VoidCallback onTap,
    required VoidCallback onFavoriteTapped,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child:
                    imageUrl.startsWith('assets/')
                        ? Image.asset(imageUrl, fit: BoxFit.cover)
                        : Image.network(imageUrl, fit: BoxFit.cover),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  color: Colors.black.withOpacity(0.45),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Heart icon
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onFavoriteTapped,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: HomeUIConstants.primaryRed,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
