import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgvrd/presentation/screens/login_screen.dart';
import 'package:sgvrd/presentation/screens/dashboard_screen.dart';
import 'package:sgvrd/presentation/screens/votantes_screen.dart';
import 'package:sgvrd/presentation/screens/votante_detail_screen.dart';
import 'package:sgvrd/presentation/screens/map_screen.dart';
import 'package:sgvrd/presentation/screens/profile_screen.dart';
import 'package:sgvrd/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
        redirect: (context, state) {
          final authProvider = context.read<AuthProvider>();
          if (!authProvider.isAuthenticated) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/votantes',
        name: 'votantes',
        builder: (context, state) => const VotantesScreen(),
        redirect: (context, state) {
          final authProvider = context.read<AuthProvider>();
          if (!authProvider.isAuthenticated) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/votantes/nuevo',
        name: 'votante-nuevo',
        builder: (context, state) => const VotanteDetailScreen(isNew: true),
        redirect: (context, state) {
          final authProvider = context.read<AuthProvider>();
          if (!authProvider.isAuthenticated) {
            return '/login';
          }
          if (!authProvider.hasPermission('add_votantes')) {
            return '/dashboard';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/votantes/:id',
        name: 'votante-detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return VotanteDetailScreen(votanteId: id);
        },
        redirect: (context, state) {
          final authProvider = context.read<AuthProvider>();
          if (!authProvider.isAuthenticated) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/mapa',
        name: 'mapa',
        builder: (context, state) => const MapScreen(),
        redirect: (context, state) {
          final authProvider = context.read<AuthProvider>();
          if (!authProvider.isAuthenticated) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/perfil',
        name: 'perfil',
        builder: (context, state) => const ProfileScreen(),
        redirect: (context, state) {
          final authProvider = context.read<AuthProvider>();
          if (!authProvider.isAuthenticated) {
            return '/login';
          }
          return null;
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Error desconocido',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Ir al Inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}