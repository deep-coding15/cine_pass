import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/router/app_router.dart';
import '../../../../main.dart';

/// Tableau de bord responsable : indicateurs et accès rapides.
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final structure = await client.cinePass.getMyStructure();
      final events = await client.cinePass.getMyEvents();
      final rapport = await client.cinePass.getRapportCA('30j');
      if (!mounted) return;
      setState(() {
        _countStructures = structure != null ? 1 : 0;
        _countEvents = events.length;
        _countReservations = rapport.nbReservations;
        _chiffreAffaires = rapport.totalCA;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
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
                  title: 'Revenus',
                  value: '${_chiffreAffaires.toStringAsFixed(0)} MAD',
                  subtitle: '30 derniers jours',
                  icon: Icons.payments_rounded,
                  color: AppTheme.accentGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _KpiCard(
                  title: 'Réservations',
                  value: '$_countReservations',
                  subtitle: '30 derniers jours',
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
          const SizedBox(height: 24),
          Text(
            'Les montants détaillés et exports sont dans l’onglet Rapports.',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.95),
              fontSize: 13,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
