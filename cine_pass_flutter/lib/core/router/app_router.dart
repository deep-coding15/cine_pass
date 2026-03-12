import 'package:go_router/go_router.dart';

import '../widgets/main_scaffold.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/films/presentation/pages/films_list_page.dart';
import '../../features/films/presentation/pages/film_detail_page.dart';
import '../../features/reservation/presentation/pages/seat_selection_page.dart';
import '../../features/reservation/presentation/pages/ticket_type_page.dart';
import '../../features/reservation/presentation/pages/payment_page.dart';
import '../../features/reservation/presentation/pages/confirmation_page.dart';
import '../../features/events/presentation/pages/events_list_page.dart';
import '../../features/events/presentation/pages/event_detail_page.dart';
import '../../features/billets/presentation/pages/billets_page.dart';
import '../../features/profil/presentation/pages/profil_page.dart';
import '../../features/admin/presentation/widgets/admin_scaffold.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_films_page.dart';
import '../../features/admin/presentation/pages/admin_seances_page.dart';
import '../../features/admin/presentation/pages/admin_events_page.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/admin/presentation/pages/admin_stats_report_page.dart';
import '../../features/admin/presentation/pages/admin_reservations_page.dart';
import '../../features/admin/presentation/pages/admin_demandes_page.dart';
import '../../features/auth/presentation/pages/connexion_page.dart';
import '../../features/auth/presentation/pages/connexion_responsable_page.dart';
import '../../features/auth/presentation/pages/inscription_page.dart';
import '../../features/preferences/presentation/pages/preferences_page.dart';
import '../../features/faq/presentation/pages/faq_page.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/devenir_responsable/presentation/pages/devenir_responsable_page.dart';
import '../../features/responsable/presentation/widgets/responsable_scaffold.dart';
import '../../features/responsable/presentation/pages/responsable_dashboard_page.dart';
import '../../features/responsable/presentation/pages/responsable_structures_page.dart';
import '../../features/responsable/presentation/pages/responsable_events_page.dart';
import '../../features/responsable/presentation/pages/responsable_reservations_page.dart';
import '../../features/responsable/presentation/pages/responsable_rapports_page.dart';
import '../../features/responsable/presentation/pages/responsable_reclamations_page.dart';

class AppRouter {
  static const String home = '/';
  static const String films = '/films';
  static const String filmDetail = '/films/:id';
  static const String reservationSieges = '/reservation/sieges';
  static const String reservationTypeBillet = '/reservation/type-billet';
  static const String paiement = '/paiement';
  static const String confirmation = '/confirmation';
  static const String events = '/events';
  static const String eventDetail = '/events/:id';
  static const String billets = '/billets';
  static const String profil = '/profil';
  static const String connexion = '/connexion';
  static const String connexionResponsable = '/connexion-responsable';
  static const String inscription = '/inscription';
  static const String preferences = '/preferences';
  static const String faq = '/faq';
  static const String support = '/support';
  static const String admin = '/admin';
  static const String devenirResponsable = '/devenir-responsable';
  static const String responsable = '/responsable';
  static const String responsableStructures = '/responsable/structures';
  static const String responsableEvents = '/responsable/events';
  static const String responsableReservations = '/responsable/reservations';
  static const String responsableRapports = '/responsable/rapports';
  static const String responsableReclamations = '/responsable/reclamations';

  static String filmDetailPath(String id) => '/films/$id';
  static String eventDetailPath(String id) => '/events/$id';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: home,
            pageBuilder: (_, _) => const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: films,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: FilmsListPage()),
          ),
          GoRoute(
            path: '/films/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return NoTransitionPage(child: FilmDetailPage(filmId: id));
            },
          ),
          GoRoute(
            path: reservationSieges,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: SeatSelectionPage()),
          ),
          GoRoute(
            path: reservationTypeBillet,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: TicketTypePage()),
          ),
          GoRoute(
            path: paiement,
            pageBuilder: (_, _) => const NoTransitionPage(child: PaymentPage()),
          ),
          GoRoute(
            path: confirmation,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: ConfirmationPage()),
          ),
          GoRoute(
            path: events,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: EventsListPage()),
          ),
          GoRoute(
            path: '/events/:id',
            pageBuilder: (_, state) {
              final id = state.pathParameters['id'] ?? '';
              return NoTransitionPage(child: EventDetailPage(eventId: id));
            },
          ),
          GoRoute(
            path: billets,
            pageBuilder: (_, _) => const NoTransitionPage(child: BilletsPage()),
          ),
          GoRoute(
            path: profil,
            pageBuilder: (_, _) => const NoTransitionPage(child: ProfilPage()),
          ),
          GoRoute(
            path: preferences,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: PreferencesPage()),
          ),
          GoRoute(
            path: connexion,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: ConnexionPage()),
          ),
          GoRoute(
            path: inscription,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: InscriptionPage()),
          ),
          GoRoute(
            path: faq,
            pageBuilder: (_, _) => const NoTransitionPage(child: FaqPage()),
          ),
          GoRoute(
            path: support,
            pageBuilder: (_, _) => const NoTransitionPage(child: SupportPage()),
          ),
          GoRoute(
            path: devenirResponsable,
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: DevenirResponsablePage()),
          ),
          GoRoute(
            path: connexionResponsable,
            pageBuilder: (_, _) => const NoTransitionPage(
                child: ConnexionResponsablePage()),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AdminScaffold(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdminDashboardPage()),
          ),
          GoRoute(
            path: '/admin/films',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdminFilmsPage()),
          ),
          GoRoute(
            path: '/admin/seances',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdminSeancesPage()),
          ),
          GoRoute(
            path: '/admin/events',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdminEventsPage()),
          ),
          GoRoute(
            path: '/admin/users',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdminUsersPage()),
          ),
          GoRoute(
            path: '/admin/reservations',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdminReservationsPage()),
          ),
          GoRoute(
            path: '/admin/stats',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdminStatsReportPage()),
          ),
          GoRoute(
            path: '/admin/demandes',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdminDemandesPage()),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) =>
            ResponsableScaffold(child: child),
        routes: [
          GoRoute(
            path: responsable,
            pageBuilder: (_, _) => const NoTransitionPage(
                child: ResponsableDashboardPage()),
          ),
          GoRoute(
            path: '/responsable/structures',
            pageBuilder: (_, _) => const NoTransitionPage(
                child: ResponsableStructuresPage()),
          ),
          GoRoute(
            path: '/responsable/events',
            pageBuilder: (_, _) => const NoTransitionPage(
                child: ResponsableEventsPage()),
          ),
          GoRoute(
            path: '/responsable/reservations',
            pageBuilder: (_, _) => const NoTransitionPage(
                child: ResponsableReservationsPage()),
          ),
          GoRoute(
            path: '/responsable/rapports',
            pageBuilder: (_, _) => const NoTransitionPage(
                child: ResponsableRapportsPage()),
          ),
          GoRoute(
            path: '/responsable/reclamations',
            pageBuilder: (_, _) => const NoTransitionPage(
                child: ResponsableReclamationsPage()),
          ),
        ],
      ),
    ],
  );
}
