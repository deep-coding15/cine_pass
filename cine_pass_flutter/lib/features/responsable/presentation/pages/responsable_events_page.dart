import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../widgets/responsable_add_event_dialog.dart';

/// Événements créés par le responsable pour ses structures.
class ResponsableEventsPage extends StatefulWidget {
  const ResponsableEventsPage({super.key});

  @override
  State<ResponsableEventsPage> createState() => _ResponsableEventsPageState();
}

class _ResponsableEventsPageState extends State<ResponsableEventsPage> {
  bool _loading = true;
  List<EventResponse> _events = [];

  /// Structures pour le dialogue « Créer un événement » (structure assignée au responsable).
  List<ResponsableStructureItem> _structuresForDialog = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final events = await client.cinePass.getMyEvents();
      final myStructure = await client.cinePass.getMyStructure();
      if (!mounted) return;
      setState(() {
        _events = events;
        _structuresForDialog = myStructure != null
            ? [
                ResponsableStructureItem(
                  id: myStructure.id.uuid,
                  name: myStructure.name,
                ),
              ]
            : [];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _events = [];
        _structuresForDialog = [];
        _loading = false;
      });
    }
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

  void _openSeriesDetail(_EventSeries s) {
    context.go('/responsable/events/${s.events.first.id}');
  }

  Future<void> _deleteSeries(_EventSeries s) async {
    final n = s.events.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Supprimer ?'),
        content: Text(
          n > 1
              ? 'Supprimer toute la série « ${s.title} » ($n séances) ?'
              : 'Supprimer « ${s.title} » ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    var deleted = 0;
    var blocked = 0;
    for (final ev in s.events) {
      try {
        final d = await client.cinePass.deleteEvent(ev.id);
        if (d) {
          deleted++;
        } else {
          blocked++;
        }
      } catch (_) {
        blocked++;
      }
    }
    if (!mounted) return;
    String msg;
    Color bg;
    if (deleted == n) {
      msg = 'Événement(s) supprimé(s).';
      bg = AppTheme.accentGreen;
    } else if (deleted > 0) {
      msg =
          'Suppression partielle ($deleted/$n). Les autres séances ont peut‑être des réservations actives.';
      bg = AppTheme.textSecondary;
    } else if (blocked > 0) {
      msg =
          'Suppression impossible : réservations actives sur une ou plusieurs séances, ou droits insuffisants.';
      bg = AppTheme.primaryRed;
    } else {
      msg = 'Suppression impossible.';
      bg = AppTheme.primaryRed;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
    await _load();
  }

  Future<void> _openEditSeriesDialog(_EventSeries s) async {
    if (_structuresForDialog.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucune structure assignée : impossible d’ouvrir le formulaire.',
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => ResponsableAddEventDialog(
        structures: _structuresForDialog,
        editEventId: s.events.first.id,
        onSaved: _load,
      ),
    );
    if (mounted) await _load();
  }

  List<_EventSeries> _buildSeries(List<EventResponse> events) {
    final map = <String, List<EventResponse>>{};
    for (final e in events) {
      final key =
          '${e.title.trim().toLowerCase()}||${e.category.trim().toLowerCase()}';
      map.putIfAbsent(key, () => []).add(e);
    }
    final series =
        map.entries.map((entry) {
          final items = entry.value..sort((a, b) => a.date.compareTo(b.date));
          return _EventSeries(
            title: items.first.title,
            category: items.first.category,
            events: items,
          );
        }).toList()..sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    return series;
  }

  @override
  Widget build(BuildContext context) {
    final series = _buildSeries(_events);
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
              itemCount: series.length,
              itemBuilder: (context, index) {
                final s = series[index];
                final allArchived =
                    s.events.every((x) => x.archived == true);
                final someArchived =
                    s.events.any((x) => x.archived == true) && !allArchived;
                final archPrefix = allArchived
                    ? 'Archivé — '
                    : (someArchived ? 'Partiellement archivé — ' : '');
                return Card(
                  color: AppTheme.cardDark,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => _openSeriesDetail(s),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.title,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$archPrefix${s.category} • ${s.events.length} séance(s)\n'
                                    '${s.events.first.date} ${s.events.first.time} • ${s.events.first.location}',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Modifier',
                          icon: const Icon(Icons.edit_rounded),
                          onPressed: () => _openEditSeriesDialog(s),
                        ),
                        IconButton(
                          tooltip: 'Supprimer',
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: AppTheme.primaryRed,
                          onPressed: () => _deleteSeries(s),
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

class _EventSeries {
  const _EventSeries({
    required this.title,
    required this.category,
    required this.events,
  });

  final String title;
  final String category;
  final List<EventResponse> events;
}
