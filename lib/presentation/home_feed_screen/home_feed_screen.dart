import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/category_chip_widget.dart';
import './widgets/video_card_widget.dart';
import '../../core/services/video_service.dart';
import '../../core/services/auth_service.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final RefreshIndicator _refreshIndicator = RefreshIndicator(
    onRefresh: () async {},
    child: Container(),
  );
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  int _currentPage = 1;
  final int _videosPerPage = 10;
  List<Map<String, dynamic>> _videos = [];
  String _selectedCategory = 'All';

  // Data is fetched from API with asset fallback

  final List<String> _categories = [
    'All', 'Trending', 'Music', 'Gaming', 'Food', 'Technology', 'Fitness', 'Education'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialVideos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && !_hasError) {
        _loadMoreVideos();
      }
    }
  }

  Future<void> _loadInitialVideos() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final fetched = await VideoService.I.fetchHomeFeed(
        category: _selectedCategory,
        page: 1,
        pageSize: _videosPerPage,
      );

      setState(() {
        _videos = List.from(fetched);
        _isLoading = false;
        _currentPage = 1;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadMoreVideos() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final fetched = await VideoService.I.fetchHomeFeed(
        category: _selectedCategory,
        page: nextPage,
        pageSize: _videosPerPage,
      );

      if (fetched.isNotEmpty) {
        setState(() {
          _videos.addAll(fetched);
          _currentPage = nextPage;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadInitialVideos();
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
      });
      _loadInitialVideos();
    }
  }

  void _onVideoTap(Map<String, dynamic> video) {
    Navigator.pushNamed(
      context,
      '/video-player-screen',
      arguments: {'videoId': video['id']},
    );
  }

  void _onSearchTap() {
    Navigator.pushNamed(context, '/search-results-screen');
  }

  Future<void> _onUploadTap() async {
    final loggedIn = await AuthService.I.isLoggedIn();
    if (!loggedIn) {
      final result = await Navigator.pushNamed(context, '/auth');
      if (result != true) return;
    }
    if (!mounted) return;
    Navigator.pushNamed(context, '/upload-video-screen');
  }

  void _retryLoading() {
    _loadInitialVideos();
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
            // Logo
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'play_arrow',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 5.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'VideoShare',
                    style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Search and Profile buttons
            Row(
              children: [
                IconButton(
                  onPressed: _onSearchTap,
                  icon: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                  padding: EdgeInsets.all(2.w),
                ),
                SizedBox(width: 1.w),
                IconButton(
                  onPressed: _onUploadTap,
                  icon: CustomIconWidget(
                    iconName: 'add_circle_outline',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                  padding: EdgeInsets.all(2.w),
                ),
                SizedBox(width: 1.w),
                GestureDetector(
                  onTap: () {
                    // Profile action
                  },
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.lightTheme.dividerColor,
                        width: 1,
                      ),
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        imageUrl: "https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
                        width: 8.w,
                        height: 8.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStrip() {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return CategoryChipWidget(
            label: category,
            isSelected: _selectedCategory == category,
            onTap: () => _onCategorySelected(category),
          );
        },
      ),
    );
  }

  Widget _buildVideoList() {
    if (_isLoading) {
      return _buildSkeletonLoader();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.lightTheme.primaryColor,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: _videos.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => SizedBox(height: 3.h),
        itemBuilder: (context, index) {
          if (index >= _videos.length) {
            return _buildLoadingMoreIndicator();
          }

          final video = _videos[index];
          return VideoCardWidget(
            video: video,
            onTap: () => _onVideoTap(video),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: 5,
      separatorBuilder: (context, index) => SizedBox(height: 3.h),
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail skeleton
          Container(
            width: double.infinity,
            height: 50.w * 9 / 16,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(3.w)),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar skeleton
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                ),
                
                SizedBox(width: 3.w),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title skeleton
                      Container(
                        width: double.infinity,
                        height: 4.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                      ),
                      
                      SizedBox(height: 2.w),
                      
                      // Subtitle skeleton
                      Container(
                        width: 60.w,
                        height: 3.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'wifi_off',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 15.w,
            ),
            
            SizedBox(height: 4.h),
            
            Text(
              'Network Error',
              style: AppTheme.lightTheme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 2.h),
            
            Text(
              'Please check your internet connection and try again.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
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
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Center(
        child: SizedBox(
          width: 6.w,
          height: 6.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.primaryColor,
            ),
          ),
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
          _buildCategoryStrip(),
          Expanded(
            child: _buildVideoList(),
          ),
        ],
      ),
    );
  }
}