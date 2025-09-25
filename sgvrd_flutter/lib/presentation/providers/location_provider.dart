import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoadingLocation = false;
  String? _locationError;
  LocationPermission? _permission;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get locationError => _locationError;
  bool get hasLocationPermission => _permission == LocationPermission.always ||
                                     _permission == LocationPermission.whileInUse;

  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationError = 'Los servicios de ubicación están desactivados. Por favor, actívelos en la configuración.';
      notifyListeners();
      return false;
    }

    permission = await Geolocator.checkPermission();
    _permission = permission;

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      _permission = permission;

      if (permission == LocationPermission.denied) {
        _locationError = 'Los permisos de ubicación fueron denegados.';
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _locationError = 'Los permisos de ubicación están permanentemente denegados. Por favor, habilítelos en la configuración de la aplicación.';
      notifyListeners();
      return false;
    }

    _locationError = null;
    notifyListeners();
    return true;
  }

  Future<Position?> getCurrentLocation() async {
    _isLoadingLocation = true;
    _locationError = null;
    notifyListeners();

    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        _isLoadingLocation = false;
        notifyListeners();
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;
      _locationError = null;

      // Aquí podrías usar un servicio de geocoding para obtener la dirección
      _currentAddress = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';

      _isLoadingLocation = false;
      notifyListeners();
      return position;
    } catch (e) {
      _locationError = 'Error al obtener la ubicación: ${e.toString()}';
      _isLoadingLocation = false;
      notifyListeners();
      return null;
    }
  }

  void setPosition(double latitude, double longitude) {
    _currentPosition = Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
    _currentAddress = 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    notifyListeners();
  }

  void clearLocation() {
    _currentPosition = null;
    _currentAddress = null;
    _locationError = null;
    notifyListeners();
  }

  void clearError() {
    _locationError = null;
    notifyListeners();
  }

  double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}