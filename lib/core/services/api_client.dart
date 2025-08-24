import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
	ApiClient._();
	static final ApiClient _instance = ApiClient._();
	static ApiClient get I => _instance;

	late final Dio _dio = Dio(BaseOptions(
		baseUrl: dotenv.env['API_BASE_URL']?.trim() ?? '',
		connectTimeout: const Duration(seconds: 10),
		receiveTimeout: const Duration(seconds: 20),
	));

	Dio get dio => _dio;
}

