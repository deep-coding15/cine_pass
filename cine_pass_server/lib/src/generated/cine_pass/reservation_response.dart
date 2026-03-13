/* Generated - run "serverpod generate" to update. */
import 'package:serverpod/serverpod.dart' as _i1;

abstract class ReservationResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ReservationResponse._({
    required this.id,
    required this.numero,
    this.eventTitle,
    required this.totalAmount,
    required this.createdAtStr,
    required this.statut,
    required this.nbBillets,
  });

  factory ReservationResponse({
    required String id,
    required String numero,
    String? eventTitle,
    required double totalAmount,
    required String createdAtStr,
    required String statut,
    required int nbBillets,
  }) = _ReservationResponseImpl;

  factory ReservationResponse.fromJson(Map<String, dynamic> json) {
    return ReservationResponse(
      id: json['id'] as String,
      numero: json['numero'] as String,
      eventTitle: json['eventTitle'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAtStr: json['createdAtStr'] as String,
      statut: json['statut'] as String,
      nbBillets: json['nbBillets'] as int,
    );
  }

  String id;
  String numero;
  String? eventTitle;
  double totalAmount;
  String createdAtStr;
  String statut;
  int nbBillets;

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReservationResponse',
      'id': id,
      'numero': numero,
      if (eventTitle != null) 'eventTitle': eventTitle,
      'totalAmount': totalAmount,
      'createdAtStr': createdAtStr,
      'statut': statut,
      'nbBillets': nbBillets,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() => toJson();

  @override
  String toString() => _i1.SerializationManager.encode(this);
}

class _ReservationResponseImpl extends ReservationResponse {
  _ReservationResponseImpl({
    required String id,
    required String numero,
    String? eventTitle,
    required double totalAmount,
    required String createdAtStr,
    required String statut,
    required int nbBillets,
  }) : super._(
          id: id,
          numero: numero,
          eventTitle: eventTitle,
          totalAmount: totalAmount,
          createdAtStr: createdAtStr,
          statut: statut,
          nbBillets: nbBillets,
        );
}
