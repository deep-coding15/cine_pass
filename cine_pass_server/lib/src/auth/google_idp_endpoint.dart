import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

/// Exposes Google sign-in methods to the client.
class GoogleIdpEndpoint extends GoogleIdpBaseEndpoint {
  Future<void> _ensureClientRoleByEmail(Session session, String email) async {
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
  }

  String? _extractEmailFromIdToken(String idToken) {
    final parts = idToken.split('.');
    if (parts.length < 2) return null;

    try {
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final jsonMap = jsonDecode(decoded);
      if (jsonMap is Map<String, dynamic>) {
        final email = jsonMap['email']?.toString();
        if (email != null && email.contains('@')) return email;
      }
    } catch (_) {
      return null;
    }
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
    if (email != null) {
      await _ensureClientRoleByEmail(session, email);
    }

    return result;
  }
}
