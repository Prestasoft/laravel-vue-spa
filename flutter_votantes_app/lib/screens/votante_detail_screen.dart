import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/votante.dart';
import '../providers/votantes_provider.dart';

class VotanteDetailScreen extends StatelessWidget {
  final Votante votante;

  const VotanteDetailScreen({Key? key, required this.votante}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Votante'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Editar'),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirmar eliminación'),
                    content: Text('¿Está seguro de eliminar este votante?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('Eliminar'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && votante.id != null) {
                  final success = await context
                      .read<VotantesProvider>()
                      .deleteVotante(votante.id!);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Votante eliminado'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información Personal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: votante.activo ? Colors.green : Colors.grey,
                          child: Text(
                            votante.nombreCompleto.isNotEmpty
                                ? votante.nombreCompleto[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                votante.nombreCompleto,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Cédula: ${votante.cedula}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Chip(
                                label: Text(
                                  votante.activo ? 'ACTIVO' : 'INACTIVO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor:
                                    votante.activo ? Colors.green : Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Información del Padrón
            if (votante.padronData != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Padrón',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.person,
                        label: 'Sexo',
                        value: votante.padronData!.sexo ?? 'No especificado',
                      ),
                      if (votante.padronData!.fechaNacimiento != null)
                        _InfoRow(
                          icon: Icons.cake,
                          label: 'Fecha de Nacimiento',
                          value: dateFormat.format(votante.padronData!.fechaNacimiento!),
                        ),
                      if (votante.padronData!.lugarNacimiento != null)
                        _InfoRow(
                          icon: Icons.place,
                          label: 'Lugar de Nacimiento',
                          value: votante.padronData!.lugarNacimiento!,
                        ),
                      if (votante.padronData!.estadoCivil != null)
                        _InfoRow(
                          icon: Icons.favorite,
                          label: 'Estado Civil',
                          value: votante.padronData!.estadoCivil!,
                        ),
                      if (votante.padronData!.provincia != null)
                        _InfoRow(
                          icon: Icons.map,
                          label: 'Provincia',
                          value: votante.padronData!.provincia!,
                        ),
                      if (votante.padronData!.municipio != null)
                        _InfoRow(
                          icon: Icons.location_city,
                          label: 'Municipio',
                          value: votante.padronData!.municipio!,
                        ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Información Electoral
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Electoral',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.school,
                      label: 'Colegio Electoral',
                      value: votante.colegioNombre ?? 'No asignado',
                    ),
                    _InfoRow(
                      icon: Icons.table_chart,
                      label: 'Mesa de Votación',
                      value: votante.mesa ?? 'No asignada',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Información de Contacto
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de Contacto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.phone,
                      label: 'Teléfono',
                      value: votante.telefono ?? 'No registrado',
                    ),
                    _InfoRow(
                      icon: Icons.home,
                      label: 'Dirección',
                      value: votante.direccion ?? 'No registrada',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Observaciones
            if (votante.observaciones != null &&
                votante.observaciones!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Observaciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(votante.observaciones!),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Fecha de Registro
            if (votante.fechaRegistro != null)
              Center(
                child: Text(
                  'Registrado el ${dateFormat.format(votante.fechaRegistro!)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (votante.telefono != null && votante.telefono!.isNotEmpty)
            FloatingActionButton(
              heroTag: 'call',
              onPressed: () {
                // Implementar llamada
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.phone),
            ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'gestion',
            onPressed: () {
              // Implementar agregar gestión
            },
            icon: Icon(Icons.add),
            label: Text('Gestión'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}