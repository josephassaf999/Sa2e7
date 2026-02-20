import 'package:flutter/material.dart';

/// UI Constants for BusinessManagement (YourListingsPage)
class BusinessManagementUIConstants {
  static const String yourListingsTitle = 'Your Listings';
  static const String noBusinessesMessage =
      'You haven\'t created any listings yet';
  static const String deleteConfirmTitle = 'Delete Listing?';
  static const String deleteConfirmMessage =
      'This action cannot be undone. The listing will be permanently removed.';
  static const String cancelButton = 'Cancel';
  static const String deleteButton = 'Delete';
  static const String editButton = 'Edit';
  static const String loadingMessage = 'Loading your listings...';
  static const String errorMessage =
      'Failed to load listings. Please try again.';
}

/// UI Utilities for BusinessManagement
class BusinessManagementUIUtils {
  // ─── CONFIRMATION DIALOG ─────────────────────────────────────────────────────
  static void showDeleteConfirmation({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(BusinessManagementUIConstants.deleteConfirmTitle),
          content: const Text(
            BusinessManagementUIConstants.deleteConfirmMessage,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(BusinessManagementUIConstants.cancelButton),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text(
                BusinessManagementUIConstants.deleteButton,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── EMPTY STATE WIDGET ──────────────────────────────────────────────────────
  static Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(Icons.storefront, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            BusinessManagementUIConstants.noBusinessesMessage,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ─── LOADING WIDGET ──────────────────────────────────────────────────────────
  static Widget buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            BusinessManagementUIConstants.loadingMessage,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ─── ERROR WIDGET ────────────────────────────────────────────────────────────
  static Widget buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
          const SizedBox(height: 24),
          Text(
            BusinessManagementUIConstants.errorMessage,
            style: TextStyle(fontSize: 16, color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── BUSINESS CARD BUILDER ───────────────────────────────────────────────────
  static Widget buildBusinessCard({
    required String businessName,
    required String category,
    required String imageUrl,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          SizedBox(
            height: 160,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
              child:
                  imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.storefront),
                      ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text(
                        BusinessManagementUIConstants.editButton,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD7141A),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text(
                        BusinessManagementUIConstants.deleteButton,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
