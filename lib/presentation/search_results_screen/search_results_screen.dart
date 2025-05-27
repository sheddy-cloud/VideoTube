import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/search_result_card_widget.dart';
import './widgets/search_suggestion_widget.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool _showSuggestions = true;
  String _errorMessage = '';
  int _currentPage = 1;
  final int _resultsPerPage = 15;
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _suggestions = [];
  String _selectedFilter = 'All';
  String _currentQuery = '';

  // Mock search results data
  final List<Map<String, dynamic>> _mockSearchResults = [
    {
  "id": "1",
  "title": "Flutter Tutorial: Building Beautiful UIs",
  "channelName": "CodeMaster",
  "channelAvatar": "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/356056/pexels-photo-356056.jpeg?auto=compress&cs=tinysrgb&w=300&h=169&fit=crop",
  "views": "1.2M",
  "uploadTime": "2 days ago",

  "duration": "15:42",
  "type": "video"},
    {
  "id": "2",
  "title": "React vs Flutter: Complete Comparison",
  "channelName": "Tech Insights",
  "channelAvatar": "https://images.pexels.com/photos/1040881/pexels-photo-1040881.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/442576/pexels-photo-442576.jpeg?auto=compress&cs=tinysrgb&w=300&h=169&fit=crop",
  "views": "856K",
  "uploadTime": "1 week ago",

  "duration": "22:15",
  "type": "video"},
    {
  "id": "3",
  "title": "Mobile App Development Bootcamp",
  "channelName": "Dev Academy",
  "channelAvatar": "https://images.pexels.com/photos/1181690/pexels-photo-1181690.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/574071/pexels-photo-574071.jpeg?auto=compress&cs=tinysrgb&w=300&h=169&fit=crop",
  "views": "2.3M",
  "uploadTime": "3 days ago",

  "duration": "45:30",
  "type": "video"},
    {
  "id": "4",
  "title": "Programming Channel",
  "channelName": "Programming Channel",
  "channelAvatar": "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "subscribers": "1.5M subscribers",

  "description": "Learn programming with easy tutorials",
  "type": "channel"},
    {
  "id": "5",
  "title": "Advanced Flutter Animations",
  "channelName": "Animation Pro",
  "channelAvatar": "https://images.pexels.com/photos/1181244/pexels-photo-1181244.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/1431822/pexels-photo-1431822.jpeg?auto=compress&cs=tinysrgb&w=300&h=169&fit=crop",
  "views": "654K",
  "uploadTime": "5 days ago",

  "duration": "18:22",
  "type": "video"},
    {
  "id": "6",
  "title": "Flutter State Management Guide",
  "channelName": "Flutter Expert",
  "channelAvatar": "https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/317157/pexels-photo-317157.jpeg?auto=compress&cs=tinysrgb&w=300&h=169&fit=crop",
  "views": "987K",
  "uploadTime": "1 week ago",

  "duration": "25:30",
  "type": "video"},
    {
  "id": "7",
  "title": "Dart Programming Fundamentals",
  "channelName": "Dart Master",
  "channelAvatar": "https://images.pexels.com/photos/1181467/pexels-photo-1181467.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/618833/pexels-photo-618833.jpeg?auto=compress&cs=tinysrgb&w=300&h=169&fit=crop",
  "views": "1.8M",
  "uploadTime": "4 days ago",

  "duration": "32:15",
  "type": "video"},
    {
  "id": "8",
  "title": "Mobile UI/UX Design",
  "channelName": "Design Studio",
  "channelAvatar": "https://images.pexels.com/photos/1181263/pexels-photo-1181263.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg?auto=compress&cs=tinysrgb&w=300&h=169&fit=crop",
  "views": "743K",
  "uploadTime": "6 days ago",

  "duration": "28:45",
  "type": "video"},
    {
  "id": "9",
  "title": "Code Academy",
  "channelName": "Code Academy",
  "channelAvatar": "https://images.pexels.com/photos/1181345/pexels-photo-1181345.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "subscribers": "2.1M subscribers",

  "description": "Professional coding tutorials and courses",
  "type": "channel"},
    {
  "id": "10",
  "title": "Flutter Performance Optimization",
  "channelName": "Performance Pro",
  "channelAvatar": "https://images.pexels.com/photos/1181424/pexels-photo-1181424.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg?auto=compress&cs=tinysrgb&w=300&h=169&fit=crop",
  "views": "1.1M",
  "uploadTime": "2 weeks ago",

  "duration": "19:30",
  "type": "video"},
    {
  "id": "11",
  "title": "Cross-Platform Development",
  "channelName": "Multi Platform",
  "channelAvatar": "https://images.pexels.com/photos/1181533/pexels-photo-1181533.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/1080721/pexels-photo-1080721.jpeg?auto=compress&cs=tinysrgb&w=300&h=169&fit=crop",
  "views": "892K",
  "uploadTime": "1 week ago",

  "duration": "35:20",
  "type": "video"},
    {
  "id": "12",
  "title": "App Development Trends 2024",
  "channelName": "Tech Trends",
  "channelAvatar": "https://images.pexels.com/photos/1181298/pexels-photo-1181298.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop",
  "thumbnail": "https://images.pexels.com/photos/120049/pexels-photo-120049.jpeg?auto=compress&cs=tinysrgb&w=300&h=169&fit=crop",
  "views": "1.5M",
  "uploadTime": "3 days ago",

  "duration": "24:10",
  "type": "video"}
  ];

  final List<String> _filters = ['All', 'Videos', 'Channels'];

  final List<String> _searchHistory = [
    'Flutter tutorial',
    'React vs Flutter',
    'Mobile app development',
    'Dart programming',
    'UI design'
  ];

  final List<String> _popularSearches = [
    'Flutter widgets',
    'State management',
    'Animation tutorial',
    'API integration',
    'Firebase setup',
    'Performance tips',
    'Testing guide',
    'Deployment process'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.requestFocus();
    _suggestions = List.from(_searchHistory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && !_hasError && _searchResults.isNotEmpty) {
        _loadMoreResults();
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentQuery = query;
    });

    if (query.length >= 3) {
      _debounceSearch(query);
    } else if (query.isEmpty) {
      setState(() {
        _showSuggestions = true;
        _suggestions = List.from(_searchHistory);
        _searchResults.clear();
      });
    } else {
      setState(() {
        _showSuggestions = true;
        _suggestions = _searchHistory
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _debounceSearch(String query) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentQuery == query && query.length >= 3) {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _showSuggestions = false;
      _currentPage = 1;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      final filteredResults = _mockSearchResults.where((result) {
        final matchesQuery = (result['title'] as String)
            .toLowerCase()
            .contains(query.toLowerCase()) ||
            (result['channelName'] as String)
            .toLowerCase()
            .contains(query.toLowerCase());
        
        if (_selectedFilter == 'All') return matchesQuery;
        if (_selectedFilter == 'Videos') return matchesQuery && result['type'] == 'video';
        if (_selectedFilter == 'Channels') return matchesQuery && result['type'] == 'channel';
        
        return false;
      }).take(_resultsPerPage).toList();

      setState(() {
        _searchResults = List.from(filteredResults);
        _isLoading = false;
      });

      // Add to search history if not already present
      if (!_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load search results. Please try again.';
      });
    }
  }

  Future<void> _loadMoreResults() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final startIndex = _currentPage * _resultsPerPage;
      final filteredResults = _mockSearchResults.where((result) {
        final matchesQuery = (result['title'] as String)
            .toLowerCase()
            .contains(_currentQuery.toLowerCase()) ||
            (result['channelName'] as String)
            .toLowerCase()
            .contains(_currentQuery.toLowerCase());
        
        if (_selectedFilter == 'All') return matchesQuery;
        if (_selectedFilter == 'Videos') return matchesQuery && result['type'] == 'video';
        if (_selectedFilter == 'Channels') return matchesQuery && result['type'] == 'channel';
        
        return false;
      }).toList();

      if (startIndex < filteredResults.length) {
        final newResults = filteredResults.skip(startIndex).take(_resultsPerPage).toList();
        
        setState(() {
          _searchResults.addAll(newResults);
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

  void _onFilterSelected(String filter) {
    if (_selectedFilter != filter) {
      setState(() {
        _selectedFilter = filter;
      });
      if (_currentQuery.isNotEmpty) {
        _performSearch(_currentQuery);
      }
    }
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }

  void _onResultTap(Map<String, dynamic> result) {
    if (result['type'] == 'video') {
      Navigator.pushNamed(context, '/video-player-screen');
    }
  }

  void _onVoiceSearch() {
    // Voice search implementation would go here
    // For now, we'll simulate it with a popular search
    final randomSearch = _popularSearches[DateTime.now().millisecond % _popularSearches.length];
    _searchController.text = randomSearch;
    _performSearch(randomSearch);
  }

  void _retrySearch() {
    if (_currentQuery.isNotEmpty) {
      _performSearch(_currentQuery);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentQuery = '';
      _showSuggestions = true;
      _suggestions = List.from(_searchHistory);
      _searchResults.clear();
    });
  }

  Widget _buildSearchBar() {
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
            // Back button
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
            
            // Search input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.w),
                  border: Border.all(
                    color: AppTheme.lightTheme.dividerColor,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search videos and channels',
                    hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 5.w,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _clearSearch,
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                              size: 5.w,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 3.w,
                    ),
                  ),
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ),
            ),
            
            SizedBox(width: 2.w),
            
            // Voice search button
            IconButton(
              onPressed: _onVoiceSearch,
              icon: CustomIconWidget(
                iconName: 'mic',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
              padding: EdgeInsets.all(2.w),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          return FilterChipWidget(
            label: filter,
            isSelected: _selectedFilter == filter,
            onTap: () => _onFilterSelected(filter),
          );
        },
      ),
    );
  }

  Widget _buildSuggestions() {
    if (!_showSuggestions || _suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: _suggestions.length + (_currentQuery.isEmpty ? _popularSearches.length : 0),
        separatorBuilder: (context, index) => SizedBox(height: 1.h),
        itemBuilder: (context, index) {
          if (index < _suggestions.length) {
            return SearchSuggestionWidget(
              suggestion: _suggestions[index],
              isHistory: true,
              onTap: () => _onSuggestionTap(_suggestions[index]),
            );
          } else {
            final popularIndex = index - _suggestions.length;
            return SearchSuggestionWidget(
              suggestion: _popularSearches[popularIndex],
              isHistory: false,
              onTap: () => _onSuggestionTap(_popularSearches[popularIndex]),
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return _buildSkeletonLoader();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_searchResults.isEmpty && _currentQuery.isNotEmpty) {
      return _buildEmptyState();
    }

    return Expanded(
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: _searchResults.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          if (index >= _searchResults.length) {
            return _buildLoadingMoreIndicator();
          }

          final result = _searchResults[index];
          return SearchResultCardWidget(
            result: result,
            onTap: () => _onResultTap(result),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: 8,
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemBuilder: (context, index) => _buildSkeletonCard(),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 20.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Thumbnail skeleton
          Container(
            width: 35.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(2.w)),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title skeleton
                  Container(
                    width: double.infinity,
                    height: 3.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                  ),
                  
                  SizedBox(height: 2.w),
                  
                  // Channel skeleton
                  Container(
                    width: 40.w,
                    height: 2.5.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                  ),
                  
                  SizedBox(height: 2.w),
                  
                  // Views skeleton
                  Container(
                    width: 30.w,
                    height: 2.5.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 15.w,
              ),
              
              SizedBox(height: 4.h),
              
              Text(
                'Search Error',
                style: AppTheme.lightTheme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 2.h),
              
              Text(
                _errorMessage,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 4.h),
              
              ElevatedButton(
                onPressed: _retrySearch,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'search_off',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 15.w,
              ),
              
              SizedBox(height: 4.h),
              
              Text(
                'No results found',
                style: AppTheme.lightTheme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 2.h),
              
              Text(
                'Try searching for something else or check your spelling.',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 4.h),
              
              Text(
                'Popular searches:',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              
              SizedBox(height: 2.h),
              
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: _popularSearches.take(4).map((search) => 
                  GestureDetector(
                    onTap: () => _onSuggestionTap(search),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(4.w),
                        border: Border.all(
                          color: AppTheme.lightTheme.dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        search,
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ],
          ),
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
          _buildSearchBar(),
          if (!_showSuggestions) _buildFilterChips(),
          _showSuggestions ? _buildSuggestions() : _buildSearchResults(),
        ],
      ),
    );
  }
}