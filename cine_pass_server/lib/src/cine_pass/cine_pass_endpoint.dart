import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../auth/email_idp_mailer.dart';
import '../generated/film_response.dart';
import '../generated/seance_response.dart';
import '../generated/event_response.dart';
import '../generated/cinema_response.dart';
import '../generated/demande_responsable_response.dart';
import '../generated/reservation_response.dart';
import '../generated/rapport_ca_response.dart';
import '../generated/profile_response.dart';
import '../generated/billet_group_response.dart';
import '../generated/cine_pass/event_reservation_config_response.dart';
import '../generated/cine_pass/event_ticket_type_config_response.dart';
import '../generated/cine_pass/event_ticket_option_response.dart';
import '../generated/cine_pass/reservation_quote_response.dart';
import '../generated/cine_pass/reservation_quote_line_response.dart';
import '../generated/cine_pass/reservation_confirm_response.dart';
import '../generated/cine_pass/event_seat_plan_response.dart';
import '../generated/cine_pass/event_seat_plan_entry_response.dart';
import '../generated/salle.dart';
import '../generated/structure.dart';

/// Taux de commission CinePass sur chaque réservation (en %).
/// Ex. : 8.0 = 8 % du montant du billet gardé par la plateforme.
/// Voir docs/MONETISATION_STRATEGIE.md.
const double cinePassCommissionPercent = 8.0;

/// Endpoint CinePass : films, séances, cinémas, événements (données BDD).
class CinePassEndpoint extends Endpoint {
  String _eventTypeFromCategory(String? categorie) {
    final c = (categorie ?? '').trim().toLowerCase();
    if (c.contains('film')) return 'FILM';
    if (c.contains('festival')) return 'FESTIVAL';
    if (c.contains('stand-up') || c.contains('standup')) return 'STANDUP';
    if (c.contains('concert')) return 'CONCERT';
    if (c.contains('théâtre') || c.contains('theatre')) return 'THEATRE';
    return 'AUTRE';
  }

  String? _extractPrefixedValue(String? description, String prefix) {
    if (description == null || description.trim().isEmpty) return null;
    final needle = '${prefix.toLowerCase()}:';
    for (final line in description.split('\n')) {
      final t = line.trim();
      if (t.toLowerCase().startsWith(needle)) {
        final value = t.substring(needle.length).trim();
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }

  int? _parsePositiveInt(String? raw) {
    final v = int.tryParse((raw ?? '').trim());
    if (v == null || v <= 0) return null;
    return v;
  }

  Map<String, dynamic>? _parseTypedDetailsJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  String? _typedPickStr(
    Map<String, dynamic>? t,
    String key,
    String? Function() fallback,
  ) {
    if (t != null && t.containsKey(key)) {
      final v = t[key];
      if (v == null) return fallback();
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
      return fallback();
    }
    return fallback();
  }

  int? _typedPickInt(
    Map<String, dynamic>? t,
    String key,
    int? Function() fallback,
  ) {
    if (t != null && t.containsKey(key)) {
      final v = t[key];
      if (v == null) return fallback();
      if (v is int) return v > 0 ? v : fallback();
      if (v is num) {
        final i = v.toInt();
        return i > 0 ? i : fallback();
      }
      final p = int.tryParse(v.toString().trim());
      if (p != null && p > 0) return p;
      return fallback();
    }
    return fallback();
  }

  String _normalizeUserRole(String? role) {
    final r = (role ?? '').trim().toLowerCase();
    if (r == 'admin') return 'admin';
    if (r == 'responsable') return 'responsable';
    return 'client';
  }

  /// UUID normalisé pour comparer structureId (évite échecs delete/archive si format diffère).
  String _uuidNorm(dynamic v) => (v?.toString() ?? '').trim().toLowerCase();

  bool _assignedHasStructure(List<String> assigned, dynamic structureId) {
    final key = _uuidNorm(structureId);
    if (key.isEmpty) return false;
    for (final a in assigned) {
      if (_uuidNorm(a) == key) return true;
    }
    return false;
  }

  /// UUID reçu du client (trim, sans accolades) pour les casts SQL `::uuid`.
  String? _normalizeClientEventId(String? raw) {
    if (raw == null) return null;
    var s = raw.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('{') && s.endsWith('}')) {
      s = s.substring(1, s.length - 1).trim();
    }
    if (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) {
      s = s.substring(1, s.length - 1).trim();
    }
    return s.isEmpty ? null : s;
  }

  Future<void> _syncEventTypedDetails(
    Session session, {
    required String eventId,
    required String eventType,
    String? category,
    String? description,
    String? typedDetailsJson,
    Transaction? transaction,
  }) async {
    final td = _parseTypedDetailsJson(typedDetailsJson);
    try {
      // Une seule commande par requête : le driver Postgres refuse plusieurs
      // instructions dans une même requête préparée (42601).
      const detailTables = <String>[
        'cine_pass_event_film_details',
        'cine_pass_event_festival_details',
        'cine_pass_event_standup_details',
        'cine_pass_event_concert_details',
        'cine_pass_event_theatre_details',
        'cine_pass_event_other_details',
      ];
      for (final table in detailTables) {
        await session.db.unsafeQuery(
          'DELETE FROM "$table" WHERE "event_id" = (@eid)::uuid',
          parameters: QueryParameters.named({'eid': eventId}),
          transaction: transaction,
        );
      }

      if (eventType == 'FILM') {
        await session.db.unsafeQuery(
          r'''
          INSERT INTO "cine_pass_event_film_details" (
            "event_id", "film_genre", "synopsis", "director", "duration_min", "film_format", "original_language", "age_rating"
          ) VALUES (
            (@eid)::uuid, COALESCE(NULLIF(TRIM(@filmGenre::text), ''), 'Général'), @synopsis::text, @director::text,
            @durationMin::integer,
            @filmFormat::text, @originalLanguage::text, @ageRating::text
          )
          ''',
          parameters: QueryParameters.named({
            'eid': eventId,
            'filmGenre': _typedPickStr(td, 'filmGenre', () {
              return _extractPrefixedValue(description, 'Genre') ?? category;
            }),
            'synopsis': _typedPickStr(td, 'synopsis', () {
              return _extractPrefixedValue(description, 'Synopsis');
            }),
            'director': _typedPickStr(td, 'director', () {
              return _extractPrefixedValue(description, 'Réalisateur');
            }),
            'durationMin': _typedPickInt(td, 'durationMin', () {
              return _parsePositiveInt(
                _extractPrefixedValue(
                  description,
                  'Durée',
                )?.replaceAll('min', '').trim(),
              );
            }),
            'filmFormat': _typedPickStr(td, 'filmFormat', () {
              return _extractPrefixedValue(description, 'Type de film');
            }),
            'originalLanguage': _typedPickStr(td, 'originalLanguage', () {
              return _extractPrefixedValue(description, 'Langue originale');
            }),
            'ageRating': _typedPickStr(td, 'ageRating', () {
              return _extractPrefixedValue(description, 'Classification') ??
                  _extractPrefixedValue(description, 'Âge recommandé');
            }),
          }),
          transaction: transaction,
        );
      } else if (eventType == 'FESTIVAL') {
        await session.db.unsafeQuery(
          r'''
          INSERT INTO "cine_pass_event_festival_details" (
            "event_id", "theme", "edition_label", "program_summary", "headliners", "pass_info"
          )
          VALUES ((@eid)::uuid, @theme::text, @edition::text, @program::text, @headliners::text, @passInfo::text)
          ''',
          parameters: QueryParameters.named({
            'eid': eventId,
            'theme': _typedPickStr(td, 'theme', () {
              return _extractPrefixedValue(description, 'Thématique');
            }),
            'edition': _typedPickStr(td, 'edition', () {
              return _extractPrefixedValue(description, 'Édition');
            }),
            'program': _typedPickStr(td, 'program', () {
              return _extractPrefixedValue(description, 'Programme');
            }),
            'headliners': _typedPickStr(td, 'headliners', () {
              return _extractPrefixedValue(description, "Têtes d'affiche") ??
                  _extractPrefixedValue(description, 'Headliners');
            }),
            'passInfo': _typedPickStr(td, 'passInfo', () {
              return _extractPrefixedValue(description, 'Infos pass') ??
                  _extractPrefixedValue(description, 'Pass');
            }),
          }),
          transaction: transaction,
        );
      } else if (eventType == 'STANDUP') {
        await session.db.unsafeQuery(
          r'''
          INSERT INTO "cine_pass_event_standup_details" ("event_id", "main_artist", "guests", "language", "show_format")
          VALUES ((@eid)::uuid, COALESCE(NULLIF(TRIM(@mainArtist::text), ''), 'Stand-up'), @guests::text, @language::text, @showFormat::text)
          ''',
          parameters: QueryParameters.named({
            'eid': eventId,
            'mainArtist': _typedPickStr(td, 'mainArtist', () {
              return _extractPrefixedValue(
                description,
                'Humoriste principal',
              );
            }),
            'guests': _typedPickStr(td, 'guests', () {
              return _extractPrefixedValue(description, 'Guests');
            }),
            'language': _typedPickStr(td, 'language', () {
              return _extractPrefixedValue(description, 'Langue');
            }),
            'showFormat': _typedPickStr(td, 'showFormat', () {
              return _extractPrefixedValue(description, 'Format du spectacle');
            }),
          }),
          transaction: transaction,
        );
      } else if (eventType == 'CONCERT') {
        await session.db.unsafeQuery(
          r'''
          INSERT INTO "cine_pass_event_concert_details" ("event_id", "artist", "music_genre", "opening_act", "lineup")
          VALUES ((@eid)::uuid, COALESCE(NULLIF(TRIM(@artist::text), ''), 'Concert'), @musicGenre::text, @openingAct::text, @lineup::text)
          ''',
          parameters: QueryParameters.named({
            'eid': eventId,
            'artist': _typedPickStr(td, 'artist', () {
              return _extractPrefixedValue(description, 'Artiste/Groupe');
            }),
            'musicGenre': _typedPickStr(td, 'musicGenre', () {
              return _extractPrefixedValue(description, 'Genre musical');
            }),
            'openingAct': _typedPickStr(td, 'openingAct', () {
              return _extractPrefixedValue(description, 'Première partie');
            }),
            'lineup': _typedPickStr(td, 'lineup', () {
              return _extractPrefixedValue(description, 'Line-up') ??
                  _extractPrefixedValue(description, 'Programmation');
            }),
          }),
          transaction: transaction,
        );
      } else if (eventType == 'THEATRE') {
        await session.db.unsafeQuery(
          r'''
          INSERT INTO "cine_pass_event_theatre_details" ("event_id", "author", "stage_director", "troupe", "play_style")
          VALUES ((@eid)::uuid, @author::text, @stageDirector::text, @troupe::text, @playStyle::text)
          ''',
          parameters: QueryParameters.named({
            'eid': eventId,
            'author': _typedPickStr(td, 'author', () {
              return _extractPrefixedValue(description, 'Auteur');
            }),
            'stageDirector': _typedPickStr(td, 'stageDirector', () {
              return _extractPrefixedValue(
                description,
                'Metteur en scène',
              );
            }),
            'troupe': _typedPickStr(td, 'troupe', () {
              return _extractPrefixedValue(description, 'Troupe');
            }),
            'playStyle': _typedPickStr(td, 'playStyle', () {
              return _extractPrefixedValue(description, 'Style de pièce');
            }),
          }),
          transaction: transaction,
        );
      } else {
        final otherPayload = <String, dynamic>{};
        if (td != null) {
          otherPayload.addAll(td);
        }
        if (!otherPayload.containsKey('eventLanguage') ||
            (otherPayload['eventLanguage']?.toString().trim().isEmpty ??
                true)) {
          final el = _extractPrefixedValue(description, 'Langue événement');
          if (el != null && el.isNotEmpty) {
            otherPayload['eventLanguage'] = el;
          }
        }
        final payloadJson = jsonEncode(
          otherPayload.isEmpty ? {'eventLanguage': ''} : otherPayload,
        );
        await session.db.unsafeQuery(
          r'''
          INSERT INTO "cine_pass_event_other_details" ("event_id", "custom_fields_json")
          VALUES ((@eid)::uuid, CAST(@payload::text AS jsonb))
          ''',
          parameters: QueryParameters.named({
            'eid': eventId,
            'payload': payloadJson,
          }),
          transaction: transaction,
        );
      }

      final evLang = _typedPickStr(td, 'eventLanguage', () {
        return _extractPrefixedValue(description, 'Langue événement');
      });
      await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_evenement"
        SET "event_language" = @eventLanguage::text
        WHERE "id" = (@eid)::uuid
        ''',
        parameters: QueryParameters.named({
          'eid': eventId,
          'eventLanguage': evLang,
        }),
        transaction: transaction,
      );
    } catch (e, st) {
      session.log(
        'CinePass syncEventTypedDetails',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      if (transaction != null) rethrow;
    }
  }

  /// Crée une réservation + billets après paiement (simulé).
  /// Retourne le numéro de réservation (ex: BOOK-...).
  Future<String?> createReservationAndBillets(
    Session session, {
    required bool isEvent,
    String? seanceId,
    String? eventId,
    String? reservationNumber,
    required List<String> seatLabels,
    required List<String> ticketTypes,
    required List<bool> optionParking,
    required List<bool> optionPopcorn,
    required List<bool> optionBoisson,
    required List<double> prices,
    required double totalAmount,
  }) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return null;
    if (isEvent) {
      if (eventId == null || eventId.isEmpty) return null;
    } else {
      if (seanceId == null || seanceId.isEmpty) return null;
    }
    if (prices.isEmpty) return null;
    if (ticketTypes.length != prices.length ||
        optionParking.length != prices.length ||
        optionPopcorn.length != prices.length ||
        optionBoisson.length != prices.length) {
      return null;
    }

    try {
      final numero =
          (reservationNumber != null && reservationNumber.trim().isNotEmpty)
          ? reservationNumber.trim()
          : 'BOOK-${DateTime.now().millisecondsSinceEpoch}';

      DateTime? sessionAt;
      String? salleId;
      if (isEvent) {
        final rows = await session.db.unsafeQuery(
          r'''
          SELECT "eventDate", "eventTime"
          FROM "cine_pass_evenement"
          WHERE "id" = (@id)::uuid
          ''',
          parameters: QueryParameters.named({'id': eventId}),
        );
        if (rows.isNotEmpty) {
          final d = _safeDateTime(rows.first[0]);
          final t = _safeDateTime(rows.first[1]);
          sessionAt = t ?? d;
        }
      } else {
        final rows = await session.db.unsafeQuery(
          r'''
          SELECT "debutAt", "salleId"
          FROM "cine_pass_seance"
          WHERE "id" = (@id)::uuid
          ''',
          parameters: QueryParameters.named({'id': seanceId}),
        );
        if (rows.isNotEmpty) {
          sessionAt = _safeDateTime(rows.first[0]);
          salleId = rows.first.length > 1 ? rows.first[1].toString() : null;
        }
      }

      final reservationInsert = await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_reservation" (
          "user_id", "seance_id", "evenement_id", "numero", "statut",
          "total_amount", "session_at"
        )
        VALUES (
          (@uid)::uuid,
          CASE WHEN @seanceId::text = '' OR @seanceId IS NULL THEN NULL ELSE (@seanceId)::uuid END,
          CASE WHEN @eventId::text = '' OR @eventId IS NULL THEN NULL ELSE (@eventId)::uuid END,
          @numero,
          'paid',
          @total,
          @sessionAt
        )
        RETURNING "id"
        ''',
        parameters: QueryParameters.named({
          'uid': userId,
          'seanceId': isEvent ? '' : (seanceId ?? ''),
          'eventId': isEvent ? (eventId ?? '') : '',
          'numero': numero,
          'total': totalAmount,
          'sessionAt': sessionAt,
        }),
      );
      if (reservationInsert.isEmpty) return null;
      final reservationId = reservationInsert.first[0].toString();

      for (var i = 0; i < prices.length; i++) {
        final seatLabel = (!isEvent && i < seatLabels.length)
            ? seatLabels[i]
            : null;
        String? siegeId;
        if (!isEvent &&
            seatLabel != null &&
            seatLabel.isNotEmpty &&
            salleId != null) {
          final parsed = _parseSeatLabel(seatLabel);
          if (parsed != null) {
            final seatRows = await session.db.unsafeQuery(
              r'''
              SELECT "id"
              FROM "cine_pass_siege"
              WHERE "salleId" = (@sid)::uuid AND "rangee" = @rangee AND "numero" = @numero
              LIMIT 1
              ''',
              parameters: QueryParameters.named({
                'sid': salleId,
                'rangee': parsed.$1,
                'numero': parsed.$2,
              }),
            );
            if (seatRows.isNotEmpty) {
              siegeId = seatRows.first[0].toString();
            }
          }
        }

        final tType = ticketTypes[i].trim().toLowerCase() == 'vip'
            ? 'vip'
            : 'normal';
        await session.db.unsafeQuery(
          r'''
          INSERT INTO "cine_pass_billet" (
            "reservation_id", "siege_id", "ticket_type",
            "option_parking", "option_popcorn", "option_boisson",
            "prix"
          )
          VALUES (
            (@rid)::uuid,
            CASE WHEN @siegeId::text = '' OR @siegeId IS NULL THEN NULL ELSE (@siegeId)::uuid END,
            @ticketType,
            @parking,
            @popcorn,
            @boisson,
            @prix
          )
          ''',
          parameters: QueryParameters.named({
            'rid': reservationId,
            'siegeId': siegeId ?? '',
            'ticketType': tType,
            'parking': optionParking[i],
            'popcorn': optionPopcorn[i],
            'boisson': optionBoisson[i],
            'prix': prices[i],
          }),
        );
      }

      return numero;
    } catch (e, st) {
      session.log(
        'CinePass createReservationAndBillets',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Mes billets (1 entrée par réservation, avec la liste des billets associés).
  Future<List<BilletGroupResponse>> getMyBillets(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return [];
    try {
      final rows = await session.db.unsafeQuery(
        r'''
        SELECT r."id", r."numero", r."total_amount",
               r."seance_id", r."evenement_id",
               r."session_at", r."created_at", r."statut",
               f."titre" as film_title,
               c."nom" as cinema_nom,
               c."ville" as cinema_ville,
               sal."nom" as salle_nom,
               s."debutAt" as seance_debutAt,
               e."titre" as event_title,
               e."lieu" as event_lieu,
               e."ville" as event_ville,
               e."eventDate" as event_date,
               e."eventTime" as event_time
        FROM "cine_pass_reservation" r
        LEFT JOIN "cine_pass_seance" s ON s."id" = r."seance_id"
        LEFT JOIN "cine_pass_film" f ON f."id" = s."filmId"
        LEFT JOIN "cine_pass_salle" sal ON sal."id" = s."salleId"
        LEFT JOIN "cine_pass_cinema" c ON c."id" = sal."cinemaId"
        LEFT JOIN "cine_pass_evenement" e ON e."id" = r."evenement_id"
        WHERE r."user_id" = (@uid)::uuid
        ORDER BY r."created_at" DESC
        ''',
        parameters: QueryParameters.named({'uid': userId}),
      );

      final result = <BilletGroupResponse>[];
      for (final row in rows) {
        final reservationId = row[0].toString();
        final numero = row[1]?.toString() ?? '';
        final total = row[2] is num
            ? (row[2] as num).toDouble()
            : _safeDouble(row[2]);
        final isEvent = row[4] != null;
        final status = (row[7] as String?) ?? 'paid';

        DateTime sessionDt =
            _safeDateTime(row[5]) ?? _safeDateTime(row[12]) ?? DateTime.now();
        if (isEvent) {
          sessionDt =
              _safeDateTime(row[5]) ??
              _safeDateTime(row[16]) ??
              _safeDateTime(row[17]) ??
              sessionDt;
        }

        final title = isEvent
            ? (row[13] as String?) ?? ''
            : (row[8] as String?) ?? '';
        final location = isEvent
            ? '${(row[14] as String?) ?? ''} - ${(row[15] as String?) ?? ''}'
            : '${(row[9] as String?) ?? ''} - ${(row[10] as String?) ?? ''}';
        final room = isEvent ? null : (row[11] as String?);
        final dateTimeLabel = _formatDateTimeLabel(sessionDt);

        final billetRows = await session.db.unsafeQuery(
          r'''
          SELECT b."ticket_type", sg."rangee", sg."numero", b."placement_label"
          FROM "cine_pass_billet" b
          LEFT JOIN "cine_pass_siege" sg ON sg."id" = b."siege_id"
          WHERE b."reservation_id" = (@rid)::uuid
          ORDER BY b."created_at" ASC
          ''',
          parameters: QueryParameters.named({'rid': reservationId}),
        );

        final seats = <String>[];
        final types = <String>[];
        for (final b in billetRows) {
          final t = (b.isNotEmpty ? b[0]?.toString() : null) ?? 'normal';
          types.add(t.toLowerCase() == 'vip' ? 'VIP' : 'Normal');
          final pl = b.length > 3 ? (b[3]?.toString() ?? '').trim() : '';
          if (pl.isNotEmpty) {
            seats.add(pl);
            continue;
          }
          final rangee = b.length > 1 ? b[1]?.toString() : null;
          final num = b.length > 2 ? b[2] : null;
          if (rangee != null && rangee.isNotEmpty && num != null) {
            seats.add('$rangee${_safeInt(num)}');
          }
        }

        result.add(
          BilletGroupResponse(
            id: numero.isNotEmpty ? numero : reservationId,
            title: title,
            location: location.trim().isEmpty ? '—' : location,
            dateTime: dateTimeLabel,
            totalAmount: total,
            seats: seats.isEmpty ? null : seats,
            ticketCount: isEvent ? billetRows.length : null,
            isEvent: isEvent,
            room: room,
            ticketTypes: types.isEmpty ? null : types,
            sessionDateTime: sessionDt,
            status: status,
          ),
        );
      }

      return result;
    } catch (e, st) {
      session.log(
        'CinePass getMyBillets',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
    }
  }

  // Helpers pour gestion des rôles
  bool _adminTableEnsured = false;
  bool _responsableTableEnsured = false;

  Future<void> _ensureAdminRoleTable(Session session) async {
    if (_adminTableEnsured) return;
    await session.db.unsafeQuery(
      r'''
      CREATE TABLE IF NOT EXISTS "cine_pass_admin_user" (
        "id" bigserial PRIMARY KEY,
        "user_id" uuid NOT NULL UNIQUE,
        "created_at" timestamp without time zone NOT NULL DEFAULT now()
      )
      ''',
    );
    _adminTableEnsured = true;
  }

  Future<void> _ensureResponsableRoleTable(Session session) async {
    if (_responsableTableEnsured) return;
    await session.db.unsafeQuery(
      r'''
      CREATE TABLE IF NOT EXISTS "cine_pass_responsable_user" (
        "id" bigserial PRIMARY KEY,
        "user_id" uuid NOT NULL UNIQUE,
        "active" boolean NOT NULL DEFAULT true,
        "created_at" timestamp without time zone NOT NULL DEFAULT now(),
        "updated_at" timestamp without time zone NOT NULL DEFAULT now()
      )
      ''',
    );
    _responsableTableEnsured = true;
  }

  Future<bool> _isAdmin(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return false;

    await _ensureAdminRoleTable(session);
    final rows = await session.db.unsafeQuery(
      r'''
      SELECT 1
      FROM "cine_pass_admin_user"
      WHERE "user_id" = (@uid)::uuid
      LIMIT 1
      ''',
      parameters: QueryParameters.named({'uid': userId}),
    );
    return rows.isNotEmpty;
  }

  Future<bool> _isResponsable(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return false;

    await _ensureResponsableRoleTable(session);
    final rows = await session.db.unsafeQuery(
      r'''
      SELECT 1
      FROM "cine_pass_responsable_user"
      WHERE "user_id" = (@uid)::uuid AND "active" = true
      LIMIT 1
      ''',
      parameters: QueryParameters.named({'uid': userId}),
    );
    return rows.isNotEmpty;
  }

  Future<List<String>> _responsableStructureIds(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return [];
    try {
      final rows = await session.db.unsafeQuery(
        r'''
        SELECT "structure_id"
        FROM "cine_pass_responsable_assignment"
        WHERE "user_id" = (@uid)::uuid AND "active" = true
        ''',
        parameters: QueryParameters.named({'uid': userId}),
      );
      return rows
          .map((r) => _uuidNorm(r[0]))
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Lit le structureId d’un événement, normalisé (évite refus archive/update/delete si format UUID diffère).
  String? _eventStructureIdFromRow(List<dynamic> targetRows) {
    if (targetRows.isEmpty) return null;
    final raw = targetRows.first[0];
    if (raw == null) return null;
    final s = _uuidNorm(raw);
    return s.isEmpty ? null : s;
  }

  /// Frontend: indique si l'utilisateur connecté est admin plateforme.
  Future<bool> isCurrentUserAdmin(Session session) async {
    return _isAdmin(session);
  }

  /// Frontend: indique si l'utilisateur connecté est responsable d'au moins une structure.
  Future<bool> isCurrentUserResponsable(Session session) async {
    return _isResponsable(session);
  }

  /// Admin: active/desactive le role responsable pour un utilisateur via son email.
  Future<bool> setResponsableActiveByEmail(
    Session session, {
    required String email,
    required bool active,
  }) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('setResponsableActiveByEmail refuse: admin requis');
        return false;
      }

      final normalizedEmail = email.trim().toLowerCase();
      if (normalizedEmail.isEmpty) return false;

      final userRows = await session.db.unsafeQuery(
        r'''
        SELECT "authUserId"
        FROM "serverpod_auth_core_profile"
        WHERE lower("email") = @email
        LIMIT 1
        ''',
        parameters: QueryParameters.named({'email': normalizedEmail}),
      );
      if (userRows.isEmpty) return false;
      final userId = userRows.first[0].toString();

      await _ensureResponsableRoleTable(session);
      await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_responsable_user" ("user_id", "active", "updated_at")
        VALUES ((@uid)::uuid, @active, now())
        ON CONFLICT ("user_id") DO UPDATE SET
          "active" = EXCLUDED."active",
          "updated_at" = now()
        ''',
        parameters: QueryParameters.named({'uid': userId, 'active': active}),
      );

      // Keep assignment table aligned when role is deactivated.
      if (!active) {
        await session.db.unsafeQuery(
          r'''
          UPDATE "cine_pass_responsable_assignment"
          SET "active" = false
          WHERE "user_id" = (@uid)::uuid
          ''',
          parameters: QueryParameters.named({'uid': userId}),
        );
      }

      return true;
    } catch (e, st) {
      session.log(
        'CinePass setResponsableActiveByEmail',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Liste de tous les films.
  Future<List<FilmResponse>> getFilms(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'''
        SELECT "id", "titre", "genre", "dureeMinutes", "synopsis", "directeur",
               "casting", "posterColor", "posterUrl", "dateSortie", "dateFin", "audience"
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
               "casting", "posterColor", "posterUrl", "dateSortie", "dateFin", "audience"
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
      session.log(
        'CinePass getSalles',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Liste des événements à venir.
  Future<List<EventResponse>> getEvents(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'''
      SELECT e."id", e."titre", e."categorie", e."description", e."lieu", e."adresse", e."ville",
             e."eventDate", e."eventTime", e."placesTotal", e."prixBase", e."posterColor", e."posterUrl", e."availableOptions",
             e."event_type", e."event_subtype", e."custom_type_label", e."event_language",
             f."film_genre", f."director", fe."theme", s."main_artist", c."artist", c."music_genre", t."author",
             COALESCE((
               SELECT MIN(tt."price") FROM "cine_pass_event_ticket_type" tt
               WHERE tt."event_id" = e."id" AND tt."active" = true
             ), e."prixBase") AS min_ticket_price,
             COALESCE((
               SELECT MAX(tt."price") FROM "cine_pass_event_ticket_type" tt
               WHERE tt."event_id" = e."id" AND tt."active" = true
             ), e."prixBase") AS max_ticket_price,
             (SELECT cfg."reservation_mode" FROM "cine_pass_event_reservation_config" cfg
              WHERE cfg."event_id" = e."id" LIMIT 1) AS reservation_mode,
             (SELECT st."name" FROM "cine_pass_structure" st WHERE st."id" = e."structureId" LIMIT 1) AS structure_name,
             (SELECT COUNT(*)::bigint FROM "cine_pass_billet" b
              INNER JOIN "cine_pass_reservation" r ON r."id" = b."reservation_id"
              WHERE r."evenement_id" = e."id"
                AND LOWER(TRIM(COALESCE(r."statut", ''))) = 'paid') AS tickets_sold,
             COALESCE(e."archived", false) AS ev_archived
      FROM "cine_pass_evenement" e
      LEFT JOIN "cine_pass_event_film_details" f ON f."event_id" = e."id"
      LEFT JOIN "cine_pass_event_festival_details" fe ON fe."event_id" = e."id"
      LEFT JOIN "cine_pass_event_standup_details" s ON s."event_id" = e."id"
      LEFT JOIN "cine_pass_event_concert_details" c ON c."event_id" = e."id"
      LEFT JOIN "cine_pass_event_theatre_details" t ON t."event_id" = e."id"
      WHERE e."eventDate" >= CURRENT_DATE
        AND COALESCE(e."archived", false) = false
      ORDER BY e."eventDate", e."eventTime"
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
      final idNorm = _normalizeClientEventId(id);
      if (idNorm == null) return null;
      final result = await session.db.unsafeQuery(
        r"""
      SELECT e."id", e."titre", e."categorie", e."description", e."lieu", e."adresse", e."ville",
             e."eventDate", e."eventTime", e."placesTotal", e."prixBase", e."posterColor", e."posterUrl", e."availableOptions",
             e."event_type", e."event_subtype", e."custom_type_label", e."event_language",
             f."film_genre", f."director", fe."theme", s."main_artist", c."artist", c."music_genre", t."author",
             COALESCE((
               SELECT MIN(tt."price") FROM "cine_pass_event_ticket_type" tt
               WHERE tt."event_id" = e."id" AND tt."active" = true
             ), e."prixBase") AS min_ticket_price,
             COALESCE((
               SELECT MAX(tt."price") FROM "cine_pass_event_ticket_type" tt
               WHERE tt."event_id" = e."id" AND tt."active" = true
             ), e."prixBase") AS max_ticket_price,
             (SELECT cfg."reservation_mode" FROM "cine_pass_event_reservation_config" cfg
              WHERE cfg."event_id" = e."id" LIMIT 1) AS reservation_mode,
             (SELECT st."name" FROM "cine_pass_structure" st WHERE st."id" = e."structureId" LIMIT 1) AS structure_name,
             (SELECT COUNT(*)::bigint FROM "cine_pass_billet" b
              INNER JOIN "cine_pass_reservation" r ON r."id" = b."reservation_id"
              WHERE r."evenement_id" = e."id"
                AND LOWER(TRIM(COALESCE(r."statut", ''))) = 'paid') AS tickets_sold,
             COALESCE(e."archived", false) AS ev_archived
      FROM "cine_pass_evenement" e
      LEFT JOIN "cine_pass_event_film_details" f ON f."event_id" = e."id"
      LEFT JOIN "cine_pass_event_festival_details" fe ON fe."event_id" = e."id"
      LEFT JOIN "cine_pass_event_standup_details" s ON s."event_id" = e."id"
      LEFT JOIN "cine_pass_event_concert_details" c ON c."event_id" = e."id"
      LEFT JOIN "cine_pass_event_theatre_details" t ON t."event_id" = e."id"
      WHERE e."id" = (@id)::uuid
      """,
        parameters: QueryParameters.named({'id': idNorm}),
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

  /// Configuration réservation d'un événement (publique côté lecture).
  Future<EventReservationConfigResponse?> getEventReservationConfig(
    Session session,
    String eventId,
  ) async {
    try {
      final eid = _normalizeClientEventId(eventId);
      if (eid == null) return null;
      final eventRows = await session.db.unsafeQuery(
        r'''
        SELECT "id", "prixBase", "placesTotal"
        FROM "cine_pass_evenement"
        WHERE "id" = (@eventId)::uuid
        LIMIT 1
        ''',
        parameters: QueryParameters.named({'eventId': eid}),
      );
      if (eventRows.isEmpty) return null;

      final eventPrixBase = _safeDouble(eventRows.first[1]);
      final eventPlacesTotal = _safeInt(eventRows.first[2]);

      final configRows = await session.db.unsafeQuery(
        r'''
        SELECT "reservation_mode", "max_tickets_per_order", "adjacent_best_effort"
        FROM "cine_pass_event_reservation_config"
        WHERE "event_id" = (@eventId)::uuid
        LIMIT 1
        ''',
        parameters: QueryParameters.named({'eventId': eid}),
      );

      final soldRows = await session.db.unsafeQuery(
        r'''
        SELECT COALESCE(b."ticket_type", 'standard') AS ticket_type, COUNT(*)::int AS sold_count
        FROM "cine_pass_billet" b
        JOIN "cine_pass_reservation" r ON r."id" = b."reservation_id"
        WHERE r."evenement_id" = (@eventId)::uuid
          AND lower(COALESCE(r."statut", '')) = 'paid'
        GROUP BY COALESCE(b."ticket_type", 'standard')
        ''',
        parameters: QueryParameters.named({'eventId': eid}),
      );
      final soldByType = <String, int>{};
      for (final row in soldRows) {
        soldByType[(row[0]?.toString() ?? 'standard').toLowerCase()] = _safeInt(
          row[1],
        );
      }

      final typeRows = await session.db.unsafeQuery(
        r'''
        SELECT "code", "label", "price", "quota", "active", "sort_order"
        FROM "cine_pass_event_ticket_type"
        WHERE "event_id" = (@eventId)::uuid
        ORDER BY "sort_order" ASC, "code" ASC
        ''',
        parameters: QueryParameters.named({'eventId': eventId}),
      );

      final optionRows = await session.db.unsafeQuery(
        r'''
        SELECT "ticket_type_code", "option_code", "label", "price", "included", "active", "sort_order"
        FROM "cine_pass_event_ticket_option"
        WHERE "event_id" = (@eventId)::uuid
        ORDER BY "sort_order" ASC, "option_code" ASC
        ''',
        parameters: QueryParameters.named({'eventId': eventId}),
      );

      final optionsByType = <String, List<EventTicketOptionResponse>>{};
      for (final row in optionRows) {
        final code = (row[0]?.toString() ?? '').toLowerCase();
        if (code.isEmpty) continue;
        final list = optionsByType.putIfAbsent(code, () => []);
        list.add(
          EventTicketOptionResponse(
            optionCode: row[1]?.toString() ?? '',
            label: row[2]?.toString() ?? '',
            price: _safeDouble(row[3]),
            included: row[4] == true,
            active: row[5] == true,
            sortOrder: _safeInt(row[6]),
          ),
        );
      }

      final ticketTypes = <EventTicketTypeConfigResponse>[];
      for (final row in typeRows) {
        final code = (row[0]?.toString() ?? '').trim();
        if (code.isEmpty) continue;
        final codeLower = code.toLowerCase();
        final quota = _safeInt(row[3]);
        final sold = soldByType[codeLower] ?? 0;
        ticketTypes.add(
          EventTicketTypeConfigResponse(
            code: code,
            label: row[1]?.toString() ?? code,
            price: _safeDouble(row[2]),
            quota: quota,
            soldCount: sold,
            remaining: (quota - sold).clamp(0, 1 << 30),
            active: row[4] == true,
            sortOrder: _safeInt(row[5]),
            options: optionsByType[codeLower] ?? const [],
          ),
        );
      }

      final hasDbConfig = configRows.isNotEmpty;
      if (!hasDbConfig && ticketTypes.isEmpty) {
        final sold = soldByType['standard'] ?? 0;
        ticketTypes.add(
          EventTicketTypeConfigResponse(
            code: 'STANDARD',
            label: 'Standard',
            price: eventPrixBase,
            quota: eventPlacesTotal,
            soldCount: sold,
            remaining: (eventPlacesTotal - sold).clamp(0, 1 << 30),
            active: true,
            sortOrder: 0,
            options: const [],
          ),
        );
      }

      return EventReservationConfigResponse(
        eventId: eid,
        reservationMode: hasDbConfig
            ? (configRows.first[0]?.toString() ?? 'SANS_SIEGES')
            : 'SANS_SIEGES',
        maxTicketsPerOrder: hasDbConfig ? _safeInt(configRows.first[1]) : 8,
        adjacentBestEffort: hasDbConfig ? (configRows.first[2] == true) : true,
        ticketTypes: ticketTypes,
      );
    } catch (e, st) {
      session.log(
        'CinePass getEventReservationConfig',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Admin / Responsable: configure mode de réservation + types + options.
  Future<bool> setEventReservationConfig(
    Session session, {
    required String eventId,
    required String reservationMode,
    int maxTicketsPerOrder = 8,
    bool adjacentBestEffort = true,
    required List<String> ticketTypeCodes,
    required List<String> ticketTypeLabels,
    required List<double> ticketTypePrices,
    required List<int> ticketTypeQuotas,
    required List<String> optionTicketTypeCodes,
    required List<String> optionCodes,
    required List<String> optionLabels,
    required List<double> optionPrices,
    required List<bool> optionIncluded,
  }) async {
    try {
      final normalizedMode = reservationMode.trim().toUpperCase();
      if (normalizedMode != 'SANS_SIEGES' && normalizedMode != 'AVEC_SIEGES') {
        return false;
      }
      if (ticketTypeCodes.isEmpty ||
          ticketTypeCodes.length != ticketTypeLabels.length ||
          ticketTypeCodes.length != ticketTypePrices.length ||
          ticketTypeCodes.length != ticketTypeQuotas.length) {
        return false;
      }
      if (optionTicketTypeCodes.length != optionCodes.length ||
          optionCodes.length != optionLabels.length ||
          optionLabels.length != optionPrices.length ||
          optionPrices.length != optionIncluded.length) {
        return false;
      }

      final eidCfg = _normalizeClientEventId(eventId);
      if (eidCfg == null) return false;

      final eventRows = await session.db.unsafeQuery(
        r'''SELECT "structureId" FROM "cine_pass_evenement" WHERE "id" = (@eventId)::uuid LIMIT 1''',
        parameters: QueryParameters.named({'eventId': eidCfg}),
      );
      if (eventRows.isEmpty) return false;

      final isAdmin = await _isAdmin(session);
      if (!isAdmin) {
        final assigned = await _responsableStructureIds(session);
        if (assigned.isEmpty) return false;
        final targetStructureId = _eventStructureIdFromRow(eventRows);
        if (targetStructureId == null ||
            !_assignedHasStructure(assigned, targetStructureId)) {
          session.log(
            'setEventReservationConfig refuse: structure hors perimetre responsable',
          );
          return false;
        }
      }

      final maxPerOrder = maxTicketsPerOrder <= 0 ? 8 : maxTicketsPerOrder;
      await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_event_reservation_config" (
          "event_id", "reservation_mode", "max_tickets_per_order", "adjacent_best_effort", "updated_at"
        )
        VALUES (
          (@eventId)::uuid, @reservationMode, @maxTicketsPerOrder, @adjacentBestEffort, now()
        )
        ON CONFLICT ("event_id") DO UPDATE SET
          "reservation_mode" = EXCLUDED."reservation_mode",
          "max_tickets_per_order" = EXCLUDED."max_tickets_per_order",
          "adjacent_best_effort" = EXCLUDED."adjacent_best_effort",
          "updated_at" = now()
        ''',
        parameters: QueryParameters.named({
          'eventId': eidCfg,
          'reservationMode': normalizedMode,
          'maxTicketsPerOrder': maxPerOrder,
          'adjacentBestEffort': adjacentBestEffort,
        }),
      );

      await session.db.unsafeQuery(
        r'''DELETE FROM "cine_pass_event_ticket_option" WHERE "event_id" = (@eventId)::uuid''',
        parameters: QueryParameters.named({'eventId': eidCfg}),
      );
      await session.db.unsafeQuery(
        r'''DELETE FROM "cine_pass_event_ticket_type" WHERE "event_id" = (@eventId)::uuid''',
        parameters: QueryParameters.named({'eventId': eidCfg}),
      );

      var totalQuota = 0;
      final typeCodeSet = <String>{};
      for (var i = 0; i < ticketTypeCodes.length; i++) {
        final code = ticketTypeCodes[i].trim().toUpperCase();
        final label = ticketTypeLabels[i].trim();
        final price = ticketTypePrices[i];
        final quota = ticketTypeQuotas[i];
        if (code.isEmpty || label.isEmpty || price < 0 || quota < 0) {
          return false;
        }
        if (typeCodeSet.contains(code)) return false;
        typeCodeSet.add(code);
        totalQuota += quota;

        await session.db.unsafeQuery(
          r'''
          INSERT INTO "cine_pass_event_ticket_type" (
            "event_id", "code", "label", "price", "quota", "active", "sort_order", "updated_at"
          )
          VALUES (
            (@eventId)::uuid, @code, @label, @price, @quota, true, @sortOrder, now()
          )
          ''',
          parameters: QueryParameters.named({
            'eventId': eventId,
            'code': code,
            'label': label,
            'price': price,
            'quota': quota,
            'sortOrder': i,
          }),
        );
      }

      for (var i = 0; i < optionCodes.length; i++) {
        final ticketCode = optionTicketTypeCodes[i].trim().toUpperCase();
        final optionCode = optionCodes[i].trim().toUpperCase();
        final optionLabel = optionLabels[i].trim();
        final optionPrice = optionPrices[i];
        final included = optionIncluded[i];
        if (ticketCode.isEmpty ||
            optionCode.isEmpty ||
            optionLabel.isEmpty ||
            optionPrice < 0) {
          return false;
        }
        if (!typeCodeSet.contains(ticketCode)) return false;

        await session.db.unsafeQuery(
          r'''
          INSERT INTO "cine_pass_event_ticket_option" (
            "event_id", "ticket_type_code", "option_code", "label", "price", "included",
            "active", "sort_order", "updated_at"
          )
          VALUES (
            (@eventId)::uuid, @ticketTypeCode, @optionCode, @label, @price, @included,
            true, @sortOrder, now()
          )
          ''',
          parameters: QueryParameters.named({
            'eventId': eidCfg,
            'ticketTypeCode': ticketCode,
            'optionCode': optionCode,
            'label': optionLabel,
            'price': optionPrice,
            'included': included,
            'sortOrder': i,
          }),
        );
      }

      if (totalQuota > 0) {
        await session.db.unsafeQuery(
          r'''
          UPDATE "cine_pass_evenement"
          SET "placesTotal" = @placesTotal
          WHERE "id" = (@eventId)::uuid
          ''',
          parameters: QueryParameters.named({
            'placesTotal': totalQuota,
            'eventId': eidCfg,
          }),
        );
      }

      return true;
    } catch (e, st) {
      session.log(
        'CinePass setEventReservationConfig',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Plan de sièges défini par le responsable (lecture publique).
  Future<EventSeatPlanResponse?> getEventSeatPlan(
    Session session,
    String eventId,
  ) async {
    try {
      final evRows = await session.db.unsafeQuery(
        r'''SELECT 1 FROM "cine_pass_evenement" WHERE "id" = (@eventId)::uuid LIMIT 1''',
        parameters: QueryParameters.named({'eventId': eventId}),
      );
      if (evRows.isEmpty) return null;

      final configRows = await session.db.unsafeQuery(
        r'''SELECT "reservation_mode" FROM "cine_pass_event_reservation_config" WHERE "event_id" = (@eventId)::uuid LIMIT 1''',
        parameters: QueryParameters.named({'eventId': eventId}),
      );
      final mode = configRows.isNotEmpty
          ? (configRows.first[0]?.toString() ?? 'SANS_SIEGES')
          : 'SANS_SIEGES';

      final seatRows = await session.db.unsafeQuery(
        r'''
        SELECT s."label", s."row_index", s."col_index", s."blocked", s."zone",
          EXISTS (
            SELECT 1 FROM "cine_pass_billet" b
            INNER JOIN "cine_pass_reservation" r ON r."id" = b."reservation_id"
            WHERE r."evenement_id" = s."event_id"
              AND lower(COALESCE(r."statut", '')) = 'paid'
              AND lower(trim(COALESCE(b."placement_label", ''))) = lower(trim(s."label"))
          ) AS taken
        FROM "cine_pass_event_seat" s
        WHERE s."event_id" = (@eventId)::uuid
        ORDER BY s."row_index" ASC, s."col_index" ASC
        ''',
        parameters: QueryParameters.named({'eventId': eventId}),
      );

      final seats = <EventSeatPlanEntryResponse>[];
      for (final row in seatRows) {
        seats.add(
          EventSeatPlanEntryResponse(
            label: row[0]?.toString() ?? '',
            rowIndex: _safeInt(row[1]),
            colIndex: _safeInt(row[2]),
            blocked: row[3] == true,
            taken: row.length > 5 ? (row[5] == true) : false,
            zone: row[4]?.toString() ?? '',
          ),
        );
      }

      return EventSeatPlanResponse(
        eventId: eventId,
        reservationMode: mode,
        seats: seats,
      );
    } catch (e, st) {
      session.log(
        'CinePass getEventSeatPlan',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Admin / Responsable : remplace tout le plan de sièges de l’événement.
  Future<bool> setEventSeatPlan(
    Session session, {
    required String eventId,
    required List<String> seatLabels,
    required List<int> seatRowIndices,
    required List<int> seatColIndices,
    required List<bool> seatBlocked,
    required List<String> seatZones,
  }) async {
    try {
      final eidPlan = _normalizeClientEventId(eventId);
      if (eidPlan == null) return false;
      final n = seatLabels.length;
      if (n != seatRowIndices.length ||
          n != seatColIndices.length ||
          n != seatBlocked.length ||
          n != seatZones.length) {
        return false;
      }

      final eventRows = await session.db.unsafeQuery(
        r'''SELECT "structureId" FROM "cine_pass_evenement" WHERE "id" = (@eventId)::uuid LIMIT 1''',
        parameters: QueryParameters.named({'eventId': eidPlan}),
      );
      if (eventRows.isEmpty) return false;

      final isAdmin = await _isAdmin(session);
      if (!isAdmin) {
        final assigned = await _responsableStructureIds(session);
        if (assigned.isEmpty) return false;
        final targetStructureId = _eventStructureIdFromRow(eventRows);
        if (targetStructureId == null ||
            !_assignedHasStructure(assigned, targetStructureId)) {
          return false;
        }
      }

      final seenLower = <String>{};
      for (var i = 0; i < n; i++) {
        final lab = seatLabels[i].trim();
        if (lab.isEmpty) return false;
        final k = lab.toLowerCase();
        if (seenLower.contains(k)) return false;
        seenLower.add(k);
      }

      await session.db.transaction((transaction) async {
        await session.db.unsafeQuery(
          r'''DELETE FROM "cine_pass_event_seat" WHERE "event_id" = (@eventId)::uuid''',
          parameters: QueryParameters.named({'eventId': eidPlan}),
          transaction: transaction,
        );
        for (var i = 0; i < n; i++) {
          final lab = seatLabels[i].trim();
          final z = seatZones[i].trim();
          await session.db.unsafeQuery(
            r'''
            INSERT INTO "cine_pass_event_seat" (
              "event_id", "label", "row_index", "col_index", "blocked", "zone"
            )
            VALUES (
              (@eventId)::uuid, @label, @rowIndex, @colIndex, @blocked, @zone
            )
            ''',
            parameters: QueryParameters.named({
              'eventId': eidPlan,
              'label': lab,
              'rowIndex': seatRowIndices[i],
              'colIndex': seatColIndices[i],
              'blocked': seatBlocked[i],
              'zone': z,
            }),
            transaction: transaction,
          );
        }
      });

      return true;
    } catch (e, st) {
      session.log(
        'CinePass setEventSeatPlan',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  static bool _seatZoneAllowsTicket(String zone, String ticketTypeCode) {
    final z = zone.trim().toUpperCase();
    if (z.isEmpty) return true;
    return z == ticketTypeCode.trim().toUpperCase();
  }

  /// Prévisualisation de réservation (sans écriture DB).
  Future<ReservationQuoteResponse?> quoteEventReservation(
    Session session, {
    required String eventId,
    required List<String> ticketTypeCodes,
    required List<int> quantities,
  }) async {
    try {
      if (ticketTypeCodes.isEmpty ||
          ticketTypeCodes.length != quantities.length) {
        return null;
      }
      final cfg = await getEventReservationConfig(session, eventId);
      if (cfg == null) return null;

      var requestedCount = 0;
      for (final q in quantities) {
        if (q <= 0) return null;
        requestedCount += q;
      }
      if (requestedCount > cfg.maxTicketsPerOrder) {
        return ReservationQuoteResponse(
          eventId: eventId,
          reservationMode: cfg.reservationMode,
          available: false,
          message: 'Maximum ${cfg.maxTicketsPerOrder} billet(s) par commande.',
          totalAmount: 0,
          ticketCount: requestedCount,
          lines: const [],
        );
      }

      final typeByCode = <String, EventTicketTypeConfigResponse>{
        for (final t in cfg.ticketTypes) t.code.toLowerCase(): t,
      };

      final lines = <ReservationQuoteLineResponse>[];
      var total = 0.0;
      for (var i = 0; i < ticketTypeCodes.length; i++) {
        final reqCode = ticketTypeCodes[i].trim().toLowerCase();
        final qty = quantities[i];
        final type = typeByCode[reqCode];
        if (type == null || !type.active) {
          return ReservationQuoteResponse(
            eventId: eventId,
            reservationMode: cfg.reservationMode,
            available: false,
            message: 'Type de billet introuvable: ${ticketTypeCodes[i]}',
            totalAmount: 0,
            ticketCount: requestedCount,
            lines: const [],
          );
        }
        if (qty > type.remaining) {
          return ReservationQuoteResponse(
            eventId: eventId,
            reservationMode: cfg.reservationMode,
            available: false,
            message:
                'Plus assez de places pour ${type.label} (reste ${type.remaining}).',
            totalAmount: 0,
            ticketCount: requestedCount,
            lines: const [],
          );
        }
        final lineTotal = type.price * qty;
        total += lineTotal;
        lines.add(
          ReservationQuoteLineResponse(
            ticketTypeCode: type.code,
            ticketTypeLabel: type.label,
            quantity: qty,
            unitPrice: type.price,
            lineTotal: lineTotal,
            remainingAfterQuote: type.remaining - qty,
          ),
        );
      }

      return ReservationQuoteResponse(
        eventId: eventId,
        reservationMode: cfg.reservationMode,
        available: true,
        message: 'Prévisualisation OK',
        totalAmount: total,
        ticketCount: requestedCount,
        lines: lines,
      );
    } catch (e, st) {
      session.log(
        'CinePass quoteEventReservation',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Confirme une réservation événement en mode transactionnel.
  /// [perBilletTypeCodes] : un type par billet (ex. STANDARD, VIP).
  /// [perBilletPayantOptionCsv] : pour chaque billet, codes d'options payantes séparés par des virgules (ex. "PARKING,SNACK").
  /// [perBilletSeatLabels] : si l’événement est en AVEC_SIEGES, un libellé par billet (ex. A3), ordre aligné sur [perBilletTypeCodes].
  Future<ReservationConfirmResponse> confirmEventReservation(
    Session session, {
    required String eventId,
    required List<String> perBilletTypeCodes,
    List<String> perBilletPayantOptionCsv = const [],
    List<String> perBilletSeatLabels = const [],
  }) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) {
      return ReservationConfirmResponse(
        success: false,
        message: 'Authentification requise.',
        reservationNumber: null,
        totalAmount: 0,
        placementLabel: null,
      );
    }
    if (perBilletTypeCodes.isEmpty) {
      return ReservationConfirmResponse(
        success: false,
        message: 'Paramètres de réservation invalides.',
        reservationNumber: null,
        totalAmount: 0,
        placementLabel: null,
      );
    }

    try {
      return await session.db.transaction((transaction) async {
        final eventRows = await session.db.unsafeQuery(
          r'''
          SELECT "eventDate", "eventTime"
          FROM "cine_pass_evenement"
          WHERE "id" = (@eventId)::uuid
          LIMIT 1
          FOR UPDATE
          ''',
          parameters: QueryParameters.named({'eventId': eventId}),
          transaction: transaction,
        );
        if (eventRows.isEmpty) {
          return ReservationConfirmResponse(
            success: false,
            message: 'Événement introuvable.',
            reservationNumber: null,
            totalAmount: 0,
            placementLabel: null,
          );
        }

        final configRows = await session.db.unsafeQuery(
          r'''
          SELECT "reservation_mode", "max_tickets_per_order", "adjacent_best_effort"
          FROM "cine_pass_event_reservation_config"
          WHERE "event_id" = (@eventId)::uuid
          LIMIT 1
          FOR UPDATE
          ''',
          parameters: QueryParameters.named({'eventId': eventId}),
          transaction: transaction,
        );
        final reservationMode = configRows.isNotEmpty
            ? (configRows.first[0]?.toString() ?? 'SANS_SIEGES')
            : 'SANS_SIEGES';
        final maxPerOrder = configRows.isNotEmpty
            ? _safeInt(configRows.first[1])
            : 8;
        final adjacentBestEffort = configRows.isNotEmpty
            ? (configRows.first[2] == true)
            : true;

        var placementPerBillet = List<String?>.filled(
          perBilletTypeCodes.length,
          null,
        );

        final hasAnySeatLabel = perBilletSeatLabels.any(
          (s) => s.trim().isNotEmpty,
        );
        if (reservationMode != 'AVEC_SIEGES' && hasAnySeatLabel) {
          return ReservationConfirmResponse(
            success: false,
            message: 'Cet événement ne nécessite pas de sièges.',
            reservationNumber: null,
            totalAmount: 0,
            placementLabel: null,
          );
        }
        if (reservationMode == 'AVEC_SIEGES') {
          final autoAssign =
              perBilletSeatLabels.isEmpty ||
              perBilletSeatLabels.every((s) => s.trim().isEmpty);

          final planRows = await session.db.unsafeQuery(
            r'''
            SELECT "label", "row_index", "col_index", "blocked", "zone"
            FROM "cine_pass_event_seat"
            WHERE "event_id" = (@eventId)::uuid
            ''',
            parameters: QueryParameters.named({'eventId': eventId}),
            transaction: transaction,
          );
          if (planRows.isEmpty) {
            return ReservationConfirmResponse(
              success: false,
              message:
                  'Plan de sièges non configuré pour cet événement. Le responsable doit le définir.',
              reservationNumber: null,
              totalAmount: 0,
              placementLabel: null,
            );
          }

          final takenRows = await session.db.unsafeQuery(
            r'''
            SELECT DISTINCT upper(trim(b."placement_label")) AS pl
            FROM "cine_pass_billet" b
            JOIN "cine_pass_reservation" r ON r."id" = b."reservation_id"
            WHERE r."evenement_id" = (@eventId)::uuid
              AND lower(COALESCE(r."statut", '')) = 'paid'
              AND b."placement_label" IS NOT NULL
              AND trim(b."placement_label") <> ''
            ''',
            parameters: QueryParameters.named({'eventId': eventId}),
            transaction: transaction,
          );
          final taken = <String>{
            for (final row in takenRows)
              if (row.isNotEmpty && row[0] != null)
                row[0].toString().toUpperCase(),
          };

          final planByLower =
              <
                String,
                ({
                  String label,
                  int rowIndex,
                  int colIndex,
                  bool blocked,
                  String zone,
                })
              >{};
          for (final row in planRows) {
            final plab = row[0]?.toString().trim() ?? '';
            if (plab.isEmpty) continue;
            planByLower[plab.toLowerCase()] = (
              label: plab,
              rowIndex: _safeInt(row[1]),
              colIndex: _safeInt(row[2]),
              blocked: row[3] == true,
              zone: row[4]?.toString() ?? '',
            );
          }

          if (!autoAssign) {
            if (perBilletSeatLabels.length != perBilletTypeCodes.length) {
              return ReservationConfirmResponse(
                success: false,
                message: 'Un siège est requis pour chaque billet.',
                reservationNumber: null,
                totalAmount: 0,
                placementLabel: null,
              );
            }

            final normalized = <String>[];
            final seen = <String>{};
            for (final raw in perBilletSeatLabels) {
              final lab = raw.trim();
              if (lab.isEmpty) {
                return ReservationConfirmResponse(
                  success: false,
                  message: 'Siège invalide (libellé vide).',
                  reservationNumber: null,
                  totalAmount: 0,
                  placementLabel: null,
                );
              }
              final key = lab.toUpperCase();
              if (seen.contains(key)) {
                return ReservationConfirmResponse(
                  success: false,
                  message: 'Deux billets ne peuvent pas avoir le même siège.',
                  reservationNumber: null,
                  totalAmount: 0,
                  placementLabel: null,
                );
              }
              seen.add(key);
              normalized.add(lab);
            }

            for (var bi = 0; bi < normalized.length; bi++) {
              final lab = normalized[bi];
              final planEntry = planByLower[lab.toLowerCase()];
              if (planEntry == null) {
                return ReservationConfirmResponse(
                  success: false,
                  message:
                      'Siège inconnu : ce numéro ne fait pas partie du plan de l’événement.',
                  reservationNumber: null,
                  totalAmount: 0,
                  placementLabel: null,
                );
              }
              if (planEntry.blocked) {
                return ReservationConfirmResponse(
                  success: false,
                  message: 'Le siège ${planEntry.label} est indisponible.',
                  reservationNumber: null,
                  totalAmount: 0,
                  placementLabel: null,
                );
              }
              final ticketCode = perBilletTypeCodes[bi].trim();
              if (!_seatZoneAllowsTicket(planEntry.zone, ticketCode)) {
                return ReservationConfirmResponse(
                  success: false,
                  message:
                      'Le siège ${planEntry.label} ne correspond pas au type de billet choisi.',
                  reservationNumber: null,
                  totalAmount: 0,
                  placementLabel: null,
                );
              }
              if (taken.contains(planEntry.label.toUpperCase())) {
                return ReservationConfirmResponse(
                  success: false,
                  message: 'Le siège ${planEntry.label} n’est plus disponible.',
                  reservationNumber: null,
                  totalAmount: 0,
                  placementLabel: null,
                );
              }
              placementPerBillet[bi] = planEntry.label;
            }
          } else {
            // Auto-attribution : on choisit les meilleurs sièges disponibles
            // selon les types de billets sélectionnés (zone + adjacent best effort).
            final indicesByType = <String, List<int>>{};
            final typeOrder = <String>[];
            for (var bi = 0; bi < perBilletTypeCodes.length; bi++) {
              final code = perBilletTypeCodes[bi].trim().toUpperCase();
              indicesByType.putIfAbsent(code, () => <int>[]).add(bi);
              if (!typeOrder.contains(code)) typeOrder.add(code);
            }

            final availableByUpper =
                <
                  String,
                  ({String label, int rowIndex, int colIndex, String zone})
                >{};
            for (final e in planByLower.values) {
              if (e.blocked) continue;
              final upper = e.label.toUpperCase();
              if (taken.contains(upper)) continue;
              availableByUpper[upper] = (
                label: e.label,
                rowIndex: e.rowIndex,
                colIndex: e.colIndex,
                zone: e.zone,
              );
            }

            List<({String label, int rowIndex, int colIndex, String zone})>
            pickForType({
              required String ticketTypeCode,
              required int count,
            }) {
              final candidates =
                  availableByUpper.values
                      .where(
                        (s) => _seatZoneAllowsTicket(s.zone, ticketTypeCode),
                      )
                      .toList()
                    ..sort((a, b) {
                      final r = a.rowIndex.compareTo(b.rowIndex);
                      return r != 0 ? r : a.colIndex.compareTo(b.colIndex);
                    });

              if (candidates.length < count) return const [];

              if (!adjacentBestEffort || count <= 1) {
                return candidates.take(count).toList();
              }

              // Tentative : trouver un bloc contigu en col_index dans une même row.
              final byRow =
                  <
                    int,
                    List<
                      ({String label, int rowIndex, int colIndex, String zone})
                    >
                  >{};
              for (final s in candidates) {
                byRow
                    .putIfAbsent(
                      s.rowIndex,
                      () =>
                          <
                            ({
                              String label,
                              int rowIndex,
                              int colIndex,
                              String zone,
                            })
                          >[],
                    )
                    .add(s);
              }
              final sortedRowKeys = byRow.keys.toList()..sort();
              for (final rk in sortedRowKeys) {
                final list = byRow[rk]!;
                if (list.length < count) continue;
                final sorted = list
                  ..sort((a, b) => a.colIndex.compareTo(b.colIndex));
                for (var start = 0; start <= sorted.length - count; start++) {
                  var ok = true;
                  final baseCol = sorted[start].colIndex;
                  for (var off = 0; off < count; off++) {
                    if (sorted[start + off].colIndex != baseCol + off) {
                      ok = false;
                      break;
                    }
                  }
                  if (ok) {
                    return sorted.sublist(start, start + count);
                  }
                }
              }

              // Fallback : premiers disponibles.
              return candidates.take(count).toList();
            }

            for (final typeCode in typeOrder) {
              final indices = indicesByType[typeCode] ?? const <int>[];
              final count = indices.length;
              if (count == 0) continue;

              final chosenSeats = pickForType(
                ticketTypeCode: typeCode,
                count: count,
              );
              if (chosenSeats.isEmpty) {
                return ReservationConfirmResponse(
                  success: false,
                  message:
                      'Stock insuffisant dans le plan de sièges pour le type de billet $typeCode.',
                  reservationNumber: null,
                  totalAmount: 0,
                  placementLabel: null,
                );
              }

              for (var i = 0; i < indices.length; i++) {
                placementPerBillet[indices[i]] = chosenSeats[i].label;
              }

              // Verrou local : retirer les sièges choisis du pool disponible pour les autres types.
              for (final s in chosenSeats) {
                availableByUpper.remove(s.label.toUpperCase());
              }
            }
          }
        }

        final requestedCount = perBilletTypeCodes.length;
        if (requestedCount > maxPerOrder) {
          return ReservationConfirmResponse(
            success: false,
            message: 'Maximum $maxPerOrder billet(s) par commande.',
            reservationNumber: null,
            totalAmount: 0,
            placementLabel: null,
          );
        }

        final typeRows = await session.db.unsafeQuery(
          r'''
          SELECT "code", "label", "price", "quota", "active", "sort_order"
          FROM "cine_pass_event_ticket_type"
          WHERE "event_id" = (@eventId)::uuid
          ORDER BY "sort_order" ASC, "code" ASC
          FOR UPDATE
          ''',
          parameters: QueryParameters.named({'eventId': eventId}),
          transaction: transaction,
        );
        if (typeRows.isEmpty) {
          return ReservationConfirmResponse(
            success: false,
            message: 'Configuration des billets manquante.',
            reservationNumber: null,
            totalAmount: 0,
            placementLabel: null,
          );
        }

        final optionMetaRows = await session.db.unsafeQuery(
          r'''
          SELECT "ticket_type_code", "option_code", "price", "included", "active"
          FROM "cine_pass_event_ticket_option"
          WHERE "event_id" = (@eventId)::uuid
          ''',
          parameters: QueryParameters.named({'eventId': eventId}),
          transaction: transaction,
        );
        final payantOptionPrice = <String, double>{};
        for (final row in optionMetaRows) {
          final tt = (row[0]?.toString() ?? '').toUpperCase();
          final oc = (row[1]?.toString() ?? '').toUpperCase();
          if (tt.isEmpty || oc.isEmpty) continue;
          final incl = row[3] == true;
          final active = row[4] == true;
          if (!active || incl) continue;
          payantOptionPrice['$tt|$oc'] = _safeDouble(row[2]);
        }

        final soldRows = await session.db.unsafeQuery(
          r'''
          SELECT COALESCE(b."ticket_type", 'standard') AS ticket_type, COUNT(*)::int AS sold_count
          FROM "cine_pass_billet" b
          JOIN "cine_pass_reservation" r ON r."id" = b."reservation_id"
          WHERE r."evenement_id" = (@eventId)::uuid
            AND lower(COALESCE(r."statut", '')) = 'paid'
          GROUP BY COALESCE(b."ticket_type", 'standard')
          ''',
          parameters: QueryParameters.named({'eventId': eventId}),
          transaction: transaction,
        );
        final soldByType = <String, int>{};
        for (final row in soldRows) {
          soldByType[(row[0]?.toString() ?? 'standard').toLowerCase()] =
              _safeInt(row[1]);
        }

        final typeByCode = <String, List<dynamic>>{
          for (final row in typeRows)
            (row[0]?.toString() ?? '').toLowerCase(): row,
        };

        final qtyByType = <String, int>{};
        for (final raw in perBilletTypeCodes) {
          final reqCode = raw.trim().toLowerCase();
          qtyByType[reqCode] = (qtyByType[reqCode] ?? 0) + 1;
        }

        for (final e in qtyByType.entries) {
          final reqCode = e.key;
          final qty = e.value;
          final type = typeByCode[reqCode];
          if (type == null) {
            return ReservationConfirmResponse(
              success: false,
              message: 'Type de billet introuvable: $reqCode',
              reservationNumber: null,
              totalAmount: 0,
              placementLabel: null,
            );
          }
          final isActive = type[4] == true;
          if (!isActive) {
            return ReservationConfirmResponse(
              success: false,
              message:
                  'Type de billet inactif: ${type[1]?.toString() ?? reqCode}',
              reservationNumber: null,
              totalAmount: 0,
              placementLabel: null,
            );
          }
          final quota = _safeInt(type[3]);
          final sold = soldByType[reqCode] ?? 0;
          final remaining = quota - sold;
          if (qty > remaining) {
            return ReservationConfirmResponse(
              success: false,
              message:
                  'Stock insuffisant pour ${type[1]?.toString() ?? reqCode} (reste $remaining).',
              reservationNumber: null,
              totalAmount: 0,
              placementLabel: null,
            );
          }
        }

        final lineAmounts = <double>[];
        var totalAmount = 0.0;
        for (var bi = 0; bi < perBilletTypeCodes.length; bi++) {
          final reqCode = perBilletTypeCodes[bi].trim().toLowerCase();
          final type = typeByCode[reqCode]!;
          final base = _safeDouble(type[2]);
          var line = base;
          final csv = bi < perBilletPayantOptionCsv.length
              ? perBilletPayantOptionCsv[bi]
              : '';
          final codes = <String>{};
          for (final part in csv.split(',')) {
            final o = part.trim().toUpperCase();
            if (o.isEmpty) continue;
            codes.add(o);
          }
          final ttUpper = (type[0]?.toString() ?? '').toUpperCase();
          for (final o in codes) {
            final key = '$ttUpper|$o';
            if (!payantOptionPrice.containsKey(key)) {
              return ReservationConfirmResponse(
                success: false,
                message: 'Option invalide pour ce type de billet: $o',
                reservationNumber: null,
                totalAmount: 0,
                placementLabel: null,
              );
            }
            line += payantOptionPrice[key]!;
          }
          lineAmounts.add(line);
          totalAmount += line;
        }

        final numero = 'BOOK-${DateTime.now().millisecondsSinceEpoch}';
        final eventDate = _safeDateTime(eventRows.first[0]);
        final eventTime = _safeDateTime(eventRows.first[1]);
        final sessionAt = eventTime ?? eventDate ?? DateTime.now();

        final reservationInsert = await session.db.unsafeQuery(
          r'''
          INSERT INTO "cine_pass_reservation" (
            "user_id", "seance_id", "evenement_id", "numero", "statut",
            "total_amount", "session_at"
          )
          VALUES (
            (@uid)::uuid, NULL, (@eventId)::uuid, @numero, 'paid',
            @totalAmount, @sessionAt
          )
          RETURNING "id"
          ''',
          parameters: QueryParameters.named({
            'uid': userId,
            'eventId': eventId,
            'numero': numero,
            'totalAmount': totalAmount,
            'sessionAt': sessionAt,
          }),
          transaction: transaction,
        );
        if (reservationInsert.isEmpty) {
          return ReservationConfirmResponse(
            success: false,
            message: 'Impossible de créer la réservation.',
            reservationNumber: null,
            totalAmount: 0,
            placementLabel: null,
          );
        }
        final reservationId = reservationInsert.first[0].toString();

        for (var bi = 0; bi < perBilletTypeCodes.length; bi++) {
          final reqCode = perBilletTypeCodes[bi].trim().toLowerCase();
          final billetPrix = lineAmounts[bi];
          await session.db.unsafeQuery(
            r'''
            INSERT INTO "cine_pass_billet" (
              "reservation_id", "siege_id", "ticket_type",
              "option_parking", "option_popcorn", "option_boisson", "prix",
              "placement_label"
            )
            VALUES (
              (@rid)::uuid, NULL, @ticketType, false, false, false, @prix,
              @placementLabel
            )
            ''',
            parameters: QueryParameters.named({
              'rid': reservationId,
              'ticketType': reqCode,
              'prix': billetPrix,
              'placementLabel': placementPerBillet[bi],
            }),
            transaction: transaction,
          );
        }

        final placementSummary = reservationMode == 'AVEC_SIEGES'
            ? () {
                final labels = placementPerBillet.whereType<String>().toList();
                return labels.isEmpty
                    ? 'Sièges à attribuer'
                    : 'Sièges : ${labels.join(', ')}';
              }()
            : 'Placement libre';

        return ReservationConfirmResponse(
          success: true,
          message: 'Réservation confirmée.',
          reservationNumber: numero,
          totalAmount: totalAmount,
          placementLabel: placementSummary,
        );
      });
    } catch (e, st) {
      session.log(
        'CinePass confirmEventReservation',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return ReservationConfirmResponse(
        success: false,
        message: 'Erreur serveur pendant la confirmation.',
        reservationNumber: null,
        totalAmount: 0,
        placementLabel: null,
      );
    }
  }

  /// Villes distinctes (films + événements) pour les filtres.
  /// Une entrée par ville « logique » (insensible à la casse).
  Future<List<String>> getCities(Session session) async {
    try {
      final rows = await session.db.unsafeQuery(
        r'''
        SELECT MIN(TRIM(v)) AS display_ville
        FROM (
          SELECT "ville"::text AS v FROM "cine_pass_cinema"
          WHERE TRIM(COALESCE("ville", '')) <> ''
          UNION ALL
          SELECT "ville"::text AS v FROM "cine_pass_evenement"
          WHERE TRIM(COALESCE("ville", '')) <> ''
        ) AS u
        GROUP BY LOWER(TRIM(v))
        ORDER BY display_ville
        ''',
      );
      return ['Toutes', ...rows.map((row) => row[0] as String)];
    } catch (_) {
      return ['Toutes'];
    }
  }

  /// Genres distincts (films) pour les filtres.
  Future<List<String>> getGenres(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'''
        SELECT DISTINCT g FROM (
          SELECT TRIM("genre") AS g FROM "cine_pass_film"
          WHERE TRIM(COALESCE("genre", '')) <> ''
          UNION
          SELECT TRIM(f."film_genre") AS g
          FROM "cine_pass_event_film_details" f
          WHERE TRIM(COALESCE(f."film_genre", '')) <> ''
        ) AS u
        WHERE g <> ''
        ORDER BY g
        ''',
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

  /// Valeurs de filtre dynamiques selon le type d'événement.
  Future<List<String>> getEventDynamicFilterValues(
    Session session, {
    required String eventType,
    required String filterKey,
  }) async {
    try {
      final type = eventType.trim().toUpperCase();
      final key = filterKey.trim().toLowerCase();
      String? sql;
      if (type == 'FILM' && key == 'genre') {
        sql = r'''
          SELECT DISTINCT COALESCE(f."film_genre", '')
          FROM "cine_pass_event_film_details" f
          JOIN "cine_pass_evenement" e ON e."id" = f."event_id"
          WHERE COALESCE(f."film_genre", '') <> ''
            AND COALESCE(e."archived", false) = false
            AND e."eventDate" >= CURRENT_DATE
          ORDER BY 1
        ''';
      } else if (type == 'FILM' && key == 'director') {
        sql = r'''
          SELECT DISTINCT COALESCE(f."director", '')
          FROM "cine_pass_event_film_details" f
          JOIN "cine_pass_evenement" e ON e."id" = f."event_id"
          WHERE COALESCE(f."director", '') <> ''
            AND COALESCE(e."archived", false) = false
            AND e."eventDate" >= CURRENT_DATE
          ORDER BY 1
        ''';
      } else if (type == 'FILM' && key == 'language') {
        sql = r'''
          SELECT DISTINCT v FROM (
            SELECT COALESCE(f."original_language", '') AS v
            FROM "cine_pass_event_film_details" f
            JOIN "cine_pass_evenement" e ON e."id" = f."event_id"
            WHERE COALESCE(f."original_language", '') <> ''
              AND COALESCE(e."archived", false) = false
              AND e."eventDate" >= CURRENT_DATE
            UNION
            SELECT COALESCE(e."event_language", '') AS v
            FROM "cine_pass_evenement" e
            WHERE e."event_type" = 'FILM'
              AND COALESCE(e."event_language", '') <> ''
              AND COALESCE(e."archived", false) = false
              AND e."eventDate" >= CURRENT_DATE
          ) u WHERE v <> ''
          ORDER BY 1
        ''';
      } else if (type == 'CONCERT' && key == 'artist') {
        sql = r'''
          SELECT DISTINCT COALESCE(c."artist", '')
          FROM "cine_pass_event_concert_details" c
          JOIN "cine_pass_evenement" e ON e."id" = c."event_id"
          WHERE COALESCE(c."artist", '') <> ''
            AND COALESCE(e."archived", false) = false
            AND e."eventDate" >= CURRENT_DATE
          ORDER BY 1
        ''';
      } else if (type == 'CONCERT' && key == 'music_genre') {
        sql = r'''
          SELECT DISTINCT COALESCE(c."music_genre", '')
          FROM "cine_pass_event_concert_details" c
          JOIN "cine_pass_evenement" e ON e."id" = c."event_id"
          WHERE COALESCE(c."music_genre", '') <> ''
            AND COALESCE(e."archived", false) = false
            AND e."eventDate" >= CURRENT_DATE
          ORDER BY 1
        ''';
      } else if (type == 'FESTIVAL' && key == 'theme') {
        sql = r'''
          SELECT DISTINCT COALESCE(f."theme", '')
          FROM "cine_pass_event_festival_details" f
          JOIN "cine_pass_evenement" e ON e."id" = f."event_id"
          WHERE COALESCE(f."theme", '') <> ''
            AND COALESCE(e."archived", false) = false
            AND e."eventDate" >= CURRENT_DATE
          ORDER BY 1
        ''';
      } else if (type == 'STANDUP' && key == 'main_artist') {
        sql = r'''
          SELECT DISTINCT COALESCE(s."main_artist", '')
          FROM "cine_pass_event_standup_details" s
          JOIN "cine_pass_evenement" e ON e."id" = s."event_id"
          WHERE COALESCE(s."main_artist", '') <> ''
            AND COALESCE(e."archived", false) = false
            AND e."eventDate" >= CURRENT_DATE
          ORDER BY 1
        ''';
      } else if (type == 'THEATRE' && key == 'author') {
        sql = r'''
          SELECT DISTINCT COALESCE(t."author", '')
          FROM "cine_pass_event_theatre_details" t
          JOIN "cine_pass_evenement" e ON e."id" = t."event_id"
          WHERE COALESCE(t."author", '') <> ''
            AND COALESCE(e."archived", false) = false
            AND e."eventDate" >= CURRENT_DATE
          ORDER BY 1
        ''';
      }
      if (sql == null) return ['Tous'];
      final rows = await session.db.unsafeQuery(sql);
      final values =
          rows
              .map((r) => r.isNotEmpty ? (r[0]?.toString() ?? '') : '')
              .where((v) => v.trim().isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      return ['Tous', ...values];
    } catch (_) {
      return ['Tous'];
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
    String? posterUrl,
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
          "casting", "posterColor", "posterUrl", "dateSortie", "dateFin", "audience"
        )
        VALUES (
          @titre, @genre, @dureeMinutes, @synopsis, @directeur,
          @casting, @posterColor, @posterUrl, @dateSortie, @dateFin, @audience
        )
        RETURNING "id", "titre", "genre", "dureeMinutes", "synopsis", "directeur",
                  "casting", "posterColor", "posterUrl"
        ''',
        parameters: QueryParameters.named({
          'titre': title,
          'genre': genre,
          'dureeMinutes': durationMinutes,
          'synopsis': synopsis,
          'directeur': director,
          'casting': casting,
          'posterColor': posterColor,
          'posterUrl': posterUrl,
          'dateSortie': dSortie,
          'dateFin': dFin,
          'audience': audience,
        }),
      );
      if (id.isEmpty) return null;
      return _rowToFilmResponse(id.first);
    } catch (e, st) {
      session.log(
        'CinePass createFilm',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
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
    required DateTime eventDate,
    required String eventTimeStr,
    required int placesTotal,
    required double prixBase,
    int? posterColor,
    String? posterUrl,
    String? structureId,

    /// JSON des champs typés (film, concert, etc.) — alimente les tables `cine_pass_event_*_details`.
    String? eventTypedDetailsJson,
  }) async {
    try {
      final isAdmin = await _isAdmin(session);
      var effectiveStructureId = structureId?.trim();
      if (effectiveStructureId != null && effectiveStructureId.isEmpty) {
        effectiveStructureId = null;
      }

      if (!isAdmin) {
        final assigned = await _responsableStructureIds(session);
        if (assigned.isEmpty) {
          session.log(
            'createEvent refuse: utilisateur non admin/non responsable',
          );
          return null;
        }

        if (effectiveStructureId == null) {
          effectiveStructureId = assigned.first;
        } else if (!_assignedHasStructure(assigned, effectiveStructureId)) {
          session.log(
            'createEvent refuse: structure hors perimetre responsable',
          );
          return null;
        }
      }

      final eventDateDt = eventDate;
      DateTime eventTime = eventDateDt;
      if (eventTimeStr.length >= 5) {
        final parts = eventTimeStr.split(':');
        if (parts.length >= 2) {
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          eventTime = DateTime(
            eventDateDt.year,
            eventDateDt.month,
            eventDateDt.day,
            h,
            m,
          );
        }
      }
      final eventType = _eventTypeFromCategory(categorie);
      late final String eventId;
      await session.db.transaction((txn) async {
        final result = await session.db.unsafeQuery(
          r'''
        INSERT INTO "cine_pass_evenement" (
          "titre", "categorie", "event_type", "description", "lieu", "adresse", "ville",
          "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor",
          "posterUrl", "structureId"
        )
        VALUES (
          @titre::text, @categorie::text, @eventType::text, @description::text, @lieu::text, @adresse::text, @ville::text,
          @eventDate::timestamp, @eventTime::timestamp, @placesTotal::bigint, @prixBase::double precision, @posterColor::bigint,
          @posterUrl::text,
          CASE WHEN @structureId::text = '' OR @structureId IS NULL THEN NULL ELSE (@structureId)::uuid END
        )
        RETURNING "id", "titre", "categorie", "description", "lieu", "adresse", "ville",
                  "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor",
                  "posterUrl", "availableOptions"
        ''',
          parameters: QueryParameters.named({
            'titre': titre,
            'categorie': categorie,
            'eventType': eventType,
            'description': description,
            'lieu': lieu,
            'adresse': adresse,
            'ville': ville,
            'eventDate': eventDateDt,
            'eventTime': eventTime,
            'placesTotal': placesTotal,
            'prixBase': prixBase,
            'posterColor': posterColor,
            'posterUrl': posterUrl,
            'structureId': effectiveStructureId ?? '',
          }),
          transaction: txn,
        );
        if (result.isEmpty) {
          throw StateError('createEvent: INSERT returned no row');
        }
        eventId = result.first[0].toString();
        await _syncEventTypedDetails(
          session,
          eventId: eventId,
          eventType: eventType,
          category: categorie,
          description: description,
          typedDetailsJson: eventTypedDetailsJson,
          transaction: txn,
        );
      });
      return await getEventById(session, eventId);
    } catch (e, st) {
      session.log(
        'CinePass createEvent',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Liste de toutes les structures (admin).
  Future<List<Structure>> getStructures(Session session) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('getStructures refuse: admin requis');
        return [];
      }
      return await Structure.db.find(session, orderBy: (t) => t.name);
    } catch (e, st) {
      session.log(
        'CinePass getStructures',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Détail d'une structure par id (admin).
  Future<Structure?> getStructureById(Session session, String id) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('getStructureById refuse: admin requis');
        return null;
      }
      final list = await Structure.db.find(session);
      for (final s in list) {
        if (s.id.toString() == id) return s;
      }
      return null;
    } catch (e, st) {
      session.log(
        'CinePass getStructureById',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
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
    DateTime? eventDate,
    String? eventTimeStr,
    int? placesTotal,
    double? prixBase,
    int? posterColor,
    String? posterUrl,
    String? eventTypedDetailsJson,
  }) async {
    try {
      final idNorm = _normalizeClientEventId(id);
      if (idNorm == null) return null;
      final isAdmin = await _isAdmin(session);
      if (!isAdmin) {
        final assigned = await _responsableStructureIds(session);
        if (assigned.isEmpty) return null;
        final targetRows = await session.db.unsafeQuery(
          r'''SELECT "structureId" FROM "cine_pass_evenement" WHERE "id" = (@id)::uuid''',
          parameters: QueryParameters.named({'id': idNorm}),
        );
        final targetStructureId = _eventStructureIdFromRow(targetRows);
        if (targetStructureId == null ||
            !_assignedHasStructure(assigned, targetStructureId)) {
          session.log(
            'updateEvent refuse: structure hors perimetre responsable (structureId=$targetStructureId)',
          );
          return null;
        }
      }

      final eventDateDt = eventDate;
      DateTime? eventTimeDt;
      if (eventDateDt != null &&
          eventTimeStr != null &&
          eventTimeStr.length >= 5) {
        final parts = eventTimeStr.split(':');
        if (parts.length >= 2) {
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          eventTimeDt = DateTime(
            eventDateDt.year,
            eventDateDt.month,
            eventDateDt.day,
            h,
            m,
          );
        }
      }
      final normalizedCategory = (categorie ?? '').trim();
      final eventTypeForRow = normalizedCategory.isEmpty
          ? null
          : _eventTypeFromCategory(normalizedCategory);
      late final List<dynamic> row;
      await session.db.transaction((txn) async {
        final result = await session.db.unsafeQuery(
          r'''
        UPDATE "cine_pass_evenement"
        SET
          "titre" = CASE WHEN @titre::text IS NOT NULL AND @titre::text != '' THEN @titre::text ELSE "titre" END,
          "categorie" = CASE WHEN @categorie::text IS NOT NULL AND @categorie::text != '' THEN @categorie::text ELSE "categorie" END,
          "event_type" = CASE WHEN @eventTypeCode::text IS NOT NULL AND @eventTypeCode::text != '' THEN @eventTypeCode::text ELSE "event_type" END,
          "description" = CASE WHEN @description::text IS NOT NULL THEN @description::text ELSE "description" END,
          "lieu" = CASE WHEN @lieu::text IS NOT NULL AND @lieu::text != '' THEN @lieu::text ELSE "lieu" END,
          "adresse" = CASE WHEN @adresse::text IS NOT NULL THEN @adresse::text ELSE "adresse" END,
          "ville" = CASE WHEN @ville::text IS NOT NULL AND @ville::text != '' THEN @ville::text ELSE "ville" END,
          "eventDate" = CASE WHEN @eventDate::timestamp IS NOT NULL THEN @eventDate::timestamp ELSE "eventDate" END,
          "eventTime" = CASE WHEN @eventTime::timestamp IS NOT NULL THEN @eventTime::timestamp ELSE "eventTime" END,
          "placesTotal" = CASE WHEN @placesTotal::bigint IS NOT NULL THEN @placesTotal::bigint ELSE "placesTotal" END,
          "prixBase" = CASE WHEN @prixBase::double precision IS NOT NULL THEN @prixBase::double precision ELSE "prixBase" END,
          "posterColor" = CASE WHEN @posterColor::bigint IS NOT NULL THEN @posterColor::bigint ELSE "posterColor" END,
          "posterUrl" = CASE WHEN @posterUrl::text IS NOT NULL THEN @posterUrl::text ELSE "posterUrl" END
        WHERE "id" = (@id)::uuid
        RETURNING "id", "titre", "categorie", "description", "lieu", "adresse", "ville",
                  "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor",
                  "posterUrl", "availableOptions"
        ''',
          parameters: QueryParameters.named({
            'id': idNorm,
            'titre': titre,
            'categorie': categorie,
            'eventTypeCode': eventTypeForRow,
            'description': description,
            'lieu': lieu,
            'adresse': adresse,
            'ville': ville,
            'eventDate': eventDateDt,
            'eventTime': eventTimeDt,
            'placesTotal': placesTotal,
            'prixBase': prixBase,
            'posterColor': posterColor,
            'posterUrl': posterUrl,
          }),
          transaction: txn,
        );
        if (result.isEmpty) {
          throw StateError('updateEvent: no row updated');
        }
        row = result.first;
        await _syncEventTypedDetails(
          session,
          eventId: row[0].toString(),
          eventType:
              eventTypeForRow ?? _eventTypeFromCategory(row[2]?.toString()),
          category: normalizedCategory.isNotEmpty
              ? normalizedCategory
              : row[2]?.toString(),
          description: description ?? row[3]?.toString(),
          typedDetailsJson: eventTypedDetailsJson,
          transaction: txn,
        );
      });
      return await getEventById(session, idNorm);
    } catch (e, st) {
      session.log(
        'CinePass updateEvent',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Supprimer un événement (admin ou responsable de la structure).
  Future<bool> deleteEvent(Session session, String id) async {
    try {
      final idNorm = _normalizeClientEventId(id);
      if (idNorm == null) return false;
      final isAdmin = await _isAdmin(session);
      if (!isAdmin) {
        final assigned = await _responsableStructureIds(session);
        if (assigned.isEmpty) return false;
        final targetRows = await session.db.unsafeQuery(
          r'''SELECT "structureId" FROM "cine_pass_evenement" WHERE "id" = (@id)::uuid''',
          parameters: QueryParameters.named({'id': idNorm}),
        );
        final targetStructureId = _eventStructureIdFromRow(targetRows);
        if (targetStructureId == null ||
            !_assignedHasStructure(assigned, targetStructureId)) {
          session.log(
            'deleteEvent refuse: structure hors perimetre responsable (structureId=$targetStructureId)',
          );
          return false;
        }

        /// Responsable : pas de suppression si des réservations actives existent.
        final resRows = await session.db.unsafeQuery(
          r'''
          SELECT COUNT(*)::int AS c FROM "cine_pass_reservation"
          WHERE "evenement_id" = (@id)::uuid
            AND LOWER(TRIM(COALESCE("statut", ''))) NOT IN (
              'cancelled', 'refunded', 'annulé', 'annule', 'remboursé', 'rembourse'
            )
          ''',
          parameters: QueryParameters.named({'id': idNorm}),
        );
        final activeRes = resRows.isEmpty
            ? 0
            : int.tryParse(resRows.first[0].toString()) ?? 0;
        if (activeRes > 0) {
          session.log(
            'deleteEvent refuse: $activeRes reservation(s) active(s) sur cet evenement',
          );
          return false;
        }
      }

      await session.db.unsafeQuery(
        r'DELETE FROM "cine_pass_evenement" WHERE "id" = (@id)::uuid',
        parameters: QueryParameters.named({'id': idNorm}),
      );
      return true;
    } catch (e, st) {
      session.log(
        'CinePass deleteEvent',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Structure(s) assignée(s) au responsable connecté.
  Future<Structure?> getMyStructure(Session session) async {
    try {
      final userId = session.authenticated?.userIdentifier;
      if (userId == null) {
        return null;
      }
      final rows = await session.db.unsafeQuery(
        r'SELECT "structure_id" FROM "cine_pass_responsable_assignment" WHERE "user_id" = (@uid)::uuid AND "active" = true LIMIT 1',
        parameters: QueryParameters.named({'uid': userId}),
      );
      if (rows.isEmpty) return null;
      final structureId = rows.first[0].toString();
      final key = _uuidNorm(structureId);
      final all = await Structure.db.find(session);
      for (final s in all) {
        if (_uuidNorm(s.id) == key) {
          return s;
        }
      }
      return null;
    } catch (e, st) {
      session.log(
        'CinePass getMyStructure',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Responsable: mettre à jour les informations de sa structure assignée.
  /// Admin: peut aussi mettre à jour n'importe quelle structure via structureId.
  Future<Structure?> updateMyStructure(
    Session session, {
    String? structureId,
    String? name,
    String? city,
    String? address,
    String? website,
    String? phone,
  }) async {
    try {
      final isAdmin = await _isAdmin(session);
      String? targetStructureId = structureId;

      if (!isAdmin) {
        final assigned = await _responsableStructureIds(session);
        if (assigned.isEmpty) {
          session.log('updateMyStructure refuse: aucune structure assignee');
          return null;
        }
        if (targetStructureId == null || targetStructureId.trim().isEmpty) {
          targetStructureId = assigned.first;
        } else if (!_assignedHasStructure(assigned, targetStructureId)) {
          session.log(
            'updateMyStructure refuse: structure hors perimetre responsable',
          );
          return null;
        }
      } else {
        if (targetStructureId == null || targetStructureId.trim().isEmpty) {
          return null;
        }
      }

      final rows = await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_structure"
        SET
          "name" = CASE WHEN @name::text IS NOT NULL AND @name::text != '' THEN @name::text ELSE "name" END,
          "city" = CASE WHEN @city::text IS NOT NULL AND @city::text != '' THEN @city::text ELSE "city" END,
          "address" = CASE WHEN @address::text IS NOT NULL THEN @address::text ELSE "address" END,
          "website" = CASE WHEN @website::text IS NOT NULL THEN @website::text ELSE "website" END,
          "phone" = CASE WHEN @phone::text IS NOT NULL THEN @phone::text ELSE "phone" END
        WHERE "id" = (@id)::uuid
        RETURNING "id", "type", "name", "city", "address", "website", "phone", "cinemaId"
        ''',
        parameters: QueryParameters.named({
          'id': targetStructureId,
          'name': name,
          'city': city,
          'address': address,
          'website': website,
          'phone': phone,
        }),
      );
      if (rows.isEmpty) return null;
      return _rowToStructure(rows.first);
    } catch (e, st) {
      session.log(
        'CinePass updateMyStructure',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Admin: désactiver une structure côté responsable (assignments inactifs).
  Future<bool> banStructure(Session session, String structureId) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('banStructure refuse: admin requis');
        return false;
      }
      final usersRows = await session.db.unsafeQuery(
        r'''
        SELECT DISTINCT "user_id"
        FROM "cine_pass_responsable_assignment"
        WHERE "structure_id" = (@sid)::uuid
        ''',
        parameters: QueryParameters.named({'sid': structureId}),
      );

      await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_responsable_assignment"
        SET "active" = false
        WHERE "structure_id" = (@sid)::uuid
        ''',
        parameters: QueryParameters.named({'sid': structureId}),
      );

      for (final row in usersRows) {
        final uid = row[0]?.toString();
        if (uid == null || uid.isEmpty) continue;
        final activeRows = await session.db.unsafeQuery(
          r'''
          SELECT 1
          FROM "cine_pass_responsable_assignment"
          WHERE "user_id" = (@uid)::uuid AND "active" = true
          LIMIT 1
          ''',
          parameters: QueryParameters.named({'uid': uid}),
        );
        if (activeRows.isEmpty) {
          await session.db.unsafeQuery(
            r'''
            UPDATE "cine_pass_responsable_user"
            SET "active" = false, "updated_at" = now()
            WHERE "user_id" = (@uid)::uuid
            ''',
            parameters: QueryParameters.named({'uid': uid}),
          );
        }
      }
      return true;
    } catch (e, st) {
      session.log(
        'CinePass banStructure',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Admin: supprimer une structure.
  Future<bool> deleteStructure(Session session, String structureId) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('deleteStructure refuse: admin requis');
        return false;
      }
      await session.db.unsafeQuery(
        r'DELETE FROM "cine_pass_structure" WHERE "id" = (@sid)::uuid',
        parameters: QueryParameters.named({'sid': structureId}),
      );
      return true;
    } catch (e, st) {
      session.log(
        'CinePass deleteStructure',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Événements des structures du responsable connecté.
  Future<List<EventResponse>> getMyEvents(Session session) async {
    try {
      final userId = session.authenticated?.userIdentifier;
      if (userId == null) {
        return [];
      }
      final result = await session.db.unsafeQuery(
        r"""
        SELECT e."id", e."titre", e."categorie", e."description", e."lieu", e."adresse", e."ville",
               e."eventDate", e."eventTime", e."placesTotal", e."prixBase", e."posterColor", e."posterUrl", e."availableOptions",
               e."event_type", e."event_subtype", e."custom_type_label", e."event_language",
               f."film_genre", f."director", fe."theme", s."main_artist", c."artist", c."music_genre", t."author",
               COALESCE((
                 SELECT MIN(tt."price") FROM "cine_pass_event_ticket_type" tt
                 WHERE tt."event_id" = e."id" AND tt."active" = true
               ), e."prixBase") AS min_ticket_price,
               COALESCE((
                 SELECT MAX(tt."price") FROM "cine_pass_event_ticket_type" tt
                 WHERE tt."event_id" = e."id" AND tt."active" = true
               ), e."prixBase") AS max_ticket_price,
               (SELECT cfg."reservation_mode" FROM "cine_pass_event_reservation_config" cfg
                WHERE cfg."event_id" = e."id" LIMIT 1) AS reservation_mode,
               (SELECT st."name" FROM "cine_pass_structure" st WHERE st."id" = e."structureId" LIMIT 1) AS structure_name,
               (SELECT COUNT(*)::bigint FROM "cine_pass_billet" b
                INNER JOIN "cine_pass_reservation" r ON r."id" = b."reservation_id"
                WHERE r."evenement_id" = e."id"
                  AND LOWER(TRIM(COALESCE(r."statut", ''))) = 'paid') AS tickets_sold,
               COALESCE(e."archived", false) AS ev_archived
        FROM "cine_pass_evenement" e
        LEFT JOIN "cine_pass_event_film_details" f ON f."event_id" = e."id"
        LEFT JOIN "cine_pass_event_festival_details" fe ON fe."event_id" = e."id"
        LEFT JOIN "cine_pass_event_standup_details" s ON s."event_id" = e."id"
        LEFT JOIN "cine_pass_event_concert_details" c ON c."event_id" = e."id"
        LEFT JOIN "cine_pass_event_theatre_details" t ON t."event_id" = e."id"
        WHERE e."structureId" IN (
          SELECT a."structure_id" FROM "cine_pass_responsable_assignment" a
          WHERE a."user_id" = (@uid)::uuid AND a."active" = true
        )
        ORDER BY e."archived" ASC, e."eventDate", e."eventTime"
        """,
        parameters: QueryParameters.named({'uid': userId}),
      );
      return result.map((row) => _rowToEventResponse(row)).toList();
    } catch (e, st) {
      session.log(
        'CinePass getMyEvents',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Admin: demandes en attente (devenir responsable).
  Future<List<DemandeResponsableResponse>> getDemandesEnAttente(
    Session session,
  ) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('getDemandesEnAttente refuse: admin requis');
        return [];
      }

      final result = await session.db.unsafeQuery(
        r'''
        SELECT r."id", r."user_id", r."structure_type", r."structure_name", r."structure_city",
               r."structure_address", r."structure_website", r."structure_siret", r."structure_phone",
               r."contact_role", r."description", r."social_links", r."professional_email",
               r."status", r."created_at",
               COALESCE(p."fullName", '') AS user_display_name,
               COALESCE(p."email", '') AS user_account_email
        FROM "cine_pass_responsable_request" r
        LEFT JOIN "serverpod_auth_core_profile" p ON p."authUserId" = r."user_id"
        WHERE r."status" = 'PENDING'
        ORDER BY r."created_at" ASC
        ''',
      );
      return result
          .map((row) => _rowToDemandeResponsableResponse(row))
          .toList();
    } catch (e, st) {
      session.log(
        'CinePass getDemandesEnAttente',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Admin: approuver une demande responsable → crée la structure et l'assignment.
  Future<bool> approuverDemande(Session session, String id) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('approuverDemande refuse: admin requis');
        return false;
      }

      final adminId = session.authenticated?.userIdentifier;
      if (adminId == null) {
        return false;
      }
      final rows = await session.db.unsafeQuery(
        r'''
        SELECT "user_id", "structure_type", "structure_name", "structure_city", "structure_address",
               "structure_website", "structure_phone"
        FROM "cine_pass_responsable_request"
        WHERE "id" = (@id)::uuid AND "status" = 'PENDING'
        ''',
        parameters: QueryParameters.named({'id': id}),
      );
      if (rows.isEmpty) {
        return false;
      }
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
      if (structureResult.isEmpty) {
        return false;
      }
      final structureId = structureResult.first[0].toString();
      await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_responsable_assignment" ("user_id", "structure_id", "active")
        VALUES ((@uid)::uuid, (@sid)::uuid, true)
        ON CONFLICT ("user_id", "structure_id") DO UPDATE SET "active" = true
        ''',
        parameters: QueryParameters.named({'uid': userId, 'sid': structureId}),
      );

      await _ensureResponsableRoleTable(session);
      await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_responsable_user" ("user_id", "active", "updated_at")
        VALUES ((@uid)::uuid, true, now())
        ON CONFLICT ("user_id") DO UPDATE SET
          "active" = true,
          "updated_at" = now()
        ''',
        parameters: QueryParameters.named({'uid': userId}),
      );

      await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_responsable_request"
        SET "status" = 'APPROVED', "decided_at" = now(), "admin_id" = (@adminId)::uuid
        WHERE "id" = (@id)::uuid
        ''',
        parameters: QueryParameters.named({'id': id, 'adminId': adminId}),
      );

      try {
        final emailRows = await session.db.unsafeQuery(
          r'''
          SELECT "email" FROM "serverpod_auth_core_profile"
          WHERE "authUserId" = (@uid)::uuid
          LIMIT 1
          ''',
          parameters: QueryParameters.named({'uid': userId}),
        );
        final userEmail = emailRows.isNotEmpty
            ? emailRows.first[0]?.toString().trim()
            : null;
        if (userEmail != null && userEmail.isNotEmpty) {
          await sendResponsableDemandApprovedEmail(
            session,
            email: userEmail,
            structureName: name,
          );
        } else {
          session.log(
            'approuverDemande: aucun email profil pour notifier user_id=$userId',
            level: LogLevel.warning,
          );
        }
      } catch (e, st) {
        session.log(
          'approuverDemande: echec envoi email approbation (approbation enregistree): $e',
          level: LogLevel.warning,
          exception: e,
          stackTrace: st,
        );
      }

      return true;
    } catch (e, st) {
      session.log(
        'CinePass approuverDemande',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Admin: rejeter une demande responsable.
  Future<bool> rejeterDemande(Session session, String id, String reason) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('rejeterDemande refuse: admin requis');
        return false;
      }

      final adminId = session.authenticated?.userIdentifier;
      if (adminId == null) {
        return false;
      }
      final existsRows = await session.db.unsafeQuery(
        r'''
        SELECT 1
        FROM "cine_pass_responsable_request"
        WHERE "id" = (@id)::uuid AND "status" = 'PENDING'
        LIMIT 1
        ''',
        parameters: QueryParameters.named({'id': id}),
      );
      if (existsRows.isEmpty) return false;

      await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_responsable_request"
        SET "status" = 'REJECTED', "decided_at" = now(), "admin_id" = (@adminId)::uuid, "rejection_reason" = @reason
        WHERE "id" = (@id)::uuid AND "status" = 'PENDING'
        ''',
        parameters: QueryParameters.named({
          'id': id,
          'adminId': adminId,
          'reason': reason,
        }),
      );
      return true;
    } catch (e, st) {
      session.log(
        'CinePass rejeterDemande',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
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
      if (userId == null) {
        return null;
      }

      // Anti-doublon: un compte déjà responsable ne doit pas recréer de demande.
      if (await _isResponsable(session)) {
        session.log(
          'createDemandeResponsable ignore: utilisateur deja responsable',
        );
        return null;
      }

      // Anti-doublon: si une demande PENDING existe déjà, on la renvoie.
      final pendingRows = await session.db.unsafeQuery(
        r'''
        SELECT "id", "user_id", "structure_type", "structure_name", "structure_city",
               "structure_address", "status", "created_at"
        FROM "cine_pass_responsable_request"
        WHERE "user_id" = (@uid)::uuid AND "status" = 'PENDING'
        ORDER BY "created_at" DESC
        LIMIT 1
        ''',
        parameters: QueryParameters.named({'uid': userId}),
      );
      if (pendingRows.isNotEmpty) {
        final row = pendingRows.first;
        final createdAt = row[7];
        String createdAtStr = '';
        if (createdAt != null) {
          final dt = _safeDateTime(createdAt);
          if (dt != null) {
            createdAtStr = dt.toIso8601String();
          } else {
            createdAtStr = createdAt.toString();
          }
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
      }

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
        if (dt != null) {
          createdAtStr = dt.toIso8601String();
        } else {
          createdAtStr = createdAt.toString();
        }
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
      session.log(
        'CinePass createDemandeResponsable',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Utilisateur connecté: indique s'il a déjà une demande responsable en attente.
  Future<bool> hasMyPendingDemandeResponsable(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return false;
    try {
      final rows = await session.db.unsafeQuery(
        r'''
        SELECT 1
        FROM "cine_pass_responsable_request"
        WHERE "user_id" = (@uid)::uuid AND "status" = 'PENDING'
        LIMIT 1
        ''',
        parameters: QueryParameters.named({'uid': userId}),
      );
      return rows.isNotEmpty;
    } catch (e, st) {
      session.log(
        'CinePass hasMyPendingDemandeResponsable',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Client: annuler sa réservation événement si >= 2h avant le début.
  Future<bool> cancelMyEventReservation(
    Session session, {
    required String reservationNumber,
  }) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return false;
    final numero = reservationNumber.trim();
    if (numero.isEmpty) return false;
    try {
      final rows = await session.db.unsafeQuery(
        r'''
        SELECT "id", "session_at", "statut", "evenement_id"
        FROM "cine_pass_reservation"
        WHERE "user_id" = (@uid)::uuid
          AND "numero" = @numero
        LIMIT 1
        FOR UPDATE
        ''',
        parameters: QueryParameters.named({'uid': userId, 'numero': numero}),
      );
      if (rows.isEmpty) return false;
      final reservationId = rows.first[0].toString();
      final sessionAt = _safeDateTime(rows.first[1]);
      final statut = (rows.first[2] as String?)?.toLowerCase() ?? 'pending';
      final evenementId = rows.first[3];

      if (evenementId == null) return false; // règle demandée: événements
      if (statut != 'paid') return false;
      if (sessionAt == null) return false;

      final now = DateTime.now();
      final latestCancelable = sessionAt.subtract(const Duration(hours: 2));
      if (now.isAfter(latestCancelable)) return false;

      await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_reservation"
        SET "statut" = 'cancelled', "updated_at" = now()
        WHERE "id" = (@rid)::uuid
        ''',
        parameters: QueryParameters.named({'rid': reservationId}),
      );
      return true;
    } catch (e, st) {
      session.log(
        'CinePass cancelMyEventReservation',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Admin: toutes les réservations (événements et séances).
  Future<List<ReservationResponse>> getReservations(Session session) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('getReservations refuse: admin requis');
        return [];
      }
      final result = await session.db.unsafeQuery(
        r'''
        SELECT r."id", r."numero", r."total_amount", r."created_at", r."statut",
               COALESCE(e."titre", f."titre") AS display_title,
               CASE
                 WHEN e."id" IS NOT NULL THEN
                   TRIM(CONCAT(COALESCE(e."lieu", ''), ' — ', COALESCE(e."ville", '')))
                 ELSE
                   TRIM(CONCAT(COALESCE(c."nom", ''), ' — ', COALESCE(sal."nom", '')))
               END AS location_label,
               CASE
                 WHEN e."id" IS NOT NULL THEN
                   to_char(e."eventDate", 'DD/MM/YYYY') || ' ' || to_char(e."eventTime", 'HH24:MI')
                 ELSE
                   to_char(se."debutAt", 'DD/MM/YYYY HH24:MI')
               END AS session_at,
               (SELECT COUNT(*)::int FROM "cine_pass_billet" b WHERE b."reservation_id" = r."id") AS nb_billets,
               p."email" AS user_email
        FROM "cine_pass_reservation" r
        LEFT JOIN "cine_pass_evenement" e ON e."id" = r."evenement_id"
        LEFT JOIN "cine_pass_seance" se ON se."id" = r."seance_id"
        LEFT JOIN "cine_pass_film" f ON f."id" = se."filmId"
        LEFT JOIN "cine_pass_salle" sal ON sal."id" = se."salleId"
        LEFT JOIN "cine_pass_cinema" c ON c."id" = sal."cinemaId"
        LEFT JOIN "serverpod_auth_core_profile" p ON p."authUserId" = r."user_id"
        ORDER BY r."created_at" DESC
        ''',
      );
      return result.map((row) => _rowToReservationResponse(row)).toList();
    } catch (e, st) {
      session.log(
        'CinePass getReservations',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Responsable: réservations pour les événements de ses structures.
  Future<List<ReservationResponse>> getReservationsForMyStructures(
    Session session,
  ) async {
    try {
      final userId = session.authenticated?.userIdentifier;
      if (userId == null) {
        return [];
      }
      final result = await session.db.unsafeQuery(
        r'''
        SELECT r."id", r."numero", r."total_amount", r."created_at", r."statut",
               e."titre" AS display_title,
               TRIM(CONCAT(COALESCE(e."lieu", ''), ' — ', COALESCE(e."ville", ''))) AS location_label,
               to_char(e."eventDate", 'DD/MM/YYYY') || ' ' || to_char(e."eventTime", 'HH24:MI') AS session_at,
               (SELECT COUNT(*)::int FROM "cine_pass_billet" b WHERE b."reservation_id" = r."id") AS nb_billets,
               p."email" AS user_email
        FROM "cine_pass_reservation" r
        JOIN "cine_pass_evenement" e ON e."id" = r."evenement_id"
        LEFT JOIN "serverpod_auth_core_profile" p ON p."authUserId" = r."user_id"
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
      session.log(
        'CinePass getReservationsForMyStructures',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Admin/Responsable: archiver un événement (retire des listings futurs).
  Future<bool> archiveEvent(Session session, String eventId) async {
    try {
      final eid = _normalizeClientEventId(eventId);
      if (eid == null) return false;
      final isAdmin = await _isAdmin(session);
      if (!isAdmin) {
        final assigned = await _responsableStructureIds(session);
        if (assigned.isEmpty) return false;
        final targetRows = await session.db.unsafeQuery(
          r'''SELECT "structureId" FROM "cine_pass_evenement" WHERE "id" = (@id)::uuid''',
          parameters: QueryParameters.named({'id': eid}),
        );
        final targetStructureId = _eventStructureIdFromRow(targetRows);
        if (targetStructureId == null ||
            !_assignedHasStructure(assigned, targetStructureId)) {
          session.log(
            'archiveEvent refuse: structure hors perimetre responsable (structureId=$targetStructureId)',
          );
          return false;
        }
      }

      final upd = await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_evenement" AS e
        SET "archived" = true
        FROM (
          SELECT "titre", "categorie", "structureId"
          FROM "cine_pass_evenement"
          WHERE "id" = (@id)::uuid
        ) AS ref
        WHERE LOWER(TRIM(e."titre")) = LOWER(TRIM(ref."titre"))
          AND LOWER(TRIM(e."categorie")) = LOWER(TRIM(ref."categorie"))
          AND e."structureId" IS NOT DISTINCT FROM ref."structureId"
        RETURNING e."id"
        ''',
        parameters: QueryParameters.named({'id': eid}),
      );
      return upd.isNotEmpty;
    } catch (e, st) {
      session.log(
        'CinePass archiveEvent',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Admin/Responsable: désarchiver un événement (réaffiche au catalogue public).
  Future<bool> unarchiveEvent(Session session, String eventId) async {
    try {
      final eid = _normalizeClientEventId(eventId);
      if (eid == null) return false;
      final isAdmin = await _isAdmin(session);
      if (!isAdmin) {
        final assigned = await _responsableStructureIds(session);
        if (assigned.isEmpty) return false;
        final targetRows = await session.db.unsafeQuery(
          r'''SELECT "structureId" FROM "cine_pass_evenement" WHERE "id" = (@id)::uuid''',
          parameters: QueryParameters.named({'id': eid}),
        );
        final targetStructureId = _eventStructureIdFromRow(targetRows);
        if (targetStructureId == null ||
            !_assignedHasStructure(assigned, targetStructureId)) {
          session.log(
            'unarchiveEvent refuse: structure hors perimetre responsable (structureId=$targetStructureId)',
          );
          return false;
        }
      }

      final upd = await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_evenement" AS e
        SET "archived" = false
        FROM (
          SELECT "titre", "categorie", "structureId"
          FROM "cine_pass_evenement"
          WHERE "id" = (@id)::uuid
        ) AS ref
        WHERE LOWER(TRIM(e."titre")) = LOWER(TRIM(ref."titre"))
          AND LOWER(TRIM(e."categorie")) = LOWER(TRIM(ref."categorie"))
          AND e."structureId" IS NOT DISTINCT FROM ref."structureId"
        RETURNING e."id"
        ''',
        parameters: QueryParameters.named({'id': eid}),
      );
      return upd.isNotEmpty;
    } catch (e, st) {
      session.log(
        'CinePass unarchiveEvent',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Responsable: détails billets d'une réservation de ses structures.
  Future<List<String>> getReservationBilletDetailsForMyStructures(
    Session session, {
    required String reservationId,
  }) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return [];
    try {
      final scopeRows = await session.db.unsafeQuery(
        r'''
        SELECT 1
        FROM "cine_pass_reservation" r
        JOIN "cine_pass_evenement" e ON e."id" = r."evenement_id"
        WHERE r."id" = (@rid)::uuid
          AND e."structureId" IN (
            SELECT a."structure_id"
            FROM "cine_pass_responsable_assignment" a
            WHERE a."user_id" = (@uid)::uuid AND a."active" = true
          )
        LIMIT 1
        ''',
        parameters: QueryParameters.named({
          'rid': reservationId,
          'uid': userId,
        }),
      );
      if (scopeRows.isEmpty) return [];

      final rows = await session.db.unsafeQuery(
        r'''
        SELECT b."ticket_type", b."prix", b."placement_label", sg."rangee", sg."numero"
        FROM "cine_pass_billet" b
        LEFT JOIN "cine_pass_siege" sg ON sg."id" = b."siege_id"
        WHERE b."reservation_id" = (@rid)::uuid
        ORDER BY b."created_at" ASC
        ''',
        parameters: QueryParameters.named({'rid': reservationId}),
      );
      final lines = <String>[];
      for (final row in rows) {
        final type = (row[0] as String?) ?? 'normal';
        final price = _safeDouble(row[1]).toStringAsFixed(2);
        final placement = (row[2] as String?)?.trim() ?? '';
        final rangee = row[3]?.toString();
        final numero = row[4];
        String seat = '';
        if (placement.isNotEmpty) {
          seat = placement;
        } else if (rangee != null && rangee.isNotEmpty && numero != null) {
          seat = '$rangee${_safeInt(numero)}';
        }
        lines.add(
          'Type: ${type.toUpperCase()} • Prix: $price €${seat.isNotEmpty ? ' • Place: $seat' : ''}',
        );
      }
      return lines;
    } catch (e, st) {
      session.log(
        'CinePass getReservationBilletDetailsForMyStructures',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Responsable: changement de statut d'une réservation de ses structures.
  Future<bool> updateReservationStatusForMyStructures(
    Session session, {
    required String reservationId,
    required String status,
  }) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return false;
    final normalized = status.trim().toLowerCase();
    const allowed = {'pending', 'paid', 'cancelled', 'refunded'};
    if (!allowed.contains(normalized)) return false;
    try {
      final scopeRows = await session.db.unsafeQuery(
        r'''
        SELECT 1
        FROM "cine_pass_reservation" r
        JOIN "cine_pass_evenement" e ON e."id" = r."evenement_id"
        WHERE r."id" = (@rid)::uuid
          AND e."structureId" IN (
            SELECT a."structure_id"
            FROM "cine_pass_responsable_assignment" a
            WHERE a."user_id" = (@uid)::uuid AND a."active" = true
          )
        LIMIT 1
        ''',
        parameters: QueryParameters.named({
          'rid': reservationId,
          'uid': userId,
        }),
      );
      if (scopeRows.isEmpty) return false;

      await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_reservation"
        SET "statut" = @status, "updated_at" = now()
        WHERE "id" = (@rid)::uuid
        ''',
        parameters: QueryParameters.named({
          'rid': reservationId,
          'status': normalized,
        }),
      );
      return true;
    } catch (e, st) {
      session.log(
        'CinePass updateReservationStatusForMyStructures',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Responsable: rapport CA sur une période (7j, 30j, 3m, 1an).
  Future<RapportCAResponse> getRapportCA(
    Session session,
    String periode,
  ) async {
    try {
      final userId = session.authenticated?.userIdentifier;
      if (userId == null) {
        return RapportCAResponse(totalCA: 0, nbReservations: 0);
      }
      String intervalExpr = "interval '30 days'";
      if (periode == '7j') {
        intervalExpr = "interval '7 days'";
      } else if (periode == '3m') {
        intervalExpr = "interval '3 months'";
      } else if (periode == '1an') {
        intervalExpr = "interval '1 year'";
      }
      final result = await session.db.unsafeQuery(
        '''
        SELECT COALESCE(SUM(r."total_amount"), 0)::double precision AS total, COUNT(r."id")::int AS nb
        FROM "cine_pass_reservation" r
        JOIN "cine_pass_evenement" e ON e."id" = r."evenement_id"
        WHERE e."structureId" IN (
          SELECT a."structure_id" FROM "cine_pass_responsable_assignment" a
          WHERE a."user_id" = (@uid)::uuid AND a."active" = true
        )
        AND r."created_at" >= now() - $intervalExpr
        '''
            .replaceAll(r'$intervalExpr', intervalExpr),
        parameters: QueryParameters.named({'uid': userId}),
      );
      if (result.isEmpty) {
        return RapportCAResponse(totalCA: 0, nbReservations: 0);
      }
      final row = result.first;
      final total = row[0] is num ? (row[0] as num).toDouble() : 0.0;
      final nb = row.length > 1 ? _safeInt(row[1]) : 0;
      return RapportCAResponse(totalCA: total, nbReservations: nb);
    } catch (e, st) {
      session.log(
        'CinePass getRapportCA',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
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
      session.log(
        'CinePass createSeance',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
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

  static String? _formatDateFr(dynamic v) {
    final d = _safeDateTime(v);
    if (d == null) {
      return null;
    }
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
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
      posterUrl: row.length > 8 ? row[8] as String? : null,
      dateSortieStr: row.length > 9 ? _formatDateFr(row[9]) : null,
      dateFinStr: row.length > 10 ? _formatDateFr(row[10]) : null,
      audience: row.length > 11 ? row[11] as String? : null,
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
    final posterUrl = row.length > 12 ? row[12] as String? : null;
    final optionsJson = row.length > 13 ? row[13] : null;
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
      final td = _safeDateTime(time);
      if (td != null) {
        timeStr =
            '${td.hour.toString().padLeft(2, '0')}:${td.minute.toString().padLeft(2, '0')}';
      } else {
        final s = time.toString();
        final hm = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(s);
        if (hm != null) {
          timeStr = '${hm.group(1)!.padLeft(2, '0')}:${hm.group(2)}';
        }
      }
    }
    final price = row.length > 10 ? _safeDouble(row[10]) : 0.0;
    final posterColor = row.length > 11 && row[11] != null
        ? _safeInt(row[11])
        : null;
    double? priceFrom;
    double? priceTo;
    String? reservationMode;
    if (row.length > 25 && row[25] != null) {
      priceFrom = _safeDouble(row[25]);
    }
    if (row.length > 26 && row[26] != null) {
      priceTo = _safeDouble(row[26]);
    }
    if (row.length > 27 && row[27] != null) {
      final m = row[27].toString().trim();
      reservationMode = m.isEmpty ? null : m;
    }
    String? structureName;
    if (row.length > 28 && row[28] != null) {
      final sn = row[28].toString().trim();
      structureName = sn.isEmpty ? null : sn;
    }
    var ticketsSold = 0;
    bool? archived;
    if (row.length >= 31) {
      ticketsSold = _safeInt(row[29]);
      final v = row[30];
      if (v is bool) {
        archived = v;
      } else if (v != null) {
        archived = v.toString().toLowerCase() == 'true';
      }
    } else if (row.length > 29) {
      final v = row[29];
      if (v is bool) {
        archived = v;
      } else if (v != null) {
        archived = v.toString().toLowerCase() == 'true';
      }
    }
    final placesLeft = (placesTotal - ticketsSold).clamp(
      0,
      placesTotal > 0 ? placesTotal : 0,
    );

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
      placesLeft: placesLeft,
      placesTotal: placesTotal,
      price: price,
      posterColor: posterColor,
      availableOptions: options,
      posterUrl: posterUrl,
      priceFrom: priceFrom,
      priceTo: priceTo,
      reservationMode: reservationMode,
      eventType: row.length > 14 ? row[14] as String? : null,
      eventSubtype: row.length > 15 ? row[15] as String? : null,
      customTypeLabel: row.length > 16 ? row[16] as String? : null,
      eventLanguage: row.length > 17 ? row[17] as String? : null,
      filmGenre: row.length > 18 ? row[18] as String? : null,
      filmDirector: row.length > 19 ? row[19] as String? : null,
      festivalTheme: row.length > 20 ? row[20] as String? : null,
      standupMainArtist: row.length > 21 ? row[21] as String? : null,
      concertArtist: row.length > 22 ? row[22] as String? : null,
      concertMusicGenre: row.length > 23 ? row[23] as String? : null,
      theatreAuthor: row.length > 24 ? row[24] as String? : null,
      structureName: structureName,
      archived: archived,
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

  static DemandeResponsableResponse _rowToDemandeResponsableResponse(
    List<dynamic> row,
  ) {
    // Ordre SELECT getDemandesEnAttente (17 colonnes).
    final createdAt = row.length > 14 ? row[14] : null;
    String createdAtStr = '';
    if (createdAt != null) {
      final dt = _safeDateTime(createdAt);
      if (dt != null) {
        createdAtStr = dt.toIso8601String();
      } else {
        createdAtStr = createdAt.toString();
      }
    }
    String? pickStr(int i) =>
        row.length > i && row[i] != null ? row[i].toString().trim() : null;
    final displayName = pickStr(15);
    final accountEmail = pickStr(16);
    final userName = [
      if (displayName != null && displayName.isNotEmpty) displayName,
      if (accountEmail != null && accountEmail.isNotEmpty) accountEmail,
    ].join(' · ');
    return DemandeResponsableResponse(
      id: row[0].toString(),
      userId: row.length > 1 ? row[1].toString() : '',
      structureType: row.length > 2 ? (row[2] as String?) ?? '' : '',
      structureName: row.length > 3 ? (row[3] as String?) ?? '' : '',
      structureCity: row.length > 4 ? (row[4] as String?) ?? '' : '',
      structureAddress: row.length > 5 ? row[5] as String? : null,
      structureWebsite: row.length > 6 ? row[6] as String? : null,
      structureSiret: row.length > 7 ? row[7] as String? : null,
      structurePhone: row.length > 8 ? row[8] as String? : null,
      contactRole: row.length > 9 ? row[9] as String? : null,
      description: row.length > 10 ? row[10] as String? : null,
      socialLinks: row.length > 11 ? row[11] as String? : null,
      professionalEmail: row.length > 12 ? row[12] as String? : null,
      status: row.length > 13 ? (row[13] as String?) ?? 'PENDING' : 'PENDING',
      createdAt: createdAtStr,
      userName: userName.isEmpty ? null : userName,
      userEmail: (accountEmail == null || accountEmail.isEmpty)
          ? null
          : accountEmail,
    );
  }

  static Structure _rowToStructure(List<dynamic> row) {
    return Structure(
      id: UuidValue.fromString(row[0].toString()),
      type: row.length > 1 ? (row[1] as String?) ?? '' : '',
      name: row.length > 2 ? (row[2] as String?) ?? '' : '',
      city: row.length > 3 ? (row[3] as String?) ?? '' : '',
      address: row.length > 4 ? row[4] as String? : null,
      website: row.length > 5 ? row[5] as String? : null,
      phone: row.length > 6 ? row[6] as String? : null,
      cinemaId: row.length > 7 && row[7] != null
          ? UuidValue.fromString(row[7].toString())
          : null,
    );
  }

  static ReservationResponse _rowToReservationResponse(List<dynamic> row) {
    final createdAt = row.length > 3 ? row[3] : null;
    String createdAtStr = '';
    if (createdAt != null) {
      final dt = _safeDateTime(createdAt);
      if (dt != null) {
        createdAtStr = dt.toIso8601String();
      } else {
        createdAtStr = createdAt.toString();
      }
    }
    final totalAmount = row.length > 2 ? _safeDouble(row[2]) : 0.0;
    final statut = row.length > 4
        ? (row[4] as String?) ?? 'pending'
        : 'pending';

    // Nouveau format : 10 colonnes (titre, lieu, séance, nb billets, email).
    if (row.length >= 10) {
      final loc = row[6] as String?;
      final sess = row[7] as String?;
      return ReservationResponse(
        id: row[0].toString(),
        numero: row.length > 1 ? (row[1] as String?) ?? '' : '',
        eventTitle: row.length > 5 ? row[5] as String? : null,
        totalAmount: totalAmount,
        createdAtStr: createdAtStr,
        statut: statut,
        nbBillets: _safeInt(row[8]),
        userEmail: row.length > 9 ? row[9] as String? : null,
        locationLabel: (loc == null || loc.trim().isEmpty || loc.trim() == '—')
            ? null
            : loc,
        sessionAtStr: (sess == null || sess.trim().isEmpty)
            ? null
            : sess.trim(),
      );
    }

    // Ancien format (compat).
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
      userEmail: null,
      locationLabel: null,
      sessionAtStr: null,
    );
  }

  /// Profil de l'utilisateur connecté (displayName, phone, birthDate).
  /// Retourne null si non authentifié.
  Future<ProfileResponse?> getProfile(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return null;
    try {
      final profileRows = await session.db.unsafeQuery(
        r'''
        SELECT "display_name", "phone", "birth_date"
        FROM "cine_pass_user_profile"
        WHERE "user_id" = (@uid)::uuid
        ''',
        parameters: QueryParameters.named({'uid': userId}),
      );
      String? email;
      String? fullName;
      try {
        // NOTE: `serverpod_auth_core_user` doesn't store email. It's on `serverpod_auth_core_profile`.
        final authProfileRows = await session.db.unsafeQuery(
          r'''
          SELECT "fullName", "userName", "email"
          FROM "serverpod_auth_core_profile"
          WHERE "authUserId" = (@uid)::uuid
          ''',
          parameters: QueryParameters.named({'uid': userId}),
        );
        if (authProfileRows.isNotEmpty && authProfileRows.first.isNotEmpty) {
          final row = authProfileRows.first;
          fullName = row.isNotEmpty ? row[0] as String? : null;
          final userName = row.length > 1 ? row[1] as String? : null;
          email = row.length > 2 ? row[2] as String? : null;
          fullName ??= userName;
        }
      } catch (_) {}
      if (profileRows.isEmpty) {
        return ProfileResponse(
          displayName: fullName,
          email: email,
          phone: null,
          birthDate: null,
        );
      }
      final row = profileRows.first;
      final birthDate = row.length > 2 && row[2] != null
          ? (row[2] is DateTime
                ? (row[2] as DateTime).toIso8601String().substring(0, 10)
                : row[2].toString().length >= 10
                ? row[2].toString().substring(0, 10)
                : row[2].toString())
          : null;
      return ProfileResponse(
        displayName: (row.isNotEmpty ? row[0] as String? : null) ?? fullName,
        email: email,
        phone: row.length > 1 ? row[1] as String? : null,
        birthDate: birthDate,
      );
    } catch (e, st) {
      session.log(
        'CinePass getProfile',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Admin: liste des utilisateurs (profil auth + téléphone/date locale si disponible).
  Future<List<ProfileResponse>> getAdminUsers(Session session) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('getAdminUsers refuse: admin requis');
        return [];
      }
      final rows = await session.db.unsafeQuery(
        r'''
        SELECT p."authUserId",
               p."fullName", p."email", up."phone", up."birth_date",
               COALESCE(ur."role", 'client') AS role,
               CASE
                 WHEN COALESCE(ur."role", 'client') = 'admin' THEN true
                 WHEN COALESCE(ur."role", 'client') = 'responsable' THEN COALESCE(ru."active", true)
                 ELSE true
               END AS active,
               u."createdAt" AS created_at
        FROM "serverpod_auth_core_profile" p
        LEFT JOIN "cine_pass_user_profile" up ON up."user_id" = p."authUserId"
        LEFT JOIN "cine_pass_user_role" ur ON ur."user_id" = p."authUserId"
        LEFT JOIN "cine_pass_responsable_user" ru ON ru."user_id" = p."authUserId"
        LEFT JOIN "serverpod_auth_core_user" u ON u."id" = p."authUserId"
        ORDER BY COALESCE(p."fullName", p."email", '') ASC
        ''',
      );
      return rows.map((row) {
        final birth = row.length > 4 && row[4] != null
            ? (row[4] is DateTime
                  ? (row[4] as DateTime).toIso8601String().substring(0, 10)
                  : row[4].toString())
            : null;
        final createdAt = row.length > 7 && row[7] != null
            ? (row[7] is DateTime
                  ? (row[7] as DateTime).toIso8601String()
                  : row[7].toString())
            : null;
        return ProfileResponse(
          userId: row.isNotEmpty ? row[0].toString() : null,
          displayName: row.length > 1 ? row[1] as String? : null,
          email: row.length > 2 ? row[2] as String? : null,
          phone: row.length > 3 ? row[3] as String? : null,
          birthDate: birth,
          role: row.length > 5 ? row[5] as String? : 'client',
          active: row.length > 6 ? row[6] as bool? : true,
          createdAt: createdAt,
        );
      }).toList();
    } catch (e, st) {
      session.log(
        'CinePass getAdminUsers',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Admin: modifier le rôle d'un utilisateur.
  Future<bool> setAdminUserRole(
    Session session, {
    required String userId,
    required String role,
  }) async {
    if (!await _isAdmin(session)) return false;
    final normalized = _normalizeUserRole(role);
    try {
      // Pas de contrainte UNIQUE sur user_id dans toutes les bases → upsert explicite.
      await session.db.unsafeQuery(
        r'''DELETE FROM "cine_pass_user_role" WHERE "user_id" = (@uid)::uuid''',
        parameters: QueryParameters.named({'uid': userId}),
      );
      await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_user_role" ("user_id", "role")
        VALUES ((@uid)::uuid, @role)
        ''',
        parameters: QueryParameters.named({'uid': userId, 'role': normalized}),
      );
      if (normalized == 'admin') {
        await session.db.unsafeQuery(
          r'''
          INSERT INTO "cine_pass_admin_user" ("user_id")
          VALUES ((@uid)::uuid)
          ON CONFLICT ("user_id") DO NOTHING
          ''',
          parameters: QueryParameters.named({'uid': userId}),
        );
        await session.db.unsafeQuery(
          r'''DELETE FROM "cine_pass_responsable_user" WHERE "user_id" = (@uid)::uuid''',
          parameters: QueryParameters.named({'uid': userId}),
        );
      } else if (normalized == 'responsable') {
        await session.db.unsafeQuery(
          r'''DELETE FROM "cine_pass_admin_user" WHERE "user_id" = (@uid)::uuid''',
          parameters: QueryParameters.named({'uid': userId}),
        );
        await session.db.unsafeQuery(
          r'''
          INSERT INTO "cine_pass_responsable_user" ("user_id", "active")
          VALUES ((@uid)::uuid, true)
          ON CONFLICT ("user_id") DO UPDATE
          SET "active" = true, "updated_at" = now()
          ''',
          parameters: QueryParameters.named({'uid': userId}),
        );
      } else {
        await session.db.unsafeQuery(
          r'''DELETE FROM "cine_pass_admin_user" WHERE "user_id" = (@uid)::uuid''',
          parameters: QueryParameters.named({'uid': userId}),
        );
        await session.db.unsafeQuery(
          r'''
          UPDATE "cine_pass_responsable_user"
          SET "active" = false, "updated_at" = now()
          WHERE "user_id" = (@uid)::uuid
          ''',
          parameters: QueryParameters.named({'uid': userId}),
        );
        await session.db.unsafeQuery(
          r'''
          UPDATE "cine_pass_responsable_assignment"
          SET "active" = false
          WHERE "user_id" = (@uid)::uuid
          ''',
          parameters: QueryParameters.named({'uid': userId}),
        );
      }
      return true;
    } catch (e, st) {
      session.log(
        'CinePass setAdminUserRole',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Admin: supprimer un utilisateur.
  Future<bool> deleteAdminUser(
    Session session, {
    required String userId,
  }) async {
    if (!await _isAdmin(session)) return false;
    final me = session.authenticated?.userIdentifier;
    if (me != null && me == userId) return false;
    try {
      await session.db.unsafeQuery(
        r'''DELETE FROM "serverpod_auth_core_user" WHERE "id" = (@uid)::uuid''',
        parameters: QueryParameters.named({'uid': userId}),
      );
      return true;
    } catch (e, st) {
      session.log(
        'CinePass deleteAdminUser',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Met à jour le profil de l'utilisateur connecté.
  /// Seuls les champs non null sont mis à jour.
  Future<bool> updateProfile(
    Session session, {
    String? displayName,
    String? phone,
    String? birthDate,
  }) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return false;
    try {
      final existing = await session.db.unsafeQuery(
        r'SELECT "display_name", "phone", "birth_date" FROM "cine_pass_user_profile" WHERE "user_id" = (@uid)::uuid',
        parameters: QueryParameters.named({'uid': userId}),
      );
      String? d = displayName;
      String? p = phone;
      String? b = birthDate;
      if (existing.isNotEmpty) {
        final row = existing.first;
        if (d == null && row.isNotEmpty) d = row[0] as String?;
        if (p == null && row.length > 1) p = row[1] as String?;
        if (b == null && row.length > 2 && row[2] != null) {
          final v = row[2];
          b = v is DateTime
              ? v.toIso8601String().substring(0, 10)
              : v.toString();
        }
      }
      final birthDateParsed = b != null && b.isNotEmpty
          ? DateTime.tryParse(b)
          : null;
      await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_user_profile" ("user_id", "display_name", "phone", "birth_date")
        VALUES ((@uid)::uuid, @displayName, @phone, @birthDate)
        ON CONFLICT ("user_id") DO UPDATE SET
          "display_name" = EXCLUDED."display_name",
          "phone" = EXCLUDED."phone",
          "birth_date" = EXCLUDED."birth_date"
        ''',
        parameters: QueryParameters.named({
          'uid': userId,
          'displayName': d,
          'phone': p,
          'birthDate': birthDateParsed,
        }),
      );
      return true;
    } catch (e, st) {
      session.log(
        'CinePass updateProfile',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  static (String, int)? _parseSeatLabel(String seatLabel) {
    // Expected formats: "A12", "B7", "AA10"
    final s = seatLabel.trim();
    if (s.isEmpty) return null;
    final match = RegExp(r'^([A-Za-z]+)\s*([0-9]+)$').firstMatch(s);
    if (match == null) return null;
    final row = match.group(1)!.toUpperCase();
    final num = int.tryParse(match.group(2)!) ?? 0;
    if (num <= 0) return null;
    return (row, num);
  }

  static String _formatDateTimeLabel(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy à $hh:$min';
  }
}
