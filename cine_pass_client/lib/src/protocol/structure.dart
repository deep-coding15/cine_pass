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

/// Structure (cinéma, salle, organisateur) — table gérée par le schéma SQL.
abstract class Structure implements _i1.SerializableModel {
  Structure._({
    _i1.UuidValue? id,
    required this.type,
    required this.name,
    required this.city,
    this.address,
    this.website,
    this.phone,
    this.cinemaId,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory Structure({
    _i1.UuidValue? id,
    required String type,
    required String name,
    required String city,
    String? address,
    String? website,
    String? phone,
    _i1.UuidValue? cinemaId,
  }) = _StructureImpl;

  factory Structure.fromJson(Map<String, dynamic> jsonSerialization) {
    return Structure(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      type: jsonSerialization['type'] as String,
      name: jsonSerialization['name'] as String,
      city: jsonSerialization['city'] as String,
      address: jsonSerialization['address'] as String?,
      website: jsonSerialization['website'] as String?,
      phone: jsonSerialization['phone'] as String?,
      cinemaId: jsonSerialization['cinemaId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['cinemaId']),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  String type;

  String name;

  String city;

  String? address;

  String? website;

  String? phone;

  _i1.UuidValue? cinemaId;

  /// Returns a shallow copy of this [Structure]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Structure copyWith({
    _i1.UuidValue? id,
    String? type,
    String? name,
    String? city,
    String? address,
    String? website,
    String? phone,
    _i1.UuidValue? cinemaId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Structure',
      'id': id.toJson(),
      'type': type,
      'name': name,
      'city': city,
      if (address != null) 'address': address,
      if (website != null) 'website': website,
      if (phone != null) 'phone': phone,
      if (cinemaId != null) 'cinemaId': cinemaId?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StructureImpl extends Structure {
  _StructureImpl({
    _i1.UuidValue? id,
    required String type,
    required String name,
    required String city,
    String? address,
    String? website,
    String? phone,
    _i1.UuidValue? cinemaId,
  }) : super._(
         id: id,
         type: type,
         name: name,
         city: city,
         address: address,
         website: website,
         phone: phone,
         cinemaId: cinemaId,
       );

  /// Returns a shallow copy of this [Structure]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Structure copyWith({
    _i1.UuidValue? id,
    String? type,
    String? name,
    String? city,
    Object? address = _Undefined,
    Object? website = _Undefined,
    Object? phone = _Undefined,
    Object? cinemaId = _Undefined,
  }) {
    return Structure(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      city: city ?? this.city,
      address: address is String? ? address : this.address,
      website: website is String? ? website : this.website,
      phone: phone is String? ? phone : this.phone,
      cinemaId: cinemaId is _i1.UuidValue? ? cinemaId : this.cinemaId,
    );
  }
}
