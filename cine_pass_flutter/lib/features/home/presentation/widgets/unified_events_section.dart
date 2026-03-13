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
        const SizedBox(height: 16),
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
          SizedBox(
            height: 310,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ..._films.map(
                  (film) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 160,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Chip(
                            label: const Text('Film'),
                            backgroundColor: AppTheme.primaryRed.withValues(
                              alpha: 0.3,
                            ),
                            labelStyle: const TextStyle(
                              color: AppTheme.primaryRed,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(height: 6),
                          SizedBox(height: 265, child: FilmCard(film: film)),
                        ],
                      ),
                    ),
                  ),
                ),
                ..._events.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Chip(
                            label: Text(event.category),
                            backgroundColor: AppTheme.accentGreen.withValues(
                              alpha: 0.3,
                            ),
                            labelStyle: const TextStyle(
                              color: AppTheme.accentGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(height: 6),
                          SizedBox(height: 265, child: EventCard(event: event)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
