import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'api_client.dart';

class VideoService {
	VideoService._();
	static final VideoService _instance = VideoService._();
	static VideoService get I => _instance;

	Future<List<Map<String, dynamic>>> fetchHomeFeed({String category = 'All', int page = 1, int pageSize = 10}) async {
		try {
			final Response res = await ApiClient.I.dio.get(
				'/videos',
				queryParameters: {
					'category': category,
					'page': page,
					'pageSize': pageSize,
				},
			);
			final data = (res.data as List).cast<Map<String, dynamic>>();
			return data;
		} on DioException {
			return _loadHomeFeedFromAssets(category: category, page: page, pageSize: pageSize);
		}
	}

	Future<List<Map<String, dynamic>>> search({required String query, String filter = 'All', int page = 1, int pageSize = 15}) async {
		try {
			final Response res = await ApiClient.I.dio.get(
				'/search',
				queryParameters: {
					'q': query,
					'filter': filter,
					'page': page,
					'pageSize': pageSize,
				},
			);
			final data = (res.data as List).cast<Map<String, dynamic>>();
			return data;
		} on DioException {
			return _loadSearchFromAssets(query: query, filter: filter, page: page, pageSize: pageSize);
		}
	}

	Future<Map<String, dynamic>> fetchVideoDetails(String videoId) async {
		try {
			final Response res = await ApiClient.I.dio.get('/videos/$videoId');
			return (res.data as Map<String, dynamic>);
		} on DioException {
			return _loadVideoDetailsFromAssets();
		}
	}

	Future<List<Map<String, dynamic>>> fetchComments(String videoId) async {
		try {
			final Response res = await ApiClient.I.dio.get('/videos/$videoId/comments');
			return (res.data as List).cast<Map<String, dynamic>>();
		} on DioException {
			return _loadCommentsFromAssets();
		}
	}

	Future<String> getPlaybackUrl({required String videoId, String? fallbackUrl}) async {
		try {
			final Response res = await ApiClient.I.dio.get('/videos/$videoId/url');
			final data = (res.data as Map<String, dynamic>);
			final url = (data['url'] as String?)?.trim() ?? '';
			if (url.isNotEmpty) return url;
		} on DioException {
			// ignore and fall back
		}
		return (fallbackUrl ?? '').trim();
	}

	// Asset fallbacks use the current hardcoded JSON-like structures
	Future<List<Map<String, dynamic>>> _loadHomeFeedFromAssets({required String category, required int page, required int pageSize}) async {
		final String raw = await rootBundle.loadString('assets/home_feed_mock.json');
		final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
		final List<Map<String, dynamic>> all = jsonList.cast<Map<String, dynamic>>();
		final List<Map<String, dynamic>> filtered = category == 'All'
			? all
			: all.where((v) => (v['category'] as String).toLowerCase() == category.toLowerCase()).toList();
		final int start = (page - 1) * pageSize;
		return start < filtered.length ? filtered.skip(start).take(pageSize).toList() : <Map<String, dynamic>>[];
	}

	Future<List<Map<String, dynamic>>> _loadSearchFromAssets({required String query, required String filter, required int page, required int pageSize}) async {
		final String raw = await rootBundle.loadString('assets/search_results_mock.json');
		final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
		final List<Map<String, dynamic>> all = jsonList.cast<Map<String, dynamic>>();
		final q = query.toLowerCase();
		final List<Map<String, dynamic>> pre = all.where((r) {
			final matchesQuery = (r['title'] as String).toLowerCase().contains(q) || (r['channelName'] as String).toLowerCase().contains(q);
			if (filter == 'All') return matchesQuery;
			if (filter == 'Videos') return matchesQuery && r['type'] == 'video';
			if (filter == 'Channels') return matchesQuery && r['type'] == 'channel';
			return false;
		}).toList();
		final int start = (page - 1) * pageSize;
		return start < pre.length ? pre.skip(start).take(pageSize).toList() : <Map<String, dynamic>>[];
	}

	Future<Map<String, dynamic>> _loadVideoDetailsFromAssets() async {
		final String raw = await rootBundle.loadString('assets/video_details_mock.json');
		return (jsonDecode(raw) as Map<String, dynamic>);
	}

	Future<List<Map<String, dynamic>>> _loadCommentsFromAssets() async {
		final String raw = await rootBundle.loadString('assets/comments_mock.json');
		return (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
	}
}

