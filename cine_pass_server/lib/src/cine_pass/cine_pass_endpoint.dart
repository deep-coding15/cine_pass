import 'package:serverpod/serverpod.dart';
import '../generated/cine_pass/film_response.dart';
import '../generated/cine_pass/seance_response.dart';
import '../generated/cine_pass/event_response.dart';
import '../generated/cine_pass/cinema_response.dart';

/// Endpoint CinePass : films, séances, cinémas, événements (données BDD).
class CinePassEndpoint extends Endpoint {
  /// Liste de tous les films.
  Future<List<FilmResponse>> getFilms(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'SELECT id, titre, genre, duree_minutes, synopsis, directeur, casting, poster_color FROM cine_pass_film ORDER BY titre',
      );
      return result.map((row) => _rowToFilmResponse(row)).toList();
    } catch (e, st) {
      session.log('CinePass getFilms', level: LogLevel.error, exception: e, stackTrace: st);
      return [];
    }
  }

  /// Détail d'un film par id.
  Future<FilmResponse?> getFilmById(Session session, String id) async {
    try {
      final result = await session.db.unsafeQuery(
        r'SELECT id, titre, genre, duree_minutes, synopsis, directeur, casting, poster_color FROM cine_pass_film WHERE id = @id',
        parameters: QueryParameters.named({'id': id}),
      );
      if (result.isEmpty) return null;
      return _rowToFilmResponse(result.first);
    } catch (_) {
      return null;
    }
  }

  /// Séances pour un film (avec nom cinéma, salle, ville).
  Future<List<SeanceResponse>> getSeancesForFilm(
    Session session,
    String filmId,
  ) async {
    try {
      const sql = r"""
      SELECT s.id, s.debut_at, s.fin_at, s.format, s.type, s.prix_base, s.available_options,
             c.nom AS cinema_nom, c.ville AS cinema_ville, c.adresse AS cinema_adresse,
             sal.nom AS salle_nom, sal.capacite AS salle_capacite
      FROM cine_pass_seance s
      JOIN cine_pass_salle sal ON sal.id = s.salle_id
      JOIN cine_pass_cinema c ON c.id = sal.cinema_id
      WHERE s.film_id = (@filmId)::uuid
      ORDER BY s.debut_at
      """;
      final result = await session.db.unsafeQuery(
        sql,
        parameters: QueryParameters.named({'filmId': filmId}),
      );
      return result.map((row) => _rowToSeanceResponse(row)).toList();
    } catch (e, st) {
      session.log('CinePass getSeancesForFilm', level: LogLevel.error, exception: e, stackTrace: st);
      return [];
    }
  }

  /// Liste des cinémas.
  Future<List<CinemaResponse>> getCinemas(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'SELECT id, nom, ville, adresse FROM cine_pass_cinema ORDER BY ville, nom',
      );
      return result.map((row) => _rowToCinemaResponse(row)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Liste des événements à venir.
  Future<List<EventResponse>> getEvents(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'''
      SELECT id, titre, categorie, description, lieu, adresse, ville,
             event_date, event_time, places_total, prix_base, poster_color, available_options
      FROM cine_pass_evenement
      WHERE event_date >= CURRENT_DATE
      ORDER BY event_date, event_time
      ''',
      );
      return result.map((row) => _rowToEventResponse(row)).toList();
    } catch (e, st) {
      session.log('CinePass getEvents', level: LogLevel.error, exception: e, stackTrace: st);
      return [];
    }
  }

  /// Détail d'un événement par id.
  Future<EventResponse?> getEventById(Session session, String id) async {
    try {
      final result = await session.db.unsafeQuery(
        r"""
      SELECT id, titre, categorie, description, lieu, adresse, ville,
             event_date, event_time, places_total, prix_base, poster_color, available_options
      FROM cine_pass_evenement WHERE id = (@id)::uuid
      """,
        parameters: QueryParameters.named({'id': id}),
      );
      if (result.isEmpty) return null;
      return _rowToEventResponse(result.first);
    } catch (e, st) {
      session.log('CinePass getEventById', level: LogLevel.error, exception: e, stackTrace: st);
      return null;
    }
  }

  /// Villes distinctes (films + événements) pour les filtres.
  Future<List<String>> getCities(Session session) async {
    try {
      final set = <String>{};
      final films = await session.db.unsafeQuery(
        r'SELECT DISTINCT ville FROM cine_pass_cinema ORDER BY ville',
      );
      for (final row in films) {
        set.add(row[0] as String);
      }
      final events = await session.db.unsafeQuery(
        r'SELECT DISTINCT ville FROM cine_pass_evenement ORDER BY ville',
      );
      for (final row in events) {
        set.add(row[0] as String);
      }
      final list = set.toList()..sort();
      return ['Toutes', ...list];
    } catch (_) {
      return ['Toutes'];
    }
  }

  /// Genres distincts (films) pour les filtres.
  Future<List<String>> getGenres(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'SELECT DISTINCT genre FROM cine_pass_film ORDER BY genre',
      );
      return ['Tous', ...result.map((row) => row[0] as String)];
    } catch (_) {
      return ['Tous'];
    }
  }

  /// Catégories d'événements pour les filtres.
  Future<List<String>> getEventCategories(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'SELECT DISTINCT categorie FROM cine_pass_evenement ORDER BY categorie',
      );
      return ['Toutes', ...result.map((row) => row[0] as String)];
    } catch (_) {
      return ['Toutes'];
    }
  }

  static int _safeInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _safeDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static DateTime? _safeDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static FilmResponse _rowToFilmResponse(List<dynamic> row) {
    return FilmResponse(
      id: row[0].toString(),
      title: (row.length > 1 ? row[1] as String? : null) ?? '',
      genre: (row.length > 2 ? row[2] as String? : null) ?? '',
      durationMinutes: _safeInt(row.length > 3 ? row[3] : 0),
      synopsis: row.length > 4 ? row[4] as String? : null,
      director: row.length > 5 ? row[5] as String? : null,
      casting: row.length > 6 ? row[6] as String? : null,
      posterColor: row.length > 7 ? _safeInt(row[7]) : null,
    );
  }

  static SeanceResponse _rowToSeanceResponse(List<dynamic> row) {
    final debut = row.length > 1 ? _safeDateTime(row[1]) : null;
    final format = row.length > 3 ? (row[3] as String?) ?? 'VF' : 'VF';
    final type = row.length > 4 ? (row[4] as String?) ?? '2D' : '2D';
    final prix = _safeDouble(row.length > 5 ? row[5] : 0);
    final optionsJson = row.length > 6 ? row[6] : null;
    List<String> options = const ['parking', 'popcorn', 'boisson'];
    if (optionsJson != null && optionsJson is List) {
      options = optionsJson.map((e) => e.toString()).toList();
    }
    final cinemaNom = (row.length > 7 ? row[7] as String? : null) ?? '';
    final ville = (row.length > 8 ? row[8] as String? : null) ?? '';
    final salleNom = (row.length > 10 ? row[10] as String? : null) ?? '';
    final capacite = row.length > 11 ? _safeInt(row[11]) : 0;
    final location = '$cinemaNom - $ville';
    final dateTime = debut != null
        ? '${debut.day.toString().padLeft(2, '0')}/${debut.month.toString().padLeft(2, '0')}/${debut.year} à ${debut.hour.toString().padLeft(2, '0')}:${debut.minute.toString().padLeft(2, '0')}'
        : '--';
    return SeanceResponse(
      id: row[0].toString(),
      cinemaName: cinemaNom,
      location: location,
      room: salleNom,
      dateTime: dateTime,
      format: format,
      type: type,
      placesLeft: capacite,
      placesTotal: capacite,
      price: prix,
      availableOptions: options,
    );
  }

  static EventResponse _rowToEventResponse(List<dynamic> row) {
    final date = row.length > 7 ? row[7] : null;
    final time = row.length > 8 ? row[8] : null;
    final placesTotal = row.length > 9 ? _safeInt(row[9]) : 0;
    final optionsJson = row.length > 12 ? row[12] : null;
    List<String> options = const ['parking', 'popcorn', 'boisson'];
    if (optionsJson != null && optionsJson is List) {
      options = optionsJson.map((e) => e.toString()).toList();
    }
    String dateStr = '--';
    String timeStr = '--';
    if (date != null) {
      final d = _safeDateTime(date);
      if (d != null) {
        dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      } else {
        final s = date.toString();
        dateStr = s.length >= 10 ? s.substring(0, 10) : s;
      }
    }
    if (time != null) {
      final s = time.toString();
      // "21:00:00" or "21:00" or Duration
      if (s.length >= 5) timeStr = s.substring(0, 5);
    }
    final price = row.length > 10 ? _safeDouble(row[10]) : 0.0;
    final posterColor = row.length > 11 && row[11] != null ? _safeInt(row[11]) : null;
    return EventResponse(
      id: row[0].toString(),
      title: row[1] as String? ?? '',
      category: row[2] as String? ?? '',
      description: row[3] as String?,
      location: row[4] as String? ?? '',
      address: row[5] as String?,
      city: row[6] as String? ?? '',
      date: dateStr,
      time: timeStr,
      placesLeft: placesTotal,
      placesTotal: placesTotal,
      price: price,
      posterColor: posterColor,
      availableOptions: options,
    );
  }

  static CinemaResponse _rowToCinemaResponse(List<dynamic> row) {
    return CinemaResponse(
      id: row[0].toString(),
      name: row.length > 1 ? (row[1] as String?) ?? '' : '',
      city: row.length > 2 ? (row[2] as String?) ?? '' : '',
      address: row.length > 3 ? row[3] as String? : null,
    );
  }
}
