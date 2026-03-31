import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../router/app_router.dart';
import '../state/auth_state.dart';
import '../state/pending_reservation_state.dart';
import 'app_drawer.dart';
import 'animated_background.dart';
import 'app_bottom_bar.dart';
import 'cinepass_logo.dart';
import '../../features/admin/presentation/widgets/admin_scaffold.dart';

/// Largeur en dessous de laquelle la barre du haut n’affiche plus les liens texte
/// (Accueil / Événements / Billets) pour éviter les débordements RenderFlex sur mobile.
const double _kCompactTopNavWidth = 900;

/// Encore plus serré : menu Profil en icône seule (sans texte « Profil »).
const double _kVeryCompactTopNavWidth = 620;

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isAdmin = widget.location.startsWith('/admin');
    final narrowAdmin = isAdmin && width < kAdminSidebarBreakpoint;
    final compactTopNav = width < _kCompactTopNavWidth;
    final veryCompactTopNav = width < _kVeryCompactTopNavWidth;

    final auth = context.watch<AuthState>();
    final isAuthPage =
        widget.location == AppRouter.connexion ||
        widget.location == AppRouter.inscription ||
        widget.location == AppRouter.connexionResponsable;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundDark,
      appBar: isAdmin
          ? (narrowAdmin
                ? AppBar(
                    title: const Text('Espace Admin'),
                    backgroundColor: AppTheme.backgroundDark,
                    foregroundColor: AppTheme.textPrimary,
                  )
                : null)
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: isAuthPage
                  ? null
                  : GestureDetector(
                      onTap: () => context.go(AppRouter.home),
                      child: const CinePassLogo(size: LogoSize.small),
                    ),
              centerTitle: true,
              actions: [
                if (auth.isLoggedIn) ...[
                  IconButton(
                    icon: const Icon(Icons.favorite_rounded),
                    color: AppTheme.primaryRed,
                    onPressed: () => context.go(AppRouter.preferences),
                    tooltip: 'Préférences',
                  ),
                  if (!compactTopNav) ...[
                    TextButton(
                      onPressed: () => context.go(AppRouter.home),
                      child: const Text('Accueil'),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRouter.events),
                      child: const Text('Événements'),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRouter.billets),
                      child: const Text('Billets'),
                    ),
                  ],
                  if (auth.isResponsable) ...[
                    if (compactTopNav)
                      IconButton(
                        icon: const Icon(Icons.business_center_rounded),
                        color: AppTheme.accentGreen,
                        tooltip: 'Espace responsable',
                        onPressed: () => context.go(AppRouter.responsable),
                      )
                    else ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: FilledButton(
                          onPressed: () => context.go(AppRouter.responsable),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.accentGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          child: const Text('Espace responsable'),
                        ),
                      ),
                    ],
                  ],
                  PopupMenuButton<String>(
                    offset: const Offset(0, 48),
                    tooltip: auth.isResponsable
                        ? 'Profil · Déconnexion'
                        : 'Profil · Devenir responsable · Déconnexion',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: veryCompactTopNav
                          ? const Icon(Icons.person_rounded, size: 26)
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Profil'),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_drop_down, size: 20),
                              ],
                            ),
                    ),
                    onSelected: (value) {
                      if (value == 'profil') {
                        context.go(AppRouter.profil);
                      } else if (value == 'devenir_responsable') {
                        context.go(AppRouter.devenirResponsable);
                      } else if (value == 'deconnexion') {
                        context.read<PendingReservationState>().clear();
                        auth.logout();
                        context.go(AppRouter.home);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'profil',
                        child: Text('Voir mon profil'),
                      ),
                      if (!auth.isResponsable)
                        const PopupMenuItem(
                          value: 'devenir_responsable',
                          child: Row(
                            children: [
                              Icon(
                                Icons.badge_outlined,
                                size: 20,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(width: 12),
                              Text('Devenir responsable'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'deconnexion',
                        child: Text('Déconnexion'),
                      ),
                    ],
                  ),
                  if (auth.isAdmin) ...[
                    if (compactTopNav)
                      IconButton(
                        icon: const Icon(Icons.admin_panel_settings_rounded),
                        color: AppTheme.primaryRed,
                        tooltip: 'Espace admin',
                        onPressed: () => context.go(AppRouter.admin),
                      )
                    else ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: FilledButton(
                          onPressed: () => context.go(AppRouter.admin),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                          ),
                          child: const Text('Espace admin'),
                        ),
                      ),
                    ],
                  ],
                ] else if (!isAuthPage) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: FilledButton.icon(
                      onPressed: () => context.go(AppRouter.connexion),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                      ),
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text('S\'authentifier'),
                    ),
                  ),
                ],
              ],
            ),
      drawer: isAdmin
          ? (narrowAdmin
                ? Drawer(
                    backgroundColor: AppTheme.sidebarDark,
                    child: const AdminSidebarPanel(),
                  )
                : null)
          : Drawer(
              backgroundColor: AppTheme.sidebarDark,
              elevation: 0,
              child: const AppDrawer(),
            ),
      body: KeyedSubtree(
        key: ValueKey<bool>(isAdmin),
        child: isAdmin
            ? (narrowAdmin
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: widget.child),
                        const AppBottomBar(compactLinks: true),
                      ],
                    )
                  : Row(
                      children: [
                        const AdminSidebar(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: widget.child),
                              const AppBottomBar(compactLinks: true),
                            ],
                          ),
                        ),
                      ],
                    ))
            : Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedBackground(
                    opacity: 0.06,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: widget.child),
                        const AppBottomBar(),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 24,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => _scaffoldKey.currentState?.openDrawer(),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
