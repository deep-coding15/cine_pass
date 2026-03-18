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
import '../auth/google_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../auth/phone_auth_endpoint.dart' as _i4;
import '../cine_pass/cine_pass_endpoint.dart' as _i5;
import '../greetings/greeting_endpoint.dart' as _i6;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i7;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i8;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i9;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'googleIdp': _i2.GoogleIdpEndpoint()
        ..initialize(
          server,
          'googleIdp',
          null,
        ),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'phoneAuth': _i4.PhoneAuthEndpoint()
        ..initialize(
          server,
          'phoneAuth',
          null,
        ),
      'cinePass': _i5.CinePassEndpoint()
        ..initialize(
          server,
          'cinePass',
          null,
        ),
      'greeting': _i6.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['googleIdp'] = _i1.EndpointConnector(
      name: 'googleIdp',
      endpoint: endpoints['googleIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'idToken': _i1.ParameterDescription(
              name: 'idToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'accessToken': _i1.ParameterDescription(
              name: 'accessToken',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['googleIdp'] as _i2.GoogleIdpEndpoint).login(
                    session,
                    idToken: params['idToken'],
                    accessToken: params['accessToken'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleIdp'] as _i2.GoogleIdpEndpoint)
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
    connectors['phoneAuth'] = _i1.EndpointConnector(
      name: 'phoneAuth',
      endpoint: endpoints['phoneAuth']!,
      methodConnectors: {
        'sendVerificationCode': _i1.MethodConnector(
          name: 'sendVerificationCode',
          params: {
            'phoneNumber': _i1.ParameterDescription(
              name: 'phoneNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['phoneAuth'] as _i4.PhoneAuthEndpoint)
                  .sendVerificationCode(
                    session,
                    params['phoneNumber'],
                  ),
        ),
        'verifyCode': _i1.MethodConnector(
          name: 'verifyCode',
          params: {
            'phoneNumber': _i1.ParameterDescription(
              name: 'phoneNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'code': _i1.ParameterDescription(
              name: 'code',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['phoneAuth'] as _i4.PhoneAuthEndpoint).verifyCode(
                    session,
                    params['phoneNumber'],
                    params['code'],
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
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
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
                  (endpoints['cinePass'] as _i5.CinePassEndpoint).getFilmById(
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
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
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
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
                  .getCinemas(session),
        ),
        'getSalles': _i1.MethodConnector(
          name: 'getSalles',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
                  .getSalles(session),
        ),
        'getEvents': _i1.MethodConnector(
          name: 'getEvents',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
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
                  (endpoints['cinePass'] as _i5.CinePassEndpoint).getEventById(
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
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
                  .getCities(session),
        ),
        'getGenres': _i1.MethodConnector(
          name: 'getGenres',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
                  .getGenres(session),
        ),
        'getEventCategories': _i1.MethodConnector(
          name: 'getEventCategories',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
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
                  (endpoints['cinePass'] as _i5.CinePassEndpoint).createFilm(
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
                  (endpoints['cinePass'] as _i5.CinePassEndpoint).createEvent(
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
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
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
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
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
                  (endpoints['cinePass'] as _i5.CinePassEndpoint).updateEvent(
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
                  (endpoints['cinePass'] as _i5.CinePassEndpoint).deleteEvent(
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
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
                  .getMyStructure(session),
        ),
        'getMyEvents': _i1.MethodConnector(
          name: 'getMyEvents',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
                  .getMyEvents(session),
        ),
        'getDemandesEnAttente': _i1.MethodConnector(
          name: 'getDemandesEnAttente',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
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
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
                  .approuverDemande(
                    session,
                    params['id'],
                  ),
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
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
                  .rejeterDemande(
                    session,
                    params['id'],
                    params['reason'],
                  ),
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
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
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
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
                  .getReservations(session),
        ),
        'getReservationsForMyStructures': _i1.MethodConnector(
          name: 'getReservationsForMyStructures',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i5.CinePassEndpoint)
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
              ) async =>
                  (endpoints['cinePass'] as _i5.CinePassEndpoint).getRapportCA(
                    session,
                    params['periode'],
                  ),
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
                  (endpoints['cinePass'] as _i5.CinePassEndpoint).createSeance(
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
              ) async => (endpoints['greeting'] as _i6.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    modules['serverpod_auth'] = _i7.Endpoints()..initializeEndpoints(server);
    modules['serverpod_auth_idp'] = _i8.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i9.Endpoints()
      ..initializeEndpoints(server);
  }
}
