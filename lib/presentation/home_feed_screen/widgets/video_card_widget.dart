import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VideoCardWidget extends StatelessWidget {
  final Map<String, dynamic> video;
  final VoidCallback onTap;

  const VideoCardWidget({
    super.key,
    required this.video,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(),
            _buildVideoInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(3.w)),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: CustomImageWidget(
              imageUrl: video['thumbnail'] as String,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // Duration overlay
        Positioned(
          bottom: 2.w,
          right: 2.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(1.w),
            ),
            child: Text(
              video['duration'] as String,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        // Play button overlay
        Positioned.fill(
          child: Center(
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'play_arrow',
                  color: Colors.white,
                  size: 8.w,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoInfo() {
    return Padding(
      padding: EdgeInsets.all(3.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Channel avatar
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: video['channelAvatar'] as String,
                width: 10.w,
                height: 10.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SizedBox(width: 3.w),
          
          // Video details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video['title'] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 1.w),
                
                Text(
                  video['channelName'] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 1.w),
                
                Row(
                  children: [
                    Text(
                      '${video['views']} views',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      width: 1.w,
                      height: 1.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    
                    Text(
                      video['uploadTime'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // More options button
          IconButton(
            onPressed: () {
              // Show more options
            },
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            padding: EdgeInsets.all(1.w),
            constraints: BoxConstraints(
              minWidth: 8.w,
              minHeight: 8.w,
            ),
          ),
        ],
      ),
    );
  }
}