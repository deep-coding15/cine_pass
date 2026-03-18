import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  String? _error;
  double _totalCA = 0;
  int _nbReservations = 0;

  Future<void> _loadRapport() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rapport = await client.cinePass.getRapportCA(_selectedPeriode);
      if (!mounted) return;
      setState(() {
        _totalCA = rapport.totalCA;
        _nbReservations = rapport.nbReservations;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRapport();
  }

  String get _periodeLabel {
    switch (_selectedPeriode) {
      case '7j':
        return '7 jours';
      case '30j':
        return '30 jours';
      case '3m':
        return '3 mois';
      case '1an':
        return '1 an';
      default:
        return _selectedPeriode;
    }
  }

  Future<void> _exportPdfCa() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Rapport CA — Espace responsable',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Période: $_periodeLabel', style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 24),
              pw.Text('Chiffre d\'affaires: ${_totalCA.toStringAsFixed(2)} €', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),
              pw.Text('Nombre de réservations: $_nbReservations', style: const pw.TextStyle(fontSize: 14)),
            ],
          );
        },
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'cinepass-rapport-ca-$_selectedPeriode.pdf');
  }

  void _export(String type) {
    if (type == 'pdf_ca') {
      _exportPdfCa();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rapport CA (PDF) exporté'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export $type (période: $_selectedPeriode) — à venir'),
        backgroundColor: AppTheme.accentGreen,
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
                        onTap: () {
                          setState(() => _selectedPeriode = '7j');
                          _loadRapport();
                        },
                      ),
                      const SizedBox(width: 8),
                      _ChipChoice(
                        label: '30 jours',
                        value: '30j',
                        selected: _selectedPeriode == '30j',
                        onTap: () {
                          setState(() => _selectedPeriode = '30j');
                          _loadRapport();
                        },
                      ),
                      const SizedBox(width: 8),
                      _ChipChoice(
                        label: '3 mois',
                        value: '3m',
                        selected: _selectedPeriode == '3m',
                        onTap: () {
                          setState(() => _selectedPeriode = '3m');
                          _loadRapport();
                        },
                      ),
                      const SizedBox(width: 8),
                      _ChipChoice(
                        label: 'Année',
                        value: '1an',
                        selected: _selectedPeriode == '1an',
                        onTap: () {
                          setState(() => _selectedPeriode = '1an');
                          _loadRapport();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_loading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed)),
          ] else if (_error != null) ...[
            const SizedBox(height: 24),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ] else ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Chiffre d\'affaires',
                    value: '${_totalCA.toStringAsFixed(2)} €',
                    icon: Icons.euro_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Réservations',
                    value: '$_nbReservations',
                    icon: Icons.confirmation_number_rounded,
                  ),
                ),
              ],
            ),
          ],
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
            subtitle: 'Chiffre d\'affaires et réservations par période',
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
          Icon(icon, color: AppTheme.accentGreen, size: 28),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
        trailing: const Icon(
          Icons.download_rounded,
          color: AppTheme.accentGreen,
        ),
        onTap: onTap,
      ),
    );
  }
}
