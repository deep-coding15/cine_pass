import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'; // for session.authenticated
import '../generated/cine_pass/film_response.dart';
import '../generated/cine_pass/seance_response.dart';
import '../generated/cine_pass/event_response.dart';
import '../generated/cine_pass/cinema_response.dart';
import '../generated/cine_pass/demande_responsable_response.dart';
import '../generated/cine_pass/reservation_response.dart';
import '../generated/cine_pass/rapport_ca_response.dart';
import '../generated/salle.dart';
import '../generated/structure.dart';

/// Taux de commission CinePass sur chaque réservation (en %).
/// Ex. : 8.0 = 8 % du montant du billet gardé par la plateforme.
/// Voir docs/MONETISATION_STRATEGIE.md.
const double cinePassCommissionPercent = 8.0;

/// Endpoint CinePass : films, séances, cinémas, événements (données BDD).
class CinePassEndpoint extends Endpoint {
  /// Liste de tous les films.
  Future<List<FilmResponse>> getFilms(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'''
        SELECT "id", "titre", "genre", "dureeMinutes", "synopsis", "directeur",
               "casting", "posterColor"
        FROM "cine_pass_film"
        ORDER BY "titre"
        ''',
      );
      return result.map((row) => _rowToFilmResponse(row)).toList();
    } catch (e, st) {
      session.log(
        'CinePass getFilms',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Détail d'un film par id.
  Future<FilmResponse?> getFilmById(Session session, String id) async {
    try {
      final result = await session.db.unsafeQuery(
        r'''
        SELECT "id", "titre", "genre", "dureeMinutes", "synopsis", "directeur",
               "casting", "posterColor"
        FROM "cine_pass_film"
        WHERE "id" = @id
        ''',
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
      SELECT s."id",
             s."debutAt",
             s."finAt",
             s."format",
             s."type",
             s."prixBase",
             s."availableOptions",
             c."nom"   AS cinema_nom,
             c."ville" AS cinema_ville,
             c."adresse" AS cinema_adresse,
             sal."nom" AS salle_nom,
             sal."capacite" AS salle_capacite
      FROM "cine_pass_seance" s
      JOIN "cine_pass_salle" sal ON sal."id" = s."salleId"
      JOIN "cine_pass_cinema" c ON c."id" = sal."cinemaId"
      WHERE s."filmId" = (@filmId)::uuid
      ORDER BY s."debutAt"
      """;
      final result = await session.db.unsafeQuery(
        sql,
        parameters: QueryParameters.named({'filmId': filmId}),
      );
      return result.map((row) => _rowToSeanceResponse(row)).toList();
    } catch (e, st) {
      session.log(
        'CinePass getSeancesForFilm',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Liste des cinémas.
  Future<List<CinemaResponse>> getCinemas(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'SELECT "id", "nom", "ville", "adresse" FROM "cine_pass_cinema" ORDER BY "ville", "nom"',
      );
      return result.map((row) => _rowToCinemaResponse(row)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Liste des salles (pour admin séances).
  Future<List<Salle>> getSalles(Session session) async {
    try {
      return await Salle.db.find(session, orderBy: (t) => t.nom);
    } catch (e, st) {
      session.log('CinePass getSalles', level: LogLevel.error, exception: e, stackTrace: st);
      return [];
    }
  }

  /// Liste des événements à venir.
  Future<List<EventResponse>> getEvents(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'''
      SELECT "id", "titre", "categorie", "description", "lieu", "adresse", "ville",
             "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor", "availableOptions"
      FROM "cine_pass_evenement"
      WHERE "eventDate" >= CURRENT_DATE
      ORDER BY "eventDate", "eventTime"
      ''',
      );
      return result.map((row) => _rowToEventResponse(row)).toList();
    } catch (e, st) {
      session.log(
        'CinePass getEvents',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Détail d'un événement par id.
  Future<EventResponse?> getEventById(Session session, String id) async {
    try {
      final result = await session.db.unsafeQuery(
        r"""
      SELECT "id", "titre", "categorie", "description", "lieu", "adresse", "ville",
             "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor", "availableOptions"
      FROM "cine_pass_evenement" WHERE "id" = (@id)::uuid
      """,
        parameters: QueryParameters.named({'id': id}),
      );
      if (result.isEmpty) return null;
      return _rowToEventResponse(result.first);
    } catch (e, st) {
      session.log(
        'CinePass getEventById',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
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

  /// Admin: créer un film.
  Future<FilmResponse?> createFilm(
    Session session, {
    required String title,
    required String genre,
    required int durationMinutes,
    String? synopsis,
    String? director,
    String? casting,
    int? posterColor,
    Object? dateSortie,
    Object? dateFin,
    String? audience,
  }) async {
    try {
      final dSortie = _parseDateTime(dateSortie);
      final dFin = _parseDateTime(dateFin);
      final id = await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_film" (
          "titre", "genre", "dureeMinutes", "synopsis", "directeur",
          "casting", "posterColor", "dateSortie", "dateFin", "audience"
        )
        VALUES (
          @titre, @genre, @dureeMinutes, @synopsis, @directeur,
          @casting, @posterColor, @dateSortie, @dateFin, @audience
        )
        RETURNING "id", "titre", "genre", "dureeMinutes", "synopsis", "directeur",
                  "casting", "posterColor"
        ''',
        parameters: QueryParameters.named({
          'titre': title,
          'genre': genre,
          'dureeMinutes': durationMinutes,
          'synopsis': synopsis,
          'directeur': director,
          'casting': casting,
          'posterColor': posterColor,
          'dateSortie': dSortie,
          'dateFin': dFin,
          'audience': audience,
        }),
      );
      if (id.isEmpty) return null;
      return _rowToFilmResponse(id.first);
    } catch (e, st) {
      session.log('CinePass createFilm', level: LogLevel.error, exception: e, stackTrace: st);
      return null;
    }
  }

  /// Admin / Responsable: créer un événement (optionnellement lié à une structure).
  Future<EventResponse?> createEvent(
    Session session, {
    required String titre,
    required String categorie,
    String? description,
    required String lieu,
    String? adresse,
    required String ville,
    required Object eventDate,
    required String eventTimeStr,
    required int placesTotal,
    required double prixBase,
    int? posterColor,
    String? structureId,
  }) async {
    try {
      final eventDateDt = _parseDateTime(eventDate);
      if (eventDateDt == null) return null;
      DateTime eventTime = eventDateDt;
      if (eventTimeStr.length >= 5) {
        final parts = eventTimeStr.split(':');
        if (parts.length >= 2) {
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          eventTime = DateTime(eventDateDt.year, eventDateDt.month, eventDateDt.day, h, m);
        }
      }
      final result = await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_evenement" (
          "titre", "categorie", "description", "lieu", "adresse", "ville",
          "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor", "structureId"
        )
        VALUES (
          @titre, @categorie, @description, @lieu, @adresse, @ville,
          @eventDate, @eventTime, @placesTotal, @prixBase, @posterColor,
          CASE WHEN @structureId::text = '' OR @structureId IS NULL THEN NULL ELSE (@structureId)::uuid END
        )
        RETURNING "id", "titre", "categorie", "description", "lieu", "adresse", "ville",
                  "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor", "availableOptions"
        ''',
        parameters: QueryParameters.named({
          'titre': titre,
          'categorie': categorie,
          'description': description,
          'lieu': lieu,
          'adresse': adresse,
          'ville': ville,
          'eventDate': eventDateDt,
          'eventTime': eventTime,
          'placesTotal': placesTotal,
          'prixBase': prixBase,
          'posterColor': posterColor,
          'structureId': structureId ?? '',
        }),
      );
      if (result.isEmpty) return null;
      return _rowToEventResponse(result.first);
    } catch (e, st) {
      session.log('CinePass createEvent', level: LogLevel.error, exception: e, stackTrace: st);
      return null;
    }
  }

  /// Liste de toutes les structures (admin).
  Future<List<Structure>> getStructures(Session session) async {
    try {
      return await Structure.db.find(session, orderBy: (t) => t.name);
    } catch (e, st) {
      session.log('CinePass getStructures', level: LogLevel.error, exception: e, stackTrace: st);
      return [];
    }
  }

  /// Détail d'une structure par id (admin).
  Future<Structure?> getStructureById(Session session, String id) async {
    try {
      final list = await Structure.db.find(session);
      for (final s in list) {
        if (s.id.toString() == id) return s;
      }
      return null;
    } catch (e, st) {
      session.log('CinePass getStructureById', level: LogLevel.error, exception: e, stackTrace: st);
      return null;
    }
  }

  /// Mettre à jour un événement (admin ou responsable de la structure).
  Future<EventResponse?> updateEvent(
    Session session, {
    required String id,
    String? titre,
    String? categorie,
    String? description,
    String? lieu,
    String? adresse,
    String? ville,
    Object? eventDate,
    String? eventTimeStr,
    int? placesTotal,
    double? prixBase,
    int? posterColor,
  }) async {
    try {
      final eventDateDt = eventDate != null ? _parseDateTime(eventDate) : null;
      DateTime? eventTimeDt;
      if (eventDateDt != null && eventTimeStr != null && eventTimeStr.length >= 5) {
        final parts = eventTimeStr.split(':');
        if (parts.length >= 2) {
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          eventTimeDt = DateTime(eventDateDt.year, eventDateDt.month, eventDateDt.day, h, m);
        }
      }
      final result = await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_evenement"
        SET
          "titre" = CASE WHEN @titre IS NOT NULL AND @titre != '' THEN @titre ELSE "titre" END,
          "categorie" = CASE WHEN @categorie IS NOT NULL AND @categorie != '' THEN @categorie ELSE "categorie" END,
          "description" = CASE WHEN @description IS NOT NULL THEN @description ELSE "description" END,
          "lieu" = CASE WHEN @lieu IS NOT NULL AND @lieu != '' THEN @lieu ELSE "lieu" END,
          "adresse" = CASE WHEN @adresse IS NOT NULL THEN @adresse ELSE "adresse" END,
          "ville" = CASE WHEN @ville IS NOT NULL AND @ville != '' THEN @ville ELSE "ville" END,
          "eventDate" = CASE WHEN @eventDate IS NOT NULL THEN @eventDate ELSE "eventDate" END,
          "eventTime" = CASE WHEN @eventTime IS NOT NULL THEN @eventTime ELSE "eventTime" END,
          "placesTotal" = CASE WHEN @placesTotal IS NOT NULL THEN @placesTotal ELSE "placesTotal" END,
          "prixBase" = CASE WHEN @prixBase IS NOT NULL THEN @prixBase ELSE "prixBase" END,
          "posterColor" = CASE WHEN @posterColor IS NOT NULL THEN @posterColor ELSE "posterColor" END
        WHERE "id" = (@id)::uuid
        RETURNING "id", "titre", "categorie", "description", "lieu", "adresse", "ville",
                  "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor", "availableOptions"
        ''',
        parameters: QueryParameters.named({
          'id': id,
          'titre': titre,
          'categorie': categorie,
          'description': description,
          'lieu': lieu,
          'adresse': adresse,
          'ville': ville,
          'eventDate': eventDateDt,
          'eventTime': eventTimeDt,
          'placesTotal': placesTotal,
          'prixBase': prixBase,
          'posterColor': posterColor,
        }),
      );
      if (result.isEmpty) return null;
      return _rowToEventResponse(result.first);
    } catch (e, st) {
      session.log('CinePass updateEvent', level: LogLevel.error, exception: e, stackTrace: st);
      return null;
    }
  }

  /// Supprimer un événement (admin ou responsable de la structure).
  Future<bool> deleteEvent(Session session, String id) async {
    try {
      await session.db.unsafeQuery(
        r'DELETE FROM "cine_pass_evenement" WHERE "id" = (@id)::uuid',
        parameters: QueryParameters.named({'id': id}),
      );
      return true;
    } catch (e, st) {
      session.log('CinePass deleteEvent', level: LogLevel.error, exception: e, stackTrace: st);
      return false;
    }
  }

  /// Structure(s) assignée(s) au responsable connecté.
  Future<Structure?> getMyStructure(Session session) async {
    try {
      final userId = session.authenticated?.userIdentifier;
      if (userId == null) return null;
      final rows = await session.db.unsafeQuery(
        r'SELECT "structure_id" FROM "cine_pass_responsable_assignment" WHERE "user_id" = (@uid)::uuid AND "active" = true LIMIT 1',
        parameters: QueryParameters.named({'uid': userId}),
      );
      if (rows.isEmpty) return null;
      final structureId = rows.first[0].toString();
      final all = await Structure.db.find(session);
      for (final s in all) {
        if (s.id.toString() == structureId) return s;
      }
      return null;
    } catch (e, st) {
      session.log('CinePass getMyStructure', level: LogLevel.error, exception: e, stackTrace: st);
      return null;
    }
  }

  /// Événements des structures du responsable connecté.
  Future<List<EventResponse>> getMyEvents(Session session) async {
    try {
      final userId = session.authenticated?.userIdentifier;
      if (userId == null) return [];
      final result = await session.db.unsafeQuery(
        r'''
        SELECT e."id", e."titre", e."categorie", e."description", e."lieu", e."adresse", e."ville",
               e."eventDate", e."eventTime", e."placesTotal", e."prixBase", e."posterColor", e."availableOptions"
        FROM "cine_pass_evenement" e
        WHERE e."structureId" IN (
          SELECT a."structure_id" FROM "cine_pass_responsable_assignment" a
          WHERE a."user_id" = (@uid)::uuid AND a."active" = true
        )
        ORDER BY e."eventDate", e."eventTime"
        ''',
        parameters: QueryParameters.named({'uid': userId}),
      );
      return result.map((row) => _rowToEventResponse(row)).toList();
    } catch (e, st) {
      session.log('CinePass getMyEvents', level: LogLevel.error, exception: e, stackTrace: st);
      return [];
    }
  }

  /// Admin: demandes en attente (devenir responsable).
  Future<List<DemandeResponsableResponse>> getDemandesEnAttente(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'''
        SELECT r."id", r."user_id", r."structure_type", r."structure_name", r."structure_city",
               r."structure_address", r."status", r."created_at",
               COALESCE(r."professional_email", '') AS user_name
        FROM "cine_pass_responsable_request" r
        WHERE r."status" = 'PENDING'
        ORDER BY r."created_at" ASC
        ''',
      );
      return result.map((row) => _rowToDemandeResponsableResponse(row)).toList();
    } catch (e, st) {
      session.log('CinePass getDemandesEnAttente', level: LogLevel.error, exception: e, stackTrace: st);
      return [];
    }
  }

  /// Admin: approuver une demande responsable → crée la structure et l'assignment.
  Future<bool> approuverDemande(Session session, String id) async {
    try {
      final adminId = session.authenticated?.userIdentifier;
      if (adminId == null) return false;
      final rows = await session.db.unsafeQuery(
        r'''
        SELECT "user_id", "structure_type", "structure_name", "structure_city", "structure_address",
               "structure_website", "structure_phone"
        FROM "cine_pass_responsable_request"
        WHERE "id" = (@id)::uuid AND "status" = 'PENDING'
        ''',
        parameters: QueryParameters.named({'id': id}),
      );
      if (rows.isEmpty) return false;
      final r = rows.first;
      final userId = r[0].toString();
      final type = (r[1] as String?) ?? 'ORGANIZER';
      final name = (r[2] as String?) ?? '';
      final city = (r[3] as String?) ?? '';
      final address = r[4] as String?;
      final website = r[5] as String?;
      final phone = r[6] as String?;
      final structureResult = await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_structure" ("type", "name", "city", "address", "website", "phone")
        VALUES (@type, @name, @city, @address, @website, @phone)
        RETURNING "id"
        ''',
        parameters: QueryParameters.named({
          'type': type,
          'name': name,
          'city': city,
          'address': address,
          'website': website,
          'phone': phone,
        }),
      );
      if (structureResult.isEmpty) return false;
      final structureId = structureResult.first[0].toString();
      await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_responsable_assignment" ("user_id", "structure_id", "active")
        VALUES ((@uid)::uuid, (@sid)::uuid, true)
        ON CONFLICT ("user_id", "structure_id") DO UPDATE SET "active" = true
        ''',
        parameters: QueryParameters.named({'uid': userId, 'sid': structureId}),
      );
      await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_responsable_request"
        SET "status" = 'APPROVED', "decided_at" = now(), "admin_id" = (@adminId)::uuid
        WHERE "id" = (@id)::uuid
        ''',
        parameters: QueryParameters.named({'id': id, 'adminId': adminId}),
      );
      return true;
    } catch (e, st) {
      session.log('CinePass approuverDemande', level: LogLevel.error, exception: e, stackTrace: st);
      return false;
    }
  }

  /// Admin: rejeter une demande responsable.
  Future<bool> rejeterDemande(Session session, String id, String reason) async {
    try {
      final adminId = session.authenticated?.userIdentifier;
      if (adminId == null) return false;
      await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_responsable_request"
        SET "status" = 'REJECTED', "decided_at" = now(), "admin_id" = (@adminId)::uuid, "rejection_reason" = @reason
        WHERE "id" = (@id)::uuid
        ''',
        parameters: QueryParameters.named({'id': id, 'adminId': adminId, 'reason': reason}),
      );
      return true;
    } catch (e, st) {
      session.log('CinePass rejeterDemande', level: LogLevel.error, exception: e, stackTrace: st);
      return false;
    }
  }

  /// Créer une demande pour devenir responsable (utilisateur connecté).
  Future<DemandeResponsableResponse?> createDemandeResponsable(
    Session session, {
    required String structureType,
    required String structureName,
    required String structureCity,
    String? structureAddress,
    String? structureWebsite,
    String? structurePhone,
    required String description,
  }) async {
    try {
      final userId = session.authenticated?.userIdentifier;
      if (userId == null) return null;
      final result = await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_responsable_request" (
          "user_id", "structure_type", "structure_name", "structure_city",
          "structure_address", "structure_website", "structure_phone", "description", "status"
        )
        VALUES (
          (@uid)::uuid, @structureType, @structureName, @structureCity,
          @structureAddress, @structureWebsite, @structurePhone, @description, 'PENDING'
        )
        RETURNING "id", "user_id", "structure_type", "structure_name", "structure_city",
                  "structure_address", "status", "created_at"
        ''',
        parameters: QueryParameters.named({
          'uid': userId,
          'structureType': structureType,
          'structureName': structureName,
          'structureCity': structureCity,
          'structureAddress': structureAddress,
          'structureWebsite': structureWebsite,
          'structurePhone': structurePhone,
          'description': description,
        }),
      );
      if (result.isEmpty) return null;
      final row = result.first;
      final createdAt = row[7];
      String createdAtStr = '';
      if (createdAt != null) {
        final dt = _safeDateTime(createdAt);
        if (dt != null) createdAtStr = dt.toIso8601String();
        else createdAtStr = createdAt.toString();
      }
      return DemandeResponsableResponse(
        id: row[0].toString(),
        userId: row[1].toString(),
        structureType: (row[2] as String?) ?? '',
        structureName: (row[3] as String?) ?? '',
        structureCity: (row[4] as String?) ?? '',
        structureAddress: row[5] as String?,
        status: (row[6] as String?) ?? 'PENDING',
        createdAt: createdAtStr,
        userName: null,
      );
    } catch (e, st) {
      session.log('CinePass createDemandeResponsable', level: LogLevel.error, exception: e, stackTrace: st);
      return null;
    }
  }

  /// Admin: toutes les réservations (événements et séances).
  Future<List<ReservationResponse>> getReservations(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'''
        SELECT r."id", r."numero", r."total_amount", r."created_at", r."statut",
               e."titre" AS event_title,
               (SELECT COUNT(*) FROM "cine_pass_billet" b WHERE b."reservation_id" = r."id") AS nb_billets
        FROM "cine_pass_reservation" r
        LEFT JOIN "cine_pass_evenement" e ON e."id" = r."evenement_id"
        ORDER BY r."created_at" DESC
        ''',
      );
      return result.map((row) => _rowToReservationResponse(row)).toList();
    } catch (e, st) {
      session.log('CinePass getReservations', level: LogLevel.error, exception: e, stackTrace: st);
      return [];
    }
  }

  /// Responsable: réservations pour les événements de ses structures.
  Future<List<ReservationResponse>> getReservationsForMyStructures(Session session) async {
    try {
      final userId = session.authenticated?.userIdentifier;
      if (userId == null) return [];
      final result = await session.db.unsafeQuery(
        r'''
        SELECT r."id", r."numero", r."total_amount", r."created_at", r."statut",
               e."titre" AS event_title,
               (SELECT COUNT(*) FROM "cine_pass_billet" b WHERE b."reservation_id" = r."id") AS nb_billets
        FROM "cine_pass_reservation" r
        JOIN "cine_pass_evenement" e ON e."id" = r."evenement_id"
        WHERE e."structureId" IN (
          SELECT a."structure_id" FROM "cine_pass_responsable_assignment" a
          WHERE a."user_id" = (@uid)::uuid AND a."active" = true
        )
        ORDER BY r."created_at" DESC
        ''',
        parameters: QueryParameters.named({'uid': userId}),
      );
      return result.map((row) => _rowToReservationResponse(row)).toList();
    } catch (e, st) {
      session.log('CinePass getReservationsForMyStructures', level: LogLevel.error, exception: e, stackTrace: st);
      return [];
    }
  }

  /// Responsable: rapport CA sur une période (7j, 30j, 3m, 1an).
  Future<RapportCAResponse> getRapportCA(Session session, String periode) async {
    try {
      final userId = session.authenticated?.userIdentifier;
      if (userId == null) return RapportCAResponse(totalCA: 0, nbReservations: 0);
      String intervalExpr = "interval '30 days'";
      if (periode == '7j') intervalExpr = "interval '7 days'";
      else if (periode == '3m') intervalExpr = "interval '3 months'";
      else if (periode == '1an') intervalExpr = "interval '1 year'";
      final result = await session.db.unsafeQuery(
        '''
        SELECT COALESCE(SUM(r."total_amount"), 0)::double AS total, COUNT(r."id")::int AS nb
        FROM "cine_pass_reservation" r
        JOIN "cine_pass_evenement" e ON e."id" = r."evenement_id"
        WHERE e."structureId" IN (
          SELECT a."structure_id" FROM "cine_pass_responsable_assignment" a
          WHERE a."user_id" = (@uid)::uuid AND a."active" = true
        )
        AND r."created_at" >= now() - $intervalExpr
        '''.replaceAll(r'$intervalExpr', intervalExpr),
        parameters: QueryParameters.named({'uid': userId}),
      );
      if (result.isEmpty) return RapportCAResponse(totalCA: 0, nbReservations: 0);
      final row = result.first;
      final total = row[0] is num ? (row[0] as num).toDouble() : 0.0;
      final nb = row.length > 1 ? _safeInt(row[1]) : 0;
      return RapportCAResponse(totalCA: total, nbReservations: nb);
    } catch (e, st) {
      session.log('CinePass getRapportCA', level: LogLevel.error, exception: e, stackTrace: st);
      return RapportCAResponse(totalCA: 0, nbReservations: 0);
    }
  }

  /// Admin: créer une séance.
  Future<SeanceResponse?> createSeance(
    Session session, {
    required String filmId,
    required String salleId,
    required Object debutAt,
    Object? finAt,
    String format = 'VF',
    String type = '2D',
    required double prixBase,
  }) async {
    try {
      final debut = _parseDateTime(debutAt);
      if (debut == null) return null;
      final endDt = _parseDateTime(finAt);
      final end = endDt ?? debut.add(const Duration(minutes: 120));
      await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_seance" (
          "filmId", "salleId", "debutAt", "finAt", "format", "type", "prixBase"
        )
        VALUES (
          (@filmId)::uuid, (@salleId)::uuid, @debutAt, @finAt, @format, @type, @prixBase
        )
        ''',
        parameters: QueryParameters.named({
          'filmId': filmId,
          'salleId': salleId,
          'debutAt': debut,
          'finAt': end,
          'format': format,
          'type': type,
          'prixBase': prixBase,
        }),
      );
      final salleResult = await session.db.unsafeQuery(
        r'''
        SELECT s."id", s."debutAt", s."finAt", s."format", s."type", s."prixBase", s."availableOptions",
               c."nom", c."ville", c."adresse", sal."nom", sal."capacite"
        FROM "cine_pass_seance" s
        JOIN "cine_pass_salle" sal ON sal."id" = s."salleId"
        JOIN "cine_pass_cinema" c ON c."id" = sal."cinemaId"
        WHERE s."filmId" = (@filmId)::uuid
        ORDER BY s."debutAt" DESC
        LIMIT 1
        ''',
        parameters: QueryParameters.named({'filmId': filmId}),
      );
      if (salleResult.isEmpty) return null;
      return _rowToSeanceResponse(salleResult.first);
    } catch (e, st) {
      session.log('CinePass createSeance', level: LogLevel.error, exception: e, stackTrace: st);
      return null;
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

  static DateTime? _parseDateTime(Object? v) {
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
        dateStr =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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
    final posterColor = row.length > 11 && row[11] != null
        ? _safeInt(row[11])
        : null;
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

  static DemandeResponsableResponse _rowToDemandeResponsableResponse(List<dynamic> row) {
    final createdAt = row.length > 7 ? row[7] : null;
    String createdAtStr = '';
    if (createdAt != null) {
      final dt = _safeDateTime(createdAt);
      if (dt != null) createdAtStr = dt.toIso8601String();
      else createdAtStr = createdAt.toString();
    }
    return DemandeResponsableResponse(
      id: row[0].toString(),
      userId: row.length > 1 ? row[1].toString() : '',
      structureType: row.length > 2 ? (row[2] as String?) ?? '' : '',
      structureName: row.length > 3 ? (row[3] as String?) ?? '' : '',
      structureCity: row.length > 4 ? (row[4] as String?) ?? '' : '',
      structureAddress: row.length > 5 ? row[5] as String? : null,
      status: row.length > 6 ? (row[6] as String?) ?? 'PENDING' : 'PENDING',
      createdAt: createdAtStr,
      userName: row.length > 8 ? row[8] as String? : null,
    );
  }

  static ReservationResponse _rowToReservationResponse(List<dynamic> row) {
    final createdAt = row.length > 3 ? row[3] : null;
    String createdAtStr = '';
    if (createdAt != null) {
      final dt = _safeDateTime(createdAt);
      if (dt != null) createdAtStr = dt.toIso8601String();
      else createdAtStr = createdAt.toString();
    }
    final totalAmount = row.length > 2 ? _safeDouble(row[2]) : 0.0;
    final statut = row.length > 4 ? (row[4] as String?) ?? 'pending' : 'pending';
    final eventTitle = row.length > 5 ? row[5] as String? : null;
    final nbBillets = row.length > 6 ? _safeInt(row[6]) : 0;
    return ReservationResponse(
      id: row[0].toString(),
      numero: row.length > 1 ? (row[1] as String?) ?? '' : '',
      eventTitle: eventTitle,
      totalAmount: totalAmount,
      createdAtStr: createdAtStr,
      statut: statut,
      nbBillets: nbBillets,
    );
  }
}
