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

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  String? _errorMessage;

  void _validateEmail(String email) {
    // "Domaine réel" (simple) : le domaine doit contenir un point et un TLD >= 2.
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
              'Connexion',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              pending.hasPending
                  ? 'Connectez-vous pour poursuivre votre réservation'
                  : 'Connexion par email (mot de passe + reset) ou Google',
              style: TextStyle(
                color: pending.hasPending
                    ? AppTheme.primaryRed
                    : AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: pending.hasPending ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 24),
            EmailSignInWidget(
              client: client,
              startScreen: EmailFlowScreen.login,
              emailValidation: (email) => _validateEmail(email),
              onAuthenticated: () {
                // onAuthenticated attend un `void Function()`, on déclenche la
                // redirection sans bloquer l'UI.
                _handlePostAuthRedirect();
              },
              onError: (error) {
                if (!mounted) return;
                setState(() => _errorMessage = error.toString());
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pas encore de compte ? ',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                TextButton(
                  onPressed: () => context.go(AppRouter.inscription),
                  child: const Text("S'inscrire"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Connexion via Google',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            GoogleSignInWidget(
              client: client,
              onAuthenticated: _handlePostAuthRedirect,
              onError: (error) {
                if (!mounted) return;
                setState(() => _errorMessage = error.toString());
              },
            ),
          ],
        ),
      ),
    );
  }
}
