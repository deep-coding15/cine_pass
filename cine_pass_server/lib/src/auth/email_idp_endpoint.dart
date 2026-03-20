import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Exposes email/password auth and a simplified registration flow.
class EmailAuthEndpoint extends EmailIdpBaseEndpoint {
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

  /// Creates an email account in DB and returns a signed-in auth session.
  Future<AuthSuccess> register(
    Session session, {
    required String email,
    required String password,
    String? fullName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedFullName = fullName?.trim();

    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw Exception('Email invalide.');
    }
    if (password.length < 8) {
      throw Exception('Le mot de passe doit contenir au moins 8 caracteres.');
    }

    final existing = await emailIdp.admin.findAccount(
      session,
      email: normalizedEmail,
    );

    if (existing == null) {
      final authUser = await AuthServices.instance.authUsers.create(session);

      await emailIdp.admin.createEmailAuthentication(
        session,
        authUserId: authUser.id,
        email: normalizedEmail,
        password: password,
      );

      // Create profile explicitly; changeFullName would fail if profile doesn't exist yet.
      await AuthServices.instance.userProfiles.createUserProfile(
        session,
        authUser.id,
        UserProfileData(
          email: normalizedEmail,
          fullName: (normalizedFullName != null && normalizedFullName.isNotEmpty)
              ? normalizedFullName
              : null,
        ),
      );
    }

    // If the account exists, this works as "register-or-login".
    final auth = await login(
      session,
      email: normalizedEmail,
      password: password,
    );

    await _ensureClientRoleByEmail(session, normalizedEmail);
    return auth;
  }
}
