import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/votante.dart';
import '../providers/auth_provider.dart';
import '../providers/votantes_provider.dart';

class AddVotanteScreen extends StatefulWidget {
  const AddVotanteScreen({Key? key}) : super(key: key);

  @override
  State<AddVotanteScreen> createState() => _AddVotanteScreenState();
}

class _AddVotanteScreenState extends State<AddVotanteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _observacionesController = TextEditingController();

  PadronData? _padronData;
  int? _selectedColegioId;
  String? _selectedMesa;
  bool _isLoading = false;
  bool _yaRegistrado = false;

  @override
  void dispose() {
    _cedulaController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _buscarEnPadron() async {
    final cedula = _cedulaController.text.trim();

    if (cedula.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingrese una cédula')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<VotantesProvider>();
    final result = await provider.buscarEnPadron(cedula);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result != null) {
        _padronData = result['padron'];
        _yaRegistrado = result['ya_registrado'];
        _selectedColegioId = _padronData?.colegioId;
      }
    });

    if (result == null && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: Colors.red,
        ),
      );
    } else if (_yaRegistrado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Este votante ya está en tu lista'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _guardarVotante() async {
    if (!_formKey.currentState!.validate()) return;

    if (_padronData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Primero debe buscar la cédula en el padrón')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final votantesProvider = context.read<VotantesProvider>();

    final votante = Votante(
      cedula: _cedulaController.text.trim(),
      dirigenteId: authProvider.user!.id,
      colegioId: _selectedColegioId,
      mesa: _selectedMesa,
      telefono: _telefonoController.text.trim(),
      direccion: _direccionController.text.trim(),
      observaciones: _observacionesController.text.trim(),
    );

    final success = await votantesProvider.createVotante(votante);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Votante agregado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (votantesProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(votantesProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Votante'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buscar en Padrón',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cedulaController,
                              decoration: InputDecoration(
                                labelText: 'Cédula',
                                hintText: '00000000000',
                                prefixIcon: Icon(Icons.badge),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 11,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese la cédula';
                                }
                                if (value.length != 11) {
                                  return 'La cédula debe tener 11 dígitos';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _buscarEnPadron,
                            icon: Icon(Icons.search),
                            label: Text('Buscar'),
                          ),
                        ],
                      ),
                      if (_padronData != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _yaRegistrado ? Colors.orange[50] : Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _yaRegistrado ? Colors.orange : Colors.green,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _yaRegistrado ? Icons.warning : Icons.check_circle,
                                    color: _yaRegistrado ? Colors.orange : Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _yaRegistrado
                                        ? 'Ya está en tu lista'
                                        : 'Encontrado en el padrón',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _yaRegistrado ? Colors.orange : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Nombre: ${_padronData!.nombres} ${_padronData!.apellido1} ${_padronData!.apellido2}'),
                              if (_padronData!.sexo != null)
                                Text('Sexo: ${_padronData!.sexo}'),
                              if (_padronData!.colegio != null)
                                Text('Colegio: ${_padronData!.colegio}'),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_padronData != null && !_yaRegistrado) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información Adicional',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<VotantesProvider>(
                          builder: (context, provider, _) {
                            return DropdownButtonFormField<int>(
                              value: _selectedColegioId,
                              decoration: InputDecoration(
                                labelText: 'Colegio Electoral',
                                prefixIcon: Icon(Icons.school),
                              ),
                              items: provider.colegios.map((colegio) {
                                return DropdownMenuItem<int>(
                                  value: colegio['id'],
                                  child: Text(colegio['nombre']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedColegioId = value;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _selectedMesa,
                          decoration: InputDecoration(
                            labelText: 'Mesa de Votación',
                            prefixIcon: Icon(Icons.table_chart),
                          ),
                          onChanged: (value) {
                            _selectedMesa = value;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _telefonoController,
                          decoration: InputDecoration(
                            labelText: 'Teléfono',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _direccionController,
                          decoration: InputDecoration(
                            labelText: 'Dirección',
                            prefixIcon: Icon(Icons.home),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _observacionesController,
                          decoration: InputDecoration(
                            labelText: 'Observaciones',
                            prefixIcon: Icon(Icons.note),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _guardarVotante,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Guardar Votante', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}