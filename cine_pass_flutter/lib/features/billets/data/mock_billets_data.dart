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

/// Barème indicatif : ≥48h 100%, 24–48h 80%, 2–24h 50%, moins de 2h 0% (non annulable dans l’app).
int getRefundPercent(DateTime sessionDateTime) {
  final now = DateTime.now();
  if (!sessionDateTime.isAfter(now)) return 0;
  final diff = sessionDateTime.difference(now);
  if (diff >= const Duration(hours: 48)) return 100;
  if (diff >= const Duration(hours: 24)) return 80;
  if (diff >= const Duration(hours: 2)) return 50;
  return 0;
}

/// Annulation possible uniquement s’il reste **au moins 2 h** avant le début.
bool canCancelReservation(DateTime sessionDateTime) {
  final now = DateTime.now();
  if (!sessionDateTime.isAfter(now)) return false;
  return sessionDateTime.difference(now) >= const Duration(hours: 2);
}
