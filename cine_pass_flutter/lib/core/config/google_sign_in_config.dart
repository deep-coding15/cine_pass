import 'package:flutter/foundation.dart';

class GoogleSignInConfig {
  // Defaults used when no --dart-define is provided.
  static const defaultWebClientId =
      '780713404787-qgeac9u7gn7an6kntv5kg24ntp30u2dq.apps.googleusercontent.com';
  static const defaultAndroidClientId =
      '780713404787-th1oi0uk8pvtuofjmap99bc1o7num427.apps.googleusercontent.com';

  static const _clientIdFromDefine = String.fromEnvironment('GOOGLE_CLIENT_ID');
  static const _serverClientIdFromDefine =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  static String? _normalizedOrNull(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  /// `clientId` is the native client id (Android/iOS/desktop).
  static String get clientId =>
      _normalizedOrNull(_clientIdFromDefine) ?? defaultAndroidClientId;

  /// `serverClientId` should be the Web client id.
  static String get serverClientId =>
      _normalizedOrNull(_serverClientIdFromDefine) ?? defaultWebClientId;

  /// Google sign-in initialization is only required on non-web.
  static bool get needsNativeInit => !kIsWeb;
}

