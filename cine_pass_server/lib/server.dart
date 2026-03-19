import 'dart:io';

import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/root.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args, 
    Protocol(), 
    Endpoints()
  );

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Configure les tockens JWT
      JwtConfig(
        // Pepper used to hash the refresh token secret.
        refreshTokenHashPepper: pod.getPassword('jwtRefreshTokenHashPepper')!,
        algorithm: JwtAlgorithm.hmacSha512(
        // Private key to sign the tokens. Must be a valid HMAC SHA-512 key.
          SecretKey(pod.getPassword('jwtHmacSha512PrivateKey')!),
        )
      ),
    ],
    identityProviderBuilders: [
      // Expects `googleClientSecret` in passwords.yaml with the Google web
      // client secret JSON payload.
      GoogleIdpConfigFromPasswords(),
      // Email/password authentication (sign-in, registration and password
      // reset) used by `EmailSignInWidget`.
      EmailIdpConfig(
        secretHashPepper: pod.getPassword('emailSecretHashPepper')!,
        // Envoi réel via SMTP (voir config passwords.yaml).
        sendRegistrationVerificationCode: (
          session, {
          required String email,
          required UuidValue accountRequestId,
          required String verificationCode,
          required Transaction? transaction,
        }) async {
          try {
            final smtpHost = pod.getPassword('smtpHost')!;
            final smtpPort = pod.getPassword('smtpPort')!;
            final smtpUsername = pod.getPassword('smtpUsername')!;
            final smtpPassword = pod.getPassword('smtpPassword')!;
            final smtpFrom = pod.getPassword('smtpFromEmail')!;

            session.log(
              '[EmailAuth] SMTP configured: host=$smtpHost port=$smtpPort from=$smtpFrom user=${smtpUsername.isNotEmpty ? '(set)' : '(empty)'}',
              level: LogLevel.info,
            );

            final smtpServer = SmtpServer(
              smtpHost,
              port: int.parse(smtpPort),
              username: smtpUsername,
              password: smtpPassword,
              ignoreBadCertificate: false,
            );

            final message = mailer.Message()
              ..from = mailer.Address(smtpFrom)
              ..recipients.add(email)
              ..subject = 'CinePass - code de vérification'
              ..text =
                  'Ton code de vérification CinePass est : $verificationCode\n\nCe code expire bientôt. Si tu n\'as pas demandé cette inscription, ignore ce message.';

            await mailer.send(message, smtpServer);
            session.log(
              '[EmailAuth] sent registration code to $email',
              level: LogLevel.info,
            );
          } catch (e) {
            // En dev: si SMTP n'est pas configuré, on garde l'ancien comportement
            // (code dans les logs) pour ne pas casser le flow.
            session.log(
              '[EmailAuth] SMTP not configured or send failed. Fallback code for $email: $verificationCode. Error: $e',
              level: LogLevel.warning,
            );
          }
        },
        sendPasswordResetVerificationCode: (
          session, {
          required String email,
          required UuidValue passwordResetRequestId,
          required String verificationCode,
          required Transaction? transaction,
        }) async {
          try {
            final smtpHost = pod.getPassword('smtpHost')!;
            final smtpPort = pod.getPassword('smtpPort')!;
            final smtpUsername = pod.getPassword('smtpUsername')!;
            final smtpPassword = pod.getPassword('smtpPassword')!;
            final smtpFrom = pod.getPassword('smtpFromEmail')!;

            session.log(
              '[EmailAuth] SMTP configured: host=$smtpHost port=$smtpPort from=$smtpFrom user=${smtpUsername.isNotEmpty ? '(set)' : '(empty)'}',
              level: LogLevel.info,
            );

            final smtpServer = SmtpServer(
              smtpHost,
              port: int.parse(smtpPort),
              username: smtpUsername,
              password: smtpPassword,
              ignoreBadCertificate: false,
            );

            final message = mailer.Message()
              ..from = mailer.Address(smtpFrom)
              ..recipients.add(email)
              ..subject = 'CinePass - reset de mot de passe'
              ..text =
                  'Ton code de reset CinePass est : $verificationCode\n\nSi tu n\'as pas demandé ce reset, ignore ce message.';

            await mailer.send(message, smtpServer);
            session.log(
              '[EmailAuth] sent password reset code to $email',
              level: LogLevel.info,
            );
          } catch (e) {
            session.log(
              '[EmailAuth] SMTP not configured or send failed. Fallback code for $email: $verificationCode. Error: $e',
              level: LogLevel.warning,
            );
          }
        },
      ),
    ],
  );

  // Setup a default page at the web root.
  // These are used by the default page.
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /.
  // These are used by the default web page.
  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root));

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under the /app path.
    pod.webServer.addRoute(
      FlutterRoute(
        Directory(
          Uri(path: 'web/app').toFilePath(),
        ),
      ),
      '/app',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    pod.webServer.addRoute(
      StaticRoute.file(
        File(
          Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
        ),
      ),
      '/app/**',
    );
  }

  // Start the server.
  await pod.start();
}
