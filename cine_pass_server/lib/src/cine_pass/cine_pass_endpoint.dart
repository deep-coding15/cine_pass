import 'package:serverpod/serverpod.dart';
import '../generated/billet_group_response.dart';
import '../generated/film_response.dart';
import '../generated/seance_response.dart';
import '../generated/event_response.dart';
import '../generated/cinema_response.dart';
import '../generated/demande_responsable_response.dart';
import '../generated/reservation_response.dart';
import '../generated/rapport_ca_response.dart';
import '../generated/profile_response.dart';
import '../generated/salle.dart';

import '../generated/structure.dart';

/// Taux de commission CinePass sur chaque réservation (en %).
/// Ex. : 8.0 = 8 % du montant du billet gardé par la plateforme.
/// Voir docs/MONETISATION_STRATEGIE.md.
const double cinePassCommissionPercent = 8.0;

/// Endpoint CinePass : films, séances, cinémas, événements (données BDD).
class CinePassEndpoint extends Endpoint {
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
      final numero = (reservationNumber != null && reservationNumber.trim().isNotEmpty)
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
        final seatLabel =
            (!isEvent && i < seatLabels.length) ? seatLabels[i] : null;
        String? siegeId;
        if (!isEvent && seatLabel != null && seatLabel.isNotEmpty && salleId != null) {
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

        final tType = ticketTypes[i].trim().toLowerCase() == 'vip' ? 'vip' : 'normal';
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
               r."session_at", r."created_at",
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
        final total = row[2] is num ? (row[2] as num).toDouble() : _safeDouble(row[2]);
        final isEvent = row[4] != null;

        DateTime sessionDt =
            _safeDateTime(row[5]) ?? _safeDateTime(row[11]) ?? DateTime.now();
        if (isEvent) {
          sessionDt =
              _safeDateTime(row[5]) ?? _safeDateTime(row[16]) ?? _safeDateTime(row[17]) ?? sessionDt;
        }

        final title = isEvent
            ? (row[12] as String?) ?? ''
            : (row[7] as String?) ?? '';
        final location = isEvent
            ? '${(row[13] as String?) ?? ''} - ${(row[14] as String?) ?? ''}'
            : '${(row[8] as String?) ?? ''} - ${(row[9] as String?) ?? ''}';
        final room = isEvent ? null : (row[10] as String?);
        final dateTimeLabel = _formatDateTimeLabel(sessionDt);

        final billetRows = await session.db.unsafeQuery(
          r'''
          SELECT b."ticket_type", sg."rangee", sg."numero"
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

  // ============================================================================
  // GESTION ROLES V2 (source unique: cine_pass_user_role)
  // ============================================================================
  // Status: 'actif' | 'inactif' | 'bloque' | 'banni'
  // Changement admin <-> responsable: demande + 2 approbations minimum.
  bool _userRoleTableEnsured = false;

  Future<void> _ensureUserRoleTable(Session session) async {
    if (_userRoleTableEnsured) return;
    await session.db.unsafeQuery(
      r'''
      CREATE TABLE IF NOT EXISTS "cine_pass_user_role" (
        "id"         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "user_id"    uuid NOT NULL,
        "role"       text NOT NULL DEFAULT 'CLIENT',
        "status"     text NOT NULL DEFAULT 'actif',
        "created_at" timestamp without time zone NOT NULL DEFAULT now(),
        "updated_at" timestamp without time zone NOT NULL DEFAULT now()
      )
      ''',
    );
    await session.db.unsafeQuery(
      r'''
      CREATE UNIQUE INDEX IF NOT EXISTS "cine_pass_user_role_user_role_uniq"
      ON "cine_pass_user_role" ("user_id", "role")
      ''',
    );
    _userRoleTableEnsured = true;
  }

  /// Récupère le statut d'un rôle pour un utilisateur.
  /// Retourne : 'actif', 'inactif', 'bloqué', 'banni', ou null si pas de rôle.
  Future<String?> _getRoleStatus(
    Session session, {
    required String userId,
    required String role,
  }) async {
    await _ensureUserRoleTable(session);
    final normalizedRole = role.toLowerCase().trim();

    final rows = await session.db.unsafeQuery(
      r'''
      SELECT "status"
      FROM "cine_pass_user_role"
      WHERE "user_id" = (@uid)::uuid AND "role" = @role
      LIMIT 1
      ''',
      parameters: QueryParameters.named({'uid': userId, 'role': normalizedRole}),
    );

    if (rows.isEmpty) return null;
    return rows.first[0]?.toString().toLowerCase();
  }

  /// Accorde un rôle avec un statut spécifique.
  /// Idempotent : met à jour le statut si le rôle existe déjà.
  Future<void> _grantUserRoleWithStatus(
    Session session, {
    required String userId,
    required String role,
    String status = 'actif',
  }) async {
    await _ensureUserRoleTable(session);
    final normalizedRole = role.toLowerCase().trim();
    final normalizedStatus = status.toLowerCase().trim();

    if (normalizedRole.isEmpty) return;

    await session.db.unsafeQuery(
      r'''
      INSERT INTO "cine_pass_user_role" ("user_id", "role", "status", "updated_at")
      VALUES ((@uid)::uuid, @role, @status, now())
      ON CONFLICT ("user_id", "role") DO UPDATE SET
        "status" = @status,
        "updated_at" = now()
      ''',
      parameters: QueryParameters.named({
        'uid': userId,
        'role': normalizedRole,
        'status': normalizedStatus,
      }),
    );
  }

  /// Change le statut d'un rôle (inactif, bloqué, banni, etc.).
  Future<void> _setRoleStatus(
    Session session, {
    required String userId,
    required String role,
    required String newStatus,
  }) async {
    await _ensureUserRoleTable(session);
    final normalizedRole = role.toLowerCase().trim();
    final normalizedStatus = newStatus.toLowerCase().trim();

    await session.db.unsafeQuery(
      r'''
      UPDATE "cine_pass_user_role"
      SET "status" = @status, "updated_at" = now()
      WHERE "user_id" = (@uid)::uuid AND "role" = @role
      ''',
      parameters: QueryParameters.named({
        'uid': userId,
        'role': normalizedRole,
        'status': normalizedStatus,
      }),
    );
  }

  /// Retire complètement un rôle (sauf 'client' qui ne peut pas être retiré).
  Future<void> _revokeUserRole(
    Session session, {
    required String userId,
    required String role,
  }) async {
    await _ensureUserRoleTable(session);
    final normalizedRole = role.toLowerCase().trim();

    // Ne jamais retirer 'client'
    if (normalizedRole == 'client') return;

    await session.db.unsafeQuery(
      r'''
      DELETE FROM "cine_pass_user_role"
      WHERE "user_id" = (@uid)::uuid AND "role" = @role
      ''',
      parameters: QueryParameters.named({'uid': userId, 'role': normalizedRole}),
    );
  }

  /// Récupère tous les rôles actifs de l'utilisateur.
  /// Seuls les rôles avec status='actif' sont retournés.
  Future<List<String>> _getUserRoles(
    Session session, {
    required String userId,
  }) async {
    await _ensureUserRoleTable(session);
    final roles = <String>{};

    // Lire uniquement depuis la source de verite (roles actifs).
    final roleRows = await session.db.unsafeQuery(
      r'''
      SELECT "role"
      FROM "cine_pass_user_role"
      WHERE "user_id" = (@uid)::uuid AND "status" = 'actif'
      ''',
      parameters: QueryParameters.named({'uid': userId}),
    );
    for (final row in roleRows) {
      final role = row[0]?.toString().toLowerCase() ?? '';
      if (role.isNotEmpty) roles.add(role);
    }

    // Garantir le role client au minimum.
    roles.add('client');
    await _grantUserRoleWithStatus(
      session,
      userId: userId,
      role: 'client',
      status: 'actif',
    );

    return roles.toList()..sort();
  }

  /// Crée une demande de changement de rôle critique (admin ↔ responsable).
  /// Retourne l'ID de la demande, ou null si erreur.
  /// Requiert 2 approbations minimum avant changement.
  Future<String?> _requestRoleChange(
    Session session, {
    required String userId,
    required String fromRole,
    required String toRole,
    required String requestedByUserId,
  }) async {
    try {
      await session.db.unsafeQuery(
        r'''
        CREATE TABLE IF NOT EXISTS "cine_pass_role_change_request" (
          "id"              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
          "user_id"         uuid NOT NULL,
          "from_role"       text NOT NULL,
          "to_role"         text NOT NULL,
          "requested_by"    uuid NOT NULL,
          "status"          text NOT NULL DEFAULT 'pending',
          "approvals_count" integer NOT NULL DEFAULT 0,
          "rejection_reason" text,
          "created_at"      timestamp without time zone NOT NULL DEFAULT now(),
          "expires_at"      timestamp without time zone NOT NULL DEFAULT (now() + interval '7 days')
        )
        ''',
      );

      final result = await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_role_change_request" (
          "user_id", "from_role", "to_role", "requested_by", "status", "approvals_count"
        )
        VALUES (
          (@uid)::uuid, @fromRole, @toRole, (@reqBy)::uuid, 'pending', 0
        )
        RETURNING "id"
        ''',
        parameters: QueryParameters.named({
          'uid': userId,
          'fromRole': fromRole.toLowerCase().trim(),
          'toRole': toRole.toLowerCase().trim(),
          'reqBy': requestedByUserId,
        }),
      );

      if (result.isEmpty) return null;
      return result.first[0].toString();
    } catch (e, st) {
      session.log(
        'CinePass _requestRoleChange',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Approuve une demande de changement rôle.
  /// Retourne true si approbation enregistrée et changement appliqué (si 2 approbations atteintes).
  Future<bool> _approveRoleChange(
    Session session, {
    required String changeRequestId,
    required String approverId,
  }) async {
    try {
      await session.db.unsafeQuery(
        r'''
        CREATE TABLE IF NOT EXISTS "cine_pass_role_change_approval" (
          "id"          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
          "change_id"   uuid NOT NULL,
          "approver_id" uuid NOT NULL,
          "approval_at" timestamp without time zone NOT NULL DEFAULT now()
        )
        ''',
      );

      // 1) Vérifier si la demande existe et est pending
      final reqRows = await session.db.unsafeQuery(
        r'''
        SELECT "user_id", "from_role", "to_role", "approvals_count", "status"
        FROM "cine_pass_role_change_request"
        WHERE "id" = (@id)::uuid
        LIMIT 1
        ''',
        parameters: QueryParameters.named({'id': changeRequestId}),
      );

      if (reqRows.isEmpty) return false;
      final reqRow = reqRows.first;
      final targetUserId = reqRow[0].toString();
      final fromRole = (reqRow[1] as String?)?.toLowerCase() ?? '';
      final toRole = (reqRow[2] as String?)?.toLowerCase() ?? '';
      final status = (reqRow[4] as String?)?.toLowerCase() ?? '';

      if (status != 'pending') return false;

      // 2) Ajouter l'approbation
      await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_role_change_approval" ("change_id", "approver_id")
        VALUES ((@changeId)::uuid, (@approverId)::uuid)
        ''',
        parameters: QueryParameters.named({
          'changeId': changeRequestId,
          'approverId': approverId,
        }),
      );

      // 3) Compter les approbations
      final approvalCount = await session.db.unsafeQuery(
        r'''
        SELECT COUNT(*)::integer
        FROM "cine_pass_role_change_approval"
        WHERE "change_id" = (@id)::uuid
        ''',
        parameters: QueryParameters.named({'id': changeRequestId}),
      );

      final newApprovalCount = _safeInt(approvalCount.first[0]);

      // 4) Si >= 2 approbations, appliquer le changement
      if (newApprovalCount >= 2) {
        // Retirer l'ancien rôle (sauf client)
        if (fromRole != 'client') {
          await _revokeUserRole(session, userId: targetUserId, role: fromRole);
        }

        // Accorder le nouveau rôle
        await _grantUserRoleWithStatus(session, userId: targetUserId, role: toRole, status: 'actif');

        // Marquer la demande comme approuvée
        await session.db.unsafeQuery(
          r'''
          UPDATE "cine_pass_role_change_request"
          SET "status" = 'approved', "approvals_count" = @count
          WHERE "id" = (@id)::uuid
          ''',
          parameters: QueryParameters.named({
            'id': changeRequestId,
            'count': newApprovalCount,
          }),
        );

        return true;
      } else {
        // Juste incrémenter le compteur
        await session.db.unsafeQuery(
          r'''
          UPDATE "cine_pass_role_change_request"
          SET "approvals_count" = @count
          WHERE "id" = (@id)::uuid
          ''',
          parameters: QueryParameters.named({
            'id': changeRequestId,
            'count': newApprovalCount,
          }),
        );

        return true; // Approbation enregistrée (mais changement pas encore appliqué)
      }
    } catch (e, st) {
      session.log(
        'CinePass _approveRoleChange',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Rejette une demande de changement rôle.
  Future<bool> _rejectRoleChange(
    Session session, {
    required String changeRequestId,
    required String reason,
  }) async {
    try {
      await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_role_change_request"
        SET "status" = 'rejected', "rejection_reason" = @reason
        WHERE "id" = (@id)::uuid
        ''',
        parameters: QueryParameters.named({
          'id': changeRequestId,
          'reason': reason,
        }),
      );
      return true;
    } catch (e, st) {
      session.log(
        'CinePass _rejectRoleChange',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Vérifie si l'utilisateur connecté est admin (rôle actif).
  Future<bool> _isAdmin(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return false;
    final roles = await _getUserRoles(session, userId: userId);
    return roles.contains('admin');
  }

  /// Vérifie si l'utilisateur connecté est responsable (rôle actif).
  Future<bool> _isResponsable(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return false;
    final roles = await _getUserRoles(session, userId: userId);
    return roles.contains('responsable');
  }

  /// Retourne les IDs des structures assignées au responsable connecté.
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
      return rows.map((r) => r[0].toString()).toList();
    } catch (_) {
      return [];
    }
  }

  /// Frontend: récupère tous les rôles actifs de l'utilisateur connecté.
  Future<List<String>> getUserRoles(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return ['guest'];
    try {
      return await _getUserRoles(session, userId: userId);
    } catch (e, st) {
      session.log(
        'CinePass getUserRoles',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return ['client'];
    }
  }

  /// Frontend: indique si l'utilisateur connecté est admin.
  Future<bool> isCurrentUserAdmin(Session session) async {
    return _isAdmin(session);
  }

  /// Frontend: indique si l'utilisateur connecté est responsable.
  Future<bool> isCurrentUserResponsable(Session session) async {
    return _isResponsable(session);
  }

  /// Admin: change le statut d'un rôle utilisateur (actif, inactif, bloqué, banni).
  Future<bool> setRoleStatus(
    Session session, {
    required String userEmail,
    required String role,
    required String newStatus,
  }) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('setRoleStatus refuse: admin requis');
        return false;
      }

      final normalizedEmail = userEmail.trim().toLowerCase();
      final normalizedRole = role.trim().toLowerCase();
      final normalizedStatus = newStatus.trim().toLowerCase();

      if (normalizedEmail.isEmpty || normalizedRole.isEmpty || normalizedStatus.isEmpty) {
        return false;
      }

      // Valider le statut
      const validStatuses = ['actif', 'inactif', 'bloqué', 'banni'];
      if (!validStatuses.contains(normalizedStatus)) {
        return false;
      }

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

      await _setRoleStatus(
        session,
        userId: userId,
        role: normalizedRole,
        newStatus: normalizedStatus,
      );

      return true;
    } catch (e, st) {
      session.log(
        'CinePass setRoleStatus',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Admin: crée une demande de changement de rôle critique (admin ↔ responsable).
  /// Retourne l'ID de la demande, ou null si erreur.
  /// Requiert 2 approbations minimum avant application.
  Future<String?> createRoleChangeRequest(
    Session session, {
    required String userEmail,
    required String toRole,
  }) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('createRoleChangeRequest refuse: admin requis');
        return null;
      }

      final normalizedEmail = userEmail.trim().toLowerCase();
      final normalizedToRole = toRole.trim().toLowerCase();

      if (normalizedEmail.isEmpty || normalizedToRole.isEmpty) return null;

      // Valider la transition
      const criticalRoles = ['admin', 'responsable'];
      if (!criticalRoles.contains(normalizedToRole)) return null;

      final userRows = await session.db.unsafeQuery(
        r'''
        SELECT "authUserId"
        FROM "serverpod_auth_core_profile"
        WHERE lower("email") = @email
        LIMIT 1
        ''',
        parameters: QueryParameters.named({'email': normalizedEmail}),
      );
      if (userRows.isEmpty) return null;
      final userId = userRows.first[0].toString();

      // Déterminer le rôle actuel (admin ou responsable)
      final currentRoles = await _getUserRoles(session, userId: userId);
      String fromRole = 'client';
      if (currentRoles.contains('admin')) {
        fromRole = 'admin';
      } else if (currentRoles.contains('responsable')) {
        fromRole = 'responsable';
      }

      // Créer la demande
      final adminId = session.authenticated?.userIdentifier;
      if (adminId == null) return null;

      final changeId = await _requestRoleChange(
        session,
        userId: userId,
        fromRole: fromRole,
        toRole: normalizedToRole,
        requestedByUserId: adminId,
      );

      return changeId;
    } catch (e, st) {
      session.log(
        'CinePass createRoleChangeRequest',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Admin: approuve une demande de changement de rôle.
  /// Retourne true si approbation enregistrée (changement appliqué si 2 approbations atteintes).
  Future<bool> approveRoleChangeRequest(
    Session session, {
    required String changeRequestId,
  }) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('approveRoleChangeRequest refuse: admin requis');
        return false;
      }

      final approverId = session.authenticated?.userIdentifier;
      if (approverId == null) return false;

      return await _approveRoleChange(
        session,
        changeRequestId: changeRequestId,
        approverId: approverId,
      );
    } catch (e, st) {
      session.log(
        'CinePass approveRoleChangeRequest',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Admin: rejette une demande de changement de rôle.
  Future<bool> rejectRoleChangeRequest(
    Session session, {
    required String changeRequestId,
    required String reason,
  }) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('rejectRoleChangeRequest refuse: admin requis');
        return false;
      }

      return await _rejectRoleChange(
        session,
        changeRequestId: changeRequestId,
        reason: reason,
      );
    } catch (e, st) {
      session.log(
        'CinePass rejectRoleChangeRequest',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Admin: simule une promotion directe (pour test/migration).
  /// N'utilise PAS le système de demande critique.
  /// À utiliser avec prudence (admin direct seulement).
  @Deprecated('Utiliser createRoleChangeRequest + approveRoleChangeRequest à la place')
  Future<bool> grantRoleByEmail(
    Session session, {
    required String email,
    required String role,
  }) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('grantRoleByEmail refuse: admin requis');
        return false;
      }

      final normalizedEmail = email.trim().toLowerCase();
      final normalizedRole = role.trim().toLowerCase();

      if (normalizedEmail.isEmpty || normalizedRole.isEmpty) return false;
      if (normalizedRole == 'guest' || normalizedRole == 'client') return false;

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

      // Accorder le role uniquement via le systeme v2.
      await _grantUserRoleWithStatus(
        session,
        userId: userId,
        role: normalizedRole,
        status: 'actif',
      );

      return true;
    } catch (e, st) {
      session.log(
        'CinePass grantRoleByEmail',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Admin: retire un rôle cote frontend en le bloquant en base.
  Future<bool> revokeRoleByEmail(
    Session session, {
    required String email,
    required String role,
  }) async {
    try {
      if (!await _isAdmin(session)) {
        session.log('revokeRoleByEmail refuse: admin requis');
        return false;
      }

      final normalizedEmail = email.trim().toLowerCase();
      final normalizedRole = role.trim().toLowerCase();

      if (normalizedEmail.isEmpty || normalizedRole.isEmpty) return false;
      if (normalizedRole == 'client') return false;

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

      // Un retrait frontend devient un blocage explicite en base.
      await _grantUserRoleWithStatus(
        session,
        userId: userId,
        role: normalizedRole,
        status: 'bloqué',
      );

      return true;
    } catch (e, st) {
      session.log(
        'CinePass revokeRoleByEmail',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Admin: récupère les rôles d'un utilisateur.
  Future<List<String>> getRolesByEmail(
    Session session, {
    required String email,
  }) async {
    try {
      if (!await _isAdmin(session)) {
        return [];
      }

      final normalizedEmail = email.trim().toLowerCase();
      if (normalizedEmail.isEmpty) return [];

      final userRows = await session.db.unsafeQuery(
        r'''
        SELECT "authUserId"
        FROM "serverpod_auth_core_profile"
        WHERE lower("email") = @email
        LIMIT 1
        ''',
        parameters: QueryParameters.named({'email': normalizedEmail}),
      );
      if (userRows.isEmpty) return [];
      final userId = userRows.first[0].toString();

      return await _getUserRoles(session, userId: userId);
    } catch (e, st) {
      session.log(
        'CinePass getRolesByEmail',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
    }
  }

  /// Liste de tous les films.
  Future<List<FilmResponse>> getFilms(Session session) async {
    try {
      final result = await session.db.unsafeQuery(
        r'''
        SELECT "id", "titre", "genre", "dureeMinutes", "synopsis", "directeur",
               "casting", "posterColor", "posterUrl"
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
               "casting", "posterColor", "posterUrl"
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
      SELECT "id", "titre", "categorie", "description", "lieu", "adresse", "ville",
             "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor", "posterUrl", "availableOptions"
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
             "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor", "posterUrl", "availableOptions"
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
    required Object eventDate,
    required String eventTimeStr,
    required int placesTotal,
    required double prixBase,
    int? posterColor,
      String? posterUrl,
    String? structureId,
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
          session.log('createEvent refuse: utilisateur non admin/non responsable');
          return null;
        }

        if (effectiveStructureId == null) {
          effectiveStructureId = assigned.first;
        } else if (!assigned.contains(effectiveStructureId)) {
          session.log('createEvent refuse: structure hors perimetre responsable');
          return null;
        }
      }

      final eventDateDt = _parseDateTime(eventDate);
      if (eventDateDt == null) {
        return null;
      }
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
      final result = await session.db.unsafeQuery(
        r'''
        INSERT INTO "cine_pass_evenement" (
          "titre", "categorie", "description", "lieu", "adresse", "ville",
          "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor",
          "posterUrl", "structureId"
        )
        VALUES (
          @titre, @categorie, @description, @lieu, @adresse, @ville,
          @eventDate, @eventTime, @placesTotal, @prixBase, @posterColor,
          @posterUrl,
          CASE WHEN @structureId::text = '' OR @structureId IS NULL THEN NULL ELSE (@structureId)::uuid END
        )
        RETURNING "id", "titre", "categorie", "description", "lieu", "adresse", "ville",
                  "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor",
                  "posterUrl", "availableOptions"
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
          'posterUrl': posterUrl,
          'structureId': effectiveStructureId ?? '',
        }),
      );
      if (result.isEmpty) return null;
      return _rowToEventResponse(result.first);
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
    Object? eventDate,
    String? eventTimeStr,
    int? placesTotal,
    double? prixBase,
    int? posterColor,
      String? posterUrl,
    }) async {
    try {
      final isAdmin = await _isAdmin(session);
      if (!isAdmin) {
        final assigned = await _responsableStructureIds(session);
        if (assigned.isEmpty) return null;
        final targetRows = await session.db.unsafeQuery(
          r'''SELECT "structureId" FROM "cine_pass_evenement" WHERE "id" = (@id)::uuid''',
          parameters: QueryParameters.named({'id': id}),
        );
        if (targetRows.isEmpty) return null;
        final targetStructureId = targetRows.first[0]?.toString();
        if (targetStructureId == null || !assigned.contains(targetStructureId)) {
          session.log('updateEvent refuse: structure hors perimetre responsable');
          return null;
        }
      }

      final eventDateDt = eventDate != null ? _parseDateTime(eventDate) : null;
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
          "posterColor" = CASE WHEN @posterColor IS NOT NULL THEN @posterColor ELSE "posterColor" END,
          "posterUrl" = CASE WHEN @posterUrl IS NOT NULL THEN @posterUrl ELSE "posterUrl" END
        WHERE "id" = (@id)::uuid
        RETURNING "id", "titre", "categorie", "description", "lieu", "adresse", "ville",
                  "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor",
                  "posterUrl", "availableOptions"
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
          'posterUrl': posterUrl,
        }),
      );
      if (result.isEmpty) return null;
      return _rowToEventResponse(result.first);
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
      final isAdmin = await _isAdmin(session);
      if (!isAdmin) {
        final assigned = await _responsableStructureIds(session);
        if (assigned.isEmpty) return false;
        final targetRows = await session.db.unsafeQuery(
          r'''SELECT "structureId" FROM "cine_pass_evenement" WHERE "id" = (@id)::uuid''',
          parameters: QueryParameters.named({'id': id}),
        );
        if (targetRows.isEmpty) return false;
        final targetStructureId = targetRows.first[0]?.toString();
        if (targetStructureId == null || !assigned.contains(targetStructureId)) {
          session.log('deleteEvent refuse: structure hors perimetre responsable');
          return false;
        }
      }

      await session.db.unsafeQuery(
        r'DELETE FROM "cine_pass_evenement" WHERE "id" = (@id)::uuid',
        parameters: QueryParameters.named({'id': id}),
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
      final all = await Structure.db.find(session);
      for (final s in all) {
        if (s.id.toString() == structureId) {
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

  /// Événements des structures du responsable connecté.
  Future<List<EventResponse>> getMyEvents(Session session) async {
    try {
      final userId = session.authenticated?.userIdentifier;
      if (userId == null) {
        return [];
      }
      final result = await session.db.unsafeQuery(
        r'''
        SELECT e."id", e."titre", e."categorie", e."description", e."lieu", e."adresse", e."ville",
               e."eventDate", e."eventTime", e."placesTotal", e."prixBase", e."posterColor",
               e."posterUrl", e."availableOptions"
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
               r."structure_address", r."status", r."created_at",
               COALESCE(r."professional_email", '') AS user_name
        FROM "cine_pass_responsable_request" r
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

      await _grantUserRoleWithStatus(
        session,
        userId: userId,
        role: 'responsable',
        status: 'actif',
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
      await session.db.unsafeQuery(
        r'''
        UPDATE "cine_pass_responsable_request"
        SET "status" = 'REJECTED', "decided_at" = now(), "admin_id" = (@adminId)::uuid, "rejection_reason" = @reason
        WHERE "id" = (@id)::uuid
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
      session.log(
        'CinePass getReservationsForMyStructures',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      return [];
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
        SELECT COALESCE(SUM(r."total_amount"), 0)::double AS total, COUNT(r."id")::int AS nb
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
      final s = time.toString();
      // "21:00:00" or "21:00" or Duration
      if (s.length >= 5) {
        timeStr = s.substring(0, 5);
      }
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
      posterUrl: posterUrl,
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
    final createdAt = row.length > 7 ? row[7] : null;
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

  /// Profil de l'utilisateur connecté (displayName, phone, birthDate).
  /// Retourne null si non authentifié.
  Future<ProfileResponse?> getProfile(Session session) async {
    final userId = session.authenticated?.userIdentifier;
    if (userId == null) return null;
    try {
      await _grantUserRoleWithStatus(
        session,
        userId: userId,
        role: 'client',
        status: 'actif',
      );

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
          b = v is DateTime ? v.toIso8601String().substring(0, 10) : v.toString();
        }
      }
      final birthDateParsed = b != null && b.isNotEmpty ? DateTime.tryParse(b) : null;
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
