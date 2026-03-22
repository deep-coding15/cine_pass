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
import '../cine_pass/event_ticket_option_response.dart' as _i2;
import 'package:cine_pass_client/src/protocol/protocol.dart' as _i3;

abstract class EventTicketTypeConfigResponse implements _i1.SerializableModel {
  EventTicketTypeConfigResponse._({
    required this.code,
    required this.label,
    required this.price,
    required this.quota,
    required this.soldCount,
    required this.remaining,
    required this.active,
    required this.sortOrder,
    required this.options,
  });

  factory EventTicketTypeConfigResponse({
    required String code,
    required String label,
    required double price,
    required int quota,
    required int soldCount,
    required int remaining,
    required bool active,
    required int sortOrder,
    required List<_i2.EventTicketOptionResponse> options,
  }) = _EventTicketTypeConfigResponseImpl;

  factory EventTicketTypeConfigResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EventTicketTypeConfigResponse(
      code: jsonSerialization['code'] as String,
      label: jsonSerialization['label'] as String,
      price: (jsonSerialization['price'] as num).toDouble(),
      quota: jsonSerialization['quota'] as int,
      soldCount: jsonSerialization['soldCount'] as int,
      remaining: jsonSerialization['remaining'] as int,
      active: _i1.BoolJsonExtension.fromJson(jsonSerialization['active']),
      sortOrder: jsonSerialization['sortOrder'] as int,
      options: _i3.Protocol().deserialize<List<_i2.EventTicketOptionResponse>>(
        jsonSerialization['options'],
      ),
    );
  }

  String code;

  String label;

  double price;

  int quota;

  int soldCount;

  int remaining;

  bool active;

  int sortOrder;

  List<_i2.EventTicketOptionResponse> options;

  /// Returns a shallow copy of this [EventTicketTypeConfigResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EventTicketTypeConfigResponse copyWith({
    String? code,
    String? label,
    double? price,
    int? quota,
    int? soldCount,
    int? remaining,
    bool? active,
    int? sortOrder,
    List<_i2.EventTicketOptionResponse>? options,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EventTicketTypeConfigResponse',
      'code': code,
      'label': label,
      'price': price,
      'quota': quota,
      'soldCount': soldCount,
      'remaining': remaining,
      'active': active,
      'sortOrder': sortOrder,
      'options': options.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _EventTicketTypeConfigResponseImpl extends EventTicketTypeConfigResponse {
  _EventTicketTypeConfigResponseImpl({
    required String code,
    required String label,
    required double price,
    required int quota,
    required int soldCount,
    required int remaining,
    required bool active,
    required int sortOrder,
    required List<_i2.EventTicketOptionResponse> options,
  }) : super._(
         code: code,
         label: label,
         price: price,
         quota: quota,
         soldCount: soldCount,
         remaining: remaining,
         active: active,
         sortOrder: sortOrder,
         options: options,
       );

  /// Returns a shallow copy of this [EventTicketTypeConfigResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EventTicketTypeConfigResponse copyWith({
    String? code,
    String? label,
    double? price,
    int? quota,
    int? soldCount,
    int? remaining,
    bool? active,
    int? sortOrder,
    List<_i2.EventTicketOptionResponse>? options,
  }) {
    return EventTicketTypeConfigResponse(
      code: code ?? this.code,
      label: label ?? this.label,
      price: price ?? this.price,
      quota: quota ?? this.quota,
      soldCount: soldCount ?? this.soldCount,
      remaining: remaining ?? this.remaining,
      active: active ?? this.active,
      sortOrder: sortOrder ?? this.sortOrder,
      options: options ?? this.options.map((e0) => e0.copyWith()).toList(),
    );
  }
}
