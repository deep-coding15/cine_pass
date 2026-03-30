import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../main.dart';
import '../../../films/presentation/widgets/film_card.dart';
import '../../../events/presentation/widgets/event_card.dart';

/// Une seule section "À l'affiche" : films + événements sans différencier.
/// Tout ce qui est publié sur la plateforme (films et événements).
class UnifiedEventsSection extends StatefulWidget {
  const UnifiedEventsSection({super.key});

  @override
  State<UnifiedEventsSection> createState() => _UnifiedEventsSectionState();
}

class _UnifiedEventsSectionState extends State<UnifiedEventsSection> {
  List<FilmResponse> _films = [];
  List<EventResponse> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        client.cinePass.getFilms(),
        client.cinePass.getEvents(),
      ]);
      if (!mounted) return;
      setState(() {
        _films = (results[0] as List<FilmResponse>).take(6).toList();
        _events = (results[1] as List<EventResponse>).take(6).toList();
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

  static const double _cardWidth = 180;
  /// Hauteur suffisante pour EventCard (affiche 2/3 + texte + bouton) sans overflow.
  static const double _rowHeight = 500;

  @override
  Widget build(BuildContext context) {
    final allCount = _films.length + _events.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'À l\'affiche',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.go(AppRouter.events),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                label: const Text('Voir tous les événements'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryRed,
              ),
            ),
          )
        else if (allCount == 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Text(
              'Aucun événement pour le moment.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_films.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.movie_rounded,
                        size: 18,
                        color: AppTheme.primaryRed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Films',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: _rowHeight,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    clipBehavior: Clip.hardEdge,
                    children: _films.map((film) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: _cardWidth,
                          child: ClipRect(
                            child: FilmCard(film: film),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),
              ],
              if (_events.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: AppTheme.accentGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Événements',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: _rowHeight,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    clipBehavior: Clip.hardEdge,
                    children: _events.map((event) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: _cardWidth,
                          child: ClipRect(
                            child: EventCard(event: event),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}
