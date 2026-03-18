import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../router/app_router.dart';
import '../state/auth_state.dart';
import '../state/pending_reservation_state.dart';
import 'app_drawer.dart';
import 'animated_background.dart';
import 'cinepass_logo.dart';
import '../../features/admin/presentation/widgets/admin_scaffold.dart';

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
    final isAdmin = widget.location.startsWith('/admin');
    final auth = context.watch<AuthState>();
    final isAuthPage =
        widget.location == AppRouter.connexion ||
        widget.location == AppRouter.inscription ||
        widget.location == AppRouter.connexionResponsable;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundDark,
      appBar: isAdmin
          ? null
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
            PopupMenuButton<String>(
              offset: const Offset(0, 48),
              tooltip: 'Profil · Devenir responsable · Déconnexion',
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
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
          ? null
          : Drawer(
              backgroundColor: AppTheme.sidebarDark,
              elevation: 0,
              child: const AppDrawer(),
            ),
      body: KeyedSubtree(
        key: ValueKey<bool>(isAdmin),
        child: isAdmin
            ? Row(
                children: [
                  const AdminSidebar(),
                  Expanded(child: widget.child),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedBackground(
                    opacity: 0.06,
                    child: widget.child,
                  ),
                  // Bande gauche : survol pour ouvrir le drawer (sidebar)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 24,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) =>
                          _scaffoldKey.currentState?.openDrawer(),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
