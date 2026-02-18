import 'package:flutter/material.dart';
import '../../../constants/index.dart';
import '../../../commmon_widgets/index.dart';

class OnboardingScreen3 extends StatelessWidget {
  final VoidCallback onNextPressed;
  final VoidCallback onSkipPressed;
  final String backgroundImage;

  const OnboardingScreen3({
    super.key,
    required this.onNextPressed,
    required this.onSkipPressed,
    this.backgroundImage = 'assets/images/onboarding3.jpg',
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          // Image Section (Top ~60%)
          Stack(
            children: [
              // Background Image
              Container(
                height: screenHeight * 0.6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.darkGradient,
                  ),
                ),
                child: Image.asset(
                  backgroundImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback gradient if image not found
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryDark,
                            const Color(0xFF0C4A6E),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Skip Button (Overlay)
              Positioned(
                top: AppDimensions.paddingMedium + 50,
                right: AppDimensions.paddingLarge,
                child: GestureDetector(
                  onTap: onSkipPressed,
                  child: const Text(
                    AppStrings.skip,
                    style: TextStyle(
                      fontSize: AppDimensions.fontSizeLarge,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content Section (Bottom ~40%)
          Expanded(
            child: Container(
              color: AppColors.primaryDark,
              padding: EdgeInsets.all(AppDimensions.paddingLarge),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      AppStrings.onboarding3Title,
                      style: TextStyle(
                        fontSize: isMobile
                            ? AppDimensions.fontSizeXXLarge
                            : AppDimensions.fontSizeXXXLarge,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                        height: AppDimensions.lineHeightLarge,
                      ),
                    ),

                    SizedBox(height: AppDimensions.paddingLarge),

                    // Description
                    Text(
                      AppStrings.onboarding3Description,
                      style: TextStyle(
                        fontSize: AppDimensions.fontSizeLarge,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textGrey,
                        height: AppDimensions.lineHeightLarge,
                      ),
                    ),

                    SizedBox(height: AppDimensions.paddingXLarge),

                    // Page Indicator
                    PageIndicator(currentPage: 2, totalPages: 3),

                    SizedBox(height: AppDimensions.paddingLarge),

                    // Next Button (Changes to Get Started on last screen)
                    PrimaryButton(
                      label: AppStrings.getStarted,
                      onPressed: onNextPressed,
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
}
