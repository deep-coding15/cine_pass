import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/state/favorites_state.dart';
import '../../../../main.dart';

/// Page Préférences / Favoris : films et événements mis en favoris.
class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  List<FilmResponse> _films = [];
  List<EventResponse> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final favorites = FavoritesState.instance;
    final filmIds = favorites.filmIds;
    final eventIds = favorites.eventIds;
    setState(() => _loading = true);
    try {
      final films = <FilmResponse>[];
      for (final id in filmIds) {
        final f = await client.cinePass.getFilmById(id);
        if (f != null) films.add(f);
      }
      final events = <EventResponse>[];
      for (final id in eventIds) {
        final e = await client.cinePass.getEventById(id);
        if (e != null) events.add(e);
      }
      if (!mounted) return;
      setState(() {
        _films = films;
        _events = events;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _films = [];
        _events = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    if (!auth.isLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 64,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: 24),
              Text(
                'Connectez-vous pour voir vos favoris',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(AppRouter.connexion),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                ),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryRed),
      );
    }

    final films = _films;
    final events = _events;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: AppTheme.primaryRed,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Mes préférences',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Films et événements que vous avez mis en favoris',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          if (films.isEmpty && events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 48,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun favori pour le moment',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cliquez sur le cœur sur un film ou un événement pour l\'ajouter ici.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (films.isNotEmpty) ...[
              Text(
                'Films',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              ...films.map(
                (f) => _FavoriteTile(
                  title: f.title,
                  subtitle: f.genre,
                  onTap: () => context.go(AppRouter.filmDetailPath(f.id)),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (events.isNotEmpty) ...[
              Text(
                'Événements',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              ...events.map(
                (e) => _FavoriteTile(
                  title: e.title,
                  subtitle: '${e.location} • ${e.date}',
                  onTap: () => context.go(AppRouter.eventDetailPath(e.id)),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(
          Icons.favorite,
          color: AppTheme.primaryRed,
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        onTap: onTap,
      ),
    );
  }
}
