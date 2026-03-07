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
import '../endpoints/reservation_endpoint.dart' as _i4;
import '../greetings/greeting_endpoint.dart' as _i5;
import 'package:cine_pass_server/src/generated/reservation_billet/reservation_statut.dart'
    as _i6;
import 'package:cine_pass_server/src/generated/reservation_billet/paiement_method.dart'
    as _i7;
import 'package:cine_pass_server/src/generated/reservation_billet/paiement_statut.dart'
    as _i8;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i9;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i10;

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
      'reservation': _i4.ReservationEndpoint()
        ..initialize(
          server,
          'reservation',
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
    connectors['reservation'] = _i1.EndpointConnector(
      name: 'reservation',
      endpoint: endpoints['reservation']!,
      methodConnectors: {
        'createReservation': _i1.MethodConnector(
          name: 'createReservation',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'cinemaId': _i1.ParameterDescription(
              name: 'cinemaId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'seanceId': _i1.ParameterDescription(
              name: 'seanceId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'siegeIds': _i1.ParameterDescription(
              name: 'siegeIds',
              type: _i1.getType<Set<int>>(),
              nullable: false,
            ),
            'optionnelIds': _i1.ParameterDescription(
              name: 'optionnelIds',
              type: _i1.getType<Map<int, int>>(),
              nullable: false,
            ),
            'dateReservation': _i1.ParameterDescription(
              name: 'dateReservation',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'montantTotal': _i1.ParameterDescription(
              name: 'montantTotal',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'statut': _i1.ParameterDescription(
              name: 'statut',
              type: _i1.getType<_i6.ReservationStatut>(),
              nullable: false,
            ),
            'paiementMethod': _i1.ParameterDescription(
              name: 'paiementMethod',
              type: _i1.getType<_i7.PaiementMethod>(),
              nullable: false,
            ),
            'codePromo': _i1.ParameterDescription(
              name: 'codePromo',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['reservation'] as _i4.ReservationEndpoint)
                  .createReservation(
                    session,
                    userId: params['userId'],
                    cinemaId: params['cinemaId'],
                    seanceId: params['seanceId'],
                    siegeIds: params['siegeIds'],
                    optionnelIds: params['optionnelIds'],
                    dateReservation: params['dateReservation'],
                    montantTotal: params['montantTotal'],
                    statut: params['statut'],
                    paiementMethod: params['paiementMethod'],
                    codePromo: params['codePromo'],
                  ),
        ),
        'validerAppartenance': _i1.MethodConnector(
          name: 'validerAppartenance',
          params: {
            'siegeIds': _i1.ParameterDescription(
              name: 'siegeIds',
              type: _i1.getType<List<int>>(),
              nullable: false,
            ),
            'cinemaId': _i1.ParameterDescription(
              name: 'cinemaId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'salleId': _i1.ParameterDescription(
              name: 'salleId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['reservation'] as _i4.ReservationEndpoint)
                  .validerAppartenance(
                    session,
                    siegeIds: params['siegeIds'],
                    cinemaId: params['cinemaId'],
                    salleId: params['salleId'],
                  ),
        ),
        'validerDisponibilite': _i1.MethodConnector(
          name: 'validerDisponibilite',
          params: {
            'siegeIds': _i1.ParameterDescription(
              name: 'siegeIds',
              type: _i1.getType<List<int>>(),
              nullable: false,
            ),
            'seanceId': _i1.ParameterDescription(
              name: 'seanceId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['reservation'] as _i4.ReservationEndpoint)
                  .validerDisponibilite(
                    session,
                    siegeIds: params['siegeIds'],
                    seanceId: params['seanceId'],
                  ),
        ),
        'payerReservation': _i1.MethodConnector(
          name: 'payerReservation',
          params: {
            'reservationId': _i1.ParameterDescription(
              name: 'reservationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'montant': _i1.ParameterDescription(
              name: 'montant',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'paiementMethod': _i1.ParameterDescription(
              name: 'paiementMethod',
              type: _i1.getType<_i7.PaiementMethod>(),
              nullable: false,
            ),
            'statut': _i1.ParameterDescription(
              name: 'statut',
              type: _i1.getType<_i8.PaiementStatut>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['reservation'] as _i4.ReservationEndpoint)
                  .payerReservation(
                    session,
                    reservationId: params['reservationId'],
                    montant: params['montant'],
                    paiementMethod: params['paiementMethod'],
                    statut: params['statut'],
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
    modules['serverpod_auth_idp'] = _i9.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i10.Endpoints()
      ..initializeEndpoints(server);
  }
}
