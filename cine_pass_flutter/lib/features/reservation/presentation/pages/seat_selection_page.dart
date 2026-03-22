import 'dart:math';

import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../main.dart';
import '../../data/reservation_state.dart';

class SeatSelectionPage extends StatefulWidget {
  const SeatSelectionPage({super.key});

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  static const _rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
  static const _seatsPerRow = 12;
  late List<List<SeatStatus>> _seats;
  final _random = Random();

  /// Pour résa film / événement AVEC_SIEGES avec N billets : siège par billet (index = billet).
  List<String?>? _assignedSeats;

  String? _loadedPlanEventId;
  bool _eventPlanLoading = false;
  String? _eventPlanError;
  EventSeatPlanResponse? _eventPlan;

  bool _eventAvecSieges(ReservationState s) =>
      s.isEvent && s.eventReservationConfig?.reservationMode == 'AVEC_SIEGES';

  Future<void> _loadEventSeatPlan(String eventId) async {
    setState(() {
      _eventPlanLoading = true;
      _eventPlanError = null;
      _eventPlan = null;
    });
    try {
      final p = await client.cinePass.getEventSeatPlan(eventId);
      if (!mounted) return;
      setState(() {
        _eventPlanLoading = false;
        _eventPlan = p;
        if (p == null) {
          _eventPlanError = 'Impossible de charger le plan de sièges.';
        } else if (p.seats.isEmpty) {
          _eventPlanError =
              'Aucun siège n’est défini. Le responsable doit configurer le plan.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _eventPlanLoading = false;
        _eventPlanError = '$e';
      });
    }
  }

  void _ensureEventPlanLoaded(ReservationState state) {
    final id = state.eventId;
    if (!_eventAvecSieges(state) || id == null) return;
    if (_loadedPlanEventId == id && (_eventPlan != null || _eventPlanError != null)) {
      return;
    }
    _loadedPlanEventId = id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadEventSeatPlan(id);
    });
  }

  @override
  void initState() {
    super.initState();
    _seats = List.generate(
      _rows.length,
      (r) => List.generate(
        _seatsPerRow,
        (s) {
          if (s == 3 || s == 8) return SeatStatus.aisle;
          return _random.nextDouble() > 0.5
              ? SeatStatus.available
              : SeatStatus.occupied;
        },
      ),
    );
  }

  String _seatId(int row, int col) => '${_rows[row]}${col + 1}';

  /// Sièges VIP (rangées A et B) — réservés aux billets VIP.
  static bool _isVipSeat(String row, int col) {
    return row == 'A' || row == 'B';
  }

  bool _isSeatOccupied(int row, int col) =>
      _seats[row][col] == SeatStatus.occupied ||
      _seats[row][col] == SeatStatus.aisle;

  void _toggleSeat(int row, int col) {
    final state = ReservationState.instance;
    if (_isSeatOccupied(row, col)) return;
    final seatId = _seatId(row, col);

    if ((state.filmTickets.isNotEmpty || _eventAvecSieges(state)) &&
        _assignedSeats != null) {
      final idx = _assignedSeats!.indexWhere((s) => s == seatId);
      setState(() {
        if (idx >= 0) {
          _assignedSeats![idx] = null;
        } else {
          final currentBillet = _assignedSeats!.indexWhere((s) => s == null);
          if (currentBillet >= 0 &&
              _canSelectSeatForBillet(row, col, currentBillet)) {
            _assignedSeats![currentBillet] = seatId;
          }
        }
        _syncAssignedToState();
      });
      return;
    }

    if (!_canSelectSeat(row, col)) return;
    final current = _seats[row][col];
    setState(() {
      _seats[row][col] = current == SeatStatus.selected
          ? SeatStatus.available
          : SeatStatus.selected;
    });
    _updateReservationState();
  }

  void _syncAssignedToState() {
    if (_assignedSeats == null) return;
    ReservationState.instance.setSelectedSeats(
      _assignedSeats!.map((s) => s ?? '').toList(),
    );
  }

  void _updateReservationState() {
    final selected = <String>[];
    for (var r = 0; r < _rows.length; r++) {
      for (var c = 0; c < _seatsPerRow; c++) {
        if (_seats[r][c] == SeatStatus.selected) {
          selected.add(_seatId(r, c));
        }
      }
    }
    ReservationState.instance.setSelectedSeats(selected);
  }

  /// Pour mode par billet : le siège (row,col) est-il sélectionnable pour le billet d'index i ?
  bool _canSelectSeatForBillet(int row, int col, int billetIndex) {
    final state = ReservationState.instance;
    if (billetIndex < 0 || billetIndex >= state.filmTickets.length) {
      return false;
    }
    final seatId = _seatId(row, col);
    if (_assignedSeats!.contains(seatId)) return false;
    final isVipSeat = _isVipSeat(_rows[row], col + 1);
    final billetIsVip = state.filmTickets[billetIndex].isVip;
    return isVipSeat == billetIsVip;
  }

  bool _canSelectEventPlanSeat(
    EventSeatPlanEntryResponse e,
    int billetIndex,
    ReservationState state,
  ) {
    if (e.taken || e.blocked) return false;
    if (_assignedSeats == null) return false;
    if (_assignedSeats!.contains(e.label)) return false;
    if (billetIndex < 0 || billetIndex >= state.eventTickets.length) {
      return false;
    }
    final z = e.zone.trim().toUpperCase();
    if (z.isEmpty) return true;
    return z ==
        state.eventTickets[billetIndex].eventTypeCode.trim().toUpperCase();
  }

  void _toggleEventPlanSeat(EventSeatPlanEntryResponse e) {
    final state = ReservationState.instance;
    if (_assignedSeats == null) return;
    if (e.taken || e.blocked) return;
    final idx = _assignedSeats!.indexWhere((s) => s == e.label);
    setState(() {
      if (idx >= 0) {
        _assignedSeats![idx] = null;
      } else {
        final bi = _assignedSeats!.indexWhere((s) => s == null);
        if (bi >= 0 && _canSelectEventPlanSeat(e, bi, state)) {
          _assignedSeats![bi] = e.label;
        }
      }
      _syncAssignedToState();
    });
  }

  bool _canSelectSeat(int row, int col) {
    if (_isSeatOccupied(row, col)) return false;
    final state = ReservationState.instance;
    if (!state.isEvent &&
        state.filmTickets.isNotEmpty &&
        _assignedSeats != null) {
      final seatId = _seatId(row, col);
      if (_assignedSeats!.contains(seatId)) return true;
      final currentBillet = _assignedSeats!.indexWhere((s) => s == null);
      if (currentBillet < 0) return false;
      return _canSelectSeatForBillet(row, col, currentBillet);
    }
    final isVip = _isVipSeat(_rows[row], col + 1);
    if (state.ticketType == 'vip') return isVip;
    return !isVip;
  }

  /// Index du billet assigné à ce siège (-1 si aucun).
  int _assignedBilletIndex(String seatId) {
    if (_assignedSeats == null) return -1;
    return _assignedSeats!.indexWhere((s) => s == seatId);
  }

  bool _isSeatSelectedByBillet(int row, int col) {
    final state = ReservationState.instance;
    final perBillet = !state.isEvent && state.filmTickets.isNotEmpty;
    if (!perBillet || _assignedSeats == null) {
      return _seats[row][col] == SeatStatus.selected;
    }
    return _assignedSeats!.contains(_seatId(row, col));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReservationState>();
    final eventAvec = _eventAvecSieges(state);

    if (state.isEvent) {
      if (state.eventId == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Aucune réservation en cours.',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(AppRouter.events),
                child: const Text('Voir les événements'),
              ),
            ],
          ),
        );
      }
      if (!eventAvec) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Cet événement ne propose pas la sélection de sièges.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(AppRouter.paiement),
                child: const Text('Aller au paiement'),
              ),
            ],
          ),
        );
      }

      if (state.eventTickets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Aucun billet dans la commande.',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(AppRouter.reservationTypeBillet),
                child: const Text('Retour'),
              ),
            ],
          ),
        );
      }

      // AVEC_SIEGES : le client ne choisit pas manuellement. Le serveur attribue
      // les sièges automatiquement à la confirmation à partir du plan.
      if (eventAvec) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sièges attribués automatiquement',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                'Vous n’avez rien à sélectionner. Au paiement, le serveur choisit les sièges restants selon la configuration.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(AppRouter.paiement),
                child: const Text('Continuer vers le paiement'),
              ),
            ],
          ),
        );
      }
    }

    if (!state.isEvent && state.filmTitle == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Aucune réservation en cours.',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go(AppRouter.films),
              child: const Text('Voir les films'),
            ),
          ],
        ),
      );
    }

    if (eventAvec && state.eventTickets.isNotEmpty) {
      if (_assignedSeats == null ||
          _assignedSeats!.length != state.eventTickets.length) {
        _assignedSeats = List.filled(state.eventTickets.length, null);
      }
    } else if (state.filmTickets.isNotEmpty) {
      if (_assignedSeats == null ||
          _assignedSeats!.length != state.filmTickets.length) {
        _assignedSeats = List.filled(state.filmTickets.length, null);
      }
    } else {
      _assignedSeats = null;
    }

    final currentBilletIndex = _assignedSeats != null
        ? _assignedSeats!.indexWhere((s) => s == null)
        : -1;
    final hasPerBilletMode = _assignedSeats != null &&
        (eventAvec
            ? state.eventTickets.isNotEmpty
            : state.filmTickets.isNotEmpty);
    final perBilletCount = eventAvec
        ? state.eventTickets.length
        : state.filmTickets.length;

    if (eventAvec) {
      _ensureEventPlanLoaded(state);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => context.go(AppRouter.reservationTypeBillet),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Retour',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Sélection des sièges',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (hasPerBilletMode) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      currentBilletIndex >= 0
                          ? eventAvec
                                ? 'Billet ${currentBilletIndex + 1}/${state.eventTickets.length} (${state.eventTickets[currentBilletIndex].eventTypeCode}) : choisissez un siège.'
                                : 'Billet ${currentBilletIndex + 1}/${state.filmTickets.length} (${state.filmTickets[currentBilletIndex].isVip ? 'VIP' : 'Normal'}) : choisissez un siège ${state.filmTickets[currentBilletIndex].isVip ? 'en zone VIP (rangées A-B)' : 'standard'}'
                          : 'Tous les billets ont un siège. Cliquez sur un siège pour modifier.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ] else if (!state.isEvent && state.filmTickets.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Sélectionnez ${state.filmTickets.length} siège(s)',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  )
                else if (eventAvec && state.eventTickets.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Sélectionnez ${state.eventTickets.length} siège(s)',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (eventAvec)
                  _buildEventPlanSection(state, currentBilletIndex)
                else ...[
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accentGreen, Colors.black],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Écran',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var r = 0; r < _rows.length; r++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  child: Text(
                                    _rows[r],
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (var c = 0; c < _seatsPerRow; c++) ...[
                                      _seatWidget(r, c),
                                      if (c < _seatsPerRow - 1)
                                        const SizedBox(width: 4),
                                    ],
                                  ],
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 20,
                                  child: Text(
                                    _rows[r],
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _legendItem('Disponible', SeatStatus.available),
                      const SizedBox(width: 24),
                      _legendItem('Sélectionné', SeatStatus.selected),
                      const SizedBox(width: 24),
                      _legendItem('Occupé', SeatStatus.occupied),
                      if (state.ticketType == 'vip') ...[
                        const SizedBox(width: 24),
                        _legendItem('VIP', SeatStatus.vip),
                      ] else ...[
                        const SizedBox(width: 24),
                        _legendItem('Siège VIP', SeatStatus.vip),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 320,
            child: Card(
              color: AppTheme.cardDark,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Récapitulatif',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (eventAvec) ...[
                      _recapRow('Événement', state.eventTitle ?? '-'),
                      _recapRow('Lieu', state.eventLocation ?? ''),
                      _recapRow('Date', state.eventDateTime ?? ''),
                    ] else ...[
                      _recapRow('Film', state.filmTitle ?? '-'),
                      _recapRow(
                        'Cinéma',
                        '${state.cinemaName ?? ''}\n${state.cinemaLocation ?? ''}',
                      ),
                      _recapRow('Date et heure', state.dateTime ?? ''),
                    ],
                    const Divider(color: AppTheme.textSecondary, height: 24),
                    if (hasPerBilletMode && _assignedSeats != null) ...[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Sièges par billet',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      ...List.generate(perBilletCount, (i) {
                        final seat = _assignedSeats![i];
                        final type = eventAvec
                            ? state.eventTickets[i].eventTypeCode
                            : (state.filmTickets[i].isVip ? 'VIP' : 'Normal');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Text(
                                'Billet ${i + 1} ($type): ',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                seat ?? '—',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ] else
                      _recapRow(
                        'Sièges sélectionnés',
                        state.selectedSeats.isEmpty
                            ? 'Aucun siège sélectionné'
                            : state.selectedSeats.where((s) => s.isNotEmpty).join(', '),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: ${(eventAvec ? state.totalEvent : state.totalFilm).toStringAsFixed(2)} MAD',
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Builder(
                      builder: (context) {
                        final ok = perBilletCount > 0
                            ? state.selectedSeats.length ==
                                      perBilletCount &&
                                  !state.selectedSeats.any((s) => s.isEmpty)
                            : state.selectedSeats.any((s) => s.isNotEmpty);
                        return SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: ok
                                ? () => context.go(AppRouter.paiement)
                                : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primaryRed,
                            ),
                            child: Text(
                              perBilletCount > 0
                                  ? 'Continuer (${state.selectedSeats.where((s) => s.isNotEmpty).length}/$perBilletCount)'
                                  : 'Continuer',
                            ),
                          ),
                        );
                      },
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

  Widget _buildEventPlanSection(ReservationState state, int currentBilletIndex) {
    final childKey = _eventPlanLoading
        ? 'loading'
        : _eventPlanError != null
            ? 'error'
            : (_eventPlan == null || _eventPlan!.seats.isEmpty)
                ? 'empty'
                : 'ok';

    final Widget child;
    if (_eventPlanLoading) {
      child = const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.accentGreen),
        ),
      );
    } else if (_eventPlanError != null) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _eventPlanError!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              final id = state.eventId;
              if (id != null) _loadEventSeatPlan(id);
            },
            child: const Text('Réessayer'),
          ),
          TextButton(
            onPressed: () => context.go(AppRouter.reservationTypeBillet),
            child: const Text('Retour types de billets'),
          ),
        ],
      );
    } else {
      final plan = _eventPlan;
      if (plan == null || plan.seats.isEmpty) {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plan de sièges indisponible.',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            TextButton(
              onPressed: () =>
                  context.go(AppRouter.reservationTypeBillet),
              child: const Text('Retour'),
            ),
          ],
        );
      } else {
        final byRow = <int, List<EventSeatPlanEntryResponse>>{};
        for (final s in plan.seats) {
          byRow.putIfAbsent(s.rowIndex, () => []).add(s);
        }
        for (final list in byRow.values) {
          list.sort((a, b) => a.colIndex.compareTo(b.colIndex));
        }
        final rowKeys = byRow.keys.toList()..sort();

        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.accentGreen, Colors.black],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Scène',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Plan défini par l’organisateur (${plan.seats.length} sièges)',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final rk in rowKeys)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final e in byRow[rk]!)
                            _eventPlanSeatTile(
                              e,
                              state,
                              currentBilletIndex,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _legendItem('Disponible', SeatStatus.available),
                _legendItem('Sélectionné', SeatStatus.selected),
                _legendItem('Vendu', SeatStatus.occupied),
                _legendItem('Bloqué', SeatStatus.occupied),
                _legendItem('Zone restreinte', SeatStatus.vip),
              ],
            ),
          ],
        );
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (w, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1.0).animate(anim),
          child: w,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(childKey),
        child: child,
      ),
    );
  }

  Widget _eventPlanSeatTile(
    EventSeatPlanEntryResponse e,
    ReservationState state,
    int currentBilletIndex,
  ) {
    final isMine = _assignedSeats?.contains(e.label) ?? false;
    final billetNum =
        isMine && _assignedSeats != null ? _assignedBilletIndex(e.label) + 1 : null;
    final unavailable = e.taken || e.blocked;
    final bi =
        currentBilletIndex >= 0 ? currentBilletIndex : _assignedSeats?.indexWhere((s) => s == null) ?? -1;
    final canTap = !unavailable &&
        (isMine ||
            (bi >= 0 && _canSelectEventPlanSeat(e, bi, state)));
    final restrictedZone = e.zone.trim().isNotEmpty;

    return Tooltip(
      message: e.blocked
          ? 'Bloqué'
          : e.taken
              ? 'Déjà vendu'
              : (e.zone.isEmpty
                  ? 'Siège ${e.label}'
                  : 'Siège ${e.label} (zone ${e.zone})'),
      child: GestureDetector(
        onTap: canTap ? () => _toggleEventPlanSeat(e) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: unavailable
                ? AppTheme.surfaceDark
                : isMine
                    ? AppTheme.primaryRed
                    : (restrictedZone
                        ? AppTheme.primaryRed.withValues(alpha: 0.2)
                        : AppTheme.cardDark),
            border: Border.all(
              color: unavailable
                  ? AppTheme.textSecondary.withValues(alpha: 0.3)
                  : (restrictedZone
                      ? AppTheme.primaryRed
                      : AppTheme.textSecondary),
              width: restrictedZone ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                e.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: unavailable
                      ? AppTheme.textSecondary
                      : (isMine ? Colors.white : AppTheme.textPrimary),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (billetNum != null)
                Text(
                  '#$billetNum',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seatWidget(int row, int col) {
    final status = _seats[row][col];
    if (status == SeatStatus.aisle) {
      return const SizedBox(width: 28, height: 28);
    }
    final isOccupied = _isSeatOccupied(row, col);
    final isSelected = _isSeatSelectedByBillet(row, col);
    final isVip = _isVipSeat(_rows[row], col + 1);
    final canSelect = _canSelectSeat(row, col);
    final isDisabled = !canSelect && !isOccupied;
    final assignedBillet = isSelected && _assignedSeats != null
        ? _assignedBilletIndex(_seatId(row, col)) + 1
        : null;
    return GestureDetector(
      onTap: (isOccupied || isDisabled) ? null : () => _toggleSeat(row, col),
      child: Tooltip(
        message: assignedBillet != null
            ? 'Billet $assignedBillet'
            : (isVip ? 'Siège VIP' : 'Siège standard'),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isOccupied
                ? AppTheme.surfaceDark
                : isDisabled
                ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                : (isSelected
                      ? AppTheme.primaryRed
                      : (isVip
                            ? AppTheme.primaryRed.withValues(alpha: 0.25)
                            : AppTheme.cardDark)),
            border: isOccupied || isDisabled
                ? null
                : Border.all(
                    color: isVip ? AppTheme.primaryRed : AppTheme.textSecondary,
                    width: isVip ? 1.5 : 1,
                  ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: assignedBillet != null
              ? Center(
                  child: Text(
                    '$assignedBillet',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _legendItem(String label, SeatStatus status) {
    Color color;
    bool filled = true;
    if (status == SeatStatus.available) {
      color = AppTheme.cardDark;
      filled = false;
    } else if (status == SeatStatus.selected) {
      color = AppTheme.primaryRed;
    } else if (status == SeatStatus.vip) {
      color = AppTheme.primaryRed.withValues(alpha: 0.25);
    } else {
      color = AppTheme.surfaceDark;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: filled ? color : null,
            border: filled ? null : Border.all(color: AppTheme.textSecondary),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _recapRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

enum SeatStatus { available, selected, occupied, aisle, vip }
