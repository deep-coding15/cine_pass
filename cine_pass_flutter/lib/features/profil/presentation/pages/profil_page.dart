import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/router/app_router.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthState.instance;
    if (!auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go(AppRouter.home));
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mon profil',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryRed,
                    child: Text(
                      auth.userInitials,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.userName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.userEmail,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _tag('Client', AppTheme.primaryRed),
                            const SizedBox(width: 8),
                            _tag('Compte actif', AppTheme.accentGreen),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_rounded, color: AppTheme.textSecondary),
                    tooltip: 'Modifier',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations personnelles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  _infoRow(Icons.person_outline_rounded, 'Nom complet', auth.userName),
                  _infoRow(Icons.email_outlined, 'Email', auth.userEmail),
                  _infoRow(Icons.phone_outlined, 'Téléphone', '+33 6 12 34 56 78'),
                  _infoRow(Icons.calendar_today_rounded, 'Date de naissance', '15 mai 1990'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Préférences',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  const Text('Genres préférés', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 8, children: [_tag('Action', AppTheme.surfaceDark), _tag('Science-Fiction', AppTheme.surfaceDark)]),
                  const SizedBox(height: 12),
                  const Text('Villes préférées', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 8, children: [_tag('Paris', AppTheme.surfaceDark), _tag('Lyon', AppTheme.surfaceDark)]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_rounded, color: AppTheme.textPrimary),
                    title: const Text('Modifier mon profil', style: TextStyle(color: AppTheme.textPrimary)),
                    onTap: () {},
                  ),
                  const Divider(color: AppTheme.textSecondary, height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppTheme.primaryRed),
                    title: const Text('Se déconnecter', style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.w600)),
                    onTap: () {
                      auth.logout();
                      if (context.mounted) context.go(AppRouter.home);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: AppTheme.textSecondary)),
          Expanded(child: Text(value, style: const TextStyle(color: AppTheme.textPrimary))),
        ],
      ),
    );
  }
}
