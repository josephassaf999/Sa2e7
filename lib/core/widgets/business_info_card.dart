import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sa2e7/pages/business_page.dart';
import 'package:sa2e7/core/utils/map_utils.dart';

/// Reusable widget for business info bottom card in map
class BusinessInfoCard extends StatelessWidget {
  final Map<String, dynamic> business;
  final VoidCallback onClose;
  final VoidCallback onNavigate;

  const BusinessInfoCard({
    super.key,
    required this.business,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        business['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BusinessDetailsPage(
                                  businessId: business['id'],
                                ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category
                if (business['category'] != null)
                  Row(
                    children: [
                      const Icon(Icons.category, size: 20, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(business['category']),
                    ],
                  ),

                // Hours
                if (business['displayHours'] != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(business['displayHours']),
                    ],
                  ),

                // Rating
                if (business['avgRating'] != null)
                  Row(
                    children: [
                      const Icon(Icons.star, size: 20, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        '${(business['avgRating'] as num).toStringAsFixed(1)} ⭐',
                      ),
                    ],
                  ),

                // Distance & ETA
                if (business['distance'] != null && business['eta'] != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.directions,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${MapUIUtils.formatDistance(business['distance'])} km, '
                        '${business['eta'].inMinutes} min',
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                // Buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onNavigate,
                      icon: const Icon(Icons.navigation, color: Colors.white),
                      label: const Text(
                        MapUIConstants.navigateLabel,
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MapUIConstants.primaryRed,
                      ),
                    ),
                    if (business['phone'] != null)
                      ElevatedButton.icon(
                        onPressed: () {
                          final Uri launchUri = Uri(
                            scheme: 'tel',
                            path: business['phone'],
                          );
                          launchUrl(launchUri);
                        },
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: const Text(
                          MapUIConstants.callLabel,
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
