import 'package:flutter/material.dart';

// Import screens for each category
import 'beaches.dart';
import 'historical_sites.dart';
import 'mountains.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Discover',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white), // No shadow
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore Amazing Places',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            _buildFeatureItem(
              title: 'Beaches',
              imageUrl: 'assets/images/sa2e7 beaches.webp',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BeachesScreen()),
                );
              },
            ),
            SizedBox(height: 10),
            _buildFeatureItem(
              title: 'Mountains',
              imageUrl: 'assets/images/sa2e7 mountain.webp',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MountainsScreen()),
                );
              },
            ),
            SizedBox(height: 10),
            _buildFeatureItem(
              title: 'Historical Sites',
              imageUrl: 'assets/images/sa2e7 historical site.jpg',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HistoricalSitesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required String title,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Image.asset(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
