import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

/// Liste admin : réservations réelles (`getReservations`).
class AdminReservationsPage extends StatefulWidget {
  const AdminReservationsPage({super.key});

  @override
  State<AdminReservationsPage> createState() => _AdminReservationsPageState();
}

class _AdminReservationsPageState extends State<AdminReservationsPage> {
  List<ReservationResponse> _rows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await client.cinePass.getReservations();
      if (!mounted) return;
      setState(() {
        _rows = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _rows = [];
        _loading = false;
        _error = e.toString();
      });
    }
  }

  static String _statutLabel(String s) {
    switch (s.toLowerCase()) {
      case 'confirmed':
      case 'paid':
      case 'confirmée':
        return 'Confirmée';
      case 'cancelled':
      case 'canceled':
        return 'Annulée';
      case 'pending':
      default:
        return 'En attente';
    }
  }

  static bool _isConfirmed(String s) {
    final x = s.toLowerCase();
    return x == 'confirmed' || x == 'paid';
  }

  static bool _isCancelled(String s) {
    final x = s.toLowerCase();
    return x == 'cancelled' || x == 'canceled';
  }

  String _formatCreated(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) {
      return iso;
    }
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryRed),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Erreur: $_error',
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Réservations',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Toutes les réservations (films et événements), données base',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Actualiser',
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.cardDark,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppTheme.surfaceDark),
                columns: const [
                  DataColumn(
                    label: Text(
                      'N°',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Utilisateur',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Titre',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Lieu',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Date séance',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Billets',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Montant',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Statut',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Créée le',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                rows: _rows.map((r) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          r.numero,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          r.userEmail ?? '—',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          r.eventTitle ?? '—',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          r.locationLabel ?? '—',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          r.sessionAtStr ?? '—',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${r.nbBillets}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${r.totalAmount.toStringAsFixed(2)} MAD',
                          style: const TextStyle(
                            color: AppTheme.accentGreen,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _isConfirmed(r.statut)
                                ? AppTheme.accentGreen.withValues(alpha: 0.2)
                                : _isCancelled(r.statut)
                                ? AppTheme.primaryRed.withValues(alpha: 0.15)
                                : AppTheme.textSecondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _statutLabel(r.statut),
                            style: TextStyle(
                              color: _isConfirmed(r.statut)
                                  ? AppTheme.accentGreen
                                  : _isCancelled(r.statut)
                                  ? AppTheme.primaryRed
                                  : AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          _formatCreated(r.createdAtStr),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          if (_rows.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  'Aucune réservation en base.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
