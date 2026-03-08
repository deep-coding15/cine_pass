import 'package:cine_pass_client/cine_pass_client.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final serverUrl = await getServerUrl();
  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  client.auth.initialize();

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
