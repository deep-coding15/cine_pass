import 'package:flutter/foundation.dart';

/// État des billets : annulations (pour affichage Mes billets).
class BilletsState extends ChangeNotifier {
  static BilletsState? _instance;
  static BilletsState get instance => _instance ??= BilletsState._();

  BilletsState._();

  final Set<String> _cancelledIds = {};
  final Map<String, int> _cancelledRefundPercent = {};

  bool isCancelled(String billetId) => _cancelledIds.contains(billetId);

  /// Pourcentage de remboursement au moment de l'annulation (0, 50, 80 ou 100).
  int? getRefundPercentWhenCancelled(String billetId) =>
      _cancelledRefundPercent[billetId];

  void cancel(String billetId, int refundPercent) {
    _cancelledIds.add(billetId);
    _cancelledRefundPercent[billetId] = refundPercent;
    notifyListeners();
  }

  void clearCancelled(String billetId) {
    _cancelledIds.remove(billetId);
    _cancelledRefundPercent.remove(billetId);
    notifyListeners();
  }
}
