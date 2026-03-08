/// Données mock pour les événements.
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

final mockEvents = [
  MockEvent(
    id: 'e1',
    title: 'Concert Électro Night',
    category: 'Concert',
    description:
        'Une soirée exceptionnelle avec les meilleurs DJs de la scène électronique internationale.',
    location: 'Gaumont Opéra',
    address: '2 Boulevard des Capucines, 75009 Paris',
    city: 'Paris',
    date: 'dimanche 15 mars 2026',
    time: '21:00',
    placesLeft: 120,
    placesTotal: 300,
    price: 35.00,
    posterColor: 0xFF4E1B3D,
  ),
  MockEvent(
    id: 'e2',
    title: 'Festival Jazz Live',
    category: 'Concert',
    description: 'Grande soirée jazz avec des artistes internationaux.',
    location: 'Salle Pleyel',
    address: 'Paris',
    city: 'Paris',
    date: '20 mars 2026',
    time: '20:00',
    placesLeft: 80,
    placesTotal: 200,
    price: 45.00,
    posterColor: 0xFF1B4E3D,
  ),
  MockEvent(
    id: 'e3',
    title: 'Spectacle Théâtral - Hamlet',
    category: 'Théâtre',
    description: 'Représentation classique de Hamlet.',
    location: 'UGC Ciné Cité Confluence',
    address: 'Lyon',
    city: 'Lyon',
    date: '25 mars 2026',
    time: '19:30',
    placesLeft: 50,
    placesTotal: 150,
    price: 28.00,
    posterColor: 0xFF3D2B1B,
  ),
];

MockEvent? getEventById(String id) {
  try {
    return mockEvents.firstWhere((e) => e.id == id);
  } catch (_) {
    return null;
  }
}

final mockCities = ['Toutes', 'Paris', 'Lyon', 'Marseille', 'Bordeaux'];
final mockGenres = ['Tous', 'Action', 'Comédie', 'Drame', 'Science-Fiction', 'Horreur', 'Romance'];
final mockEventCategories = ['Toutes', 'Concert', 'Théâtre'];
