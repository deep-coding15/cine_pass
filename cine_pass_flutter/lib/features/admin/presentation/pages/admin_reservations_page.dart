import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/mock_admin_reservations.dart';

class AdminReservationsPage extends StatelessWidget {
  const AdminReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Réservations',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Liste de toutes les réservations (films et événements)',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.cardDark,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppTheme.surfaceDark),
                columns: const [
                  DataColumn(label: Text('Résa', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Utilisateur', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Titre', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Lieu / Salle', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Date séance', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Billets', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Montant', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Statut', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Date résa', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                ],
                rows: mockAdminReservations.map((r) {
                  return DataRow(
                    cells: [
                      DataCell(Text('#${r.id}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
                      DataCell(Text(r.userEmail, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
                      DataCell(Text(r.title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
                      DataCell(Text(r.room != null ? '${r.location}\n${r.room}' : r.location, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
                      DataCell(Text(r.dateTime, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
                      DataCell(Text('${r.ticketCount}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
                      DataCell(Text('${r.totalAmount.toStringAsFixed(2)} €', style: const TextStyle(color: AppTheme.accentGreen, fontSize: 13))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: r.status == 'confirmed' ? AppTheme.accentGreen.withValues(alpha: 0.2) : AppTheme.textSecondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            r.status == 'confirmed' ? 'Confirmée' : 'Annulée',
                            style: TextStyle(
                              color: r.status == 'confirmed' ? AppTheme.accentGreen : AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(_formatDate(r.createdAt), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
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

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
