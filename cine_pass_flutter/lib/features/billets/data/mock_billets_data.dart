/// Modèle billet (film ou événement). Données réelles via backend (plus de mock).
/// Un seul QR code par réservation : il couvre tous les billets de la réservation.
class MockBillet {
  MockBillet({
    required this.id,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.totalAmount,
    this.seats,
    this.ticketCount,
    required this.isEvent,
    this.room,
    this.ticketTypes,
    required this.sessionDateTime,
  });
  final String id;
  final String title;
  final String location;
  final String dateTime;
  final double totalAmount;
  final List<String>? seats;
  final int? ticketCount;
  final bool isEvent;
  final String? room;
  final List<String>? ticketTypes;
  /// Date/heure de la séance ou de l'événement (pour calcul annulation / remboursement).
  final DateTime sessionDateTime;
}

/// Liste vide : à alimenter via le backend.
final mockBillets = <MockBillet>[];

/// Barème remboursement : ≥48h 100%, 24-48h 80%, 2-24h 50%, <2h 0%.
int getRefundPercent(DateTime sessionDateTime) {
  final now = DateTime.now();
  if (now.isAfter(sessionDateTime)) return 0;
  final diff = sessionDateTime.difference(now);
  final hours = diff.inHours + diff.inMinutes / 60;
  if (hours >= 48) return 100;
  if (hours >= 24) return 80;
  if (hours >= 2) return 50;
  return 0;
}

/// Annulation possible uniquement si ≥ 2 h avant (sinon 0% remboursement).
bool canCancelReservation(DateTime sessionDateTime) {
  final now = DateTime.now();
  if (now.isAfter(sessionDateTime)) return false;
  final diff = sessionDateTime.difference(now);
  final hours = diff.inHours + diff.inMinutes / 60;
  return hours >= 2;
}
