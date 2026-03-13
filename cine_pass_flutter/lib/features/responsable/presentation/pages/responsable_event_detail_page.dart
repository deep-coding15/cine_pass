import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

/// Modèle mock pour un événement responsable (détail + séances).
class ResponsableEventDetailData {
  const ResponsableEventDetailData({
    required this.id,
    required this.title,
    required this.category,
    required this.structureName,
    required this.date,
    required this.placesTotal,
    required this.placesLeft,
    this.description,
    this.address,
    required this.seances,
  });

  final String id;
  final String title;
  final String category;
  final String structureName;
  final String date;
  final int placesTotal;
  final int placesLeft;
  final String? description;
  final String? address;
  final List<ResponsableSeanceItem> seances;
}

class ResponsableSeanceItem {
  const ResponsableSeanceItem({
    required this.id,
    required this.dateStr,
    required this.timeStr,
    required this.lieu,
  });

  final String id;
  final String dateStr;
  final String timeStr;
  final String lieu;
}

/// Page responsable : détail d'un événement avec toutes les séances et actions (ajouter, modifier, archiver, supprimer).
class ResponsableEventDetailPage extends StatefulWidget {
  const ResponsableEventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  State<ResponsableEventDetailPage> createState() =>
      _ResponsableEventDetailPageState();
}

class _ResponsableEventDetailPageState
    extends State<ResponsableEventDetailPage> {
  bool _loading = true;
  ResponsableEventDetailData? _event;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final ev = await client.cinePass.getEventById(widget.eventId);
      if (!mounted) return;
      if (ev == null) {
        setState(() {
          _event = null;
          _loading = false;
        });
        return;
      }
      final structureName = await client.cinePass.getMyStructure().then(
        (s) => s?.name ?? '',
      );
      if (!mounted) return;
      setState(() {
        _event = ResponsableEventDetailData(
          id: ev.id,
          title: ev.title,
          category: ev.category,
          structureName: structureName,
          date: ev.date,
          placesTotal: ev.placesTotal,
          placesLeft: ev.placesLeft,
          description: ev.description,
          address: ev.address ?? ev.location,
          seances: [
            ResponsableSeanceItem(
              id: ev.id,
              dateStr: ev.date,
              timeStr: ev.time,
              lieu: ev.location,
            ),
          ],
        );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _event = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentGreen),
      );
    }
    if (_event == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'Événement introuvable',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.go('/responsable/events'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour à la liste'),
            ),
          ],
        ),
      );
    }
    final e = _event!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/responsable/events'),
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Retour',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  e.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.event_rounded,
                          color: AppTheme.accentGreen,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGreen.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                e.category,
                                style: const TextStyle(
                                  color: AppTheme.accentGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Structure / Lieu : ${e.structureName}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                            if (e.address != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                e.address!,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              '${e.date} • ${e.placesTotal - e.placesLeft}/${e.placesTotal} places réservées',
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
                  if (e.description != null && e.description!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(color: AppTheme.textSecondary, height: 1),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.description!,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.textSecondary, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Séances',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Ajout de séance à brancher sur l\'API',
                              ),
                              backgroundColor: AppTheme.accentGreen,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Ajouter une séance'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...e.seances.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              color: AppTheme.accentGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${s.dateStr} ${s.timeStr}',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    s.lieu,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: AppTheme.textSecondary,
                              ),
                              tooltip: 'Modifier la séance',
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: AppTheme.primaryRed,
                              ),
                              tooltip: 'Supprimer la séance',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Modification à brancher sur l\'API'),
                      backgroundColor: AppTheme.accentGreen,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                ),
                icon: const Icon(Icons.edit_rounded, size: 20),
                label: const Text('Modifier l\'événement'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Archiver à brancher sur l\'API'),
                      backgroundColor: AppTheme.textSecondary,
                    ),
                  );
                },
                icon: const Icon(Icons.archive_rounded, size: 20),
                label: const Text('Archiver'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.cardDark,
                      title: const Text('Supprimer cet événement ?'),
                      content: const Text(
                        'Cette action est irréversible.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Annuler'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Supprimer'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    try {
                      final ok = await client.cinePass.deleteEvent(e.id);
                      if (!mounted) return;
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Événement supprimé.'),
                            backgroundColor: AppTheme.accentGreen,
                          ),
                        );
                        context.go('/responsable/events');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Échec de la suppression.'),
                          ),
                        );
                      }
                    } catch (_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erreur réseau.')),
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryRed,
                  side: const BorderSide(color: AppTheme.primaryRed),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: const Text('Supprimer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
