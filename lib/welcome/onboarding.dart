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

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool isLastPage = false;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await OnboardingService.finishOnboarding();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  void _resetAnimations() {
    _slideController.reset();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page content
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
                isLastPage = index == 2;
              });
              _resetAnimations();
            },
            children: [
              buildFullScreenPage(
                isImage: true,
                imageOrAnimation: OnboardingUIConstants.heroImage,
                title: OnboardingUIConstants.page1Title,
                subtitle: OnboardingUIConstants.page1Subtitle,
              ),
              buildFullScreenPage(
                isImage: false,
                imageOrAnimation: OnboardingUIConstants.mapAnimation,
                title: OnboardingUIConstants.page2Title,
                subtitle: OnboardingUIConstants.page2Subtitle,
              ),
              buildFullScreenPage(
                isImage: false,
                imageOrAnimation: OnboardingUIConstants.compassAnimation,
                title: OnboardingUIConstants.page3Title,
                subtitle: OnboardingUIConstants.page3Subtitle,
              ),
            ],
          ),

          // Overlay gradient (bottom fade)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    OnboardingUIUtils.backgroundGradient().colors[1],
                    OnboardingUIUtils.backgroundGradient().colors[1]
                        .withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Content card with animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _slideController,
                        child: Column(
                          children: [
                            Text(
                              _getTitle(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getSubtitle(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Page indicator
                    SmoothPageIndicator(
                      controller: _controller,
                      count: 3,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Colors.white,
                        dotColor: Colors.white.withOpacity(0.3),
                        dotHeight: OnboardingUIUtils.dotHeight,
                        dotWidth: OnboardingUIUtils.dotHeight,
                        expansionFactor: OnboardingUIUtils.expansionFactor,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Buttons row
                    Row(
                      children: [
                        // Skip / Back button
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              if (currentPage > 0) {
                                _controller.previousPage(
                                  duration: OnboardingUIUtils.animationDuration,
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _finishOnboarding();
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              currentPage > 0
                                  ? OnboardingUIConstants.backButton
                                  : OnboardingUIConstants.skipButton,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Next / Get Started button
                        Expanded(
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
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isLastPage
                                  ? OnboardingUIConstants.getStartedButton
                                  : OnboardingUIConstants.nextButton,
                              style: const TextStyle(
                                color: OnboardingUIConstants.primaryRed,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFullScreenPage({
    required bool isImage,
    required String imageOrAnimation,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: OnboardingUIUtils.backgroundGradient(),
      ),
      child: Stack(
        children: [
          // Background content (image or animation)
          if (isImage)
            Center(
              child: SizedBox(
                height: 650,
                width: 600,
                child: Image.asset(imageOrAnimation, fit: BoxFit.contain),
              ),
            )
          else
            Center(
              child: SizedBox(
                height: 350,
                child: Lottie.asset(
                  imageOrAnimation,
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (currentPage) {
      case 0:
        return OnboardingUIConstants.page1Title;
      case 1:
        return OnboardingUIConstants.page2Title;
      case 2:
        return OnboardingUIConstants.page3Title;
      default:
        return '';
    }
  }

  String _getSubtitle() {
    switch (currentPage) {
      case 0:
        return OnboardingUIConstants.page1Subtitle;
      case 1:
        return OnboardingUIConstants.page2Subtitle;
      case 2:
        return OnboardingUIConstants.page3Subtitle;
      default:
        return '';
    }
  }
}
