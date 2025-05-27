import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Map<String, dynamic> videoData;
  final bool isControlsVisible;
  final Animation<double> controlsAnimation;
  final VoidCallback onToggleControls;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onNavigateBack;

  const VideoPlayerWidget({
    super.key,
    required this.videoData,
    required this.isControlsVisible,
    required this.controlsAnimation,
    required this.onToggleControls,
    required this.onToggleFullscreen,
    required this.onNavigateBack,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  final double _totalDuration = 225.0; // 3:45 in seconds
  bool _isSeeking = false;

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _onSeekStart(double value) {
    setState(() {
      _isSeeking = true;
    });
  }

  void _onSeekUpdate(double value) {
    setState(() {
      _currentPosition = value;
    });
  }

  void _onSeekEnd(double value) {
    setState(() {
      _currentPosition = value;
      _isSeeking = false;
    });
  }

  void _onDoubleTap(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.globalPosition.dx;
    
    if (tapPosition < screenWidth / 2) {
      // Seek backward 10 seconds
      setState(() {
        _currentPosition = (_currentPosition - 10).clamp(0.0, _totalDuration);
      });
    } else {
      // Seek forward 10 seconds
      setState(() {
        _currentPosition = (_currentPosition + 10).clamp(0.0, _totalDuration);
      });
    }
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Video thumbnail/placeholder
            Positioned.fill(
              child: CustomImageWidget(
                imageUrl: widget.videoData['thumbnail'] as String,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            // Tap detector for controls
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.onToggleControls,
                onDoubleTapDown: _onDoubleTap,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            
            // Video controls overlay
            AnimatedBuilder(
              animation: widget.controlsAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: widget.controlsAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildTopControls(),
                        Expanded(
                          child: _buildCenterControls(),
                        ),
                        _buildBottomControls(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onNavigateBack,
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: Colors.white,
              size: 6.w,
            ),
          ),
          Expanded(
            child: Text(
              widget.videoData['title'] as String,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {
              // More options
            },
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: Colors.white,
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Seek backward
        GestureDetector(
          onTap: () {
            setState(() {
              _currentPosition = (_currentPosition - 10).clamp(0.0, _totalDuration);
            });
          },
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'replay_10',
              color: Colors.white,
              size: 8.w,
            ),
          ),
        ),
        
        // Play/Pause button
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: _isPlaying ? 'pause' : 'play_arrow',
              color: Colors.white,
              size: 12.w,
            ),
          ),
        ),
        
        // Seek forward
        GestureDetector(
          onTap: () {
            setState(() {
              _currentPosition = (_currentPosition + 10).clamp(0.0, _totalDuration);
            });
          },
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'forward_10',
              color: Colors.white,
              size: 8.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _currentPosition,
                  min: 0.0,
                  max: _totalDuration,
                  onChangeStart: _onSeekStart,
                  onChanged: _onSeekUpdate,
                  onChangeEnd: _onSeekEnd,
                  activeColor: AppTheme.lightTheme.primaryColor,
                  inactiveColor: Colors.white.withValues(alpha: 0.3),
                  thumbColor: AppTheme.lightTheme.primaryColor,
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 2.w),
          
          // Bottom control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Quality settings
                    },
                    icon: CustomIconWidget(
                      iconName: 'settings',
                      color: Colors.white,
                      size: 5.w,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Captions
                    },
                    icon: CustomIconWidget(
                      iconName: 'closed_caption',
                      color: Colors.white,
                      size: 5.w,
                    ),
                  ),
                ],
              ),
              
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Picture in picture
                    },
                    icon: CustomIconWidget(
                      iconName: 'picture_in_picture_alt',
                      color: Colors.white,
                      size: 5.w,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onToggleFullscreen,
                    icon: CustomIconWidget(
                      iconName: 'fullscreen',
                      color: Colors.white,
                      size: 5.w,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}