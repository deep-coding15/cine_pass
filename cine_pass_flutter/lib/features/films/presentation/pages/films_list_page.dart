import 'package:flutter/material.dart';

import '../../../events/presentation/pages/events_list_page.dart';

/// La rubrique films réutilise désormais la liste unifiée des événements.
class FilmsListPage extends StatelessWidget {
  const FilmsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EventsListPage();
  }
}
