import 'package:flutter/material.dart';
import 'package:sgvrd/data/datasources/api_service.dart';
import 'package:sgvrd/data/models/votante_model.dart';

class VotanteProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<VotanteModel> _votantes = [];
  VotanteModel? _selectedVotante;
  bool _isLoading = false;
  String? _errorMessage;

  List<VotanteModel> get votantes => _votantes;
  VotanteModel? get selectedVotante => _selectedVotante;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadVotantes({
    String? search,
    int? dirigenteId,
    int? colegioId,
    int page = 1,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final votantes = await _apiService.getVotantes(
        search: search,
        dirigenteId: dirigenteId,
        colegioId: colegioId,
        page: page,
      );

      if (page == 1) {
        _votantes = votantes;
      } else {
        _votantes.addAll(votantes);
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error al cargar votantes';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> buscarVotantePorCedula(String cedula) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final votante = await _apiService.buscarVotantePorCedula(cedula);

      if (votante != null) {
        _selectedVotante = votante;
        _errorMessage = null;
      } else {
        _errorMessage = 'Votante no encontrado';
      }
    } catch (e) {
      _errorMessage = 'Error al buscar votante';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createVotante(VotanteModel votante) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.createVotante(votante);

      if (result['success'] == true) {
        final newVotante = result['data'] as VotanteModel;
        _votantes.insert(0, newVotante);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Error al crear votante';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al crear votante';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVotante(int id, VotanteModel votante) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.updateVotante(id, votante);

      if (result['success'] == true) {
        final updatedVotante = result['data'] as VotanteModel;

        // Update in list
        final index = _votantes.indexWhere((v) => v.id == id);
        if (index != -1) {
          _votantes[index] = updatedVotante;
        }

        // Update selected if it's the same
        if (_selectedVotante?.id == id) {
          _selectedVotante = updatedVotante;
        }

        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Error al actualizar votante';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error al actualizar votante';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVotante(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.deleteVotante(id);

      if (success) {
        _votantes.removeWhere((v) => v.id == id);

        if (_selectedVotante?.id == id) {
          _selectedVotante = null;
        }

        _errorMessage = null;
      } else {
        _errorMessage = 'Error al eliminar votante';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error al eliminar votante';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectVotante(VotanteModel votante) {
    _selectedVotante = votante;
    notifyListeners();
  }

  void clearSelected() {
    _selectedVotante = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearAll() {
    _votantes = [];
    _selectedVotante = null;
    _errorMessage = null;
    notifyListeners();
  }
}