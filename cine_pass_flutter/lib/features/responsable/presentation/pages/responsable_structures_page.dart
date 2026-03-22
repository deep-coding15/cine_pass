import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

/// Page "Ma structure" : la structure que le responsable représente (celle de sa demande approuvée).
/// Il ne peut pas en ajouter une autre — affichage type "about us" avec les infos fournies dans la demande.
class ResponsableStructuresPage extends StatefulWidget {
  const ResponsableStructuresPage({super.key});

  @override
  State<ResponsableStructuresPage> createState() =>
      _ResponsableStructuresPageState();
}

class _ResponsableStructuresPageState extends State<ResponsableStructuresPage> {
  bool _loading = true;
  Structure? _structure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = await client.cinePass.getMyStructure();
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

  Future<void> _editStructure() async {
    final current = _structure;
    if (current == null) return;

    final nameController = TextEditingController(text: current.name);
    final cityController = TextEditingController(text: current.city);
    final addressController = TextEditingController(
      text: current.address ?? '',
    );
    final websiteController = TextEditingController(
      text: current.website ?? '',
    );
    final phoneController = TextEditingController(text: current.phone ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Modifier ma structure'),
        content: SizedBox(
          width: 520,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom *'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Le nom est requis'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'Ville *'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'La ville est requise'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: websiteController,
                    decoration: const InputDecoration(labelText: 'Site web'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Téléphone'),
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
              final updated = await client.cinePass.updateMyStructure(
                structureId: current.id.uuid,
                name: nameController.text.trim(),
                city: cityController.text.trim(),
                address: addressController.text.trim().isEmpty
                    ? null
                    : addressController.text.trim(),
                website: websiteController.text.trim().isEmpty
                    ? null
                    : websiteController.text.trim(),
                phone: phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
              );
              if (!mounted) return;
              Navigator.pop(ctx, updated != null);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Structure mise à jour.'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ma structure',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'La structure que vous représentez (celle de votre demande approuvée). Vous ne pouvez pas en ajouter une autre.',
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
          else if (_structure == null)
            Card(
              color: AppTheme.cardDark,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.store_rounded,
                        size: 64,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune structure assignée.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Votre structure sera créée après approbation de votre demande par un admin.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            _MaStructureCard(
              structure: _structure!,
              labelType: _labelType,
              onEdit: _editStructure,
            ),
        ],
      ),
    );
  }
}

class _MaStructureCard extends StatelessWidget {
  const _MaStructureCard({
    required this.structure,
    required this.labelType,
    required this.onEdit,
  });

  final Structure structure;
  final String Function(String) labelType;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    size: 32,
                    color: AppTheme.accentGreen,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        structure.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${labelType(structure.type)} • ${structure.city}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Modifier'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'À propos de ma structure',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune description renseignée.',
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppTheme.textSecondary, height: 1),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Adresse',
              value: structure.address ?? '—',
            ),
            if (structure.website != null && structure.website!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.language_rounded,
                label: 'Site web',
                value: structure.website!,
              ),
            ],
            if (structure.phone != null && structure.phone!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Téléphone',
                value: structure.phone!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
