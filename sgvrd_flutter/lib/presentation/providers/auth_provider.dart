import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sgvrd/data/datasources/api_service.dart';
import 'package:sgvrd/data/models/user_model.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final userData = await _storage.read(key: 'user_data');
      
      if (token != null && userData != null) {
        _user = UserModel.fromJson(jsonDecode(userData));
        _user!.token = token;
        _isAuthenticated = true;
        
        // Verificar token con el servidor
        final currentUser = await _apiService.getCurrentUser();
        if (currentUser != null) {
          _user = currentUser;
          _user!.token = token;
          await _storage.write(key: 'user_data', value: jsonEncode(_user!.toJson()));
        } else {
          // Token inválido, limpiar
          await logout();
        }
      }
    } catch (e) {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);
      
      if (result['success'] == true) {
        _user = result['user'] as UserModel;
        _user!.token = result['token'];
        _isAuthenticated = true;
        _errorMessage = null;
        
        // Guardar datos localmente
        await _storage.write(key: 'auth_token', value: result['token']);
        await _storage.write(key: 'user_data', value: jsonEncode(_user!.toJson()));
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Error al iniciar sesión';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Verifique su internet.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
    } catch (e) {
      // Ignorar errores del servidor al cerrar sesión
    }

    // Limpiar datos locales
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    await _storage.deleteAll();
    
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Verificar permisos
  bool hasPermission(String permission) {
    if (_user == null) return false;
    
    switch (permission) {
      case 'view_votantes':
        return _user!.canViewVotantes;
      case 'add_votantes':
        return _user!.canAddVotantes;
      case 'edit_votantes':
        return _user!.canEditVotantes;
      case 'delete_votantes':
        return _user!.canDeleteVotantes;
      case 'view_users':
        return _user!.canViewUsers;
      case 'add_users':
        return _user!.canAddUsers;
      case 'edit_users':
        return _user!.canEditUsers;
      case 'delete_users':
        return _user!.canDeleteUsers;
      case 'view_reports':
        return _user!.canViewReports;
      case 'export_data':
        return _user!.canExportData;
      case 'view_all_votantes':
        return _user!.canViewAllVotantes;
      case 'manage_coordinadores':
        return _user!.canManageCoordinadores;
      default:
        return false;
    }
  }

  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isCoordinador => _user?.isCoordinador ?? false;
  bool get isCandidato => _user?.isCandidato ?? false;
  bool get isGuest => _user?.isGuest ?? false;
}