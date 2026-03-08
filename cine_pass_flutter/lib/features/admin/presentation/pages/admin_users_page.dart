import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/mock_admin_data.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final total = mockAdminUsers.length;
    final admins = mockAdminUsers.where((u) => u.role == 'Admin').length;
    final actifs = mockAdminUsers.where((u) => u.status == 'Actif').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion des utilisateurs',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Gérez les comptes utilisateurs et leurs permissions',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
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
                  DataColumn(label: Text('Utilisateur')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Rôle')),
                  DataColumn(label: Text('Statut')),
                  DataColumn(label: Text('Date de création')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: mockAdminUsers.map((u) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppTheme.primaryRed,
                              child: Text(
                                u.name.isNotEmpty
                                    ? u.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (u.phone != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    u.phone!,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(u.email)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: u.role == 'Admin'
                                ? AppTheme.primaryRed.withValues(alpha: 0.2)
                                : AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            u.role,
                            style: TextStyle(
                              color: u.role == 'Admin'
                                  ? AppTheme.primaryRed
                                  : AppTheme.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            u.status,
                            style: const TextStyle(
                              color: AppTheme.accentGreen,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(u.createdAt)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.shield_outlined,
                                size: 20,
                                color: AppTheme.textSecondary,
                              ),
                              tooltip: 'Permissions',
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.block,
                                size: 20,
                                color: AppTheme.primaryRed,
                              ),
                              tooltip: 'Bloquer',
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 20,
                                color: AppTheme.textSecondary,
                              ),
                              tooltip: 'Voir',
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
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total utilisateurs',
                  value: '$total',
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Administrateurs',
                  value: '$admins',
                  color: AppTheme.primaryRed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Comptes actifs',
                  value: '$actifs',
                  color: AppTheme.accentGreen,
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
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
