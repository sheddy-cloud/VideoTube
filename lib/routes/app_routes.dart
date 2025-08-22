import 'package:flutter/material.dart';
import '../presentation/home_feed_screen/home_feed_screen.dart';
import '../presentation/upload_video_screen/upload_video_screen.dart';
import '../presentation/search_results_screen/search_results_screen.dart';
import '../presentation/video_player_screen/video_player_screen.dart';
import '../presentation/auth_screen/auth_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String homeFeedScreen = '/home-feed-screen';
  static const String videoPlayerScreen = '/video-player-screen';
  static const String searchResultsScreen = '/search-results-screen';
  static const String uploadVideoScreen = '/upload-video-screen';
  static const String authScreen = '/auth';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const HomeFeedScreen(),
    homeFeedScreen: (context) => const HomeFeedScreen(),
    uploadVideoScreen: (context) => const UploadVideoScreen(),
    videoPlayerScreen: (context) => const VideoPlayerScreen(),
    searchResultsScreen: (context) => const SearchResultsScreen(),
    authScreen: (context) => const AuthScreen(),
  };
}