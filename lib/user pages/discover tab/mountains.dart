import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../search tab/user location information page.dart';

class MountainsScreen extends StatelessWidget {
  const MountainsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mountains in Lebanon',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildMountainItem(
            name: 'Mount Lebanon',
            location: 'Western Lebanon',
            imageUrls: [
              'assets/images/mountleb1.jpeg',
              'assets/images/mountleb2.jpeg',
              'assets/images/mountleb3.webp',
            ],
            context: context,
            description:
                'Majestic range offering scenic beauty and diverse ecosystems, with historical significance and recreational opportunities.',
          ),
          _buildMountainItem(
            name: 'Mount Hermon',
            imageUrls: [
              'assets/images/hermon1.jpeg',
              'assets/images/hermon2.jpg',
              'assets/images/hermon3.jpg',
            ],
            location: 'Southern Lebanon',
            context: context,
            description:
                ' Snow-capped peak offering stunning vistas and outdoor activities, rich in biodiversity and cultural heritage.',
          ),
          _buildMountainItem(
            name: 'Mount Sannine',
            location: 'Mount Lebanon Range',
            imageUrls: [
              'assets/images/sannine1.jpg',
              'assets/images/sannine2.webp',
              'assets/images/sannine3.jpg',
            ],
            context: context,
            description:
                'Iconic summit renowned for its panoramic views, hiking trails, and winter sports, nestled in the Mount Lebanon range.',
          ),
          _buildMountainItem(
              name: 'Qornet es-Sawda',
              location: 'Mount Lebanon Range',
              imageUrls: [
                'assets/images/qornet1.jpeg',
                'assets/images/qornet2.jpeg',
                'assets/images/qornet3.jpeg',
              ],
              context: context,
              description:
                  'Lebanons highest peak, offering breathtaking views, challenging hikes, and unique alpine flora and fauna.'),
        ],
      ),
    );
  }

  Widget _buildMountainItem({
    required String name,
    required String location,
    required List<String> imageUrls,
    required BuildContext context,
    required String description,
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
                          fit: BoxFit
                              .fitWidth, // Use BoxFit.fitWidth to maintain image aspect ratio
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
