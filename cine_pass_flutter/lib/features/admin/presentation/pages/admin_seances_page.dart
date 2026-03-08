import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../films/data/mock_films_data.dart';
import '../../data/mock_admin_data.dart';
import '../widgets/admin_add_seance_dialog.dart';

class AdminSeancesPage extends StatelessWidget {
  const AdminSeancesPage({super.key});

  static List<({MockSeance seance, String filmTitle})> _allSeances() {
    final list = <({MockSeance seance, String filmTitle})>[];
    for (final entry in mockSeancesByFilm.entries) {
      final film = getFilmById(entry.key);
      final title = film?.title ?? 'Film inconnu';
      for (final s in entry.value) {
        list.add((seance: s, filmTitle: title));
      }
    }
    return list;
  }

  /// Format court pour affichage tableau (ex. "07/03 à 14:00").
  static String _shortDate(String dateTime) {
    final match = RegExp(r'(\d{1,2})\s+\w+\s+\d{4}\s+à\s+(\d{2}:\d{2})').firstMatch(dateTime);
    if (match != null) {
      final day = match.group(1)!.padLeft(2, '0');
      return '$day/03 à ${match.group(2)}';
    }
    return dateTime.length > 16 ? dateTime.substring(0, 16) : dateTime;
  }

  @override
  Widget build(BuildContext context) {
    final seances = _allSeances();
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gérez les séances de cinéma',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () => showDialog(context: context, builder: (_) => const AdminAddSeanceDialog()),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Nouvelle séance'),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
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
                headingTextStyle: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
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
                rows: seances.map((e) {
                  final s = e.seance;
                  return DataRow(
                    cells: [
                      DataCell(Text(e.filmTitle)),
                      DataCell(Text(s.cinemaName)),
                      DataCell(Text(s.room)),
                      DataCell(Text(_shortDate(s.dateTime))),
                      DataCell(Text(s.format)),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(s.type, style: const TextStyle(color: AppTheme.primaryRed, fontSize: 12)),
                      )),
                      DataCell(Text('${s.price.toStringAsFixed(2)} €')),
                      DataCell(Text('${s.placesTotal - s.placesLeft}/${s.placesTotal}')),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.textSecondary),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.primaryRed),
                          ),
                        ],
                      )),
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
