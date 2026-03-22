import 'dart:convert';

import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _eventSearch = TextEditingController();
  List<EventResponse> _events = [];
  int _structuresCount = 0;
  int _usersCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _eventSearch.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        client.cinePass.getEvents(),
        client.cinePass.getStructures(),
        client.cinePass.getAdminUsers(),
      ]);
      final events = results[0] as List<EventResponse>;
      final structures = results[1] as List<Structure>;
      final users = results[2] as List<ProfileResponse>;
      if (!mounted) return;
      setState(() {
        _events = events;
        _structuresCount = structures.length;
        _usersCount = users.length;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _events = [];
        _structuresCount = 0;
        _usersCount = 0;
      });
    }
  }

  String _eventSubtitle(EventResponse e) {
    final lieu = e.location.trim();
    final s = e.structureName?.trim();
    if (s != null && s.isNotEmpty && lieu.isNotEmpty) {
      return '$s / $lieu';
    }
    if (s != null && s.isNotEmpty) {
      return s;
    }
    if (lieu.isNotEmpty) {
      return lieu;
    }
    return e.city;
  }

  List<EventResponse> get _filteredDashboardEvents {
    final q = _eventSearch.text.trim().toLowerCase();
    if (q.isEmpty) return _events;
    return _events
        .where(
          (e) =>
              e.title.toLowerCase().contains(q) ||
              e.category.toLowerCase().contains(q) ||
              e.city.toLowerCase().contains(q) ||
              e.location.toLowerCase().contains(q) ||
              (e.structureName?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.primaryRed,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tableau de bord',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vue d\'ensemble de votre plateforme CinePass',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Actualiser',
                  onPressed: _load,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final cards = [
                  _StatCard(
                    title: 'Événements',
                    value: '${_events.length}',
                    subtitle: 'À venir (liste publique)',
                    icon: Icons.event_rounded,
                    color: AppTheme.primaryRed,
                  ),
                  _StatCard(
                    title: 'Structures',
                    value: '$_structuresCount',
                    subtitle: 'Organisateurs',
                    icon: Icons.store_rounded,
                    color: const Color(0xFF26A69A),
                  ),
                  _StatCard(
                    title: 'Utilisateurs',
                    value: '$_usersCount',
                    subtitle: 'Comptes inscrits',
                    icon: Icons.people_rounded,
                    color: AppTheme.accentGreen,
                  ),
                ];
                if (w < 640) {
                  return Column(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        cards[i],
                      ],
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 14),
                    Expanded(child: cards[1]),
                    const SizedBox(width: 14),
                    Expanded(child: cards[2]),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryRed.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRed.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Card(
                color: AppTheme.cardDark,
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: AppTheme.textSecondary.withValues(alpha: 0.08),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_movies_outlined,
                            color: AppTheme.accentGreen,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Événements à l\'affiche',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Spectacles & événements — structure / lieu',
                        style: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_events.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Aucun événement à venir dans la liste publique.',
                              style: TextStyle(
                                color: AppTheme.textSecondary.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                          ),
                        )
                      else if (_filteredDashboardEvents.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'Aucun événement ne correspond au filtre.',
                              style: TextStyle(
                                color: AppTheme.textSecondary.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        ..._filteredDashboardEvents
                            .take(8)
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Material(
                                  color: AppTheme.surfaceDark,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () =>
                                        context.go('/admin/events/${e.id}'),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          _AdminEventPosterThumb(
                                            posterUrl: e.posterUrl,
                                            posterColor:
                                                e.posterColor ?? 0xFF4E1B3D,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e.title,
                                                  style: const TextStyle(
                                                    color: AppTheme.textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${e.category} • ${_eventSubtitle(e)}',
                                                  style: const TextStyle(
                                                    color:
                                                        AppTheme.textSecondary,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${e.date} • ${e.city}',
                                                  style: TextStyle(
                                                    color: AppTheme
                                                        .textSecondary
                                                        .withValues(
                                                          alpha: 0.85,
                                                        ),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${e.price.toStringAsFixed(0)} MAD',
                                                style: const TextStyle(
                                                  color: AppTheme.accentGreen,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${e.placesLeft}/${e.placesTotal} pl.',
                                                style: const TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
      ),
    );
  }
}

/// Mini-affiche événement (URL réseau ou data: base64).
class _AdminEventPosterThumb extends StatelessWidget {
  const _AdminEventPosterThumb({
    required this.posterUrl,
    required this.posterColor,
  });

  final String? posterUrl;
  final int posterColor;

  @override
  Widget build(BuildContext context) {
    final c = Color(posterColor);
    final placeholder = Container(
      width: 44,
      height: 56,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.event_rounded,
        color: Colors.white.withValues(alpha: 0.35),
        size: 22,
      ),
    );
    final url = posterUrl?.trim();
    if (url == null || url.isEmpty) return placeholder;
    if (url.startsWith('data:')) {
      try {
        final i = url.indexOf(',');
        if (i > 0) {
          final bytes = base64Decode(url.substring(i + 1));
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes,
              width: 44,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
          );
        }
      } catch (_) {
        return placeholder;
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 44,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: 44,
            height: 56,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: c.withValues(alpha: 0.8),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppTheme.textSecondary.withValues(alpha: 0.1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 3, color: color),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.85,
                            ),
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
