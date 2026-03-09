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

/// Film (affichage programmation).
abstract class Film extends _i1.CinePassRow implements _i2.SerializableModel {
  Film._({
    _i2.UuidValue? id,
    super.createdAt,
    required this.titre,
    required this.genre,
    required this.dureeMinutes,
    this.synopsis,
    this.directeur,
    this.casting,
    this.posterColor,
    this.posterUrl,
    this.dateSortie,
    this.dateFin,
    this.audience,
    DateTime? updatedAt,
  }) : id = id ?? const _i2.Uuid().v4obj(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Film({
    _i2.UuidValue? id,
    DateTime? createdAt,
    required String titre,
    required String genre,
    required int dureeMinutes,
    String? synopsis,
    String? directeur,
    String? casting,
    int? posterColor,
    String? posterUrl,
    DateTime? dateSortie,
    DateTime? dateFin,
    String? audience,
    DateTime? updatedAt,
  }) = _FilmImpl;

  factory Film.fromJson(Map<String, dynamic> jsonSerialization) {
    return Film(
      id: jsonSerialization['id'] == null
          ? null
          : _i2.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      titre: jsonSerialization['titre'] as String,
      genre: jsonSerialization['genre'] as String,
      dureeMinutes: jsonSerialization['dureeMinutes'] as int,
      synopsis: jsonSerialization['synopsis'] as String?,
      directeur: jsonSerialization['directeur'] as String?,
      casting: jsonSerialization['casting'] as String?,
      posterColor: jsonSerialization['posterColor'] as int?,
      posterUrl: jsonSerialization['posterUrl'] as String?,
      dateSortie: jsonSerialization['dateSortie'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['dateSortie']),
      dateFin: jsonSerialization['dateFin'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['dateFin']),
      audience: jsonSerialization['audience'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i2.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The id of the object.
  _i2.UuidValue id;

  String titre;

  String genre;

  int dureeMinutes;

  String? synopsis;

  String? directeur;

  String? casting;

  int? posterColor;

  String? posterUrl;

  DateTime? dateSortie;

  DateTime? dateFin;

  String? audience;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Film]
  /// with some or all fields replaced by the given arguments.
  @override
  @_i2.useResult
  Film copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    String? titre,
    String? genre,
    int? dureeMinutes,
    String? synopsis,
    String? directeur,
    String? casting,
    int? posterColor,
    String? posterUrl,
    DateTime? dateSortie,
    DateTime? dateFin,
    String? audience,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Film',
      'id': id.toJson(),
      'createdAt': createdAt.toJson(),
      'titre': titre,
      'genre': genre,
      'dureeMinutes': dureeMinutes,
      if (synopsis != null) 'synopsis': synopsis,
      if (directeur != null) 'directeur': directeur,
      if (casting != null) 'casting': casting,
      if (posterColor != null) 'posterColor': posterColor,
      if (posterUrl != null) 'posterUrl': posterUrl,
      if (dateSortie != null) 'dateSortie': dateSortie?.toJson(),
      if (dateFin != null) 'dateFin': dateFin?.toJson(),
      if (audience != null) 'audience': audience,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i2.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FilmImpl extends Film {
  _FilmImpl({
    _i2.UuidValue? id,
    DateTime? createdAt,
    required String titre,
    required String genre,
    required int dureeMinutes,
    String? synopsis,
    String? directeur,
    String? casting,
    int? posterColor,
    String? posterUrl,
    DateTime? dateSortie,
    DateTime? dateFin,
    String? audience,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         createdAt: createdAt,
         titre: titre,
         genre: genre,
         dureeMinutes: dureeMinutes,
         synopsis: synopsis,
         directeur: directeur,
         casting: casting,
         posterColor: posterColor,
         posterUrl: posterUrl,
         dateSortie: dateSortie,
         dateFin: dateFin,
         audience: audience,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Film]
  /// with some or all fields replaced by the given arguments.
  @_i2.useResult
  @override
  Film copyWith({
    _i2.UuidValue? id,
    DateTime? createdAt,
    String? titre,
    String? genre,
    int? dureeMinutes,
    Object? synopsis = _Undefined,
    Object? directeur = _Undefined,
    Object? casting = _Undefined,
    Object? posterColor = _Undefined,
    Object? posterUrl = _Undefined,
    Object? dateSortie = _Undefined,
    Object? dateFin = _Undefined,
    Object? audience = _Undefined,
    DateTime? updatedAt,
  }) {
    return Film(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      titre: titre ?? this.titre,
      genre: genre ?? this.genre,
      dureeMinutes: dureeMinutes ?? this.dureeMinutes,
      synopsis: synopsis is String? ? synopsis : this.synopsis,
      directeur: directeur is String? ? directeur : this.directeur,
      casting: casting is String? ? casting : this.casting,
      posterColor: posterColor is int? ? posterColor : this.posterColor,
      posterUrl: posterUrl is String? ? posterUrl : this.posterUrl,
      dateSortie: dateSortie is DateTime? ? dateSortie : this.dateSortie,
      dateFin: dateFin is DateTime? ? dateFin : this.dateFin,
      audience: audience is String? ? audience : this.audience,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
