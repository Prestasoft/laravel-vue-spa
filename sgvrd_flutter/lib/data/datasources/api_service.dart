import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sgvrd/core/constants/api_constants.dart';
import 'package:sgvrd/data/models/user_model.dart';
import 'package:sgvrd/data/models/votante_model.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: ApiConstants.headers,
      ),
    );

    // Interceptor para agregar token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Agregar token si existe
          if (_token == null) {
            _token = await _storage.read(key: 'auth_token');
          }
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
        onError: (DioException error, handler) {
          // Manejar errores de autenticación
          if (error.response?.statusCode == 401) {
            _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  void _handleUnauthorized() async {
    // Limpiar token y redirigir a login
    _token = null;
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
  }

  // Auth Methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        final userData = response.data['data']['user'];
        
        // Guardar token
        _token = token;
        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(key: 'user_data', value: jsonEncode(userData));
        
        return {
          'success': true,
          'user': UserModel.fromJson(userData),
          'token': token,
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Error al iniciar sesión',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    }
  }

  Future<bool> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
      _token = null;
      await _storage.deleteAll();
      return true;
    } catch (e) {
      // Limpiar localmente aunque falle el servidor
      _token = null;
      await _storage.deleteAll();
      return true;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConstants.user);
      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Votantes Methods
  Future<List<VotanteModel>> getVotantes({
    String? search,
    int? dirigenteId,
    int? colegioId,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
        if (dirigenteId != null) 'dirigente_id': dirigenteId,
        if (colegioId != null) 'colegio_id': colegioId,
      };

      final response = await _dio.get(
        ApiConstants.votantes,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['data'] ?? [];
        return data.map((json) => VotanteModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<VotanteModel?> buscarVotantePorCedula(String cedula) async {
    try {
      final response = await _dio.get('${ApiConstants.votantesBuscar}/$cedula');
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return VotanteModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createVotante(VotanteModel votante) async {
    try {
      final response = await _dio.post(
        ApiConstants.votantes,
        data: votante.toJson(),
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': VotanteModel.fromJson(response.data['data']),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Error al crear votante',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    }
  }

  Future<Map<String, dynamic>> updateVotante(int id, VotanteModel votante) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.votantes}/$id',
        data: votante.toJson(),
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'data': VotanteModel.fromJson(response.data['data']),
        };
      }
      
      return {
        'success': false,
        'message': response.data['message'] ?? 'Error al actualizar votante',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    }
  }

  Future<bool> deleteVotante(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.votantes}/$id');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getVotanteFoto(String cedula) async {
    try {
      final response = await _dio.get('${ApiConstants.votantesFoto}/$cedula');
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data']['foto'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final response = await _dio.get(ApiConstants.votantesEstadisticas);
      
      if (response.data['success'] == true) {
        return response.data['data'] ?? {};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getVotantesMapa() async {
    try {
      final response = await _dio.get(ApiConstants.votantesMapa);
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Colegios Methods
  Future<List<Map<String, dynamic>>> getColegios() async {
    try {
      final response = await _dio.get(ApiConstants.colegios);
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Error Handler
  String _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de conexión agotado';
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return 'Error de conexión. Verifique su internet';
    }
    
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      
      if (statusCode == 422) {
        // Validation errors
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
        return data['message'] ?? 'Error de validación';
      }
      
      if (statusCode == 401) {
        return 'Sesión expirada. Por favor inicie sesión nuevamente';
      }
      
      if (statusCode == 403) {
        return 'No tiene permisos para realizar esta acción';
      }
      
      if (statusCode == 404) {
        return 'Recurso no encontrado';
      }
      
      if (statusCode == 500) {
        return 'Error del servidor. Intente más tarde';
      }
      
      return data['message'] ?? 'Error desconocido';
    }
    
    return 'Error de conexión';
  }

  // Para permitir certificados autofirmados en desarrollo
  static void allowSelfSignedCertificate() {
    HttpOverrides.global = MyHttpOverrides();
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}