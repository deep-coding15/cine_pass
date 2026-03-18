import 'package:test/test.dart';

import 'package:cine_pass_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given PhoneAuth endpoint', (sessionBuilder, endpoints) {
    test(
      'when sending and verifying a valid SMS code then returns auth success and consumes the code',
      () async {
        const phone = '+33612345678';

        await endpoints.phoneAuth.sendVerificationCode(sessionBuilder, phone);

        final session = sessionBuilder.build();
        try {
          final latestCode = await PhoneAuthCode.db.findFirstRow(
            session,
            where: (t) => t.phone.equals(phone),
            orderBy: (t) => t.createdAt,
            orderDescending: true,
          );

          expect(latestCode, isNotNull);

          final authSuccess = await endpoints.phoneAuth.verifyCode(
            sessionBuilder,
            phone,
            latestCode!.code,
          );

          expect(authSuccess, isNotNull);
          expect(authSuccess!.token, isNotEmpty);
          expect(authSuccess.authUserId.toString(), isNotEmpty);

          final reusedCodeResult = await endpoints.phoneAuth.verifyCode(
            sessionBuilder,
            phone,
            latestCode.code,
          );
          expect(reusedCodeResult, isNull);
        } finally {
          await session.close();
        }
      },
    );
  });
}

