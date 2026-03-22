import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Libellé affiché pour le type d’événement (API `eventType` + `customTypeLabel`).
String eventTypeDisplayLabel(EventResponse e) {
  final t = (e.eventType ?? '').trim().toUpperCase();
  if (t.isEmpty) {
    return e.category;
  }
  if (t == 'AUTRE') {
    final c = (e.customTypeLabel ?? '').trim();
    if (c.isNotEmpty) {
      return c;
    }
  }
  const map = <String, String>{
    'FILM': 'Film',
    'FESTIVAL': 'Festival',
    'STANDUP': 'Stand-up',
    'CONCERT': 'Concert',
    'THEATRE': 'Théâtre',
    'AUTRE': 'Autre',
  };
  return map[t] ?? e.category;
}

/// Couleur d’accent pour le badge selon `eventType`.
Color eventTypeBadgeColor(String? eventType) {
  switch ((eventType ?? '').trim().toUpperCase()) {
    case 'FILM':
      return AppTheme.primaryRed;
    case 'FESTIVAL':
      return const Color(0xFF7E57C2);
    case 'STANDUP':
      return const Color(0xFFFF9800);
    case 'CONCERT':
      return const Color(0xFFAB47BC);
    case 'THEATRE':
      return const Color(0xFF42A5F5);
    case 'AUTRE':
      return const Color(0xFF5C5C5C);
    default:
      return AppTheme.accentGreen;
  }
}

/// Badge homogène : liste, détail, admin.
class EventTypeBadge extends StatelessWidget {
  const EventTypeBadge({
    super.key,
    required this.event,
    this.compact = false,
    this.maxWidth,
  });

  final EventResponse event;
  final bool compact;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final label = eventTypeDisplayLabel(event);
    final bg = eventTypeBadgeColor(event.eventType);
    final padH = compact ? 6.0 : 10.0;
    final padV = compact ? 2.0 : 5.0;
    final fontSize = compact ? 10.0 : 12.0;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(compact ? 4 : 12),
          boxShadow: compact
              ? null
              : [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
