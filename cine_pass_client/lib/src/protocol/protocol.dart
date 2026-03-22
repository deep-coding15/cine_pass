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
import 'cine_pass/event_reservation_config_response.dart' as _i3;
import 'cine_pass/event_seat_plan_entry_response.dart' as _i4;
import 'cine_pass/event_seat_plan_response.dart' as _i5;
import 'cine_pass/event_ticket_option_response.dart' as _i6;
import 'cine_pass/event_ticket_type_config_response.dart' as _i7;
import 'cine_pass/reservation_confirm_response.dart' as _i8;
import 'cine_pass/reservation_quote_line_response.dart' as _i9;
import 'cine_pass/reservation_quote_response.dart' as _i10;
import 'cinema.dart' as _i11;
import 'evenement.dart' as _i12;
import 'film.dart' as _i13;
import 'seance.dart' as _i14;
import 'cine_pass_row.dart' as _i15;
import 'cinema_response.dart' as _i16;
import 'demande_responsable_response.dart' as _i17;
import 'event_response.dart' as _i18;
import 'event_seance_response.dart' as _i19;
import 'film_response.dart' as _i20;
import 'greetings/greeting.dart' as _i21;
import 'phone_auth_code.dart' as _i22;
import 'profile_response.dart' as _i23;
import 'rapport_ca_response.dart' as _i24;
import 'reservation_response.dart' as _i25;
import 'responsable_billet_response.dart' as _i26;
import 'salle.dart' as _i27;
import 'seance_response.dart' as _i28;
import 'siege.dart' as _i29;
import 'structure.dart' as _i30;
import 'package:cine_pass_client/src/protocol/billet_group_response.dart'
    as _i31;
import 'package:cine_pass_client/src/protocol/film_response.dart' as _i32;
import 'package:cine_pass_client/src/protocol/seance_response.dart' as _i33;
import 'package:cine_pass_client/src/protocol/cinema_response.dart' as _i34;
import 'package:cine_pass_client/src/protocol/salle.dart' as _i35;
import 'package:cine_pass_client/src/protocol/event_response.dart' as _i36;
import 'package:cine_pass_client/src/protocol/structure.dart' as _i37;
import 'package:cine_pass_client/src/protocol/demande_responsable_response.dart'
    as _i38;
import 'package:cine_pass_client/src/protocol/reservation_response.dart'
    as _i39;
import 'package:cine_pass_client/src/protocol/profile_response.dart' as _i40;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i41;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i42;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i43;
export 'billet_group_response.dart';
export 'cine_pass/event_reservation_config_response.dart';
export 'cine_pass/event_seat_plan_entry_response.dart';
export 'cine_pass/event_seat_plan_response.dart';
export 'cine_pass/event_ticket_option_response.dart';
export 'cine_pass/event_ticket_type_config_response.dart';
export 'cine_pass/reservation_confirm_response.dart';
export 'cine_pass/reservation_quote_line_response.dart';
export 'cine_pass/reservation_quote_response.dart';
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
    if (t == _i3.EventReservationConfigResponse) {
      return _i3.EventReservationConfigResponse.fromJson(data) as T;
    }
    if (t == _i4.EventSeatPlanEntryResponse) {
      return _i4.EventSeatPlanEntryResponse.fromJson(data) as T;
    }
    if (t == _i5.EventSeatPlanResponse) {
      return _i5.EventSeatPlanResponse.fromJson(data) as T;
    }
    if (t == _i6.EventTicketOptionResponse) {
      return _i6.EventTicketOptionResponse.fromJson(data) as T;
    }
    if (t == _i7.EventTicketTypeConfigResponse) {
      return _i7.EventTicketTypeConfigResponse.fromJson(data) as T;
    }
    if (t == _i8.ReservationConfirmResponse) {
      return _i8.ReservationConfirmResponse.fromJson(data) as T;
    }
    if (t == _i9.ReservationQuoteLineResponse) {
      return _i9.ReservationQuoteLineResponse.fromJson(data) as T;
    }
    if (t == _i10.ReservationQuoteResponse) {
      return _i10.ReservationQuoteResponse.fromJson(data) as T;
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
    if (t == _i16.CinemaResponse) {
      return _i16.CinemaResponse.fromJson(data) as T;
    }
    if (t == _i17.DemandeResponsableResponse) {
      return _i17.DemandeResponsableResponse.fromJson(data) as T;
    }
    if (t == _i18.EventResponse) {
      return _i18.EventResponse.fromJson(data) as T;
    }
    if (t == _i19.EventSeanceResponse) {
      return _i19.EventSeanceResponse.fromJson(data) as T;
    }
    if (t == _i20.FilmResponse) {
      return _i20.FilmResponse.fromJson(data) as T;
    }
    if (t == _i21.Greeting) {
      return _i21.Greeting.fromJson(data) as T;
    }
    if (t == _i22.PhoneAuthCode) {
      return _i22.PhoneAuthCode.fromJson(data) as T;
    }
    if (t == _i23.ProfileResponse) {
      return _i23.ProfileResponse.fromJson(data) as T;
    }
    if (t == _i24.RapportCAResponse) {
      return _i24.RapportCAResponse.fromJson(data) as T;
    }
    if (t == _i25.ReservationResponse) {
      return _i25.ReservationResponse.fromJson(data) as T;
    }
    if (t == _i26.ResponsableBilletResponse) {
      return _i26.ResponsableBilletResponse.fromJson(data) as T;
    }
    if (t == _i27.Salle) {
      return _i27.Salle.fromJson(data) as T;
    }
    if (t == _i28.SeanceResponse) {
      return _i28.SeanceResponse.fromJson(data) as T;
    }
    if (t == _i29.Siege) {
      return _i29.Siege.fromJson(data) as T;
    }
    if (t == _i30.Structure) {
      return _i30.Structure.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.BilletGroupResponse?>()) {
      return (data != null ? _i2.BilletGroupResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i3.EventReservationConfigResponse?>()) {
      return (data != null
              ? _i3.EventReservationConfigResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i4.EventSeatPlanEntryResponse?>()) {
      return (data != null
              ? _i4.EventSeatPlanEntryResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i5.EventSeatPlanResponse?>()) {
      return (data != null ? _i5.EventSeatPlanResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.EventTicketOptionResponse?>()) {
      return (data != null
              ? _i6.EventTicketOptionResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i7.EventTicketTypeConfigResponse?>()) {
      return (data != null
              ? _i7.EventTicketTypeConfigResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i8.ReservationConfirmResponse?>()) {
      return (data != null
              ? _i8.ReservationConfirmResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i9.ReservationQuoteLineResponse?>()) {
      return (data != null
              ? _i9.ReservationQuoteLineResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i10.ReservationQuoteResponse?>()) {
      return (data != null
              ? _i10.ReservationQuoteResponse.fromJson(data)
              : null)
          as T;
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
    if (t == _i1.getType<_i16.CinemaResponse?>()) {
      return (data != null ? _i16.CinemaResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.DemandeResponsableResponse?>()) {
      return (data != null
              ? _i17.DemandeResponsableResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i18.EventResponse?>()) {
      return (data != null ? _i18.EventResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.EventSeanceResponse?>()) {
      return (data != null ? _i19.EventSeanceResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i20.FilmResponse?>()) {
      return (data != null ? _i20.FilmResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.Greeting?>()) {
      return (data != null ? _i21.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.PhoneAuthCode?>()) {
      return (data != null ? _i22.PhoneAuthCode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.ProfileResponse?>()) {
      return (data != null ? _i23.ProfileResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.RapportCAResponse?>()) {
      return (data != null ? _i24.RapportCAResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.ReservationResponse?>()) {
      return (data != null ? _i25.ReservationResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i26.ResponsableBilletResponse?>()) {
      return (data != null
              ? _i26.ResponsableBilletResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i27.Salle?>()) {
      return (data != null ? _i27.Salle.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.SeanceResponse?>()) {
      return (data != null ? _i28.SeanceResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.Siege?>()) {
      return (data != null ? _i29.Siege.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.Structure?>()) {
      return (data != null ? _i30.Structure.fromJson(data) : null) as T;
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
    if (t == List<_i7.EventTicketTypeConfigResponse>) {
      return (data as List)
              .map((e) => deserialize<_i7.EventTicketTypeConfigResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i4.EventSeatPlanEntryResponse>) {
      return (data as List)
              .map((e) => deserialize<_i4.EventSeatPlanEntryResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i6.EventTicketOptionResponse>) {
      return (data as List)
              .map((e) => deserialize<_i6.EventTicketOptionResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i9.ReservationQuoteLineResponse>) {
      return (data as List)
              .map((e) => deserialize<_i9.ReservationQuoteLineResponse>(e))
              .toList()
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
    if (t == List<_i31.BilletGroupResponse>) {
      return (data as List)
              .map((e) => deserialize<_i31.BilletGroupResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i32.FilmResponse>) {
      return (data as List)
              .map((e) => deserialize<_i32.FilmResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i33.SeanceResponse>) {
      return (data as List)
              .map((e) => deserialize<_i33.SeanceResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i34.CinemaResponse>) {
      return (data as List)
              .map((e) => deserialize<_i34.CinemaResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i35.Salle>) {
      return (data as List).map((e) => deserialize<_i35.Salle>(e)).toList()
          as T;
    }
    if (t == List<_i36.EventResponse>) {
      return (data as List)
              .map((e) => deserialize<_i36.EventResponse>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_i37.Structure>) {
      return (data as List).map((e) => deserialize<_i37.Structure>(e)).toList()
          as T;
    }
    if (t == List<_i38.DemandeResponsableResponse>) {
      return (data as List)
              .map((e) => deserialize<_i38.DemandeResponsableResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i39.ReservationResponse>) {
      return (data as List)
              .map((e) => deserialize<_i39.ReservationResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i40.ProfileResponse>) {
      return (data as List)
              .map((e) => deserialize<_i40.ProfileResponse>(e))
              .toList()
          as T;
    }
    try {
      return _i41.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i42.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i43.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.BilletGroupResponse => 'BilletGroupResponse',
      _i3.EventReservationConfigResponse => 'EventReservationConfigResponse',
      _i4.EventSeatPlanEntryResponse => 'EventSeatPlanEntryResponse',
      _i5.EventSeatPlanResponse => 'EventSeatPlanResponse',
      _i6.EventTicketOptionResponse => 'EventTicketOptionResponse',
      _i7.EventTicketTypeConfigResponse => 'EventTicketTypeConfigResponse',
      _i8.ReservationConfirmResponse => 'ReservationConfirmResponse',
      _i9.ReservationQuoteLineResponse => 'ReservationQuoteLineResponse',
      _i10.ReservationQuoteResponse => 'ReservationQuoteResponse',
      _i11.Cinema => 'Cinema',
      _i12.Evenement => 'Evenement',
      _i13.Film => 'Film',
      _i14.Seance => 'Seance',
      _i15.CinePassRow => 'CinePassRow',
      _i16.CinemaResponse => 'CinemaResponse',
      _i17.DemandeResponsableResponse => 'DemandeResponsableResponse',
      _i18.EventResponse => 'EventResponse',
      _i19.EventSeanceResponse => 'EventSeanceResponse',
      _i20.FilmResponse => 'FilmResponse',
      _i21.Greeting => 'Greeting',
      _i22.PhoneAuthCode => 'PhoneAuthCode',
      _i23.ProfileResponse => 'ProfileResponse',
      _i24.RapportCAResponse => 'RapportCAResponse',
      _i25.ReservationResponse => 'ReservationResponse',
      _i26.ResponsableBilletResponse => 'ResponsableBilletResponse',
      _i27.Salle => 'Salle',
      _i28.SeanceResponse => 'SeanceResponse',
      _i29.Siege => 'Siege',
      _i30.Structure => 'Structure',
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
      case _i3.EventReservationConfigResponse():
        return 'EventReservationConfigResponse';
      case _i4.EventSeatPlanEntryResponse():
        return 'EventSeatPlanEntryResponse';
      case _i5.EventSeatPlanResponse():
        return 'EventSeatPlanResponse';
      case _i6.EventTicketOptionResponse():
        return 'EventTicketOptionResponse';
      case _i7.EventTicketTypeConfigResponse():
        return 'EventTicketTypeConfigResponse';
      case _i8.ReservationConfirmResponse():
        return 'ReservationConfirmResponse';
      case _i9.ReservationQuoteLineResponse():
        return 'ReservationQuoteLineResponse';
      case _i10.ReservationQuoteResponse():
        return 'ReservationQuoteResponse';
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
      case _i16.CinemaResponse():
        return 'CinemaResponse';
      case _i17.DemandeResponsableResponse():
        return 'DemandeResponsableResponse';
      case _i18.EventResponse():
        return 'EventResponse';
      case _i19.EventSeanceResponse():
        return 'EventSeanceResponse';
      case _i20.FilmResponse():
        return 'FilmResponse';
      case _i21.Greeting():
        return 'Greeting';
      case _i22.PhoneAuthCode():
        return 'PhoneAuthCode';
      case _i23.ProfileResponse():
        return 'ProfileResponse';
      case _i24.RapportCAResponse():
        return 'RapportCAResponse';
      case _i25.ReservationResponse():
        return 'ReservationResponse';
      case _i26.ResponsableBilletResponse():
        return 'ResponsableBilletResponse';
      case _i27.Salle():
        return 'Salle';
      case _i28.SeanceResponse():
        return 'SeanceResponse';
      case _i29.Siege():
        return 'Siege';
      case _i30.Structure():
        return 'Structure';
    }
    className = _i41.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    className = _i42.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i43.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'EventReservationConfigResponse') {
      return deserialize<_i3.EventReservationConfigResponse>(data['data']);
    }
    if (dataClassName == 'EventSeatPlanEntryResponse') {
      return deserialize<_i4.EventSeatPlanEntryResponse>(data['data']);
    }
    if (dataClassName == 'EventSeatPlanResponse') {
      return deserialize<_i5.EventSeatPlanResponse>(data['data']);
    }
    if (dataClassName == 'EventTicketOptionResponse') {
      return deserialize<_i6.EventTicketOptionResponse>(data['data']);
    }
    if (dataClassName == 'EventTicketTypeConfigResponse') {
      return deserialize<_i7.EventTicketTypeConfigResponse>(data['data']);
    }
    if (dataClassName == 'ReservationConfirmResponse') {
      return deserialize<_i8.ReservationConfirmResponse>(data['data']);
    }
    if (dataClassName == 'ReservationQuoteLineResponse') {
      return deserialize<_i9.ReservationQuoteLineResponse>(data['data']);
    }
    if (dataClassName == 'ReservationQuoteResponse') {
      return deserialize<_i10.ReservationQuoteResponse>(data['data']);
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
    if (dataClassName == 'CinemaResponse') {
      return deserialize<_i16.CinemaResponse>(data['data']);
    }
    if (dataClassName == 'DemandeResponsableResponse') {
      return deserialize<_i17.DemandeResponsableResponse>(data['data']);
    }
    if (dataClassName == 'EventResponse') {
      return deserialize<_i18.EventResponse>(data['data']);
    }
    if (dataClassName == 'EventSeanceResponse') {
      return deserialize<_i19.EventSeanceResponse>(data['data']);
    }
    if (dataClassName == 'FilmResponse') {
      return deserialize<_i20.FilmResponse>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i21.Greeting>(data['data']);
    }
    if (dataClassName == 'PhoneAuthCode') {
      return deserialize<_i22.PhoneAuthCode>(data['data']);
    }
    if (dataClassName == 'ProfileResponse') {
      return deserialize<_i23.ProfileResponse>(data['data']);
    }
    if (dataClassName == 'RapportCAResponse') {
      return deserialize<_i24.RapportCAResponse>(data['data']);
    }
    if (dataClassName == 'ReservationResponse') {
      return deserialize<_i25.ReservationResponse>(data['data']);
    }
    if (dataClassName == 'ResponsableBilletResponse') {
      return deserialize<_i26.ResponsableBilletResponse>(data['data']);
    }
    if (dataClassName == 'Salle') {
      return deserialize<_i27.Salle>(data['data']);
    }
    if (dataClassName == 'SeanceResponse') {
      return deserialize<_i28.SeanceResponse>(data['data']);
    }
    if (dataClassName == 'Siege') {
      return deserialize<_i29.Siege>(data['data']);
    }
    if (dataClassName == 'Structure') {
      return deserialize<_i30.Structure>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i41.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i42.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i43.Protocol().deserializeByClassName(data);
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
      return _i41.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i42.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i43.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
