import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ThumbnailSelectorWidget extends StatelessWidget {
  final List<String> thumbnails;
  final int selectedIndex;
  final Function(int) onThumbnailSelected;

  const ThumbnailSelectorWidget({
    super.key,
    required this.thumbnails,
    required this.selectedIndex,
    required this.onThumbnailSelected,
  });

  Widget _buildThumb(String pathOrUrl) {
    if (pathOrUrl.startsWith('http')) {
      return CustomImageWidget(
        imageUrl: pathOrUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
    final file = File(pathOrUrl);
    return Image.file(
      file,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Thumbnail',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 2.h),
        
        SizedBox(
          height: 20.w * 9 / 16,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: thumbnails.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              
              return GestureDetector(
                onTap: () => onThumbnailSelected(index),
                child: Container(
                  width: 30.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.dividerColor,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2.w),
                        child: _buildThumb(thumbnails[index]),
                      ),
                      
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                            child: Center(
                              child: Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: 'check',
                                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                                    size: 5.w,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      // Frame indicator
                      Positioned(
                        bottom: 1.w,
                        left: 1.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        SizedBox(height: 1.h),
        
        Text(
          'Choose the best frame to represent your video',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}