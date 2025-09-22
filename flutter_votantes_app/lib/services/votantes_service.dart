import 'package:dio/dio.dart';
import '../models/votante.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class VotantesService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getVotantes({
    int page = 1,
    int perPage = 20,
    int? colegioId,
    String? mesa,
    String? search,
    bool? activo,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'per_page': perPage,
        if (colegioId != null) 'colegio_id': colegioId,
        if (mesa != null) 'mesa': mesa,
        if (search != null) 'search': search,
        if (activo != null) 'activo': activo,
      };

      final response = await _apiService.dio.get(
        ApiConfig.votantes,
        queryParameters: queryParams,
      );

      final votantes = (response.data['data'] as List)
          .map((v) => Votante.fromJson(v))
          .toList();

      return {
        'votantes': votantes,
        'total': response.data['total'],
        'current_page': response.data['current_page'],
        'last_page': response.data['last_page'],
      };
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Votante> createVotante(Votante votante) async {
    try {
      final response = await _apiService.dio.post(
        ApiConfig.votantes,
        data: votante.toJson(),
      );

      return Votante.fromJson(response.data['votante']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Votante> updateVotante(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.put(
        '${ApiConfig.votantes}/$id',
        data: data,
      );

      return Votante.fromJson(response.data['votante']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteVotante(int id) async {
    try {
      await _apiService.dio.delete('${ApiConfig.votantes}/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> buscarEnPadron(String cedula) async {
    try {
      final response = await _apiService.dio.get(
        '${ApiConfig.votantesBuscar}/$cedula',
      );

      return {
        'padron': PadronData.fromJson(response.data['padron']),
        'ya_registrado': response.data['ya_registrado'] ?? false,
      };
    } catch (e) {
      if (e is DioError && e.response?.statusCode == 404) {
        throw 'Cédula no encontrada en el padrón';
      }
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final response = await _apiService.dio.get(ApiConfig.votantesEstadisticas);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> agregarGestion(int votanteId, String tipoGestion, String? nota) async {
    try {
      await _apiService.dio.post(
        '${ApiConfig.votantes}/$votanteId/gestiones',
        data: {
          'tipo_gestion': tipoGestion,
          if (nota != null) 'nota': nota,
        },
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getColegios() async {
    try {
      final response = await _apiService.dio.get(ApiConfig.colegios);
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is String) return error;
    if (error is DioError) {
      if (error.response != null) {
        final message = error.response!.data['message'];
        if (message != null) return message;
      }
      return 'Error de conexión';
    }
    return 'Error desconocido';
  }
}