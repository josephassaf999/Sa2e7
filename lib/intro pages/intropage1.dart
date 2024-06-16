import 'package:flutter/material.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Background color
      child: Stack(
        children: [
          // Centered asset image
          Center(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/onboardpic1.jpg'), // Replace with your asset image path
                  fit: BoxFit.cover, // Cover the entire area
                ),
              ),
            ),
          ),
          Center(
            heightFactor: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Welcome to Sa2e7!!\n'
                'The number one travel guide in Lebanon.',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 25,
                  color: Colors.black, // Make the text black
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
