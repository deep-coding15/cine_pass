import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/state/favorites_state.dart';

class EventsSection extends StatelessWidget {
  const EventsSection({super.key});

  static const _events = [
    _EventItem(
      id: 'e1',
      title: 'Concert Électro Night',
      location: 'Gaumont Opéra - Paris',
      date: '15 mars 2028',
      price: '35.00 €',
      type: 'Concert',
      color: Color(0xFF4E1B3D),
    ),
    _EventItem(
      id: 'e2',
      title: 'Festival Jazz Live',
      location: 'Salle Pleyel - Paris',
      date: '20 mars 2028',
      price: '45.00 €',
      type: 'Concert',
      color: Color(0xFF1B4E3D),
    ),
    _EventItem(
      id: 'e3',
      title: 'Spectacle Théâtral - Hamlet',
      location: 'UGC Ciné Cité Confluence - Lyon',
      date: '25 mars 2028',
      price: '28.00 €',
      type: 'Théâtre',
      color: Color(0xFF3D2B1B),
    ),
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
                child: InkWell(
                  onTap: () => context.go(AppRouter.eventDetailPath(e.id)),
                  borderRadius: BorderRadius.circular(12),
                  child: _EventCard(item: e),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EventItem {
  const _EventItem({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.price,
    required this.type,
    required this.color,
  });
  final String id;
  final String title;
  final String location;
  final String date;
  final String price;
  final String type;
  final Color color;
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.item});

  final _EventItem item;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final favorites = context.watch<FavoritesState>();
    final isFav = favorites.isEventFavorite(item.id);
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 140,
                  width: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [item.color, item.color.withValues(alpha: 0.7)],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.event_rounded,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              if (auth.isLoggedIn)
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    onPressed: () => favorites.toggleEvent(item.id),
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? AppTheme.primaryRed : Colors.white70, size: 22),
                    style: IconButton.styleFrom(backgroundColor: Colors.black26, padding: const EdgeInsets.all(4)),
                  ),
                ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.type,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.location,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.date,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            item.price,
            style: const TextStyle(
              color: AppTheme.accentGreen,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
