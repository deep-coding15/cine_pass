import 'package:flutter/material.dart';

import 'admin_events_page.dart';

/// Vue legacy conservée pour compatibilité.
/// Le back-office est désormais centré sur les événements.
class AdminFilmsPage extends StatelessWidget {
  const AdminFilmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminEventsPage();
  }
}
