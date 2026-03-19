import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/billets_state.dart';
import '../../data/billets_cache_store.dart';
import '../../data/mock_billets_data.dart';
import '../../../../main.dart';

class _BilletsLoadResult {
  const _BilletsLoadResult({
    required this.items,
    required this.isOffline,
    this.networkError,
  });

  final List<BilletGroupResponse> items;
  final bool isOffline;
  final Object? networkError;
}

void _showQrFullScreen(BuildContext context, BilletGroupResponse billet) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => Navigator.of(ctx).pop(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QrImageView(
                    data: 'CINEPASS-${billet.id}',
                    version: QrVersions.auto,
                    size: 260,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    billet.title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scannez ce QR code à l\'entrée',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Appuyez n\'importe où pour fermer',
                    style: TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class BilletsPage extends StatefulWidget {
  const BilletsPage({super.key});

  @override
  State<BilletsPage> createState() => _BilletsPageState();
}

class _BilletsPageState extends State<BilletsPage> {
  late Future<_BilletsLoadResult> _future;
  final _cacheStore = BilletsCacheStore();

  @override
  void initState() {
    super.initState();
    _future = _loadBilletsWithOfflineFallback();
  }

  Future<_BilletsLoadResult> _loadBilletsWithOfflineFallback() async {
    try {
      final remote = await client.cinePass.getMyBillets();
      await _cacheStore.saveBillets(remote);
      return _BilletsLoadResult(items: remote, isOffline: false);
    } catch (e) {
      final cached = await _cacheStore.loadBillets();
      if (cached.isNotEmpty) {
        return _BilletsLoadResult(
          items: cached,
          isOffline: true,
          networkError: e,
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mes billets',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _future = _loadBilletsWithOfflineFallback()),
                tooltip: 'Rafraîchir',
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Un seul QR code par réservation : il permet d\'entrer avec tous les billets de la réservation.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          FutureBuilder<_BilletsLoadResult>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: CircularProgressIndicator(color: AppTheme.primaryRed),
                  ),
                );
              }
              if (snap.hasError) {
                return Text(
                  'Impossible de charger vos billets pour le moment. Connectez-vous a internet puis reessayez.',
                  style: const TextStyle(color: Colors.redAccent),
                );
              }

              final result = snap.data ??
                  const _BilletsLoadResult(items: [], isOffline: false);
              final list = result.items;

              if (list.isEmpty) {
                return const Text(
                  'Aucun billet pour le moment.',
                  style: TextStyle(color: AppTheme.textSecondary),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (result.isOffline)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mode hors ligne: affichage des billets enregistres localement (QR disponibles).',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ...list.map((b) => _BilletCard(billet: b)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BilletCard extends StatelessWidget {
  const _BilletCard({required this.billet});

  final BilletGroupResponse billet;

  @override
  Widget build(BuildContext context) {
    final billetsState = context.watch<BilletsState>();
    final cancelled = billetsState.isCancelled(billet.id);
    final canCancel =
        !cancelled && canCancelReservation(billet.sessionDateTime);
    final refundPercent = getRefundPercent(billet.sessionDateTime);
    final refundWhenCancelled = billetsState.getRefundPercentWhenCancelled(
      billet.id,
    );

    return Card(
      color: cancelled
          ? AppTheme.cardDark.withValues(alpha: 0.6)
          : AppTheme.cardDark,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          billet.title,
                          style: TextStyle(
                            color: cancelled
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (cancelled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Annulée',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Réservation #${billet.id}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          billet.location,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        billet.dateTime,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (billet.room != null && billet.room!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Salle : ${billet.room}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (billet.ticketTypes != null &&
                      billet.ticketTypes!.isNotEmpty) ...[
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        Text(
                          'Type : ',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        ...billet.ticketTypes!.asMap().entries.map((e) {
                          final isVip = e.value == 'VIP';
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isVip
                                  ? AppTheme.primaryRed.withValues(alpha: 0.2)
                                  : AppTheme.surfaceDark,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Billet ${e.key + 1} ${e.value}',
                              style: TextStyle(
                                color: isVip
                                    ? AppTheme.primaryRed
                                    : AppTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (billet.seats != null && billet.seats!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.event_seat_rounded,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Sièges : ',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        ...billet.seats!.map(
                          (s) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.primaryRed),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                color: AppTheme.primaryRed,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (billet.ticketCount != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${billet.ticketCount} billet(s)',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Montant total',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${billet.totalAmount.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          color: AppTheme.accentGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (cancelled && refundWhenCancelled != null) ...[
                    Text(
                      'Remboursement $refundWhenCancelled % (sous 5-10 jours)',
                      style: TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else if (canCancel) ...[
                    Text(
                      'Annulable : remboursement $refundPercent % si annulation maintenant',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        final percent = getRefundPercent(
                          billet.sessionDateTime,
                        );
                        billetsState.cancel(billet.id, percent);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Réservation annulée. Remboursement de $percent % sous 5-10 jours.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Annuler la réservation'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryRed,
                        side: const BorderSide(color: AppTheme.primaryRed),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else if (!cancelled &&
                      !canCancel &&
                      DateTime.now().isBefore(billet.sessionDateTime)) ...[
                    Text(
                      'Annulation non possible (moins de 2 h avant la séance)',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (!cancelled)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: AppTheme.accentGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Valide',
                          style: TextStyle(
                            color: AppTheme.accentGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            if (!cancelled)
              InkWell(
                onTap: () => _showQrFullScreen(context, billet),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: 'CINEPASS-${billet.id}',
                        version: QrVersions.auto,
                        size: 100,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Scannez à l\'entrée',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.touch_app_rounded,
                            size: 14,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                      if ((billet.seats != null && billet.seats!.length > 1) ||
                          (billet.ticketCount != null &&
                              billet.ticketCount! > 1)) ...[
                        const SizedBox(height: 4),
                        Text(
                          '1 QR code pour toute la réservation',
                          style: TextStyle(color: Colors.black54, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        'Appuyez pour agrandir',
                        style: TextStyle(color: Colors.black38, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cancel_rounded,
                      size: 48,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Annulée',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
