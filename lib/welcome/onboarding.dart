import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';

import '../pages/homepage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  final Color red = const Color(0xFFED1C24);

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: red, // solid red background
        child: SafeArea(
          child: Column(
            children: [
              // --- Skip button ---
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 16),
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() => isLastPage = index == 2);
                  },
                  children: [
                    buildPageImage(
                      image: "assets/image/lebhero.png", // static image
                      title: "Welcome to Sa2e7",
                      subtitle:
                      "Discover destinations, experiences, and hidden gems around you.",
                    ),
                    buildPage(
                      animation: "assets/lottie/Map.json",
                      title: "Plan Your Journey",
                      subtitle:
                      "Find places, activities, and trips that match your vibe.",
                    ),
                    buildPage(
                      animation: "assets/lottie/Compass.json",
                      title: "Explore With Confidence",
                      subtitle:
                      "Navigate easily and make every adventure unforgettable.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white.withOpacity(0.5),
                  dotHeight: 10,
                  dotWidth: 10,
                  expansionFactor: 3,
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLastPage) {
                        _finishOnboarding();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      isLastPage ? "Get Started" : "Next",
                      style: TextStyle(
                        fontSize: 18,
                        color: red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- Page Builder for Lottie ---
  Widget buildPage({
    required String animation,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 260,
            child: Lottie.asset(
              animation,
              repeat: true,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // --- Page Builder for Static Image ---
  Widget buildPageImage({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 260,
            child: Image.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
