import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sa2e7/drawer/Businesses/BusinessEditPage.dart';
import 'package:sa2e7/pages/business_page.dart';

class YourListingsPage extends StatefulWidget {
  const YourListingsPage({super.key});

  @override
  State<YourListingsPage> createState() => _YourListingsPageState();
}

class _YourListingsPageState extends State<YourListingsPage> {
  final Color primaryBlue = const Color(0xFFF63C3C);

  final user = FirebaseAuth.instance.currentUser;

  CollectionReference get businesses =>
      FirebaseFirestore.instance.collection('businesses');

  // Delete a business
  void deleteBusiness(String businessId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this business?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await businesses.doc(businessId).delete();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Business deleted")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete business: $e")));
      }
    }
  }

  // Navigate to edit page
  void editBusiness(String businessId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessEditPage(businessId: businessId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: Text("Not logged in"));

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Your Listings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryBlue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: businesses.where('ownerId', isEqualTo: user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "You have no Businesses yet.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final businessDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: businessDocs.length,
            itemBuilder: (context, index) {
              final business = businessDocs[index];
              final name = business['name'] ?? '';
              final description = business['description'] ?? '';

              // Since images are not stored in Firestore, default to 0
              final imagesCount = 0;

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  onTap: () {
                    // Open read-only BusinessDetailsPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BusinessDetailsPage(businessId: business.id),
                      ),
                    );
                  },
                  title: Text(name),
                  subtitle: Text(description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => editBusiness(business.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteBusiness(business.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
