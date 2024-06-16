import 'package:flutter/material.dart';
import 'package:Sa2e7/intro%20pages/intropage1.dart';
import 'package:Sa2e7/intro%20pages/intropage2.dart';
import 'package:Sa2e7/intro%20pages/intropage3.dart';
import 'package:Sa2e7/welcome/welcome.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  bool onLastPage = false;
  bool onFirstPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
                onFirstPage = (index == 0);
              });
            },
            children: const [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),
          // Dot indicator
          Container(
            alignment: const Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Previous
                onFirstPage
                    ? MaterialButton(
                        onPressed: () {
                          _controller.jumpToPage(onLastPage as int);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: Colors.blue.shade200,
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : MaterialButton(
                        onPressed: () {
                          _controller.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: Colors.blue.shade200,
                        child: const Text(
                          'Previous',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                // Empty space if on the first page
                const SizedBox(width: 0),

                // Dot indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: const WormEffect(
                    // Use the Worm effect
                    dotColor: Colors.white,
                    activeDotColor:
                        Colors.blue, // Change active dot color to blue
                  ),
                ),

                // Next or Done
                onLastPage
                    ? MaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomePage(),
                            ),
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: Colors.blue,
                        child: const Text(
                          'Done',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : MaterialButton(
                        onPressed: () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: Colors.blue,
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
