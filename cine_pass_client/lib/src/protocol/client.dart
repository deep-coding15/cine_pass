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
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:cine_pass_client/src/protocol/billet_group_response.dart'
    as _i5;
import 'package:cine_pass_client/src/protocol/film_response.dart' as _i6;
import 'package:cine_pass_client/src/protocol/seance_response.dart' as _i7;
import 'package:cine_pass_client/src/protocol/cinema_response.dart' as _i8;
import 'package:cine_pass_client/src/protocol/salle.dart' as _i9;
import 'package:cine_pass_client/src/protocol/event_response.dart' as _i10;
import 'package:cine_pass_client/src/protocol/cine_pass/event_reservation_config_response.dart'
    as _i11;
import 'package:cine_pass_client/src/protocol/cine_pass/event_seat_plan_response.dart'
    as _i12;
import 'package:cine_pass_client/src/protocol/cine_pass/reservation_quote_response.dart'
    as _i13;
import 'package:cine_pass_client/src/protocol/cine_pass/reservation_confirm_response.dart'
    as _i14;
import 'package:cine_pass_client/src/protocol/structure.dart' as _i15;
import 'package:cine_pass_client/src/protocol/demande_responsable_response.dart'
    as _i16;
import 'package:cine_pass_client/src/protocol/reservation_response.dart'
    as _i17;
import 'package:cine_pass_client/src/protocol/rapport_ca_response.dart' as _i18;
import 'package:cine_pass_client/src/protocol/profile_response.dart' as _i19;
import 'package:cine_pass_client/src/protocol/greetings/greeting.dart' as _i20;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i21;
import 'protocol.dart' as _i22;

/// Exposes email/password auth and a simplified registration flow.
/// {@category Endpoint}
class EndpointEmailAuth extends _i1.EndpointEmailIdpBase {
  EndpointEmailAuth(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailAuth';

  /// Creates an email account in DB and returns a signed-in auth session.
  _i3.Future<_i4.AuthSuccess> register({
    required String email,
    required String password,
    String? fullName,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailAuth',
    'register',
    {
      'email': email,
      'password': password,
      'fullName': fullName,
    },
  );

  /// Lie un email/mot de passe a l'utilisateur deja connecte.
  /// - si l'email n'existe pas: creation du credential
  /// - si l'email existe pour le meme user: OK
  /// - si l'email existe pour un autre user: erreur
  _i3.Future<bool> ensureCredentialForCurrentUser({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<bool>(
    'emailAuth',
    'ensureCredentialForCurrentUser',
    {
      'email': email,
      'password': password,
    },
  );

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailAuth',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailAuth',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailAuth',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailAuth',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailAuth',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailAuth',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailAuth',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _i3.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailAuth',
    'hasAccount',
    {},
  );
}

/// Exposes Google sign-in methods to the client.
/// {@category Endpoint}
class EndpointGoogleIdp extends _i1.EndpointGoogleIdpBase {
  EndpointGoogleIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'googleIdp';

  @override
  _i3.Future<_i4.AuthSuccess> login({
    required String idToken,
    required String? accessToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'googleIdp',
    'login',
    {
      'idToken': idToken,
      'accessToken': accessToken,
    },
  );

  @override
  _i3.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'googleIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// {@category Endpoint}
class EndpointPhoneAuth extends _i2.EndpointRef {
  EndpointPhoneAuth(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'phoneAuth';

  _i3.Future<void> sendVerificationCode(String phoneNumber) =>
      caller.callServerEndpoint<void>(
        'phoneAuth',
        'sendVerificationCode',
        {'phoneNumber': phoneNumber},
        authenticated: false,
      );

  _i3.Future<_i4.AuthSuccess?> verifyCode(
    String phoneNumber,
    String code,
  ) => caller.callServerEndpoint<_i4.AuthSuccess?>(
    'phoneAuth',
    'verifyCode',
    {
      'phoneNumber': phoneNumber,
      'code': code,
    },
    authenticated: false,
  );
}

/// Endpoint CinePass : films, séances, cinémas, événements (données BDD).
/// {@category Endpoint}
class EndpointCinePass extends _i2.EndpointRef {
  EndpointCinePass(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'cinePass';

  /// Crée une réservation + billets après paiement (simulé).
  /// Retourne le numéro de réservation (ex: BOOK-...).
  _i3.Future<String?> createReservationAndBillets({
    required bool isEvent,
    String? seanceId,
    String? eventId,
    String? reservationNumber,
    required List<String> seatLabels,
    required List<String> ticketTypes,
    required List<bool> optionParking,
    required List<bool> optionPopcorn,
    required List<bool> optionBoisson,
    required List<double> prices,
    required double totalAmount,
  }) => caller.callServerEndpoint<String?>(
    'cinePass',
    'createReservationAndBillets',
    {
      'isEvent': isEvent,
      'seanceId': seanceId,
      'eventId': eventId,
      'reservationNumber': reservationNumber,
      'seatLabels': seatLabels,
      'ticketTypes': ticketTypes,
      'optionParking': optionParking,
      'optionPopcorn': optionPopcorn,
      'optionBoisson': optionBoisson,
      'prices': prices,
      'totalAmount': totalAmount,
    },
  );

  /// Mes billets (1 entrée par réservation, avec la liste des billets associés).
  _i3.Future<List<_i5.BilletGroupResponse>> getMyBillets() =>
      caller.callServerEndpoint<List<_i5.BilletGroupResponse>>(
        'cinePass',
        'getMyBillets',
        {},
      );

  /// Frontend: indique si l'utilisateur connecté est admin plateforme.
  _i3.Future<bool> isCurrentUserAdmin() => caller.callServerEndpoint<bool>(
    'cinePass',
    'isCurrentUserAdmin',
    {},
  );

  /// Frontend: indique si l'utilisateur connecté est responsable d'au moins une structure.
  _i3.Future<bool> isCurrentUserResponsable() =>
      caller.callServerEndpoint<bool>(
        'cinePass',
        'isCurrentUserResponsable',
        {},
      );

  /// Admin: active/desactive le role responsable pour un utilisateur via son email.
  _i3.Future<bool> setResponsableActiveByEmail({
    required String email,
    required bool active,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'setResponsableActiveByEmail',
    {
      'email': email,
      'active': active,
    },
  );

  /// Liste de tous les films.
  _i3.Future<List<_i6.FilmResponse>> getFilms() =>
      caller.callServerEndpoint<List<_i6.FilmResponse>>(
        'cinePass',
        'getFilms',
        {},
      );

  /// Détail d'un film par id.
  _i3.Future<_i6.FilmResponse?> getFilmById(String id) =>
      caller.callServerEndpoint<_i6.FilmResponse?>(
        'cinePass',
        'getFilmById',
        {'id': id},
      );

  /// Séances pour un film (avec nom cinéma, salle, ville).
  _i3.Future<List<_i7.SeanceResponse>> getSeancesForFilm(String filmId) =>
      caller.callServerEndpoint<List<_i7.SeanceResponse>>(
        'cinePass',
        'getSeancesForFilm',
        {'filmId': filmId},
      );

  /// Liste des cinémas.
  _i3.Future<List<_i8.CinemaResponse>> getCinemas() =>
      caller.callServerEndpoint<List<_i8.CinemaResponse>>(
        'cinePass',
        'getCinemas',
        {},
      );

  /// Liste des salles (pour admin séances).
  _i3.Future<List<_i9.Salle>> getSalles() =>
      caller.callServerEndpoint<List<_i9.Salle>>(
        'cinePass',
        'getSalles',
        {},
      );

  /// Liste des événements à venir.
  _i3.Future<List<_i10.EventResponse>> getEvents() =>
      caller.callServerEndpoint<List<_i10.EventResponse>>(
        'cinePass',
        'getEvents',
        {},
      );

  /// Détail d'un événement par id.
  _i3.Future<_i10.EventResponse?> getEventById(String id) =>
      caller.callServerEndpoint<_i10.EventResponse?>(
        'cinePass',
        'getEventById',
        {'id': id},
      );

  /// Configuration réservation d'un événement (publique côté lecture).
  _i3.Future<_i11.EventReservationConfigResponse?> getEventReservationConfig(
    String eventId,
  ) => caller.callServerEndpoint<_i11.EventReservationConfigResponse?>(
    'cinePass',
    'getEventReservationConfig',
    {'eventId': eventId},
  );

  /// Admin / Responsable: configure mode de réservation + types + options.
  _i3.Future<bool> setEventReservationConfig({
    required String eventId,
    required String reservationMode,
    required int maxTicketsPerOrder,
    required bool adjacentBestEffort,
    required List<String> ticketTypeCodes,
    required List<String> ticketTypeLabels,
    required List<double> ticketTypePrices,
    required List<int> ticketTypeQuotas,
    required List<String> optionTicketTypeCodes,
    required List<String> optionCodes,
    required List<String> optionLabels,
    required List<double> optionPrices,
    required List<bool> optionIncluded,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'setEventReservationConfig',
    {
      'eventId': eventId,
      'reservationMode': reservationMode,
      'maxTicketsPerOrder': maxTicketsPerOrder,
      'adjacentBestEffort': adjacentBestEffort,
      'ticketTypeCodes': ticketTypeCodes,
      'ticketTypeLabels': ticketTypeLabels,
      'ticketTypePrices': ticketTypePrices,
      'ticketTypeQuotas': ticketTypeQuotas,
      'optionTicketTypeCodes': optionTicketTypeCodes,
      'optionCodes': optionCodes,
      'optionLabels': optionLabels,
      'optionPrices': optionPrices,
      'optionIncluded': optionIncluded,
    },
  );

  /// Plan de sièges défini par le responsable (lecture publique).
  _i3.Future<_i12.EventSeatPlanResponse?> getEventSeatPlan(String eventId) =>
      caller.callServerEndpoint<_i12.EventSeatPlanResponse?>(
        'cinePass',
        'getEventSeatPlan',
        {'eventId': eventId},
      );

  /// Admin / Responsable : remplace tout le plan de sièges de l’événement.
  _i3.Future<bool> setEventSeatPlan({
    required String eventId,
    required List<String> seatLabels,
    required List<int> seatRowIndices,
    required List<int> seatColIndices,
    required List<bool> seatBlocked,
    required List<String> seatZones,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'setEventSeatPlan',
    {
      'eventId': eventId,
      'seatLabels': seatLabels,
      'seatRowIndices': seatRowIndices,
      'seatColIndices': seatColIndices,
      'seatBlocked': seatBlocked,
      'seatZones': seatZones,
    },
  );

  /// Prévisualisation de réservation (sans écriture DB).
  _i3.Future<_i13.ReservationQuoteResponse?> quoteEventReservation({
    required String eventId,
    required List<String> ticketTypeCodes,
    required List<int> quantities,
  }) => caller.callServerEndpoint<_i13.ReservationQuoteResponse?>(
    'cinePass',
    'quoteEventReservation',
    {
      'eventId': eventId,
      'ticketTypeCodes': ticketTypeCodes,
      'quantities': quantities,
    },
  );

  /// Confirme une réservation événement en mode transactionnel.
  /// [perBilletTypeCodes] : un type par billet (ex. STANDARD, VIP).
  /// [perBilletPayantOptionCsv] : pour chaque billet, codes d'options payantes séparés par des virgules (ex. "PARKING,SNACK").
  /// [perBilletSeatLabels] : si l’événement est en AVEC_SIEGES, un libellé par billet (ex. A3), ordre aligné sur [perBilletTypeCodes].
  _i3.Future<_i14.ReservationConfirmResponse> confirmEventReservation({
    required String eventId,
    required List<String> perBilletTypeCodes,
    required List<String> perBilletPayantOptionCsv,
    required List<String> perBilletSeatLabels,
  }) => caller.callServerEndpoint<_i14.ReservationConfirmResponse>(
    'cinePass',
    'confirmEventReservation',
    {
      'eventId': eventId,
      'perBilletTypeCodes': perBilletTypeCodes,
      'perBilletPayantOptionCsv': perBilletPayantOptionCsv,
      'perBilletSeatLabels': perBilletSeatLabels,
    },
  );

  /// Villes distinctes (films + événements) pour les filtres.
  /// Une entrée par ville « logique » (insensible à la casse).
  _i3.Future<List<String>> getCities() =>
      caller.callServerEndpoint<List<String>>(
        'cinePass',
        'getCities',
        {},
      );

  /// Genres distincts (films) pour les filtres.
  _i3.Future<List<String>> getGenres() =>
      caller.callServerEndpoint<List<String>>(
        'cinePass',
        'getGenres',
        {},
      );

  /// Catégories d'événements pour les filtres.
  _i3.Future<List<String>> getEventCategories() =>
      caller.callServerEndpoint<List<String>>(
        'cinePass',
        'getEventCategories',
        {},
      );

  /// Valeurs de filtre dynamiques selon le type d'événement.
  _i3.Future<List<String>> getEventDynamicFilterValues({
    required String eventType,
    required String filterKey,
  }) => caller.callServerEndpoint<List<String>>(
    'cinePass',
    'getEventDynamicFilterValues',
    {
      'eventType': eventType,
      'filterKey': filterKey,
    },
  );

  /// Admin: créer un film.
  _i3.Future<_i6.FilmResponse?> createFilm({
    required String title,
    required String genre,
    required int durationMinutes,
    String? synopsis,
    String? director,
    String? casting,
    int? posterColor,
    String? posterUrl,
    Object? dateSortie,
    Object? dateFin,
    String? audience,
  }) => caller.callServerEndpoint<_i6.FilmResponse?>(
    'cinePass',
    'createFilm',
    {
      'title': title,
      'genre': genre,
      'durationMinutes': durationMinutes,
      'synopsis': synopsis,
      'director': director,
      'casting': casting,
      'posterColor': posterColor,
      'posterUrl': posterUrl,
      'dateSortie': dateSortie,
      'dateFin': dateFin,
      'audience': audience,
    },
  );

  /// Admin / Responsable: créer un événement (optionnellement lié à une structure).
  _i3.Future<_i10.EventResponse?> createEvent({
    required String titre,
    required String categorie,
    String? description,
    required String lieu,
    String? adresse,
    required String ville,
    required DateTime eventDate,
    required String eventTimeStr,
    required int placesTotal,
    required double prixBase,
    int? posterColor,
    String? posterUrl,
    String? structureId,
    String? eventTypedDetailsJson,
  }) => caller.callServerEndpoint<_i10.EventResponse?>(
    'cinePass',
    'createEvent',
    {
      'titre': titre,
      'categorie': categorie,
      'description': description,
      'lieu': lieu,
      'adresse': adresse,
      'ville': ville,
      'eventDate': eventDate,
      'eventTimeStr': eventTimeStr,
      'placesTotal': placesTotal,
      'prixBase': prixBase,
      'posterColor': posterColor,
      'posterUrl': posterUrl,
      'structureId': structureId,
      'eventTypedDetailsJson': eventTypedDetailsJson,
    },
  );

  /// Liste de toutes les structures (admin).
  _i3.Future<List<_i15.Structure>> getStructures() =>
      caller.callServerEndpoint<List<_i15.Structure>>(
        'cinePass',
        'getStructures',
        {},
      );

  /// Détail d'une structure par id (admin).
  _i3.Future<_i15.Structure?> getStructureById(String id) =>
      caller.callServerEndpoint<_i15.Structure?>(
        'cinePass',
        'getStructureById',
        {'id': id},
      );

  /// Mettre à jour un événement (admin ou responsable de la structure).
  _i3.Future<_i10.EventResponse?> updateEvent({
    required String id,
    String? titre,
    String? categorie,
    String? description,
    String? lieu,
    String? adresse,
    String? ville,
    DateTime? eventDate,
    String? eventTimeStr,
    int? placesTotal,
    double? prixBase,
    int? posterColor,
    String? posterUrl,
    String? eventTypedDetailsJson,
  }) => caller.callServerEndpoint<_i10.EventResponse?>(
    'cinePass',
    'updateEvent',
    {
      'id': id,
      'titre': titre,
      'categorie': categorie,
      'description': description,
      'lieu': lieu,
      'adresse': adresse,
      'ville': ville,
      'eventDate': eventDate,
      'eventTimeStr': eventTimeStr,
      'placesTotal': placesTotal,
      'prixBase': prixBase,
      'posterColor': posterColor,
      'posterUrl': posterUrl,
      'eventTypedDetailsJson': eventTypedDetailsJson,
    },
  );

  /// Supprimer un événement (admin ou responsable de la structure).
  _i3.Future<bool> deleteEvent(String id) => caller.callServerEndpoint<bool>(
    'cinePass',
    'deleteEvent',
    {'id': id},
  );

  /// Structure(s) assignée(s) au responsable connecté.
  _i3.Future<_i15.Structure?> getMyStructure() =>
      caller.callServerEndpoint<_i15.Structure?>(
        'cinePass',
        'getMyStructure',
        {},
      );

  /// Responsable: mettre à jour les informations de sa structure assignée.
  /// Admin: peut aussi mettre à jour n'importe quelle structure via structureId.
  _i3.Future<_i15.Structure?> updateMyStructure({
    String? structureId,
    String? name,
    String? city,
    String? address,
    String? website,
    String? phone,
  }) => caller.callServerEndpoint<_i15.Structure?>(
    'cinePass',
    'updateMyStructure',
    {
      'structureId': structureId,
      'name': name,
      'city': city,
      'address': address,
      'website': website,
      'phone': phone,
    },
  );

  /// Admin: désactiver une structure côté responsable (assignments inactifs).
  _i3.Future<bool> banStructure(String structureId) =>
      caller.callServerEndpoint<bool>(
        'cinePass',
        'banStructure',
        {'structureId': structureId},
      );

  /// Admin: supprimer une structure.
  _i3.Future<bool> deleteStructure(String structureId) =>
      caller.callServerEndpoint<bool>(
        'cinePass',
        'deleteStructure',
        {'structureId': structureId},
      );

  /// Événements des structures du responsable connecté.
  _i3.Future<List<_i10.EventResponse>> getMyEvents() =>
      caller.callServerEndpoint<List<_i10.EventResponse>>(
        'cinePass',
        'getMyEvents',
        {},
      );

  /// Admin: demandes en attente (devenir responsable).
  _i3.Future<List<_i16.DemandeResponsableResponse>> getDemandesEnAttente() =>
      caller.callServerEndpoint<List<_i16.DemandeResponsableResponse>>(
        'cinePass',
        'getDemandesEnAttente',
        {},
      );

  /// Admin: approuver une demande responsable → crée la structure et l'assignment.
  _i3.Future<bool> approuverDemande(String id) =>
      caller.callServerEndpoint<bool>(
        'cinePass',
        'approuverDemande',
        {'id': id},
      );

  /// Admin: rejeter une demande responsable.
  _i3.Future<bool> rejeterDemande(
    String id,
    String reason,
  ) => caller.callServerEndpoint<bool>(
    'cinePass',
    'rejeterDemande',
    {
      'id': id,
      'reason': reason,
    },
  );

  /// Créer une demande pour devenir responsable (utilisateur connecté).
  _i3.Future<_i16.DemandeResponsableResponse?> createDemandeResponsable({
    required String structureType,
    required String structureName,
    required String structureCity,
    String? structureAddress,
    String? structureWebsite,
    String? structurePhone,
    required String description,
  }) => caller.callServerEndpoint<_i16.DemandeResponsableResponse?>(
    'cinePass',
    'createDemandeResponsable',
    {
      'structureType': structureType,
      'structureName': structureName,
      'structureCity': structureCity,
      'structureAddress': structureAddress,
      'structureWebsite': structureWebsite,
      'structurePhone': structurePhone,
      'description': description,
    },
  );

  /// Utilisateur connecté: indique s'il a déjà une demande responsable en attente.
  _i3.Future<bool> hasMyPendingDemandeResponsable() =>
      caller.callServerEndpoint<bool>(
        'cinePass',
        'hasMyPendingDemandeResponsable',
        {},
      );

  /// Liste des films favoris de l'utilisateur connecté.
  _i3.Future<List<String>> getMyFavoriteFilmIds() =>
      caller.callServerEndpoint<List<String>>(
        'cinePass',
        'getMyFavoriteFilmIds',
        {},
      );

  /// Ajoute / retire un film des favoris de l'utilisateur connecté.
  _i3.Future<bool> setMyFilmFavorite({
    required String filmId,
    required bool isFavorite,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'setMyFilmFavorite',
    {
      'filmId': filmId,
      'isFavorite': isFavorite,
    },
  );

  /// Liste des événements favoris de l'utilisateur connecté.
  _i3.Future<List<String>> getMyFavoriteEventIds() =>
      caller.callServerEndpoint<List<String>>(
        'cinePass',
        'getMyFavoriteEventIds',
        {},
      );

  /// Ajoute / retire un événement des favoris de l'utilisateur connecté.
  _i3.Future<bool> setMyEventFavorite({
    required String eventId,
    required bool isFavorite,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'setMyEventFavorite',
    {
      'eventId': eventId,
      'isFavorite': isFavorite,
    },
  );

  /// Client: annuler sa réservation événement si >= 2h avant le début.
  _i3.Future<bool> cancelMyEventReservation({
    required String reservationNumber,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'cancelMyEventReservation',
    {'reservationNumber': reservationNumber},
  );

  /// Admin: toutes les réservations (événements et séances).
  _i3.Future<List<_i17.ReservationResponse>> getReservations() =>
      caller.callServerEndpoint<List<_i17.ReservationResponse>>(
        'cinePass',
        'getReservations',
        {},
      );

  /// Responsable: réservations pour les événements de ses structures.
  _i3.Future<List<_i17.ReservationResponse>> getReservationsForMyStructures() =>
      caller.callServerEndpoint<List<_i17.ReservationResponse>>(
        'cinePass',
        'getReservationsForMyStructures',
        {},
      );

  /// Admin/Responsable: archiver un événement (retire des listings futurs).
  _i3.Future<bool> archiveEvent(String eventId) =>
      caller.callServerEndpoint<bool>(
        'cinePass',
        'archiveEvent',
        {'eventId': eventId},
      );

  /// Admin/Responsable: désarchiver un événement (réaffiche au catalogue public).
  _i3.Future<bool> unarchiveEvent(String eventId) =>
      caller.callServerEndpoint<bool>(
        'cinePass',
        'unarchiveEvent',
        {'eventId': eventId},
      );

  /// Responsable: détails billets d'une réservation de ses structures.
  _i3.Future<List<String>> getReservationBilletDetailsForMyStructures({
    required String reservationId,
  }) => caller.callServerEndpoint<List<String>>(
    'cinePass',
    'getReservationBilletDetailsForMyStructures',
    {'reservationId': reservationId},
  );

  /// Responsable: changement de statut d'une réservation de ses structures.
  _i3.Future<bool> updateReservationStatusForMyStructures({
    required String reservationId,
    required String status,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'updateReservationStatusForMyStructures',
    {
      'reservationId': reservationId,
      'status': status,
    },
  );

  /// Responsable: rapport CA sur une période (7j, 30j, 3m, 1an).
  _i3.Future<_i18.RapportCAResponse> getRapportCA(String periode) =>
      caller.callServerEndpoint<_i18.RapportCAResponse>(
        'cinePass',
        'getRapportCA',
        {'periode': periode},
      );

  /// Admin: créer une séance.
  _i3.Future<_i7.SeanceResponse?> createSeance({
    required String filmId,
    required String salleId,
    required Object debutAt,
    Object? finAt,
    required String format,
    required String type,
    required double prixBase,
  }) => caller.callServerEndpoint<_i7.SeanceResponse?>(
    'cinePass',
    'createSeance',
    {
      'filmId': filmId,
      'salleId': salleId,
      'debutAt': debutAt,
      'finAt': finAt,
      'format': format,
      'type': type,
      'prixBase': prixBase,
    },
  );

  /// Profil de l'utilisateur connecté (displayName, phone, birthDate).
  /// Retourne null si non authentifié.
  _i3.Future<_i19.ProfileResponse?> getProfile() =>
      caller.callServerEndpoint<_i19.ProfileResponse?>(
        'cinePass',
        'getProfile',
        {},
      );

  /// Admin: liste des utilisateurs (profil auth + téléphone/date locale si disponible).
  _i3.Future<List<_i19.ProfileResponse>> getAdminUsers() =>
      caller.callServerEndpoint<List<_i19.ProfileResponse>>(
        'cinePass',
        'getAdminUsers',
        {},
      );

  /// Admin: modifier le rôle d'un utilisateur.
  _i3.Future<bool> setAdminUserRole({
    required String userId,
    required String role,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'setAdminUserRole',
    {
      'userId': userId,
      'role': role,
    },
  );

  /// Admin: supprimer un utilisateur.
  _i3.Future<bool> deleteAdminUser({required String userId}) =>
      caller.callServerEndpoint<bool>(
        'cinePass',
        'deleteAdminUser',
        {'userId': userId},
      );

  /// Met à jour le profil de l'utilisateur connecté.
  /// Seuls les champs non null sont mis à jour.
  _i3.Future<bool> updateProfile({
    String? displayName,
    String? phone,
    String? birthDate,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'updateProfile',
    {
      'displayName': displayName,
      'phone': phone,
      'birthDate': birthDate,
    },
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i2.EndpointRef {
  EndpointGreeting(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i3.Future<_i20.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i20.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i21.Caller(client);
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i21.Caller auth;

  late final _i1.Caller serverpod_auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i22.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailAuth = EndpointEmailAuth(this);
    googleIdp = EndpointGoogleIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    phoneAuth = EndpointPhoneAuth(this);
    cinePass = EndpointCinePass(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailAuth emailAuth;

  late final EndpointGoogleIdp googleIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointPhoneAuth phoneAuth;

  late final EndpointCinePass cinePass;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailAuth': emailAuth,
    'googleIdp': googleIdp,
    'jwtRefresh': jwtRefresh,
    'phoneAuth': phoneAuth,
    'cinePass': cinePass,
    'greeting': greeting,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'auth': modules.auth,
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
