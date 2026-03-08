import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AdminStatsReportPage extends StatefulWidget {
  const AdminStatsReportPage({super.key});

  @override
  State<AdminStatsReportPage> createState() => _AdminStatsReportPageState();
}

class _AdminStatsReportPageState extends State<AdminStatsReportPage> {
  DateTime? _dateStart;
  DateTime? _dateEnd;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rapport de statistiques',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Générez un rapport selon la période choisie',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Période',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _dateStart ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (d != null) setState(() => _dateStart = d);
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            _dateStart != null
                                ? '${_dateStart!.day}/${_dateStart!.month}/${_dateStart!.year}'
                                : 'Date de début',
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate:
                                  _dateEnd ?? _dateStart ?? DateTime.now(),
                              firstDate: _dateStart ?? DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (d != null) setState(() => _dateEnd = d);
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            _dateEnd != null
                                ? '${_dateEnd!.day}/${_dateEnd!.month}/${_dateEnd!.year}'
                                : 'Date de fin',
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      if (_dateStart == null || _dateEnd == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Choisissez une date de début et de fin',
                            ),
                            backgroundColor: AppTheme.primaryRed,
                          ),
                        );
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Rapport généré du ${_dateStart!.day}/${_dateStart!.month}/${_dateStart!.year} au ${_dateEnd!.day}/${_dateEnd!.month}/${_dateEnd!.year}',
                          ),
                          backgroundColor: AppTheme.accentGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.assessment),
                    label: const Text('Générer le rapport'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_dateStart != null && _dateEnd != null) ...[
            const SizedBox(height: 32),
            Text(
              'Résumé (démo)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Réservations',
                    value: '42',
                    icon: Icons.confirmation_number_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Chiffre d\'affaires',
                    value: '1 240 €',
                    icon: Icons.euro_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Films projetés',
                    value: '12',
                    icon: Icons.movie_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Événements',
                    value: '3',
                    icon: Icons.event_rounded,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryRed, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
