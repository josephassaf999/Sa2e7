import 'package:flutter/material.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({Key? key}) : super(key: key);

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
                      'assets/images/onboardpic3.jpg'), // Replace with your asset image path
                  fit: BoxFit.cover, // Cover the entire area
                ),
              ),
            ),
          ),
          // Positioned container for the text
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "So? \n What are we waiting for? \nLet's get started!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto', // Custom font family
                    fontSize: 25,
                    color: Colors.black, // Make the text black
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
