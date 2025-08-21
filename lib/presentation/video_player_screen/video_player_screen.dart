import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/comments_section_widget.dart';
import './widgets/video_info_widget.dart';
import './widgets/video_player_widget.dart';
import '../../core/services/video_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isFullscreen = false;
  bool _isControlsVisible = true;
  bool _isSubscribed = false;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _showMoreComments = false;
  
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  Map<String, dynamic>? _videoData;
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controlsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _loadVideo();
    _controlsAnimationController.forward();
  }

  @override
  void dispose() {
    _controlsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadVideo() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String videoId = (args != null && args['videoId'] != null) ? args['videoId'] as String : '1';

      final details = await VideoService.I.fetchVideoDetails(videoId);
      final comments = await VideoService.I.fetchComments(videoId);

      setState(() {
        _videoData = details;
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
    
    if (_isControlsVisible) {
      _controlsAnimationController.forward();
    } else {
      _controlsAnimationController.reverse();
    }
  }

  void _onSubscribePressed() {
    setState(() {
      _isSubscribed = !_isSubscribed;
    });
  }

  void _onLikePressed() {
    setState(() {
      if (_isLiked) {
        _isLiked = false;
      } else {
        _isLiked = true;
        _isDisliked = false;
      }
    });
  }

  void _onDislikePressed() {
    setState(() {
      if (_isDisliked) {
        _isDisliked = false;
      } else {
        _isDisliked = true;
        _isLiked = false;
      }
    });
  }

  void _onCommentLike(String commentId) {
    setState(() {
      final commentIndex = _comments.indexWhere((comment) => comment['id'] == commentId);
      if (commentIndex != -1) {
        final comment = _comments[commentIndex];
        final isCurrentlyLiked = comment['isLiked'] as bool;
        _comments[commentIndex]['isLiked'] = !isCurrentlyLiked;
        
        if (!isCurrentlyLiked) {
          _comments[commentIndex]['likes'] = (comment['likes'] as int) + 1;
        } else {
          _comments[commentIndex]['likes'] = (comment['likes'] as int) - 1;
        }
      }
    });
  }

  void _retryLoading() {
    _loadVideo();
  }

  void _navigateBack() {
    if (_isFullscreen) {
      _toggleFullscreen();
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (_hasError) {
      return _buildErrorState();
    }
    
    return VideoPlayerWidget(
      videoData: _videoData!,
      isControlsVisible: _isControlsVisible,
      controlsAnimation: _controlsAnimation,
      onToggleControls: _toggleControls,
      onToggleFullscreen: _toggleFullscreen,
      onNavigateBack: _navigateBack,
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      height: _isFullscreen ? 100.h : 56.25.w,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 12.w,
              height: 12.w,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Loading video...',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Buffering 45%',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      height: _isFullscreen ? 100.h : 56.25.w,
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: Colors.white,
                size: 15.w,
              ),
              SizedBox(height: 3.h),
              Text(
                'Playback Error',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                'Unable to load video. Please check your connection and try again.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              ElevatedButton(
                onPressed: _retryLoading,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildVideoPlayer(),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildVideoPlayer(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VideoInfoWidget(
                      videoData: _videoData!,
                      isSubscribed: _isSubscribed,
                      isLiked: _isLiked,
                      isDisliked: _isDisliked,
                      onSubscribePressed: _onSubscribePressed,
                      onLikePressed: _onLikePressed,
                      onDislikePressed: _onDislikePressed,
                    ),
                    CommentsSection(
                      comments: _comments,
                      showMoreComments: _showMoreComments,
                      onToggleMoreComments: () {
                        setState(() {
                          _showMoreComments = !_showMoreComments;
                        });
                      },
                      onCommentLike: _onCommentLike,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}