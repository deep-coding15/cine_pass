import 'package:cine_pass_server/src/services/paiement/bank_card_paiement.dart';
import 'package:cine_pass_server/src/services/paiement/orange_money_paiement.dart';
import 'package:cine_pass_server/src/services/paiement/paiement_method_class.dart';
import 'package:cine_pass_server/src/services/paiement/paypal_paiement.dart';
import 'package:cine_pass_server/src/services/paiement/stripe_paiement.dart';

class PaiementFactory {

  static PaiementMethodClass create(String type/* , PaiementStatut statut, double montant */) {

    switch (type.toLowerCase()) {
      case "bank":
        return BankCardPayment();

      case "orange_money":
        return OrangeMoneyPayment();

      case "paypal":
        return PaypalPayment();

      case "stripe":
        return StripePayment();

      default:
        throw Exception("Méthode de paiement non supportée");
    }
  }
}
