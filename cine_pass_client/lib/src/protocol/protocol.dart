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
import 'greetings/greeting.dart' as _i2;
import 'reservation_billet/billet.dart' as _i3;
import 'reservation_billet/billet_result.dart' as _i4;
import 'reservation_billet/cinema.dart' as _i5;
import 'reservation_billet/code_promo.dart' as _i6;
import 'reservation_billet/code_promo_statut.dart' as _i7;
import 'reservation_billet/film.dart' as _i8;
import 'reservation_billet/optionnel.dart' as _i9;
import 'reservation_billet/optionnel_reservation.dart' as _i10;
import 'reservation_billet/paiement.dart' as _i11;
import 'reservation_billet/paiement_method.dart' as _i12;
import 'reservation_billet/paiement_result.dart' as _i13;
import 'reservation_billet/paiement_statut.dart' as _i14;
import 'reservation_billet/reservation.dart' as _i15;
import 'reservation_billet/reservation_siege.dart' as _i16;
import 'reservation_billet/reservation_siege_statut.dart' as _i17;
import 'reservation_billet/reservation_statut.dart' as _i18;
import 'reservation_billet/salle.dart' as _i19;
import 'reservation_billet/seance.dart' as _i20;
import 'reservation_billet/seance_statut.dart' as _i21;
import 'reservation_billet/siege.dart' as _i22;
import 'reservation_billet/siege_state.dart' as _i23;
import 'reservation_billet/siege_statut.dart' as _i24;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i25;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i26;
export 'greetings/greeting.dart';
export 'reservation_billet/billet.dart';
export 'reservation_billet/billet_result.dart';
export 'reservation_billet/cinema.dart';
export 'reservation_billet/code_promo.dart';
export 'reservation_billet/code_promo_statut.dart';
export 'reservation_billet/film.dart';
export 'reservation_billet/optionnel.dart';
export 'reservation_billet/optionnel_reservation.dart';
export 'reservation_billet/paiement.dart';
export 'reservation_billet/paiement_method.dart';
export 'reservation_billet/paiement_result.dart';
export 'reservation_billet/paiement_statut.dart';
export 'reservation_billet/reservation.dart';
export 'reservation_billet/reservation_siege.dart';
export 'reservation_billet/reservation_siege_statut.dart';
export 'reservation_billet/reservation_statut.dart';
export 'reservation_billet/salle.dart';
export 'reservation_billet/seance.dart';
export 'reservation_billet/seance_statut.dart';
export 'reservation_billet/siege.dart';
export 'reservation_billet/siege_state.dart';
export 'reservation_billet/siege_statut.dart';
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

    if (t == _i2.Greeting) {
      return _i2.Greeting.fromJson(data) as T;
    }
    if (t == _i3.Billet) {
      return _i3.Billet.fromJson(data) as T;
    }
    if (t == _i4.BilletResult) {
      return _i4.BilletResult.fromJson(data) as T;
    }
    if (t == _i5.Cinema) {
      return _i5.Cinema.fromJson(data) as T;
    }
    if (t == _i6.CodePromo) {
      return _i6.CodePromo.fromJson(data) as T;
    }
    if (t == _i7.CodePromoStatut) {
      return _i7.CodePromoStatut.fromJson(data) as T;
    }
    if (t == _i8.Film) {
      return _i8.Film.fromJson(data) as T;
    }
    if (t == _i9.Optionnel) {
      return _i9.Optionnel.fromJson(data) as T;
    }
    if (t == _i10.OptionnelReservation) {
      return _i10.OptionnelReservation.fromJson(data) as T;
    }
    if (t == _i11.Paiement) {
      return _i11.Paiement.fromJson(data) as T;
    }
    if (t == _i12.PaiementMethod) {
      return _i12.PaiementMethod.fromJson(data) as T;
    }
    if (t == _i13.PaiementResult) {
      return _i13.PaiementResult.fromJson(data) as T;
    }
    if (t == _i14.PaiementStatut) {
      return _i14.PaiementStatut.fromJson(data) as T;
    }
    if (t == _i15.Reservation) {
      return _i15.Reservation.fromJson(data) as T;
    }
    if (t == _i16.ReservationSiege) {
      return _i16.ReservationSiege.fromJson(data) as T;
    }
    if (t == _i17.ReservationSiegeStatut) {
      return _i17.ReservationSiegeStatut.fromJson(data) as T;
    }
    if (t == _i18.ReservationStatut) {
      return _i18.ReservationStatut.fromJson(data) as T;
    }
    if (t == _i19.Salle) {
      return _i19.Salle.fromJson(data) as T;
    }
    if (t == _i20.Seance) {
      return _i20.Seance.fromJson(data) as T;
    }
    if (t == _i21.SeanceStatut) {
      return _i21.SeanceStatut.fromJson(data) as T;
    }
    if (t == _i22.Siege) {
      return _i22.Siege.fromJson(data) as T;
    }
    if (t == _i23.SiegeState) {
      return _i23.SiegeState.fromJson(data) as T;
    }
    if (t == _i24.SiegeStatut) {
      return _i24.SiegeStatut.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Greeting?>()) {
      return (data != null ? _i2.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.Billet?>()) {
      return (data != null ? _i3.Billet.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.BilletResult?>()) {
      return (data != null ? _i4.BilletResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Cinema?>()) {
      return (data != null ? _i5.Cinema.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.CodePromo?>()) {
      return (data != null ? _i6.CodePromo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.CodePromoStatut?>()) {
      return (data != null ? _i7.CodePromoStatut.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Film?>()) {
      return (data != null ? _i8.Film.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Optionnel?>()) {
      return (data != null ? _i9.Optionnel.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.OptionnelReservation?>()) {
      return (data != null ? _i10.OptionnelReservation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.Paiement?>()) {
      return (data != null ? _i11.Paiement.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.PaiementMethod?>()) {
      return (data != null ? _i12.PaiementMethod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.PaiementResult?>()) {
      return (data != null ? _i13.PaiementResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.PaiementStatut?>()) {
      return (data != null ? _i14.PaiementStatut.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.Reservation?>()) {
      return (data != null ? _i15.Reservation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.ReservationSiege?>()) {
      return (data != null ? _i16.ReservationSiege.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.ReservationSiegeStatut?>()) {
      return (data != null ? _i17.ReservationSiegeStatut.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.ReservationStatut?>()) {
      return (data != null ? _i18.ReservationStatut.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.Salle?>()) {
      return (data != null ? _i19.Salle.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.Seance?>()) {
      return (data != null ? _i20.Seance.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.SeanceStatut?>()) {
      return (data != null ? _i21.SeanceStatut.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.Siege?>()) {
      return (data != null ? _i22.Siege.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.SiegeState?>()) {
      return (data != null ? _i23.SiegeState.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.SiegeStatut?>()) {
      return (data != null ? _i24.SiegeStatut.fromJson(data) : null) as T;
    }
    if (t == List<_i10.OptionnelReservation>) {
      return (data as List)
              .map((e) => deserialize<_i10.OptionnelReservation>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i10.OptionnelReservation>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i10.OptionnelReservation>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i16.ReservationSiege>) {
      return (data as List)
              .map((e) => deserialize<_i16.ReservationSiege>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i16.ReservationSiege>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i16.ReservationSiege>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == Set<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toSet() as T;
    }
    if (t == Map<int, int>) {
      return Map.fromEntries(
            (data as List).map(
              (e) =>
                  MapEntry(deserialize<int>(e['k']), deserialize<int>(e['v'])),
            ),
          )
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    try {
      return _i25.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i26.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Greeting => 'Greeting',
      _i3.Billet => 'Billet',
      _i4.BilletResult => 'BilletResult',
      _i5.Cinema => 'Cinema',
      _i6.CodePromo => 'CodePromo',
      _i7.CodePromoStatut => 'CodePromoStatut',
      _i8.Film => 'Film',
      _i9.Optionnel => 'Optionnel',
      _i10.OptionnelReservation => 'OptionnelReservation',
      _i11.Paiement => 'Paiement',
      _i12.PaiementMethod => 'PaiementMethod',
      _i13.PaiementResult => 'PaiementResult',
      _i14.PaiementStatut => 'PaiementStatut',
      _i15.Reservation => 'Reservation',
      _i16.ReservationSiege => 'ReservationSiege',
      _i17.ReservationSiegeStatut => 'ReservationSiegeStatut',
      _i18.ReservationStatut => 'ReservationStatut',
      _i19.Salle => 'Salle',
      _i20.Seance => 'Seance',
      _i21.SeanceStatut => 'SeanceStatut',
      _i22.Siege => 'Siege',
      _i23.SiegeState => 'SiegeState',
      _i24.SiegeStatut => 'SiegeStatut',
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
      case _i2.Greeting():
        return 'Greeting';
      case _i3.Billet():
        return 'Billet';
      case _i4.BilletResult():
        return 'BilletResult';
      case _i5.Cinema():
        return 'Cinema';
      case _i6.CodePromo():
        return 'CodePromo';
      case _i7.CodePromoStatut():
        return 'CodePromoStatut';
      case _i8.Film():
        return 'Film';
      case _i9.Optionnel():
        return 'Optionnel';
      case _i10.OptionnelReservation():
        return 'OptionnelReservation';
      case _i11.Paiement():
        return 'Paiement';
      case _i12.PaiementMethod():
        return 'PaiementMethod';
      case _i13.PaiementResult():
        return 'PaiementResult';
      case _i14.PaiementStatut():
        return 'PaiementStatut';
      case _i15.Reservation():
        return 'Reservation';
      case _i16.ReservationSiege():
        return 'ReservationSiege';
      case _i17.ReservationSiegeStatut():
        return 'ReservationSiegeStatut';
      case _i18.ReservationStatut():
        return 'ReservationStatut';
      case _i19.Salle():
        return 'Salle';
      case _i20.Seance():
        return 'Seance';
      case _i21.SeanceStatut():
        return 'SeanceStatut';
      case _i22.Siege():
        return 'Siege';
      case _i23.SiegeState():
        return 'SiegeState';
      case _i24.SiegeStatut():
        return 'SiegeStatut';
    }
    className = _i25.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i26.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'Greeting') {
      return deserialize<_i2.Greeting>(data['data']);
    }
    if (dataClassName == 'Billet') {
      return deserialize<_i3.Billet>(data['data']);
    }
    if (dataClassName == 'BilletResult') {
      return deserialize<_i4.BilletResult>(data['data']);
    }
    if (dataClassName == 'Cinema') {
      return deserialize<_i5.Cinema>(data['data']);
    }
    if (dataClassName == 'CodePromo') {
      return deserialize<_i6.CodePromo>(data['data']);
    }
    if (dataClassName == 'CodePromoStatut') {
      return deserialize<_i7.CodePromoStatut>(data['data']);
    }
    if (dataClassName == 'Film') {
      return deserialize<_i8.Film>(data['data']);
    }
    if (dataClassName == 'Optionnel') {
      return deserialize<_i9.Optionnel>(data['data']);
    }
    if (dataClassName == 'OptionnelReservation') {
      return deserialize<_i10.OptionnelReservation>(data['data']);
    }
    if (dataClassName == 'Paiement') {
      return deserialize<_i11.Paiement>(data['data']);
    }
    if (dataClassName == 'PaiementMethod') {
      return deserialize<_i12.PaiementMethod>(data['data']);
    }
    if (dataClassName == 'PaiementResult') {
      return deserialize<_i13.PaiementResult>(data['data']);
    }
    if (dataClassName == 'PaiementStatut') {
      return deserialize<_i14.PaiementStatut>(data['data']);
    }
    if (dataClassName == 'Reservation') {
      return deserialize<_i15.Reservation>(data['data']);
    }
    if (dataClassName == 'ReservationSiege') {
      return deserialize<_i16.ReservationSiege>(data['data']);
    }
    if (dataClassName == 'ReservationSiegeStatut') {
      return deserialize<_i17.ReservationSiegeStatut>(data['data']);
    }
    if (dataClassName == 'ReservationStatut') {
      return deserialize<_i18.ReservationStatut>(data['data']);
    }
    if (dataClassName == 'Salle') {
      return deserialize<_i19.Salle>(data['data']);
    }
    if (dataClassName == 'Seance') {
      return deserialize<_i20.Seance>(data['data']);
    }
    if (dataClassName == 'SeanceStatut') {
      return deserialize<_i21.SeanceStatut>(data['data']);
    }
    if (dataClassName == 'Siege') {
      return deserialize<_i22.Siege>(data['data']);
    }
    if (dataClassName == 'SiegeState') {
      return deserialize<_i23.SiegeState>(data['data']);
    }
    if (dataClassName == 'SiegeStatut') {
      return deserialize<_i24.SiegeStatut>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i25.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i26.Protocol().deserializeByClassName(data);
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
      return _i25.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i26.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }

  /// Maps container types (like [List], [Map], [Set]) containing
  /// [Record]s or non-String-keyed [Map]s to their JSON representation.
  ///
  /// It should not be called for [SerializableModel] types. These
  /// handle the "[Record] in container" mapping internally already.
  ///
  /// It is only supposed to be called from generated protocol code.
  ///
  /// Returns either a `List<dynamic>` (for List, Sets, and Maps with
  /// non-String keys) or a `Map<String, dynamic>` in case the input was
  /// a `Map<String, …>`.
  Object? mapContainerToJson(Object obj) {
    if (obj is! Iterable && obj is! Map) {
      throw ArgumentError.value(
        obj,
        'obj',
        'The object to serialize should be of type List, Map, or Set',
      );
    }

    dynamic mapIfNeeded(Object? obj) {
      return switch (obj) {
        Record record => mapRecordToJson(record),
        Iterable iterable => mapContainerToJson(iterable),
        Map map => mapContainerToJson(map),
        Object? value => value,
      };
    }

    switch (obj) {
      case Map<String, dynamic>():
        return {
          for (var entry in obj.entries) entry.key: mapIfNeeded(entry.value),
        };
      case Map():
        return [
          for (var entry in obj.entries)
            {
              'k': mapIfNeeded(entry.key),
              'v': mapIfNeeded(entry.value),
            },
        ];

      case Iterable():
        return [
          for (var e in obj) mapIfNeeded(e),
        ];
    }

    return obj;
  }
}
