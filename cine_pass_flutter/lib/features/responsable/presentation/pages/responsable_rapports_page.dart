import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

/// Rapports et exports : CA, réservations, statistiques.
class ResponsableRapportsPage extends StatefulWidget {
  const ResponsableRapportsPage({super.key});

  @override
  State<ResponsableRapportsPage> createState() => _ResponsableRapportsPageState();
}

class _ResponsableRapportsPageState extends State<ResponsableRapportsPage> {
  String _selectedPeriode = '30j';
  bool _loading = false;
  RapportCAResponse? _rapportCA;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rapports',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Exports et statistiques détaillées pour vos structures.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Période',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ChipChoice(
                        label: '7 jours',
                        value: '7j',
                        selected: _selectedPeriode == '7j',
                        onTap: () => setState(() => _selectedPeriode = '7j'),
                      ),
                      const SizedBox(width: 8),
                      _ChipChoice(
                        label: '30 jours',
                        value: '30j',
                        selected: _selectedPeriode == '30j',
                        onTap: () => setState(() => _selectedPeriode = '30j'),
                      ),
                      const SizedBox(width: 8),
                      _ChipChoice(
                        label: '3 mois',
                        value: '3m',
                        selected: _selectedPeriode == '3m',
                        onTap: () => setState(() => _selectedPeriode = '3m'),
                      ),
                      const SizedBox(width: 8),
                      _ChipChoice(
                        label: 'Année',
                        value: '1an',
                        selected: _selectedPeriode == '1an',
                        onTap: () => setState(() => _selectedPeriode = '1an'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Exporter',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          _ReportActionTile(
            icon: Icons.picture_as_pdf_rounded,
            title: 'Rapport CA (PDF)',
            subtitle: 'Chiffre d\'affaires et réservations par événement',
            onTap: () => _export('pdf_ca'),
          ),
          const SizedBox(height: 8),
          _ReportActionTile(
            icon: Icons.table_chart_rounded,
            title: 'Réservations (Excel)',
            subtitle: 'Liste détaillée des réservations',
            onTap: () => _export('excel_resa'),
          ),
          const SizedBox(height: 8),
          _ReportActionTile(
            icon: Icons.bar_chart_rounded,
            title: 'Statistiques événements (PDF)',
            subtitle: 'Taux de remplissage, CA par événement',
            onTap: () => _export('pdf_stats'),
          ),
          const SizedBox(height: 28),
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rapports disponibles',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Les exports sont générés pour la période sélectionnée et incluent uniquement les données de vos structures assignées.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _export(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export $type (période: $_selectedPeriode) — à venir'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }
}

class _ChipChoice extends StatelessWidget {
  const _ChipChoice({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.accentGreen.withValues(alpha: 0.3),
      checkmarkColor: AppTheme.accentGreen,
      labelStyle: TextStyle(
        color: selected ? AppTheme.accentGreen : AppTheme.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _ReportActionTile extends StatelessWidget {
  const _ReportActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.accentGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.accentGreen, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(Icons.download_rounded, color: AppTheme.accentGreen),
        onTap: onTap,
      ),
    );
  }
}
