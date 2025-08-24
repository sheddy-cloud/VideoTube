import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

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
  VideoPlayerController? _controller;
  bool _isControllerReady = false;

  bool _isSeeking = false;

  @override
  void initState() {
    super.initState();
    final url = (widget.videoData['videoUrl'] as String?) ?? '';
    if (url.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() {
            _isControllerReady = true;
          });
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {});
  }

  void _onSeekStart(double value) {
    setState(() {
      _isSeeking = true;
    });
  }

  void _onSeekUpdate(double value) {
    if (_controller == null) return;
    final duration = _controller!.value.duration;
    final position = Duration(seconds: value.round());
    final clamped = position < Duration.zero
        ? Duration.zero
        : (position > duration ? duration : position);
    _controller!.seekTo(clamped);
    setState(() {});
  }

  void _onSeekEnd(double value) {
    setState(() {
      _isSeeking = false;
    });
  }

  void _onDoubleTap(TapDownDetails details) {
    if (_controller == null) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.globalPosition.dx;
    final cur = _controller!.value.position;
    if (tapPosition < screenWidth / 2) {
      _controller!.seekTo(cur - const Duration(seconds: 10));
    } else {
      _controller!.seekTo(cur + const Duration(seconds: 10));
    }
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _isControllerReady && _controller != null;
    final duration = isReady ? _controller!.value.duration : const Duration(seconds: 0);
    final position = isReady ? _controller!.value.position : const Duration(seconds: 0);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: isReady
                  ? VideoPlayer(_controller!)
                  : CustomImageWidget(
                      imageUrl: widget.videoData['thumbnail'] as String,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),

            Positioned.fill(
              child: GestureDetector(
                onTap: widget.onToggleControls,
                onDoubleTapDown: _onDoubleTap,
                child: Container(color: Colors.transparent),
              ),
            ),

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
                        const Spacer(),
                        _buildCenterControls(isReady),
                        _buildBottomControls(position, duration, isReady),
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
            onPressed: () {},
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

  Widget _buildCenterControls(bool isReady) {
    final isPlaying = isReady && _controller!.value.isPlaying;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            if (!isReady) return;
            final cur = _controller!.value.position;
            _controller!.seekTo(cur - const Duration(seconds: 10));
            setState(() {});
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
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: isPlaying ? 'pause' : 'play_arrow',
              color: Colors.white,
              size: 12.w,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (!isReady) return;
            final cur = _controller!.value.position;
            _controller!.seekTo(cur + const Duration(seconds: 10));
            setState(() {});
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

  Widget _buildBottomControls(Duration position, Duration duration, bool isReady) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _formatDuration(position),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Slider(
                  value: position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
                  min: 0.0,
                  max: (duration.inSeconds > 0 ? duration.inSeconds : 1).toDouble(),
                  onChangeStart: (_) => _onSeekStart(0),
                  onChanged: (v) => _onSeekUpdate(v),
                  onChangeEnd: (v) => _onSeekEnd(v),
                  activeColor: AppTheme.lightTheme.primaryColor,
                  inactiveColor: Colors.white.withValues(alpha: 0.3),
                  thumbColor: AppTheme.lightTheme.primaryColor,
                ),
              ),
              Text(
                _formatDuration(duration),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.w),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: CustomIconWidget(
                      iconName: 'settings',
                      color: Colors.white,
                      size: 5.w,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
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
                    onPressed: () {},
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