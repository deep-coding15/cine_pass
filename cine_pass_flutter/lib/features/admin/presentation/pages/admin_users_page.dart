import 'package:flutter/material.dart';
import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../main.dart';

String _initialLetter(String? name, String? email) {
  final s = (name ?? email ?? '?').trim();
  if (s.isEmpty) return '?';
  return s[0].toUpperCase();
}

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late Future<List<ProfileResponse>> _future;

  @override
  void initState() {
    super.initState();
    _future = client.cinePass.getAdminUsers();
  }

  Future<void> _reload() async {
    setState(() {
      _future = client.cinePass.getAdminUsers();
    });
  }

  Future<void> _showUserDetails(ProfileResponse user) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Détails utilisateur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('ID', user.userId ?? '—'),
              _detailRow('Nom affiché', user.displayName ?? '—'),
              _detailRow('Email', user.email ?? '—'),
              _detailRow('Téléphone', user.phone ?? '—'),
              _detailRow('Date de naissance', user.birthDate ?? '—'),
              _detailRow('Rôle', user.role ?? 'client'),
              _detailRow('Statut', (user.active ?? true) ? 'Actif' : 'Inactif'),
              _detailRow('Compte créé le', user.createdAt ?? '—'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Future<void> _changeRole(ProfileResponse user) async {
    final uid = user.userId;
    if (uid == null || uid.isEmpty) return;
    final currentRole = (user.role ?? 'client').toLowerCase();
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => _AdminRolePickerDialog(initialRole: currentRole),
    );
    if (selected == null || selected == currentRole) return;
    final ok = await client.cinePass.setAdminUserRole(
      userId: uid,
      role: selected,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Rôle mis à jour.' : 'Échec de mise à jour du rôle.',
        ),
        backgroundColor: ok ? AppTheme.accentGreen : AppTheme.primaryRed,
      ),
    );
    if (ok) await _reload();
  }

  Future<void> _deleteUser(ProfileResponse user) async {
    final myEmail = context.read<AuthState>().userEmail.trim().toLowerCase();
    final targetEmail = (user.email ?? '').trim().toLowerCase();
    if (myEmail.isNotEmpty &&
        targetEmail.isNotEmpty &&
        myEmail == targetEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vous ne pouvez pas supprimer votre propre compte admin.',
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }
    final uid = user.userId;
    if (uid == null || uid.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet utilisateur ?'),
        content: Text(
          'Cette action est définitive pour ${user.email ?? user.displayName ?? 'cet utilisateur'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await client.cinePass.deleteAdminUser(userId: uid);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Utilisateur supprimé.' : 'Suppression impossible.'),
        backgroundColor: ok ? AppTheme.accentGreen : AppTheme.primaryRed,
      ),
    );
    if (ok) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProfileResponse>>(
      future: _future,
      builder: (context, snap) {
        final users = snap.data ?? const <ProfileResponse>[];
        final myEmail = context
            .read<AuthState>()
            .userEmail
            .trim()
            .toLowerCase();
        final total = users.length;
        final actifs = users.where((u) => (u.active ?? true) == true).length;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestion des utilisateurs',
                style:
                    Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gérez les comptes utilisateurs et leurs permissions',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
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
                      DataColumn(label: Text('Créé le')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: users.map((u) {
                      final role = (u.role ?? 'client').toLowerCase();
                      final roleLabel = role == 'admin'
                          ? 'Admin'
                          : role == 'responsable'
                          ? 'Responsable'
                          : 'Client';
                      final created = (u.createdAt ?? '').trim();
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
                                    _initialLetter(u.displayName, u.email),
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
                                      u.displayName ?? '-',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (u.phone != null &&
                                        u.phone!.isNotEmpty) ...[
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
                          DataCell(Text(u.email ?? '-')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRed.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                roleLabel,
                                style: TextStyle(
                                  color: AppTheme.primaryRed,
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
                                color: AppTheme.accentGreen.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (u.active ?? true) ? 'Actif' : 'Inactif',
                                style: const TextStyle(
                                  color: AppTheme.accentGreen,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              created.length >= 10
                                  ? created.substring(0, 10)
                                  : '-',
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _showUserDetails(u),
                                  icon: const Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: AppTheme.textSecondary,
                                  ),
                                  tooltip: 'Voir détails',
                                ),
                                IconButton(
                                  onPressed: () => _changeRole(u),
                                  icon: const Icon(
                                    Icons.shield_outlined,
                                    size: 20,
                                    color: AppTheme.textSecondary,
                                  ),
                                  tooltip: 'Changer rôle',
                                ),
                                IconButton(
                                  onPressed:
                                      (myEmail.isNotEmpty &&
                                          (u.email ?? '')
                                                  .trim()
                                                  .toLowerCase() ==
                                              myEmail)
                                      ? null
                                      : () => _deleteUser(u),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: AppTheme.primaryRed,
                                  ),
                                  tooltip:
                                      (myEmail.isNotEmpty &&
                                          (u.email ?? '')
                                                  .trim()
                                                  .toLowerCase() ==
                                              myEmail)
                                      ? 'Impossible de supprimer votre compte'
                                      : 'Supprimer',
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
                  const Expanded(child: SizedBox.shrink()),
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
      },
    );
  }
}

/// Dialogue avec état local fiable pour le [DropdownButtonFormField].
class _AdminRolePickerDialog extends StatefulWidget {
  const _AdminRolePickerDialog({required this.initialRole});

  final String initialRole;

  @override
  State<_AdminRolePickerDialog> createState() => _AdminRolePickerDialogState();
}

class _AdminRolePickerDialogState extends State<_AdminRolePickerDialog> {
  late String _role;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardDark,
      title: const Text('Changer le rôle'),
      content: DropdownButton<String>(
        value: _role,
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: 'client', child: Text('Client')),
          DropdownMenuItem(
            value: 'responsable',
            child: Text('Responsable'),
          ),
          DropdownMenuItem(value: 'admin', child: Text('Admin')),
        ],
        onChanged: (v) {
          if (v != null) setState(() => _role = v);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_role),
          child: const Text('Enregistrer'),
        ),
      ],
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
