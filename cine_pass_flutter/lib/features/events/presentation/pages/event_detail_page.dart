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

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  int _quantity = 1;
  EventResponse? _event;
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
      final event = await client.cinePass.getEventById(widget.eventId);
      if (!mounted) return;
      setState(() {
        _event = event;
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
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
    }
    if (_error != null || _event == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error ?? 'Événement introuvable', style: const TextStyle(color: AppTheme.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }
    final event = _event!;
    final maxQty = event.placesLeft.clamp(1, 999);
    final total = event.price * _quantity;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.go(AppRouter.events),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                const Text('Retour', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(event.category, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(event.posterColor ?? 0xFF4E1B3D),
                      Color(event.posterColor ?? 0xFF4E1B3D).withValues(alpha: 0.5),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.event_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: _EventFavoriteHeart(eventId: event.id),
              ),
              Positioned(
                left: 24,
                bottom: 24,
                child: Text(
                  event.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: AppTheme.cardDark,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event.description ?? '',
                              style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: AppTheme.cardDark,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations pratiques',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on_outlined, size: 20, color: AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(event.location, style: const TextStyle(color: AppTheme.textPrimary)),
                                      Text(event.address ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                      Text(event.city, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 20, color: AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Text(event.date, style: const TextStyle(color: AppTheme.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 20, color: AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Text(event.time, style: const TextStyle(color: AppTheme.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.people_outline_rounded, size: 20, color: AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  '${event.placesLeft} places disponibles',
                                  style: const TextStyle(color: AppTheme.textPrimary),
                                ),
                                Text(
                                  ' sur ${event.placesTotal} au total',
                                  style: const TextStyle(color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 320,
                child: Card(
                  color: AppTheme.cardDark,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Prix par billet',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${event.price.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            color: AppTheme.accentGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Nombre de billets',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton.filled(
                              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
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
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20),
                              ),
                            ),
                            IconButton.filled(
                              onPressed: _quantity < maxQty ? () => setState(() => _quantity++) : null,
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.surfaceDark,
                                foregroundColor: AppTheme.textPrimary,
                              ),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                        Text(
                          'Maximum : ${event.placesLeft} billets',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppTheme.textSecondary),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sous-total', style: TextStyle(color: AppTheme.textSecondary)),
                            Text('${total.toStringAsFixed(2)} €', style: const TextStyle(color: AppTheme.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                            Text(
                              '${total.toStringAsFixed(2)} €',
                              style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              final auth = context.read<AuthState>();
                              if (!auth.isLoggedIn) {
                                context.read<PendingReservationState>().setPendingEvent(
                                  eventId: event.id,
                                  eventTitle: event.title,
                                  eventLocation: '${event.location}, ${event.city}',
                                  eventDateTime: '${event.date} à ${event.time}',
                                  quantity: _quantity,
                                  pricePerTicket: event.price,
                                  availableOptions: event.availableOptions ?? [],
                                );
                                context.go(AppRouter.connexion);
                                return;
                              }
                              ReservationState.instance.setEventReservation(
                                eventId: event.id,
                                eventTitle: event.title,
                                eventLocation: '${event.location}, ${event.city}',
                                eventDateTime: '${event.date} à ${event.time}',
                                quantity: _quantity,
                                pricePerTicket: event.price,
                                availableOptions: event.availableOptions ?? [],
                              );
                              context.push(AppRouter.reservationTypeBillet);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primaryRed,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Continuer'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Vous pourrez payer lors de l\'étape suivante',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventFavoriteHeart extends StatelessWidget {
  const _EventFavoriteHeart({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesState>();
    final isFav = favorites.isEventFavorite(eventId);
    return IconButton(
      onPressed: () => favorites.toggleEvent(eventId),
      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? AppTheme.primaryRed : Colors.white70, size: 28),
      style: IconButton.styleFrom(backgroundColor: Colors.black38),
    );
  }
}
