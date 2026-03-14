import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

class AdminStatsReportPage extends StatefulWidget {
  const AdminStatsReportPage({super.key});

  @override
  State<AdminStatsReportPage> createState() => _AdminStatsReportPageState();
}

class _AdminStatsReportPageState extends State<AdminStatsReportPage> {
  DateTime? _dateStart;
  DateTime? _dateEnd;
  bool _loading = false;
  String? _error;
  int _nbReservations = 0;
  double _totalCA = 0;
  int _nbFilms = 0;
  int _nbEvents = 0;

  Future<void> _loadReport() async {
    if (_dateStart == null || _dateEnd == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reservations = await client.cinePass.getReservations();
      final films = await client.cinePass.getFilms();
      final events = await client.cinePass.getEvents();

      final start = DateTime(_dateStart!.year, _dateStart!.month, _dateStart!.day);
      final end = DateTime(_dateEnd!.year, _dateEnd!.month, _dateEnd!.day, 23, 59, 59);

      int nb = 0;
      double ca = 0;
      for (final r in reservations) {
        final createdAt = DateTime.tryParse(r.createdAtStr);
        if (createdAt != null && !createdAt.isBefore(start) && !createdAt.isAfter(end)) {
          nb++;
          ca += r.totalAmount;
        }
      }

      if (!mounted) return;
      setState(() {
        _nbReservations = nb;
        _totalCA = ca;
        _nbFilms = films.length;
        _nbEvents = events.length;
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

  Future<void> _exportPdf() async {
    if (_dateStart == null || _dateEnd == null) return;
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Rapport de statistiques CinePass',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Période: ${_dateStart!.day}/${_dateStart!.month}/${_dateStart!.year} - ${_dateEnd!.day}/${_dateEnd!.month}/${_dateEnd!.year}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 24),
              pw.Text('Réservations: $_nbReservations', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 4),
              pw.Text('Chiffre d\'affaires: ${_totalCA.toStringAsFixed(2)} €', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 4),
              pw.Text('Films au catalogue: $_nbFilms', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 4),
              pw.Text('Événements: $_nbEvents', style: const pw.TextStyle(fontSize: 14)),
            ],
          );
        },
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'cinepass-rapport-admin.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rapport de statistiques',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.textPrimary),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _loading
                              ? null
                              : () async {
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
                          onPressed: _loading
                              ? null
                              : () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: _dateEnd ?? _dateStart ?? DateTime.now(),
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
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _loading || _dateStart == null || _dateEnd == null
                            ? null
                            : _loadReport,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.assessment),
                        label: Text(_loading ? 'Chargement...' : 'Générer le rapport'),
                        style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                      ),
                      const SizedBox(width: 12),
                      if (_nbReservations > 0 || _totalCA > 0 || _nbFilms > 0 || _nbEvents > 0)
                        OutlinedButton.icon(
                          onPressed: _exportPdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Exporter PDF'),
                        ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ),
          if (_nbReservations > 0 || _totalCA > 0 || _nbFilms > 0 || _nbEvents > 0) ...[
            const SizedBox(height: 32),
            Text(
              'Résumé',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Réservations',
                    value: '$_nbReservations',
                    icon: Icons.confirmation_number_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Chiffre d\'affaires',
                    value: '${_totalCA.toStringAsFixed(0)} €',
                    icon: Icons.euro_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Films',
                    value: '$_nbFilms',
                    icon: Icons.movie_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Événements',
                    value: '$_nbEvents',
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
