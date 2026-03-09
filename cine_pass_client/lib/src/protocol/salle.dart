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

/// Salle d'un cinéma (pas de created_at dans le schéma).
abstract class Salle implements _i1.SerializableModel {
  Salle._({
    _i1.UuidValue? id,
    required this.cinemaId,
    required this.nom,
    required this.capacite,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory Salle({
    _i1.UuidValue? id,
    required _i1.UuidValue cinemaId,
    required String nom,
    required int capacite,
  }) = _SalleImpl;

  factory Salle.fromJson(Map<String, dynamic> jsonSerialization) {
    return Salle(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      cinemaId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['cinemaId'],
      ),
      nom: jsonSerialization['nom'] as String,
      capacite: jsonSerialization['capacite'] as int,
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue cinemaId;

  String nom;

  int capacite;

  /// Returns a shallow copy of this [Salle]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Salle copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? cinemaId,
    String? nom,
    int? capacite,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Salle',
      'id': id.toJson(),
      'cinemaId': cinemaId.toJson(),
      'nom': nom,
      'capacite': capacite,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _SalleImpl extends Salle {
  _SalleImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue cinemaId,
    required String nom,
    required int capacite,
  }) : super._(
         id: id,
         cinemaId: cinemaId,
         nom: nom,
         capacite: capacite,
       );

  /// Returns a shallow copy of this [Salle]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Salle copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? cinemaId,
    String? nom,
    int? capacite,
  }) {
    return Salle(
      id: id ?? this.id,
      cinemaId: cinemaId ?? this.cinemaId,
      nom: nom ?? this.nom,
      capacite: capacite ?? this.capacite,
    );
  }
}
