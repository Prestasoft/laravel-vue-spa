import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/votantes_provider.dart';
import '../widgets/votante_card.dart';
import '../widgets/filter_drawer.dart';

class VotantesListScreen extends StatefulWidget {
  const VotantesListScreen({Key? key}) : super(key: key);

  @override
  State<VotantesListScreen> createState() => _VotantesListScreenState();
}

class _VotantesListScreenState extends State<VotantesListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<VotantesProvider>();
      if (!provider.isLoading) {
        provider.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: FilterDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por cédula o teléfono',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<VotantesProvider>().setFilters(
                                      search: null,
                                    );
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (value) {
                      context.read<VotantesProvider>().setFilters(
                            search: value.isEmpty ? null : value,
                          );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<VotantesProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.votantes.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.votantes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${provider.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadVotantes(reset: true),
                          child: Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.votantes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No hay votantes registrados',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Presiona el botón + para agregar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadVotantes(reset: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: provider.votantes.length + 1,
                    itemBuilder: (context, index) {
                      if (index == provider.votantes.length) {
                        if (provider.isLoading) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (provider.currentPage < provider.totalPages) {
                          return Center(
                            child: TextButton(
                              onPressed: () => provider.loadMore(),
                              child: Text('Cargar más'),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      }

                      final votante = provider.votantes[index];
                      return VotanteCard(votante: votante);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}