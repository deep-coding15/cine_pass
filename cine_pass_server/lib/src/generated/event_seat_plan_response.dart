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
import '../cine_pass/event_seat_plan_entry_response.dart' as _i2;
import 'package:cine_pass_server/src/generated/protocol.dart' as _i3;

abstract class EventSeatPlanResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  EventSeatPlanResponse._({
    required this.eventId,
    required this.reservationMode,
    required this.seats,
  });

  factory EventSeatPlanResponse({
    required String eventId,
    required String reservationMode,
    required List<_i2.EventSeatPlanEntryResponse> seats,
  }) = _EventSeatPlanResponseImpl;

  factory EventSeatPlanResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EventSeatPlanResponse(
      eventId: jsonSerialization['eventId'] as String,
      reservationMode: jsonSerialization['reservationMode'] as String,
      seats: _i3.Protocol().deserialize<List<_i2.EventSeatPlanEntryResponse>>(
        jsonSerialization['seats'],
      ),
    );
  }

  String eventId;

  String reservationMode;

  List<_i2.EventSeatPlanEntryResponse> seats;

  /// Returns a shallow copy of this [EventSeatPlanResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EventSeatPlanResponse copyWith({
    String? eventId,
    String? reservationMode,
    List<_i2.EventSeatPlanEntryResponse>? seats,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EventSeatPlanResponse',
      'eventId': eventId,
      'reservationMode': reservationMode,
      'seats': seats.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EventSeatPlanResponse',
      'eventId': eventId,
      'reservationMode': reservationMode,
      'seats': seats.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _EventSeatPlanResponseImpl extends EventSeatPlanResponse {
  _EventSeatPlanResponseImpl({
    required String eventId,
    required String reservationMode,
    required List<_i2.EventSeatPlanEntryResponse> seats,
  }) : super._(
         eventId: eventId,
         reservationMode: reservationMode,
         seats: seats,
       );

  /// Returns a shallow copy of this [EventSeatPlanResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EventSeatPlanResponse copyWith({
    String? eventId,
    String? reservationMode,
    List<_i2.EventSeatPlanEntryResponse>? seats,
  }) {
    return EventSeatPlanResponse(
      eventId: eventId ?? this.eventId,
      reservationMode: reservationMode ?? this.reservationMode,
      seats: seats ?? this.seats.map((e0) => e0.copyWith()).toList(),
    );
  }
}
