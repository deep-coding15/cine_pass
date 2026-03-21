import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cine_pass_client/cine_pass_client.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/router/app_router.dart';
import '../../../../main.dart';

/// Tableau de bord responsable : CA, indicateurs clés, graphiques détaillés.
class ResponsableDashboardPage extends StatefulWidget {
  const ResponsableDashboardPage({super.key});

  @override
  State<ResponsableDashboardPage> createState() =>
      _ResponsableDashboardPageState();
}

class _ResponsableDashboardPageState extends State<ResponsableDashboardPage> {
  int _countStructures = 0;
  int _countEvents = 0;
  int _countReservations = 0;
  double _chiffreAffaires = 0;
  bool _loading = true;

  List<double> _caParMois = [0, 0, 0, 0, 0, 0];
  List<String> _moisLabels = const ['M-5', 'M-4', 'M-3', 'M-2', 'M-1', 'M'];
  List<_EventStats> _eventStats = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final structure = await client.cinePass.getMyStructure();
      final events = await client.cinePass.getMyEvents();
      final reservations = await client.cinePass.getReservationsForMyStructures();
      final rapport = await client.cinePass.getRapportCA('30j');

      final now = DateTime.now();
      final labels = List<String>.generate(6, (i) {
        final d = DateTime(now.year, now.month - (5 - i), 1);
        const m = ['Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aou', 'Sep', 'Oct', 'Nov', 'Dec'];
        return m[d.month - 1];
      });
      final monthly = List<double>.filled(6, 0);
      for (final r in reservations) {
        final dt = DateTime.tryParse(r.createdAtStr);
        if (dt == null) continue;
        final monthsAgo = (now.year - dt.year) * 12 + now.month - dt.month;
        if (monthsAgo < 0 || monthsAgo > 5) continue;
        final idx = 5 - monthsAgo;
        monthly[idx] += r.totalAmount;
      }

      final Map<String, _EventStats> statsByEvent = {};
      for (final r in reservations) {
        final key = (r.eventTitle == null || r.eventTitle!.trim().isEmpty)
            ? 'Événement'
            : r.eventTitle!.trim();
        final current = statsByEvent[key];
        if (current == null) {
          statsByEvent[key] = _EventStats(
            title: key,
            reservations: 1,
            ca: r.totalAmount,
          );
        } else {
          statsByEvent[key] = _EventStats(
            title: current.title,
            reservations: current.reservations + 1,
            ca: current.ca + r.totalAmount,
          );
        }
      }
      final eventStats = statsByEvent.values.toList()
        ..sort((a, b) => b.ca.compareTo(a.ca));

      if (!mounted) return;
      setState(() {
        _countStructures = structure == null ? 0 : 1;
        _countEvents = events.length;
        _countReservations = reservations.length;
        _chiffreAffaires = rapport.totalCA;
        _moisLabels = labels;
        _caParMois = monthly;
        _eventStats = eventStats;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _countStructures = 0;
        _countEvents = 0;
        _countReservations = 0;
        _chiffreAffaires = 0;
        _caParMois = [0, 0, 0, 0, 0, 0];
        _eventStats = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentGreen),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de bord',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bienvenue, ${auth.userName}',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 28),

          // KPIs
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  title: 'Chiffre d\'affaires',
                  value: '${_chiffreAffaires.toStringAsFixed(0)} €',
                  subtitle: 'Total période',
                  icon: Icons.euro_rounded,
                  color: AppTheme.accentGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KpiCard(
                  title: 'Réservations',
                  value: '$_countReservations',
                  subtitle: 'Toutes structures',
                  icon: Icons.confirmation_number_rounded,
                  color: AppTheme.primaryRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  title: 'Événements',
                  value: '$_countEvents',
                  subtitle: 'Publiés',
                  icon: Icons.calendar_today_rounded,
                  color: AppTheme.accentGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KpiCard(
                  title: 'Ma structure',
                  value: '$_countStructures',
                  subtitle: 'Assignée',
                  icon: Icons.store_rounded,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Graphique CA par mois
          Text(
            'Chiffre d\'affaires par mois',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: Card(
              color: AppTheme.cardDark,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  right: 16,
                  left: 8,
                  bottom: 12,
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: ((_caParMois.reduce((a, b) => a > b ? a : b)) <= 0
                            ? 100
                            : (_caParMois.reduce((a, b) => a > b ? a : b) * 1.2))
                        .ceilToDouble(),
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i >= 0 && i < _moisLabels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _moisLabels[i],
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 28,
                          interval: 1,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()} €',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 100,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppTheme.textSecondary.withValues(alpha: 0.15),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _caParMois
                        .asMap()
                        .entries
                        .map(
                          (e) => BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value,
                                color: AppTheme.accentGreen,
                                width: 24,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          ),
                        )
                        .toList(),
                  ),
                  duration: const Duration(milliseconds: 300),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // CA / réservations par événement
          Text(
            'Réservations et CA par événement',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: _eventStats.isEmpty
                    ? const [
                        Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Aucune donnée réservation pour le moment.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      ]
                    : _eventStats.map((e) {
                  final maxCa = _eventStats
                      .map((x) => x.ca)
                      .reduce((a, b) => a > b ? a : b);
                  final pct = maxCa > 0 ? (e.ca / maxCa) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                e.title,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${e.reservations} rés. • ${e.ca.toStringAsFixed(0)} €',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor: AppTheme.surfaceDark,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Accès rapides
          Text(
            'Accès rapides',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DashboardCard(
                  icon: Icons.store_rounded,
                  title: 'Ma structure',
                  subtitle: 'La structure que vous représentez',
                  count: _countStructures,
                  onTap: () => context.go(AppRouter.responsableStructures),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DashboardCard(
                  icon: Icons.calendar_today_rounded,
                  title: 'Mes événements',
                  subtitle: 'Créer et modifier',
                  count: _countEvents,
                  onTap: () => context.go(AppRouter.responsableEvents),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DashboardCard(
                  icon: Icons.confirmation_number_rounded,
                  title: 'Réservations',
                  subtitle: 'Gérer les réservations',
                  count: _countReservations,
                  onTap: () => context.go(AppRouter.responsableReservations),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DashboardCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Rapports',
                  subtitle: 'Exports et statistiques',
                  onTap: () => context.go(AppRouter.responsableRapports),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.count,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 26, color: AppTheme.accentGreen),
                  ),
                  if (count != null) ...[
                    const Spacer(),
                    Text(
                      '$count',
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventStats {
  final String title;
  final int reservations;
  final double ca;
  _EventStats({
    required this.title,
    required this.reservations,
    required this.ca,
  });
}
