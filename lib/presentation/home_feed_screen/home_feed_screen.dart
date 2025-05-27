import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/category_chip_widget.dart';
import './widgets/video_card_widget.dart';

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

  // Mock video data
  final List<Map<String, dynamic>> _mockVideos = [
    {
  "id": "1",
  "title": "Amazing Sunset Timelapse in 4K",
  "channelName": "Nature Explorer",
  "channelAvatar": "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/1431822/pexels-photo-1431822.jpeg?auto=compress&cs=tinysrgb&w=400&h=225&fit=crop",
  "views": "2.3M",
  "uploadTime": "2 days ago",

  "duration": "3:45",
  "category": "Nature"},
    {
  "id": "2",
  "title": "Top 10 Gaming Moments of 2024",
  "channelName": "GameMaster Pro",
  "channelAvatar": "https://images.pexels.com/photos/1040881/pexels-photo-1040881.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/442576/pexels-photo-442576.jpeg?auto=compress&cs=tinysrgb&w=400&h=225&fit=crop",
  "views": "1.8M",
  "uploadTime": "1 week ago",

  "duration": "12:30",
  "category": "Gaming"},
    {
  "id": "3",
  "title": "Relaxing Piano Music for Study & Work",
  "channelName": "Peaceful Sounds",
  "channelAvatar": "https://images.pexels.com/photos/1181690/pexels-photo-1181690.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/164743/pexels-photo-164743.jpeg?auto=compress&cs=tinysrgb&w=400&h=225&fit=crop",
  "views": "892K",
  "uploadTime": "3 days ago",

  "duration": "1:45:20",
  "category": "Music"},
    {
  "id": "4",
  "title": "Street Food Around the World",
  "channelName": "Foodie Adventures",
  "channelAvatar": "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=400&h=225&fit=crop",
  "views": "3.1M",
  "uploadTime": "5 days ago",

  "duration": "8:15",
  "category": "Food"},
    {
  "id": "5",
  "title": "Latest Tech Gadgets Review 2024",
  "channelName": "Tech Insider",
  "channelAvatar": "https://images.pexels.com/photos/1181244/pexels-photo-1181244.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/356056/pexels-photo-356056.jpeg?auto=compress&cs=tinysrgb&w=400&h=225&fit=crop",
  "views": "1.2M",
  "uploadTime": "1 day ago",

  "duration": "15:42",
  "category": "Technology"},
    {
  "id": "6",
  "title": "Morning Yoga for Beginners",
  "channelName": "Wellness Journey",
  "channelAvatar": "https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/317157/pexels-photo-317157.jpeg?auto=compress&cs=tinysrgb&w=400&h=225&fit=crop",
  "views": "654K",
  "uploadTime": "4 days ago",

  "duration": "25:30",
  "category": "Fitness"},
    {
  "id": "7",
  "title": "Epic Mountain Climbing Adventure",
  "channelName": "Adventure Seekers",
  "channelAvatar": "https://images.pexels.com/photos/1181467/pexels-photo-1181467.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/618833/pexels-photo-618833.jpeg?auto=compress&cs=tinysrgb&w=400&h=225&fit=crop",
  "views": "2.7M",
  "uploadTime": "1 week ago",

  "duration": "18:22",
  "category": "Adventure"},
    {
  "id": "8",
  "title": "Cooking Masterclass: Italian Pasta",
  "channelName": "Chef's Kitchen",
  "channelAvatar": "https://images.pexels.com/photos/1181263/pexels-photo-1181263.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg?auto=compress&cs=tinysrgb&w=400&h=225&fit=crop",
  "views": "1.5M",
  "uploadTime": "6 days ago",

  "duration": "22:15",
  "category": "Food"},
    {
  "id": "9",
  "title": "Space Exploration Documentary",
  "channelName": "Cosmos Channel",
  "channelAvatar": "https://images.pexels.com/photos/1181345/pexels-photo-1181345.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/586063/pexels-photo-586063.jpeg?auto=compress&cs=tinysrgb&w=400&h=225&fit=crop",
  "views": "4.2M",
  "uploadTime": "2 weeks ago",

  "duration": "45:30",
  "category": "Education"},
    {
  "id": "10",
  "title": "Funny Cat Compilation 2024",
  "channelName": "Pet Paradise",
  "channelAvatar": "https://images.pexels.com/photos/1181424/pexels-photo-1181424.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg?auto=compress&cs=tinysrgb&w=400&h=225&fit=crop",
  "views": "5.8M",
  "uploadTime": "3 days ago",

  "duration": "10:45",
  "category": "Entertainment"},
    {
  "id": "11",
  "title": "DIY Home Decoration Ideas",
  "channelName": "Creative Home",
  "channelAvatar": "https://images.pexels.com/photos/1181533/pexels-photo-1181533.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/1080721/pexels-photo-1080721.jpeg?auto=compress&cs=tinysrgb&w=400&h=225&fit=crop",
  "views": "987K",
  "uploadTime": "1 week ago",

  "duration": "14:20",
  "category": "Lifestyle"},
    {
  "id": "12",
  "title": "Electric Car Test Drive Review",
  "channelName": "Auto Review Hub",
  "channelAvatar": "https://images.pexels.com/photos/1181298/pexels-photo-1181298.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/120049/pexels-photo-120049.jpeg?auto=compress&cs=tinysrgb&w=400&h=225&fit=crop",
  "views": "2.1M",
  "uploadTime": "4 days ago",

  "duration": "16:35",
  "category": "Automotive"}
  ];

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
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final filteredVideos = _selectedCategory == 'All' 
          ? _mockVideos.take(_videosPerPage).toList()
          : _mockVideos.where((video) => 
              (video['category'] as String).toLowerCase() == _selectedCategory.toLowerCase()
            ).take(_videosPerPage).toList();

      setState(() {
        _videos = List.from(filteredVideos);
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
      await Future.delayed(const Duration(milliseconds: 800));
      
      final startIndex = _currentPage * _videosPerPage;
      final endIndex = startIndex + _videosPerPage;
      
      List<Map<String, dynamic>> sourceVideos = _selectedCategory == 'All' 
          ? _mockVideos
          : _mockVideos.where((video) => 
              (video['category'] as String).toLowerCase() == _selectedCategory.toLowerCase()
            ).toList();

      if (startIndex < sourceVideos.length) {
        final newVideos = sourceVideos.skip(startIndex).take(_videosPerPage).toList();
        
        setState(() {
          _videos.addAll(newVideos);
          _currentPage++;
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
    Navigator.pushNamed(context, '/video-player-screen');
  }

  void _onSearchTap() {
    Navigator.pushNamed(context, '/search-results-screen');
  }

  void _onUploadTap() {
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