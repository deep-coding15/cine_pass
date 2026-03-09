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
import 'package:cine_pass_client/src/protocol/protocol.dart' as _i3;

/// Séance (film + salle + créneau).
abstract class Seance extends _i1.CinePassRow implements _i2.SerializableModel {
  Seance._({
    _i2.UuidValue? id,
    super.createdAt,
    required this.filmId,
    required this.salleId,
    required this.debutAt,
    this.finAt,
    String? format,
    String? type,
    required this.prixBase,
    this.availableOptions,
  }) : id = id ?? const _i2.Uuid().v4obj(),
       format = format ?? 'VF',
       type = type ?? '2D';

  factory Seance({
    _i2.UuidValue? id,
    DateTime? createdAt,
    required _i2.UuidValue filmId,
    required _i2.UuidValue salleId,
    required DateTime debutAt,
    DateTime? finAt,
    String? format,
    String? type,
    required double prixBase,
    List<String>? availableOptions,
  }) = _SeanceImpl;

  factory Seance.fromJson(Map<String, dynamic> jsonSerialization) {
    return Seance(
      id: jsonSerialization['id'] == null
          ? null
          : _i2.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      filmId: _i2.UuidValueJsonExtension.fromJson(jsonSerialization['filmId']),
      salleId: _i2.UuidValueJsonExtension.fromJson(
        jsonSerialization['salleId'],
      ),
      debutAt: _i2.DateTimeJsonExtension.fromJson(jsonSerialization['debutAt']),
      finAt: jsonSerialization['finAt'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['finAt']),
      format: jsonSerialization['format'] as String?,
      type: jsonSerialization['type'] as String?,
      prixBase: (jsonSerialization['prixBase'] as num).toDouble(),
      availableOptions: jsonSerialization['availableOptions'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(
              jsonSerialization['availableOptions'],
            ),
    );
  }

  /// The id of the object.
  _i2.UuidValue id;

  _i2.UuidValue filmId;

  _i2.UuidValue salleId;

  DateTime debutAt;

  DateTime? finAt;

  String format;

  String type;

  double prixBase;

  List<String>? availableOptions;

  /// Returns a shallow copy of this [Seance]
  /// with some or all fields replaced by the given arguments.
  @override
  @_i2.useResult
  Seance copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    _i2.UuidValue? filmId,
    _i2.UuidValue? salleId,
    DateTime? debutAt,
    DateTime? finAt,
    String? format,
    String? type,
    double? prixBase,
    List<String>? availableOptions,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Seance',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'filmId': filmId.toJson(),
      'salleId': salleId.toJson(),
      'debutAt': debutAt.toJson(),
      if (finAt != null) 'finAt': finAt?.toJson(),
      'format': format,
      'type': type,
      'prixBase': prixBase,
      if (availableOptions != null)
        'availableOptions': availableOptions?.toJson(),
    };
  }

  @override
  String toString() {
    return _i2.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SeanceImpl extends Seance {
  _SeanceImpl({
    _i2.UuidValue? id,
    DateTime? createdAt,
    required _i2.UuidValue filmId,
    required _i2.UuidValue salleId,
    required DateTime debutAt,
    DateTime? finAt,
    String? format,
    String? type,
    required double prixBase,
    List<String>? availableOptions,
  }) : super._(
         id: id,
         createdAt: createdAt,
         filmId: filmId,
         salleId: salleId,
         debutAt: debutAt,
         finAt: finAt,
         format: format,
         type: type,
         prixBase: prixBase,
         availableOptions: availableOptions,
       );

  /// Returns a shallow copy of this [Seance]
  /// with some or all fields replaced by the given arguments.
  @_i2.useResult
  @override
  Seance copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    _i2.UuidValue? filmId,
    _i2.UuidValue? salleId,
    DateTime? debutAt,
    Object? finAt = _Undefined,
    String? format,
    String? type,
    double? prixBase,
    Object? availableOptions = _Undefined,
  }) {
    return Seance(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      filmId: filmId ?? this.filmId,
      salleId: salleId ?? this.salleId,
      debutAt: debutAt ?? this.debutAt,
      finAt: finAt is DateTime? ? finAt : this.finAt,
      format: format ?? this.format,
      type: type ?? this.type,
      prixBase: prixBase ?? this.prixBase,
      availableOptions: availableOptions is List<String>?
          ? availableOptions
          : this.availableOptions?.map((e0) => e0).toList(),
    );
  }
}
