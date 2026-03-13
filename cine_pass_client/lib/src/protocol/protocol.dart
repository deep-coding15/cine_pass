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
import 'phone_auth_code.dart' as _i12;
import 'salle.dart' as _i13;
import 'siege.dart' as _i14;
import 'cine_pass/demande_responsable_response.dart' as _i3;
import 'cine_pass/event_response.dart' as _i4;
import 'cine_pass/film_response.dart' as _i5;
import 'cine_pass/seance_response.dart' as _i6;
import 'cinema.dart' as _i7;
import 'evenement.dart' as _i8;
import 'film.dart' as _i9;
import 'reclamation.dart' as _i10;
import 'seance.dart' as _i11;
import 'cine_pass_row.dart' as _i12;
import 'greetings/greeting.dart' as _i13;
import 'salle.dart' as _i14;
import 'siege.dart' as _i15;
import 'structure.dart' as _i16;
import 'package:cine_pass_client/src/protocol/cine_pass/film_response.dart'
    as _i15;
import 'package:cine_pass_client/src/protocol/cine_pass/seance_response.dart'
    as _i16;
import 'package:cine_pass_client/src/protocol/cine_pass/cinema_response.dart'
    as _i17;
    as _i17;
import 'package:cine_pass_client/src/protocol/cine_pass/seance_response.dart'
    as _i18;
import 'package:cine_pass_client/src/protocol/cine_pass/cinema_response.dart'
    as _i19;
import 'package:cine_pass_client/src/protocol/salle.dart' as _i20;
import 'package:cine_pass_client/src/protocol/cine_pass/event_response.dart'
    as _i18;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i19;
    as _i21;
import 'package:cine_pass_client/src/protocol/structure.dart' as _i22;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i23;
    as _i20;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i21;
    as _i24;
import 'cine_pass/reservation_response.dart' as _i25;
import 'cine_pass/rapport_ca_response.dart' as _i26;
export 'cine_pass/cinema_response.dart';
export 'cine_pass/demande_responsable_response.dart';
export 'cine_pass/reservation_response.dart';
export 'cine_pass/rapport_ca_response.dart';
export 'cine_pass/event_response.dart';
export 'cine_pass/film_response.dart';
export 'cine_pass/seance_response.dart';
export 'cinema.dart';
export 'evenement.dart';
export 'film.dart';
export 'reclamation.dart';
export 'seance.dart';
export 'cine_pass_row.dart';
export 'greetings/greeting.dart';
export 'phone_auth_code.dart';
export 'salle.dart';
export 'siege.dart';
export 'structure.dart';
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
    if (t == _i3.DemandeResponsableResponse) {
      return _i3.DemandeResponsableResponse.fromJson(data) as T;
    }
    if (t == _i25.ReservationResponse) {
      return _i25.ReservationResponse.fromJson(data) as T;
    }
    if (t == _i26.RapportCAResponse) {
      return _i26.RapportCAResponse.fromJson(data) as T;
    }
    if (t == _i4.EventResponse) {
      return _i4.EventResponse.fromJson(data) as T;
    }
    if (t == _i5.FilmResponse) {
      return _i5.FilmResponse.fromJson(data) as T;
    }
    if (t == _i6.SeanceResponse) {
      return _i6.SeanceResponse.fromJson(data) as T;
    }
    if (t == _i7.Cinema) {
      return _i7.Cinema.fromJson(data) as T;
    }
    if (t == _i8.Evenement) {
      return _i8.Evenement.fromJson(data) as T;
    }
    if (t == _i9.Film) {
      return _i9.Film.fromJson(data) as T;
    }
    if (t == _i10.Reclamation) {
      return _i10.Reclamation.fromJson(data) as T;
    }
    if (t == _i11.Seance) {
      return _i11.Seance.fromJson(data) as T;
    if (t == _i12.PhoneAuthCode) {
      return _i12.PhoneAuthCode.fromJson(data) as T;
    }
    if (t == _i13.Salle) {
      return _i13.Salle.fromJson(data) as T;
    }
    if (t == _i14.Siege) {
      return _i14.Siege.fromJson(data) as T;
    if (t == _i12.CinePassRow) {
      return _i12.CinePassRow.fromJson(data) as T;
    }
    if (t == _i13.Greeting) {
      return _i13.Greeting.fromJson(data) as T;
    }
    if (t == _i14.Salle) {
      return _i14.Salle.fromJson(data) as T;
    }
    if (t == _i15.Siege) {
      return _i15.Siege.fromJson(data) as T;
    }
    if (t == _i16.Structure) {
      return _i16.Structure.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.CinemaResponse?>()) {
      return (data != null ? _i2.CinemaResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.DemandeResponsableResponse?>()) {
      return (data != null
              ? _i3.DemandeResponsableResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i25.ReservationResponse?>()) {
      return (data != null ? _i25.ReservationResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i26.RapportCAResponse?>()) {
      return (data != null ? _i26.RapportCAResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.EventResponse?>()) {
      return (data != null ? _i4.EventResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.FilmResponse?>()) {
      return (data != null ? _i5.FilmResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.SeanceResponse?>()) {
      return (data != null ? _i6.SeanceResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Cinema?>()) {
      return (data != null ? _i7.Cinema.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Evenement?>()) {
      return (data != null ? _i8.Evenement.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Film?>()) {
      return (data != null ? _i9.Film.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Reclamation?>()) {
      return (data != null ? _i10.Reclamation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.PhoneAuthCode?>()) {
      return (data != null ? _i12.PhoneAuthCode.fromJson(data) : null) as T;
    if (t == _i1.getType<_i11.Seance?>()) {
      return (data != null ? _i11.Seance.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.Salle?>()) {
      return (data != null ? _i13.Salle.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.Siege?>()) {
      return (data != null ? _i14.Siege.fromJson(data) : null) as T;
    if (t == _i1.getType<_i12.CinePassRow?>()) {
      return (data != null ? _i12.CinePassRow.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.Greeting?>()) {
      return (data != null ? _i13.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.Salle?>()) {
      return (data != null ? _i14.Salle.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.Siege?>()) {
      return (data != null ? _i15.Siege.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.Structure?>()) {
      return (data != null ? _i16.Structure.fromJson(data) : null) as T;
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
    if (t == List<_i17.FilmResponse>) {
      return (data as List)
              .map((e) => deserialize<_i17.FilmResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i16.SeanceResponse>) {
      return (data as List)
              .map((e) => deserialize<_i16.SeanceResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i17.CinemaResponse>) {
      return (data as List)
              .map((e) => deserialize<_i17.CinemaResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i20.Salle>) {
      return (data as List).map((e) => deserialize<_i20.Salle>(e)).toList()
          as T;
    }
    if (t == List<_i21.EventResponse>) {
      return (data as List)
              .map((e) => deserialize<_i21.EventResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i3.DemandeResponsableResponse>) {
      return (data as List)
              .map((e) => deserialize<_i3.DemandeResponsableResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.ReservationResponse>) {
      return (data as List)
              .map((e) => deserialize<_i25.ReservationResponse>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i22.Structure>) {
      return (data as List).map((e) => deserialize<_i22.Structure>(e)).toList()
          as T;
    }
    try {
      return _i23.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i20.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i21.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.CinemaResponse => 'CinemaResponse',
      _i3.DemandeResponsableResponse => 'DemandeResponsableResponse',
      _i4.EventResponse => 'EventResponse',
      _i5.FilmResponse => 'FilmResponse',
      _i6.SeanceResponse => 'SeanceResponse',
      _i7.Cinema => 'Cinema',
      _i8.Evenement => 'Evenement',
      _i9.Film => 'Film',
      _i10.Reclamation => 'Reclamation',
      _i11.Seance => 'Seance',
      _i12.CinePassRow => 'CinePassRow',
      _i13.Greeting => 'Greeting',
      _i14.Salle => 'Salle',
      _i15.Siege => 'Siege',
      _i16.Structure => 'Structure',
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
      case _i3.DemandeResponsableResponse():
        return 'DemandeResponsableResponse';
      case _i25.ReservationResponse():
        return 'ReservationResponse';
      case _i26.RapportCAResponse():
        return 'RapportCAResponse';
      case _i4.EventResponse():
        return 'EventResponse';
      case _i5.FilmResponse():
        return 'FilmResponse';
      case _i6.SeanceResponse():
        return 'SeanceResponse';
      case _i7.Cinema():
        return 'Cinema';
      case _i8.Evenement():
        return 'Evenement';
      case _i9.Film():
        return 'Film';
      case _i10.Reclamation():
        return 'Reclamation';
      case _i11.Seance():
        return 'Seance';
      case _i12.CinePassRow():
        return 'CinePassRow';
      case _i13.Greeting():
        return 'Greeting';
      case _i14.Salle():
        return 'Salle';
      case _i15.Siege():
        return 'Siege';
      case _i16.Structure():
        return 'Structure';
    }
    className = _i23.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i24.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'DemandeResponsableResponse') {
      return deserialize<_i3.DemandeResponsableResponse>(data['data']);
    }
    if (dataClassName == 'ReservationResponse') {
      return deserialize<_i25.ReservationResponse>(data['data']);
    }
    if (dataClassName == 'RapportCAResponse') {
      return deserialize<_i26.RapportCAResponse>(data['data']);
    }
    if (dataClassName == 'EventResponse') {
      return deserialize<_i4.EventResponse>(data['data']);
    }
    if (dataClassName == 'FilmResponse') {
      return deserialize<_i5.FilmResponse>(data['data']);
    }
    if (dataClassName == 'SeanceResponse') {
      return deserialize<_i6.SeanceResponse>(data['data']);
    }
    if (dataClassName == 'Cinema') {
      return deserialize<_i7.Cinema>(data['data']);
    }
    if (dataClassName == 'Evenement') {
      return deserialize<_i8.Evenement>(data['data']);
    }
    if (dataClassName == 'Film') {
      return deserialize<_i9.Film>(data['data']);
    }
    if (dataClassName == 'Reclamation') {
      return deserialize<_i10.Reclamation>(data['data']);
    }
    if (dataClassName == 'Seance') {
      return deserialize<_i11.Seance>(data['data']);
    }
    if (dataClassName == 'CinePassRow') {
      return deserialize<_i12.CinePassRow>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i13.Greeting>(data['data']);
    }
    if (dataClassName == 'PhoneAuthCode') {
      return deserialize<_i12.PhoneAuthCode>(data['data']);
    }
    if (dataClassName == 'Salle') {
      return deserialize<_i14.Salle>(data['data']);
    }
    if (dataClassName == 'Siege') {
      return deserialize<_i15.Siege>(data['data']);
    }
    if (dataClassName == 'Structure') {
      return deserialize<_i16.Structure>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i23.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i24.Protocol().deserializeByClassName(data);
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
      return _i23.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i24.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
