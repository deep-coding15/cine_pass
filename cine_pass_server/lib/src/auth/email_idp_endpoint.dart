import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Exposes email/password auth and a simplified registration flow.
class EmailAuthEndpoint extends EmailIdpBaseEndpoint {
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
    if (password.length < 6) {
      throw Exception('Le mot de passe doit contenir au moins 6 caracteres.');
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
    return login(
      session,
      email: normalizedEmail,
      password: password,
    );
  }
}
