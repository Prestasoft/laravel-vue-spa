import 'package:flutter/material.dart';
import 'package:sgvrd/core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: const Center(
        child: Text('Perfil del usuario'),
      ),
    );
  }
}