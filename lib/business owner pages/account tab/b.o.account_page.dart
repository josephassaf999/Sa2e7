import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../welcome/welcome.dart';
import 'b.o profile edit page.dart';

class BAccountScreen extends StatelessWidget {
  const BAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Account',
            style: TextStyle(
              fontFamily: "Roboto",
            ),
          ),
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            child: const CircleAvatar(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto",
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text(
                  'Edit Profile',
                  style: TextStyle(fontFamily: "Roboto"),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              const Text(
                'Information',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto",
                ),
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Business Owner')
                    .doc(user!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  var databaseUsername =
                      userData['username'] ?? 'Not available';
                  var databaseEmail = userData['email'] ?? 'Not available';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          'Username: $databaseUsername',
                          style: const TextStyle(fontFamily: "Roboto"),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.email),
                        title: Text(
                          'Email: $databaseEmail',
                          style: TextStyle(fontFamily: "Roboto"),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Call a function to delete the account
                          deleteAccount(user.uid, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          'Delete Account',
                          style: TextStyle(
                              fontFamily: "Roboto", color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteAccount(String userId, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(fontFamily: "Roboto", color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete',
                  style: TextStyle(fontFamily: "Roboto", color: Colors.red)),
              onPressed: () async {
                try {
                  // Fetch user's businesses
                  QuerySnapshot businessSnapshot = await FirebaseFirestore
                      .instance
                      .collection('Business Owner')
                      .doc(userId)
                      .collection('businesses')
                      .get();

                  // Delete each business
                  for (DocumentSnapshot business in businessSnapshot.docs) {
                    await business.reference.delete();
                  }

                  // Delete user document from Firestore
                  await FirebaseFirestore.instance
                      .collection('Business Owner')
                      .doc(userId)
                      .delete();

                  // Delete user account from FirebaseAuth
                  await FirebaseAuth.instance.currentUser!.delete();

                  // Navigate back to welcome page
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomePage()),
                    (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  print('Error deleting account: $e');
                  // Handle error
                }
              },
            ),
          ],
        );
      },
    );
  }
}
