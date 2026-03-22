import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Exposes email/password auth and a simplified registration flow.
class EmailAuthEndpoint extends EmailIdpBaseEndpoint {
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
          fullName:
              (normalizedFullName != null && normalizedFullName.isNotEmpty)
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

    await _ensureClientDataByEmail(
      session,
      normalizedEmail,
      displayName: normalizedFullName,
    );
    return auth;
  }

  /// Lie un email/mot de passe a l'utilisateur deja connecte.
  /// - si l'email n'existe pas: creation du credential
  /// - si l'email existe pour le meme user: OK
  /// - si l'email existe pour un autre user: erreur
  Future<bool> ensureCredentialForCurrentUser(
    Session session, {
    required String email,
    required String password,
  }) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) {
      throw Exception('Utilisateur non authentifie.');
    }

    final normalizedEmail = email.trim().toLowerCase();
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
      await emailIdp.admin.createEmailAuthentication(
        session,
        authUserId: UuidValue.fromString(userId),
        email: normalizedEmail,
        password: password,
      );
      return true;
    }

    if (existing.authUserId.toString() != userId) {
      throw Exception('Cet email est deja utilise par un autre compte.');
    }

    return true;
  }
}
