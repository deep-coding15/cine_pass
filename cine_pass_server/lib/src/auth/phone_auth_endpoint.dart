import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cine_pass_server/src/generated/protocol.dart';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';

class PhoneAuthEndpoint extends Endpoint {
  static const _otpLength = 6;
  static const _otpTtl = Duration(minutes: 5);
  static const _resendCooldown = Duration(seconds: 45);
  static const _maxAttempts = 5;

  @unauthenticatedClientCall
  Future<void> sendVerificationCode(Session session, String phoneNumber) async {
    final normalizedPhone = _normalizePhone(phoneNumber);
    final now = DateTime.now().toUtc();

    final lastCode = await PhoneAuthCode.db.findFirstRow(
      session,
      where: (t) => t.phone.equals(normalizedPhone),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );

    if (lastCode != null &&
        now.difference(lastCode.createdAt) < _resendCooldown &&
        lastCode.consumedAt == null) {
      throw Exception('Veuillez patienter avant de demander un nouveau code.');
    }

    final verificationCode = _generateVerificationCode();
    await PhoneAuthCode.db.insertRow(
      session,
      PhoneAuthCode(
        phone: normalizedPhone,
        code: verificationCode,
        createdAt: now,
        expiresAt: now.add(_otpTtl),
        attemptCount: 0,
      ),
    );

    // TODO: Integrate your SMS provider here (Twilio, etc.)
    session.log('[PhoneAuth] OTP for $normalizedPhone: $verificationCode');
  }

  @unauthenticatedClientCall
  Future<AuthSuccess?> verifyCode(
    Session session,
    String phoneNumber,
    String code,
  ) async {
    final normalizedPhone = _normalizePhone(phoneNumber);
    final now = DateTime.now().toUtc();

    final latestCode = await PhoneAuthCode.db.findFirstRow(
      session,
      where: (t) => t.phone.equals(normalizedPhone),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );

    if (latestCode == null || latestCode.consumedAt != null) {
      return null;
    }

    if (latestCode.expiresAt.isBefore(now)) {
      await PhoneAuthCode.db.updateRow(
        session,
        latestCode.copyWith(consumedAt: now),
      );
      return null;
    }

    if (latestCode.attemptCount >= _maxAttempts) {
      await PhoneAuthCode.db.updateRow(
        session,
        latestCode.copyWith(consumedAt: now),
      );
      return null;
    }

    if (latestCode.code != code.trim()) {
      await PhoneAuthCode.db.updateRow(
        session,
        latestCode.copyWith(attemptCount: latestCode.attemptCount + 1),
      );
      return null;
    }

    await PhoneAuthCode.db.updateRow(
      session,
      latestCode.copyWith(consumedAt: now),
    );

    final authUserId = await _ensureAuthUserForPhone(
      session,
      phone: normalizedPhone,
    );

    return AuthServices.instance.tokenManager.issueToken(
      session,
      authUserId: authUserId,
      method: 'phone',
    );
  }

  Future<UuidValue> _ensureAuthUserForPhone(
    Session session, {
    required String phone,
  }) async {
    final authUserId = _phoneAuthUserId(phone);

    final existingAuthUser = await AuthUser.db.findById(session, authUserId);
    if (existingAuthUser == null) {
      await AuthUser.db.insertRow(
        session,
        AuthUser(
          id: authUserId,
          scopeNames: const {},
          blocked: false,
        ),
      );
    }

    final existingProfile = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (existingProfile == null) {
      await AuthServices.instance.userProfiles.createUserProfile(
        session,
        authUserId,
        UserProfileData(
          userName: phone,
          fullName: phone,
        ),
      );
    }

    return authUserId;
  }

  UuidValue _phoneAuthUserId(String phone) {
    final digest = sha1.convert(utf8.encode('cinepass-phone:$phone')).bytes;
    final bytes = Uint8List.fromList(digest.sublist(0, 16));

    bytes[6] = (bytes[6] & 0x0f) | 0x50;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final uuid =
        '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';

    return UuidValue.fromString(uuid);
  }

  String _generateVerificationCode() {
    final random = Random.secure();
    final min = pow(10, _otpLength - 1).toInt();
    final maxOffset = pow(10, _otpLength).toInt() - min;
    return (min + random.nextInt(maxOffset)).toString();
  }

  String _normalizePhone(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw Exception('Numero de telephone invalide.');
    }

    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      final ch = trimmed[i];
      final isDigit = ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
      if (isDigit) {
        buffer.write(ch);
      } else if (ch == '+' && i == 0) {
        buffer.write(ch);
      }
    }

    final normalized = buffer.toString();
    if (normalized.length < 8) {
      throw Exception('Numero de telephone invalide.');
    }

    return normalized;
  }
}
