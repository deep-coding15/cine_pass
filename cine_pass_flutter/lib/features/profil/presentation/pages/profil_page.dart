import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cine_pass_client/src/protocol/cine_pass/profile_response.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/router/app_router.dart';
import '../../../../main.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  ProfileResponse? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await client.cinePass.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = p;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profile = null;
        _loading = false;
        _error = e.toString();
      });
    }
  }

  String get _displayName {
    if (_profile?.displayName != null && _profile!.displayName!.isNotEmpty) {
      return _profile!.displayName!;
    }
    return context.read<AuthState>().userName;
  }

  String get _email {
    if (_profile?.email != null && _profile!.email!.isNotEmpty) {
      return _profile!.email!;
    }
    return context.read<AuthState>().userEmail;
  }

  String get _phone => _profile?.phone ?? '—';
  String get _birthDate => _profile?.birthDate ?? '—';

  void _showEditProfile() {
    final nameController = TextEditingController(text: _profile?.displayName ?? context.read<AuthState>().userName);
    final phoneController = TextEditingController(text: _profile?.phone ?? '');
    final birthController = TextEditingController(text: _profile?.birthDate ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Modifier mon profil',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom affiché',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: birthController,
                decoration: const InputDecoration(
                  labelText: 'Date de naissance (AAAA-MM-JJ)',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () async {
                      final ok = await client.cinePass.updateProfile(
                        displayName: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
                        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                        birthDate: birthController.text.trim().isEmpty ? null : birthController.text.trim(),
                      );
                      if (!ctx.mounted) return;
                      Navigator.of(ctx).pop();
                      if (ok) await _loadProfile();
                    },
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    if (!auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.go(AppRouter.home),
      );
      return const SizedBox.shrink();
    }

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
          Text(
            'Mon profil',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              'Profil chargé depuis l\'app (connexion locale).',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
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
                    onPressed: _showEditProfile,
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: AppTheme.textSecondary,
                    ),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _infoRow(Icons.person_outline_rounded, 'Nom complet', _displayName),
                  _infoRow(Icons.email_outlined, 'Email', _email),
                  _infoRow(Icons.phone_outlined, 'Téléphone', _phone),
                  _infoRow(Icons.calendar_today_rounded, 'Date de naissance', _birthDate),
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
                    title: const Text(
                      'Modifier mon profil',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    onTap: _showEditProfile,
                  ),
                  const Divider(color: AppTheme.textSecondary, height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppTheme.primaryRed),
                    title: const Text(
                      'Se déconnecter',
                      style: TextStyle(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
