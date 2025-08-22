import 'dart:io';

import 'package:dio/dio.dart';

import 'api_client.dart';
import 'auth_service.dart';

class UploadService {
  UploadService._();
  static final UploadService _instance = UploadService._();
  static UploadService get I => _instance;

  Future<String> uploadVideo({
    required String filePath,
    required String title,
    required String description,
    required String visibility,
    required List<String> tags,
    required int selectedThumbnailIndex,
    required void Function(int sentBytes, int totalBytes) onProgress,
    CancelToken? cancelToken,
  }) async {
    final file = File(filePath);
    final fileName = file.path.split(Platform.pathSeparator).last;

    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      'visibility': visibility,
      'tags': tags,
      'selectedThumbnailIndex': selectedThumbnailIndex,
      'file': await MultipartFile.fromFile(file.path, filename: fileName, contentType: DioMediaType.parse('video/mp4')),
    });

    final token = await AuthService.I.getToken();
    final Response res = await ApiClient.I.dio.post(
      '/videos/upload',
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: onProgress,
      options: Options(
        contentType: 'multipart/form-data',
        headers: token != null && token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
      ),
    );

    final data = res.data as Map<String, dynamic>;
    return (data['videoId'] ?? data['id'] ?? '').toString();
  }
}


