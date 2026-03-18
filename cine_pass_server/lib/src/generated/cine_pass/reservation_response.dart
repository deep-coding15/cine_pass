/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
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

  factory ReservationResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReservationResponse(
      id: jsonSerialization['id'] as String,
      numero: jsonSerialization['numero'] as String,
      eventTitle: jsonSerialization['eventTitle'] as String?,
      totalAmount: (jsonSerialization['totalAmount'] as num).toDouble(),
      createdAtStr: jsonSerialization['createdAtStr'] as String,
      statut: jsonSerialization['statut'] as String,
      nbBillets: jsonSerialization['nbBillets'] as int,
    );
  }

  String id;

  String numero;

  String? eventTitle;

  double totalAmount;

  String createdAtStr;

  String statut;

  int nbBillets;

  /// Returns a shallow copy of this [ReservationResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ReservationResponse copyWith({
    String? id,
    String? numero,
    String? eventTitle,
    double? totalAmount,
    String? createdAtStr,
    String? statut,
    int? nbBillets,
  });
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
  Map<String, dynamic> toJsonForProtocol() {
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
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

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

  /// Returns a shallow copy of this [ReservationResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ReservationResponse copyWith({
    String? id,
    String? numero,
    Object? eventTitle = _Undefined,
    double? totalAmount,
    String? createdAtStr,
    String? statut,
    int? nbBillets,
  }) {
    return ReservationResponse(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      eventTitle: eventTitle is String? ? eventTitle : this.eventTitle,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAtStr: createdAtStr ?? this.createdAtStr,
      statut: statut ?? this.statut,
      nbBillets: nbBillets ?? this.nbBillets,
    );
  }
}
