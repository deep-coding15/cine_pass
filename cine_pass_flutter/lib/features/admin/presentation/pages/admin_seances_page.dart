import 'package:flutter/material.dart';

import 'admin_events_page.dart';

/// Vue legacy conservée pour compatibilité.
/// Les anciennes séances sont désormais gérées comme des événements.
class AdminSeancesPage extends StatelessWidget {
  const AdminSeancesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminEventsPage();
  }
}
