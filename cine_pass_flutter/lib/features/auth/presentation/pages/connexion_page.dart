import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../../core/config/google_sign_in_config.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/state/pending_reservation_state.dart';
import '../../../../core/theme/app_theme.dart';
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
      {'email': email, 'password': password},
      authenticated: false,
    );
  }

  Future<UuidValue> startPasswordReset({required String email}) {
    return caller.callServerEndpoint<UuidValue>(
      name,
      'startPasswordReset',
      {'email': email},
      authenticated: false,
    );
  }

  Future<String> verifyPasswordResetCode({
    required UuidValue passwordResetRequestId,
    required String verificationCode,
  }) {
    return caller.callServerEndpoint<String>(
      name,
      'verifyPasswordResetCode',
      {
        'passwordResetRequestId': passwordResetRequestId,
        'verificationCode': verificationCode,
      },
      authenticated: false,
    );
  }

  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) {
    return caller.callServerEndpoint<void>(
      name,
      'finishPasswordReset',
      {
        'finishPasswordResetToken': finishPasswordResetToken,
        'newPassword': newPassword,
      },
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      // Retried on demand in onError.
    }

    if (!mounted) return;
    setState(() => _googleReady = true);
  }

  Future<void> _onGoogleAuthenticated() async {
    if (!mounted) return;
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
      setState(() => _errorMessage = 'Connexion email echouee: $e');
    } finally {
      if (mounted) {
        setState(() => _isEmailSubmitting = false);
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final authState = context.read<AuthState>();

    final resetEmailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    var step = 0;
    var isSubmitting = false;
    String? localError;
    String? localInfo;
    UuidValue? requestId;
    String? finishToken;

    try {
      final result = await showDialog<Map<String, String>?>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              final title = switch (step) {
                0 => 'Mot de passe oublie',
                1 => 'Verification du code',
                _ => 'Nouveau mot de passe',
              };

              return AlertDialog(
                backgroundColor: AppTheme.cardDark,
                title: Text(
                  title,
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (step == 0) ...[
                      const Text(
                        'Entrez votre email. Un code de reinitialisation sera envoye.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: resetEmailController,
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
                    ] else if (step == 1) ...[
                      const Text(
                        'Entrez le code recu par email.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: codeController,
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          labelText: 'Code de verification',
                          hintText: '123456',
                          filled: true,
                          fillColor: AppTheme.backgroundDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ] else ...[
                      const Text(
                        'Definissez un nouveau mot de passe.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: newPasswordController,
                        enabled: !isSubmitting,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Nouveau mot de passe',
                          hintText: '••••••••',
                          filled: true,
                          fillColor: AppTheme.backgroundDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmPasswordController,
                        enabled: !isSubmitting,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          hintText: '••••••••',
                          filled: true,
                          fillColor: AppTheme.backgroundDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ],
                    if (localInfo != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        localInfo!,
                        style: const TextStyle(
                          color: AppTheme.accentGreen,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
                  if (step > 0)
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
                              setModalState(() {
                                step -= 1;
                                localError = null;
                                localInfo = null;
                              });
                            },
                      child: const Text('Retour'),
                    ),
                  TextButton(
                    onPressed: isSubmitting ? null : () => context.pop(),
                    child: const Text('Annuler'),
                  ),
                  FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final dialogNavigator = Navigator.of(context);
                            final email = resetEmailController.text.trim();

                            setModalState(() {
                              localError = null;
                              localInfo = null;
                            });

                            if (step == 0) {
                              if (email.isEmpty || !email.contains('@')) {
                                setModalState(() => localError = 'Email invalide.');
                                return;
                              }

                              setModalState(() => isSubmitting = true);
                              try {
                                requestId = await _EmailAuthEndpoint(client)
                                    .startPasswordReset(email: email);
                                setModalState(() {
                                  step = 1;
                                  localInfo =
                                      'Code envoye. Verifiez votre boite mail.';
                                });
                              } catch (e) {
                                final message = e.toString();
                                // ignore: avoid_print
                                print('[ForgotPassword] startPasswordReset error: $message');
                                setModalState(() {
                                  localError =
                                      message.contains('tooManyAttempts')
                                          ? 'Trop de tentatives. Reessayez dans quelques minutes.'
                                          : 'Impossible d\'envoyer le code pour le moment.';
                                });
                              } finally {
                                if (context.mounted) {
                                  setModalState(() => isSubmitting = false);
                                }
                              }
                              return;
                            }

                            if (step == 1) {
                              final code = codeController.text.trim();
                              if (requestId == null) {
                                setModalState(() {
                                  localError =
                                      'Session de reinitialisation invalide. Recommencez.';
                                });
                                return;
                              }
                              if (code.length < 4) {
                                setModalState(() => localError = 'Code invalide.');
                                return;
                              }

                              setModalState(() => isSubmitting = true);
                              try {
                                finishToken = await _EmailAuthEndpoint(client)
                                    .verifyPasswordResetCode(
                                      passwordResetRequestId: requestId!,
                                      verificationCode: code,
                                    );
                                setModalState(() {
                                  step = 2;
                                  localInfo = null;
                                });
                              } catch (_) {
                                setModalState(
                                  () => localError = 'Code invalide ou expire.',
                                );
                              } finally {
                                if (context.mounted) {
                                  setModalState(() => isSubmitting = false);
                                }
                              }
                              return;
                            }

                            final newPassword = newPasswordController.text;
                            final confirmPassword = confirmPasswordController.text;

                            if (finishToken == null) {
                              setModalState(() {
                                localError =
                                    'Jeton de reinitialisation invalide. Recommencez.';
                              });
                              return;
                            }
                            if (newPassword.length < 8) {
                              setModalState(() {
                                localError =
                                    'Le mot de passe doit contenir au moins 8 caracteres.';
                              });
                              return;
                            }
                            if (newPassword != confirmPassword) {
                              setModalState(() {
                                localError =
                                    'La confirmation du mot de passe ne correspond pas.';
                              });
                              return;
                            }

                            setModalState(() => isSubmitting = true);
                            try {
                              await _EmailAuthEndpoint(client).finishPasswordReset(
                                finishPasswordResetToken: finishToken!,
                                newPassword: newPassword,
                              );

                              final authSuccess = await _EmailAuthEndpoint(client)
                                  .login(email: email, password: newPassword);
                              await client.auth.updateSignedInUser(authSuccess);
                              if (!mounted) return;
                              await authState.refreshProfileFromServer();
                              if (!mounted) return;

                              dialogNavigator.pop({
                                'email': email,
                                'password': newPassword,
                              });
                            } catch (e) {
                              final message = e.toString();
                              setModalState(() {
                                localError = message.contains('policyViolation')
                                    ? 'Mot de passe non conforme: au moins 8 caracteres, sans espaces en debut/fin.'
                                    : 'Impossible de finaliser la reinitialisation pour le moment.';
                              });
                            } finally {
                              if (context.mounted) {
                                setModalState(() => isSubmitting = false);
                              }
                            }
                          },
                    child: Text(
                      isSubmitting
                          ? 'Patientez...'
                          : switch (step) {
                              0 => 'Envoyer le code',
                              1 => 'Verifier le code',
                              _ => 'Valider le nouveau mot de passe',
                            },
                    ),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result != null && mounted) {
        _emailController.text = result['email'] ?? _emailController.text;
        _passwordController.text = result['password'] ?? _passwordController.text;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Mot de passe reinitialise avec succes. Vous etes connecte.',
            ),
          ),
        );

        // Let dialog disposal finish before triggering route changes.
        await Future<void>.delayed(Duration.zero);
        if (!mounted) return;
        await _handlePostAuthRedirect();
      }
    } finally {
      // Intentionally not disposing local controllers here to avoid
      // rare dispose-while-rebuild issues on web dialog teardown.
    }
  }

  Future<void> _handleForgotPasswordTap() => _showForgotPasswordDialog();

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
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: AppTheme.textPrimary),
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
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
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
              onPressed: _handleForgotPasswordTap,
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
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

