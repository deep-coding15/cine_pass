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

abstract class ResponsableBilletResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ResponsableBilletResponse._({
    required this.id,
    required this.reservationId,
    required this.reservationNumero,
    this.eventTitle,
    required this.ticketType,
    this.seatLabel,
    required this.prix,
    required this.statut,
    required this.createdAtStr,
  });

  factory ResponsableBilletResponse({
    required String id,
    required String reservationId,
    required String reservationNumero,
    String? eventTitle,
    required String ticketType,
    String? seatLabel,
    required double prix,
    required String statut,
    required String createdAtStr,
  }) = _ResponsableBilletResponseImpl;

  factory ResponsableBilletResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ResponsableBilletResponse(
      id: jsonSerialization['id'] as String,
      reservationId: jsonSerialization['reservationId'] as String,
      reservationNumero: jsonSerialization['reservationNumero'] as String,
      eventTitle: jsonSerialization['eventTitle'] as String?,
      ticketType: jsonSerialization['ticketType'] as String,
      seatLabel: jsonSerialization['seatLabel'] as String?,
      prix: (jsonSerialization['prix'] as num).toDouble(),
      statut: jsonSerialization['statut'] as String,
      createdAtStr: jsonSerialization['createdAtStr'] as String,
    );
  }

  String id;

  String reservationId;

  String reservationNumero;

  String? eventTitle;

  String ticketType;

  String? seatLabel;

  double prix;

  String statut;

  String createdAtStr;

  /// Returns a shallow copy of this [ResponsableBilletResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ResponsableBilletResponse copyWith({
    String? id,
    String? reservationId,
    String? reservationNumero,
    String? eventTitle,
    String? ticketType,
    String? seatLabel,
    double? prix,
    String? statut,
    String? createdAtStr,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ResponsableBilletResponse',
      'id': id,
      'reservationId': reservationId,
      'reservationNumero': reservationNumero,
      if (eventTitle != null) 'eventTitle': eventTitle,
      'ticketType': ticketType,
      if (seatLabel != null) 'seatLabel': seatLabel,
      'prix': prix,
      'statut': statut,
      'createdAtStr': createdAtStr,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ResponsableBilletResponse',
      'id': id,
      'reservationId': reservationId,
      'reservationNumero': reservationNumero,
      if (eventTitle != null) 'eventTitle': eventTitle,
      'ticketType': ticketType,
      if (seatLabel != null) 'seatLabel': seatLabel,
      'prix': prix,
      'statut': statut,
      'createdAtStr': createdAtStr,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ResponsableBilletResponseImpl extends ResponsableBilletResponse {
  _ResponsableBilletResponseImpl({
    required String id,
    required String reservationId,
    required String reservationNumero,
    String? eventTitle,
    required String ticketType,
    String? seatLabel,
    required double prix,
    required String statut,
    required String createdAtStr,
  }) : super._(
         id: id,
         reservationId: reservationId,
         reservationNumero: reservationNumero,
         eventTitle: eventTitle,
         ticketType: ticketType,
         seatLabel: seatLabel,
         prix: prix,
         statut: statut,
         createdAtStr: createdAtStr,
       );

  /// Returns a shallow copy of this [ResponsableBilletResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ResponsableBilletResponse copyWith({
    String? id,
    String? reservationId,
    String? reservationNumero,
    Object? eventTitle = _Undefined,
    String? ticketType,
    Object? seatLabel = _Undefined,
    double? prix,
    String? statut,
    String? createdAtStr,
  }) {
    return ResponsableBilletResponse(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      reservationNumero: reservationNumero ?? this.reservationNumero,
      eventTitle: eventTitle is String? ? eventTitle : this.eventTitle,
      ticketType: ticketType ?? this.ticketType,
      seatLabel: seatLabel is String? ? seatLabel : this.seatLabel,
      prix: prix ?? this.prix,
      statut: statut ?? this.statut,
      createdAtStr: createdAtStr ?? this.createdAtStr,
    );
  }
}
