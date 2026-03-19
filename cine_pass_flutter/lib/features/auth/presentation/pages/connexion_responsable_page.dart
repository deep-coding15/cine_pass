import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/widgets/cinepass_logo.dart';
import '../../../../main.dart';

class _EmailAuthEndpoint extends EndpointRef {
  _EmailAuthEndpoint(super.caller);

  @override
  String get name => 'emailAuth';

  Future<AuthSuccess> login({required String email, required String password}) {
    return caller.callServerEndpoint<AuthSuccess>(
      name,
      'login',
      {
        'email': email,
        'password': password,
      },
      authenticated: false,
    );
  }
}

/// Connexion à l'espace responsable avec l'email professionnel et le mot de passe
/// renseignés lors de la demande « Devenir responsable » (une fois la demande approuvée).
class ConnexionResponsablePage extends StatefulWidget {
  const ConnexionResponsablePage({super.key});

  @override
  State<ConnexionResponsablePage> createState() =>
      _ConnexionResponsablePageState();
}

class _ConnexionResponsablePageState extends State<ConnexionResponsablePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final router = GoRouter.of(context);
    final auth = context.read<AuthState>();

    try {
      final authSuccess = await _EmailAuthEndpoint(client).login(
        email: email,
        password: password,
      );
      await client.auth.updateSignedInUser(authSuccess);
      await auth.refreshProfileFromServer();

      if (!mounted) return;
      if (!auth.isResponsable) {
        await client.auth.signOutDevice();
        if (!mounted) return;
        setState(() {
          _errorMessage =
              'Ce compte n\'est pas encore responsable approuve. Faites d\'abord valider votre demande.';
        });
        return;
      }

      router.go(AppRouter.responsable);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Connexion responsable impossible: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
              'Espace responsable',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connectez-vous avec votre email professionnel et le mot de passe définis lors de votre demande.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email professionnel',
                hintText: 'contact@votrestructure.fr',
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
                if (v == null || v.trim().isEmpty) {
                  return 'Entrez votre email professionnel';
                }
                if (!v.contains('@')) {
                  return 'Email invalide';
                }
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
                  return 'Entrez votre mot de passe';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Accéder à mon espace responsable'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Connexion classique ? ',
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
