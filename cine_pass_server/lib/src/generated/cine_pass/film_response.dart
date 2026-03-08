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
  Map<String, dynamic> toJson() => toJsonForProtocol();
  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FilmResponse',
      'id': id,
      'title': title,
      'genre': genre,
      'durationMinutes': durationMinutes,
      'synopsis': synopsis,
      'director': director,
      'casting': casting,
      'posterColor': posterColor,
    };
  }
}

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

  @override
  FilmResponse copyWith({
    String? id,
    String? title,
    String? genre,
    int? durationMinutes,
    String? synopsis,
    String? director,
    String? casting,
    int? posterColor,
  }) {
    return FilmResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      synopsis: synopsis ?? this.synopsis,
      director: director ?? this.director,
      casting: casting ?? this.casting,
      posterColor: posterColor ?? this.posterColor,
    );
  }
}
