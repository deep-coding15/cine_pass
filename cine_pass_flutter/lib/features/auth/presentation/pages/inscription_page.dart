import 'dart:async';

import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/state/pending_reservation_state.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cinepass_logo.dart';
import '../../../../features/reservation/data/reservation_state.dart';
import '../../../../main.dart';
import '../widgets/auth_mode_tabs.dart';

/// Inscription : email + mot de passe (auth) puis complétion du profil
/// dans le même formulaire, avec vérification par code email.
class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  late final EmailAuthController _emailAuthController;

  final _passwordUiController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _emailAuthController = EmailAuthController(
      client: client,
      startScreen: EmailFlowScreen.startRegistration,
      emailValidation: (email) => _validateEmail(email),
      onAuthenticated: () {
        // `onAuthenticated` est un void callback : on déclenche la tâche async
        // en best-effort.
        unawaited(_onAuthenticatedAndCompleteProfile());
      },
      onError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
    );

    // Rebuild when the password changes so we can show requirements live.
    _passwordUiController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });

    _emailAuthController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailAuthController.dispose();
    _passwordUiController.dispose();
    super.dispose();
  }

  void _validateEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) throw const InvalidEmailException('Email invalide');

    final domain = parts[1].trim();
    if (domain.isEmpty || !domain.contains('.') || domain.endsWith('.')) {
      throw const InvalidEmailException('Domaine email invalide');
    }
    if (domain.split('.').last.length < 2) {
      throw const InvalidEmailException('Domaine email invalide');
    }
  }

  bool _passwordHasNoOuterWhitespace(String password) {
    return password.trim() == password;
  }

  bool _passwordHasLowercase(String password) {
    return RegExp(r'[a-z]').hasMatch(password);
  }

  bool _passwordHasUppercase(String password) {
    return RegExp(r'[A-Z]').hasMatch(password);
  }

  bool _passwordHasDigit(String password) {
    return RegExp(r'[0-9]').hasMatch(password);
  }

  bool _isPasswordValidForClient(String password) {
    // Match server default policy (>= 8 chars, no outer whitespace) and add
    // extra requirements requested by the user.
    return password.length >= 8 &&
        _passwordHasNoOuterWhitespace(password) &&
        _passwordHasDigit(password) &&
        _passwordHasUppercase(password) &&
        _passwordHasLowercase(password);
  }

  Widget _buildPasswordRule({
    required bool ok,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: ok ? AppTheme.accentGreen : AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: ok ? AppTheme.accentGreen : AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAuthenticatedAndCompleteProfile() async {
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
        EventReservationConfigResponse? evCfg;
        try {
          evCfg = await client.cinePass.getEventReservationConfig(
            pending.eventId!,
          );
        } catch (_) {}
        if (!mounted) return;
        reservationState.setEventReservation(
          eventId: pending.eventId!,
          eventTitle: pending.eventTitle!,
          eventLocation: pending.eventLocation!,
          eventDateTime: pending.eventDateTime!,
          quantity: pending.quantity,
          pricePerTicket: pending.eventPricePerTicket,
          availableOptions: pending.availableOptionsEvent,
          reservationConfig: evCfg,
        );
      }

      pending.clear();
      if (!mounted) return;
      context.go(AppRouter.reservationTypeBillet);
      return;
    }

    if (!mounted) return;
    context.go(AppRouter.home);
  }

  Future<void> _onGoogleAuthenticated() async {
    if (!mounted) return;
    await context.read<AuthState>().refreshProfileFromServer();
    if (!mounted) return;
    await _handlePostAuthRedirect();
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordUiController.text;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const CinePassLogo(size: LogoSize.medium),
            const SizedBox(height: 32),
            Text(
              'Inscription',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez votre compte avec email et mot de passe',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            const AuthModeTabs(activeTab: AuthModeTab.inscription),
            const SizedBox(height: 20),

            // --- Bloc auth (email + mot de passe + code) ---
            TextFormField(
              controller: _emailAuthController.emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'ex: prenom.nom@domaine.com',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordUiController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                hintText: 'Votre mot de passe',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              obscureText: true,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPasswordRule(
                    ok: password.length >= 8,
                    label: 'Au moins 8 caractères',
                  ),
                  _buildPasswordRule(
                    ok: _passwordHasUppercase(password),
                    label: 'Au moins 1 lettre majuscule',
                  ),
                  _buildPasswordRule(
                    ok: _passwordHasLowercase(password),
                    label: 'Au moins 1 lettre minuscule',
                  ),
                  _buildPasswordRule(
                    ok: _passwordHasDigit(password),
                    label: 'Au moins 1 chiffre',
                  ),
                  _buildPasswordRule(
                    ok: _passwordHasNoOuterWhitespace(password),
                    label: 'Pas d espaces au début/fin',
                  ),
                ],
              ),
            ),

            // Le code apparaît ensuite sur la même page.
            if (_emailAuthController.currentScreen ==
                EmailFlowScreen.verifyRegistration) ...[
              const SizedBox(height: 12),
              Text(
                'Entrez le code de vérification reçu par email',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailAuthController.verificationCodeController,
                decoration: InputDecoration(
                  labelText: 'Code de vérification',
                  hintText: 'XXXXXXXX',
                  prefixIcon: const Icon(Icons.verified_outlined),
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                ),
                style: const TextStyle(color: AppTheme.textPrimary),
                keyboardType: TextInputType.text,
              ),
            ],

            const SizedBox(height: 20),
            if (_emailAuthController.isLoading)
              const LinearProgressIndicator(color: AppTheme.primaryRed),

            const SizedBox(height: 12),
            FilledButton(
              onPressed: _emailAuthController.isLoading
                  ? null
                  : () async {
                      // Vérifie le mot de passe AVANT de lancer les étapes
                      // (sinon on obtient policyViolation au moment du finish).
                      if (_emailAuthController.currentScreen !=
                          EmailFlowScreen.completeRegistration) {
                        if (!_isPasswordValidForClient(
                          _passwordUiController.text,
                        )) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Mot de passe invalide. Ajoute 8+ caractères, 1 chiffre, 1 majuscule, 1 minuscule, sans espaces au début/fin.',
                              ),
                            ),
                          );
                          return;
                        }
                      }

                      switch (_emailAuthController.currentScreen) {
                        case EmailFlowScreen.startRegistration:
                          await _emailAuthController.startRegistration();
                          break;
                        case EmailFlowScreen.verifyRegistration:
                          final rawCode = _emailAuthController
                              .verificationCodeController
                              .text;
                          final normalizedCode = rawCode.trim().toLowerCase();
                          _emailAuthController.verificationCodeController.text =
                              normalizedCode;

                          if (normalizedCode.length != 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Code invalide : colle exactement 8 caractères (sans espaces).',
                                ),
                              ),
                            );
                            return;
                          }
                          await _emailAuthController.verifyRegistrationCode();
                          break;
                        case EmailFlowScreen.completeRegistration:
                          if (!_isPasswordValidForClient(
                            _passwordUiController.text,
                          )) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Mot de passe invalide. Corrige avant de valider.',
                                ),
                              ),
                            );
                            return;
                          }

                          // Le controller vide passwordController quand on arrive
                          // sur completeRegistration : on le copie au dernier moment.
                          _emailAuthController.passwordController.text =
                              _passwordUiController.text.trim();

                          await _emailAuthController.finishRegistration();
                          break;
                        default:
                          break;
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _emailAuthController.currentScreen ==
                        EmailFlowScreen.verifyRegistration
                    ? 'Valider le code et créer le compte'
                    : 'Créer le compte (code email)',
              ),
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
            const SizedBox(height: 16),
            GoogleSignInWidget(
              client: client,
              onAuthenticated: _onGoogleAuthenticated,
              onError: (error) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Connexion Google échouée: $error'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go(AppRouter.connexion),
              child: const Text("J'ai déjà un compte"),
            ),
          ],
        ),
      ),
    );
  }
}
