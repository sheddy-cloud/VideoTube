import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VideoInfoWidget extends StatelessWidget {
  final Map<String, dynamic> videoData;
  final bool isSubscribed;
  final bool isLiked;
  final bool isDisliked;
  final VoidCallback onSubscribePressed;
  final VoidCallback onLikePressed;
  final VoidCallback onDislikePressed;

  const VideoInfoWidget({
    super.key,
    required this.videoData,
    required this.isSubscribed,
    required this.isLiked,
    required this.isDisliked,
    required this.onSubscribePressed,
    required this.onLikePressed,
    required this.onDislikePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVideoTitle(),
          SizedBox(height: 3.w),
          _buildVideoStats(),
          SizedBox(height: 4.w),
          _buildChannelInfo(),
          SizedBox(height: 4.w),
          _buildActionButtons(),
          SizedBox(height: 4.w),
          _buildVideoDescription(),
        ],
      ),
    );
  }

  Widget _buildVideoTitle() {
    return Text(
      videoData['title'] as String,
      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildVideoStats() {
    return Row(
      children: [
        Text(
          '${videoData['views']} views',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
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
          videoData['uploadTime'] as String,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildChannelInfo() {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.lightTheme.dividerColor,
              width: 1,
            ),
          ),
          child: ClipOval(
            child: CustomImageWidget(
              imageUrl: videoData['channelAvatar'] as String,
              width: 12.w,
              height: 12.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        SizedBox(width: 3.w),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                videoData['channelName'] as String,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.w),
              Text(
                '${videoData['channelSubscribers']} subscribers',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        ElevatedButton(
          onPressed: onSubscribePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSubscribed 
                ? AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                : AppTheme.lightTheme.primaryColor,
            foregroundColor: isSubscribed 
                ? AppTheme.lightTheme.colorScheme.onSurface
                : AppTheme.lightTheme.colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.w),
            ),
          ),
          child: Text(
            isSubscribed ? 'Subscribed' : 'Subscribe',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton(
          icon: 'thumb_up',
          label: videoData['likes'] as String,
          isActive: isLiked,
          onPressed: onLikePressed,
        ),
        
        SizedBox(width: 4.w),
        
        _buildActionButton(
          icon: 'thumb_down',
          label: videoData['dislikes'] as String,
          isActive: isDisliked,
          onPressed: onDislikePressed,
        ),
        
        SizedBox(width: 4.w),
        
        _buildActionButton(
          icon: 'share',
          label: 'Share',
          isActive: false,
          onPressed: () {
            // Share functionality
          },
        ),
        
        SizedBox(width: 4.w),
        
        _buildActionButton(
          icon: 'download',
          label: 'Download',
          isActive: false,
          onPressed: () {
            // Download functionality
          },
        ),
        
        Spacer(),
        
        IconButton(
          onPressed: () {
            // More actions
          },
          icon: CustomIconWidget(
            iconName: 'more_horiz',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 6.w,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
        decoration: BoxDecoration(
          color: isActive 
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6.w),
          border: isActive ? Border.all(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isActive 
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isActive 
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoDescription() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.w),
          Text(
            videoData['description'] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.w),
          GestureDetector(
            onTap: () {
              // Show full description
            },
            child: Text(
              'Show more',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}