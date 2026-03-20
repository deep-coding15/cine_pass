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
import 'package:cine_pass_client/src/protocol/structure.dart' as _i11;
import 'package:cine_pass_client/src/protocol/demande_responsable_response.dart'
    as _i12;
import 'package:cine_pass_client/src/protocol/reservation_response.dart'
    as _i13;
import 'package:cine_pass_client/src/protocol/rapport_ca_response.dart' as _i14;
import 'package:cine_pass_client/src/protocol/profile_response.dart' as _i15;
import 'package:cine_pass_client/src/protocol/greetings/greeting.dart' as _i16;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i17;
import 'protocol.dart' as _i18;

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

  /// Frontend: récupère tous les rôles actifs de l'utilisateur connecté.
  _i3.Future<List<String>> getUserRoles() =>
      caller.callServerEndpoint<List<String>>(
        'cinePass',
        'getUserRoles',
        {},
      );

  /// Frontend: indique si l'utilisateur connecté est admin.
  _i3.Future<bool> isCurrentUserAdmin() => caller.callServerEndpoint<bool>(
    'cinePass',
    'isCurrentUserAdmin',
    {},
  );

  /// Frontend: indique si l'utilisateur connecté est responsable.
  _i3.Future<bool> isCurrentUserResponsable() =>
      caller.callServerEndpoint<bool>(
        'cinePass',
        'isCurrentUserResponsable',
        {},
      );

  /// Admin: change le statut d'un rôle utilisateur (actif, inactif, bloqué, banni).
  _i3.Future<bool> setRoleStatus({
    required String userEmail,
    required String role,
    required String newStatus,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'setRoleStatus',
    {
      'userEmail': userEmail,
      'role': role,
      'newStatus': newStatus,
    },
  );

  /// Admin: crée une demande de changement de rôle critique (admin ↔ responsable).
  /// Retourne l'ID de la demande, ou null si erreur.
  /// Requiert 2 approbations minimum avant application.
  _i3.Future<String?> createRoleChangeRequest({
    required String userEmail,
    required String toRole,
  }) => caller.callServerEndpoint<String?>(
    'cinePass',
    'createRoleChangeRequest',
    {
      'userEmail': userEmail,
      'toRole': toRole,
    },
  );

  /// Admin: approuve une demande de changement de rôle.
  /// Retourne true si approbation enregistrée (changement appliqué si 2 approbations atteintes).
  _i3.Future<bool> approveRoleChangeRequest({
    required String changeRequestId,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'approveRoleChangeRequest',
    {'changeRequestId': changeRequestId},
  );

  /// Admin: rejette une demande de changement de rôle.
  _i3.Future<bool> rejectRoleChangeRequest({
    required String changeRequestId,
    required String reason,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'rejectRoleChangeRequest',
    {
      'changeRequestId': changeRequestId,
      'reason': reason,
    },
  );

  /// Admin: simule une promotion directe (pour test/migration).
  /// N'utilise PAS le système de demande critique.
  /// À utiliser avec prudence (admin direct seulement).
  @Deprecated(
    'Utiliser createRoleChangeRequest + approveRoleChangeRequest à la place',
  )
  _i3.Future<bool> grantRoleByEmail({
    required String email,
    required String role,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'grantRoleByEmail',
    {
      'email': email,
      'role': role,
    },
  );

  /// Admin: retire un rôle cote frontend en le bloquant en base.
  _i3.Future<bool> revokeRoleByEmail({
    required String email,
    required String role,
  }) => caller.callServerEndpoint<bool>(
    'cinePass',
    'revokeRoleByEmail',
    {
      'email': email,
      'role': role,
    },
  );

  /// Admin: récupère les rôles d'un utilisateur.
  _i3.Future<List<String>> getRolesByEmail({required String email}) =>
      caller.callServerEndpoint<List<String>>(
        'cinePass',
        'getRolesByEmail',
        {'email': email},
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

  /// Villes distinctes (films + événements) pour les filtres.
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
    required Object eventDate,
    required String eventTimeStr,
    required int placesTotal,
    required double prixBase,
    int? posterColor,
    String? posterUrl,
    String? structureId,
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
    },
  );

  /// Liste de toutes les structures (admin).
  _i3.Future<List<_i11.Structure>> getStructures() =>
      caller.callServerEndpoint<List<_i11.Structure>>(
        'cinePass',
        'getStructures',
        {},
      );

  /// Détail d'une structure par id (admin).
  _i3.Future<_i11.Structure?> getStructureById(String id) =>
      caller.callServerEndpoint<_i11.Structure?>(
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
    Object? eventDate,
    String? eventTimeStr,
    int? placesTotal,
    double? prixBase,
    int? posterColor,
    String? posterUrl,
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
    },
  );

  /// Supprimer un événement (admin ou responsable de la structure).
  _i3.Future<bool> deleteEvent(String id) => caller.callServerEndpoint<bool>(
    'cinePass',
    'deleteEvent',
    {'id': id},
  );

  /// Structure(s) assignée(s) au responsable connecté.
  _i3.Future<_i11.Structure?> getMyStructure() =>
      caller.callServerEndpoint<_i11.Structure?>(
        'cinePass',
        'getMyStructure',
        {},
      );

  /// Événements des structures du responsable connecté.
  _i3.Future<List<_i10.EventResponse>> getMyEvents() =>
      caller.callServerEndpoint<List<_i10.EventResponse>>(
        'cinePass',
        'getMyEvents',
        {},
      );

  /// Admin: demandes en attente (devenir responsable).
  _i3.Future<List<_i12.DemandeResponsableResponse>> getDemandesEnAttente() =>
      caller.callServerEndpoint<List<_i12.DemandeResponsableResponse>>(
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
  _i3.Future<_i12.DemandeResponsableResponse?> createDemandeResponsable({
    required String structureType,
    required String structureName,
    required String structureCity,
    String? structureAddress,
    String? structureWebsite,
    String? structurePhone,
    required String description,
  }) => caller.callServerEndpoint<_i12.DemandeResponsableResponse?>(
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

  /// Admin: toutes les réservations (événements et séances).
  _i3.Future<List<_i13.ReservationResponse>> getReservations() =>
      caller.callServerEndpoint<List<_i13.ReservationResponse>>(
        'cinePass',
        'getReservations',
        {},
      );

  /// Responsable: réservations pour les événements de ses structures.
  _i3.Future<List<_i13.ReservationResponse>> getReservationsForMyStructures() =>
      caller.callServerEndpoint<List<_i13.ReservationResponse>>(
        'cinePass',
        'getReservationsForMyStructures',
        {},
      );

  /// Responsable: rapport CA sur une période (7j, 30j, 3m, 1an).
  _i3.Future<_i14.RapportCAResponse> getRapportCA(String periode) =>
      caller.callServerEndpoint<_i14.RapportCAResponse>(
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
  _i3.Future<_i15.ProfileResponse?> getProfile() =>
      caller.callServerEndpoint<_i15.ProfileResponse?>(
        'cinePass',
        'getProfile',
        {},
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
  _i3.Future<_i16.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i16.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i17.Caller(client);
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i17.Caller auth;

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
         _i18.Protocol(),
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
