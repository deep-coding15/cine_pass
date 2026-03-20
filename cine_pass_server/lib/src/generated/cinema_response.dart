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

abstract class CinemaResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  CinemaResponse._({
    required this.id,
    required this.name,
    required this.city,
    this.address,
  });

  factory CinemaResponse({
    required String id,
    required String name,
    required String city,
    String? address,
  }) = _CinemaResponseImpl;

  factory CinemaResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return CinemaResponse(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      city: jsonSerialization['city'] as String,
      address: jsonSerialization['address'] as String?,
    );
  }

  String id;

  String name;

  String city;

  String? address;

  /// Returns a shallow copy of this [CinemaResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CinemaResponse copyWith({
    String? id,
    String? name,
    String? city,
    String? address,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CinemaResponse',
      'id': id,
      'name': name,
      'city': city,
      if (address != null) 'address': address,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CinemaResponse',
      'id': id,
      'name': name,
      'city': city,
      if (address != null) 'address': address,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CinemaResponseImpl extends CinemaResponse {
  _CinemaResponseImpl({
    required String id,
    required String name,
    required String city,
    String? address,
  }) : super._(
         id: id,
         name: name,
         city: city,
         address: address,
       );

  /// Returns a shallow copy of this [CinemaResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CinemaResponse copyWith({
    String? id,
    String? name,
    String? city,
    Object? address = _Undefined,
  }) {
    return CinemaResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      address: address is String? ? address : this.address,
    );
  }
}
