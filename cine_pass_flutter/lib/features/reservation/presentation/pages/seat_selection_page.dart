import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
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

  /// Pour résa film avec N billets : siège assigné par billet (index = billet, value = "A3", "C10", etc.)
  List<String?>? _assignedSeats;

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

    if (state.filmTickets.isNotEmpty && _assignedSeats != null) {
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
    final all = _assignedSeats!.whereType<String>().toList();
    ReservationState.instance.setSelectedSeats(all);
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
    if (state.filmTickets.isEmpty || _assignedSeats == null) {
      return _seats[row][col] == SeatStatus.selected;
    }
    return _assignedSeats!.contains(_seatId(row, col));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReservationState>();
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

    if (state.filmTickets.isNotEmpty &&
        (_assignedSeats == null ||
            _assignedSeats!.length != state.filmTickets.length)) {
      _assignedSeats = List.filled(state.filmTickets.length, null);
    } else if (state.filmTickets.isEmpty) {
      _assignedSeats = null;
    }

    final currentBilletIndex = _assignedSeats != null
        ? _assignedSeats!.indexWhere((s) => s == null)
        : -1;
    final hasPerBilletMode =
        state.filmTickets.isNotEmpty && _assignedSeats != null;

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
                          ? 'Billet ${currentBilletIndex + 1}/${state.filmTickets.length} (${state.filmTickets[currentBilletIndex].isVip ? 'VIP' : 'Normal'}) : choisissez un siège ${state.filmTickets[currentBilletIndex].isVip ? 'en zone VIP (rangées A-B)' : 'standard'}'
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
                  ),
                const SizedBox(height: 16),
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
                    _recapRow('Film', state.filmTitle ?? '-'),
                    _recapRow(
                      'Cinéma',
                      '${state.cinemaName ?? ''}\n${state.cinemaLocation ?? ''}',
                    ),
                    _recapRow('Date et heure', state.dateTime ?? ''),
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
                      ...List.generate(state.filmTickets.length, (i) {
                        final seat = _assignedSeats![i];
                        final type = state.filmTickets[i].isVip
                            ? 'VIP'
                            : 'Normal';
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
                            : state.selectedSeats.join(', '),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: ${state.totalFilm.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Builder(
                      builder: (context) {
                        final ok = state.filmTickets.isNotEmpty
                            ? state.selectedSeats.length ==
                                  state.filmTickets.length
                            : state.selectedSeats.isNotEmpty;
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
                              state.filmTickets.isNotEmpty
                                  ? 'Continuer (${state.selectedSeats.length}/${state.filmTickets.length})'
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
