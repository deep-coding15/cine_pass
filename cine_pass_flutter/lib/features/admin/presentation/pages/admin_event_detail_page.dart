import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

/// Page admin : détail d'un événement avec séances et boutons d'action (modifier, archiver, supprimer).
class AdminEventDetailPage extends StatefulWidget {
  const AdminEventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  State<AdminEventDetailPage> createState() => _AdminEventDetailPageState();
}

class _AdminEventDetailPageState extends State<AdminEventDetailPage> {
  EventResponse? _event;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final event = await client.cinePass.getEventById(widget.eventId);
      if (!mounted) return;
      setState(() {
        _event = event;
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
        child: CircularProgressIndicator(color: AppTheme.primaryRed),
      );
    }
    if (_event == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.textSecondary,
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
              onPressed: () => context.go('/admin/events'),
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
                onPressed: () => context.go('/admin/events'),
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
                        width: 80,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Color(e.posterColor ?? 0xFF4E1B3D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.event_rounded,
                          color: Colors.white24,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.category,
                              style: TextStyle(
                                color: AppTheme.primaryRed,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Structure / Lieu : ${e.location}',
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
                            const SizedBox(height: 4),
                            Text(
                              '${e.city} • ${e.date} ${e.time}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${e.price.toStringAsFixed(2)} € • ${e.placesTotal - e.placesLeft}/${e.placesTotal} places',
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
                  Text(
                    'Séances liées à cet événement',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Détail de chaque séance (date, heure, lieu, places, prix).',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingTextStyle: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        dataTextStyle: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                        ),
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Heure')),
                          DataColumn(label: Text('Lieu / Salle')),
                          DataColumn(label: Text('Places totales')),
                          DataColumn(label: Text('Places restantes')),
                          DataColumn(label: Text('Places réservées')),
                          DataColumn(label: Text('Prix (€)')),
                        ],
                        rows: [
                          DataRow(
                            cells: [
                              DataCell(Text(e.date)),
                              DataCell(Text(e.time)),
                              DataCell(Text(e.location)),
                              DataCell(Text('${e.placesTotal}')),
                              DataCell(Text('${e.placesLeft}')),
                              DataCell(Text('${e.placesTotal - e.placesLeft}')),
                              DataCell(Text(e.price.toStringAsFixed(2))),
                            ],
                          ),
                          // Quand l'API getSeancesForEvent existera, charger les séances supplémentaires ici
                        ],
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
                  // TODO: ouvrir dialogue modification
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                ),
                icon: const Icon(Icons.edit_rounded, size: 20),
                label: const Text('Modifier'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: archiver l'événement
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonction archiver à brancher'),
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
                      title: const Text('Supprimer l\'événement ?'),
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
                  if (confirm == true && context.mounted) {
                    try {
                      final ok = await client.cinePass.deleteEvent(e.id);
                      if (!context.mounted) return;
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Événement supprimé'),
                            backgroundColor: AppTheme.accentGreen,
                          ),
                        );
                        context.go('/admin/events');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Impossible de supprimer'),
                            backgroundColor: AppTheme.primaryRed,
                          ),
                        );
                      }
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erreur lors de la suppression'),
                          backgroundColor: AppTheme.primaryRed,
                        ),
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
