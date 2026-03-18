import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'dart:async';

import '../../../../core/config/google_sign_in_config.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/pending_reservation_state.dart';
import '../../../../core/widgets/cinepass_logo.dart';
import '../../../../features/reservation/data/reservation_state.dart';
import '../../../../main.dart';
import '../widgets/auth_mode_tabs.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _EmailAuthEndpoint extends EndpointRef {
  _EmailAuthEndpoint(super.caller);

  @override
  String get name => 'emailAuth';

  Future<AuthSuccess> login({
    required String email,
    required String password,
  }) {
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

  Future<void> startPasswordReset({required String email}) {
    return caller.callServerEndpoint<void>(
      name,
      'startPasswordReset',
      {'email': email},
      authenticated: false,
    );
  }
}

class _ConnexionPageState extends State<ConnexionPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isEmailSubmitting = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _googleReady = false;
  int _googleWidgetNonce = 0;

  @override
  void initState() {
    super.initState();
    _warmUpGoogleSignIn();
  }

  Future<void> _warmUpGoogleSignIn() async {
    if (!GoogleSignInConfig.needsNativeInit) {
      setState(() => _googleReady = true);
      return;
    }
    try {
      await client.auth.initializeGoogleSignIn(
        clientId: GoogleSignInConfig.clientId,
        serverClientId: GoogleSignInConfig.serverClientId,
      );
    } catch (_) {
      // We'll retry on demand after the first failure.
    }
    if (!mounted) return;
    setState(() => _googleReady = true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onGoogleAuthenticated() async {
    if (!mounted) return;
    // Pull real user info from backend after login.
    await context.read<AuthState>().refreshProfileFromServer();
    await _handlePostAuthRedirect();
  }

  Future<void> _handlePostAuthRedirect() async {
    final pending = context.read<PendingReservationState>();
    final reservationState = context.read<ReservationState>();

    if (!mounted) return;

    if (pending.hasPending) {
      if (pending.isFilm &&
          pending.filmId != null &&
          pending.filmTitle != null &&
          pending.seanceId != null &&
          pending.cinemaName != null &&
          pending.cinemaLocation != null &&
          pending.room != null &&
          pending.dateTime != null) {
        reservationState.setFilmReservation(
          filmId: pending.filmId!,
          filmTitle: pending.filmTitle!,
          seanceId: pending.seanceId!,
          cinemaName: pending.cinemaName!,
          cinemaLocation: pending.cinemaLocation!,
          room: pending.room!,
          dateTime: pending.dateTime!,
          format: pending.format,
          type: pending.type,
          pricePerSeat: pending.pricePerSeat,
          quantity: pending.quantity,
          availableOptions: pending.availableOptionsFilm,
        );
      } else if (!pending.isFilm &&
          pending.eventId != null &&
          pending.eventTitle != null &&
          pending.eventLocation != null &&
          pending.eventDateTime != null) {
        reservationState.setEventReservation(
          eventId: pending.eventId!,
          eventTitle: pending.eventTitle!,
          eventLocation: pending.eventLocation!,
          eventDateTime: pending.eventDateTime!,
          quantity: pending.quantity,
          pricePerTicket: pending.eventPricePerTicket,
          availableOptions: pending.availableOptionsEvent,
        );
      }

      pending.clear();
      context.go(AppRouter.reservationTypeBillet);
      return;
    }

    context.go(AppRouter.home);
  }

  Future<void> _loginWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Email invalide.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Mot de passe requis.');
      return;
    }

    setState(() {
      _isEmailSubmitting = true;
      _errorMessage = null;
    });

    try {
      final authSuccess = await _EmailAuthEndpoint(client).login(
        email: email,
        password: password,
      );

      await client.auth.updateSignedInUser(authSuccess);
      if (!mounted) return;

      await context.read<AuthState>().refreshProfileFromServer();
      if (!mounted) return;

      await _handlePostAuthRedirect();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Connexion email echouee: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isEmailSubmitting = false;
        });
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final parentContext = context;
    final resetController = TextEditingController(text: _emailController.text.trim());
    var isSubmitting = false;
    String? localError;

    try {
      await showDialog<void>(
        context: parentContext,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return AlertDialog(
                backgroundColor: AppTheme.cardDark,
                title: const Text(
                  'Mot de passe oublie',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Entrez votre email pour recevoir les instructions de reinitialisation.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: resetController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isSubmitting,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'votre@email.com',
                        filled: true,
                        fillColor: AppTheme.backgroundDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelStyle: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                    if (localError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        localError!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: isSubmitting ? null : () => context.pop(),
                    child: const Text('Annuler'),
                  ),
                  FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final email = resetController.text.trim();
                            if (email.isEmpty || !email.contains('@')) {
                              setModalState(() => localError = 'Email invalide.');
                              return;
                            }

                            setModalState(() {
                              isSubmitting = true;
                              localError = null;
                            });

                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);

                            try {
                              await _EmailAuthEndpoint(client).startPasswordReset(email: email);
                              navigator.pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Si ce compte existe, un email de reinitialisation a ete envoye.',
                                  ),
                                ),
                              );
                            } catch (_) {
                              setModalState(() {
                                isSubmitting = false;
                                localError = 'Impossible d\'envoyer la demande pour le moment.';
                              });
                            }
                          },
                    child: Text(isSubmitting ? 'Envoi...' : 'Envoyer'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      resetController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = context.watch<PendingReservationState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const CinePassLogo(size: LogoSize.medium),
          const SizedBox(height: 32),
          Text(
            'Connexion',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            pending.hasPending
                ? 'Connectez-vous pour poursuivre votre reservation'
                : 'Connectez-vous avec email ou Google',
            style: TextStyle(
              color: pending.hasPending
                  ? AppTheme.primaryRed
                  : AppTheme.textSecondary,
              fontSize: 14,
              fontWeight:
                  pending.hasPending ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 24),
          const AuthModeTabs(activeTab: AuthModeTab.connexion),
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
          ),
          const SizedBox(height: 12),
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
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: const Text('Mot de passe oublie ?'),
            ),
          ),
          FilledButton(
            onPressed: _isEmailSubmitting ? null : _loginWithEmail,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(_isEmailSubmitting ? 'Connexion...' : 'Se connecter'),
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
            key: ValueKey('google-sign-in-$_googleWidgetNonce'),
            client: client,
            onAuthenticated: _onGoogleAuthenticated,
            onError: (error) {
              if (!mounted) return;
              setState(() {
                _errorMessage = 'Connexion Google echouee: $error';
              });
              unawaited(_warmUpGoogleSignIn());
              setState(() => _googleWidgetNonce++);
            },
          ),
          if (!_googleReady) ...[
            const SizedBox(height: 10),
            const Text(
              'Initialisation de Google…',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () => context.go(AppRouter.connexionResponsable),
              icon: const Icon(Icons.store_rounded, size: 18),
              label: const Text('Connexion espace responsable'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accentGreen,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Pour tester en admin : connectez-vous avec admin@cinepass.com (mot de passe au choix).',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
