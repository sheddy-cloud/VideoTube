import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VideoFormWidget extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController tagsController;
  final String visibility;
  final Function(String) onVisibilityChanged;
  final String? errorMessage;

  const VideoFormWidget({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.tagsController,
    required this.visibility,
    required this.onVisibilityChanged,
    this.errorMessage,
  });

  @override
  State<VideoFormWidget> createState() => _VideoFormWidgetState();
}

class _VideoFormWidgetState extends State<VideoFormWidget> {
  final List<String> _visibilityOptions = ['Public', 'Unlisted', 'Private'];
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Details',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 3.h),
        
        _buildTitleField(),
        
        SizedBox(height: 3.h),
        
        _buildDescriptionField(),
        
        SizedBox(height: 3.h),
        
        _buildTagsField(),
        
        SizedBox(height: 3.h),
        
        _buildVisibilitySelector(),
        
        if (widget.errorMessage != null) ...[
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
                    widget.errorMessage!,
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

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Title',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            Text(
              ' *',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 1.h),
        
        TextFormField(
          controller: widget.titleController,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: 'Enter video title',
            counterText: '${widget.titleController.text.length}/100',
            suffixIcon: widget.titleController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      widget.titleController.clear();
                      setState(() {});
                    },
                    icon: CustomIconWidget(
                      iconName: 'clear',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        
        SizedBox(height: 1.h),
        
        Text(
          'Choose a title that accurately describes your video content',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Description',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            Text(
              ' *',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 1.h),
        
        TextFormField(
          controller: widget.descriptionController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Tell viewers about your video',
            counterText: '${widget.descriptionController.text.length}/500',
            alignLabelWithHint: true,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        
        SizedBox(height: 1.h),
        
        Text(
          'Add a description to help viewers understand what your video is about',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 1.h),
        
        TextFormField(
          controller: widget.tagsController,
          decoration: InputDecoration(
            hintText: 'Add tags separated by commas',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'tag',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
          ),
        ),
        
        SizedBox(height: 1.h),
        
        Text(
          'Tags help people discover your video. Use relevant keywords.',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visibility',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 2.h),
        
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.lightTheme.dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Column(
            children: _visibilityOptions.map((option) {
              final isSelected = widget.visibility == option;
              final index = _visibilityOptions.indexOf(option);
              
              return GestureDetector(
                onTap: () => widget.onVisibilityChanged(option),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: index == 0
                        ? BorderRadius.vertical(top: Radius.circular(2.w))
                        : index == _visibilityOptions.length - 1
                            ? BorderRadius.vertical(bottom: Radius.circular(2.w))
                            : BorderRadius.zero,
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: _getVisibilityIcon(option),
                        color: isSelected
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 6.w,
                      ),
                      
                      SizedBox(width: 4.w),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option,
                              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppTheme.lightTheme.primaryColor
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                            
                            SizedBox(height: 0.5.h),
                            
                            Text(
                              _getVisibilityDescription(option),
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (isSelected)
                        CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 6.w,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getVisibilityIcon(String visibility) {
    switch (visibility) {
      case 'Public':
        return 'public';
      case 'Unlisted':
        return 'link';
      case 'Private':
        return 'lock';
      default:
        return 'public';
    }
  }

  String _getVisibilityDescription(String visibility) {
    switch (visibility) {
      case 'Public':
        return 'Anyone can search for and view this video';
      case 'Unlisted':
        return 'Anyone with the link can view this video';
      case 'Private':
        return 'Only you can view this video';
      default:
        return '';
    }
  }
}