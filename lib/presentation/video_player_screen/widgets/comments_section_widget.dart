import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommentsSection extends StatelessWidget {
  final List<Map<String, dynamic>> comments;
  final bool showMoreComments;
  final VoidCallback onToggleMoreComments;
  final Function(String) onCommentLike;

  const CommentsSection({
    super.key,
    required this.comments,
    required this.showMoreComments,
    required this.onToggleMoreComments,
    required this.onCommentLike,
  });

  @override
  Widget build(BuildContext context) {
    final displayedComments = showMoreComments ? comments : comments.take(5).toList();
    
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentsHeader(),
          SizedBox(height: 3.w),
          _buildAddCommentField(),
          SizedBox(height: 4.w),
          ...displayedComments.map((comment) => _buildCommentItem(comment)),
          if (comments.length > 5) _buildViewMoreButton(),
        ],
      ),
    );
  }

  Widget _buildCommentsHeader() {
    return Row(
      children: [
        Text(
          'Comments',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 2.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(3.w),
          ),
          child: Text(
            '${comments.length}',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Spacer(),
        IconButton(
          onPressed: () {
            // Sort comments
          },
          icon: CustomIconWidget(
            iconName: 'sort',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
        ),
      ],
    );
  }

  Widget _buildAddCommentField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6.w),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.primaryColor,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Add a comment...',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          CustomIconWidget(
            iconName: 'send',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final isLiked = comment['isLiked'] as bool;
    
    return Container(
      margin: EdgeInsets.only(bottom: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                imageUrl: comment['avatar'] as String,
                width: 10.w,
                height: 10.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SizedBox(width: 3.w),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment['username'] as String,
                      style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      comment['timestamp'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 1.w),
                
                Text(
                  comment['comment'] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                
                SizedBox(height: 2.w),
                
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => onCommentLike(comment['id'] as String),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: isLiked ? 'thumb_up' : 'thumb_up_outlined',
                            color: isLiked 
                                ? AppTheme.lightTheme.primaryColor
                                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${comment['likes']}',
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: isLiked 
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(width: 4.w),
                    
                    GestureDetector(
                      onTap: () {
                        // Dislike comment
                      },
                      child: CustomIconWidget(
                        iconName: 'thumb_down_outlined',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                    ),
                    
                    SizedBox(width: 4.w),
                    
                    GestureDetector(
                      onTap: () {
                        // Reply to comment
                      },
                      child: Text(
                        'Reply',
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    Spacer(),
                    
                    IconButton(
                      onPressed: () {
                        // More options for comment
                      },
                      icon: CustomIconWidget(
                        iconName: 'more_vert',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                      padding: EdgeInsets.all(1.w),
                      constraints: BoxConstraints(
                        minWidth: 6.w,
                        minHeight: 6.w,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewMoreButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 2.w),
      child: TextButton(
        onPressed: onToggleMoreComments,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 3.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
            side: BorderSide(
              color: AppTheme.lightTheme.dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              showMoreComments ? 'Show less comments' : 'View more comments',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: showMoreComments ? 'expand_less' : 'expand_more',
              color: AppTheme.lightTheme.primaryColor,
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }
}