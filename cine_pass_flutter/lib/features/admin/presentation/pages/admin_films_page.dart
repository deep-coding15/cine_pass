import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../../data/mock_admin_data.dart';
import '../widgets/admin_add_film_dialog.dart';

class AdminFilmsPage extends StatefulWidget {
  const AdminFilmsPage({super.key});

  @override
  State<AdminFilmsPage> createState() => _AdminFilmsPageState();
}

class _AdminFilmsPageState extends State<AdminFilmsPage> {
  final _searchController = TextEditingController();
  List<FilmResponse> _films = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final films = await client.cinePass.getFilms();
      if (!mounted) return;
      setState(() {
        _films = films;
        _loading = false;
        _applySearch();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _films = [];
        _loading = false;
      });
    }
  }

  void _applySearch() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _films = _films.where((f) {
        return q.isEmpty ||
            f.title.toLowerCase().contains(q) ||
            f.genre.toLowerCase().contains(q) ||
            (f.director ?? '').toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryRed),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestion des films',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gérez les films disponibles sur la plateforme',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => AdminAddFilmDialog(onSaved: _load),
                  );
                  if (mounted) _load();
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Nouveau film'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            onChanged: (_) => _applySearch(),
            decoration: InputDecoration(
              hintText: 'Rechercher un film...',
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
              prefixIcon: const Icon(
                Icons.search,
                color: AppTheme.textSecondary,
              ),
              filled: true,
              fillColor: AppTheme.cardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 24),
          ..._films.map((film) => _FilmAdminCard(film: film)),
        ],
      ),
    );
  }
}

class _FilmAdminCard extends StatelessWidget {
  const _FilmAdminCard({required this.film});

  final FilmResponse film;

  @override
  Widget build(BuildContext context) {
    final audience = audienceForFilmId(film.id);
    final posterColor = film.posterColor ?? 0xFF2D1B4E;
    return Card(
      color: AppTheme.cardDark,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 110,
                color: Color(posterColor),
                child: Icon(
                  Icons.movie_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 36,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    film.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${film.genre} • ${film.durationMinutes} min • $audience',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    film.synopsis ?? '',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Réalisateur: ${film.director ?? ''}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Sortie: ${releaseDateForFilmId(film.id)}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Fin: ${endDateForFilmId(film.id)}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppTheme.textSecondary,
                  ),
                  tooltip: 'Modifier',
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.primaryRed,
                  ),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
