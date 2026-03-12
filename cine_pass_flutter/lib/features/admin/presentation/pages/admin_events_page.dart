import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../widgets/admin_add_event_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              FilledButton.icon(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => AdminAddEventDialog(onSaved: _load),
                  );
                  if (mounted) _load();
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Nouvel événement'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
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
                  DataColumn(label: Text('Catégorie')),
                  DataColumn(label: Text('Ville')),
                  DataColumn(label: Text('Date/Heure')),
                  DataColumn(label: Text('Prix')),
                  DataColumn(label: Text('Places')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _events.map((e) => _buildRow(e)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(EventResponse e) {
    final sold = e.placesTotal - e.placesLeft;
    return DataRow(
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
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              e.category,
              style: const TextStyle(color: AppTheme.primaryRed, fontSize: 12),
            ),
          ),
        ),
        DataCell(Text(e.city)),
        DataCell(Text('${e.date} ${e.time}')),
        DataCell(Text('${e.price.toStringAsFixed(2)} €')),
        DataCell(Text('$sold/${e.placesTotal}')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
              ),
              IconButton(
                onPressed: () {},
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
