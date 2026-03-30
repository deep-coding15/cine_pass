import 'dart:convert';
import 'dart:math' as math;

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
import '../widgets/event_type_badge.dart';

/// Places encore réservables : somme des quotas restants (types actifs), sinon `placesLeft` de l’événement.
String _formatEventTimeLabel(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return '—';
  final d = DateTime.tryParse(t);
  if (d != null) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
  if (RegExp(r'^\d{1,2}:\d{2}').hasMatch(t)) {
    return t.length >= 5 ? t.substring(0, 5) : t;
  }
  return t;
}

Widget _eventHeroImage(EventResponse event) {
  final posterUrl = event.posterUrl;
  final posterColor = event.posterColor ?? 0xFF4E1B3D;
  final c = Color(posterColor);
  final fallback = Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c, c.withValues(alpha: 0.5)],
      ),
    ),
    child: Center(
      child: Icon(
        Icons.event_rounded,
        size: 64,
        color: Colors.white.withValues(alpha: 0.4),
      ),
    ),
  );
  if (posterUrl == null || posterUrl.isEmpty) return fallback;
  if (posterUrl.startsWith('data:')) {
    try {
      final i = posterUrl.indexOf(',');
      if (i > 0) {
        final bytes = base64Decode(posterUrl.substring(i + 1));
        return Image.memory(
          bytes,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback,
        );
      }
    } catch (_) {
      return fallback;
    }
  }
  return Image.network(
    posterUrl,
    height: 200,
    width: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => fallback,
  );
}

int _maxBookableTickets(
  EventResponse event,
  EventReservationConfigResponse? cfg,
) {
  final active = cfg?.ticketTypes.where((t) => t.active).toList() ?? [];
  if (active.isEmpty) {
    return event.placesLeft;
  }
  return active.fold<int>(0, (sum, t) => sum + t.remaining);
}

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  int _quantity = 1;
  EventResponse? _event;
  EventReservationConfigResponse? _reservationConfig;
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
      final config = await client.cinePass.getEventReservationConfig(
        widget.eventId,
      );
      if (!mounted) return;
      if (event == null) {
        setState(() {
          _loading = false;
          _error = 'Événement introuvable';
        });
        return;
      }
      setState(() {
        _event = event;
        _reservationConfig = config;
        final maxB = _maxBookableTickets(event, config);
        if (maxB > 0 && _quantity > maxB) {
          _quantity = maxB;
        }
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
    if (_error != null || _event == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error ?? 'Événement introuvable',
              style: const TextStyle(color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }
    final event = _event!;
    final cfg = _reservationConfig;
    final activeTypes =
        cfg?.ticketTypes.where((t) => t.active).toList() ?? const [];
    final maxBookable = _maxBookableTickets(event, cfg);
    final maxPerOrder = cfg?.maxTicketsPerOrder ?? 8;
    final maxQty = maxBookable <= 0 ? 0 : math.min(maxBookable, maxPerOrder);
    final referenceUnitPrice = activeTypes.isEmpty
        ? event.price
        : activeTypes.map((t) => t.price).reduce((a, b) => a < b ? a : b);
    final maxUnitPrice = activeTypes.isEmpty
        ? event.price
        : activeTypes.map((t) => t.price).reduce((a, b) => a > b ? a : b);
    final multiTarif =
        activeTypes.length > 1 &&
        (maxUnitPrice - referenceUnitPrice).abs() > 0.009;
    final minEstimateTotal = referenceUnitPrice * _quantity;
    final maxEstimateTotal = maxUnitPrice * _quantity;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.go(AppRouter.events),
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Retour',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _eventHeroImage(event),
              ),
              if (context.watch<AuthState>().isLoggedIn)
                Positioned(
                  top: 16,
                  right: 16,
                  child: _EventFavoriteHeart(eventId: event.id),
                ),
              Positioned(
                top: 16,
                left: 16,
                child: EventTypeBadge(event: event),
              ),
              Positioned(
                left: 16,
                right: 56,
                bottom: 20,
                child: Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 840;
              final leftColumn = Column(
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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event.description ?? '',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if ((event.eventType ?? '').isNotEmpty)
                                  _detailChip(
                                    'Type',
                                    eventTypeDisplayLabel(event),
                                  ),
                                if ((event.eventLanguage ?? '').isNotEmpty)
                                  _detailChip('Langue', event.eventLanguage!),
                                if ((event.filmGenre ?? '').isNotEmpty)
                                  _detailChip('Genre film', event.filmGenre!),
                                if ((event.filmDirector ?? '').isNotEmpty)
                                  _detailChip(
                                    'Réalisateur',
                                    event.filmDirector!,
                                  ),
                                if ((event.festivalTheme ?? '').isNotEmpty)
                                  _detailChip(
                                    'Thématique',
                                    event.festivalTheme!,
                                  ),
                                if ((event.standupMainArtist ?? '').isNotEmpty)
                                  _detailChip(
                                    'Humoriste',
                                    event.standupMainArtist!,
                                  ),
                                if ((event.concertArtist ?? '').isNotEmpty)
                                  _detailChip('Artiste', event.concertArtist!),
                                if ((event.concertMusicGenre ?? '').isNotEmpty)
                                  _detailChip(
                                    'Genre musical',
                                    event.concertMusicGenre!,
                                  ),
                                if ((event.theatreAuthor ?? '').isNotEmpty)
                                  _detailChip('Auteur', event.theatreAuthor!),
                              ],
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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 20,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.location,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        event.address ?? '',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        event.city,
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 20,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  event.date,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 20,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatEventTimeLabel(event.time),
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.people_outline_rounded,
                                  size: 20,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  maxBookable <= 0
                                      ? 'Complet'
                                      : '$maxBookable place${maxBookable > 1 ? 's' : ''} disponible${maxBookable > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  ' sur ${event.placesTotal} au total',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              final bookingCard = SizedBox(
                width: narrow ? double.infinity : 320,
                child: Card(
                  color: AppTheme.cardDark,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          multiTarif ? 'Tarifs' : 'Prix par billet',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          multiTarif
                              ? '${referenceUnitPrice.toStringAsFixed(2)} MAD — ${maxUnitPrice.toStringAsFixed(2)} MAD'
                              : '${referenceUnitPrice.toStringAsFixed(2)} MAD',
                          style: TextStyle(
                            color: AppTheme.accentGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: multiTarif ? 20 : 24,
                          ),
                        ),
                        if (multiTarif) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Le total exact dépend des types choisis à l’étape suivante.',
                            style: TextStyle(
                              color: AppTheme.textSecondary.withValues(
                                alpha: 0.9,
                              ),
                              fontSize: 11,
                            ),
                          ),
                        ],
                        if (activeTypes.isNotEmpty &&
                            activeTypes.length <= 4) ...[
                          const SizedBox(height: 10),
                          ...activeTypes.map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      t.label,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${t.price.toStringAsFixed(2)} MAD',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${t.remaining} rest.)',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            IconButton.filled(
                              onPressed: _quantity < maxQty
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
                        Text(
                          maxQty <= 0
                              ? 'Aucune place disponible pour le moment.'
                              : 'Maximum : $maxQty billet(s) (stock & limite commande)',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (_reservationConfig != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _reservationConfig!.reservationMode == 'AVEC_SIEGES'
                                ? 'Mode: réservation avec sièges.'
                                : 'Mode: placement libre.',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        const Divider(color: AppTheme.textSecondary),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              multiTarif ? 'Estimation (min.)' : 'Sous-total',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              '${minEstimateTotal.toStringAsFixed(2)} MAD',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (multiTarif) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Estimation (max.)',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                              Text(
                                '${maxEstimateTotal.toStringAsFixed(2)} MAD',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                multiTarif ? 'Total (à confirmer)' : 'Total',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                multiTarif
                                    ? 'À partir de ${minEstimateTotal.toStringAsFixed(2)} MAD'
                                    : '${minEstimateTotal.toStringAsFixed(2)} MAD',
                                textAlign: TextAlign.end,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.accentGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: maxQty <= 0
                                ? null
                                : () {
                                    final auth = context.read<AuthState>();
                                    if (!auth.isLoggedIn) {
                                      context
                                          .read<PendingReservationState>()
                                          .setPendingEvent(
                                            eventId: event.id,
                                            eventTitle: event.title,
                                            eventLocation:
                                                '${event.location}, ${event.city}',
                                            eventDateTime:
                                                '${event.date} à ${event.time}',
                                            quantity: _quantity,
                                            pricePerTicket: referenceUnitPrice,
                                            availableOptions:
                                                event.availableOptions ?? [],
                                          );
                                      context.go(AppRouter.connexion);
                                      return;
                                    }
                                    ReservationState.instance
                                        .setEventReservation(
                                          eventId: event.id,
                                          eventTitle: event.title,
                                          eventLocation:
                                              '${event.location}, ${event.city}',
                                          eventDateTime:
                                              '${event.date} à ${event.time}',
                                          quantity: _quantity,
                                          pricePerTicket: referenceUnitPrice,
                                          availableOptions:
                                              event.availableOptions ?? [],
                                          reservationConfig: _reservationConfig,
                                        );
                                    context.push(
                                      AppRouter.reservationTypeBillet,
                                    );
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
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    leftColumn,
                    const SizedBox(height: 16),
                    bookingCard,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: leftColumn),
                  const SizedBox(width: 24),
                  bookingCard,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _detailChip(String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppTheme.surfaceDark,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.25)),
    ),
    child: Text(
      '$label: $value',
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
    ),
  );
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
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? AppTheme.primaryRed : Colors.white70,
        size: 28,
      ),
      style: IconButton.styleFrom(backgroundColor: Colors.black38),
    );
  }
}
