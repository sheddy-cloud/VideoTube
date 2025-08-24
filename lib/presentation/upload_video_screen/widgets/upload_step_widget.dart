import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UploadStepWidget extends StatelessWidget {
  final int stepNumber;
  final String title;
  final bool isActive;
  final bool isCompleted;

  const UploadStepWidget({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted || isActive
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.dividerColor,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? CustomIconWidget(
                    iconName: 'check',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 4.w,
                  )
                : Text(
                    stepNumber.toString(),
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: isActive
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        
        SizedBox(height: 1.h),
        
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: isActive || isCompleted
                ? AppTheme.lightTheme.colorScheme.onSurface
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}