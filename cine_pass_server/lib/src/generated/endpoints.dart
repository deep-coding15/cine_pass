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
import '../auth/google_idp_endpoint.dart' as _i3;
import '../auth/jwt_refresh_endpoint.dart' as _i4;
import '../auth/phone_auth_endpoint.dart' as _i5;
import '../cine_pass/cine_pass_endpoint.dart' as _i6;
import '../greetings/greeting_endpoint.dart' as _i7;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i8;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i9;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i10;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailAuth': _i2.EmailAuthEndpoint()
        ..initialize(
          server,
          'emailAuth',
          null,
        ),
      'googleIdp': _i3.GoogleIdpEndpoint()
        ..initialize(
          server,
          'googleIdp',
          null,
        ),
      'jwtRefresh': _i4.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'phoneAuth': _i5.PhoneAuthEndpoint()
        ..initialize(
          server,
          'phoneAuth',
          null,
        ),
      'cinePass': _i6.CinePassEndpoint()
        ..initialize(
          server,
          'cinePass',
          null,
        ),
      'greeting': _i7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailAuth'] = _i1.EndpointConnector(
      name: 'emailAuth',
      endpoint: endpoints['emailAuth']!,
      methodConnectors: {
        'register': _i1.MethodConnector(
          name: 'register',
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
            'fullName': _i1.ParameterDescription(
              name: 'fullName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailAuth'] as _i2.EmailAuthEndpoint).register(
                    session,
                    email: params['email'],
                    password: params['password'],
                    fullName: params['fullName'],
                  ),
        ),
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
              ) async =>
                  (endpoints['emailAuth'] as _i2.EmailAuthEndpoint).login(
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
              ) async => (endpoints['emailAuth'] as _i2.EmailAuthEndpoint)
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
              ) async => (endpoints['emailAuth'] as _i2.EmailAuthEndpoint)
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
              ) async => (endpoints['emailAuth'] as _i2.EmailAuthEndpoint)
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
              ) async => (endpoints['emailAuth'] as _i2.EmailAuthEndpoint)
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
              ) async => (endpoints['emailAuth'] as _i2.EmailAuthEndpoint)
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
              ) async => (endpoints['emailAuth'] as _i2.EmailAuthEndpoint)
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
              ) async => (endpoints['emailAuth'] as _i2.EmailAuthEndpoint)
                  .hasAccount(session),
        ),
      },
    );
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
                  (endpoints['googleIdp'] as _i3.GoogleIdpEndpoint).login(
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
              ) async => (endpoints['googleIdp'] as _i3.GoogleIdpEndpoint)
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
              ) async => (endpoints['jwtRefresh'] as _i4.JwtRefreshEndpoint)
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
              ) async => (endpoints['phoneAuth'] as _i5.PhoneAuthEndpoint)
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
                  (endpoints['phoneAuth'] as _i5.PhoneAuthEndpoint).verifyCode(
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
        'createReservationAndBillets': _i1.MethodConnector(
          name: 'createReservationAndBillets',
          params: {
            'isEvent': _i1.ParameterDescription(
              name: 'isEvent',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'seanceId': _i1.ParameterDescription(
              name: 'seanceId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'reservationNumber': _i1.ParameterDescription(
              name: 'reservationNumber',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'seatLabels': _i1.ParameterDescription(
              name: 'seatLabels',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'ticketTypes': _i1.ParameterDescription(
              name: 'ticketTypes',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'optionParking': _i1.ParameterDescription(
              name: 'optionParking',
              type: _i1.getType<List<bool>>(),
              nullable: false,
            ),
            'optionPopcorn': _i1.ParameterDescription(
              name: 'optionPopcorn',
              type: _i1.getType<List<bool>>(),
              nullable: false,
            ),
            'optionBoisson': _i1.ParameterDescription(
              name: 'optionBoisson',
              type: _i1.getType<List<bool>>(),
              nullable: false,
            ),
            'prices': _i1.ParameterDescription(
              name: 'prices',
              type: _i1.getType<List<double>>(),
              nullable: false,
            ),
            'totalAmount': _i1.ParameterDescription(
              name: 'totalAmount',
              type: _i1.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .createReservationAndBillets(
                    session,
                    isEvent: params['isEvent'],
                    seanceId: params['seanceId'],
                    eventId: params['eventId'],
                    reservationNumber: params['reservationNumber'],
                    seatLabels: params['seatLabels'],
                    ticketTypes: params['ticketTypes'],
                    optionParking: params['optionParking'],
                    optionPopcorn: params['optionPopcorn'],
                    optionBoisson: params['optionBoisson'],
                    prices: params['prices'],
                    totalAmount: params['totalAmount'],
                  ),
        ),
        'getMyBillets': _i1.MethodConnector(
          name: 'getMyBillets',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getMyBillets(session),
        ),
        'isCurrentUserAdmin': _i1.MethodConnector(
          name: 'isCurrentUserAdmin',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .isCurrentUserAdmin(session),
        ),
        'isCurrentUserResponsable': _i1.MethodConnector(
          name: 'isCurrentUserResponsable',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .isCurrentUserResponsable(session),
        ),
        'setResponsableActiveByEmail': _i1.MethodConnector(
          name: 'setResponsableActiveByEmail',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'active': _i1.ParameterDescription(
              name: 'active',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .setResponsableActiveByEmail(
                    session,
                    email: params['email'],
                    active: params['active'],
                  ),
        ),
        'getFilms': _i1.MethodConnector(
          name: 'getFilms',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
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
                  (endpoints['cinePass'] as _i6.CinePassEndpoint).getFilmById(
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
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
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
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getCinemas(session),
        ),
        'getSalles': _i1.MethodConnector(
          name: 'getSalles',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getSalles(session),
        ),
        'getEvents': _i1.MethodConnector(
          name: 'getEvents',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
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
                  (endpoints['cinePass'] as _i6.CinePassEndpoint).getEventById(
                    session,
                    params['id'],
                  ),
        ),
        'getEventReservationConfig': _i1.MethodConnector(
          name: 'getEventReservationConfig',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getEventReservationConfig(
                    session,
                    params['eventId'],
                  ),
        ),
        'setEventReservationConfig': _i1.MethodConnector(
          name: 'setEventReservationConfig',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'reservationMode': _i1.ParameterDescription(
              name: 'reservationMode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'maxTicketsPerOrder': _i1.ParameterDescription(
              name: 'maxTicketsPerOrder',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'adjacentBestEffort': _i1.ParameterDescription(
              name: 'adjacentBestEffort',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'ticketTypeCodes': _i1.ParameterDescription(
              name: 'ticketTypeCodes',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'ticketTypeLabels': _i1.ParameterDescription(
              name: 'ticketTypeLabels',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'ticketTypePrices': _i1.ParameterDescription(
              name: 'ticketTypePrices',
              type: _i1.getType<List<double>>(),
              nullable: false,
            ),
            'ticketTypeQuotas': _i1.ParameterDescription(
              name: 'ticketTypeQuotas',
              type: _i1.getType<List<int>>(),
              nullable: false,
            ),
            'optionTicketTypeCodes': _i1.ParameterDescription(
              name: 'optionTicketTypeCodes',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'optionCodes': _i1.ParameterDescription(
              name: 'optionCodes',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'optionLabels': _i1.ParameterDescription(
              name: 'optionLabels',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'optionPrices': _i1.ParameterDescription(
              name: 'optionPrices',
              type: _i1.getType<List<double>>(),
              nullable: false,
            ),
            'optionIncluded': _i1.ParameterDescription(
              name: 'optionIncluded',
              type: _i1.getType<List<bool>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .setEventReservationConfig(
                    session,
                    eventId: params['eventId'],
                    reservationMode: params['reservationMode'],
                    maxTicketsPerOrder: params['maxTicketsPerOrder'],
                    adjacentBestEffort: params['adjacentBestEffort'],
                    ticketTypeCodes: params['ticketTypeCodes'],
                    ticketTypeLabels: params['ticketTypeLabels'],
                    ticketTypePrices: params['ticketTypePrices'],
                    ticketTypeQuotas: params['ticketTypeQuotas'],
                    optionTicketTypeCodes: params['optionTicketTypeCodes'],
                    optionCodes: params['optionCodes'],
                    optionLabels: params['optionLabels'],
                    optionPrices: params['optionPrices'],
                    optionIncluded: params['optionIncluded'],
                  ),
        ),
        'getEventSeatPlan': _i1.MethodConnector(
          name: 'getEventSeatPlan',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getEventSeatPlan(
                    session,
                    params['eventId'],
                  ),
        ),
        'setEventSeatPlan': _i1.MethodConnector(
          name: 'setEventSeatPlan',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'seatLabels': _i1.ParameterDescription(
              name: 'seatLabels',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'seatRowIndices': _i1.ParameterDescription(
              name: 'seatRowIndices',
              type: _i1.getType<List<int>>(),
              nullable: false,
            ),
            'seatColIndices': _i1.ParameterDescription(
              name: 'seatColIndices',
              type: _i1.getType<List<int>>(),
              nullable: false,
            ),
            'seatBlocked': _i1.ParameterDescription(
              name: 'seatBlocked',
              type: _i1.getType<List<bool>>(),
              nullable: false,
            ),
            'seatZones': _i1.ParameterDescription(
              name: 'seatZones',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .setEventSeatPlan(
                    session,
                    eventId: params['eventId'],
                    seatLabels: params['seatLabels'],
                    seatRowIndices: params['seatRowIndices'],
                    seatColIndices: params['seatColIndices'],
                    seatBlocked: params['seatBlocked'],
                    seatZones: params['seatZones'],
                  ),
        ),
        'quoteEventReservation': _i1.MethodConnector(
          name: 'quoteEventReservation',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'ticketTypeCodes': _i1.ParameterDescription(
              name: 'ticketTypeCodes',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'quantities': _i1.ParameterDescription(
              name: 'quantities',
              type: _i1.getType<List<int>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .quoteEventReservation(
                    session,
                    eventId: params['eventId'],
                    ticketTypeCodes: params['ticketTypeCodes'],
                    quantities: params['quantities'],
                  ),
        ),
        'confirmEventReservation': _i1.MethodConnector(
          name: 'confirmEventReservation',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'perBilletTypeCodes': _i1.ParameterDescription(
              name: 'perBilletTypeCodes',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'perBilletPayantOptionCsv': _i1.ParameterDescription(
              name: 'perBilletPayantOptionCsv',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'perBilletSeatLabels': _i1.ParameterDescription(
              name: 'perBilletSeatLabels',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .confirmEventReservation(
                    session,
                    eventId: params['eventId'],
                    perBilletTypeCodes: params['perBilletTypeCodes'],
                    perBilletPayantOptionCsv:
                        params['perBilletPayantOptionCsv'],
                    perBilletSeatLabels: params['perBilletSeatLabels'],
                  ),
        ),
        'getCities': _i1.MethodConnector(
          name: 'getCities',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getCities(session),
        ),
        'getGenres': _i1.MethodConnector(
          name: 'getGenres',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getGenres(session),
        ),
        'getEventCategories': _i1.MethodConnector(
          name: 'getEventCategories',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getEventCategories(session),
        ),
        'getEventDynamicFilterValues': _i1.MethodConnector(
          name: 'getEventDynamicFilterValues',
          params: {
            'eventType': _i1.ParameterDescription(
              name: 'eventType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'filterKey': _i1.ParameterDescription(
              name: 'filterKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getEventDynamicFilterValues(
                    session,
                    eventType: params['eventType'],
                    filterKey: params['filterKey'],
                  ),
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
            'posterUrl': _i1.ParameterDescription(
              name: 'posterUrl',
              type: _i1.getType<String?>(),
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
                  (endpoints['cinePass'] as _i6.CinePassEndpoint).createFilm(
                    session,
                    title: params['title'],
                    genre: params['genre'],
                    durationMinutes: params['durationMinutes'],
                    synopsis: params['synopsis'],
                    director: params['director'],
                    casting: params['casting'],
                    posterColor: params['posterColor'],
                    posterUrl: params['posterUrl'],
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
              type: _i1.getType<DateTime>(),
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
            'posterUrl': _i1.ParameterDescription(
              name: 'posterUrl',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'structureId': _i1.ParameterDescription(
              name: 'structureId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'eventTypedDetailsJson': _i1.ParameterDescription(
              name: 'eventTypedDetailsJson',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cinePass'] as _i6.CinePassEndpoint).createEvent(
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
                    posterUrl: params['posterUrl'],
                    structureId: params['structureId'],
                    eventTypedDetailsJson: params['eventTypedDetailsJson'],
                  ),
        ),
        'getStructures': _i1.MethodConnector(
          name: 'getStructures',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
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
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
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
              type: _i1.getType<DateTime?>(),
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
            'posterUrl': _i1.ParameterDescription(
              name: 'posterUrl',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'eventTypedDetailsJson': _i1.ParameterDescription(
              name: 'eventTypedDetailsJson',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cinePass'] as _i6.CinePassEndpoint).updateEvent(
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
                    posterUrl: params['posterUrl'],
                    eventTypedDetailsJson: params['eventTypedDetailsJson'],
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
                  (endpoints['cinePass'] as _i6.CinePassEndpoint).deleteEvent(
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
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getMyStructure(session),
        ),
        'updateMyStructure': _i1.MethodConnector(
          name: 'updateMyStructure',
          params: {
            'structureId': _i1.ParameterDescription(
              name: 'structureId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'city': _i1.ParameterDescription(
              name: 'city',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'address': _i1.ParameterDescription(
              name: 'address',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'website': _i1.ParameterDescription(
              name: 'website',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'phone': _i1.ParameterDescription(
              name: 'phone',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .updateMyStructure(
                    session,
                    structureId: params['structureId'],
                    name: params['name'],
                    city: params['city'],
                    address: params['address'],
                    website: params['website'],
                    phone: params['phone'],
                  ),
        ),
        'banStructure': _i1.MethodConnector(
          name: 'banStructure',
          params: {
            'structureId': _i1.ParameterDescription(
              name: 'structureId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cinePass'] as _i6.CinePassEndpoint).banStructure(
                    session,
                    params['structureId'],
                  ),
        ),
        'deleteStructure': _i1.MethodConnector(
          name: 'deleteStructure',
          params: {
            'structureId': _i1.ParameterDescription(
              name: 'structureId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .deleteStructure(
                    session,
                    params['structureId'],
                  ),
        ),
        'getMyEvents': _i1.MethodConnector(
          name: 'getMyEvents',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getMyEvents(session),
        ),
        'getDemandesEnAttente': _i1.MethodConnector(
          name: 'getDemandesEnAttente',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
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
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
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
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
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
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
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
        'hasMyPendingDemandeResponsable': _i1.MethodConnector(
          name: 'hasMyPendingDemandeResponsable',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .hasMyPendingDemandeResponsable(session),
        ),
        'cancelMyEventReservation': _i1.MethodConnector(
          name: 'cancelMyEventReservation',
          params: {
            'reservationNumber': _i1.ParameterDescription(
              name: 'reservationNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .cancelMyEventReservation(
                    session,
                    reservationNumber: params['reservationNumber'],
                  ),
        ),
        'getReservations': _i1.MethodConnector(
          name: 'getReservations',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getReservations(session),
        ),
        'getReservationsForMyStructures': _i1.MethodConnector(
          name: 'getReservationsForMyStructures',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getReservationsForMyStructures(session),
        ),
        'archiveEvent': _i1.MethodConnector(
          name: 'archiveEvent',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cinePass'] as _i6.CinePassEndpoint).archiveEvent(
                    session,
                    params['eventId'],
                  ),
        ),
        'unarchiveEvent': _i1.MethodConnector(
          name: 'unarchiveEvent',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .unarchiveEvent(
                    session,
                    params['eventId'],
                  ),
        ),
        'getReservationBilletDetailsForMyStructures': _i1.MethodConnector(
          name: 'getReservationBilletDetailsForMyStructures',
          params: {
            'reservationId': _i1.ParameterDescription(
              name: 'reservationId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getReservationBilletDetailsForMyStructures(
                    session,
                    reservationId: params['reservationId'],
                  ),
        ),
        'updateReservationStatusForMyStructures': _i1.MethodConnector(
          name: 'updateReservationStatusForMyStructures',
          params: {
            'reservationId': _i1.ParameterDescription(
              name: 'reservationId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .updateReservationStatusForMyStructures(
                    session,
                    reservationId: params['reservationId'],
                    status: params['status'],
                  ),
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
                  (endpoints['cinePass'] as _i6.CinePassEndpoint).getRapportCA(
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
                  (endpoints['cinePass'] as _i6.CinePassEndpoint).createSeance(
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
        'getProfile': _i1.MethodConnector(
          name: 'getProfile',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getProfile(session),
        ),
        'getAdminUsers': _i1.MethodConnector(
          name: 'getAdminUsers',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .getAdminUsers(session),
        ),
        'setAdminUserRole': _i1.MethodConnector(
          name: 'setAdminUserRole',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .setAdminUserRole(
                    session,
                    userId: params['userId'],
                    role: params['role'],
                  ),
        ),
        'deleteAdminUser': _i1.MethodConnector(
          name: 'deleteAdminUser',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['cinePass'] as _i6.CinePassEndpoint)
                  .deleteAdminUser(
                    session,
                    userId: params['userId'],
                  ),
        ),
        'updateProfile': _i1.MethodConnector(
          name: 'updateProfile',
          params: {
            'displayName': _i1.ParameterDescription(
              name: 'displayName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'phone': _i1.ParameterDescription(
              name: 'phone',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'birthDate': _i1.ParameterDescription(
              name: 'birthDate',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['cinePass'] as _i6.CinePassEndpoint).updateProfile(
                    session,
                    displayName: params['displayName'],
                    phone: params['phone'],
                    birthDate: params['birthDate'],
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
              ) async => (endpoints['greeting'] as _i7.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    modules['serverpod_auth'] = _i8.Endpoints()..initializeEndpoints(server);
    modules['serverpod_auth_idp'] = _i9.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i10.Endpoints()
      ..initializeEndpoints(server);
  }
}
