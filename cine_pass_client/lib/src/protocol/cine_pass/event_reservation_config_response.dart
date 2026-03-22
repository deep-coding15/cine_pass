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
import '../cine_pass/event_ticket_type_config_response.dart' as _i2;
import 'package:cine_pass_client/src/protocol/protocol.dart' as _i3;

abstract class EventReservationConfigResponse implements _i1.SerializableModel {
  EventReservationConfigResponse._({
    required this.eventId,
    required this.reservationMode,
    required this.maxTicketsPerOrder,
    required this.adjacentBestEffort,
    required this.ticketTypes,
  });

  factory EventReservationConfigResponse({
    required String eventId,
    required String reservationMode,
    required int maxTicketsPerOrder,
    required bool adjacentBestEffort,
    required List<_i2.EventTicketTypeConfigResponse> ticketTypes,
  }) = _EventReservationConfigResponseImpl;

  factory EventReservationConfigResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EventReservationConfigResponse(
      eventId: jsonSerialization['eventId'] as String,
      reservationMode: jsonSerialization['reservationMode'] as String,
      maxTicketsPerOrder: jsonSerialization['maxTicketsPerOrder'] as int,
      adjacentBestEffort: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['adjacentBestEffort'],
      ),
      ticketTypes: _i3.Protocol()
          .deserialize<List<_i2.EventTicketTypeConfigResponse>>(
            jsonSerialization['ticketTypes'],
          ),
    );
  }

  String eventId;

  String reservationMode;

  int maxTicketsPerOrder;

  bool adjacentBestEffort;

  List<_i2.EventTicketTypeConfigResponse> ticketTypes;

  /// Returns a shallow copy of this [EventReservationConfigResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EventReservationConfigResponse copyWith({
    String? eventId,
    String? reservationMode,
    int? maxTicketsPerOrder,
    bool? adjacentBestEffort,
    List<_i2.EventTicketTypeConfigResponse>? ticketTypes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EventReservationConfigResponse',
      'eventId': eventId,
      'reservationMode': reservationMode,
      'maxTicketsPerOrder': maxTicketsPerOrder,
      'adjacentBestEffort': adjacentBestEffort,
      'ticketTypes': ticketTypes.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _EventReservationConfigResponseImpl
    extends EventReservationConfigResponse {
  _EventReservationConfigResponseImpl({
    required String eventId,
    required String reservationMode,
    required int maxTicketsPerOrder,
    required bool adjacentBestEffort,
    required List<_i2.EventTicketTypeConfigResponse> ticketTypes,
  }) : super._(
         eventId: eventId,
         reservationMode: reservationMode,
         maxTicketsPerOrder: maxTicketsPerOrder,
         adjacentBestEffort: adjacentBestEffort,
         ticketTypes: ticketTypes,
       );

  /// Returns a shallow copy of this [EventReservationConfigResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EventReservationConfigResponse copyWith({
    String? eventId,
    String? reservationMode,
    int? maxTicketsPerOrder,
    bool? adjacentBestEffort,
    List<_i2.EventTicketTypeConfigResponse>? ticketTypes,
  }) {
    return EventReservationConfigResponse(
      eventId: eventId ?? this.eventId,
      reservationMode: reservationMode ?? this.reservationMode,
      maxTicketsPerOrder: maxTicketsPerOrder ?? this.maxTicketsPerOrder,
      adjacentBestEffort: adjacentBestEffort ?? this.adjacentBestEffort,
      ticketTypes:
          ticketTypes ?? this.ticketTypes.map((e0) => e0.copyWith()).toList(),
    );
  }
}
