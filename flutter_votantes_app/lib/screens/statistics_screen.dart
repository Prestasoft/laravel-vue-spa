import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/votantes_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VotantesProvider>(
      builder: (context, provider, _) {
        if (provider.estadisticas == null) {
          return Center(child: CircularProgressIndicator());
        }

        final stats = provider.estadisticas!;
        final total = stats['total'] ?? 0;
        final activos = stats['activos'] ?? 0;
        final inactivos = stats['inactivos'] ?? 0;

        return RefreshIndicator(
          onRefresh: () => provider.loadEstadisticas(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen General
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Votantes',
                        value: total.toString(),
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: 'Activos',
                        value: activos.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: 'Inactivos',
                        value: inactivos.toString(),
                        icon: Icons.cancel,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Gráfico de distribución
                if (total > 0) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distribución de Votantes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: activos.toDouble(),
                                    title: 'Activos\n$activos',
                                    color: Colors.green,
                                    radius: 100,
                                    titleStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (inactivos > 0)
                                    PieChartSectionData(
                                      value: inactivos.toDouble(),
                                      title: 'Inactivos\n$inactivos',
                                      color: Colors.red,
                                      radius: 100,
                                      titleStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                                centerSpaceRadius: 0,
                                sectionsSpace: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Distribución por Colegios
                if (stats['por_colegio'] != null &&
                    (stats['por_colegio'] as List).isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Votantes por Colegio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...(stats['por_colegio'] as List).map((item) {
                            final percentage = (item['total'] / total * 100)
                                .toStringAsFixed(1);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  item['total'].toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(item['colegio'] ?? 'Sin colegio'),
                              trailing: Text('$percentage%'),
                              subtitle: LinearProgressIndicator(
                                value: item['total'] / total,
                                backgroundColor: Colors.grey[300],
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.blue),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],

                // Distribución por Mesas
                if (stats['por_mesa'] != null &&
                    (stats['por_mesa'] as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Votantes por Mesa',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (stats['por_mesa'] as List).map((item) {
                              return Chip(
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: Text(
                                    item['total'].toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                label: Text('Mesa ${item['mesa']}'),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}