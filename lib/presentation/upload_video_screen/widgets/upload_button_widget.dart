import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UploadButtonWidget extends StatelessWidget {
  final Function(String) onVideoSelected;
  final String? errorMessage;

  const UploadButtonWidget({
    super.key,
    required this.onVideoSelected,
    this.errorMessage,
  });

  void _showVideoSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 1.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(0.5.w),
              ),
            ),
            
            SizedBox(height: 4.h),
            
            Text(
              'Select Video Source',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            SizedBox(height: 4.h),
            
            _buildSourceOption(
              context,
              icon: 'photo_library',
              title: 'Choose from Gallery',
              subtitle: 'Select an existing video from your device',
              onTap: () {
                Navigator.pop(context);
                _selectFromGallery();
              },
            ),
            
            SizedBox(height: 3.h),
            
            _buildSourceOption(
              context,
              icon: 'videocam',
              title: 'Record Video',
              subtitle: 'Record a new video with your camera',
              onTap: () {
                Navigator.pop(context);
                _recordVideo();
              },
            ),
            
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
              ),
            ),
            
            SizedBox(width: 4.w),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 0.5.h),
                  
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }

  void _selectFromGallery() {
    // Simulate gallery selection
    Future.delayed(const Duration(milliseconds: 500), () {
      onVideoSelected('/path/to/selected/video.mp4');
    });
  }

  void _recordVideo() {
    // Simulate video recording
    Future.delayed(const Duration(milliseconds: 500), () {
      onVideoSelected('/path/to/recorded/video.mp4');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showVideoSourceDialog(context),
          child: Container(
            width: double.infinity,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(
                color: errorMessage != null
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.primaryColor,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'cloud_upload',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 10.w,
                    ),
                  ),
                ),
                
                SizedBox(height: 3.h),
                
                Text(
                  'Upload Video',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                SizedBox(height: 1.h),
                
                Text(
                  'Tap to select a video from gallery or record new',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 2.h),
                
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    borderRadius: BorderRadius.circular(6.w),
                  ),
                  child: Text(
                    'Choose Video',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (errorMessage != null) ...[
          SizedBox(height: 2.h),
          
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 5.w,
                ),
                
                SizedBox(width: 3.w),
                
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}