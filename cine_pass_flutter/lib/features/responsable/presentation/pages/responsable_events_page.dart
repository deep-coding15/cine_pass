import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/responsable_add_event_dialog.dart';

/// Événements créés par le responsable pour ses structures.
/// TODO: brancher sur getMyEvents(session), createEvent, updateEvent, deleteEvent.
class ResponsableEventsPage extends StatefulWidget {
  const ResponsableEventsPage({super.key});

  @override
  State<ResponsableEventsPage> createState() => _ResponsableEventsPageState();
}

class _ResponsableEventsPageState extends State<ResponsableEventsPage> {
  bool _loading = true;
  final List<_MockEvent> _events = [];
  /// Structures pour le dropdown "Créer un événement" (même source que Mes structures, mock pour l’instant).
  final List<ResponsableStructureItem> _structuresForDialog = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _events.clear();
      _events.addAll([
        _MockEvent(
          id: '1',
          title: 'Concert Jazz',
          category: 'Concert',
          structureName: 'Cinéma Le Central',
          date: '15/04/2026',
          placesTotal: 200,
        ),
      ]);
      _structuresForDialog.clear();
      _structuresForDialog.add(const ResponsableStructureItem(id: '1', name: 'Cinéma Le Central'));
      _loading = false;
    });
  }

  void _openCreateEventDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => ResponsableAddEventDialog(
        structures: _structuresForDialog,
        onSaved: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mes événements',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
              FilledButton.icon(
                onPressed: _openCreateEventDialog,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Créer un événement'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Les événements que vous avez publiés pour vos structures.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.accentGreen),
            )
          else if (_events.isEmpty)
            Card(
              color: AppTheme.cardDark,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 64,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun événement.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _openCreateEventDialog,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Créer un événement'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final e = _events[index];
                return Card(
                  color: AppTheme.cardDark,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.event_rounded,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    title: Text(
                      e.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${e.category} • ${e.structureName}\n${e.date} • ${e.placesTotal} places',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MockEvent {
  final String id;
  final String title;
  final String category;
  final String structureName;
  final String date;
  final int placesTotal;

  _MockEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.structureName,
    required this.date,
    required this.placesTotal,
  });
}
