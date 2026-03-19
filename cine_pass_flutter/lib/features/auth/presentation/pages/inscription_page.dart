import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/widgets/cinepass_logo.dart';
import '../../../../main.dart';
import '../widgets/auth_mode_tabs.dart';

class _EmailAuthEndpoint extends EndpointRef {
  _EmailAuthEndpoint(super.caller);

  @override
  String get name => 'emailAuth';

  Future<AuthSuccess> register({
    required String email,
    required String password,
    String? fullName,
  }) {
    return caller.callServerEndpoint<AuthSuccess>(
      name,
      'register',
      {
        'email': email,
        'password': password,
        'fullName': fullName,
      },
      authenticated: false,
    );
  }
}

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onGoogleAuthenticated() async {
    if (!mounted) return;
    await context.read<AuthState>().refreshProfileFromServer();
    if (!mounted) return;
    context.go(AppRouter.home);
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final authSuccess = await _EmailAuthEndpoint(client).register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );

      await client.auth.updateSignedInUser(authSuccess);
      if (!mounted) return;

      await context.read<AuthState>().refreshProfileFromServer();
      if (!mounted) return;

      context.go(AppRouter.home);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Inscription impossible: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const CinePassLogo(size: LogoSize.medium),
            const SizedBox(height: 32),
            Text(
              'Inscription',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez un compte avec Google ou avec votre email',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            const AuthModeTabs(activeTab: AuthModeTab.inscription),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nom complet',
                hintText: 'Votre nom',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Entrez votre nom';
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'votre@email.com',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Entrez votre email';
                if (!v.contains('@')) return 'Email invalide';
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Choisissez un mot de passe';
                }
                if (v.length < 8) {
                  return 'Au moins 8 caractères';
                }
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(_isSubmitting ? 'Inscription...' : 'S\'inscrire'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppTheme.textSecondary.withValues(alpha: 0.35),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'OU',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppTheme.textSecondary.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GoogleSignInWidget(
              client: client,
              onAuthenticated: _onGoogleAuthenticated,
              onError: (error) {
                if (!mounted) return;
                setState(() {
                  _errorMessage = 'Connexion Google echouee: $error';
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Déjà un compte ? ',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                TextButton(
                  onPressed: () => context.go(AppRouter.connexion),
                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
