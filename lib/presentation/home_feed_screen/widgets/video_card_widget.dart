import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';
import '../../../core/services/video_service.dart';

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
            _buildVideoInfo(context),
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

  Widget _buildVideoInfo(BuildContext context) {
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
          
          // Share button
          IconButton(
            onPressed: () => _showShare(context),
            icon: const Icon(Icons.share_outlined),
            padding: EdgeInsets.all(1.w),
            constraints: BoxConstraints(
              minWidth: 8.w,
              minHeight: 8.w,
            ),
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          // More options button
          IconButton(
            onPressed: () => _showOptions(context),
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

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Download'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _downloadVideo(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.watch_later_outlined),
                title: const Text('Save to Watch later'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to Watch later')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Report'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showShare(BuildContext context) async {
    final String id = (video['id'] ?? '').toString();
    // Prefer a presigned URL if bucket is private; else fall back to stored videoUrl
    final String fallback = (video['videoUrl'] ?? '').toString();
    final String url = await VideoService.I.getPlaybackUrl(videoId: id, fallbackUrl: fallback);
    if (url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share link not available')),
        );
      }
      return;
    }

    // Compose WhatsApp deeplink and copy/share options
    final Uri wa = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(url)}');
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_all_outlined),
              title: const Text('Copy link'),
              onTap: () async {
                Navigator.pop(ctx);
                await Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share to WhatsApp'),
              onTap: () async {
                Navigator.pop(ctx);
                if (await canLaunchUrl(wa)) {
                  await launchUrl(wa, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('WhatsApp not available')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadVideo(BuildContext context) async {
    final url = (video['videoUrl'] ?? '') as String;
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video URL not available')),
      );
      return;
    }
    try {
      final dir = await getTemporaryDirectory();
      final safeTitle = (video['title'] as String).replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final savePath = '${dir.path}/$safeTitle.mp4';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading...')),
      );
      await Dio().download(url, savePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to: $savePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download failed')),
      );
    }
  }
}