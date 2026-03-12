import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Réclamations des clients liées aux événements / structures du responsable.
/// Liste, détail, statut (ouverte, en cours, résolue), réponses.
/// TODO: brancher sur getReclamationsForMyStructures(session), repondreReclamation.
class ResponsableReclamationsPage extends StatefulWidget {
  const ResponsableReclamationsPage({super.key});

  @override
  State<ResponsableReclamationsPage> createState() =>
      _ResponsableReclamationsPageState();
}

class _ResponsableReclamationsPageState extends State<ResponsableReclamationsPage> {
  bool _loading = true;
  String _filterStatut = 'Toutes';
  final List<_MockRecla> _reclamations = [];

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
      _reclamations.addAll([
        _MockRecla(
          id: '1',
          sujet: 'Place non disponible',
          clientEmail: 'client@email.com',
          eventTitle: 'Concert Jazz',
          date: '10/03/2026',
          statut: 'ouverte',
          message: 'La place réservée était occupée à mon arrivée.',
        ),
        _MockRecla(
          id: '2',
          sujet: 'Retard à l\'entrée',
          clientEmail: 'autre@email.com',
          eventTitle: 'Théâtre',
          date: '09/03/2026',
          statut: 'en_cours',
          message: 'File d\'attente trop longue, j\'ai manqué le début.',
        ),
      ]);
      _loading = false;
    });
  }

  void _showDetail(_MockRecla r) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Détail réclamation',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const Spacer(),
                    _StatutChip(statut: r.statut),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailRow(label: 'Sujet', value: r.sujet),
                        _DetailRow(label: 'Événement', value: r.eventTitle),
                        _DetailRow(label: 'Client', value: r.clientEmail),
                        _DetailRow(label: 'Date', value: r.date),
                        const SizedBox(height: 12),
                        Text(
                          'Message',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            r.message,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (r.statut != 'resolue') ...[
                          Text(
                            'Répondre',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Votre réponse au client...',
                              hintStyle: TextStyle(color: AppTheme.textSecondary),
                              filled: true,
                              fillColor: AppTheme.surfaceDark,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              FilledButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.send_rounded, size: 18),
                                label: const Text('Envoyer la réponse'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.accentGreen,
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Marquer comme résolue — à brancher')),
                                  );
                                },
                                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                label: const Text('Marquer résolue'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.accentGreen,
                                  side: const BorderSide(color: AppTheme.accentGreen),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_MockRecla> get _filtered {
    if (_filterStatut == 'Toutes') return _reclamations;
    return _reclamations.where((r) => r.statut == _filterStatut).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Réclamations',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Réclamations clients liées à vos événements et structures.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Statut :',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Toutes'),
                selected: _filterStatut == 'Toutes',
                onSelected: (_) => setState(() => _filterStatut = 'Toutes'),
                selectedColor: AppTheme.accentGreen.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: _filterStatut == 'Toutes'
                      ? AppTheme.accentGreen
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Ouvertes'),
                selected: _filterStatut == 'ouverte',
                onSelected: (_) => setState(() => _filterStatut = 'ouverte'),
                selectedColor: AppTheme.accentGreen.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: _filterStatut == 'ouverte'
                      ? AppTheme.accentGreen
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('En cours'),
                selected: _filterStatut == 'en_cours',
                onSelected: (_) => setState(() => _filterStatut = 'en_cours'),
                selectedColor: AppTheme.accentGreen.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: _filterStatut == 'en_cours'
                      ? AppTheme.accentGreen
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Résolues'),
                selected: _filterStatut == 'resolue',
                onSelected: (_) => setState(() => _filterStatut = 'resolue'),
                selectedColor: AppTheme.accentGreen.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: _filterStatut == 'resolue'
                      ? AppTheme.accentGreen
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.accentGreen),
            )
          else if (_filtered.isEmpty)
            Card(
              color: AppTheme.cardDark,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.report_problem_outlined,
                        size: 64,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune réclamation.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
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
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final r = _filtered[index];
                return Card(
                  color: AppTheme.cardDark,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryRed.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.report_problem_outlined,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    title: Text(
                      r.sujet,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${r.eventTitle} • ${r.clientEmail} • ${r.date}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatutChip(statut: r.statut),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.visibility_rounded),
                          onPressed: () => _showDetail(r),
                          color: AppTheme.accentGreen,
                        ),
                      ],
                    ),
                    onTap: () => _showDetail(r),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StatutChip extends StatelessWidget {
  const _StatutChip({required this.statut});

  final String statut;

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    switch (statut) {
      case 'ouverte':
        label = 'Ouverte';
        color = AppTheme.primaryRed;
        break;
      case 'en_cours':
        label = 'En cours';
        color = Colors.orange;
        break;
      case 'resolue':
        label = 'Résolue';
        color = AppTheme.accentGreen;
        break;
      default:
        label = statut;
        color = AppTheme.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockRecla {
  final String id;
  final String sujet;
  final String clientEmail;
  final String eventTitle;
  final String date;
  final String statut;
  final String message;

  _MockRecla({
    required this.id,
    required this.sujet,
    required this.clientEmail,
    required this.eventTitle,
    required this.date,
    required this.statut,
    required this.message,
  });
}
