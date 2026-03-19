import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/state/pending_reservation_state.dart';
import '../../../../core/widgets/cinepass_logo.dart';
import '../../../../features/reservation/data/reservation_state.dart';
import '../../../../main.dart';

/// Inscription: email + mot de passe (auth) puis on complète tous les
/// champs de `cine_pass_user_profile` dans le même formulaire.
class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _displayNameController = TextEditingController();
  final _passwordUiController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();

  late final EmailAuthController _emailAuthController;

  bool _isCompletingProfile = false;

  @override
  void initState() {
    super.initState();

    _emailAuthController = EmailAuthController(
      client: client,
      startScreen: EmailFlowScreen.startRegistration,
      emailValidation: (email) => _validateEmail(email),
      onAuthenticated: () {
        // Callback synchrone imposé par le controller: on lance l'async en
        // best-effort.
        _onAuthenticatedAndCompleteProfile();
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

    // Rebuild when the auth controller changes screens (startRegistration,
    // verifyRegistration, etc). Sinon le bouton/les champs ne reflètent pas
    // l'état réel.
    _emailAuthController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailAuthController.dispose();
    _displayNameController.dispose();
    _passwordUiController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  String? _validateProfileFields() {
    final displayName = _displayNameController.text.trim();
    final phone = _phoneController.text.trim();
    final birthDate = _birthDateController.text.trim();

    if (displayName.isEmpty) return 'Nom affiché requis';
    if (phone.isEmpty) return 'Téléphone requis';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthDate)) {
      return 'Date de naissance au format AAAA-MM-JJ';
    }
    return null;
  }

  void _validateEmail(String email) {
    // "Domaine réel" : au minimum vérifier que le domaine est présent et
    // ressemble à un FQDN (pas juste "toto@localhost").
    final parts = email.split('@');
    if (parts.length != 2) {
      throw const InvalidEmailException('Email invalide');
    }
    final domain = parts[1].trim();
    if (domain.isEmpty || !domain.contains('.') || domain.endsWith('.')) {
      throw const InvalidEmailException('Domaine email invalide');
    }
    if (domain.split('.').last.length < 2) {
      throw const InvalidEmailException('Domaine email invalide');
    }
  }

  Future<void> _handlePostAuthRedirect(BuildContext context) async {
    final pending = context.read<PendingReservationState>();
    final reservationState = context.read<ReservationState>();

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

    // Après inscription, on redirige vers `profil` pour compléter
    // systématiquement les champs manquants/invalides.
    context.go(AppRouter.profil);
  }

  Future<void> _onAuthenticatedAndCompleteProfile() async {
    if (!mounted) return;
    final profileValidationError = _validateProfileFields();

    setState(() => _isCompletingProfile = true);
    try {
      final displayName = _displayNameController.text.trim();
      final phone = _phoneController.text.trim();
      final birthDateText = _birthDateController.text.trim();

      // Best-effort : on enregistre ce qui est valide,
      // puis on corrige le reste sur `profil`.
      final birthDateToSend =
          RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthDateText)
              ? birthDateText
              : null;

      await client.cinePass.updateProfile(
        displayName: displayName.isEmpty ? null : displayName,
        phone: phone.isEmpty ? null : phone,
        birthDate: birthDateToSend,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur profil: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCompletingProfile = false);
    }

    if (!mounted) return;

    if (profileValidationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileValidationError),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    await _handlePostAuthRedirect(context);
  }

  bool _isServerPasswordValid() {
    // Match server default policy for EmailIdpConfig:
    // - no leading/trailing whitespace
    // - at least 8 characters
    final password = _passwordUiController.text;
    return password.trim() == password && password.length >= 8;
  }

  @override
  Widget build(BuildContext context) {
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
              'Créez un compte et complétez votre profil (email + mot de passe)',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
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
              child: Text(
                'Mot de passe: au moins 8 caractères, sans espaces au début/à la fin.',
                style: TextStyle(
                  color: _isServerPasswordValid()
                      ? AppTheme.accentGreen
                      : AppTheme.textSecondary,
                  fontSize: 12,
                ),
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
                  hintText: 'XXXXXX',
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

            const SizedBox(height: 16),

            // --- Bloc profil (tous les champs visibles) ---
            TextFormField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: 'Nom affiché',
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
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Téléphone',
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
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _birthDateController,
              decoration: InputDecoration(
                labelText: 'Date de naissance (AAAA-MM-JJ)',
                hintText: '1990-01-31',
                prefixIcon: const Icon(Icons.calendar_today_rounded),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(color: AppTheme.textSecondary),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),

            const SizedBox(height: 20),
            if (_isCompletingProfile || _emailAuthController.isLoading)
              const LinearProgressIndicator(color: AppTheme.primaryRed),

            const SizedBox(height: 12),
            FilledButton(
              onPressed: _emailAuthController.isLoading
                  ? null
                  : () async {
                      if (!(_emailAuthController.currentScreen ==
                          EmailFlowScreen.completeRegistration)) {
                        // On ne valide pas la policy ici: le mot de passe est
                        // requis uniquement au moment du `finishRegistration`.
                      }

                      // "S'inscrire" = envoie du code, puis on valide le code.
                      // Pas d'écran séparé: tout reste sur cette page.
                      switch (_emailAuthController.currentScreen) {
                        case EmailFlowScreen.startRegistration:
                          await _emailAuthController.startRegistration();
                          break;
                        case EmailFlowScreen.verifyRegistration:
                          // Le code généré par Serverpod (défaut) fait 8
                          // caractères alphanumériques en minuscule.
                          final rawCode =
                              _emailAuthController.verificationCodeController.text;
                          final normalizedCode = rawCode.trim().toLowerCase();
                          _emailAuthController.verificationCodeController.text =
                              normalizedCode;

                          if (normalizedCode.length != 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Code invalide: tu dois coller exactement 8 caractères (sans espaces).',
                                ),
                              ),
                            );
                            return;
                          }
                          await _emailAuthController.verifyRegistrationCode();
                          break;
                        case EmailFlowScreen.completeRegistration:
                          final trimmedUiPassword =
                              _passwordUiController.text.trim();
                          // On copie dans le controller juste avant finishRegistration,
                          // car le controller le vide à l'étape `completeRegistration`.
                          _emailAuthController.passwordController.text =
                              trimmedUiPassword;

                          if (!_isServerPasswordValid()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Mot de passe invalide: minimum 8 caractères et pas d'espaces au début/fin.",
                                ),
                              ),
                            );
                            return;
                          }

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
          ],
        ),
      ),
    );
  }
}
