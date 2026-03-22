import 'dart:convert';

import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import 'event_type_badge.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final EventResponse event;

  static Widget _posterImage(String? posterUrl, int posterColor) {
    final c = Color(posterColor);
    final placeholder = Container(
      color: c,
      child: Center(
        child: Icon(
          Icons.event_rounded,
          size: 28,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
    if (posterUrl == null || posterUrl.isEmpty) return placeholder;
    if (posterUrl.startsWith('data:')) {
      try {
        final i = posterUrl.indexOf(',');
        if (i > 0) {
          final bytes = base64Decode(posterUrl.substring(i + 1));
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          );
        }
      } catch (_) {
        return placeholder;
      }
    }
    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }

  /// Libellé tarifaire pour la liste (multi-tarifs ou prix unique).
  String get _priceLabel {
    final from = event.priceFrom;
    final to = event.priceTo;
    if (from != null) {
      if (to != null && (to - from).abs() > 0.009) {
        return '${from.toStringAsFixed(2)} – ${to.toStringAsFixed(2)} MAD';
      }
      return 'À partir de ${from.toStringAsFixed(2)} MAD';
    }
    return '${event.price.toStringAsFixed(2)} MAD';
  }

  @override
  Widget build(BuildContext context) {
    final posterColor = event.posterColor ?? 0xFF4E1B3D;
    final posterUrl = event.posterUrl;
    final card = Card(
      color: AppTheme.cardDark,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => context.push(AppRouter.eventDetailPath(event.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 2 / 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: _posterImage(posterUrl, posterColor),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: EventTypeBadge(event: event, compact: true),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${event.location} - ${event.city}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.date,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _priceLabel,
                    style: const TextStyle(
                      color: AppTheme.accentGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () =>
                          context.push(AppRouter.eventDetailPath(event.id)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Réserver',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event.placesLeft} places',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryRed,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRed.withValues(alpha: 0.45),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: card,
      ),
    );
  }
}
