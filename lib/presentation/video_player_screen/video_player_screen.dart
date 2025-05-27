import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/comments_section_widget.dart';
import './widgets/video_info_widget.dart';
import './widgets/video_player_widget.dart';

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

  // Mock video data
  final Map<String, dynamic> _videoData = {
    "id": "1",
    "title": "Amazing Sunset Timelapse in 4K - Nature's Beauty Captured",
    "description": "Experience the breathtaking beauty of nature with this stunning 4K sunset timelapse. Shot over 3 hours in the mountains, this video captures the magical transition from day to night with vibrant colors painting the sky.",
    "channelName": "Nature Explorer",
    "channelAvatar": "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
    "channelSubscribers": "2.3M",
    "videoUrl": "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4",
    "thumbnail": "https://images.pexels.com/photos/1431822/pexels-photo-1431822.jpeg?auto=compress&cs=tinysrgb&w=400&h=225&fit=crop",
    "views": "2,345,678",
    "likes": "45,234",
    "dislikes": "892",
    "uploadTime": "2 days ago",
    "duration": "3:45",
    "category": "Nature"
  };

  final List<Map<String, dynamic>> _comments = [
    {
  "id": "1",
  "username": "NatureLover123",
  "avatar": "https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "comment": "Absolutely stunning! The colors in this timelapse are incredible. Nature never fails to amaze me.",
  "likes": 234,

  "timestamp": "2 hours ago",
  "isLiked": false},
    {
  "id": "2",
  "username": "PhotoPro",
  "avatar": "https://images.pexels.com/photos/1181467/pexels-photo-1181467.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "comment": "What camera did you use for this? The quality is amazing!",
  "likes": 89,

  "timestamp": "4 hours ago",
  "isLiked": true},
    {
  "id": "3",
  "username": "MountainHiker",
  "avatar": "https://images.pexels.com/photos/1181345/pexels-photo-1181345.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "comment": "I've been to this location! It's even more beautiful in person. Great work capturing this moment.",
  "likes": 156,

  "timestamp": "6 hours ago",
  "isLiked": false},
    {
  "id": "4",
  "username": "RelaxationSeeker",
  "avatar": "https://images.pexels.com/photos/1181533/pexels-photo-1181533.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "comment": "This is so peaceful and calming. Perfect for meditation and relaxation.",
  "likes": 67,

  "timestamp": "8 hours ago",
  "isLiked": false},
    {
  "id": "5",
  "username": "TimelapseExpert",
  "avatar": "https://images.pexels.com/photos/1181298/pexels-photo-1181298.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "comment": "Excellent technique! The smooth transitions and color grading are top-notch.",
  "likes": 198,

  "timestamp": "10 hours ago",
  "isLiked": true},
    {
  "id": "6",
  "username": "SkyWatcher",
  "avatar": "https://images.pexels.com/photos/1181424/pexels-photo-1181424.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "comment": "The way the clouds move across the sky is mesmerizing. Nature's own art show!",
  "likes": 112,

  "timestamp": "12 hours ago",
  "isLiked": false}
  ];

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
      // Simulate video loading
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
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
      videoData: _videoData,
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
                      videoData: _videoData,
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