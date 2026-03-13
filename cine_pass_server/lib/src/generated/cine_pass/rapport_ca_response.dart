/* Generated - run "serverpod generate" to update. */
import 'package:serverpod/serverpod.dart' as _i1;

abstract class RapportCAResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  RapportCAResponse._({
    required this.totalCA,
    required this.nbReservations,
  });

  factory RapportCAResponse({
    required double totalCA,
    required int nbReservations,
  }) = _RapportCAResponseImpl;

  factory RapportCAResponse.fromJson(Map<String, dynamic> json) {
    return RapportCAResponse(
      totalCA: (json['totalCA'] as num).toDouble(),
      nbReservations: json['nbReservations'] as int,
    );
  }

  double totalCA;
  int nbReservations;

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RapportCAResponse',
      'totalCA': totalCA,
      'nbReservations': nbReservations,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() => toJson();

  @override
  String toString() => _i1.SerializationManager.encode(this);
}

class _RapportCAResponseImpl extends RapportCAResponse {
  _RapportCAResponseImpl({
    required double totalCA,
    required int nbReservations,
  }) : super._(totalCA: totalCA, nbReservations: nbReservations);
}
