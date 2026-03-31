import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/animated_background.dart';
import '../../../../core/widgets/app_bottom_bar.dart';
import '../../../admin/presentation/widgets/admin_scaffold.dart';

/// Contenu du menu responsable (sidebar bureau ou drawer mobile).
class ResponsableSidebarPanel extends StatelessWidget {
  const ResponsableSidebarPanel({super.key});

  bool _isActive(BuildContext context, String path) {
    final location = GoRouterState.of(context).uri.path;
    return location.startsWith(path) ||
        (path == '/responsable' &&
            (location == '/responsable' || location == '/responsable/'));
  }

  void _navigate(BuildContext context, void Function() go) {
    Scaffold.maybeOf(context)?.closeDrawer();
    go();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    'Espace Responsable',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gérer vos structures et événements',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.textSecondary, height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _ResponsableNavTile(
                    icon: Icons.dashboard_rounded,
                    label: 'Tableau de bord',
                    isActive: _isActive(context, '/responsable'),
                    onTap: () => _navigate(
                      context,
                      () => context.go(AppRouter.responsable),
                    ),
                  ),
                  _ResponsableNavTile(
                    icon: Icons.store_rounded,
                    label: 'Ma structure',
                    isActive: _isActive(context, '/responsable/structures'),
                    onTap: () => _navigate(
                      context,
                      () => context.go(AppRouter.responsableStructures),
                    ),
                  ),
                  _ResponsableNavTile(
                    icon: Icons.calendar_today_rounded,
                    label: 'Mes événements',
                    isActive: _isActive(context, '/responsable/events'),
                    onTap: () => _navigate(
                      context,
                      () => context.go(AppRouter.responsableEvents),
                    ),
                  ),
                  _ResponsableNavTile(
                    icon: Icons.confirmation_number_rounded,
                    label: 'Réservations',
                    isActive: _isActive(context, '/responsable/reservations'),
                    onTap: () => _navigate(
                      context,
                      () => context.go(AppRouter.responsableReservations),
                    ),
                  ),
                  _ResponsableNavTile(
                    icon: Icons.bar_chart_rounded,
                    label: 'Rapports',
                    isActive: _isActive(context, '/responsable/rapports'),
                    onTap: () => _navigate(
                      context,
                      () => context.go(AppRouter.responsableRapports),
                    ),
                  ),
                ],
              ),
            ),
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
                Scaffold.maybeOf(context)?.closeDrawer();
                final router = GoRouter.of(context);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  router.go(AppRouter.home);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsableScaffold extends StatelessWidget {
  const ResponsableScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < kAdminSidebarBreakpoint;

    if (narrow) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          title: const Text('Espace responsable'),
          backgroundColor: AppTheme.backgroundDark,
          foregroundColor: AppTheme.textPrimary,
        ),
        drawer: Drawer(
          backgroundColor: AppTheme.sidebarDark,
          child: const ResponsableSidebarPanel(),
        ),
        body: AnimatedBackground(
          opacity: 0.06,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: child),
              const AppBottomBar(compactLinks: true),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: ResponsableSidebarPanel(),
          ),
          Expanded(
            child: AnimatedBackground(
              opacity: 0.06,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: child),
                  const AppBottomBar(compactLinks: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsableNavTile extends StatelessWidget {
  const _ResponsableNavTile({
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
        color: isActive ? AppTheme.accentGreen : Colors.transparent,
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
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
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
