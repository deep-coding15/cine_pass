import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

/// Exposes Google sign-in methods to the client.
class GoogleIdpEndpoint extends GoogleIdpBaseEndpoint {
  Future<void> _ensureUserProfileTable(Session session) async {
    await session.db.unsafeQuery(
      r'''
      CREATE TABLE IF NOT EXISTS "cine_pass_user_profile" (
        "user_id" uuid PRIMARY KEY,
        "display_name" text,
        "phone" text,
        "birth_date" date
      )
      ''',
    );
  }

  Future<void> _ensureClientDataByEmail(
    Session session,
    String email, {
    String? displayName,
  }) async {
    final rows = await session.db.unsafeQuery(
      r'''
      SELECT "authUserId"
      FROM "serverpod_auth_core_profile"
      WHERE lower("email") = @email
      LIMIT 1
      ''',
      parameters: QueryParameters.named({'email': email.trim().toLowerCase()}),
    );
    if (rows.isEmpty) return;

    final userId = rows.first[0].toString();
    await session.db.unsafeQuery(
      r'''
      INSERT INTO "cine_pass_user_role" ("user_id", "role", "status", "updated_at")
      VALUES ((@uid)::uuid, 'client', 'actif', now())
      ON CONFLICT ("user_id", "role") DO UPDATE SET
        "status" = 'actif',
        "updated_at" = now()
      ''',
      parameters: QueryParameters.named({'uid': userId}),
    );

    final safeDisplayName = (displayName ?? '').trim();
    if (safeDisplayName.isNotEmpty) {
      await _ensureUserProfileTable(session);
      await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_user_profile" ("user_id", "display_name")
        VALUES ((@uid)::uuid, @displayName)
        ON CONFLICT ("user_id") DO UPDATE SET
          "display_name" = CASE
            WHEN EXCLUDED."display_name" IS NOT NULL AND EXCLUDED."display_name" <> ''
              THEN EXCLUDED."display_name"
            ELSE "cine_pass_user_profile"."display_name"
          END
        ''',
        parameters: QueryParameters.named({
          'uid': userId,
          'displayName': safeDisplayName,
        }),
      );
    }
  }

  Map<String, dynamic>? _decodeIdTokenPayload(String idToken) {
    final parts = idToken.split('.');
    if (parts.length < 2) return null;
    try {
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final jsonMap = jsonDecode(decoded);
      if (jsonMap is Map<String, dynamic>) return jsonMap;
    } catch (_) {
      return null;
    }
    return null;
  }

  String? _extractEmailFromIdToken(String idToken) {
    final map = _decodeIdTokenPayload(idToken);
    final email = map?['email']?.toString();
    if (email != null && email.contains('@')) return email;
    return null;
  }

  String? _extractNameFromIdToken(String idToken) {
    final map = _decodeIdTokenPayload(idToken);
    final name = map?['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
    return null;
  }

  @override
  Future<AuthSuccess> login(
    Session session, {
    required String idToken,
    required String? accessToken,
  }) async {
    final result = await super.login(
      session,
      idToken: idToken,
      accessToken: accessToken,
    );

    final email = _extractEmailFromIdToken(idToken);
    final displayName = _extractNameFromIdToken(idToken);
    if (email != null) {
      await _ensureClientDataByEmail(
        session,
        email,
        displayName: displayName,
      );
    }

    return result;
  }
}
