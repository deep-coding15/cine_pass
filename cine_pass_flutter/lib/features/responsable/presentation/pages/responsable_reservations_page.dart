import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

/// Réservations liées aux structures du responsable.
class ResponsableReservationsPage extends StatefulWidget {
  const ResponsableReservationsPage({super.key});

  @override
  State<ResponsableReservationsPage> createState() =>
      _ResponsableReservationsPageState();
}

class _ResponsableReservationsPageState extends State<ResponsableReservationsPage> {
  bool _loading = true;
  String _filterStatut = 'Toutes';
  List<ReservationResponse> _reservations = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await client.cinePass.getReservationsForMyStructures();
      if (!mounted) return;
      setState(() {
        _reservations = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reservations = [];
        _loading = false;
      });
    }
  }

  void _showDetail(ReservationResponse r) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Détail réservation',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      r.statut == 'confirmed' || r.statut == 'confirmée'
                          ? 'Confirmée'
                          : r.statut == 'pending' || r.statut == 'en_attente'
                              ? 'En attente'
                              : r.statut,
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailRow(label: 'N° réservation', value: r.numero, highlight: true),
              _DetailRow(label: 'Événement', value: r.eventTitle ?? '—'),
              _DetailRow(label: 'Date', value: r.createdAtStr),
              _DetailRow(label: 'Billets', value: '${r.nbBillets}'),
              _DetailRow(label: 'Total', value: '${r.totalAmount.toStringAsFixed(2)} €'),
              _DetailRow(label: 'Statut', value: r.statut),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Ouverture page de détail complète / billets — à brancher',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_rounded, size: 20),
                    label: const Text('Voir les billets'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Changer le statut (annuler / rembourser) — à brancher',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                    label: const Text('Gérer le statut'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentGreen,
                      side: const BorderSide(color: AppTheme.accentGreen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export PDF à venir')),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                    label: const Text('Exporter PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentGreen,
                      side: const BorderSide(color: AppTheme.accentGreen),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('Fermer'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          Text(
            'Réservations',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Réservations pour les événements de vos structures. Cliquez sur une ligne pour voir le détail.',
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
          else if (_reservations.isEmpty)
            Card(
              color: AppTheme.cardDark,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.confirmation_number_rounded,
                        size: 64,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune réservation pour le moment.',
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
              itemCount: _reservations.length,
              itemBuilder: (context, index) {
                final r = _reservations[index];
                return Card(
                  color: AppTheme.cardDark,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _showDetail(r),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.numero,
                                  style: const TextStyle(
                                    color: AppTheme.accentGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${r.eventTitle ?? '—'}\n${r.totalAmount.toStringAsFixed(2)} € • ${r.createdAtStr}',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showDetail(r),
                            icon: const Icon(Icons.visibility_rounded, size: 18),
                            label: const Text('Voir détails'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.accentGreen,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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
              style: TextStyle(
                color: highlight ? AppTheme.accentGreen : AppTheme.textPrimary,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

