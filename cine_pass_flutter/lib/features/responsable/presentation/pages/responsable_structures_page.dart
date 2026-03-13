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
            _MaStructureCard(structure: _structure!, labelType: _labelType),
        ],
      ),
    );
  }
}

class _MaStructureCard extends StatelessWidget {
  const _MaStructureCard({
    required this.structure,
    required this.labelType,
  });

  final Structure structure;
  final String Function(String) labelType;

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

