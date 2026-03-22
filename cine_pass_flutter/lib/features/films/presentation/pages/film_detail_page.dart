import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/state/favorites_state.dart';
import '../../../../core/state/pending_reservation_state.dart';
import '../../../../features/reservation/data/reservation_state.dart';
import '../../../../main.dart';

class FilmDetailPage extends StatefulWidget {
  const FilmDetailPage({super.key, required this.filmId});

  final String filmId;

  @override
  State<FilmDetailPage> createState() => _FilmDetailPageState();
}

class _FilmDetailPageState extends State<FilmDetailPage> {
  int _quantity = 1;
  FilmResponse? _film;
  List<SeanceResponse> _seances = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final film = await client.cinePass.getFilmById(widget.filmId);
      final seances = await client.cinePass.getSeancesForFilm(widget.filmId);
      if (!mounted) return;
      setState(() {
        _film = film;
        _seances = seances;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryRed),
      );
    }
    if (_error != null || _film == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error ?? 'Film introuvable',
              style: const TextStyle(color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }
    final film = _film!;
    final seances = _seances;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.go(AppRouter.films),
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text('Retour', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(film.posterColor ?? 0xFF2D1B4E),
                      Color(
                        film.posterColor ?? 0xFF2D1B4E,
                      ).withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.movie_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: _FavoriteHeart(filmId: film.id),
              ),
              Positioned(
                left: 24,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      film.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${film.durationMinutes} min',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        _tag(film.genre),
                        const SizedBox(width: 8),
                        _tag('Tous publics'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            film.synopsis ?? '',
            style: const TextStyle(color: AppTheme.textPrimary, height: 1.5),
          ),
          if ((film.director ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Réalisateur: ${film.director}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
          if ((film.casting ?? '').isNotEmpty)
            Text(
              'Casting: ${film.casting}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          const SizedBox(height: 32),
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nombre de billets',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton.filled(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.surfaceDark,
                          foregroundColor: AppTheme.textPrimary,
                        ),
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: _quantity < 10
                            ? () => setState(() => _quantity++)
                            : null,
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.surfaceDark,
                          foregroundColor: AppTheme.textPrimary,
                        ),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Séances disponibles',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...seances.map(
            (s) => _SeanceCard(
              film: film,
              seance: s,
              quantity: _quantity,
              onReserver: () {
                final auth = context.read<AuthState>();
                if (_quantity > s.placesLeft) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Pas assez de places pour cette séance (${s.placesLeft} restantes).',
                      ),
                    ),
                  );
                  return;
                }
                if (!auth.isLoggedIn) {
                  context.read<PendingReservationState>().setPendingFilm(
                    filmId: film.id,
                    filmTitle: film.title,
                    seanceId: s.id,
                    cinemaName: s.cinemaName,
                    cinemaLocation: s.location,
                    room: s.room,
                    dateTime: s.dateTime,
                    format: s.format ?? 'VF',
                    type: s.type ?? '2D',
                    pricePerSeat: s.price,
                    quantity: _quantity,
                    availableOptions: s.availableOptions ?? [],
                  );
                  context.go(AppRouter.connexion);
                  return;
                }
                ReservationState.instance.setFilmReservation(
                  filmId: film.id,
                  filmTitle: film.title,
                  seanceId: s.id,
                  cinemaName: s.cinemaName,
                  cinemaLocation: s.location,
                  room: s.room,
                  dateTime: s.dateTime,
                  format: s.format,
                  type: s.type,
                  pricePerSeat: s.price,
                  quantity: _quantity,
                  availableOptions: s.availableOptions,
                );
                context.push(AppRouter.reservationTypeBillet);
              },
            ),
          ),
          if (seances.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Aucune séance disponible.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
      ),
    );
  }
}

class _SeanceCard extends StatelessWidget {
  const _SeanceCard({
    required this.film,
    required this.seance,
    required this.quantity,
    required this.onReserver,
  });

  final FilmResponse film;
  final SeanceResponse seance;
  final int quantity;
  final VoidCallback onReserver;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seance.cinemaName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        seance.location,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        seance.dateTime,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.language_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      Text(
                        ' ${seance.format} ',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          seance.type ?? '2D',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                      children: [
                        const TextSpan(text: 'Places restantes: '),
                        TextSpan(
                          text: '${seance.placesLeft}',
                          style: const TextStyle(
                            color: AppTheme.accentGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: '/${seance.placesTotal}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${seance.price.toStringAsFixed(2)} MAD',
                        style: const TextStyle(
                          color: AppTheme.accentGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'par place',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: quantity <= seance.placesLeft ? onReserver : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
              ),
              child: Text(
                quantity <= seance.placesLeft
                    ? 'Réserver ($quantity billet${quantity > 1 ? 's' : ''})'
                    : 'Complet',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteHeart extends StatelessWidget {
  const _FavoriteHeart({required this.filmId});

  final String filmId;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesState>();
    final isFav = favorites.isFilmFavorite(filmId);
    return IconButton(
      onPressed: () => favorites.toggleFilm(filmId),
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? AppTheme.primaryRed : Colors.white70,
        size: 28,
      ),
      style: IconButton.styleFrom(backgroundColor: Colors.black38),
    );
  }
}
