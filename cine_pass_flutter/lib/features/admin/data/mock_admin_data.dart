// Modèles admin. Données réelles via backend (plus de mock).

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
  final String role;
  final String status;
  final String createdAt;
  final String? phone;
}

/// Liste vide : à alimenter via le backend.
final mockAdminUsers = <MockAdminUser>[];

String releaseDateForFilmId(String id) {
  return '--/--/----';
}

String endDateForFilmId(String id) {
  return '--/--/----';
}

String audienceForFilmId(String id) {
  return 'Tous publics';
}

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
  final List<String> availableSlots;
}

/// Liste vide : à alimenter via le backend.
final mockCinemas = <MockCinema>[];
