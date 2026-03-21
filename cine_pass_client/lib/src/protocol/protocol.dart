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
import 'billet_group_response.dart' as _i2;
import 'cinema.dart' as _i3;
import 'evenement.dart' as _i4;
import 'film.dart' as _i5;
import 'seance.dart' as _i6;
import 'cine_pass_row.dart' as _i7;
import 'cinema_response.dart' as _i8;
import 'demande_responsable_response.dart' as _i9;
import 'event_response.dart' as _i10;
import 'event_seance_response.dart' as _i11;
import 'film_response.dart' as _i12;
import 'greetings/greeting.dart' as _i13;
import 'phone_auth_code.dart' as _i14;
import 'profile_response.dart' as _i15;
import 'rapport_ca_response.dart' as _i16;
import 'reservation_response.dart' as _i17;
import 'responsable_billet_response.dart' as _i18;
import 'salle.dart' as _i19;
import 'seance_response.dart' as _i20;
import 'siege.dart' as _i21;
import 'structure.dart' as _i22;
import 'package:cine_pass_client/src/protocol/billet_group_response.dart'
    as _i23;
import 'package:cine_pass_client/src/protocol/film_response.dart' as _i24;
import 'package:cine_pass_client/src/protocol/seance_response.dart' as _i25;
import 'package:cine_pass_client/src/protocol/cinema_response.dart' as _i26;
import 'package:cine_pass_client/src/protocol/salle.dart' as _i27;
import 'package:cine_pass_client/src/protocol/event_response.dart' as _i28;
import 'package:cine_pass_client/src/protocol/event_seance_response.dart'
    as _i29;
import 'package:cine_pass_client/src/protocol/structure.dart' as _i30;
import 'package:cine_pass_client/src/protocol/demande_responsable_response.dart'
    as _i31;
import 'package:cine_pass_client/src/protocol/reservation_response.dart'
    as _i32;
import 'package:cine_pass_client/src/protocol/responsable_billet_response.dart'
    as _i33;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i34;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i35;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i36;
export 'billet_group_response.dart';
export 'cinema.dart';
export 'evenement.dart';
export 'film.dart';
export 'seance.dart';
export 'cine_pass_row.dart';
export 'cinema_response.dart';
export 'demande_responsable_response.dart';
export 'event_response.dart';
export 'event_seance_response.dart';
export 'film_response.dart';
export 'greetings/greeting.dart';
export 'phone_auth_code.dart';
export 'profile_response.dart';
export 'rapport_ca_response.dart';
export 'reservation_response.dart';
export 'responsable_billet_response.dart';
export 'salle.dart';
export 'seance_response.dart';
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
    if (t == _i3.Cinema) {
      return _i3.Cinema.fromJson(data) as T;
    }
    if (t == _i4.Evenement) {
      return _i4.Evenement.fromJson(data) as T;
    }
    if (t == _i5.Film) {
      return _i5.Film.fromJson(data) as T;
    }
    if (t == _i6.Seance) {
      return _i6.Seance.fromJson(data) as T;
    }
    if (t == _i7.CinePassRow) {
      return _i7.CinePassRow.fromJson(data) as T;
    }
    if (t == _i8.CinemaResponse) {
      return _i8.CinemaResponse.fromJson(data) as T;
    }
    if (t == _i9.DemandeResponsableResponse) {
      return _i9.DemandeResponsableResponse.fromJson(data) as T;
    }
    if (t == _i10.EventResponse) {
      return _i10.EventResponse.fromJson(data) as T;
    }
    if (t == _i11.EventSeanceResponse) {
      return _i11.EventSeanceResponse.fromJson(data) as T;
    }
    if (t == _i12.FilmResponse) {
      return _i12.FilmResponse.fromJson(data) as T;
    }
    if (t == _i13.Greeting) {
      return _i13.Greeting.fromJson(data) as T;
    }
    if (t == _i14.PhoneAuthCode) {
      return _i14.PhoneAuthCode.fromJson(data) as T;
    }
    if (t == _i15.ProfileResponse) {
      return _i15.ProfileResponse.fromJson(data) as T;
    }
    if (t == _i16.RapportCAResponse) {
      return _i16.RapportCAResponse.fromJson(data) as T;
    }
    if (t == _i17.ReservationResponse) {
      return _i17.ReservationResponse.fromJson(data) as T;
    }
    if (t == _i18.ResponsableBilletResponse) {
      return _i18.ResponsableBilletResponse.fromJson(data) as T;
    }
    if (t == _i19.Salle) {
      return _i19.Salle.fromJson(data) as T;
    }
    if (t == _i20.SeanceResponse) {
      return _i20.SeanceResponse.fromJson(data) as T;
    }
    if (t == _i21.Siege) {
      return _i21.Siege.fromJson(data) as T;
    }
    if (t == _i22.Structure) {
      return _i22.Structure.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.BilletGroupResponse?>()) {
      return (data != null ? _i2.BilletGroupResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i3.Cinema?>()) {
      return (data != null ? _i3.Cinema.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Evenement?>()) {
      return (data != null ? _i4.Evenement.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Film?>()) {
      return (data != null ? _i5.Film.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.Seance?>()) {
      return (data != null ? _i6.Seance.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.CinePassRow?>()) {
      return (data != null ? _i7.CinePassRow.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.CinemaResponse?>()) {
      return (data != null ? _i8.CinemaResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.DemandeResponsableResponse?>()) {
      return (data != null
              ? _i9.DemandeResponsableResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i10.EventResponse?>()) {
      return (data != null ? _i10.EventResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.EventSeanceResponse?>()) {
      return (data != null ? _i11.EventSeanceResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.FilmResponse?>()) {
      return (data != null ? _i12.FilmResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.Greeting?>()) {
      return (data != null ? _i13.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.PhoneAuthCode?>()) {
      return (data != null ? _i14.PhoneAuthCode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.ProfileResponse?>()) {
      return (data != null ? _i15.ProfileResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.RapportCAResponse?>()) {
      return (data != null ? _i16.RapportCAResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.ReservationResponse?>()) {
      return (data != null ? _i17.ReservationResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.ResponsableBilletResponse?>()) {
      return (data != null
              ? _i18.ResponsableBilletResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i19.Salle?>()) {
      return (data != null ? _i19.Salle.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.SeanceResponse?>()) {
      return (data != null ? _i20.SeanceResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.Siege?>()) {
      return (data != null ? _i21.Siege.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.Structure?>()) {
      return (data != null ? _i22.Structure.fromJson(data) : null) as T;
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
    if (t == List<_i23.BilletGroupResponse>) {
      return (data as List)
              .map((e) => deserialize<_i23.BilletGroupResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i24.FilmResponse>) {
      return (data as List)
              .map((e) => deserialize<_i24.FilmResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.SeanceResponse>) {
      return (data as List)
              .map((e) => deserialize<_i25.SeanceResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i26.CinemaResponse>) {
      return (data as List)
              .map((e) => deserialize<_i26.CinemaResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i27.Salle>) {
      return (data as List).map((e) => deserialize<_i27.Salle>(e)).toList()
          as T;
    }
    if (t == List<_i28.EventResponse>) {
      return (data as List)
              .map((e) => deserialize<_i28.EventResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i29.EventSeanceResponse>) {
      return (data as List)
              .map((e) => deserialize<_i29.EventSeanceResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i30.Structure>) {
      return (data as List).map((e) => deserialize<_i30.Structure>(e)).toList()
          as T;
    }
    if (t == List<_i31.DemandeResponsableResponse>) {
      return (data as List)
              .map((e) => deserialize<_i31.DemandeResponsableResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i32.ReservationResponse>) {
      return (data as List)
              .map((e) => deserialize<_i32.ReservationResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i33.ResponsableBilletResponse>) {
      return (data as List)
              .map((e) => deserialize<_i33.ResponsableBilletResponse>(e))
              .toList()
          as T;
    }
    try {
      return _i34.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i35.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i36.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.BilletGroupResponse => 'BilletGroupResponse',
      _i3.Cinema => 'Cinema',
      _i4.Evenement => 'Evenement',
      _i5.Film => 'Film',
      _i6.Seance => 'Seance',
      _i7.CinePassRow => 'CinePassRow',
      _i8.CinemaResponse => 'CinemaResponse',
      _i9.DemandeResponsableResponse => 'DemandeResponsableResponse',
      _i10.EventResponse => 'EventResponse',
      _i11.EventSeanceResponse => 'EventSeanceResponse',
      _i12.FilmResponse => 'FilmResponse',
      _i13.Greeting => 'Greeting',
      _i14.PhoneAuthCode => 'PhoneAuthCode',
      _i15.ProfileResponse => 'ProfileResponse',
      _i16.RapportCAResponse => 'RapportCAResponse',
      _i17.ReservationResponse => 'ReservationResponse',
      _i18.ResponsableBilletResponse => 'ResponsableBilletResponse',
      _i19.Salle => 'Salle',
      _i20.SeanceResponse => 'SeanceResponse',
      _i21.Siege => 'Siege',
      _i22.Structure => 'Structure',
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
      case _i3.Cinema():
        return 'Cinema';
      case _i4.Evenement():
        return 'Evenement';
      case _i5.Film():
        return 'Film';
      case _i6.Seance():
        return 'Seance';
      case _i7.CinePassRow():
        return 'CinePassRow';
      case _i8.CinemaResponse():
        return 'CinemaResponse';
      case _i9.DemandeResponsableResponse():
        return 'DemandeResponsableResponse';
      case _i10.EventResponse():
        return 'EventResponse';
      case _i11.EventSeanceResponse():
        return 'EventSeanceResponse';
      case _i12.FilmResponse():
        return 'FilmResponse';
      case _i13.Greeting():
        return 'Greeting';
      case _i14.PhoneAuthCode():
        return 'PhoneAuthCode';
      case _i15.ProfileResponse():
        return 'ProfileResponse';
      case _i16.RapportCAResponse():
        return 'RapportCAResponse';
      case _i17.ReservationResponse():
        return 'ReservationResponse';
      case _i18.ResponsableBilletResponse():
        return 'ResponsableBilletResponse';
      case _i19.Salle():
        return 'Salle';
      case _i20.SeanceResponse():
        return 'SeanceResponse';
      case _i21.Siege():
        return 'Siege';
      case _i22.Structure():
        return 'Structure';
    }
    className = _i34.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    className = _i35.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i36.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'Cinema') {
      return deserialize<_i3.Cinema>(data['data']);
    }
    if (dataClassName == 'Evenement') {
      return deserialize<_i4.Evenement>(data['data']);
    }
    if (dataClassName == 'Film') {
      return deserialize<_i5.Film>(data['data']);
    }
    if (dataClassName == 'Seance') {
      return deserialize<_i6.Seance>(data['data']);
    }
    if (dataClassName == 'CinePassRow') {
      return deserialize<_i7.CinePassRow>(data['data']);
    }
    if (dataClassName == 'CinemaResponse') {
      return deserialize<_i8.CinemaResponse>(data['data']);
    }
    if (dataClassName == 'DemandeResponsableResponse') {
      return deserialize<_i9.DemandeResponsableResponse>(data['data']);
    }
    if (dataClassName == 'EventResponse') {
      return deserialize<_i10.EventResponse>(data['data']);
    }
    if (dataClassName == 'EventSeanceResponse') {
      return deserialize<_i11.EventSeanceResponse>(data['data']);
    }
    if (dataClassName == 'FilmResponse') {
      return deserialize<_i12.FilmResponse>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i13.Greeting>(data['data']);
    }
    if (dataClassName == 'PhoneAuthCode') {
      return deserialize<_i14.PhoneAuthCode>(data['data']);
    }
    if (dataClassName == 'ProfileResponse') {
      return deserialize<_i15.ProfileResponse>(data['data']);
    }
    if (dataClassName == 'RapportCAResponse') {
      return deserialize<_i16.RapportCAResponse>(data['data']);
    }
    if (dataClassName == 'ReservationResponse') {
      return deserialize<_i17.ReservationResponse>(data['data']);
    }
    if (dataClassName == 'ResponsableBilletResponse') {
      return deserialize<_i18.ResponsableBilletResponse>(data['data']);
    }
    if (dataClassName == 'Salle') {
      return deserialize<_i19.Salle>(data['data']);
    }
    if (dataClassName == 'SeanceResponse') {
      return deserialize<_i20.SeanceResponse>(data['data']);
    }
    if (dataClassName == 'Siege') {
      return deserialize<_i21.Siege>(data['data']);
    }
    if (dataClassName == 'Structure') {
      return deserialize<_i22.Structure>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i34.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i35.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i36.Protocol().deserializeByClassName(data);
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
      return _i34.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i35.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i36.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
