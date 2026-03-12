import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

/// Liste des structures du responsable (cinémas, salles, organisateur).
/// TODO: brancher sur getMyStructures(session).
class ResponsableStructuresPage extends StatefulWidget {
  const ResponsableStructuresPage({super.key});

  @override
  State<ResponsableStructuresPage> createState() =>
      _ResponsableStructuresPageState();
}

class _ResponsableStructuresPageState extends State<ResponsableStructuresPage> {
  bool _loading = true;
  final List<_MockStructure> _structures = [];

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
      _structures.addAll([
        _MockStructure(
          id: '1',
          type: 'CINEMA',
          name: 'Cinéma Le Central',
          city: 'Lyon',
          address: '12 rue de la République',
        ),
      ]);
      _loading = false;
    });
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
                'Mes structures',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
              FilledButton.icon(
                onPressed: () {
                  // TODO: dialog ou page Créer une structure
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Création de structure (à brancher).'),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Ajouter une structure'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Les structures que vous gérez (cinémas, salles, organisateur).',
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
          else if (_structures.isEmpty)
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
                        'Aucune structure pour le moment.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Votre ou vos structures seront créées après approbation de votre demande.',
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _structures.length,
              itemBuilder: (context, index) {
                final s = _structures[index];
                return Card(
                  color: AppTheme.cardDark,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.accentGreen.withValues(alpha: 0.3),
                      child: Icon(
                        Icons.store_rounded,
                        color: AppTheme.accentGreen,
                      ),
                    ),
                    title: Text(
                      s.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${_labelType(s.type)} • ${s.city}\n${s.address ?? ''}',
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
}

class _MockStructure {
  final String id;
  final String type;
  final String name;
  final String city;
  final String? address;

  _MockStructure({
    required this.id,
    required this.type,
    required this.name,
    required this.city,
    this.address,
  });
}
