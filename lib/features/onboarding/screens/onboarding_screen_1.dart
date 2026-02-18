import 'package:flutter/material.dart';
import '../../../constants/index.dart';
import '../../../commmon_widgets/index.dart';

class OnboardingScreen1 extends StatelessWidget {
  final VoidCallback onNextPressed;
  final VoidCallback onSkipPressed;
  final String backgroundImage;

  const OnboardingScreen1({
    super.key,
    required this.onNextPressed,
    required this.onSkipPressed,
    this.backgroundImage = 'assets/images/onboarding1.jpg',
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with Gradient Overlay
          Container(
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
                      colors: [AppColors.primaryDark, const Color(0xFF1E3A8A)],
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          Column(
            children: [
              // Top Bar with Skip Button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingMedium,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
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
                  ],
                ),
              ),

              // Spacer to push content to bottom
              const Spacer(),

              // Bottom Content Section
              Container(
                padding: EdgeInsets.all(AppDimensions.paddingLarge),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        AppStrings.onboarding1Title,
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
                        AppStrings.onboarding1Description,
                        style: TextStyle(
                          fontSize: AppDimensions.fontSizeLarge,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textGrey,
                          height: AppDimensions.lineHeightLarge,
                        ),
                      ),

                      SizedBox(height: AppDimensions.paddingXLarge),

                      // Page Indicator
                      PageIndicator(currentPage: 0, totalPages: 3),

                      SizedBox(height: AppDimensions.paddingLarge),

                      // Next Button
                      PrimaryButton(
                        label: AppStrings.next,
                        onPressed: onNextPressed,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppDimensions.paddingMedium),
            ],
          ),
        ],
      ),
    );
  }
}
