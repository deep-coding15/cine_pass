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

abstract class RapportCAResponse implements _i1.SerializableModel {
  RapportCAResponse._({
    required this.totalCA,
    required this.nbReservations,
  });

  factory RapportCAResponse({
    required double totalCA,
    required int nbReservations,
  }) = _RapportCAResponseImpl;

  factory RapportCAResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return RapportCAResponse(
      totalCA: (jsonSerialization['totalCA'] as num).toDouble(),
      nbReservations: jsonSerialization['nbReservations'] as int,
    );
  }

  double totalCA;

  int nbReservations;

  /// Returns a shallow copy of this [RapportCAResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RapportCAResponse copyWith({
    double? totalCA,
    int? nbReservations,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RapportCAResponse',
      'totalCA': totalCA,
      'nbReservations': nbReservations,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _RapportCAResponseImpl extends RapportCAResponse {
  _RapportCAResponseImpl({
    required double totalCA,
    required int nbReservations,
  }) : super._(
         totalCA: totalCA,
         nbReservations: nbReservations,
       );

  /// Returns a shallow copy of this [RapportCAResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RapportCAResponse copyWith({
    double? totalCA,
    int? nbReservations,
  }) {
    return RapportCAResponse(
      totalCA: totalCA ?? this.totalCA,
      nbReservations: nbReservations ?? this.nbReservations,
    );
  }
}
