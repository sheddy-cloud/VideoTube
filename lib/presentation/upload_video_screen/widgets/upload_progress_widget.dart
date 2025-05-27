import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UploadProgressWidget extends StatelessWidget {
  final double progress;
  final String estimatedTime;
  final bool isUploading;
  final bool isPaused;
  final String? errorMessage;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final Animation<double> progressAnimation;

  const UploadProgressWidget({
    super.key,
    required this.progress,
    required this.estimatedTime,
    required this.isUploading,
    required this.isPaused,
    this.errorMessage,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onRetry,
    required this.progressAnimation,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return _buildErrorState();
    }

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildProgressIndicator(),
          
          SizedBox(height: 4.h),
          
          _buildProgressInfo(),
          
          SizedBox(height: 4.h),
          
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 30.w,
              height: 30.w,
              child: AnimatedBuilder(
                animation: progressAnimation,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: progressAnimation.value * progress,
                    strokeWidth: 2.w,
                    backgroundColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPaused
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.primaryColor,
                    ),
                  );
                },
              ),
            ),
            
            Column(
              children: [
                CustomIconWidget(
                  iconName: isPaused ? 'pause' : 'cloud_upload',
                  color: isPaused
                      ? AppTheme.lightTheme.colorScheme.secondary
                      : AppTheme.lightTheme.primaryColor,
                  size: 8.w,
                ),
                
                SizedBox(height: 1.h),
                
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isPaused
                        ? AppTheme.lightTheme.colorScheme.secondary
                        : AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressInfo() {
    return Column(
      children: [
        Text(
          isPaused ? 'Upload Paused' : 'Uploading Video...',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 1.h),
        
        Text(
          isPaused ? 'Tap resume to continue' : estimatedTime,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 2.h),
        
        Container(
          width: double.infinity,
          height: 1.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(0.5.w),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: isPaused
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.lightTheme.primaryColor,
                borderRadius: BorderRadius.circular(0.5.w),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            child: Text('Cancel'),
          ),
        ),
        
        SizedBox(width: 4.w),
        
        Expanded(
          child: ElevatedButton(
            onPressed: isPaused ? onResume : onPause,
            child: Text(isPaused ? 'Resume' : 'Pause'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'error',
            color: AppTheme.lightTheme.colorScheme.error,
            size: 15.w,
          ),
          
          SizedBox(height: 3.h),
          
          Text(
            'Upload Failed',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 1.h),
          
          Text(
            errorMessage!,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 4.h),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.lightTheme.colorScheme.error,
                    side: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.error,
                      width: 1,
                    ),
                  ),
                  child: Text('Cancel'),
                ),
              ),
              
              SizedBox(width: 4.w),
              
              Expanded(
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.error,
                    foregroundColor: AppTheme.lightTheme.colorScheme.onError,
                  ),
                  child: Text('Retry'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}