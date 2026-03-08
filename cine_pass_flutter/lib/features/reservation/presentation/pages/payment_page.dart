import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../data/reservation_state.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _cardNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  double get _total {
    final state = ReservationState.instance;
    return state.isEvent ? state.totalEvent : state.totalFilm;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReservationState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    if (state.isEvent) {
                      context.go(AppRouter.reservationTypeBillet);
                    } else {
                      context.go(AppRouter.reservationSieges);
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Text('Retour', style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Paiement',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 24),
                Card(
                  color: AppTheme.cardDark,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.credit_card_rounded, color: AppTheme.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'Informations de paiement',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _cardNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Numéro de carte',
                            labelStyle: TextStyle(color: AppTheme.textSecondary),
                            hintText: '1234 5678 9012 3456',
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                          ),
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom sur la carte',
                            labelStyle: TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                          ),
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _expiryController,
                                decoration: const InputDecoration(
                                  labelText: 'Date d\'expiration',
                                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                                  hintText: 'MM/AA',
                                  filled: true,
                                  fillColor: AppTheme.surfaceDark,
                                ),
                                style: const TextStyle(color: AppTheme.textPrimary),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _cvvController,
                                decoration: const InputDecoration(
                                  labelText: 'CVV',
                                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                                  filled: true,
                                  fillColor: AppTheme.surfaceDark,
                                ),
                                style: const TextStyle(color: AppTheme.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              ReservationState.instance.setReservationNumber(
                                'BOOK-${DateTime.now().millisecondsSinceEpoch}',
                              );
                              context.go(AppRouter.confirmation);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primaryRed,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text('Confirmer le paiement de ${_total.toStringAsFixed(2)} €'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.lock_rounded, size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'Paiement sécurisé. Vos informations sont protégées.',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Note: Ceci est une démo. Aucun paiement réel ne sera effectué.',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 340,
            child: Card(
              color: AppTheme.cardDark,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Récapitulatif de la commande',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 20),
                    if (state.isEvent) ...[
                      _recapRow('Événement', state.eventTitle ?? ''),
                      _recapRow('Lieu', state.eventLocation ?? ''),
                      _recapRow('Date', state.eventDateTime ?? ''),
                      _recapRow('Nombre de billets', '${state.eventQuantity}'),
                      _recapRow('Détail', () {
                        final vip = state.eventTickets.where((t) => t.isVip).length;
                        final normal = state.eventTickets.length - vip;
                        if (vip == 0) return '$normal Normal';
                        if (normal == 0) return '$vip VIP';
                        return '$normal Normal, $vip VIP';
                      }()),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total (${state.eventQuantity} billet(s))',
                              style: const TextStyle(color: AppTheme.textSecondary)),
                          Text('${state.totalEvent.toStringAsFixed(2)} €', style: const TextStyle(color: AppTheme.textPrimary)),
                        ],
                      ),
                    ] else ...[
                      _recapRow('Film', state.filmTitle ?? ''),
                      _recapRow('Cinéma', '${state.cinemaName ?? ''}\n${state.cinemaLocation ?? ''}'),
                      _recapRow('Séance', state.dateTime ?? ''),
                      _recapRow('Sièges', state.selectedSeats.join(', ')),
                      if (state.filmTickets.isNotEmpty) ...[
                        _recapRow('Détail billets', () {
                          final vip = state.filmTickets.where((t) => t.isVip).length;
                          final normal = state.filmTickets.length - vip;
                          if (vip == 0) return '$normal Normal';
                          if (normal == 0) return '$vip VIP';
                          return '$normal Normal, $vip VIP';
                        }()),
                      ] else ...[
                        _recapRow('Formule', state.ticketType == 'vip' ? 'VIP' : 'Normal'),
                        if (state.ticketType == 'vip')
                          _recapRow('Options', 'Inclus (VIP)')
                        else if (state.optionParking || state.optionPopcorn || state.optionBoisson)
                          _recapRow('Options', [
                            if (state.optionParking) 'Parking',
                            if (state.optionPopcorn) 'Popcorn',
                            if (state.optionBoisson) '1 boisson offerte',
                          ].join(', ')),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            state.filmTickets.isNotEmpty
                                ? 'Total (${state.filmTickets.length} billet(s))'
                                : '${state.selectedSeats.length} x ${state.pricePerSeat.toStringAsFixed(2)} €',
                            style: const TextStyle(color: AppTheme.textSecondary)),
                          Text('${state.totalFilm.toStringAsFixed(2)} €', style: const TextStyle(color: AppTheme.textPrimary)),
                        ],
                      ),
                    ],
                    const Divider(color: AppTheme.textSecondary, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        Text(
                          '${_total.toStringAsFixed(2)} €',
                          style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recapRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
