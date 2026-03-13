import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/animated_background.dart';

class AdminScaffold extends StatelessWidget {
  const AdminScaffold({super.key, required this.child});

  final Widget child;

  bool _isActive(BuildContext context, String path) {
    final location = GoRouterState.of(context).uri.path;
    return location.startsWith(path) ||
        (path == '/admin' && (location == '/admin' || location == '/admin/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Row(
        children: [
          Container(
            width: 260,
            color: AppTheme.sidebarDark,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Espace Admin',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'CinePass',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppTheme.textSecondary, height: 1),
                  _AdminNavTile(
                    icon: Icons.dashboard_rounded,
                    label: 'Tableau de bord',
                    isActive: _isActive(context, '/admin'),
                    onTap: () => context.go(AppRouter.admin),
                  ),
                  _AdminNavTile(
                    icon: Icons.calendar_today_rounded,
                    label: 'Événements',
                    isActive: _isActive(context, '/admin/events'),
                    onTap: () => context.go('/admin/events'),
                  ),
                  _AdminNavTile(
                    icon: Icons.store_rounded,
                    label: 'Structures',
                    isActive: _isActive(context, '/admin/structures'),
                    onTap: () => context.go('/admin/structures'),
                  ),
                  _AdminNavTile(
                    icon: Icons.people_rounded,
                    label: 'Utilisateurs',
                    isActive: _isActive(context, '/admin/users'),
                    onTap: () => context.go('/admin/users'),
                  ),
                  _AdminNavTile(
                    icon: Icons.badge_outlined,
                    label: 'Demandes responsable',
                    isActive: _isActive(context, '/admin/demandes'),
                    onTap: () => context.go('/admin/demandes'),
                  ),
                  _AdminNavTile(
                    icon: Icons.confirmation_number_rounded,
                    label: 'Réservations',
                    isActive: _isActive(context, '/admin/reservations'),
                    onTap: () => context.go('/admin/reservations'),
                  ),
                  _AdminNavTile(
                    icon: Icons.assessment_rounded,
                    label: 'Rapport de statistiques',
                    isActive: _isActive(context, '/admin/stats'),
                    onTap: () => context.go('/admin/stats'),
                  ),
                  const Spacer(),
                  const Divider(color: AppTheme.textSecondary, height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppTheme.textSecondary,
                    ),
                    title: const Text(
                      'Retour à l\'app',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    onTap: () {
                      final router = GoRouter.of(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        router.go(AppRouter.home);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: AnimatedBackground(
              opacity: 0.06,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNavTile extends StatelessWidget {
  const _AdminNavTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isActive ? AppTheme.primaryRed : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isActive ? Colors.white : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppTheme.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
