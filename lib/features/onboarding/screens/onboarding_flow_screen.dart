import 'package:flutter/material.dart';
import '../../../constants/index.dart';
import '../../../commmon_widgets/index.dart';
import 'onboarding_screen_content.dart';

class OnboardingFlowScreen extends StatefulWidget {
  final VoidCallback onOnboardingComplete;

  const OnboardingFlowScreen({super.key, required this.onOnboardingComplete});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  // Onboarding data
  final List<({String title, String description, String image})>
  _onboardingData = [
    (
      title: AppStrings.onboarding1Title,
      description: AppStrings.onboarding1Description,
      image: 'assets/images/onboarding1.jpg',
    ),
    (
      title: AppStrings.onboarding2Title,
      description: AppStrings.onboarding2Description,
      image: 'assets/images/onboarding2.jpg',
    ),
    (
      title: AppStrings.onboarding3Title,
      description: AppStrings.onboarding3Description,
      image: 'assets/images/onboarding3.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Onboarding complete - navigate to next screen
      widget.onOnboardingComplete();
    }
  }

  void _skipOnboarding() {
    widget.onOnboardingComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          // Scrollable PageView with content (takes most of screen)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                final data = _onboardingData[index];
                return OnboardingScreenContent(
                  title: data.title,
                  description: data.description,
                  backgroundImage: data.image,
                  onSkipPressed: _skipOnboarding,
                );
              },
            ),
          ),

          // Fixed bottom section with page indicator and button
          Container(
            color: AppColors.primaryDark,
            padding: EdgeInsets.only(
              left: AppDimensions.paddingLarge,
              right: AppDimensions.paddingLarge,
              top: AppDimensions.paddingXLarge,
              bottom: AppDimensions.paddingXLarge + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Page Indicator (animated)
                PageIndicator(
                  currentPage: _currentPage,
                  totalPages: _onboardingData.length,
                ),

                SizedBox(height: AppDimensions.paddingXLarge),

                // Next/Get Started Button
                PrimaryButton(
                  label: _currentPage == _onboardingData.length - 1
                      ? AppStrings.getStarted
                      : AppStrings.next,
                  onPressed: _nextPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
