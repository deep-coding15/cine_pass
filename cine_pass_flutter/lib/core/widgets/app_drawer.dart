import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../router/app_router.dart';
import '../state/auth_state.dart';
import 'cinepass_logo.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    String location;
    try {
      location = GoRouterState.of(context).uri.path;
    } catch (_) {
      location = '/';
    }
    if (location.isEmpty) location = '/';
    bool isActive(String path) {
      if (path == AppRouter.home) return location == '/' || location.isEmpty;
      if (path == AppRouter.admin) return location.startsWith('/admin');
      if (path == AppRouter.responsable) return location.startsWith('/responsable');
      return location == path;
    }

    return Container(
      width: double.infinity,
      color: AppTheme.sidebarDark,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CinePassLogo(size: LogoSize.small),
                      if (!auth.isLoggedIn) ...[
                        const SizedBox(width: 12),
                        Text(
                          'Menu',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
            if (auth.isLoggedIn) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.sidebarActiveLine,
                      child: Text(
                        auth.userInitials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.userName,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            auth.userEmail,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.textSecondary, height: 1),
              const SizedBox(height: 8),
            ],
            _DrawerTile(
              icon: Icons.home_rounded,
              label: 'Accueil',
              isActive: isActive(AppRouter.home),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRouter.home);
              },
            ),
            _DrawerTile(
              icon: Icons.calendar_today_rounded,
              label: 'Événements',
              isActive: isActive(AppRouter.events),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRouter.events);
              },
            ),
            _DrawerTile(
              icon: Icons.search_rounded,
              label: 'Rechercher avec filtres',
              isActive: isActive(AppRouter.events),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRouter.events);
              },
            ),
            if (auth.isLoggedIn)
              _DrawerTile(
                icon: Icons.badge_outlined,
                label: 'Devenir responsable',
                isActive: isActive(AppRouter.devenirResponsable),
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRouter.devenirResponsable);
                },
              ),
            if (auth.isLoggedIn) ...[
              _DrawerTile(
                icon: Icons.confirmation_number_rounded,
                label: 'Mes billets',
                isActive: isActive(AppRouter.billets),
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRouter.billets);
                },
              ),
              _DrawerTile(
                icon: Icons.person_rounded,
                label: 'Profil',
                isActive: isActive(AppRouter.profil),
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRouter.profil);
                },
              ),
              if (auth.isAdmin)
                _DrawerTile(
                  icon: Icons.admin_panel_settings_rounded,
                  label: 'Espace admin',
                  isActive: isActive(AppRouter.admin),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.admin);
                  },
                  highlight: true,
                ),
              if (auth.isResponsable)
                _DrawerTile(
                  icon: Icons.store_rounded,
                  label: 'Espace responsable',
                  isActive: isActive(AppRouter.responsable),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.responsable);
                  },
                  highlight: true,
                ),
              const Divider(color: AppTheme.textSecondary, height: 24),
            ],
            _DrawerTile(
              icon: Icons.help_outline_rounded,
              label: 'FAQ',
              isActive: isActive(AppRouter.faq),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRouter.faq);
              },
            ),
            _DrawerTile(
              icon: Icons.headset_rounded,
              label: 'Support',
              isActive: isActive(AppRouter.support),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRouter.support);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final useHighlight = isActive || highlight;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: useHighlight
            ? AppTheme.sidebarActiveBg
            : (highlight && isActive
                  ? AppTheme.primaryRed
                  : Colors.transparent),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: isActive
                  ? Border(
                      left: BorderSide(
                        color: highlight
                            ? Colors.white
                            : AppTheme.sidebarActiveLine,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isActive
                      ? (highlight ? Colors.white : AppTheme.textPrimary)
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? (highlight ? Colors.white : AppTheme.textPrimary)
                        : AppTheme.textSecondary,
                    fontSize: 16,
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
