import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../router/app_router.dart';
import '../state/auth_state.dart';
import '../state/pending_reservation_state.dart';
import 'app_drawer.dart';
import 'cinepass_logo.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, required this.child});

  final Widget child;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const CinePassLogo(size: LogoSize.small),
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
              onPressed: () => context.go(AppRouter.films),
              child: const Text('Films'),
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
          ] else ...[
            TextButton(
              onPressed: () => context.go(AppRouter.connexion),
              child: const Text('Connexion'),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton(
                onPressed: () => context.go(AppRouter.inscription),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                ),
                child: const Text('Inscription'),
              ),
            ),
          ],
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppTheme.sidebarDark,
        elevation: 0,
        child: const AppDrawer(),
      ),
      body: widget.child,
    );
  }
}
