import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/votantes_provider.dart';

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({Key? key}) : super(key: key);

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  int? _selectedColegioId;
  String? _selectedMesa;
  bool? _selectedActivo;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).primaryColor,
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text(
                    'Colegio Electoral',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Consumer<VotantesProvider>(
                    builder: (context, provider, _) {
                      return DropdownButtonFormField<int>(
                        value: _selectedColegioId,
                        decoration: InputDecoration(
                          hintText: 'Todos los colegios',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          DropdownMenuItem<int>(
                            value: null,
                            child: Text('Todos los colegios'),
                          ),
                          ...provider.colegios.map((colegio) {
                            return DropdownMenuItem<int>(
                              value: colegio['id'],
                              child: Text(colegio['nombre']),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedColegioId = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mesa de Votación',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _selectedMesa,
                    decoration: InputDecoration(
                      hintText: 'Todas las mesas',
                    ),
                    onChanged: (value) {
                      _selectedMesa = value.isEmpty ? null : value;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Estado',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      RadioListTile<bool?>(
                        title: Text('Todos'),
                        value: null,
                        groupValue: _selectedActivo,
                        onChanged: (value) {
                          setState(() {
                            _selectedActivo = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<bool?>(
                        title: Text('Solo activos'),
                        value: true,
                        groupValue: _selectedActivo,
                        onChanged: (value) {
                          setState(() {
                            _selectedActivo = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<bool?>(
                        title: Text('Solo inactivos'),
                        value: false,
                        groupValue: _selectedActivo,
                        onChanged: (value) {
                          setState(() {
                            _selectedActivo = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedColegioId = null;
                          _selectedMesa = null;
                          _selectedActivo = null;
                        });
                        context.read<VotantesProvider>().clearFilters();
                        Navigator.pop(context);
                      },
                      child: Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<VotantesProvider>().setFilters(
                              colegioId: _selectedColegioId,
                              mesa: _selectedMesa,
                              activo: _selectedActivo,
                            );
                        Navigator.pop(context);
                      },
                      child: Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}