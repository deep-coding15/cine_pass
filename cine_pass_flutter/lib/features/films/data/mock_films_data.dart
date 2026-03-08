/// Données mock pour les films et séances.
class MockFilm {
  MockFilm({
    required this.id,
    required this.title,
    required this.genre,
    required this.durationMinutes,
    required this.synopsis,
    required this.director,
    required this.casting,
    required this.posterColor,
  });
  final String id;
  final String title;
  final String genre;
  final int durationMinutes;
  final String synopsis;
  final String director;
  final String casting;
  final int posterColor;
}

class MockSeance {
  MockSeance({
    required this.id,
    required this.cinemaName,
    required this.location,
    required this.room,
    required this.dateTime,
    this.format = 'VF',
    this.type = '2D',
    required this.placesLeft,
    required this.placesTotal,
    required this.price,
    this.availableOptions = const ['parking', 'popcorn', 'boisson'],
  });
  final String id;
  final String cinemaName;
  final String location;
  final String room;
  final String dateTime;
  final String format;
  final String type;
  final int placesLeft;
  final int placesTotal;
  final double price;
  /// Options définies par l'admin pour cette séance (affichées à la résa).
  final List<String> availableOptions;
}

final mockFilms = [
  MockFilm(
    id: '1',
    title: 'Horizon Quantique',
    genre: 'Science-Fiction',
    durationMinutes: 142,
    synopsis:
        'Dans un futur proche, une physicienne découvre un moyen de voyager entre les dimensions parallèles. Mais chaque saut fragilise la réalité elle-même.',
    director: 'Sofia Chen',
    casting: 'Emma Laurent, Tom Bernard, Lisa Wang',
    posterColor: 0xFF2D1B4E,
  ),
  MockFilm(
    id: '2',
    title: 'Les Gardiens du Temps',
    genre: 'Action',
    durationMinutes: 135,
    synopsis: 'Une équipe doit empêcher la manipulation du temps pour sauver le monde.',
    director: 'Jean Dupont',
    casting: 'Pierre Martin, Léa Blanc',
    posterColor: 0xFF1B3D4E,
  ),
  MockFilm(
    id: '3',
    title: 'Rire et Préjugés',
    genre: 'Comédie',
    durationMinutes: 108,
    synopsis: 'Adaptation moderne d\'un classique, entre quiproquos et amour.',
    director: 'Marie Leroy',
    casting: 'Julie Petit, Marc Durand',
    posterColor: 0xFF4E3D1B,
  ),
  MockFilm(
    id: '4',
    title: 'Le Dernier Refuge',
    genre: 'Drame',
    durationMinutes: 128,
    synopsis: 'Un père et sa fille luttent pour survivre dans un monde en ruines.',
    director: 'Thomas Bernard',
    casting: 'Olivier Noir, Sophie Clair',
    posterColor: 0xFF2E1A1A,
  ),
];

MockFilm? getFilmById(String id) {
  try {
    return mockFilms.firstWhere((f) => f.id == id);
  } catch (_) {
    return null;
  }
}

final mockSeancesByFilm = <String, List<MockSeance>>{
  '1': [
    MockSeance(
      id: 's1',
      cinemaName: 'Gaumont Opéra',
      location: 'Paris - Salle 1',
      room: 'Salle 1',
      dateTime: '7 mars 2026 à 14:00',
      format: 'VF',
      type: '2D',
      placesLeft: 45,
      placesTotal: 150,
      price: 12.50,
    ),
    MockSeance(
      id: 's2',
      cinemaName: 'Gaumont Opéra',
      location: 'Paris - Salle 2',
      room: 'Salle 2',
      dateTime: '7 mars 2026 à 17:30',
      format: 'VO',
      type: '3D',
      placesLeft: 30,
      placesTotal: 120,
      price: 15.00,
    ),
    MockSeance(
      id: 's3',
      cinemaName: 'UGC Ciné Cité Confluence',
      location: 'Lyon - Salle 3',
      room: 'Salle 3',
      dateTime: '7 mars 2026 à 20:00',
      format: 'VF',
      type: 'IMAX',
      placesLeft: 20,
      placesTotal: 200,
      price: 18.00,
    ),
  ],
  '2': [
    MockSeance(
      id: 's4',
      cinemaName: 'Gaumont Opéra',
      location: 'Paris - Salle 4',
      room: 'Salle 4',
      dateTime: '7 mars 2026 à 19:00',
      format: 'VF',
      type: '2D',
      placesLeft: 60,
      placesTotal: 150,
      price: 12.50,
    ),
    MockSeance(
      id: 's5',
      cinemaName: 'Pathé Marseille',
      location: 'Marseille - Salle 1',
      room: 'Salle 1',
      dateTime: '8 mars 2026 à 15:00',
      format: 'VO',
      type: '2D',
      placesLeft: 80,
      placesTotal: 100,
      price: 11.00,
    ),
  ],
  '3': [
    MockSeance(
      id: 's6',
      cinemaName: 'UGC Ciné Cité Confluence',
      location: 'Lyon - Salle 2',
      room: 'Salle 2',
      dateTime: '7 mars 2026 à 21:00',
      format: 'VF',
      type: '2D',
      placesLeft: 50,
      placesTotal: 120,
      price: 12.50,
    ),
  ],
  '4': [
    MockSeance(
      id: 's7',
      cinemaName: 'CGR Bordeaux',
      location: 'Bordeaux - Salle 5',
      room: 'Salle 5',
      dateTime: '7 mars 2026 à 18:30',
      format: 'VO',
      type: '2D',
      placesLeft: 35,
      placesTotal: 100,
      price: 12.00,
    ),
  ],
};

List<MockSeance> getSeancesForFilm(String filmId) {
  return mockSeancesByFilm[filmId] ?? [];
}

const mockCities = ['Toutes', 'Paris', 'Lyon', 'Marseille', 'Bordeaux'];
const mockGenres = ['Tous', 'Action', 'Comédie', 'Drame', 'Science-Fiction', 'Horreur', 'Romance'];
