import 'package:flutter/material.dart';
import 'package:sgvrd/core/theme/app_theme.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Votantes'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: const Center(
        child: Text('Mapa con ubicación de votantes'),
      ),
    );
  }
}