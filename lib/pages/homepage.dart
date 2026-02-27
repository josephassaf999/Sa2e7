import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sa2e7/drawer/Businesses/Businesses.dart';
import 'package:sa2e7/pages/business_page.dart';
import 'package:sa2e7/pages/messages_page.dart';
import 'package:sa2e7/core/themes/design_tokens.dart';
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

  // Pagination state
  List<QueryDocumentSnapshot> _allLoadedBusinesses = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadFavorites();
    _loadMoreBusinesses(); // Load first page

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
    setState(() {
      _allLoadedBusinesses = [];
      _lastDocument = null;
      _hasMoreData = true;
    });
  }

  Future<void> _loadMoreBusinesses() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);

    try {
      Query query = FirebaseFirestore.instance
          .collection('businesses')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (_lastDocument != null) {
        query = query.startAfter([_lastDocument!['createdAt']]);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasMoreData = false;
          _isLoadingMore = false;
        });
        return;
      }

      setState(() {
        _allLoadedBusinesses.addAll(snapshot.docs);
        _lastDocument = snapshot.docs.last;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading more: $e')),
        );
      }
    }
  }

  Widget _buildBusinessesList() {
    if (_allLoadedBusinesses.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Client-side filtering
    var filteredBusinesses = _allLoadedBusinesses.where((doc) {
      final category = doc['category'] ?? 'All';
      final name = doc['name'] ?? '';
      final matchesCategory =
          _selectedCategory == "All" || category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFavorite =
          !_showOnlyFavorites || _favorites.contains(doc.id);
      return matchesCategory && matchesSearch && matchesFavorite;
    }).toList();

    if (filteredBusinesses.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text(HomeUIConstants.noBusinessesFound),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Add "Load More" button at the end if there's more data
          if (index == filteredBusinesses.length) {
            if (_hasMoreData) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _isLoadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _loadMoreBusinesses,
                        child: const Text('Load More'),
                      ),
              );
            }
            return const SizedBox.shrink();
          }

          final b = filteredBusinesses[index];
          final images = List<String>.from(b['images'] ?? []);
          final imageUrl = images.isNotEmpty
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
                  builder: (_) => BusinessDetailsPage(
                    businessId: businessId,
                  ),
                ),
              );
            },
            onFavoriteTapped: () => _toggleFavorite(businessId),
          );
        },
        childCount: filteredBusinesses.length + (_hasMoreData ? 1 : 0),
      ),
    );
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
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search businesses...",
                    hintStyle: TextStyle(
                      color: (Theme.of(context).appBarTheme.foregroundColor ?? Colors.white)
                          .withOpacity(0.7),
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                )
                : Text(
                  HomeUIConstants.appTitle,
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
                  ),
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
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Logout?'),
                                    content: const Text('Are you sure you want to logout?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dialogContext),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(dialogContext);
                                          await FirebaseAuth.instance.signOut();
                                          if (mounted) Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Logout',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
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
            ListTile(
              leading: Icon(Icons.chat_bubble_outline, color: HomeUIConstants.primaryRed),
              title: const Text('Messages'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              hoverColor: HomeUIConstants.primaryRed.withOpacity(0.08),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, Nav.go(const MessagesPage()));
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
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: HomeUIUtils.buildHeroSection(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GoogleMapPage()),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverToBoxAdapter(
                child: Row(
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
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: const Text(
                  HomeUIConstants.activitiesLabel,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildBusinessesList(),
            ),
          ],
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
