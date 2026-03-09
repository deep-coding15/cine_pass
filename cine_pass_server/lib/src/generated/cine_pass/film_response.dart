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

abstract class FilmResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  FilmResponse._({
    required this.id,
    required this.title,
    required this.genre,
    required this.durationMinutes,
    this.synopsis,
    this.director,
    this.casting,
    this.posterColor,
  });

  factory FilmResponse({
    required String id,
    required String title,
    required String genre,
    required int durationMinutes,
    String? synopsis,
    String? director,
    String? casting,
    int? posterColor,
  }) = _FilmResponseImpl;

  factory FilmResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return FilmResponse(
      id: jsonSerialization['id'] as String,
      title: jsonSerialization['title'] as String,
      genre: jsonSerialization['genre'] as String,
      durationMinutes: jsonSerialization['durationMinutes'] as int,
      synopsis: jsonSerialization['synopsis'] as String?,
      director: jsonSerialization['director'] as String?,
      casting: jsonSerialization['casting'] as String?,
      posterColor: jsonSerialization['posterColor'] as int?,
    );
  }

  String id;

  String title;

  String genre;

  int durationMinutes;

  String? synopsis;

  String? director;

  String? casting;

  int? posterColor;

  /// Returns a shallow copy of this [FilmResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FilmResponse copyWith({
    String? id,
    String? title,
    String? genre,
    int? durationMinutes,
    String? synopsis,
    String? director,
    String? casting,
    int? posterColor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FilmResponse',
      'id': id,
      'title': title,
      'genre': genre,
      'durationMinutes': durationMinutes,
      if (synopsis != null) 'synopsis': synopsis,
      if (director != null) 'director': director,
      if (casting != null) 'casting': casting,
      if (posterColor != null) 'posterColor': posterColor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FilmResponse',
      'id': id,
      'title': title,
      'genre': genre,
      'durationMinutes': durationMinutes,
      if (synopsis != null) 'synopsis': synopsis,
      if (director != null) 'director': director,
      if (casting != null) 'casting': casting,
      if (posterColor != null) 'posterColor': posterColor,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FilmResponseImpl extends FilmResponse {
  _FilmResponseImpl({
    required String id,
    required String title,
    required String genre,
    required int durationMinutes,
    String? synopsis,
    String? director,
    String? casting,
    int? posterColor,
  }) : super._(
         id: id,
         title: title,
         genre: genre,
         durationMinutes: durationMinutes,
         synopsis: synopsis,
         director: director,
         casting: casting,
         posterColor: posterColor,
       );

  /// Returns a shallow copy of this [FilmResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FilmResponse copyWith({
    String? id,
    String? title,
    String? genre,
    int? durationMinutes,
    Object? synopsis = _Undefined,
    Object? director = _Undefined,
    Object? casting = _Undefined,
    Object? posterColor = _Undefined,
  }) {
    return FilmResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      synopsis: synopsis is String? ? synopsis : this.synopsis,
      director: director is String? ? director : this.director,
      casting: casting is String? ? casting : this.casting,
      posterColor: posterColor is int? ? posterColor : this.posterColor,
    );
  }
}
