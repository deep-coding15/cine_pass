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
import '../cine_pass/reservation_quote_line_response.dart' as _i2;
import 'package:cine_pass_client/src/protocol/protocol.dart' as _i3;

abstract class ReservationQuoteResponse implements _i1.SerializableModel {
  ReservationQuoteResponse._({
    required this.eventId,
    required this.reservationMode,
    required this.available,
    required this.message,
    required this.totalAmount,
    required this.ticketCount,
    required this.lines,
  });

  factory ReservationQuoteResponse({
    required String eventId,
    required String reservationMode,
    required bool available,
    required String message,
    required double totalAmount,
    required int ticketCount,
    required List<_i2.ReservationQuoteLineResponse> lines,
  }) = _ReservationQuoteResponseImpl;

  factory ReservationQuoteResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ReservationQuoteResponse(
      eventId: jsonSerialization['eventId'] as String,
      reservationMode: jsonSerialization['reservationMode'] as String,
      available: _i1.BoolJsonExtension.fromJson(jsonSerialization['available']),
      message: jsonSerialization['message'] as String,
      totalAmount: (jsonSerialization['totalAmount'] as num).toDouble(),
      ticketCount: jsonSerialization['ticketCount'] as int,
      lines: _i3.Protocol().deserialize<List<_i2.ReservationQuoteLineResponse>>(
        jsonSerialization['lines'],
      ),
    );
  }

  String eventId;

  String reservationMode;

  bool available;

  String message;

  double totalAmount;

  int ticketCount;

  List<_i2.ReservationQuoteLineResponse> lines;

  /// Returns a shallow copy of this [ReservationQuoteResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ReservationQuoteResponse copyWith({
    String? eventId,
    String? reservationMode,
    bool? available,
    String? message,
    double? totalAmount,
    int? ticketCount,
    List<_i2.ReservationQuoteLineResponse>? lines,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReservationQuoteResponse',
      'eventId': eventId,
      'reservationMode': reservationMode,
      'available': available,
      'message': message,
      'totalAmount': totalAmount,
      'ticketCount': ticketCount,
      'lines': lines.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ReservationQuoteResponseImpl extends ReservationQuoteResponse {
  _ReservationQuoteResponseImpl({
    required String eventId,
    required String reservationMode,
    required bool available,
    required String message,
    required double totalAmount,
    required int ticketCount,
    required List<_i2.ReservationQuoteLineResponse> lines,
  }) : super._(
         eventId: eventId,
         reservationMode: reservationMode,
         available: available,
         message: message,
         totalAmount: totalAmount,
         ticketCount: ticketCount,
         lines: lines,
       );

  /// Returns a shallow copy of this [ReservationQuoteResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ReservationQuoteResponse copyWith({
    String? eventId,
    String? reservationMode,
    bool? available,
    String? message,
    double? totalAmount,
    int? ticketCount,
    List<_i2.ReservationQuoteLineResponse>? lines,
  }) {
    return ReservationQuoteResponse(
      eventId: eventId ?? this.eventId,
      reservationMode: reservationMode ?? this.reservationMode,
      available: available ?? this.available,
      message: message ?? this.message,
      totalAmount: totalAmount ?? this.totalAmount,
      ticketCount: ticketCount ?? this.ticketCount,
      lines: lines ?? this.lines.map((e0) => e0.copyWith()).toList(),
    );
  }
}
