/// Réservation vue par l'admin. Données réelles via backend (plus de mock).
class MockAdminReservation {
  MockAdminReservation({
    required this.id,
    required this.userEmail,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.totalAmount,
    required this.ticketCount,
    required this.status,
    required this.createdAt,
    this.room,
    this.isEvent,
  });
  final String id;
  final String userEmail;
  final String title;
  final String dateTime;
  final String location;
  final double totalAmount;
  final int ticketCount;
  final String status;
  final DateTime createdAt;
  final String? room;
  final bool? isEvent;
}

/// Liste vide : à alimenter via le backend.
final mockAdminReservations = <MockAdminReservation>[];
