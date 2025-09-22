import 'package:flutter/material.dart';
import '../models/votante.dart';
import '../services/votantes_service.dart';
import 'auth_provider.dart';

class VotantesProvider extends ChangeNotifier {
  final VotantesService _service = VotantesService();

  List<Votante> _votantes = [];
  Map<String, dynamic>? _estadisticas;
  List<Map<String, dynamic>> _colegios = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalVotantes = 0;

  // Filtros
  int? _colegioIdFilter;
  String? _mesaFilter;
  String? _searchFilter;
  bool? _activoFilter;

  AuthProvider? _authProvider;

  List<Votante> get votantes => _votantes;
  Map<String, dynamic>? get estadisticas => _estadisticas;
  List<Map<String, dynamic>> get colegios => _colegios;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalVotantes => _totalVotantes;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true && _votantes.isEmpty) {
      loadVotantes();
      loadColegios();
    }
  }

  Future<void> loadVotantes({bool reset = false}) async {
    if (_isLoading) return;

    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      if (reset) {
        _currentPage = 1;
        _votantes.clear();
      }

      final result = await _service.getVotantes(
        page: _currentPage,
        colegioId: _colegioIdFilter,
        mesa: _mesaFilter,
        search: _searchFilter,
        activo: _activoFilter,
      );

      if (reset) {
        _votantes = result['votantes'];
      } else {
        _votantes.addAll(result['votantes']);
      }

      _totalVotantes = result['total'];
      _totalPages = result['last_page'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_currentPage < _totalPages) {
      _currentPage++;
      await loadVotantes();
    }
  }

  Future<void> loadEstadisticas() async {
    try {
      _estadisticas = await _service.getEstadisticas();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadColegios() async {
    try {
      _colegios = await _service.getColegios();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createVotante(Votante votante) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final newVotante = await _service.createVotante(votante);
      _votantes.insert(0, newVotante);
      _totalVotantes++;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVotante(int id, Map<String, dynamic> data) async {
    try {
      _error = null;
      final updatedVotante = await _service.updateVotante(id, data);

      final index = _votantes.indexWhere((v) => v.id == id);
      if (index != -1) {
        _votantes[index] = updatedVotante;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVotante(int id) async {
    try {
      _error = null;
      await _service.deleteVotante(id);

      _votantes.removeWhere((v) => v.id == id);
      _totalVotantes--;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> buscarEnPadron(String cedula) async {
    try {
      _error = null;
      return await _service.buscarEnPadron(cedula);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void setFilters({
    int? colegioId,
    String? mesa,
    String? search,
    bool? activo,
  }) {
    _colegioIdFilter = colegioId;
    _mesaFilter = mesa;
    _searchFilter = search;
    _activoFilter = activo;
    loadVotantes(reset: true);
  }

  void clearFilters() {
    _colegioIdFilter = null;
    _mesaFilter = null;
    _searchFilter = null;
    _activoFilter = null;
    loadVotantes(reset: true);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}