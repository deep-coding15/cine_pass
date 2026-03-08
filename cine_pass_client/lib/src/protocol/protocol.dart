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
import 'cine_pass/cinema_response.dart' as _i2;
import 'cine_pass/event_response.dart' as _i3;
import 'cine_pass/film_response.dart' as _i4;
import 'cine_pass/seance_response.dart' as _i5;
import 'cinema.dart' as _i6;
import 'evenement.dart' as _i7;
import 'film.dart' as _i8;
import 'seance.dart' as _i9;
import 'cine_pass_row.dart' as _i10;
import 'greetings/greeting.dart' as _i11;
import 'salle.dart' as _i12;
import 'siege.dart' as _i13;
import 'package:cine_pass_client/src/protocol/cine_pass/film_response.dart'
    as _i14;
import 'package:cine_pass_client/src/protocol/cine_pass/seance_response.dart'
    as _i15;
import 'package:cine_pass_client/src/protocol/cine_pass/cinema_response.dart'
    as _i16;
import 'package:cine_pass_client/src/protocol/cine_pass/event_response.dart'
    as _i17;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i18;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i19;
export 'cine_pass/cinema_response.dart';
export 'cine_pass/event_response.dart';
export 'cine_pass/film_response.dart';
export 'cine_pass/seance_response.dart';
export 'cinema.dart';
export 'evenement.dart';
export 'film.dart';
export 'seance.dart';
export 'cine_pass_row.dart';
export 'greetings/greeting.dart';
export 'salle.dart';
export 'siege.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.CinemaResponse) {
      return _i2.CinemaResponse.fromJson(data) as T;
    }
    if (t == _i3.EventResponse) {
      return _i3.EventResponse.fromJson(data) as T;
    }
    if (t == _i4.FilmResponse) {
      return _i4.FilmResponse.fromJson(data) as T;
    }
    if (t == _i5.SeanceResponse) {
      return _i5.SeanceResponse.fromJson(data) as T;
    }
    if (t == _i6.Cinema) {
      return _i6.Cinema.fromJson(data) as T;
    }
    if (t == _i7.Evenement) {
      return _i7.Evenement.fromJson(data) as T;
    }
    if (t == _i8.Film) {
      return _i8.Film.fromJson(data) as T;
    }
    if (t == _i9.Seance) {
      return _i9.Seance.fromJson(data) as T;
    }
    if (t == _i10.CinePassRow) {
      return _i10.CinePassRow.fromJson(data) as T;
    }
    if (t == _i11.Greeting) {
      return _i11.Greeting.fromJson(data) as T;
    }
    if (t == _i12.Salle) {
      return _i12.Salle.fromJson(data) as T;
    }
    if (t == _i13.Siege) {
      return _i13.Siege.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.CinemaResponse?>()) {
      return (data != null ? _i2.CinemaResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.EventResponse?>()) {
      return (data != null ? _i3.EventResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.FilmResponse?>()) {
      return (data != null ? _i4.FilmResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.SeanceResponse?>()) {
      return (data != null ? _i5.SeanceResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.Cinema?>()) {
      return (data != null ? _i6.Cinema.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Evenement?>()) {
      return (data != null ? _i7.Evenement.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Film?>()) {
      return (data != null ? _i8.Film.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Seance?>()) {
      return (data != null ? _i9.Seance.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.CinePassRow?>()) {
      return (data != null ? _i10.CinePassRow.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.Greeting?>()) {
      return (data != null ? _i11.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Salle?>()) {
      return (data != null ? _i12.Salle.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.Siege?>()) {
      return (data != null ? _i13.Siege.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i14.FilmResponse>) {
      return (data as List)
              .map((e) => deserialize<_i14.FilmResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i15.SeanceResponse>) {
      return (data as List)
              .map((e) => deserialize<_i15.SeanceResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i16.CinemaResponse>) {
      return (data as List)
              .map((e) => deserialize<_i16.CinemaResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i17.EventResponse>) {
      return (data as List)
              .map((e) => deserialize<_i17.EventResponse>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    try {
      return _i18.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i19.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.CinemaResponse => 'CinemaResponse',
      _i3.EventResponse => 'EventResponse',
      _i4.FilmResponse => 'FilmResponse',
      _i5.SeanceResponse => 'SeanceResponse',
      _i6.Cinema => 'Cinema',
      _i7.Evenement => 'Evenement',
      _i8.Film => 'Film',
      _i9.Seance => 'Seance',
      _i10.CinePassRow => 'CinePassRow',
      _i11.Greeting => 'Greeting',
      _i12.Salle => 'Salle',
      _i13.Siege => 'Siege',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('cine_pass.', '');
    }

    switch (data) {
      case _i2.CinemaResponse():
        return 'CinemaResponse';
      case _i3.EventResponse():
        return 'EventResponse';
      case _i4.FilmResponse():
        return 'FilmResponse';
      case _i5.SeanceResponse():
        return 'SeanceResponse';
      case _i6.Cinema():
        return 'Cinema';
      case _i7.Evenement():
        return 'Evenement';
      case _i8.Film():
        return 'Film';
      case _i9.Seance():
        return 'Seance';
      case _i10.CinePassRow():
        return 'CinePassRow';
      case _i11.Greeting():
        return 'Greeting';
      case _i12.Salle():
        return 'Salle';
      case _i13.Siege():
        return 'Siege';
    }
    className = _i18.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i19.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CinemaResponse') {
      return deserialize<_i2.CinemaResponse>(data['data']);
    }
    if (dataClassName == 'EventResponse') {
      return deserialize<_i3.EventResponse>(data['data']);
    }
    if (dataClassName == 'FilmResponse') {
      return deserialize<_i4.FilmResponse>(data['data']);
    }
    if (dataClassName == 'SeanceResponse') {
      return deserialize<_i5.SeanceResponse>(data['data']);
    }
    if (dataClassName == 'Cinema') {
      return deserialize<_i6.Cinema>(data['data']);
    }
    if (dataClassName == 'Evenement') {
      return deserialize<_i7.Evenement>(data['data']);
    }
    if (dataClassName == 'Film') {
      return deserialize<_i8.Film>(data['data']);
    }
    if (dataClassName == 'Seance') {
      return deserialize<_i9.Seance>(data['data']);
    }
    if (dataClassName == 'CinePassRow') {
      return deserialize<_i10.CinePassRow>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i11.Greeting>(data['data']);
    }
    if (dataClassName == 'Salle') {
      return deserialize<_i12.Salle>(data['data']);
    }
    if (dataClassName == 'Siege') {
      return deserialize<_i13.Siege>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i18.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i19.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i18.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i19.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
