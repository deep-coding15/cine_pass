import 'package:cine_pass_server/src/auth/phone_auth_endpoint.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  // Test harness does not run `lib/server.dart`; `PhoneAuthEndpoint` uses
  // `AuthServices.instance` (JWT + profiles), so we mirror production init here.
  // Nested `db.transaction` in profile code also needs disabled rollbacks
  // (see serverpod_auth_idp_server integration tests).
  withServerpod(
    'Given PhoneAuth endpoint',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      setUpAll(() {
        AuthServices.set(
          tokenManagerBuilders: [
            JwtConfig(
              refreshTokenHashPepper: 'test-pepper-1234567890',
              algorithm: JwtAlgorithm.hmacSha512(
                SecretKey(
                  '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
                ),
              ),
            ),
          ],
        );
      });

      test(
        'when sending and verifying a valid SMS code then returns auth success and consumes the code',
        () async {
          const phone = '+33612345678';

          await endpoints.phoneAuth.sendVerificationCode(sessionBuilder, phone);

          final authSuccess = await endpoints.phoneAuth.verifyCode(
            sessionBuilder,
            phone,
            PhoneAuthEndpoint.testModeVerificationCode,
          );

          expect(authSuccess, isNotNull);
          expect(authSuccess!.token, isNotEmpty);
          expect(authSuccess.authUserId.toString(), isNotEmpty);

          final reusedCodeResult = await endpoints.phoneAuth.verifyCode(
            sessionBuilder,
            phone,
            PhoneAuthEndpoint.testModeVerificationCode,
          );
          expect(reusedCodeResult, isNull);
        },
      );
    },
  );
}
