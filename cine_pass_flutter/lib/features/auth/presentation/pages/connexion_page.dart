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

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  bool _codeRequested = false;
  String? _errorMessage;
  String? _infoMessage;
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
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _onGoogleAuthenticated() async {
    if (!mounted) return;
    // Pull real user info from backend after login.
    await context.read<AuthState>().refreshProfileFromServer();
    await _handlePostAuthRedirect();
  }

  Future<void> _sendCode() async {
    final phone = _normalizedPhone();
    if (phone == null) {
      setState(() {
        _errorMessage = 'Numero de telephone invalide.';
        _infoMessage = null;
      });
      return;
    }

    setState(() {
      _isSendingCode = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    try {
      await client.phoneAuth.sendVerificationCode(phone);
      if (!mounted) return;
      setState(() {
        _codeRequested = true;
        _infoMessage = 'Code envoye par SMS. Verifiez votre telephone.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Impossible d\'envoyer le code: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    final phone = _normalizedPhone();
    final code = _codeController.text.trim();

    if (phone == null) {
      setState(() {
        _errorMessage = 'Numero de telephone invalide.';
        _infoMessage = null;
      });
      return;
    }
    if (code.length < 4) {
      setState(() {
        _errorMessage = 'Code de verification invalide.';
        _infoMessage = null;
      });
      return;
    }

    setState(() {
      _isVerifyingCode = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    try {
      final authSuccess = await client.phoneAuth.verifyCode(phone, code);
      if (!mounted) return;

      if (authSuccess == null) {
        setState(() {
          _errorMessage = 'Code invalide, expire ou deja utilise.';
        });
        return;
      }

      await client.auth.updateSignedInUser(authSuccess);
      if (!mounted) return;

      // Pull real user info from backend after login.
      await context.read<AuthState>().refreshProfileFromServer();
      if (!mounted) return;

      setState(() {
        _codeRequested = false;
        _codeController.clear();
        _infoMessage = 'Connexion reussie.';
      });

      await _handlePostAuthRedirect();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Verification impossible: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
        });
      }
    }
  }

  String? _normalizedPhone() {
    final input = _phoneController.text.trim();
    if (input.isEmpty) return null;

    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      final code = ch.codeUnitAt(0);
      final isDigit = code >= 48 && code <= 57;
      if (isDigit) {
        buffer.write(ch);
      } else if (ch == '+' && i == 0) {
        buffer.write(ch);
      }
    }

    final value = buffer.toString();
    if (value.length < 8) return null;
    return value;
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
                : 'Connectez-vous avec Google ou par numero de telephone',
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
          GoogleSignInWidget(
            key: ValueKey('google-sign-in-$_googleWidgetNonce'),
            client: client,
            onAuthenticated: _onGoogleAuthenticated,
            onError: (error) {
              if (!mounted) return;
              setState(() {
                _errorMessage = 'Connexion Google echouee: $error';
                _infoMessage = null;
              });
              // Many "first attempt fails, second works" issues come from the native
              // Google Sign-In SDK not being fully ready. Re-initialize and recreate
              // the widget so the next attempt doesn't reuse a bad internal state.
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
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _infoMessage = null;
                    _googleWidgetNonce++;
                  });
                },
                child: const Text('Réessayer Google'),
              ),
            ),
          ],
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
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Numero de telephone',
              hintText: '+33612345678',
              prefixIcon: const Icon(Icons.phone_outlined),
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
          FilledButton(
            onPressed: _isSendingCode ? null : _sendCode,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(_isSendingCode ? 'Envoi...' : 'Envoyer le code SMS'),
          ),
          if (_codeRequested) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Code SMS',
                hintText: '123456',
                prefixIcon: const Icon(Icons.lock_outline),
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
            OutlinedButton(
              onPressed: _isVerifyingCode ? null : _verifyCode,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppTheme.primaryRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isVerifyingCode ? 'Verification...' : 'Verifier le code',
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ],
          if (_infoMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _infoMessage!,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pas encore de compte ? ',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              TextButton(
                onPressed: () => context.go(AppRouter.inscription),
                child: const Text('S\'inscrire'),
              ),
            ],
          ),
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
