class ApiConstants {
  // Base URL - Cambiar según el entorno
  static const String baseUrl = 'https://198.100.150.217';
  static const String apiUrl = '$baseUrl/api';

  // Auth Endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String register = '/register';
  static const String forgotPassword = '/password/email';
  static const String resetPassword = '/password/reset';

  // Votantes Endpoints
  static const String votantes = '/votantes';
  static const String votantesBuscar = '/votantes/buscar';
  static const String votantesFoto = '/votantes/foto';
  static const String votantesEstadisticas = '/votantes/estadisticas';
  static const String votantesDirigentes = '/votantes/dirigentes';
  static const String votantesExportar = '/votantes/exportar';
  static const String votantesMapa = '/votantes/mapa';
  static const String votantesGestiones = '/votantes/{id}/gestiones';

  // Colegios Endpoints
  static const String colegios = '/colegios';

  // Users Endpoints
  static const String users = '/users';
  static const String usersSearchCedula = '/users/search-cedula';
  static const String usersPhoto = '/users/photo';
  static const String usersPermissions = '/users/{id}/permissions';

  // Search Logs
  static const String searchLogs = '/search-logs';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}