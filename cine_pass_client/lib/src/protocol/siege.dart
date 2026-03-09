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

/// Siège dans une salle (plan de salle).
abstract class Siege implements _i1.SerializableModel {
  Siege._({
    _i1.UuidValue? id,
    required this.salleId,
    required this.rangee,
    required this.numero,
  }) : id = id ?? const _i1.Uuid().v4obj();

  factory Siege({
    _i1.UuidValue? id,
    required _i1.UuidValue salleId,
    required String rangee,
    required int numero,
  }) = _SiegeImpl;

  factory Siege.fromJson(Map<String, dynamic> jsonSerialization) {
    return Siege(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      salleId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['salleId'],
      ),
      rangee: jsonSerialization['rangee'] as String,
      numero: jsonSerialization['numero'] as int,
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue salleId;

  String rangee;

  int numero;

  /// Returns a shallow copy of this [Siege]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Siege copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? salleId,
    String? rangee,
    int? numero,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Siege',
      'id': id.toJson(),
      'salleId': salleId.toJson(),
      'rangee': rangee,
      'numero': numero,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _SiegeImpl extends Siege {
  _SiegeImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue salleId,
    required String rangee,
    required int numero,
  }) : super._(
         id: id,
         salleId: salleId,
         rangee: rangee,
         numero: numero,
       );

  /// Returns a shallow copy of this [Siege]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Siege copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? salleId,
    String? rangee,
    int? numero,
  }) {
    return Siege(
      id: id ?? this.id,
      salleId: salleId ?? this.salleId,
      rangee: rangee ?? this.rangee,
      numero: numero ?? this.numero,
    );
  }
}
