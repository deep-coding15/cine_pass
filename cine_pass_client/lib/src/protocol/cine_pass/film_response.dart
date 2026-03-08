import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class FilmResponse implements _i1.SerializableModel {
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

  @override
  Map<String, dynamic> toJson() {
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
}
