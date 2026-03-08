/// Réservation telle que vue par l'admin (liste pour la section Réservations).
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
  final String status; // 'confirmed', 'cancelled'
  final DateTime createdAt;
  final String? room;
  final bool? isEvent;
}

final mockAdminReservations = [
  MockAdminReservation(
    id: 'b1',
    userEmail: 'marie.dubois@email.com',
    title: 'Horizon Quantique',
    dateTime: '7 mars 2026 à 14:00',
    location: 'Gaumont Opéra - Paris',
    totalAmount: 25.00,
    ticketCount: 2,
    status: 'confirmed',
    createdAt: DateTime(2026, 3, 1, 10, 30),
    room: 'Salle 2',
    isEvent: false,
  ),
  MockAdminReservation(
    id: 'b2',
    userEmail: 'marie.dubois@email.com',
    title: 'Concert Électro Night',
    dateTime: '15 mars 2026 à 21:00',
    location: 'Gaumont Opéra - Paris',
    totalAmount: 70.00,
    ticketCount: 2,
    status: 'confirmed',
    createdAt: DateTime(2026, 3, 5, 18, 0),
    room: null,
    isEvent: true,
  ),
  MockAdminReservation(
    id: 'b3',
    userEmail: 'jean.dupont@email.com',
    title: 'Rire et Préjugés',
    dateTime: '10 mars 2026 à 20:00',
    location: 'UGC Ciné Cité Confluence - Lyon',
    totalAmount: 45.50,
    ticketCount: 3,
    status: 'cancelled',
    createdAt: DateTime(2026, 3, 2, 14, 0),
    room: 'Salle 2',
    isEvent: false,
  ),
];
