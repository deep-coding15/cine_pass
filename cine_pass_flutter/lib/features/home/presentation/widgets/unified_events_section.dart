import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../main.dart';
import '../../../events/presentation/widgets/event_card.dart';

/// Une seule section "À l'affiche" : événements uniquement.
class UnifiedEventsSection extends StatefulWidget {
  const UnifiedEventsSection({super.key});

  @override
  State<UnifiedEventsSection> createState() => _UnifiedEventsSectionState();
}

class _UnifiedEventsSectionState extends State<UnifiedEventsSection> {
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
      final events = await client.cinePass.getEvents();
      if (!mounted) return;
      setState(() {
        _events = events.take(8).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
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
                label: const Text('Voir tous'),
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
        else if (_events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Text(
              'Aucun événement pour le moment.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          )
        else
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
    );
  }
}
