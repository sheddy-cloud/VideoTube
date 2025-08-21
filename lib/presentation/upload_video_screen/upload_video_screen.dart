import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/thumbnail_selector_widget.dart';
import './widgets/upload_button_widget.dart';
import './widgets/upload_progress_widget.dart';
import './widgets/upload_step_widget.dart';
import './widgets/video_form_widget.dart';
import '../../core/services/upload_service.dart';
import 'package:dio/dio.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isUploading = false;
  bool _uploadCompleted = false;
  double _uploadProgress = 0.0;
  String _estimatedTime = '';
  String? _selectedVideoPath;
  String? _errorMessage;
  bool _isPaused = false;
  CancelToken? _cancelToken;
  
  // Form data
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String _visibility = 'Public';
  int _selectedThumbnailIndex = 0;
  
  Map<String, dynamic>? _selectedVideoMeta; // fileName, size, duration, format, resolution, thumbnails

  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _progressAnimationController.dispose();
    _cancelToken?.cancel('Disposed');
    super.dispose();
  }

  void _onVideoSelected(String videoPath) {
    setState(() {
      _selectedVideoPath = videoPath;
      _errorMessage = null;
      _currentStep = 1;
      // Minimal metadata from path; server can probe actual details after upload
      _selectedVideoMeta = {
        'fileName': videoPath.split('/').last,
        'size': '--',
        'duration': '--',
        'format': 'MP4',
        'resolution': '--',
        'thumbnails': <String>[],
      };
    });
  }

  void _onFormSubmitted() {
    if (_validateForm()) {
      setState(() {
        _currentStep = 2;
      });
      _startUpload();
    }
  }

  bool _validateForm() {
    if (_titleController.text.trim().length < 5) {
      setState(() {
        _errorMessage = 'Title must be at least 5 characters long';
      });
      return false;
    }
    if (_titleController.text.trim().length > 100) {
      setState(() {
        _errorMessage = 'Title must not exceed 100 characters';
      });
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Description is required';
      });
      return false;
    }
    setState(() {
      _errorMessage = null;
    });
    return true;
  }

  void _startUpload() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _isPaused = false;
    });
    _cancelToken = CancelToken();
    try {
      final videoId = await UploadService.I.uploadVideo(
        filePath: _selectedVideoPath!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        visibility: _visibility,
        tags: _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
        selectedThumbnailIndex: _selectedThumbnailIndex,
        cancelToken: _cancelToken,
        onProgress: (sent, total) {
          if (total > 0 && mounted && _isUploading && !_isPaused) {
            final p = sent / total;
            setState(() {
              _uploadProgress = p;
              _estimatedTime = _calculateEstimatedTime((p * 100).round());
            });
            _progressAnimationController.animateTo(_uploadProgress);
          }
        },
      );
      if (!mounted) return;
      setState(() {
        _uploadCompleted = true;
        _isUploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _errorMessage = 'Upload failed. Please try again.';
      });
    }
  }

  String _calculateEstimatedTime(int progress) {
    if (progress == 0) return '-- min remaining';
    int remainingSeconds = ((100 - progress) * 2);
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')} remaining';
  }

  void _pauseUpload() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeUpload() {
    setState(() {
      _isPaused = false;
    });
    // Note: Resuming true HTTP upload requires server support; restart upload for now
    _startUpload();
  }

  void _cancelUpload() {
    setState(() {
      _isUploading = false;
      _uploadProgress = 0.0;
      _currentStep = 0;
      _selectedVideoPath = null;
      _uploadCompleted = false;
      _isPaused = false;
    });
    _titleController.clear();
    _descriptionController.clear();
    _tagsController.clear();
    _progressAnimationController.reset();
    _cancelToken?.cancel('User cancelled');
  }

  void _retryUpload() {
    setState(() {
      _errorMessage = null;
      _uploadProgress = 0.0;
      _isPaused = false;
    });
    _startUpload();
  }

  void _shareVideo() {
    // Share functionality
  }

  void _goToHomeFeed() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home-feed-screen',
      (route) => false,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
              padding: EdgeInsets.all(2.w),
            ),
            
            SizedBox(width: 2.w),
            
            Expanded(
              child: Text(
                _uploadCompleted ? 'Upload Complete' : 'Upload Video',
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            if (_currentStep > 0 && !_isUploading && !_uploadCompleted)
              TextButton(
                onPressed: _cancelUpload,
                child: Text('Cancel'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    if (_uploadCompleted) return const SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...[
            UploadStepWidget(
              stepNumber: i + 1,
              title: _getStepTitle(i),
              isActive: _currentStep == i,
              isCompleted: _currentStep > i,
            ),
            if (i < 2)
              Expanded(
                child: Container(
                  height: 2,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: _currentStep > i 
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.lightTheme.dividerColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Select Video';
      case 1:
        return 'Add Details';
      case 2:
        return 'Upload';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    if (_uploadCompleted) {
      return _buildSuccessState();
    }

    switch (_currentStep) {
      case 0:
        return _buildVideoSelectionStep();
      case 1:
        return _buildVideoFormStep();
      case 2:
        return _buildUploadProgressStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildVideoSelectionStep() {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          children: [
            SizedBox(height: 4.h),
            
            UploadButtonWidget(
              onVideoSelected: _onVideoSelected,
              errorMessage: _errorMessage,
            ),
            
            SizedBox(height: 4.h),
            
            _buildUploadGuidelines(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadGuidelines() {
    final guidelines = [
      {'icon': 'video_file', 'text': 'Supported formats: MP4, MOV'},
      {'icon': 'storage', 'text': 'Maximum file size: 500MB'},
      {'icon': 'high_quality', 'text': 'Recommended resolution: 1080p or higher'},
      {'icon': 'timer', 'text': 'Maximum duration: 60 minutes'},
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Guidelines',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: 3.h),
          
          ...guidelines.map((guideline) => Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: guideline['icon'] as String,
                  color: AppTheme.lightTheme.primaryColor,
                  size: 5.w,
                ),
                
                SizedBox(width: 3.w),
                
                Expanded(
                  child: Text(
                    guideline['text'] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildVideoFormStep() {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            
            _buildVideoPreview(),
            
            SizedBox(height: 3.h),
            
            ThumbnailSelectorWidget(
              thumbnails: ((_selectedVideoMeta?['thumbnails'] as List?)?.cast<String>()) ?? const <String>[],
              selectedIndex: _selectedThumbnailIndex,
              onThumbnailSelected: (index) {
                setState(() {
                  _selectedThumbnailIndex = index;
                });
              },
            ),
            
            SizedBox(height: 3.h),
            
            VideoFormWidget(
              titleController: _titleController,
              descriptionController: _descriptionController,
              tagsController: _tagsController,
              visibility: _visibility,
              onVisibilityChanged: (value) {
                setState(() {
                  _visibility = value;
                });
              },
              errorMessage: _errorMessage,
            ),
            
            SizedBox(height: 4.h),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onFormSubmitted,
                child: Text('Start Upload'),
              ),
            ),
            
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.w * 9 / 16,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'play_circle_filled',
                color: AppTheme.lightTheme.primaryColor,
                size: 8.w,
              ),
            ),
          ),
          
          SizedBox(width: 4.w),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (_selectedVideoMeta?['fileName'] as String?) ?? '--',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 1.h),
                
                Row(
                  children: [
                    Text(
                      (_selectedVideoMeta?['size'] as String?) ?? '--',
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
                      (_selectedVideoMeta?['duration'] as String?) ?? '--',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 0.5.h),
                
                Text(
                  '${(_selectedVideoMeta?['format'] as String?) ?? '--'} • ${(_selectedVideoMeta?['resolution'] as String?) ?? '--'}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgressStep() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          children: [
            SizedBox(height: 4.h),
            
            UploadProgressWidget(
              progress: _uploadProgress,
              estimatedTime: _estimatedTime,
              isUploading: _isUploading,
              isPaused: _isPaused,
              errorMessage: _errorMessage,
              onPause: _pauseUpload,
              onResume: _resumeUpload,
              onCancel: _cancelUpload,
              onRetry: _retryUpload,
              progressAnimation: _progressAnimation,
            ),
            
            SizedBox(height: 4.h),
            
            _buildUploadingVideoInfo(),
            
            const Spacer(),
            
            if (_isUploading || _isPaused)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 5.w,
                    ),
                    
                    SizedBox(width: 3.w),
                    
                    Expanded(
                      child: Text(
                        'You can continue using the app while your video uploads in the background.',
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadingVideoInfo() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Uploading Video',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: 2.h),
          
          Text(
            _titleController.text.trim(),
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: 1.h),
          
          Text(
            _descriptionController.text.trim(),
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          if (_tagsController.text.trim().isNotEmpty) ...[
            SizedBox(height: 2.h),
            
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: _tagsController.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .map((tag) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.w),
                      border: Border.all(
                        color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '#$tag',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'check',
                  color: AppTheme.lightTheme.colorScheme.onTertiary,
                  size: 10.w,
                ),
              ),
            ),
            
            SizedBox(height: 4.h),
            
            Text(
              'Video Uploaded Successfully!',
              style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 2.h),
            
            Text(
              'Your video "${_titleController.text.trim()}" has been uploaded and is now processing. It will be available to viewers shortly.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 6.h),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _shareVideo,
                    child: Text('Share Video'),
                  ),
                ),
                
                SizedBox(width: 4.w),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: _goToHomeFeed,
                    child: Text('Go to Home'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            
            TextButton(
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                  _uploadCompleted = false;
                  _selectedVideoPath = null;
                });
                _titleController.clear();
                _descriptionController.clear();
                _tagsController.clear();
              },
              child: Text('Upload Another Video'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildStepIndicator(),
          _buildStepContent(),
        ],
      ),
    );
  }
}