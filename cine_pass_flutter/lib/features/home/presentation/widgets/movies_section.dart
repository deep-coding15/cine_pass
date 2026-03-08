import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/state/favorites_state.dart';

class MoviesSection extends StatelessWidget {
  const MoviesSection({super.key});

  static const _movies = [
    _MovieItem(id: '1', title: 'Horizon Quantique', genre: 'Science-Fiction', rating: 8.5, color: Color(0xFF2D1B4E)),
    _MovieItem(id: '2', title: 'Les Gardiens du Temps', genre: 'Action', rating: 7.8, color: Color(0xFF1B3D4E)),
    _MovieItem(id: '3', title: 'Rire et Préjugés', genre: 'Comédie', rating: 7.3, color: Color(0xFF4E3D1B)),
    _MovieItem(id: '4', title: 'Le Dernier Refuge', genre: 'Drame', rating: 8.0, color: Color(0xFF2E1A1A)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Films à l'affiche",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
              TextButton.icon(
                onPressed: () => context.go(AppRouter.films),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.textSecondary),
                label: const Text('Voir tous les films'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 295,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _movies.length,
            itemBuilder: (context, index) {
              final m = _movies[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: InkWell(
                  onTap: () => context.go(AppRouter.filmDetailPath(m.id)),
                  borderRadius: BorderRadius.circular(12),
                  child: _MovieCard(item: m),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MovieItem {
  const _MovieItem({
    required this.id,
    required this.title,
    required this.genre,
    required this.rating,
    required this.color,
  });
  final String id;
  final String title;
  final String genre;
  final double rating;
  final Color color;
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.item});

  final _MovieItem item;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final favorites = context.watch<FavoritesState>();
    final isFav = favorites.isFilmFavorite(item.id);
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 180,
                  width: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [item.color, item.color.withValues(alpha: 0.7)],
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.movie_rounded, size: 48, color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              if (auth.isLoggedIn)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => favorites.toggleFilm(item.id),
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? AppTheme.primaryRed : Colors.white70, size: 24),
                    style: IconButton.styleFrom(backgroundColor: Colors.black26, padding: const EdgeInsets.all(6)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.genre,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                item.rating.toString(),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
