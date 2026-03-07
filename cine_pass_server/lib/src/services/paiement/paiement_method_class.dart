import 'package:cine_pass_server/src/generated/protocol.dart';
import 'package:cine_pass_server/src/services/paiement/paiement_factory.dart';

abstract class PaiementMethodClass {
  Future<PaiementResult> pay({
    required Reservation reservation,
    required double amount,
  });
}