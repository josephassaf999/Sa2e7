import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../search tab/user location information page.dart';

class BeachesScreen extends StatelessWidget {
  const BeachesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Beaches in Lebanon',
          style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildBeachItem(
            name: 'Ramlat al-Baida Beach',
            location: 'Batroun',
            description:
                'Pristine white sands and clear blue waters make this beach a tranquil haven for relaxation and water activities.',
            imageUrls: [
              'assets/images/ramlet el bayda 1.jpeg',
              'assets/images/ramlet el bayda 2.jpeg',
              'assets/images/ramlet el bayda 3.jpeg',
            ],
            context: context,
          ),
          _buildBeachItem(
            name: 'Tyre Beach',
            location: 'Tyre',
            imageUrls: [
              'assets/images/tyre1.jpg',
              'assets/images/tyre2.jpg',
              'assets/images/tyre3.jpg',
            ],
            context: context,
            description:
                'Popular coastal destination offering golden sands, azure waters, and vibrant seaside promenades with restaurants and cafes.',
          ),
          _buildBeachItem(
            name: 'Anfeh Beach',
            location: 'Anfeh',
            imageUrls: [
              'assets/images/anfeh1.jpg',
              'assets/images/anfeh2.jpeg',
              'assets/images/anfeh3.webp',
            ],
            context: context,
            description:
                'Serene Mediterranean coastline known for its rocky coves, turquoise waters, and picturesque fishing villages.',
          ),
          _buildBeachItem(
            name: 'Rawsheh Beach',
            location: 'Beirut',
            imageUrls: [
              'assets/images/rawsheh1.jpeg',
              'assets/images/rawsheh2.jpeg',
              'assets/images/rawsheh3.avif',
            ],
            context: context,
            description:
                'Urban beachfront with stunning views of Beiruts skyline, offering sandy shores, clear waters, and seaside amenities.',
          ),
        ],
      ),
    );
  }

  Widget _buildBeachItem({
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
              description: description,
              imageUrls: imageUrls,
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
