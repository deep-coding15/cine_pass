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

abstract class EventSeatPlanEntryResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  EventSeatPlanEntryResponse._({
    required this.label,
    required this.rowIndex,
    required this.colIndex,
    required this.blocked,
    required this.taken,
    required this.zone,
  });

  factory EventSeatPlanEntryResponse({
    required String label,
    required int rowIndex,
    required int colIndex,
    required bool blocked,
    required bool taken,
    required String zone,
  }) = _EventSeatPlanEntryResponseImpl;

  factory EventSeatPlanEntryResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EventSeatPlanEntryResponse(
      label: jsonSerialization['label'] as String,
      rowIndex: jsonSerialization['rowIndex'] as int,
      colIndex: jsonSerialization['colIndex'] as int,
      blocked: _i1.BoolJsonExtension.fromJson(jsonSerialization['blocked']),
      taken: _i1.BoolJsonExtension.fromJson(jsonSerialization['taken']),
      zone: jsonSerialization['zone'] as String,
    );
  }

  String label;

  int rowIndex;

  int colIndex;

  bool blocked;

  bool taken;

  String zone;

  /// Returns a shallow copy of this [EventSeatPlanEntryResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EventSeatPlanEntryResponse copyWith({
    String? label,
    int? rowIndex,
    int? colIndex,
    bool? blocked,
    bool? taken,
    String? zone,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EventSeatPlanEntryResponse',
      'label': label,
      'rowIndex': rowIndex,
      'colIndex': colIndex,
      'blocked': blocked,
      'taken': taken,
      'zone': zone,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EventSeatPlanEntryResponse',
      'label': label,
      'rowIndex': rowIndex,
      'colIndex': colIndex,
      'blocked': blocked,
      'taken': taken,
      'zone': zone,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _EventSeatPlanEntryResponseImpl extends EventSeatPlanEntryResponse {
  _EventSeatPlanEntryResponseImpl({
    required String label,
    required int rowIndex,
    required int colIndex,
    required bool blocked,
    required bool taken,
    required String zone,
  }) : super._(
         label: label,
         rowIndex: rowIndex,
         colIndex: colIndex,
         blocked: blocked,
         taken: taken,
         zone: zone,
       );

  /// Returns a shallow copy of this [EventSeatPlanEntryResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EventSeatPlanEntryResponse copyWith({
    String? label,
    int? rowIndex,
    int? colIndex,
    bool? blocked,
    bool? taken,
    String? zone,
  }) {
    return EventSeatPlanEntryResponse(
      label: label ?? this.label,
      rowIndex: rowIndex ?? this.rowIndex,
      colIndex: colIndex ?? this.colIndex,
      blocked: blocked ?? this.blocked,
      taken: taken ?? this.taken,
      zone: zone ?? this.zone,
    );
  }
}
