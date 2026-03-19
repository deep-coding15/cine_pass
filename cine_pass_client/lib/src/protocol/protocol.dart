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
import 'cine_pass/billet_group_response.dart' as _i2;
import 'cine_pass/cinema_response.dart' as _i3;
import 'cine_pass/demande_responsable_response.dart' as _i4;
import 'cine_pass/event_response.dart' as _i5;
import 'cine_pass/film_response.dart' as _i6;
import 'cine_pass/profile_response.dart' as _i7;
import 'cine_pass/rapport_ca_response.dart' as _i8;
import 'cine_pass/reservation_response.dart' as _i9;
import 'cine_pass/seance_response.dart' as _i10;
import 'cinema.dart' as _i11;
import 'evenement.dart' as _i12;
import 'film.dart' as _i13;
import 'seance.dart' as _i14;
import 'cine_pass_row.dart' as _i15;
import 'greetings/greeting.dart' as _i16;
import 'phone_auth_code.dart' as _i17;
import 'salle.dart' as _i18;
import 'siege.dart' as _i19;
import 'structure.dart' as _i20;
import 'package:cine_pass_client/src/protocol/cine_pass/billet_group_response.dart'
    as _i21;
import 'package:cine_pass_client/src/protocol/cine_pass/film_response.dart'
    as _i22;
import 'package:cine_pass_client/src/protocol/cine_pass/seance_response.dart'
    as _i23;
import 'package:cine_pass_client/src/protocol/cine_pass/cinema_response.dart'
    as _i24;
import 'package:cine_pass_client/src/protocol/salle.dart' as _i25;
import 'package:cine_pass_client/src/protocol/cine_pass/event_response.dart'
    as _i26;
import 'package:cine_pass_client/src/protocol/structure.dart' as _i27;
import 'package:cine_pass_client/src/protocol/cine_pass/demande_responsable_response.dart'
    as _i28;
import 'package:cine_pass_client/src/protocol/cine_pass/reservation_response.dart'
    as _i29;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i30;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i31;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i32;
export 'cine_pass/billet_group_response.dart';
export 'cine_pass/cinema_response.dart';
export 'cine_pass/demande_responsable_response.dart';
export 'cine_pass/event_response.dart';
export 'cine_pass/film_response.dart';
export 'cine_pass/profile_response.dart';
export 'cine_pass/rapport_ca_response.dart';
export 'cine_pass/reservation_response.dart';
export 'cine_pass/seance_response.dart';
export 'cinema.dart';
export 'evenement.dart';
export 'film.dart';
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

    if (t == _i2.BilletGroupResponse) {
      return _i2.BilletGroupResponse.fromJson(data) as T;
    }
    if (t == _i3.CinemaResponse) {
      return _i3.CinemaResponse.fromJson(data) as T;
    }
    if (t == _i4.DemandeResponsableResponse) {
      return _i4.DemandeResponsableResponse.fromJson(data) as T;
    }
    if (t == _i5.EventResponse) {
      return _i5.EventResponse.fromJson(data) as T;
    }
    if (t == _i6.FilmResponse) {
      return _i6.FilmResponse.fromJson(data) as T;
    }
    if (t == _i7.ProfileResponse) {
      return _i7.ProfileResponse.fromJson(data) as T;
    }
    if (t == _i8.RapportCAResponse) {
      return _i8.RapportCAResponse.fromJson(data) as T;
    }
    if (t == _i9.ReservationResponse) {
      return _i9.ReservationResponse.fromJson(data) as T;
    }
    if (t == _i10.SeanceResponse) {
      return _i10.SeanceResponse.fromJson(data) as T;
    }
    if (t == _i11.Cinema) {
      return _i11.Cinema.fromJson(data) as T;
    }
    if (t == _i12.Evenement) {
      return _i12.Evenement.fromJson(data) as T;
    }
    if (t == _i13.Film) {
      return _i13.Film.fromJson(data) as T;
    }
    if (t == _i14.Seance) {
      return _i14.Seance.fromJson(data) as T;
    }
    if (t == _i15.CinePassRow) {
      return _i15.CinePassRow.fromJson(data) as T;
    }
    if (t == _i16.Greeting) {
      return _i16.Greeting.fromJson(data) as T;
    }
    if (t == _i17.PhoneAuthCode) {
      return _i17.PhoneAuthCode.fromJson(data) as T;
    }
    if (t == _i18.Salle) {
      return _i18.Salle.fromJson(data) as T;
    }
    if (t == _i19.Siege) {
      return _i19.Siege.fromJson(data) as T;
    }
    if (t == _i20.Structure) {
      return _i20.Structure.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.BilletGroupResponse?>()) {
      return (data != null ? _i2.BilletGroupResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i3.CinemaResponse?>()) {
      return (data != null ? _i3.CinemaResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.DemandeResponsableResponse?>()) {
      return (data != null
              ? _i4.DemandeResponsableResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i5.EventResponse?>()) {
      return (data != null ? _i5.EventResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.FilmResponse?>()) {
      return (data != null ? _i6.FilmResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ProfileResponse?>()) {
      return (data != null ? _i7.ProfileResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.RapportCAResponse?>()) {
      return (data != null ? _i8.RapportCAResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ReservationResponse?>()) {
      return (data != null ? _i9.ReservationResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.SeanceResponse?>()) {
      return (data != null ? _i10.SeanceResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.Cinema?>()) {
      return (data != null ? _i11.Cinema.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Evenement?>()) {
      return (data != null ? _i12.Evenement.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.Film?>()) {
      return (data != null ? _i13.Film.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.Seance?>()) {
      return (data != null ? _i14.Seance.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.CinePassRow?>()) {
      return (data != null ? _i15.CinePassRow.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.Greeting?>()) {
      return (data != null ? _i16.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.PhoneAuthCode?>()) {
      return (data != null ? _i17.PhoneAuthCode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.Salle?>()) {
      return (data != null ? _i18.Salle.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.Siege?>()) {
      return (data != null ? _i19.Siege.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.Structure?>()) {
      return (data != null ? _i20.Structure.fromJson(data) : null) as T;
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
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<bool>) {
      return (data as List).map((e) => deserialize<bool>(e)).toList() as T;
    }
    if (t == List<double>) {
      return (data as List).map((e) => deserialize<double>(e)).toList() as T;
    }
    if (t == List<_i21.BilletGroupResponse>) {
      return (data as List)
              .map((e) => deserialize<_i21.BilletGroupResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i22.FilmResponse>) {
      return (data as List)
              .map((e) => deserialize<_i22.FilmResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i23.SeanceResponse>) {
      return (data as List)
              .map((e) => deserialize<_i23.SeanceResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i24.CinemaResponse>) {
      return (data as List)
              .map((e) => deserialize<_i24.CinemaResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.Salle>) {
      return (data as List).map((e) => deserialize<_i25.Salle>(e)).toList()
          as T;
    }
    if (t == List<_i26.EventResponse>) {
      return (data as List)
              .map((e) => deserialize<_i26.EventResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i27.Structure>) {
      return (data as List).map((e) => deserialize<_i27.Structure>(e)).toList()
          as T;
    }
    if (t == List<_i28.DemandeResponsableResponse>) {
      return (data as List)
              .map((e) => deserialize<_i28.DemandeResponsableResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i29.ReservationResponse>) {
      return (data as List)
              .map((e) => deserialize<_i29.ReservationResponse>(e))
              .toList()
          as T;
    }
    try {
      return _i30.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i31.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i32.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.BilletGroupResponse => 'BilletGroupResponse',
      _i3.CinemaResponse => 'CinemaResponse',
      _i4.DemandeResponsableResponse => 'DemandeResponsableResponse',
      _i5.EventResponse => 'EventResponse',
      _i6.FilmResponse => 'FilmResponse',
      _i7.ProfileResponse => 'ProfileResponse',
      _i8.RapportCAResponse => 'RapportCAResponse',
      _i9.ReservationResponse => 'ReservationResponse',
      _i10.SeanceResponse => 'SeanceResponse',
      _i11.Cinema => 'Cinema',
      _i12.Evenement => 'Evenement',
      _i13.Film => 'Film',
      _i14.Seance => 'Seance',
      _i15.CinePassRow => 'CinePassRow',
      _i16.Greeting => 'Greeting',
      _i17.PhoneAuthCode => 'PhoneAuthCode',
      _i18.Salle => 'Salle',
      _i19.Siege => 'Siege',
      _i20.Structure => 'Structure',
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
      case _i2.BilletGroupResponse():
        return 'BilletGroupResponse';
      case _i3.CinemaResponse():
        return 'CinemaResponse';
      case _i4.DemandeResponsableResponse():
        return 'DemandeResponsableResponse';
      case _i5.EventResponse():
        return 'EventResponse';
      case _i6.FilmResponse():
        return 'FilmResponse';
      case _i7.ProfileResponse():
        return 'ProfileResponse';
      case _i8.RapportCAResponse():
        return 'RapportCAResponse';
      case _i9.ReservationResponse():
        return 'ReservationResponse';
      case _i10.SeanceResponse():
        return 'SeanceResponse';
      case _i11.Cinema():
        return 'Cinema';
      case _i12.Evenement():
        return 'Evenement';
      case _i13.Film():
        return 'Film';
      case _i14.Seance():
        return 'Seance';
      case _i15.CinePassRow():
        return 'CinePassRow';
      case _i16.Greeting():
        return 'Greeting';
      case _i17.PhoneAuthCode():
        return 'PhoneAuthCode';
      case _i18.Salle():
        return 'Salle';
      case _i19.Siege():
        return 'Siege';
      case _i20.Structure():
        return 'Structure';
    }
    className = _i30.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    className = _i31.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i32.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'BilletGroupResponse') {
      return deserialize<_i2.BilletGroupResponse>(data['data']);
    }
    if (dataClassName == 'CinemaResponse') {
      return deserialize<_i3.CinemaResponse>(data['data']);
    }
    if (dataClassName == 'DemandeResponsableResponse') {
      return deserialize<_i4.DemandeResponsableResponse>(data['data']);
    }
    if (dataClassName == 'EventResponse') {
      return deserialize<_i5.EventResponse>(data['data']);
    }
    if (dataClassName == 'FilmResponse') {
      return deserialize<_i6.FilmResponse>(data['data']);
    }
    if (dataClassName == 'ProfileResponse') {
      return deserialize<_i7.ProfileResponse>(data['data']);
    }
    if (dataClassName == 'RapportCAResponse') {
      return deserialize<_i8.RapportCAResponse>(data['data']);
    }
    if (dataClassName == 'ReservationResponse') {
      return deserialize<_i9.ReservationResponse>(data['data']);
    }
    if (dataClassName == 'SeanceResponse') {
      return deserialize<_i10.SeanceResponse>(data['data']);
    }
    if (dataClassName == 'Cinema') {
      return deserialize<_i11.Cinema>(data['data']);
    }
    if (dataClassName == 'Evenement') {
      return deserialize<_i12.Evenement>(data['data']);
    }
    if (dataClassName == 'Film') {
      return deserialize<_i13.Film>(data['data']);
    }
    if (dataClassName == 'Seance') {
      return deserialize<_i14.Seance>(data['data']);
    }
    if (dataClassName == 'CinePassRow') {
      return deserialize<_i15.CinePassRow>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i16.Greeting>(data['data']);
    }
    if (dataClassName == 'PhoneAuthCode') {
      return deserialize<_i17.PhoneAuthCode>(data['data']);
    }
    if (dataClassName == 'Salle') {
      return deserialize<_i18.Salle>(data['data']);
    }
    if (dataClassName == 'Siege') {
      return deserialize<_i19.Siege>(data['data']);
    }
    if (dataClassName == 'Structure') {
      return deserialize<_i20.Structure>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i30.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i31.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i32.Protocol().deserializeByClassName(data);
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
      return _i30.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i31.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i32.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
