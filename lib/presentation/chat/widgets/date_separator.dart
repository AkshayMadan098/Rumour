import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DateSeparator extends StatelessWidget {
  const DateSeparator({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.datePillBg : AppColors.lightIncoming,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isDark
                      ? AppColors.secondaryText
                      : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
          ),
        ),
      ),
    );
  }
}
