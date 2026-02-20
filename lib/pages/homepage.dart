import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sa2e7/drawer/Businesses/Businesses.dart';
import 'package:sa2e7/pages/business_page.dart';
import '../drawer/profie tab/profile_page.dart';
import '../drawer/settings_page.dart';
import '../core/utils/nav_transition.dart';
import '../welcome/auth_page.dart';
import 'add_business.dart';
import 'map.dart';
import 'package:sa2e7/core/services/home_service.dart';
import 'package:sa2e7/core/utils/home_utils.dart';

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
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadFavorites();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;
      if (user == null) {
        setState(() => currentUserName = null);
      } else {
        _loadUserName();
        _loadFavorites();
      }
    });
  }

  Future<void> _loadUserName() async {
    final name = await HomeService.loadUserName();
    if (!mounted) return;
    setState(() => currentUserName = name);
  }

  Future<void> _loadFavorites() async {
    final favorites = await HomeService.loadFavorites();
    if (!mounted) return;
    setState(() => _favorites = favorites);
  }

  Future<void> _toggleFavorite(String businessId) async {
    setState(() {
      if (_favorites.contains(businessId)) {
        _favorites.remove(businessId);
      } else {
        _favorites.add(businessId);
      }
    });

    try {
      await HomeService.toggleFavorite(businessId);
    } catch (e) {
      // Revert on error
      setState(() {
        if (_favorites.contains(businessId)) {
          _favorites.remove(businessId);
        } else {
          _favorites.add(businessId);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _onAddBusinessPressed() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.push(context, Nav.go(const AddBusinessPage()));
    } else {
      Navigator.push(context, Nav.go(const AuthPage()));
    }
  }

  Future<void> _refreshBusinesses() async {
    await HomeService.refreshBusinesses();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: HomeUIConstants.accentWhite),
        backgroundColor: HomeUIConstants.primaryRed,
        centerTitle: true,
        title:
            _isSearching
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
                : const Text(
                  HomeUIConstants.appTitle,
                  style: TextStyle(color: Colors.white),
                ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: HomeUIConstants.accentWhite,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) _searchQuery = "";
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: HomeUIConstants.primaryRed),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUserName != null
                        ? 'Welcome, $currentUserName'
                        : 'Welcome',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  currentUserName == null
                      ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomeUIConstants.accentWhite,
                          foregroundColor: HomeUIConstants.primaryRed,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(context, Nav.go(const AuthPage()));
                        },
                        child: const Text('Login / Register'),
                      )
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomeUIConstants.accentWhite,
                          foregroundColor: HomeUIConstants.primaryRed,
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        child: const Text('Logout'),
                      ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: HomeUIConstants.primaryRed),
              title: const Text('Profile'),
              onTap: () => Navigator.push(context, Nav.go(const ProfilePage())),
            ),
            ListTile(
              leading: Icon(Icons.store, color: HomeUIConstants.primaryRed),
              title: const Text('Your businesses'),
              onTap:
                  () =>
                      Navigator.push(context, Nav.go(const YourListingsPage())),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: HomeUIConstants.primaryRed),
              title: const Text('Settings'),
              onTap:
                  () => Navigator.push(context, Nav.go(const SettingsPage())),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBusinesses,
        color: HomeUIConstants.primaryRed,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeUIUtils.buildHeroSection(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GoogleMapPage()),
                  );
                },
              ),
              const SizedBox(height: 24),
              HomeUIUtils.buildCategoryFilter(
                selectedCategory: _selectedCategory,
                onCategoryChanged: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                HomeUIConstants.activitiesLabel,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('businesses')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final businesses =
                      snapshot.data!.docs.where((doc) {
                        final category = doc['category'] ?? 'All';
                        final name = doc['name'] ?? '';
                        final matchesCategory =
                            _selectedCategory == "All" ||
                            category == _selectedCategory;
                        final matchesSearch =
                            _searchQuery.isEmpty ||
                            name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                        return matchesCategory && matchesSearch;
                      }).toList();

                  if (businesses.isEmpty) {
                    return const Center(
                      child: Text(HomeUIConstants.noBusinessesFound),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: businesses.length,
                    itemBuilder: (context, index) {
                      final b = businesses[index];
                      final images = List<String>.from(b['images'] ?? []);
                      final imageUrl =
                          images.isNotEmpty
                              ? images[0]
                              : 'assets/image/default_business.png';
                      final businessId = b.id;

                      return HomeUIUtils.buildBusinessCard(
                        businessId: businessId,
                        name: b['name'] ?? '',
                        category: b['category'] ?? '',
                        imageUrl: imageUrl,
                        isFavorite: _favorites.contains(businessId),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BusinessDetailsPage(
                                    businessId: businessId,
                                  ),
                            ),
                          );
                        },
                        onFavoriteTapped: () => _toggleFavorite(businessId),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddBusinessPressed,
        backgroundColor: HomeUIConstants.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          HomeUIConstants.addBusinessLabel,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
