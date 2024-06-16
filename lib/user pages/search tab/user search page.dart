import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../search tab/user location information page.dart';

class Destination {
  final String name;
  final String location;
  final String description;

  Destination({
    required this.name,
    required this.location,
    required this.description,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();

  void _performSearch(String query) {
    // Clear previous search results
    _searchResults.clear();

    // Perform search in Firestore
    FirebaseFirestore.instance
        .collection('Destinations')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        _searchResults = querySnapshot.docs
            .map((doc) => Destination(
                  name: doc['name'] as String,
                  location: doc['location'] as String,
                  description: doc['description'] as String,
                ))
            .toList();
      });
    });
  }

  List<Destination> _searchResults = [];

  void _navigateToInfoPage(
      BuildContext context, Destination destination) async {
    List<String> imageUrls = await _getImageUrlsForItem(destination.name);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoPage(
          item: destination.name,
          location: destination.location,
          description: destination.description,
          imageUrls: imageUrls,
        ),
      ),
    );
  }

  Future<List<String>> _getImageUrlsForItem(String itemName) async {
    List<String> assetPaths = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Destinations')
          .where('name', isEqualTo: itemName)
          .get();

      querySnapshot.docs.forEach((doc) {
        if (doc.exists) {
          List<dynamic> urls = doc['imageUrls'];
          assetPaths.addAll(urls.map((url) => "$url"));
        }
      });
    } catch (error) {
      print("Error fetching image URLs: $error");
    }

    return assetPaths;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue, // Set app bar color to blue
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search locations and activities',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    String query = _searchController.text.trim();
                    _performSearch(query);
                  },
                ),
              ),
              onChanged: (value) {
                String query = value.trim();
                _performSearch(query);
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _searchResults.isNotEmpty
                  ? ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (BuildContext context, int index) {
                        final result = _searchResults[index];
                        return GestureDetector(
                          onTap: () {
                            _navigateToInfoPage(context, result);
                          },
                          child: Card(
                            elevation: 3.0,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                result.name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(result.location),
                              trailing: Icon(Icons.arrow_forward_ios),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'No search results',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
