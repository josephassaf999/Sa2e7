import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:sa2e7/core/services/onboarding_service.dart';
import 'package:sa2e7/core/utils/onboarding_utils.dart';
import 'package:sa2e7/pages/homepage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  Future<void> _finishOnboarding() async {
    await OnboardingService.finishOnboarding();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: OnboardingUIConstants.primaryRed,
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
                      OnboardingUIConstants.skipButton,
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
                      image: OnboardingUIConstants.heroImage,
                      title: OnboardingUIConstants.page1Title,
                      subtitle: OnboardingUIConstants.page1Subtitle,
                    ),
                    buildPage(
                      animation: OnboardingUIConstants.mapAnimation,
                      title: OnboardingUIConstants.page2Title,
                      subtitle: OnboardingUIConstants.page2Subtitle,
                    ),
                    buildPage(
                      animation: OnboardingUIConstants.compassAnimation,
                      title: OnboardingUIConstants.page3Title,
                      subtitle: OnboardingUIConstants.page3Subtitle,
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
                  dotHeight: OnboardingUIUtils.dotHeight,
                  dotWidth: OnboardingUIUtils.dotHeight,
                  expansionFactor: OnboardingUIUtils.expansionFactor,
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
                          duration: OnboardingUIUtils.animationDuration,
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: OnboardingUIUtils.nextButtonStyle(),
                    child: Text(
                      isLastPage
                          ? OnboardingUIConstants.getStartedButton
                          : OnboardingUIConstants.nextButton,
                      style: TextStyle(
                        fontSize: 18,
                        color: OnboardingUIConstants.primaryRed,
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
            child: Lottie.asset(animation, repeat: true, fit: BoxFit.contain),
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
          SizedBox(height: 260, child: Image.asset(image, fit: BoxFit.contain)),
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
