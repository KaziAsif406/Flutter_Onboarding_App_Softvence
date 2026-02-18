import 'package:flutter/material.dart';
import '../screens/index.dart';

class OnboardingFlowScreen extends StatefulWidget {
  final VoidCallback onOnboardingComplete;

  const OnboardingFlowScreen({super.key, required this.onOnboardingComplete});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

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
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Onboarding complete
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
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          OnboardingScreen1(
            onNextPressed: _nextPage,
            onSkipPressed: _skipOnboarding,
            backgroundImage: 'assets/images/onboarding1.jpg',
          ),
          OnboardingScreen2(
            onNextPressed: _nextPage,
            onSkipPressed: _skipOnboarding,
            backgroundImage: 'assets/images/onboarding2.jpg',
          ),
          OnboardingScreen3(
            onNextPressed: _nextPage,
            onSkipPressed: _skipOnboarding,
            backgroundImage: 'assets/images/onboarding3.jpg',
          ),
        ],
      ),
    );
  }
}
