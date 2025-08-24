import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchResultCardWidget extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onTap;

  const SearchResultCardWidget({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = result['type'] == 'video';
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isVideo ? 20.w : 16.w,
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
            if (isVideo) _buildVideoThumbnail() else _buildChannelAvatar(),
            Expanded(
              child: _buildResultInfo(isVideo),
            ),
            _buildMoreButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(2.w)),
          child: SizedBox(
            width: 35.w,
            height: 20.w,
            child: CustomImageWidget(
              imageUrl: result['thumbnail'] as String,
              width: 35.w,
              height: 20.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // Duration overlay
        Positioned(
          bottom: 1.w,
          right: 1.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(1.w),
            ),
            child: Text(
              result['duration'] as String,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 8.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChannelAvatar() {
    return Container(
      width: 20.w,
      height: 16.w,
      padding: EdgeInsets.all(2.w),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
        child: ClipOval(
          child: CustomImageWidget(
            imageUrl: result['channelAvatar'] as String,
            width: 16.w,
            height: 16.w,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildResultInfo(bool isVideo) {
    return Padding(
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            result['title'] as String,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: isVideo ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: 1.w),
          
          if (isVideo) _buildVideoInfo() else _buildChannelInfo(),
        ],
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result['channelName'] as String,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: 0.5.w),
        
        Row(
          children: [
            Text(
              '${result['views']} views',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontSize: 10.sp,
              ),
            ),
            
            Container(
              margin: EdgeInsets.symmetric(horizontal: 1.5.w),
              width: 1.w,
              height: 1.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
            
            Text(
              result['uploadTime'] as String,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChannelInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result['subscribers'] as String,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: 0.5.w),
        
        Text(
          result['description'] as String,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontSize: 10.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMoreButton() {
    return SizedBox(
      width: 10.w,
      child: IconButton(
        onPressed: () {
          // Show more options
        },
        icon: CustomIconWidget(
          iconName: 'more_vert',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 4.w,
        ),
        padding: EdgeInsets.all(1.w),
        constraints: BoxConstraints(
          minWidth: 8.w,
          minHeight: 8.w,
        ),
      ),
    );
  }
}