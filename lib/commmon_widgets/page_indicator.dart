import 'package:flutter/material.dart';
import '../../../constants/index.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onDotTap;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => GestureDetector(
          onTap: onDotTap != null ? () => onDotTap!(index) : null,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.indicatorSpacing / 2,
            ),
            width: AppDimensions.indicatorSize,
            height: AppDimensions.indicatorSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == currentPage
                  ? AppColors.indicatorActive
                  : AppColors.indicatorInactive,
            ),
          ),
        ),
      ),
    );
  }
}
