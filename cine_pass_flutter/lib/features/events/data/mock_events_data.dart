/// Modèles événements. Données réelles via backend (plus de mock).
class MockEvent {
  MockEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.address,
    required this.city,
    required this.date,
    required this.time,
    required this.placesLeft,
    required this.placesTotal,
    required this.price,
    required this.posterColor,
    this.availableOptions = const ['parking', 'popcorn', 'boisson'],
  });
  final String id;
  final String title;
  final String category; // Concert, Théâtre
  final String description;
  final String location;
  final String address;
  final String city;
  final String date;
  final String time;
  final int placesLeft;
  final int placesTotal;
  final double price;
  final int posterColor;

  /// Options sélectionnables par l'admin à la création (affichées à la résa).
  final List<String> availableOptions;
}

/// Liste vide : à alimenter via le backend.
final mockEvents = <MockEvent>[];

MockEvent? getEventById(String id) {
  return null;
}

const mockCities = ['Toutes'];
const mockGenres = ['Tous'];
const mockEventCategories = ['Toutes'];
