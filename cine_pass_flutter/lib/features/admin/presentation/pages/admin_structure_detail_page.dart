import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

/// Page admin : détail d'une structure avec boutons d'action (supprimer, bannir).
class AdminStructureDetailPage extends StatefulWidget {
  const AdminStructureDetailPage({super.key, required this.structureId});

  final String structureId;

  @override
  State<AdminStructureDetailPage> createState() =>
      _AdminStructureDetailPageState();
}

class _AdminStructureDetailPageState extends State<AdminStructureDetailPage> {
  Structure? _structure;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = await client.cinePass.getStructureById(widget.structureId);
      if (!mounted) return;
      setState(() {
        _structure = s;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _structure = null;
        _loading = false;
      });
    }
  }

  String _labelType(String type) {
    switch (type) {
      case 'CINEMA':
        return 'Cinéma';
      case 'VENUE':
        return 'Salle de spectacle';
      case 'ORGANIZER':
        return 'Organisateur';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryRed),
      );
    }
    if (_structure == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Structure introuvable',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.go('/admin/structures'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour à la liste'),
            ),
          ],
        ),
      );
    }
    final s = _structure!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/admin/structures'),
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Retour',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.name,
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
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.store_rounded,
                          color: AppTheme.primaryRed,
                          size: 32,
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
                                color: AppTheme.primaryRed.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _labelType(s.type),
                                style: const TextStyle(
                                  color: AppTheme.primaryRed,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.city,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                            if (s.address != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                s.address!,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                            if (s.phone != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                s.phone!,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                            if (s.website != null && s.website!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(color: AppTheme.textSecondary, height: 1),
                              const SizedBox(height: 12),
                              Text(
                                'Site web',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.website!,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.cardDark,
                      title: const Text('Bannir cette structure ?'),
                      content: const Text(
                        'La structure et son responsable seront bannis. Les événements associés pourront être archivés.',
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
                          child: const Text('Bannir'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonction bannir à brancher sur l\'API'),
                        backgroundColor: AppTheme.textSecondary,
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryRed,
                  side: const BorderSide(color: AppTheme.primaryRed),
                ),
                icon: const Icon(Icons.block_rounded, size: 20),
                label: const Text('Bannir'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.cardDark,
                      title: const Text('Supprimer cette structure ?'),
                      content: const Text(
                        'Cette action est irréversible. Les événements liés devront être gérés.',
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonction supprimer à brancher sur l\'API'),
                        backgroundColor: AppTheme.primaryRed,
                      ),
                    );
                    context.go('/admin/structures');
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
