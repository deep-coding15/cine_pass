/// Données mock pour l'espace admin (utilisateurs, etc.).

class MockAdminUser {
  MockAdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    this.phone,
  });
  final String id;
  final String name;
  final String email;
  final String role; // 'Client' | 'Admin'
  final String status; // 'Actif'
  final String createdAt;
  final String? phone;
}

final mockAdminUsers = [
  MockAdminUser(
    id: 'u1',
    name: 'Marie Dubois',
    email: 'marie.dubois@email.com',
    phone: '+33 6 12 34 56 78',
    role: 'Client',
    status: 'Actif',
    createdAt: '15/01/2024',
  ),
  MockAdminUser(
    id: 'u2',
    name: 'Jean Admin',
    email: 'admin@cinepass.com',
    role: 'Admin',
    status: 'Actif',
    createdAt: '01/01/2023',
  ),
];

/// Dates fictives pour l'affichage admin des films (non présentes dans MockFilm).
String releaseDateForFilmId(String id) {
  const dates = {'1': '15/02/2026', '2': '20/02/2026', '3': '01/03/2026', '4': '10/02/2026'};
  return dates[id] ?? '--/--/----';
}

String endDateForFilmId(String id) {
  const dates = {'1': '15/04/2026', '2': '20/04/2026', '3': '30/04/2026', '4': '10/04/2026'};
  return dates[id] ?? '--/--/----';
}

String audienceForFilmId(String id) {
  const audiences = {'1': 'Tous publics', '2': '-12', '3': 'Tous publics', '4': '-16'};
  return audiences[id] ?? 'Tous publics';
}

/// Cinémas avec salles et créneaux horaires pour le formulaire "Nouvelle séance".
class MockCinema {
  MockCinema({required this.id, required this.name, required this.city, required this.rooms});
  final String id;
  final String name;
  final String city;
  final List<MockRoom> rooms;
}

class MockRoom {
  MockRoom({required this.id, required this.name, required this.availableSlots});
  final String id;
  final String name;
  /// Créneaux disponibles pour cette salle (ex. "14:00", "18:30").
  final List<String> availableSlots;
}

final mockCinemas = [
  MockCinema(
    id: 'c1',
    name: 'Gaumont Opéra',
    city: 'Paris',
    rooms: [
      MockRoom(id: 'r1', name: 'Salle 1', availableSlots: ['10:00', '14:00', '17:30', '21:00']),
      MockRoom(id: 'r2', name: 'Salle 2', availableSlots: ['11:00', '15:00', '19:00']),
      MockRoom(id: 'r3', name: 'Salle 3', availableSlots: ['14:00', '18:00', '22:00']),
    ],
  ),
  MockCinema(
    id: 'c2',
    name: 'UGC Ciné Cité Confluence',
    city: 'Lyon',
    rooms: [
      MockRoom(id: 'r4', name: 'Salle 1', availableSlots: ['10:30', '14:30', '18:30', '21:30']),
      MockRoom(id: 'r5', name: 'Salle 2', availableSlots: ['12:00', '16:00', '20:00']),
    ],
  ),
  MockCinema(
    id: 'c3',
    name: 'Pathé Marseille',
    city: 'Marseille',
    rooms: [
      MockRoom(id: 'r6', name: 'Salle 1', availableSlots: ['11:00', '15:00', '19:00']),
    ],
  ),
  MockCinema(
    id: 'c4',
    name: 'CGR Bordeaux',
    city: 'Bordeaux',
    rooms: [
      MockRoom(id: 'r7', name: 'Salle 5', availableSlots: ['14:00', '18:30', '21:00']),
    ],
  ),
];
