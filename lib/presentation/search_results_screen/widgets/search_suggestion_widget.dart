import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchSuggestionWidget extends StatelessWidget {
  final String suggestion;
  final bool isHistory;
  final VoidCallback onTap;

  const SearchSuggestionWidget({
    super.key,
    required this.suggestion,
    required this.isHistory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: isHistory ? 'history' : 'trending_up',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            
            SizedBox(width: 3.w),
            
            Expanded(
              child: Text(
                suggestion,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            CustomIconWidget(
              iconName: 'north_west',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }
}