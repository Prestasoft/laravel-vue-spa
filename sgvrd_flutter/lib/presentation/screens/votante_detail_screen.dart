import 'package:flutter/material.dart';
import 'package:sgvrd/core/theme/app_theme.dart';

class VotanteDetailScreen extends StatelessWidget {
  final int? votanteId;
  final bool isNew;

  const VotanteDetailScreen({
    super.key,
    this.votanteId,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Nuevo Votante' : 'Detalle de Votante'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: Center(
        child: Text(
          isNew ? 'Formulario para nuevo votante' : 'Detalles del votante $votanteId',
        ),
      ),
    );
  }
}