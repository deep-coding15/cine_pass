import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/router/app_router.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _countStructures = 1;
      _countEvents = 1;
      _countReservations = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

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
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _DashboardCard(
                  icon: Icons.store_rounded,
                  title: 'Mes structures',
                  subtitle: 'Gérer vos cinémas, salles, lieux',
                  count: _countStructures,
                  onTap: () => context.go(AppRouter.responsableStructures),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DashboardCard(
                  icon: Icons.calendar_today_rounded,
                  title: 'Mes événements',
                  subtitle: 'Créer et modifier vos événements',
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
                  subtitle: 'Voir les réservations de vos structures',
                  count: _countReservations,
                  onTap: () => context.go(AppRouter.responsableReservations),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Container()),
            ],
          ),
        ],
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 32, color: AppTheme.accentGreen),
                  ),
                  if (count != null) ...[
                    const Spacer(),
                    Text(
                      '$count',
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
