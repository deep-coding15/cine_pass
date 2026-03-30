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
import 'evenement.dart' as _i11;
import 'cine_pass_row.dart' as _i12;
import 'demande_responsable_response.dart' as _i13;
import 'event_response.dart' as _i14;
import 'event_seance_response.dart' as _i15;
import 'greetings/greeting.dart' as _i16;
import 'phone_auth_code.dart' as _i17;
import 'profile_response.dart' as _i18;
import 'rapport_ca_response.dart' as _i19;
import 'reservation_response.dart' as _i20;
import 'responsable_billet_response.dart' as _i21;
import 'structure.dart' as _i22;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i23;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i24;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i25;
export 'billet_group_response.dart';
export 'cine_pass/event_reservation_config_response.dart';
export 'cine_pass/event_seat_plan_entry_response.dart';
export 'cine_pass/event_seat_plan_response.dart';
export 'cine_pass/event_ticket_option_response.dart';
export 'cine_pass/event_ticket_type_config_response.dart';
export 'cine_pass/reservation_confirm_response.dart';
export 'cine_pass/reservation_quote_line_response.dart';
export 'cine_pass/reservation_quote_response.dart';
export 'evenement.dart';
export 'cine_pass_row.dart';
export 'demande_responsable_response.dart';
export 'event_response.dart';
export 'event_seance_response.dart';
export 'greetings/greeting.dart';
export 'phone_auth_code.dart';
export 'profile_response.dart';
export 'rapport_ca_response.dart';
export 'reservation_response.dart';
export 'responsable_billet_response.dart';
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
    if (t == _i11.Evenement) {
      return _i11.Evenement.fromJson(data) as T;
    }
    if (t == _i12.CinePassRow) {
      return _i12.CinePassRow.fromJson(data) as T;
    }
    if (t == _i13.DemandeResponsableResponse) {
      return _i13.DemandeResponsableResponse.fromJson(data) as T;
    }
    if (t == _i14.EventResponse) {
      return _i14.EventResponse.fromJson(data) as T;
    }
    if (t == _i15.EventSeanceResponse) {
      return _i15.EventSeanceResponse.fromJson(data) as T;
    }
    if (t == _i16.Greeting) {
      return _i16.Greeting.fromJson(data) as T;
    }
    if (t == _i17.PhoneAuthCode) {
      return _i17.PhoneAuthCode.fromJson(data) as T;
    }
    if (t == _i18.ProfileResponse) {
      return _i18.ProfileResponse.fromJson(data) as T;
    }
    if (t == _i19.RapportCAResponse) {
      return _i19.RapportCAResponse.fromJson(data) as T;
    }
    if (t == _i20.ReservationResponse) {
      return _i20.ReservationResponse.fromJson(data) as T;
    }
    if (t == _i21.ResponsableBilletResponse) {
      return _i21.ResponsableBilletResponse.fromJson(data) as T;
    }
    if (t == _i22.Structure) {
      return _i22.Structure.fromJson(data) as T;
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
    if (t == _i1.getType<_i11.Evenement?>()) {
      return (data != null ? _i11.Evenement.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.CinePassRow?>()) {
      return (data != null ? _i12.CinePassRow.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.DemandeResponsableResponse?>()) {
      return (data != null
              ? _i13.DemandeResponsableResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i14.EventResponse?>()) {
      return (data != null ? _i14.EventResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.EventSeanceResponse?>()) {
      return (data != null ? _i15.EventSeanceResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.Greeting?>()) {
      return (data != null ? _i16.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.PhoneAuthCode?>()) {
      return (data != null ? _i17.PhoneAuthCode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.ProfileResponse?>()) {
      return (data != null ? _i18.ProfileResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.RapportCAResponse?>()) {
      return (data != null ? _i19.RapportCAResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.ReservationResponse?>()) {
      return (data != null ? _i20.ReservationResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i21.ResponsableBilletResponse?>()) {
      return (data != null
              ? _i21.ResponsableBilletResponse.fromJson(data)
              : null)
          as T;
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
    try {
      return _i23.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i24.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i25.Protocol().deserialize<T>(data, t);
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
      _i11.Evenement => 'Evenement',
      _i12.CinePassRow => 'CinePassRow',
      _i13.DemandeResponsableResponse => 'DemandeResponsableResponse',
      _i14.EventResponse => 'EventResponse',
      _i15.EventSeanceResponse => 'EventSeanceResponse',
      _i16.Greeting => 'Greeting',
      _i17.PhoneAuthCode => 'PhoneAuthCode',
      _i18.ProfileResponse => 'ProfileResponse',
      _i19.RapportCAResponse => 'RapportCAResponse',
      _i20.ReservationResponse => 'ReservationResponse',
      _i21.ResponsableBilletResponse => 'ResponsableBilletResponse',
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
      case _i11.Evenement():
        return 'Evenement';
      case _i12.CinePassRow():
        return 'CinePassRow';
      case _i13.DemandeResponsableResponse():
        return 'DemandeResponsableResponse';
      case _i14.EventResponse():
        return 'EventResponse';
      case _i15.EventSeanceResponse():
        return 'EventSeanceResponse';
      case _i16.Greeting():
        return 'Greeting';
      case _i17.PhoneAuthCode():
        return 'PhoneAuthCode';
      case _i18.ProfileResponse():
        return 'ProfileResponse';
      case _i19.RapportCAResponse():
        return 'RapportCAResponse';
      case _i20.ReservationResponse():
        return 'ReservationResponse';
      case _i21.ResponsableBilletResponse():
        return 'ResponsableBilletResponse';
      case _i22.Structure():
        return 'Structure';
    }
    className = _i23.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    className = _i24.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i25.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'Evenement') {
      return deserialize<_i11.Evenement>(data['data']);
    }
    if (dataClassName == 'CinePassRow') {
      return deserialize<_i12.CinePassRow>(data['data']);
    }
    if (dataClassName == 'DemandeResponsableResponse') {
      return deserialize<_i13.DemandeResponsableResponse>(data['data']);
    }
    if (dataClassName == 'EventResponse') {
      return deserialize<_i14.EventResponse>(data['data']);
    }
    if (dataClassName == 'EventSeanceResponse') {
      return deserialize<_i15.EventSeanceResponse>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i16.Greeting>(data['data']);
    }
    if (dataClassName == 'PhoneAuthCode') {
      return deserialize<_i17.PhoneAuthCode>(data['data']);
    }
    if (dataClassName == 'ProfileResponse') {
      return deserialize<_i18.ProfileResponse>(data['data']);
    }
    if (dataClassName == 'RapportCAResponse') {
      return deserialize<_i19.RapportCAResponse>(data['data']);
    }
    if (dataClassName == 'ReservationResponse') {
      return deserialize<_i20.ReservationResponse>(data['data']);
    }
    if (dataClassName == 'ResponsableBilletResponse') {
      return deserialize<_i21.ResponsableBilletResponse>(data['data']);
    }
    if (dataClassName == 'Structure') {
      return deserialize<_i22.Structure>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i23.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i24.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i25.Protocol().deserializeByClassName(data);
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
    try {
      return _i25.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
