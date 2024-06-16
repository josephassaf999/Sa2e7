import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addbusinesspage.dart';
import '../side menu/bookings.dart';
import 'business_page.dart';
import '../side menu/Business_Owner_messaging.dart';

class BHomeScreen extends StatefulWidget {
  @override
  _BHomeScreenState createState() => _BHomeScreenState();
}

class _BHomeScreenState extends State<BHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  List<DocumentSnapshot> ownedBusinesses = [];

  @override
  void initState() {
    super.initState();
    fetchOwnedBusinesses();
  }

  Future<void> fetchOwnedBusinesses() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Business Owner')
        .doc(userId)
        .collection('businesses')
        .get();
    setState(() {
      ownedBusinesses = querySnapshot.docs;
    });
    print('Fetched ${ownedBusinesses.length} businesses');
    ownedBusinesses.forEach((business) {
      print('Business: ${business.data()}');
    });
  }

  void onBusinessTapped(DocumentSnapshot business) async {
    DocumentSnapshot businessSnapshot = await business.reference.get();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyBusinessScreen(
          businessData: businessSnapshot.data() as Map<String, dynamic>,
          businessId: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            color: Colors.white,
            onPressed: () {
              _scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ownedBusinesses.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Businesses:',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: ownedBusinesses.length,
                    itemBuilder: (context, index) {
                      String businessName = ownedBusinesses[index]['name'];
                      return GestureDetector(
                        onTap: () {
                          onBusinessTapped(ownedBusinesses[index]);
                        },
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              businessName,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddBusinessScreen()),
                  ).then((value) {
                    if (value != null && value is DocumentSnapshot) {
                      setState(() {
                        ownedBusinesses.add(value);
                      });
                    }
                  });
                },
                child: Text('Add Business', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.book_online, color: Colors.blue),
              title: Text(
                'Booking Management',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingManagement()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.message, color: Colors.blue),
              title: Text(
                'Messaging',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BMessaging()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
