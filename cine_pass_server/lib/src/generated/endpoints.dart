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
