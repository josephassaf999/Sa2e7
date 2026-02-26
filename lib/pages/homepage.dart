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
  // Filter state
  bool _showOnlyFavorites = false;
  // Add more filter fields as needed
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
    void openFilterSheet() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text('Show only favorites'),
                      value: _showOnlyFavorites,
                      onChanged: (val) {
                        setModalState(() => _showOnlyFavorites = val);
                        setState(() => _showOnlyFavorites = val);
                      },
                    ),
                    // Add more filter widgets here
                  ],
                ),
              );
            },
          );
        },
      );
    }

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
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: HomeUIConstants.primaryRed,
                boxShadow: [
                  BoxShadow(
                    color: HomeUIConstants.primaryRed.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        radius: 24,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentUserName ?? 'Guest',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentUserName != null
                                  ? 'Welcome back!'
                                  : 'Not logged in',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child:
                        currentUserName == null
                            ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: HomeUIConstants.primaryRed,
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  Nav.go(const AuthPage()),
                                );
                              },
                              child: const Text(
                                'Login / Register',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            )
                            : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                if (mounted) Navigator.pop(context);
                              },
                              child: const Text(
                                'Logout',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.person, color: HomeUIConstants.primaryRed),
              title: const Text('Profile'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              hoverColor: HomeUIConstants.primaryRed.withOpacity(0.08),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, Nav.go(const ProfilePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.store, color: HomeUIConstants.primaryRed),
              title: const Text('Your businesses'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              hoverColor: HomeUIConstants.primaryRed.withOpacity(0.08),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, Nav.go(const YourListingsPage()));
              },
            ),
            Divider(
              height: 24,
              indent: 24,
              endIndent: 24,
              color: Colors.grey.withOpacity(0.3),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: HomeUIConstants.primaryRed),
              title: const Text('Settings'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              hoverColor: HomeUIConstants.primaryRed.withOpacity(0.08),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, Nav.go(const SettingsPage()));
              },
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: HomeUIUtils.buildCategoryFilter(
                      selectedCategory: _selectedCategory,
                      onCategoryChanged: (category) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_alt),
                    tooltip: 'Filters',
                    onPressed: openFilterSheet,
                  ),
                ],
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

                  var businesses = snapshot.data!.docs.toList();
                  // Client-side filtering
                  businesses =
                      businesses.where((doc) {
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
                        final matchesFavorite =
                            !_showOnlyFavorites || _favorites.contains(doc.id);
                        return matchesCategory &&
                            matchesSearch &&
                            matchesFavorite;
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
