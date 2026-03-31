import 'package:flutter/material.dart';

import 'unified_events_section.dart';

/// Section legacy redirigée vers la section unifiée des événements.
class MoviesSection extends StatelessWidget {
  const MoviesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedEventsSection();
  }
}
