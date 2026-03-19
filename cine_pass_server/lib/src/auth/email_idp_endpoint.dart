import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Email/password authentication endpoint.
///
/// This is required for the email auth flow (sign-in, registration and
/// password reset) used by `EmailSignInWidget` on the Flutter side.
class EmailIdpEndpoint extends EmailIdpBaseEndpoint {}
