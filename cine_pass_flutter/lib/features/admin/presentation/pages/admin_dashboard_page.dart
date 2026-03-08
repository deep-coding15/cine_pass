import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../main.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<FilmResponse> _films = [];
  List<EventResponse> _events = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final films = await client.cinePass.getFilms();
      final events = await client.cinePass.getEvents();
      if (!mounted) return;
      setState(() {
        _films = films;
        _events = events;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _films = [];
        _events = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de bord',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Vue d\'ensemble de votre plateforme CinePass',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _StatCard(title: 'Films actifs', value: '${_films.length}', icon: Icons.movie_rounded, color: AppTheme.primaryRed)),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(title: 'Événements à venir', value: '${_events.length}', icon: Icons.calendar_today_rounded, color: Color(0xFF26A69A))),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(title: 'Séances planifiées', value: '-', icon: Icons.schedule_rounded, color: Color(0xFF7E57C2))),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(title: 'Utilisateurs inscrits', value: '-', icon: Icons.people_rounded, color: AppTheme.accentGreen)),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  color: AppTheme.cardDark,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Films récents',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        ..._films.take(2).map(
                              (f) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Color(f.posterColor ?? 0xFF2D1B4E),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.movie_rounded, color: Colors.white24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(f.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                                          Text(f.genre, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Card(
                  color: AppTheme.cardDark,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Événements à venir',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        ..._events.take(2).map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Color(e.posterColor ?? 0xFF4E1B3D),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.event_rounded, color: Colors.white24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                                          Text(e.city, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Prix ${e.price.toInt()}€',
                                      style: const TextStyle(color: AppTheme.accentGreen, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
