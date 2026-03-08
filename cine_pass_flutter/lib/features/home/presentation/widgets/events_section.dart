import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/state/favorites_state.dart';
import '../../../../main.dart';
import '../../../events/presentation/widgets/event_card.dart';

class EventsSection extends StatefulWidget {
  const EventsSection({super.key});

  @override
  State<EventsSection> createState() => _EventsSectionState();
}

class _EventsSectionState extends State<EventsSection> {
  List<EventResponse> _events = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final events = await client.cinePass.getEvents();
      if (!mounted) return;
      setState(() => _events = events.take(6).toList());
    } catch (_) {
      if (!mounted) return;
      setState(() => _events = []);
    }
  }

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
                'Événements à venir',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
              TextButton.icon(
                onPressed: () => context.go(AppRouter.events),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.textSecondary),
                label: const Text('Voir tous les événements'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final e = _events[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 220,
                  child: EventCard(event: e),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
