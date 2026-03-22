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

abstract class ReservationQuoteLineResponse implements _i1.SerializableModel {
  ReservationQuoteLineResponse._({
    required this.ticketTypeCode,
    required this.ticketTypeLabel,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.remainingAfterQuote,
  });

  factory ReservationQuoteLineResponse({
    required String ticketTypeCode,
    required String ticketTypeLabel,
    required int quantity,
    required double unitPrice,
    required double lineTotal,
    required int remainingAfterQuote,
  }) = _ReservationQuoteLineResponseImpl;

  factory ReservationQuoteLineResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ReservationQuoteLineResponse(
      ticketTypeCode: jsonSerialization['ticketTypeCode'] as String,
      ticketTypeLabel: jsonSerialization['ticketTypeLabel'] as String,
      quantity: jsonSerialization['quantity'] as int,
      unitPrice: (jsonSerialization['unitPrice'] as num).toDouble(),
      lineTotal: (jsonSerialization['lineTotal'] as num).toDouble(),
      remainingAfterQuote: jsonSerialization['remainingAfterQuote'] as int,
    );
  }

  String ticketTypeCode;

  String ticketTypeLabel;

  int quantity;

  double unitPrice;

  double lineTotal;

  int remainingAfterQuote;

  /// Returns a shallow copy of this [ReservationQuoteLineResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ReservationQuoteLineResponse copyWith({
    String? ticketTypeCode,
    String? ticketTypeLabel,
    int? quantity,
    double? unitPrice,
    double? lineTotal,
    int? remainingAfterQuote,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReservationQuoteLineResponse',
      'ticketTypeCode': ticketTypeCode,
      'ticketTypeLabel': ticketTypeLabel,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
      'remainingAfterQuote': remainingAfterQuote,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ReservationQuoteLineResponseImpl extends ReservationQuoteLineResponse {
  _ReservationQuoteLineResponseImpl({
    required String ticketTypeCode,
    required String ticketTypeLabel,
    required int quantity,
    required double unitPrice,
    required double lineTotal,
    required int remainingAfterQuote,
  }) : super._(
         ticketTypeCode: ticketTypeCode,
         ticketTypeLabel: ticketTypeLabel,
         quantity: quantity,
         unitPrice: unitPrice,
         lineTotal: lineTotal,
         remainingAfterQuote: remainingAfterQuote,
       );

  /// Returns a shallow copy of this [ReservationQuoteLineResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ReservationQuoteLineResponse copyWith({
    String? ticketTypeCode,
    String? ticketTypeLabel,
    int? quantity,
    double? unitPrice,
    double? lineTotal,
    int? remainingAfterQuote,
  }) {
    return ReservationQuoteLineResponse(
      ticketTypeCode: ticketTypeCode ?? this.ticketTypeCode,
      ticketTypeLabel: ticketTypeLabel ?? this.ticketTypeLabel,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      lineTotal: lineTotal ?? this.lineTotal,
      remainingAfterQuote: remainingAfterQuote ?? this.remainingAfterQuote,
    );
  }
}
