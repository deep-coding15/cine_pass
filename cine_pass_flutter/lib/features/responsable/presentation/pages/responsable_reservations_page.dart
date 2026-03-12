import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Réservations liées aux structures du responsable.
/// TODO: brancher sur getReservationsForMyStructures(session).
class ResponsableReservationsPage extends StatefulWidget {
  const ResponsableReservationsPage({super.key});

  @override
  State<ResponsableReservationsPage> createState() =>
      _ResponsableReservationsPageState();
}

class _ResponsableReservationsPageState extends State<ResponsableReservationsPage> {
  bool _loading = true;
  final List<_MockResa> _reservations = [];

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
      _reservations.addAll([
        _MockResa(
          id: '1',
          numero: 'RES-2026-001',
          eventTitle: 'Concert Jazz',
          clientEmail: 'client@email.com',
          total: 45.0,
          date: '10/03/2026',
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
          Text(
            'Réservations',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Réservations pour les événements de vos structures.',
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
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    title: Text(
                      r.numero,
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${r.eventTitle}\n${r.clientEmail} • ${r.total.toStringAsFixed(2)} € • ${r.date}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MockResa {
  final String id;
  final String numero;
  final String eventTitle;
  final String clientEmail;
  final double total;
  final String date;

  _MockResa({
    required this.id,
    required this.numero,
    required this.eventTitle,
    required this.clientEmail,
    required this.total,
    required this.date,
  });
}
