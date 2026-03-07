import 'package:cine_pass_server/src/generated/protocol.dart';
import 'package:cine_pass_server/src/services/paiement/paiement_method_class.dart';

class OrangeMoneyPayment implements PaiementMethodClass {
  @override
  Future<PaiementResult> pay({
    required Reservation reservation,
    required double amount,
  }) async {

    // logique API bancaire
    return PaiementResult(
      success: true,
      transactionId: "ORANGE_${DateTime.now().millisecondsSinceEpoch}",
      montantTotal: amount + 0.5, // exemple de frais de service
      message: "Paiement Orange Money réussi",
    );
  }
}