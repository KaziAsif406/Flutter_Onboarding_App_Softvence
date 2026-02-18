import 'package:flutter/material.dart';
import '../../../constants/index.dart';

/// Reusable onboarding screen content that displays image, title, and description.
/// This widget is meant to be used inside a PageView.
/// The page indicator and button are managed by the parent (OnboardingFlowScreen).
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenHeight * 0.48; // 48% of screen height

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          // Image Section with Rounded Bottom Corners
          Stack(
            children: [
              // Image with ClipRRect for rounded corners
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                child: Container(
                  height: imageHeight,
                  width: screenWidth,
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
              ),

              // Skip Button (Top Right)
              Positioned(
                top: AppDimensions.paddingLarge + 50,
                right: AppDimensions.paddingLarge,
                child: GestureDetector(
                  onTap: onSkipPressed,
                  child: const Text(
                    AppStrings.skip,
                    style: TextStyle(
                      fontSize: AppDimensions.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content Section - Title & Description
          Expanded(
            child: Container(
              color: AppColors.primaryDark,
              padding: EdgeInsets.only(
                left: AppDimensions.paddingLarge,
                right: AppDimensions.paddingLarge,
                top: AppDimensions.paddingXLarge,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeXXXLarge,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: AppDimensions.paddingMedium),

                    // Description
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSizeMedium,
                        fontWeight: FontWeight.w400,
                        color: Color(0xB3FFFFFF), // White with 70% opacity
                        height: 1.6,
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
