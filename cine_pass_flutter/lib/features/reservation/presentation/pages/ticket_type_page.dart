import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../main.dart';
import '../../data/reservation_state.dart';

/// Étape dédiée : choix du type de billet (Normal / VIP) et options, avant sièges (film) ou paiement (événement).
class TicketTypePage extends StatefulWidget {
  const TicketTypePage({super.key});

  @override
  State<TicketTypePage> createState() => _TicketTypePageState();
}

class _TicketTypePageState extends State<TicketTypePage> {
  bool _loadingEventConfig = false;

  /// null = pas encore chargé ; true/false seulement si mode AVEC_SIEGES.
  bool? _eventSeatPlanOk;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureEventConfig());
  }

  Future<void> _ensureEventConfig() async {
    final state = ReservationState.instance;
    if (!state.isEvent || state.eventId == null) return;
    setState(() => _loadingEventConfig = true);
    try {
      if (state.eventReservationConfig == null) {
        final cfg = await client.cinePass.getEventReservationConfig(
          state.eventId!,
        );
        if (cfg != null && mounted) {
          state.applyEventReservationConfig(cfg);
        }
      }
      if (!mounted) return;
      final cfg = state.eventReservationConfig;
      if (cfg?.reservationMode == 'AVEC_SIEGES') {
        final plan = await client.cinePass.getEventSeatPlan(state.eventId!);
        if (mounted) {
          setState(() {
            _eventSeatPlanOk = plan != null && plan.seats.isNotEmpty;
          });
        }
      } else {
        if (mounted) setState(() => _eventSeatPlanOk = null);
      }
    } finally {
      if (mounted) setState(() => _loadingEventConfig = false);
    }
  }

  bool _eventSeatFlowReady(ReservationState state) {
    if (!state.isEvent) return true;
    if (state.eventReservationConfig?.reservationMode != 'AVEC_SIEGES') {
      return true;
    }
    return _eventSeatPlanOk == true;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReservationState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              if (state.isEvent && state.eventId != null) {
                context.go(AppRouter.eventDetailPath(state.eventId!));
              } else if (state.filmId != null) {
                context.go(AppRouter.filmDetailPath(state.filmId!));
              } else {
                context.go(AppRouter.home);
              }
            },
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text('Retour', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Type de billet',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Choisissez votre formule et les options souhaitées',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          if (_loadingEventConfig)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(
                minHeight: 3,
                color: AppTheme.accentGreen,
              ),
            ),
          _RecapCard(state: state),
          const SizedBox(height: 28),
          if (state.isEvent &&
              state.eventReservationConfig != null &&
              state.eventReservationConfig!.ticketTypes.isNotEmpty) ...[
            Text(
              'Vos billets',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Choisissez le type pour chaque billet (selon la configuration de l’organisateur).',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...List.generate(state.eventTickets.length, (i) {
              final cfg = state.eventReservationConfig!;
              final activeTypes = cfg.ticketTypes
                  .where((t) => t.active)
                  .toList();
              final ticket = state.eventTickets[i];
              final selectedCode = ticket.eventTypeCode.toUpperCase();
              EventTicketTypeConfigResponse? currentType;
              for (final t in cfg.ticketTypes) {
                if (t.code.toUpperCase() == selectedCode) {
                  currentType = t;
                  break;
                }
              }
              return Card(
                color: AppTheme.cardDark,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Billet ${i + 1}',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: activeTypes.map((type) {
                          final selected =
                              selectedCode == type.code.toUpperCase();
                          final can =
                              selected ||
                              state.canAssignEventTicketType(i, type.code);
                          return ChoiceChip(
                            label: Text(
                              '${type.label} — ${type.price.toStringAsFixed(2)} MAD',
                              style: TextStyle(
                                fontSize: selected ? 13 : 12,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: selected
                                    ? AppTheme.textPrimary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                            selected: selected,
                            onSelected: (can || selected)
                                ? (_) =>
                                      state.setEventTicketTypeCode(i, type.code)
                                : null,
                            selectedColor: AppTheme.accentGreen.withValues(
                              alpha: 0.25,
                            ),
                            checkmarkColor: AppTheme.accentGreen,
                            disabledColor: AppTheme.surfaceDark,
                          );
                        }).toList(),
                      ),
                      if (currentType != null &&
                          currentType.options.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Options',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...currentType.options.where((o) => o.active).map((o) {
                          if (o.included) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 18,
                                    color: AppTheme.accentGreen,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Inclus : ${o.label}',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          final checked = ticket.eventPayantOptionCodes
                              .contains(o.optionCode.toUpperCase());
                          return CheckboxListTile(
                            value: checked,
                            onChanged: (v) => state.setEventTicketPayantOption(
                              i,
                              o.optionCode,
                              v ?? false,
                            ),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              '${o.label} (+${o.price.toStringAsFixed(2)} MAD)',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                            activeColor: AppTheme.primaryRed,
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ] else if (state.isEvent) ...[
            Text(
              'Vos billets',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez chaque billet puis choisissez Normal ou VIP. Cliquez sur un billet pour changer.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(state.eventTickets.length, (i) {
                final t = state.eventTickets[i];
                return _EventBilletCard(
                  index: i + 1,
                  isVip: t.isVip,
                  onTap: () => state.setEventTicketVip(i, !t.isVip),
                  priceNormal: state.eventPricePerTicket,
                  priceVip: state.eventPricePerTicket * 1.5,
                );
              }),
            ),
            const SizedBox(height: 24),
            Text(
              'Options supplémentaires (billets Normaux uniquement)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            ...state.eventTickets
                .asMap()
                .entries
                .where((e) => !e.value.isVip)
                .map((e) {
                  final i = e.key;
                  final t = e.value;
                  final opts = state.eventAvailableOptions;
                  return Card(
                    color: AppTheme.cardDark,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Billet ${i + 1} (Normal)',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (opts.contains('parking'))
                            _OptionTile(
                              icon: Icons.local_parking_rounded,
                              label: 'Parking',
                              price: '3,00 MAD',
                              value: t.optionParking,
                              onChanged: (v) =>
                                  state.setEventTicketOption(i, 'parking', v),
                            ),
                          if (opts.contains('popcorn'))
                            _OptionTile(
                              icon: Icons.lunch_dining_rounded,
                              label: 'Popcorn',
                              price: '5,00 MAD',
                              value: t.optionPopcorn,
                              onChanged: (v) =>
                                  state.setEventTicketOption(i, 'popcorn', v),
                            ),
                          if (opts.contains('boisson'))
                            _OptionTile(
                              icon: Icons.local_drink_rounded,
                              label: '1 boisson',
                              price: '2,00 MAD',
                              value: t.optionBoisson,
                              onChanged: (v) =>
                                  state.setEventTicketOption(i, 'boisson', v),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
            if (state.eventTickets.every((t) => t.isVip))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Tous vos billets sont VIP. Options incluses.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ),
          ] else if (state.filmTickets.isNotEmpty) ...[
            Text(
              'Vos billets',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez chaque billet puis choisissez Normal ou VIP. Cliquez sur un billet pour changer.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(state.filmTickets.length, (i) {
                final t = state.filmTickets[i];
                return _EventBilletCard(
                  index: i + 1,
                  isVip: t.isVip,
                  onTap: () => state.setFilmTicketVip(i, !t.isVip),
                  priceNormal: state.pricePerSeat,
                  priceVip: state.pricePerSeat * 1.5,
                );
              }),
            ),
            const SizedBox(height: 24),
            Text(
              'Options supplémentaires (billets Normaux uniquement)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            ...state.filmTickets
                .asMap()
                .entries
                .where((e) => !e.value.isVip)
                .map((e) {
                  final i = e.key;
                  final t = e.value;
                  final opts = state.seanceAvailableOptions;
                  return Card(
                    color: AppTheme.cardDark,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Billet ${i + 1} (Normal)',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (opts.contains('parking'))
                            _OptionTile(
                              icon: Icons.local_parking_rounded,
                              label: 'Parking',
                              price: '3,00 MAD',
                              value: t.optionParking,
                              onChanged: (v) =>
                                  state.setFilmTicketOption(i, 'parking', v),
                            ),
                          if (opts.contains('popcorn'))
                            _OptionTile(
                              icon: Icons.lunch_dining_rounded,
                              label: 'Popcorn',
                              price: '5,00 MAD',
                              value: t.optionPopcorn,
                              onChanged: (v) =>
                                  state.setFilmTicketOption(i, 'popcorn', v),
                            ),
                          if (opts.contains('boisson'))
                            _OptionTile(
                              icon: Icons.local_drink_rounded,
                              label: '1 boisson',
                              price: '2,00 MAD',
                              value: t.optionBoisson,
                              onChanged: (v) =>
                                  state.setFilmTicketOption(i, 'boisson', v),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
            if (state.filmTickets.every((t) => t.isVip))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Tous vos billets sont VIP. Options incluses.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ),
          ] else ...[
            Text(
              'Choisir une formule',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TicketTypeCard(
                    title: 'Normal',
                    description: 'Siège standard',
                    priceLabel:
                        '${state.pricePerSeat.toStringAsFixed(2)} MAD / place',
                    isSelected: state.ticketType == 'normal',
                    onTap: () => state.setTicketType('normal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TicketTypeCard(
                    title: 'VIP',
                    description:
                        'Siège confort, espace prioritaire. Inclut: parking, popcorn, siège prioritaire, 1 boisson offerte.',
                    priceLabel:
                        '${(state.pricePerSeat * 1.5).toStringAsFixed(2)} MAD / place',
                    isSelected: state.ticketType == 'vip',
                    onTap: () => state.setTicketType('vip'),
                    isVip: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              state.ticketType == 'vip'
                  ? 'Inclus dans votre formule VIP'
                  : 'Options supplémentaires',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            state.ticketType == 'vip'
                ? Card(
                    color: AppTheme.cardDark,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.accentGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Parking, popcorn, siège prioritaire et 1 boisson sont inclus dans le billet VIP.',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Card(
                    color: AppTheme.cardDark,
                    child: Column(
                      children: [
                        if (state.seanceAvailableOptions.contains(
                          'parking',
                        )) ...[
                          _OptionTile(
                            icon: Icons.local_parking_rounded,
                            label: 'Parking',
                            price: '3,00 MAD',
                            value: state.optionParking,
                            onChanged: (v) => state.setOptionParking(v),
                          ),
                          const Divider(height: 1, color: AppTheme.surfaceDark),
                        ],
                        if (state.seanceAvailableOptions.contains(
                          'popcorn',
                        )) ...[
                          _OptionTile(
                            icon: Icons.lunch_dining_rounded,
                            label: 'Popcorn',
                            price: '5,00 MAD',
                            value: state.optionPopcorn,
                            onChanged: (v) => state.setOptionPopcorn(v),
                          ),
                          const Divider(height: 1, color: AppTheme.surfaceDark),
                        ],
                        if (state.seanceAvailableOptions.contains('boisson'))
                          _OptionTile(
                            icon: Icons.local_drink_rounded,
                            label: '1 boisson gazeuse offerte',
                            price: '2,00 MAD',
                            value: state.optionBoisson,
                            onChanged: (v) => state.setOptionBoisson(v),
                          ),
                      ],
                    ),
                  ),
          ],
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total estimé',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(state.isEvent ? state.totalEvent : state.totalFilm).toStringAsFixed(2)} MAD',
                      style: TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: _loadingEventConfig
                    ? null
                    : () {
                        if (state.isEvent) {
                          final avecSieges =
                              state.eventReservationConfig?.reservationMode ==
                              'AVEC_SIEGES';
                          if (avecSieges && !_eventSeatFlowReady(state)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Configuration des places incomplète pour cet événement.',
                                ),
                              ),
                            );
                            return;
                          }
                          if (avecSieges) {
                            state.setSelectedSeats([]);
                          }
                          context.go(AppRouter.paiement);
                        } else {
                          context.go(AppRouter.reservationSieges);
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  state.isEvent
                      ? (state.eventReservationConfig?.reservationMode ==
                                'AVEC_SIEGES'
                            ? 'Continuer vers le paiement'
                            : 'Continuer vers le paiement')
                      : 'Choisir mes sièges',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Carte billet pour événement : icône billet, clic = Normal ↔ VIP, VIP = or.
class _EventBilletCard extends StatelessWidget {
  const _EventBilletCard({
    required this.index,
    required this.isVip,
    required this.onTap,
    required this.priceNormal,
    required this.priceVip,
  });

  final int index;
  final bool isVip;
  final VoidCallback onTap;
  final double priceNormal;
  final double priceVip;

  static const Color _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isVip ? _gold.withValues(alpha: 0.15) : AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isVip ? _gold : AppTheme.surfaceDark,
              width: isVip ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎫', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                'Billet $index',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isVip
                      ? _gold.withValues(alpha: 0.3)
                      : AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isVip ? 'VIP' : 'Normal',
                  style: TextStyle(
                    color: isVip ? _gold : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(isVip ? priceVip : priceNormal).toStringAsFixed(2)} MAD',
                style: TextStyle(
                  color: AppTheme.accentGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.state});

  final ReservationState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isEvent) ...[
              Text(
                state.eventTitle ?? '',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.eventLocation ?? ''} • ${state.eventDateTime ?? ''}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.eventQuantity} place(s)',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ] else ...[
              Text(
                state.filmTitle ?? '',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.cinemaName ?? ''} • ${state.room ?? ''}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.dateTime ?? '',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              if (state.filmTickets.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '${state.filmTickets.length} place(s)',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _TicketTypeCard extends StatelessWidget {
  const _TicketTypeCard({
    required this.title,
    required this.description,
    required this.priceLabel,
    required this.isSelected,
    required this.onTap,
    this.isVip = false,
  });

  final String title;
  final String description;
  final String priceLabel;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isVip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isVip ? AppTheme.primaryRed : AppTheme.accentGreen)
                  : AppTheme.surfaceDark,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isVip)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'VIP',
                    style: TextStyle(
                      color: AppTheme.primaryRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (isVip) const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                priceLabel,
                style: TextStyle(
                  color: AppTheme.accentGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.price,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String price;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Row(
        children: [
          Icon(icon, size: 22, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppTheme.textPrimary)),
          const Spacer(),
          Text(
            price,
            style: TextStyle(
              color: AppTheme.accentGreen,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      activeColor: AppTheme.primaryRed,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}
