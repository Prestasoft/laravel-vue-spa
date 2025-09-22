import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      headers: ApiConfig.headers,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioError error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          final refreshToken = await _storage.read(key: 'refresh_token');
          if (refreshToken != null) {
            try {
              final response = await _dio.post(ApiConfig.refresh, data: {
                'refresh_token': refreshToken,
              });

              final newToken = response.data['access_token'];
              await _storage.write(key: 'token', value: newToken);

              // Retry original request
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final clonedRequest = await _dio.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(clonedRequest);
            } catch (e) {
              // Refresh failed, logout user
              await _storage.deleteAll();
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(ApiConfig.login, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];
        await _storage.write(key: 'token', value: token);
        if (refreshToken != null) {
          await _storage.write(key: 'refresh_token', value: refreshToken);
        }
        return response.data;
      }
    } catch (e) {
      throw _handleError(e);
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConfig.logout);
    } catch (e) {
      // Ignore errors
    } finally {
      await _storage.deleteAll();
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConfig.user);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioError) {
      if (error.response != null) {
        final message = error.response!.data['message'];
        if (message != null) return message;
      }
      return error.message ?? 'Error de conexión';
    }
    return error.toString();
  }
}