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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class ReservationConfirmResponse implements _i1.SerializableModel {
  ReservationConfirmResponse._({
    required this.success,
    required this.message,
    this.reservationNumber,
    required this.totalAmount,
    this.placementLabel,
  });

  factory ReservationConfirmResponse({
    required bool success,
    required String message,
    String? reservationNumber,
    required double totalAmount,
    String? placementLabel,
  }) = _ReservationConfirmResponseImpl;

  factory ReservationConfirmResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ReservationConfirmResponse(
      success: _i1.BoolJsonExtension.fromJson(jsonSerialization['success']),
      message: jsonSerialization['message'] as String,
      reservationNumber: jsonSerialization['reservationNumber'] as String?,
      totalAmount: (jsonSerialization['totalAmount'] as num).toDouble(),
      placementLabel: jsonSerialization['placementLabel'] as String?,
    );
  }

  bool success;

  String message;

  String? reservationNumber;

  double totalAmount;

  String? placementLabel;

  /// Returns a shallow copy of this [ReservationConfirmResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ReservationConfirmResponse copyWith({
    bool? success,
    String? message,
    String? reservationNumber,
    double? totalAmount,
    String? placementLabel,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReservationConfirmResponse',
      'success': success,
      'message': message,
      if (reservationNumber != null) 'reservationNumber': reservationNumber,
      'totalAmount': totalAmount,
      if (placementLabel != null) 'placementLabel': placementLabel,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReservationConfirmResponseImpl extends ReservationConfirmResponse {
  _ReservationConfirmResponseImpl({
    required bool success,
    required String message,
    String? reservationNumber,
    required double totalAmount,
    String? placementLabel,
  }) : super._(
         success: success,
         message: message,
         reservationNumber: reservationNumber,
         totalAmount: totalAmount,
         placementLabel: placementLabel,
       );

  /// Returns a shallow copy of this [ReservationConfirmResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ReservationConfirmResponse copyWith({
    bool? success,
    String? message,
    Object? reservationNumber = _Undefined,
    double? totalAmount,
    Object? placementLabel = _Undefined,
  }) {
    return ReservationConfirmResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      reservationNumber: reservationNumber is String?
          ? reservationNumber
          : this.reservationNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      placementLabel: placementLabel is String?
          ? placementLabel
          : this.placementLabel,
    );
  }
}
