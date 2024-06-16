import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../search tab/user location information page.dart';

class HistoricalSitesScreen extends StatelessWidget {
  const HistoricalSitesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historical Sites in Lebanon',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildHistoricalSiteItem(
            name: 'Baalbek',
            location: 'Baalbek, Beqaa Valley',
            imageUrls: [
              'assets/images/baalbek1.webp',
              'assets/images/baalbek2.jpg',
              'assets/images/baalbek3.webp',
            ],
            context: context,
            description:
                'Ancient city known for its monumental Roman ruins, including the Temple of Bacchus and Temple of Jupiter.',
          ),
          _buildHistoricalSiteItem(
            name: 'Byblos',
            location: 'Byblos, Mount Lebanon',
            imageUrls: [
              'assets/images/byblos1.jpg',
              'assets/images/byblos2.jpg',
              'assets/images/byblos3.jpg',
            ],
            context: context,
            description:
                'Historic port city renowned for its well-preserved Phoenician ruins, picturesque harbor, and vibrant cultural scene.',
          ),
          _buildHistoricalSiteItem(
            name: 'Tyre',
            location: 'Tyre, South Governorate',
            imageUrls: [
              'assets/images/htyre1.webp',
              'assets/images/htyre2.webp',
              'assets/images/htyre3.jpg',
            ],
            context: context,
            description:
                'Coastal city with a rich history dating back to Phoenician times, featuring impressive archaeological sites and sandy beaches.',
          ),
          _buildHistoricalSiteItem(
            name: 'Anjar',
            location: 'Anjar, Beqaa Valley',
            imageUrls: [
              'assets/images/anjar1.jpg',
              'assets/images/anjar2.png',
              'assets/images/anjar3.jpg',
            ],
            context: context,
            description:
                'UNESCO-listed archaeological site showcasing the ruins of an Umayyad city, with well-preserved structures and intricate mosaics.',
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalSiteItem({
    required String name,
    required String location,
    required String description,
    required List<String> imageUrls,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InfoPage(
              item: name,
              location: location,
              imageUrls: imageUrls,
              description: description,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 200, // Adjust the height of the carousel
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                ),
                items: imageUrls.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          height: 150, // Set a fixed height for the images
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
