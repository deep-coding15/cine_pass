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

abstract class EventSeanceResponse implements _i1.SerializableModel {
  EventSeanceResponse._({
    required this.id,
    required this.eventId,
    required this.dateStr,
    required this.timeStr,
    required this.lieu,
    required this.createdAtStr,
  });

  factory EventSeanceResponse({
    required String id,
    required String eventId,
    required String dateStr,
    required String timeStr,
    required String lieu,
    required String createdAtStr,
  }) = _EventSeanceResponseImpl;

  factory EventSeanceResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return EventSeanceResponse(
      id: jsonSerialization['id'] as String,
      eventId: jsonSerialization['eventId'] as String,
      dateStr: jsonSerialization['dateStr'] as String,
      timeStr: jsonSerialization['timeStr'] as String,
      lieu: jsonSerialization['lieu'] as String,
      createdAtStr: jsonSerialization['createdAtStr'] as String,
    );
  }

  String id;

  String eventId;

  String dateStr;

  String timeStr;

  String lieu;

  String createdAtStr;

  /// Returns a shallow copy of this [EventSeanceResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EventSeanceResponse copyWith({
    String? id,
    String? eventId,
    String? dateStr,
    String? timeStr,
    String? lieu,
    String? createdAtStr,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EventSeanceResponse',
      'id': id,
      'eventId': eventId,
      'dateStr': dateStr,
      'timeStr': timeStr,
      'lieu': lieu,
      'createdAtStr': createdAtStr,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _EventSeanceResponseImpl extends EventSeanceResponse {
  _EventSeanceResponseImpl({
    required String id,
    required String eventId,
    required String dateStr,
    required String timeStr,
    required String lieu,
    required String createdAtStr,
  }) : super._(
         id: id,
         eventId: eventId,
         dateStr: dateStr,
         timeStr: timeStr,
         lieu: lieu,
         createdAtStr: createdAtStr,
       );

  /// Returns a shallow copy of this [EventSeanceResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EventSeanceResponse copyWith({
    String? id,
    String? eventId,
    String? dateStr,
    String? timeStr,
    String? lieu,
    String? createdAtStr,
  }) {
    return EventSeanceResponse(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      dateStr: dateStr ?? this.dateStr,
      timeStr: timeStr ?? this.timeStr,
      lieu: lieu ?? this.lieu,
      createdAtStr: createdAtStr ?? this.createdAtStr,
    );
  }
}
