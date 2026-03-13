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
import 'package:serverpod/serverpod.dart' as _i1;
import '../auth/email_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../cine_pass/cine_pass_endpoint.dart' as _i4;
import '../greetings/greeting_endpoint.dart' as _i5;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i6;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i7;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailIdp': _i2.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'cinePass': _i4.CinePassEndpoint()
        ..initialize(
          server,
          'cinePass',
          null,
        ),
      'greeting': _i5.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i3.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['cinePass'] = _i1.EndpointConnector(
      name: 'cinePass',
      endpoint: endpoints['cinePass']!,
      methodConnectors: {
        'getFilms': _i1.MethodConnector(
          name: 'getFilms',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getFilms(session),
        ),
        'getFilmById': _i1.MethodConnector(
          name: 'getFilmById',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cinePass'] as _i4.CinePassEndpoint).getFilmById(
                    session,
                    params['id'],
                  ),
        ),
        'getSeancesForFilm': _i1.MethodConnector(
          name: 'getSeancesForFilm',
          params: {
            'filmId': _i1.ParameterDescription(
              name: 'filmId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getSeancesForFilm(
                    session,
                    params['filmId'],
                  ),
        ),
        'getCinemas': _i1.MethodConnector(
          name: 'getCinemas',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getCinemas(session),
        ),
        'getSalles': _i1.MethodConnector(
          name: 'getSalles',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getSalles(session),
        ),
        'getEvents': _i1.MethodConnector(
          name: 'getEvents',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getEvents(session),
        ),
        'getEventById': _i1.MethodConnector(
          name: 'getEventById',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cinePass'] as _i4.CinePassEndpoint).getEventById(
                    session,
                    params['id'],
                  ),
        ),
        'getCities': _i1.MethodConnector(
          name: 'getCities',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getCities(session),
        ),
        'getGenres': _i1.MethodConnector(
          name: 'getGenres',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getGenres(session),
        ),
        'getEventCategories': _i1.MethodConnector(
          name: 'getEventCategories',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getEventCategories(session),
        ),
        'createFilm': _i1.MethodConnector(
          name: 'createFilm',
          params: {
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'genre': _i1.ParameterDescription(
              name: 'genre',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'durationMinutes': _i1.ParameterDescription(
              name: 'durationMinutes',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'synopsis': _i1.ParameterDescription(
              name: 'synopsis',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'director': _i1.ParameterDescription(
              name: 'director',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'casting': _i1.ParameterDescription(
              name: 'casting',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'posterColor': _i1.ParameterDescription(
              name: 'posterColor',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'dateSortie': _i1.ParameterDescription(
              name: 'dateSortie',
              type: _i1.getType<Object?>(),
              nullable: true,
            ),
            'dateFin': _i1.ParameterDescription(
              name: 'dateFin',
              type: _i1.getType<Object?>(),
              nullable: true,
            ),
            'audience': _i1.ParameterDescription(
              name: 'audience',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cinePass'] as _i4.CinePassEndpoint).createFilm(
                    session,
                    title: params['title'],
                    genre: params['genre'],
                    durationMinutes: params['durationMinutes'],
                    synopsis: params['synopsis'],
                    director: params['director'],
                    casting: params['casting'],
                    posterColor: params['posterColor'],
                    dateSortie: params['dateSortie'],
                    dateFin: params['dateFin'],
                    audience: params['audience'],
                  ),
        ),
        'createEvent': _i1.MethodConnector(
          name: 'createEvent',
          params: {
            'titre': _i1.ParameterDescription(
              name: 'titre',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'categorie': _i1.ParameterDescription(
              name: 'categorie',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'lieu': _i1.ParameterDescription(
              name: 'lieu',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'adresse': _i1.ParameterDescription(
              name: 'adresse',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'ville': _i1.ParameterDescription(
              name: 'ville',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'eventDate': _i1.ParameterDescription(
              name: 'eventDate',
              type: _i1.getType<Object>(),
              nullable: false,
            ),
            'eventTimeStr': _i1.ParameterDescription(
              name: 'eventTimeStr',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'placesTotal': _i1.ParameterDescription(
              name: 'placesTotal',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'prixBase': _i1.ParameterDescription(
              name: 'prixBase',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'posterColor': _i1.ParameterDescription(
              name: 'posterColor',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'structureId': _i1.ParameterDescription(
              name: 'structureId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cinePass'] as _i4.CinePassEndpoint).createEvent(
                    session,
                    titre: params['titre'],
                    categorie: params['categorie'],
                    description: params['description'],
                    lieu: params['lieu'],
                    adresse: params['adresse'],
                    ville: params['ville'],
                    eventDate: params['eventDate'],
                    eventTimeStr: params['eventTimeStr'],
                    placesTotal: params['placesTotal'],
                    prixBase: params['prixBase'],
                    posterColor: params['posterColor'],
                    structureId: params['structureId'],
                  ),
        ),
        'getStructures': _i1.MethodConnector(
          name: 'getStructures',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getStructures(session),
        ),
        'getStructureById': _i1.MethodConnector(
          name: 'getStructureById',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getStructureById(
                    session,
                    params['id'],
                  ),
        ),
        'updateEvent': _i1.MethodConnector(
          name: 'updateEvent',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'titre': _i1.ParameterDescription(
              name: 'titre',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'categorie': _i1.ParameterDescription(
              name: 'categorie',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'lieu': _i1.ParameterDescription(
              name: 'lieu',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'adresse': _i1.ParameterDescription(
              name: 'adresse',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'ville': _i1.ParameterDescription(
              name: 'ville',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'eventDate': _i1.ParameterDescription(
              name: 'eventDate',
              type: _i1.getType<Object?>(),
              nullable: true,
            ),
            'eventTimeStr': _i1.ParameterDescription(
              name: 'eventTimeStr',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'placesTotal': _i1.ParameterDescription(
              name: 'placesTotal',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'prixBase': _i1.ParameterDescription(
              name: 'prixBase',
              type: _i1.getType<double?>(),
              nullable: true,
            ),
            'posterColor': _i1.ParameterDescription(
              name: 'posterColor',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cinePass'] as _i4.CinePassEndpoint).updateEvent(
                    session,
                    id: params['id'],
                    titre: params['titre'],
                    categorie: params['categorie'],
                    description: params['description'],
                    lieu: params['lieu'],
                    adresse: params['adresse'],
                    ville: params['ville'],
                    eventDate: params['eventDate'],
                    eventTimeStr: params['eventTimeStr'],
                    placesTotal: params['placesTotal'],
                    prixBase: params['prixBase'],
                    posterColor: params['posterColor'],
                  ),
        ),
        'deleteEvent': _i1.MethodConnector(
          name: 'deleteEvent',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cinePass'] as _i4.CinePassEndpoint).deleteEvent(
                    session,
                    params['id'],
                  ),
        ),
        'getMyStructure': _i1.MethodConnector(
          name: 'getMyStructure',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getMyStructure(session),
        ),
        'getMyEvents': _i1.MethodConnector(
          name: 'getMyEvents',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getMyEvents(session),
        ),
        'getDemandesEnAttente': _i1.MethodConnector(
          name: 'getDemandesEnAttente',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getDemandesEnAttente(session),
        ),
        'approuverDemande': _i1.MethodConnector(
          name: 'approuverDemande',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .approuverDemande(session, params['id']),
        ),
        'rejeterDemande': _i1.MethodConnector(
          name: 'rejeterDemande',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'reason': _i1.ParameterDescription(
              name: 'reason',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .rejeterDemande(session, params['id'], params['reason']),
        ),
        'createDemandeResponsable': _i1.MethodConnector(
          name: 'createDemandeResponsable',
          params: {
            'structureType': _i1.ParameterDescription(
              name: 'structureType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'structureName': _i1.ParameterDescription(
              name: 'structureName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'structureCity': _i1.ParameterDescription(
              name: 'structureCity',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'structureAddress': _i1.ParameterDescription(
              name: 'structureAddress',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'structureWebsite': _i1.ParameterDescription(
              name: 'structureWebsite',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'structurePhone': _i1.ParameterDescription(
              name: 'structurePhone',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cinePass'] as _i4.CinePassEndpoint)
                      .createDemandeResponsable(
                    session,
                    structureType: params['structureType'],
                    structureName: params['structureName'],
                    structureCity: params['structureCity'],
                    structureAddress: params['structureAddress'],
                    structureWebsite: params['structureWebsite'],
                    structurePhone: params['structurePhone'],
                    description: params['description'],
                  ),
        ),
        'getReservations': _i1.MethodConnector(
          name: 'getReservations',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getReservations(session),
        ),
        'getReservationsForMyStructures': _i1.MethodConnector(
          name: 'getReservationsForMyStructures',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getReservationsForMyStructures(session),
        ),
        'getRapportCA': _i1.MethodConnector(
          name: 'getRapportCA',
          params: {
            'periode': _i1.ParameterDescription(
              name: 'periode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i4.CinePassEndpoint)
                  .getRapportCA(session, params['periode']),
        ),
        'createSeance': _i1.MethodConnector(
          name: 'createSeance',
          params: {
            'filmId': _i1.ParameterDescription(
              name: 'filmId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'salleId': _i1.ParameterDescription(
              name: 'salleId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'debutAt': _i1.ParameterDescription(
              name: 'debutAt',
              type: _i1.getType<Object>(),
              nullable: false,
            ),
            'finAt': _i1.ParameterDescription(
              name: 'finAt',
              type: _i1.getType<Object?>(),
              nullable: true,
            ),
            'format': _i1.ParameterDescription(
              name: 'format',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'type': _i1.ParameterDescription(
              name: 'type',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'prixBase': _i1.ParameterDescription(
              name: 'prixBase',
              type: _i1.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cinePass'] as _i4.CinePassEndpoint).createSeance(
                    session,
                    filmId: params['filmId'],
                    salleId: params['salleId'],
                    debutAt: params['debutAt'],
                    finAt: params['finAt'],
                    format: params['format'],
                    type: params['type'],
                    prixBase: params['prixBase'],
                  ),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i5.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i6.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i7.Endpoints()
      ..initializeEndpoints(server);
  }
}
