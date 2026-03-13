import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/state/auth_state.dart';
import 'core/state/favorites_state.dart';
import 'core/state/pending_reservation_state.dart';
import 'features/billets/data/billets_state.dart';
import 'features/reservation/data/reservation_state.dart';

late final Client client;

const _defaultGoogleWebClientId =
    '780713404787-qgeac9u7gn7an6kntv5kg24ntp30u2dq.apps.googleusercontent.com';
const _defaultGoogleAndroidClientId =
    '780713404787-th1oi0uk8pvtuofjmap99bc1o7num427.apps.googleusercontent.com';
const _googleClientIdFromDefine = String.fromEnvironment('GOOGLE_CLIENT_ID');
const _googleServerClientIdFromDefine = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
);

String? _normalizedOrNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final serverUrl = await getServerUrl();

  // Create the client with the auth session manager
  client = Client(serverUrl)
    /// Use the FlutterConnectivityMonitor to monitor network connectivity changes in the app.
    /// It helps the client to:
    /// Automatically retry failed requests when the network is restored.
    /// Provide real-time connectivity status to the app, allowing it to adapt its behavior based on network availability.
    /// This ensures a smoother user experience by handling connectivity issues gracefully and keeping the app responsive even in offline scenarios.
    ..connectivityMonitor = FlutterConnectivityMonitor()
    /// Use the FlutterAuthSessionManager to manage authentication sessions in the app.
    /// It helps:
    /// - Store the current authentication session securely on the device.
    /// - Automatically refresh authentication sessions when they expire.
    /// - Provide the current authentication session to the client for authenticated requests.
    /// This allows the app to maintain user authentication state across app restarts and handle token refresh seamlessly.
    ..authSessionManager = FlutterAuthSessionManager();

  // Initialize the auth session manager to load any existing auth session from storage.
  await client.auth.initialize();

  final googleClientId =
      _normalizedOrNull(_googleClientIdFromDefine) ??
      _defaultGoogleAndroidClientId;
  final googleServerClientId =
      _normalizedOrNull(_googleServerClientIdFromDefine) ??
      _defaultGoogleWebClientId;

  if (!kIsWeb) {
    await client.auth.initializeGoogleSignIn(
      clientId: googleClientId,
      serverClientId: googleServerClientId,
    );
  }

  AuthState.instance.bindToClientAuth();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthState>.value(value: AuthState.instance),
        ChangeNotifierProvider<FavoritesState>.value(
          value: FavoritesState.instance,
        ),
        ChangeNotifierProvider<PendingReservationState>.value(
          value: PendingReservationState.instance,
        ),
        ChangeNotifierProvider<BilletsState>.value(
          value: BilletsState.instance,
        ),
        ChangeNotifierProvider<ReservationState>.value(
          value: ReservationState.instance,
        ),
      ],
      child: const CinePassApp(),
    ),
  );
}

class CinePassApp extends StatelessWidget {
  const CinePassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CinePass',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
