import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../widgets/admin_add_seance_dialog.dart';

class AdminSeancesPage extends StatefulWidget {
  const AdminSeancesPage({super.key});

  @override
  State<AdminSeancesPage> createState() => _AdminSeancesPageState();
}

class _AdminSeancesPageState extends State<AdminSeancesPage> {
  List<FilmResponse> _films = [];
  List<({SeanceResponse seance, String filmTitle})> _seances = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final films = await client.cinePass.getFilms();
      final list = <({SeanceResponse seance, String filmTitle})>[];
      for (final film in films) {
        final seances = await client.cinePass.getSeancesForFilm(film.id);
        for (final s in seances) {
          list.add((seance: s, filmTitle: film.title));
        }
      }
      list.sort((a, b) => a.seance.dateTime.compareTo(b.seance.dateTime));
      if (!mounted) return;
      setState(() {
        _films = films;
        _seances = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _films = [];
        _seances = [];
        _loading = false;
      });
    }
  }

  static String _shortDate(String dateTime) {
    if (dateTime.length >= 16) return dateTime.substring(0, 16);
    return dateTime;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestion des séances',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gérez les séances de cinéma',
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
                    builder: (_) => AdminAddSeanceDialog(
                      films: _films,
                      onSaved: _load,
                    ),
                  );
                  if (mounted) _load();
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Nouvelle séance'),
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
                  DataColumn(label: Text('Film')),
                  DataColumn(label: Text('Cinéma')),
                  DataColumn(label: Text('Salle')),
                  DataColumn(label: Text('Date/Heure')),
                  DataColumn(label: Text('Langue')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Prix')),
                  DataColumn(label: Text('Places')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _seances.map((e) {
                  final s = e.seance;
                  return DataRow(
                    cells: [
                      DataCell(Text(e.filmTitle)),
                      DataCell(Text(s.cinemaName)),
                      DataCell(Text(s.room)),
                      DataCell(Text(_shortDate(s.dateTime))),
                      DataCell(Text(s.format ?? 'VF')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            s.type ?? '2D',
                            style: const TextStyle(
                              color: AppTheme.primaryRed,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text('${s.price.toStringAsFixed(2)} MAD')),
                      DataCell(
                        Text(
                          '${s.placesTotal - s.placesLeft}/${s.placesTotal}',
                        ),
                      ),
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
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
