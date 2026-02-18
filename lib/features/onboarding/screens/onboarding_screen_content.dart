import 'package:flutter/material.dart';
import '../../../constants/index.dart';

/// Reusable onboarding screen content that displays image, title, and description.
/// This widget is meant to be used inside a PageView.
class OnboardingScreenContent extends StatelessWidget {
  final String title;
  final String description;
  final String backgroundImage;
  final VoidCallback onSkipPressed;

  const OnboardingScreenContent({
    super.key,
    required this.title,
    required this.description,
    required this.backgroundImage,
    required this.onSkipPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: AppColors.primaryDark,
      child: Column(
        children: [
          // Image Section
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                // Background Image with Gradient Overlay
                Container(
                  width: double.infinity,
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
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryDark,
                              const Color(0xFF1E3A8A),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Skip Button (Top Right)
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
          ),

          // Content Section (Title + Description)
          Expanded(
            flex: 4,
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
                      title,
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
                      description,
                      style: TextStyle(
                        fontSize: AppDimensions.fontSizeLarge,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textGrey,
                        height: AppDimensions.lineHeightLarge,
                      ),
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
