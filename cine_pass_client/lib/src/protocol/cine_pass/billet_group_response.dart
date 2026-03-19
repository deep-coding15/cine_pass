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
import 'package:cine_pass_client/src/protocol/protocol.dart' as _i2;

abstract class BilletGroupResponse implements _i1.SerializableModel {
  BilletGroupResponse._({
    required this.id,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.totalAmount,
    this.seats,
    this.ticketCount,
    required this.isEvent,
    this.room,
    this.ticketTypes,
    required this.sessionDateTime,
  });

  factory BilletGroupResponse({
    required String id,
    required String title,
    required String location,
    required String dateTime,
    required double totalAmount,
    List<String>? seats,
    int? ticketCount,
    required bool isEvent,
    String? room,
    List<String>? ticketTypes,
    required DateTime sessionDateTime,
  }) = _BilletGroupResponseImpl;

  factory BilletGroupResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return BilletGroupResponse(
      id: jsonSerialization['id'] as String,
      title: jsonSerialization['title'] as String,
      location: jsonSerialization['location'] as String,
      dateTime: jsonSerialization['dateTime'] as String,
      totalAmount: (jsonSerialization['totalAmount'] as num).toDouble(),
      seats: jsonSerialization['seats'] == null
          ? null
          : _i2.Protocol().deserialize<List<String>>(
              jsonSerialization['seats'],
            ),
      ticketCount: jsonSerialization['ticketCount'] as int?,
      isEvent: _i1.BoolJsonExtension.fromJson(jsonSerialization['isEvent']),
      room: jsonSerialization['room'] as String?,
      ticketTypes: jsonSerialization['ticketTypes'] == null
          ? null
          : _i2.Protocol().deserialize<List<String>>(
              jsonSerialization['ticketTypes'],
            ),
      sessionDateTime: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['sessionDateTime'],
      ),
    );
  }

  String id;

  String title;

  String location;

  String dateTime;

  double totalAmount;

  List<String>? seats;

  int? ticketCount;

  bool isEvent;

  String? room;

  List<String>? ticketTypes;

  DateTime sessionDateTime;

  /// Returns a shallow copy of this [BilletGroupResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BilletGroupResponse copyWith({
    String? id,
    String? title,
    String? location,
    String? dateTime,
    double? totalAmount,
    List<String>? seats,
    int? ticketCount,
    bool? isEvent,
    String? room,
    List<String>? ticketTypes,
    DateTime? sessionDateTime,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BilletGroupResponse',
      'id': id,
      'title': title,
      'location': location,
      'dateTime': dateTime,
      'totalAmount': totalAmount,
      if (seats != null) 'seats': seats?.toJson(),
      if (ticketCount != null) 'ticketCount': ticketCount,
      'isEvent': isEvent,
      if (room != null) 'room': room,
      if (ticketTypes != null) 'ticketTypes': ticketTypes?.toJson(),
      'sessionDateTime': sessionDateTime.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BilletGroupResponseImpl extends BilletGroupResponse {
  _BilletGroupResponseImpl({
    required String id,
    required String title,
    required String location,
    required String dateTime,
    required double totalAmount,
    List<String>? seats,
    int? ticketCount,
    required bool isEvent,
    String? room,
    List<String>? ticketTypes,
    required DateTime sessionDateTime,
  }) : super._(
         id: id,
         title: title,
         location: location,
         dateTime: dateTime,
         totalAmount: totalAmount,
         seats: seats,
         ticketCount: ticketCount,
         isEvent: isEvent,
         room: room,
         ticketTypes: ticketTypes,
         sessionDateTime: sessionDateTime,
       );

  /// Returns a shallow copy of this [BilletGroupResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BilletGroupResponse copyWith({
    String? id,
    String? title,
    String? location,
    String? dateTime,
    double? totalAmount,
    Object? seats = _Undefined,
    Object? ticketCount = _Undefined,
    bool? isEvent,
    Object? room = _Undefined,
    Object? ticketTypes = _Undefined,
    DateTime? sessionDateTime,
  }) {
    return BilletGroupResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      totalAmount: totalAmount ?? this.totalAmount,
      seats: seats is List<String>?
          ? seats
          : this.seats?.map((e0) => e0).toList(),
      ticketCount: ticketCount is int? ? ticketCount : this.ticketCount,
      isEvent: isEvent ?? this.isEvent,
      room: room is String? ? room : this.room,
      ticketTypes: ticketTypes is List<String>?
          ? ticketTypes
          : this.ticketTypes?.map((e0) => e0).toList(),
      sessionDateTime: sessionDateTime ?? this.sessionDateTime,
    );
  }
}
