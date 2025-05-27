import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.lightTheme.primaryColor
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(6.w),
          border: Border.all(
            color: isSelected 
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: isSelected 
                ? AppTheme.lightTheme.colorScheme.onPrimary
                : AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}