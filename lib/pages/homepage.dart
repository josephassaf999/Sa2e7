import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sa2e7/drawer/Businesses/Businesses.dart';
import 'package:sa2e7/pages/business_page.dart';
import '../drawer/profie tab/profile_page.dart';
import '../drawer/settings_page.dart';
import '../utils/nav_transition.dart';
import '../welcome/auth_page.dart';
import 'add_business.dart';
import 'map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSearching = false;
  String _searchQuery = "";
  String _selectedCategory = "All";
  String? currentUserName;

  final Color primaryRed = const Color(0xFFD7141A);
  final Color primaryGreen = const Color(0xFF006B3C);
  final Color accentWhite = Colors.white;

  final List<String> categories = ["All","Night Life", "Historical", "Beach", "Food", "Cave"];

  @override
  void initState() {
    super.initState();
    _loadUserName();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;
      if (user == null) {
        setState(() => currentUserName = null);
      } else {
        _loadUserName();
      }
    });
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
    await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    if (!mounted) return;

    setState(() {
      currentUserName = doc.data()?['name'] ?? 'User';
    });
  }

  void _onAddBusinessPressed() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.push(context, Nav.go(const AddBusinessPage()));
    } else {
      Navigator.push(context, Nav.go(const AuthPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: accentWhite),
        backgroundColor: primaryRed,
        centerTitle: true,
        title: _isSearching
            ? TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search businesses...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        )
            : const Text("Sa2e7", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: accentWhite),
            onPressed: () {
              setState(() {
                if (_isSearching) _searchQuery = "";
                _isSearching = !_isSearching;
              });
            },
          )
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryRed),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUserName != null ? 'Welcome, $currentUserName' : 'Welcome',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  currentUserName == null
                      ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: accentWhite,
                        foregroundColor: primaryRed),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, Nav.go(const AuthPage()));
                    },
                    child: const Text('Login / Register'),
                  )
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: accentWhite,
                        foregroundColor: primaryRed),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: primaryRed),
              title: const Text('Profile'),
              onTap: () => Navigator.push(context, Nav.go(const ProfilePage())),
            ),
            ListTile(
              leading: Icon(Icons.store, color: primaryRed),
              title: const Text('Your businesses'),
              onTap: () => Navigator.push(context, Nav.go(const YourListingsPage())),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: primaryRed),
              title: const Text('Settings'),
              onTap: () => Navigator.push(context, Nav.go(const SettingsPage())),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          /// HERO
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GoogleMapPage()),
              );
            },
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
                  "Discover Lebanon",
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
          ),

          const SizedBox(height: 24),

          /// CATEGORIES
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: primaryRed,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle:
                  TextStyle(color: isSelected ? accentWhite : Colors.black),
                  onSelected: (_) => setState(() => _selectedCategory = category),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

        /// USER BUSINESSES FROM FIRESTORE
        const SizedBox(height: 24),
        const Text(
          "Activities",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('businesses')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter businesses by category & search
            final businesses = snapshot.data!.docs.where((doc) {
              final category = doc['category'] ?? 'All';
              final name = doc['name'] ?? '';
              final matchesCategory =
                  _selectedCategory == "All" || category == _selectedCategory;
              final matchesSearch =
                  _searchQuery.isEmpty || name.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesSearch;
            }).toList();

            if (businesses.isEmpty) {
              return const Center(child: Text("No businesses found."));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: businesses.length,
              itemBuilder: (context, index) {
                final b = businesses[index];
                final images = List<String>.from(b['images'] ?? []);
                final imageUrl = images.isNotEmpty
                    ? images[0]
                    : 'assets/image/default_business.png';
                final businessId = b.id; // <-- get the Firestore doc ID

                return GestureDetector(
                  onTap: () {
                    // Navigate to BusinessDetailsPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BusinessDetailsPage(businessId: businessId),
                      ),
                    );
                  },
                  child: Container(
                    height: 180,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: imageUrl.startsWith('assets/')
                                ? Image.asset(imageUrl, fit: BoxFit.cover)
                                : Image.network(imageUrl, fit: BoxFit.cover),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              width: double.infinity,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              color: Colors.black.withOpacity(0.45),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    b['name'] ?? '',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    b['category'] ?? '',
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );

          },
          ),
        ]),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddBusinessPressed,
        backgroundColor: primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
        const Text('Add Your Business', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
