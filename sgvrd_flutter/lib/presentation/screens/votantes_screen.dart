import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgvrd/core/theme/app_theme.dart';
import 'package:sgvrd/presentation/providers/auth_provider.dart';
import 'package:sgvrd/data/datasources/api_service.dart';
import 'package:sgvrd/data/models/votante_model.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

class VotantesScreen extends StatefulWidget {
  const VotantesScreen({super.key});

  @override
  State<VotantesScreen> createState() => _VotantesScreenState();
}

class _VotantesScreenState extends State<VotantesScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<VotanteModel> _votantes = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVotantes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreVotantes();
      }
    }
  }

  Future<void> _loadVotantes({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _isLoading = true;
      });
    }

    try {
      final votantes = await _apiService.getVotantes(
        page: _currentPage,
        search: _searchQuery,
      );

      setState(() {
        if (refresh || _currentPage == 1) {
          _votantes = votantes;
        } else {
          _votantes.addAll(votantes);
        }
        _isLoading = false;
        _hasMore = votantes.length >= 20; // Assuming 20 per page
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar votantes'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreVotantes() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    await _loadVotantes();

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _performSearch() {
    _searchQuery = _searchController.text.trim();
    _loadVotantes(refresh: true);
  }

  Future<void> _deleteVotante(VotanteModel votante) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Votante'),
        content: Text('¿Está seguro que desea eliminar a ${votante.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && votante.id != null) {
      final success = await _apiService.deleteVotante(votante.id!);
      if (success) {
        _loadVotantes(refresh: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Votante eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Votantes'),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        actions: [
          if (authProvider.hasPermission('add_votantes'))
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => context.push('/votantes/nuevo'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o cédula...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery = '';
                          _loadVotantes(refresh: true);
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onSubmitted: (_) => _performSearch(),
              onChanged: (value) {
                if (value.isEmpty && _searchQuery.isNotEmpty) {
                  _searchQuery = '';
                  _loadVotantes(refresh: true);
                }
                setState(() {});
              },
            ),
          ),

          // Results count
          if (!_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Text(
                    '${_votantes.length} votantes encontrados',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _loadVotantes(refresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _votantes.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _votantes.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final votante = _votantes[index];
                        return _buildVotanteCard(votante, authProvider);
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Votantes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              // Ya estamos aquí
              break;
            case 2:
              context.push('/mapa');
              break;
            case 3:
              context.push('/perfil');
              break;
          }
        },
      ),
    );
  }

  Widget _buildVotanteCard(VotanteModel votante, AuthProvider authProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.push('/votantes/${votante.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar con foto
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: votante.fotoBase64 != null && votante.fotoBase64!.isNotEmpty
                    ? ClipOval(
                        child: Image.memory(
                          base64Decode(votante.fotoBase64!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                votante.nombreCompleto.isNotEmpty
                                    ? votante.nombreCompleto[0].toUpperCase()
                                    : 'V',
                                style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          votante.nombreCompleto.isNotEmpty
                              ? votante.nombreCompleto[0].toUpperCase()
                              : 'V',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      votante.nombreCompleto.isNotEmpty
                          ? votante.nombreCompleto
                          : 'Sin nombre',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          votante.cedula,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (votante.telefono != null && votante.telefono!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            votante.telefono!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (votante.dirigenteNombre != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Coordinador: ${votante.dirigenteNombre}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  // GPS Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: votante.tieneGps
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          votante.tieneGps ? Icons.location_on : Icons.location_off,
                          size: 14,
                          color: votante.tieneGps ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          votante.tieneGps ? 'GPS' : 'Sin GPS',
                          style: TextStyle(
                            fontSize: 11,
                            color: votante.tieneGps ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Actions Menu
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          context.push('/votantes/${votante.id}');
                          break;
                        case 'edit':
                          context.push('/votantes/${votante.id}?edit=true');
                          break;
                        case 'delete':
                          _deleteVotante(votante);
                          break;
                        case 'call':
                          // Implement phone call
                          break;
                        case 'map':
                          // Navigate to map with this votante
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 8),
                            Text('Ver detalles'),
                          ],
                        ),
                      ),
                      if (authProvider.hasPermission('edit_votantes'))
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                      if (votante.tieneTelefono)
                        const PopupMenuItem(
                          value: 'call',
                          child: Row(
                            children: [
                              Icon(Icons.phone, size: 20),
                              SizedBox(width: 8),
                              Text('Llamar'),
                            ],
                          ),
                        ),
                      if (votante.tieneGps)
                        const PopupMenuItem(
                          value: 'map',
                          child: Row(
                            children: [
                              Icon(Icons.map, size: 20),
                              SizedBox(width: 8),
                              Text('Ver en mapa'),
                            ],
                          ),
                        ),
                      if (authProvider.hasPermission('delete_votantes'))
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}