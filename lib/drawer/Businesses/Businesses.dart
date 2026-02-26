import 'package:flutter/material.dart';
import 'package:sa2e7/drawer/Businesses/BusinessEditPage.dart';
import 'package:sa2e7/pages/business_page.dart';
import 'package:sa2e7/core/services/business_management_service.dart';
import 'package:sa2e7/core/utils/business_management_utils.dart';
import 'package:sa2e7/welcome/auth_page.dart';

class YourListingsPage extends StatefulWidget {
  const YourListingsPage({super.key});

  @override
  State<YourListingsPage> createState() => _YourListingsPageState();
}

class _YourListingsPageState extends State<YourListingsPage> {
  // ─── LIFECYCLE ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    final user = BusinessManagementService.getCurrentUser();
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthPage()));
      });
    }
  }

  // ─── DELETE BUSINESS ────────────────────────────────────────────────────────
  void _deleteBusiness(String businessId) {
    BusinessManagementUIUtils.showDeleteConfirmation(
      context: context,
      onConfirm: () async {
        try {
          await BusinessManagementService.deleteBusiness(businessId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Business deleted successfully")),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to delete business: $e")),
            );
          }
        }
      },
    );
  }

  // ─── EDIT BUSINESS ───────────────────────────────────────────────────────────
  void _editBusiness(String businessId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessEditPage(businessId: businessId),
      ),
    );
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = BusinessManagementService.getCurrentUser();
    if (user == null) return const SizedBox.expand();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          BusinessManagementUIConstants.yourListingsTitle,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD7141A),
      ),
      body: StreamBuilder(
        stream: BusinessManagementService.getUserBusinesses(),
        builder: (context, snapshot) {
          // ─ LOADING STATE ───────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return BusinessManagementUIUtils.buildLoadingState();
          }

          // ─ ERROR STATE ─────────────────────────────────────────────────────
          if (snapshot.hasError) {
            return BusinessManagementUIUtils.buildErrorState();
          }

          // ─ EMPTY STATE ─────────────────────────────────────────────────────
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return BusinessManagementUIUtils.buildEmptyState();
          }

          // ─ DATA STATE ──────────────────────────────────────────────────────
          final businessDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: businessDocs.length,
            itemBuilder: (context, index) {
              final business = businessDocs[index];
              final id = business.id;
              final name = business['name'] ?? '';
              final category = business['category'] ?? 'Uncategorized';
              final images =
                  (business['images'] as List?)?.cast<String>() ?? [];
              final firstImage = images.isNotEmpty ? images[0] : '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BusinessDetailsPage(businessId: id),
                    ),
                  );
                },
                child: BusinessManagementUIUtils.buildBusinessCard(
                  businessName: name,
                  category: category,
                  imageUrl: firstImage,
                  onEdit: () => _editBusiness(id),
                  onDelete: () => _deleteBusiness(id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
