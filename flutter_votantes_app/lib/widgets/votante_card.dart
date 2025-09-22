import 'package:flutter/material.dart';
import '../models/votante.dart';
import '../screens/votante_detail_screen.dart';

class VotanteCard extends StatelessWidget {
  final Votante votante;

  const VotanteCard({Key? key, required this.votante}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: votante.activo ? Colors.green : Colors.grey,
          child: Text(
            votante.nombreCompleto.isNotEmpty
                ? votante.nombreCompleto[0].toUpperCase()
                : '?',
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          votante.nombreCompleto,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cédula: ${votante.cedula}'),
            if (votante.telefono != null && votante.telefono!.isNotEmpty)
              Text('Tel: ${votante.telefono}'),
            if (votante.colegioNombre != null)
              Text('Colegio: ${votante.colegioNombre}'),
            if (votante.mesa != null && votante.mesa!.isNotEmpty)
              Text('Mesa: ${votante.mesa}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              votante.activo ? Icons.check_circle : Icons.cancel,
              color: votante.activo ? Colors.green : Colors.red,
            ),
            Text(
              votante.activo ? 'Activo' : 'Inactivo',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VotanteDetailScreen(votante: votante),
            ),
          );
        },
      ),
    );
  }
}