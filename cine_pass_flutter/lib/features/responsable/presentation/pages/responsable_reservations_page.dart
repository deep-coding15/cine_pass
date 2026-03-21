import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

/// Réservations liées aux structures du responsable.
class ResponsableReservationsPage extends StatefulWidget {
  const ResponsableReservationsPage({super.key});

  @override
  State<ResponsableReservationsPage> createState() =>
      _ResponsableReservationsPageState();
}

class _ResponsableReservationsPageState
    extends State<ResponsableReservationsPage> {
  bool _loading = true;
  List<ReservationResponse> _reservations = [];
  final Map<String, List<ResponsableBilletResponse>> _billetsByReservation = {};
  final Set<String> _loadingBilletsFor = <String>{};

  // Règle métier responsable: uniquement scan et annulation.
  static const List<String> _allowedStatuses = [
    'checked_in',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await client.cinePass.getReservationsForMyStructures();
      if (!mounted) return;
      setState(() {
        _reservations = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reservations = [];
        _loading = false;
      });
    }
  }

  Future<void> _loadBillets(String reservationId) async {
    if (_loadingBilletsFor.contains(reservationId)) return;
    setState(() => _loadingBilletsFor.add(reservationId));
    try {
      final billets =
          await client.cinePass.getBilletsForReservationForMyStructures(reservationId);
      if (!mounted) return;
      setState(() {
        _billetsByReservation[reservationId] = billets;
      });
    } finally {
      if (mounted) {
        setState(() => _loadingBilletsFor.remove(reservationId));
      }
    }
  }

  String _prettyStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'checked_in':
        return 'Scanne (entree validee)';
      case 'cancelled':
        return 'Annule (remboursement)';
      case 'paid':
        return 'Paye';
      case 'refunded':
        return 'Rembourse';
      default:
        return raw;
    }
  }

  Future<void> _updateBilletStatus({
    required String reservationId,
    required ResponsableBilletResponse billet,
    required String nextStatus,
  }) async {
    final ok = await client.cinePass.updateBilletStatusForMyStructures(
      billetId: billet.id,
      statut: nextStatus,
    );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action refusee: seul scan/annulation est autorise.'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }

    final current = _billetsByReservation[reservationId] ?? const <ResponsableBilletResponse>[];
    setState(() {
      _billetsByReservation[reservationId] = current
          .map((b) => b.id == billet.id ? b.copyWith(statut: nextStatus) : b)
          .toList();
    });
  }

  Future<void> _updateReservationStatus({
    required ReservationResponse reservation,
    required String nextStatus,
  }) async {
    final ok = await client.cinePass.updateReservationStatusForMyStructures(
      reservationId: reservation.id,
      statut: nextStatus,
    );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action refusee: seul scan/annulation est autorise.'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }

    setState(() {
      _reservations = _reservations
          .map((r) => r.id == reservation.id ? r.copyWith(statut: nextStatus) : r)
          .toList();
      final currentBillets = _billetsByReservation[reservation.id];
      if (currentBillets != null) {
        _billetsByReservation[reservation.id] =
            currentBillets.map((b) => b.copyWith(statut: nextStatus)).toList();
      }
    });
  }

  Future<void> _showDetail(ReservationResponse r) async {
    await _loadBillets(r.id);
    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final reservation = _reservations.firstWhere(
            (item) => item.id == r.id,
            orElse: () => r,
          );
          final billets = _billetsByReservation[reservation.id] ??
              const <ResponsableBilletResponse>[];
          final isLoading = _loadingBilletsFor.contains(reservation.id);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Detail reservation',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(label: 'N° reservation', value: reservation.numero, highlight: true),
                    _DetailRow(label: 'Evenement', value: reservation.eventTitle ?? '-'),
                    _DetailRow(label: 'Date', value: reservation.createdAtStr),
                    _DetailRow(label: 'Billets', value: '${reservation.nbBillets}'),
                    _DetailRow(label: 'Total', value: '${reservation.totalAmount.toStringAsFixed(2)} EUR'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(
                          width: 130,
                          child: Text(
                            'Statut global',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ),
                        DropdownButton<String>(
                          value: _allowedStatuses.contains(reservation.statut)
                              ? reservation.statut
                              : 'checked_in',
                          dropdownColor: AppTheme.cardDark,
                          items: _allowedStatuses
                              .map(
                                (s) => DropdownMenuItem<String>(
                                  value: s,
                                  child: Text(_prettyStatus(s)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) async {
                            if (value == null || value == reservation.statut) return;
                            await _updateReservationStatus(
                              reservation: reservation,
                              nextStatus: value,
                            );
                            if (!mounted) return;
                            await _loadBillets(reservation.id);
                            if (!mounted) return;
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: AppTheme.textSecondary, height: 1),
                    const SizedBox(height: 12),
                    Text(
                      'Billets clients',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: AppTheme.accentGreen),
                            )
                          : billets.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Aucun billet trouve pour cette reservation.',
                                    style: TextStyle(color: AppTheme.textSecondary),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: billets.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                                  itemBuilder: (_, index) {
                                    final b = billets[index];
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceDark,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${b.ticketType.toUpperCase()}${b.seatLabel != null ? ' - ${b.seatLabel}' : ''}',
                                                  style: const TextStyle(
                                                    color: AppTheme.textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${b.prix.toStringAsFixed(2)} EUR',
                                                  style: const TextStyle(color: AppTheme.textSecondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                          DropdownButton<String>(
                                            value: _allowedStatuses.contains(b.statut)
                                                ? b.statut
                                                : 'checked_in',
                                            dropdownColor: AppTheme.cardDark,
                                            items: _allowedStatuses
                                                .map(
                                                  (s) => DropdownMenuItem<String>(
                                                    value: s,
                                                    child: Text(_prettyStatus(s)),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (value) async {
                                              if (value == null || value == b.statut) return;
                                              await _updateBilletStatus(
                                                reservationId: reservation.id,
                                                billet: b,
                                                nextStatus: value,
                                              );
                                              if (!mounted) return;
                                              await _loadBillets(reservation.id);
                                              if (!mounted) return;
                                              setModalState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reservations',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cliquez sur une reservation pour scanner/annuler les billets.',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.accentGreen),
            )
          else if (_reservations.isEmpty)
            const Card(
              color: AppTheme.cardDark,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Aucune reservation pour le moment.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reservations.length,
              itemBuilder: (context, index) {
                final r = _reservations[index];
                return Card(
                  color: AppTheme.cardDark,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _showDetail(r),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.numero,
                                  style: const TextStyle(
                                    color: AppTheme.accentGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${r.eventTitle ?? '-'} - ${r.totalAmount.toStringAsFixed(2)} EUR - ${_prettyStatus(r.statut)}',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: highlight ? AppTheme.accentGreen : AppTheme.textPrimary,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
