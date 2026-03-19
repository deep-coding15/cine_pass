import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart' as smtp;
import 'package:serverpod/serverpod.dart';

/// Sends registration verification code by email (or logs fallback in dev).
Future<void> sendRegistrationVerificationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) async {
  await _sendEmailOrLog(
    session,
    toEmail: email,
    subject: 'Code de verification CinePass',
    textBody:
        'Votre code de verification est: $verificationCode\n\n'
        'Demande: $accountRequestId\n'
        'Ce code expire bientot.',
    htmlBody:
        '<p>Votre code de verification est:</p>'
        '<h2 style="letter-spacing:2px;">$verificationCode</h2>'
        '<p>Demande: $accountRequestId</p>'
        '<p>Ce code expire bientot.</p>',
  );
}

/// Sends password reset verification code by email (or logs fallback in dev).
Future<void> sendPasswordResetVerificationCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) async {
  await _sendEmailOrLog(
    session,
    toEmail: email,
    subject: 'Reinitialisation mot de passe CinePass',
    textBody:
        'Votre code de reinitialisation est: $verificationCode\n\n'
        'Demande: $passwordResetRequestId\n'
        'Si vous n\'etes pas a l\'origine de cette demande, ignorez cet email.',
    htmlBody:
        '<p>Votre code de reinitialisation est:</p>'
        '<h2 style="letter-spacing:2px;">$verificationCode</h2>'
        '<p>Demande: $passwordResetRequestId</p>'
        '<p>Si vous n\'etes pas a l\'origine de cette demande, ignorez cet email.</p>',
  );
}

Future<void> _sendEmailOrLog(
  Session session, {
  required String toEmail,
  required String subject,
  required String textBody,
  required String htmlBody,
}) async {
  final smtpHost = _normalizedSecret(Serverpod.instance.getPassword('smtpHost'));
  final smtpPortRaw = _normalizedSecret(Serverpod.instance.getPassword('smtpPort'));
  final smtpUsername = _normalizedSecret(
    Serverpod.instance.getPassword('smtpUsername'),
  );
  final smtpPassword = _normalizedSecret(
    Serverpod.instance.getPassword('smtpPassword'),
  );
  final smtpFromEmail =
      _normalizedSecret(Serverpod.instance.getPassword('smtpFromEmail')) ??
      smtpUsername;
  final smtpFromName =
      _normalizedSecret(Serverpod.instance.getPassword('smtpFromName')) ??
      'CinePass';

  // Fallback dev mode: no SMTP configured -> log payload in server logs.
  if (smtpHost == null ||
      smtpPortRaw == null ||
      smtpUsername == null ||
      smtpPassword == null ||
      smtpFromEmail == null) {
    session.log(
      'SMTP non configure. Email simule vers $toEmail | sujet="$subject" | corps="$textBody"',
      level: LogLevel.warning,
    );
    return;
  }

  final smtpPort = int.tryParse(smtpPortRaw);
  if (smtpPort == null) {
    session.log(
      'smtpPort invalide: "$smtpPortRaw". Email simule vers $toEmail | sujet="$subject"',
      level: LogLevel.warning,
    );
    return;
  }

  final smtpServer = smtp.SmtpServer(
    smtpHost,
    port: smtpPort,
    username: smtpUsername,
    password: smtpPassword,
    ssl: smtpPort == 465,
  );

  final message = mailer.Message()
    ..from = mailer.Address(smtpFromEmail, smtpFromName)
    ..recipients.add(toEmail)
    ..subject = subject
    ..text = textBody
    ..html = htmlBody;

  try {
    await mailer.send(message, smtpServer);
    session.log(
      'Email envoye avec succes vers $toEmail',
      level: LogLevel.info,
    );
  } catch (e, stackTrace) {
    session.log(
      'Echec envoi email vers $toEmail: $e',
      level: LogLevel.error,
      exception: e,
      stackTrace: stackTrace,
    );
    // SMTP est configure mais l'envoi a echoue: remonter l'erreur au client.
    rethrow;
  }
}

String? _normalizedSecret(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
