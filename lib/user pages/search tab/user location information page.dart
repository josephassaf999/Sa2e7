import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class InfoPage extends StatelessWidget {
  final String item;
  final String location;
  final String description;
  final List<String> imageUrls;

  const InfoPage({
    Key? key,
    required this.item,
    required this.location,
    required this.description,
    required this.imageUrls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          item,
          style: TextStyle(color: Colors.white),
        ), // Set the title to display the item name
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 400,
                enableInfiniteScroll: false,
                viewportFraction: 1.0,
                enlargeCenterPage: true, // Enlarge the center slide
                autoPlay: true, // Automatically animate slides
                autoPlayInterval:
                    Duration(seconds: 3), // Slide transition interval
                autoPlayAnimationDuration:
                    Duration(milliseconds: 800), // Animation duration
                pauseAutoPlayOnTouch: true, // Pause auto play on touch
                autoPlayCurve: Curves.fastOutSlowIn, // Animation curve
                scrollDirection: Axis.horizontal, // Set scroll direction
                onPageChanged: (index, reason) {}, // Callback when page changes
              ),
              items: imageUrls.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900, // Make bold text blue
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Location: $location',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900, // Make bold text blue
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset:
          true, // Prevents overflow when the keyboard pops up
    );
  }
}
