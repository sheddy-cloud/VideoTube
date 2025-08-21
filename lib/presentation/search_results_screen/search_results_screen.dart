import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/search_result_card_widget.dart';
import '../../core/services/video_service.dart';
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

  // Results are fetched from API with asset fallback

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
      final results = await VideoService.I.search(
        query: query,
        filter: _selectedFilter,
        page: 1,
        pageSize: _resultsPerPage,
      );

      setState(() {
        _searchResults = List.from(results);
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
      final nextPage = _currentPage + 1;
      final results = await VideoService.I.search(
        query: _currentQuery,
        filter: _selectedFilter,
        page: nextPage,
        pageSize: _resultsPerPage,
      );

      if (results.isNotEmpty) {
        setState(() {
          _searchResults.addAll(results);
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
      Navigator.pushNamed(
        context,
        '/video-player-screen',
        arguments: {'videoId': result['id']},
      );
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