/// Modèles films / séances. Données réelles via backend (plus de mock).
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
  final List<String> availableOptions;
}

/// Liste vide : à alimenter via le backend.
final mockFilms = <MockFilm>[];

MockFilm? getFilmById(String id) {
  return null;
}

final mockSeancesByFilm = <String, List<MockSeance>>{};

List<MockSeance> getSeancesForFilm(String filmId) {
  return mockSeancesByFilm[filmId] ?? [];
}

const mockCities = ['Toutes'];
const mockGenres = ['Tous'];
