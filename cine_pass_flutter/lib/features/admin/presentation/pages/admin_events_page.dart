import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../../../events/presentation/widgets/event_type_badge.dart';

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  List<EventResponse> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _structureEtLieu(EventResponse e) {
    final lieu = e.location.trim();
    final s = e.structureName?.trim();
    if (s != null && s.isNotEmpty && lieu.isNotEmpty) {
      return '$s / $lieu';
    }
    if (s != null && s.isNotEmpty) {
      return s;
    }
    return lieu.isNotEmpty ? lieu : '—';
  }

  /// Heure lisible : évite « 2026- » si `time` est une date ISO complète.
  String _dateHeure(EventResponse e) {
    final d = e.date.trim();
    final raw = e.time.trim();
    String timeShort = raw;
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      timeShort =
          '${parsed.hour.toString().padLeft(2, '0')}:'
          '${parsed.minute.toString().padLeft(2, '0')}';
    } else {
      final m = RegExp(r'(\d{1,2}:\d{2})').firstMatch(raw);
      if (m != null) {
        timeShort = m.group(1)!;
      } else if (raw.length >= 5 && raw.substring(2, 3) == ':') {
        timeShort = raw.substring(0, 5);
      }
    }
    return '$d $timeShort';
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final events = await client.cinePass.getEvents();
      if (!mounted) return;
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _events = [];
        _loading = false;
      });
    }
  }

  Future<void> _openEdit(EventResponse e) async {
    if (!mounted) return;
    await context.push('/admin/events/${e.id}');
    if (mounted) await _load();
  }

  Future<void> _confirmDelete(EventResponse e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Supprimer l\'événement ?'),
        content: Text(
          '« ${e.title} » sera supprimé définitivement.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final deleted = await client.cinePass.deleteEvent(e.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted ? 'Événement supprimé.' : 'Suppression impossible.',
        ),
        backgroundColor: deleted ? AppTheme.accentGreen : AppTheme.primaryRed,
      ),
    );
    if (deleted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryRed),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestion des événements',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gérez les événements et spectacles',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                dataTextStyle: const TextStyle(color: AppTheme.textPrimary),
                columns: const [
                  DataColumn(label: Text('Événement')),
                  DataColumn(label: Text('Structure / Lieu')),
                  DataColumn(label: Text('Catégorie')),
                  DataColumn(label: Text('Ville')),
                  DataColumn(label: Text('Date/Heure')),
                  DataColumn(label: Text('Prix')),
                  DataColumn(label: Text('Places')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _events.map((e) => _buildRow(context, e)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(BuildContext context, EventResponse e) {
    final sold = e.placesTotal - e.placesLeft;
    return DataRow(
      onSelectChanged: (_) => _openEdit(e),
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 44,
                  height: 44,
                  color: Color(e.posterColor ?? 0xFF4E1B3D),
                  child: Icon(
                    Icons.event_rounded,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    e.location,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text(_structureEtLieu(e))),
        DataCell(
          SizedBox(
            width: 120,
            child: EventTypeBadge(event: e, compact: true, maxWidth: 120),
          ),
        ),
        DataCell(Text(e.city)),
        DataCell(Text(_dateHeure(e))),
        DataCell(Text('${e.price.toStringAsFixed(2)} MAD')),
        DataCell(Text('$sold/${e.placesTotal}')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _openEdit(e),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
              ),
              IconButton(
                onPressed: () => _confirmDelete(e),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppTheme.primaryRed,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
