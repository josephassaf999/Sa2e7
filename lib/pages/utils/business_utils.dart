import 'package:flutter/material.dart';

/// Utility class for business page UI components and helpers
class BusinessUIUtils {
  /// Build a section title with a colored accent bar
  static Widget sectionTitle(String title, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Build star rating display with support for half stars
  static Widget buildRatingStars(double rating, {double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: Colors.amber, size: size);
        } else if (index < rating && rating - index >= 0.5) {
          return Icon(Icons.star_half, color: Colors.amber, size: size);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: size);
        }
      }),
    );
  }

  /// Build opening hours display with highlighted today's hours
  static Widget buildOpeningHours(
    Map<String, dynamic> hours,
    Color primaryRed,
  ) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final today =
        [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ][DateTime.now().weekday - 1];

    return Column(
      children:
          days.where((day) => hours.containsKey(day)).map((day) {
            final times = hours[day];
            final open = times?['open'] ?? '--:--';
            final close = times?['close'] ?? '--:--';
            final isClosed = open == '--:--' || open == null;
            final isToday = day == today;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isToday ? primaryRed.withOpacity(0.07) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border:
                    isToday
                        ? Border.all(color: primaryRed.withOpacity(0.2))
                        : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? primaryRed : Colors.black87,
                    ),
                  ),
                  Text(
                    isClosed ? 'Closed' : '$open – $close',
                    style: TextStyle(
                      color: isClosed ? Colors.grey : Colors.black87,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  /// Build an action button with optional filled style
  static Widget actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    bool filled = false,
  }) {
    final c = color ?? Colors.red;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: filled ? c : c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: c.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: filled ? Colors.white : c),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : c,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format a date in a readable format
  static String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
