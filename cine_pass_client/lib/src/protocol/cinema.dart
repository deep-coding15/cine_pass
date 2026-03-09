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
import 'protocol.dart' as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;

/// Cinéma (lieu avec salles).
abstract class Cinema extends _i1.CinePassRow implements _i2.SerializableModel {
  Cinema._({
    _i2.UuidValue? id,
    super.createdAt,
    required this.nom,
    required this.ville,
    this.adresse,
    this.codePostal,
  }) : id = id ?? const _i2.Uuid().v4obj();

  factory Cinema({
    _i2.UuidValue? id,
    DateTime? createdAt,
    required String nom,
    required String ville,
    String? adresse,
    String? codePostal,
  }) = _CinemaImpl;

  factory Cinema.fromJson(Map<String, dynamic> jsonSerialization) {
    return Cinema(
      id: jsonSerialization['id'] == null
          ? null
          : _i2.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      nom: jsonSerialization['nom'] as String,
      ville: jsonSerialization['ville'] as String,
      adresse: jsonSerialization['adresse'] as String?,
      codePostal: jsonSerialization['codePostal'] as String?,
    );
  }

  /// The id of the object.
  _i2.UuidValue id;

  String nom;

  String ville;

  String? adresse;

  String? codePostal;

  /// Returns a shallow copy of this [Cinema]
  /// with some or all fields replaced by the given arguments.
  @override
  @_i2.useResult
  Cinema copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    String? nom,
    String? ville,
    String? adresse,
    String? codePostal,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Cinema',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'nom': nom,
      'ville': ville,
      if (adresse != null) 'adresse': adresse,
      if (codePostal != null) 'codePostal': codePostal,
    };
  }

  @override
  String toString() {
    return _i2.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CinemaImpl extends Cinema {
  _CinemaImpl({
    _i2.UuidValue? id,
    DateTime? createdAt,
    required String nom,
    required String ville,
    String? adresse,
    String? codePostal,
  }) : super._(
         id: id,
         createdAt: createdAt,
         nom: nom,
         ville: ville,
         adresse: adresse,
         codePostal: codePostal,
       );

  /// Returns a shallow copy of this [Cinema]
  /// with some or all fields replaced by the given arguments.
  @_i2.useResult
  @override
  Cinema copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    String? nom,
    String? ville,
    Object? adresse = _Undefined,
    Object? codePostal = _Undefined,
  }) {
    return Cinema(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      nom: nom ?? this.nom,
      ville: ville ?? this.ville,
      adresse: adresse is String? ? adresse : this.adresse,
      codePostal: codePostal is String? ? codePostal : this.codePostal,
    );
  }
}
