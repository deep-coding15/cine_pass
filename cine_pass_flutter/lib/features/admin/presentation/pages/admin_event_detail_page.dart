import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../../../events/presentation/widgets/event_type_badge.dart';

/// Page admin : détail d'un événement avec séances et boutons d'action (modifier, supprimer).
class AdminEventDetailPage extends StatefulWidget {
  const AdminEventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  State<AdminEventDetailPage> createState() => _AdminEventDetailPageState();
}

class _AdminEventDetailPageState extends State<AdminEventDetailPage> {
  EventResponse? _event;
  bool _loading = true;

  Future<void> _editEvent(EventResponse e) async {
    final titleController = TextEditingController(text: e.title);
    final categoryController = TextEditingController(text: e.category);
    final cityController = TextEditingController(text: e.city);
    final venueController = TextEditingController(text: e.location);
    final addressController = TextEditingController(text: e.address ?? '');
    final descController = TextEditingController(text: e.description ?? '');
    final priceController = TextEditingController(
      text: e.price.toStringAsFixed(2),
    );
    final placesController = TextEditingController(text: '${e.placesTotal}');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Modifier événement'),
        content: SizedBox(
          width: 560,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Titre *'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Catégorie'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: venueController,
                    decoration: const InputDecoration(labelText: 'Lieu *'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'Ville *'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requis' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Prix (MAD)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: placesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Places',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() != true) return;
              final updated = await client.cinePass.updateEvent(
                id: e.id,
                titre: titleController.text.trim(),
                categorie: categoryController.text.trim(),
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
                lieu: venueController.text.trim(),
                ville: cityController.text.trim(),
                adresse: addressController.text.trim().isEmpty
                    ? null
                    : addressController.text.trim(),
                prixBase: double.tryParse(
                  priceController.text.trim().replaceAll(',', '.'),
                ),
                placesTotal: int.tryParse(placesController.text.trim()),
              );
              if (!mounted) return;
              Navigator.pop(ctx, updated != null);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (saved == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Événement mis à jour.'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
      await _load();
    }
  }

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
                            EventTypeBadge(event: e),
                            if (e.category.trim().isNotEmpty &&
                                e.category != eventTypeDisplayLabel(e)) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Catégorie affichée : ${e.category}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
                              '${e.price.toStringAsFixed(2)} MAD • ${e.placesTotal - e.placesLeft}/${e.placesTotal} places',
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
                          DataColumn(label: Text('Prix (MAD)')),
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
                onPressed: () => _editEvent(e),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                ),
                icon: const Icon(Icons.edit_rounded, size: 20),
                label: const Text('Modifier'),
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
