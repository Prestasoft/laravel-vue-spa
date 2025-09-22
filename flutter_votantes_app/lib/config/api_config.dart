class ApiConfig {
  static const String baseUrl = 'http://localhost:8000/api'; // Cambiar en producción
  static const Duration timeout = Duration(seconds: 30);

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String refresh = '/refresh';

  // Votantes
  static const String votantes = '/votantes';
  static const String votantesBuscar = '/votantes/buscar';
  static const String votantesEstadisticas = '/votantes/estadisticas';
  static const String votantesExportar = '/votantes/exportar';

  // Colegios
  static const String colegios = '/colegios';
  static const String mesasPorColegio = '/colegios/{id}/mesas';
}