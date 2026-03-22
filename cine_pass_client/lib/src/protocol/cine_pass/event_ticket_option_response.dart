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

abstract class EventTicketOptionResponse implements _i1.SerializableModel {
  EventTicketOptionResponse._({
    required this.optionCode,
    required this.label,
    required this.price,
    required this.included,
    required this.active,
    required this.sortOrder,
  });

  factory EventTicketOptionResponse({
    required String optionCode,
    required String label,
    required double price,
    required bool included,
    required bool active,
    required int sortOrder,
  }) = _EventTicketOptionResponseImpl;

  factory EventTicketOptionResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EventTicketOptionResponse(
      optionCode: jsonSerialization['optionCode'] as String,
      label: jsonSerialization['label'] as String,
      price: (jsonSerialization['price'] as num).toDouble(),
      included: _i1.BoolJsonExtension.fromJson(jsonSerialization['included']),
      active: _i1.BoolJsonExtension.fromJson(jsonSerialization['active']),
      sortOrder: jsonSerialization['sortOrder'] as int,
    );
  }

  String optionCode;

  String label;

  double price;

  bool included;

  bool active;

  int sortOrder;

  /// Returns a shallow copy of this [EventTicketOptionResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EventTicketOptionResponse copyWith({
    String? optionCode,
    String? label,
    double? price,
    bool? included,
    bool? active,
    int? sortOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EventTicketOptionResponse',
      'optionCode': optionCode,
      'label': label,
      'price': price,
      'included': included,
      'active': active,
      'sortOrder': sortOrder,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _EventTicketOptionResponseImpl extends EventTicketOptionResponse {
  _EventTicketOptionResponseImpl({
    required String optionCode,
    required String label,
    required double price,
    required bool included,
    required bool active,
    required int sortOrder,
  }) : super._(
         optionCode: optionCode,
         label: label,
         price: price,
         included: included,
         active: active,
         sortOrder: sortOrder,
       );

  /// Returns a shallow copy of this [EventTicketOptionResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EventTicketOptionResponse copyWith({
    String? optionCode,
    String? label,
    double? price,
    bool? included,
    bool? active,
    int? sortOrder,
  }) {
    return EventTicketOptionResponse(
      optionCode: optionCode ?? this.optionCode,
      label: label ?? this.label,
      price: price ?? this.price,
      included: included ?? this.included,
      active: active ?? this.active,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
