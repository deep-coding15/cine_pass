import 'package:cine_pass_server/src/generated/protocol.dart';
import 'package:cine_pass_server/src/services/paiement/paiement_factory.dart';
import 'package:serverpod/server.dart';

class ReservationEndpoint extends Endpoint {
  /// le prix final est calculé en fonction du prix de base de la séance + le prix des optionnels - la réduction du code promo
  /// la reduction du code promo est appliquée sur le montant total (prix de base) et pas sur les optionnels)
  Future<Reservation> createReservation(
      Session session, {
        required int userId,
        required int cinemaId,
        required int seanceId,
        required Set<int> siegeIds,
        required Map<int, int> optionnelIds, // optionnelId -> quantity
        String dateReservation = '',
        required double montantTotal,
        ReservationStatut statut = ReservationStatut.EN_ATTENTE,
        PaiementMethod paiementMethod = PaiementMethod.BANK,
        String codePromo = '',
      }) async {
    if (siegeIds.isEmpty) {
      throw Exception("Au moins un siège doit être sélectionné");
    }

    if (optionnelIds.isEmpty) {
      throw Exception("Au moins un optionnel doit être sélectionné");
    }

    if (userId <= 0 || cinemaId <= 0 || seanceId <= 0) {
      throw Exception("Ids invalide");
    }

    if (montantTotal <= 0) {
      throw Exception("Montant total invalide");
    }

    /*if(dateReservation.isEmpty) {
      dateReservation = DateTime.now().toString();
    }*/

    return await session.db.transaction((transaction) async {
      // verifier le cinema
      final cinema = await Cinema.db.findById(
        session,
        cinemaId,
        transaction: transaction,
      );

      if (cinema == null) {
        throw Exception("Cinema introuvable");
      }

      // 1- Vérifier séance
      final seance = await Seance.db.findById(
        session,
        seanceId,
        transaction: transaction,
      );

      if (seance == null) {
        throw Exception("Séance introuvable");
      }

      // 2- Vérifier que les sièges existent dans la salle de la séance du cinéma
      await validerAppartenance(
        session,
        siegeIds: siegeIds.toList(),
        cinemaId: cinemaId,
        salleId: seance.salleId,
      );

      // 3️- Vérifier disponibilité
      //final existingReservations =
      //  await ReservationEndpoint.getDisponibiliteSieges(session, seanceId);
      /*final existingReservations = await ReservationSiege.db.find(
        session,
        where: (rs) =>
            rs.siegeId.inSet(siegeIds) & rs.reservationId.notEquals(null),
        transaction: transaction,
      );*/

      /*if (existingReservations.isNotEmpty) {
        throw Exception("Un ou plusieurs sièges sont déjà réservés");
      }*/

      /*final conflicts = await ReservationSiege.db.find(
        session,
        where: (rs) =>
            rs.siegeId.inSet(siegeIds),
        include: ReservationSiege.include(
          reservation: Reservation.include(),
        ),
        transaction: transaction,
      );

      final hasConflict = conflicts.any((rs) =>
      rs.reservation?.seanceId == seanceId &&
          (rs.reservation?.statut == 'EN_ATTENTE' ||
              rs.reservation?.statut == 'PAYEE'));

      if (hasConflict) {
        throw Exception("Sièges déjà réservés pour cette séance");
      }*/

      // 4️- Créer réservation
      final reservation = await Reservation.db.insertRow(
        session,
        Reservation(
          userId: userId,
          seanceId: seanceId,
          dateReservation: DateTime.now(),
          montantTotal: 0, // à calculer plus tard
          statut: ReservationStatut.EN_ATTENTE, // à modifier
          codePromo: '', // à modifier
        ),
        transaction: transaction,
      );

      // 5️- Bloquer sièges
      for (final siegeId in siegeIds) {
        await ReservationSiege.db.insertRow(
          session,
          ReservationSiege(
            reservationId: reservation.id!,
            siegeId: siegeId,
            statut: ReservationSiegeStatut.RESERVE,
          ),
          transaction: transaction,
        );
      }

      //Ajouter les sieges dans la reservation
      await Reservation.db.updateRow(
        session,
        reservation.copyWith(
          reservationSieges: siegeIds
              .map(
                (id) => ReservationSiege(
              reservationId: reservation.id!,
              siegeId: id,
              statut: ReservationSiegeStatut.RESERVE,
            ),
          )
              .toList(),
        ),
        transaction: transaction,
      );

      // Ajouter les optionnels dans la reservation
      await Reservation.db.updateRow(
        session,
        reservation.copyWith(
          produitsOptionnels: optionnelIds.entries
              .map(
                (entry) => OptionnelReservation(
              reservationId: reservation.id!,
              optionnelId: entry.key,
              number: entry.value,
              dateAjout: DateTime.now(),
            ),
          )
              .toList(),
        ),
        transaction: transaction,
      );
      // Ajouter le prix des optionnels au montant total
      final optionnels = await Optionnel.db.find(
        session,
        where: (o) => o.id.inSet(optionnelIds.keys.toSet()),
        transaction: transaction,
      );

      double totalOptionnels = optionnels.fold(
        0,
            (sum, o) => sum + o.price,
      );

      // Applique le code promo si fourni
      if (codePromo.isNotEmpty) {
        final code = await CodePromo.db.findFirstRow(
          session,
          where: (cp) => cp.code.equals(codePromo.toUpperCase()),
          transaction: transaction,
        );

        if (code != null) {
          montantTotal -= montantTotal * code.pourcentage / 100;
        }
      }

      await payerReservation(
        session,
        reservationId: reservation.id!,
        montant: montantTotal + totalOptionnels,
        paiementMethod: paiementMethod,
      );

      return reservation;
    });
  }

  /// 1. Vérifie si les sièges appartiennent bien au cinéma et à la salle de la séance
  Future<void> validerAppartenance(
      Session session, {
        required List<int> siegeIds,
        required int cinemaId,
        required int salleId,
      }) async {
    final sieges = await Siege.db.find(
      session,
      where: (s) =>
      s.id.inSet(siegeIds.toSet()) &
      s.cinemaId.equals(cinemaId) &
      s.salleId.equals(salleId),
    );

    if (sieges.length != siegeIds.length) {
      throw Exception(
        "Certains sièges sont invalides pour cette salle ou ce cinéma.",
      );
    }
  }

  /// 2. Vérifie si les sièges ne sont pas déjà réservés pour une séance précise
  Future<void> validerDisponibilite(
      Session session, {
        required List<int> siegeIds,
        required int seanceId,
      }) async {
    // On cherche si une ReservationSiege existe déjà pour ces sièges ET cette séance
    final occupations = await ReservationSiege.db.find(
      session,
      where: (rs) =>
      rs.siegeId.inSet(siegeIds.toSet()) &
      //rs.seanceId.equals(seanceId) &
      rs.reservation.seanceId.equals(seanceId) &
      (rs.reservation.statut.equals(ReservationStatut.EN_ATTENTE) |
      rs.reservation.statut.equals(ReservationStatut.PAYEE)),
      //include: ReservationSiege.include(reservation: Reservation.include()),
    );

    if (occupations.isNotEmpty) {
      throw Exception(
        "Un ou plusieurs sièges sont déjà occupés pour cette séance.",
      );
    }
  }

  Future<PaiementResult> payerReservation(
      Session session, {
        required int reservationId,
        required double montant,
        PaiementMethod paiementMethod = PaiementMethod.BANK,
        PaiementStatut statut = PaiementStatut.SUCCESS,
      }) async {
    final reservation = await Reservation.db.findById(session, reservationId);

    if (reservation == null) {
      throw Exception("Reservation introuvable");
    }

    final method = PaiementFactory.create(paiementMethod.name);

    final result = await method.pay(
      reservation: reservation,
      amount: reservation.montantTotal,
    );

    if (result.success) {
      await Reservation.db.updateRow(
        session,
        reservation.copyWith(statut: ReservationStatut.PAYEE),
      );
      await Paiement.db.insertRow(
        session,
        Paiement(
          reservationId: reservation.id!,
          montant: result.montantTotal,
          method: paiementMethod.name,
          statut: statut,
          transactionId: result.transactionId,
          datePaiement: DateTime.now(),
        ),
      );
    }

    return result;
  }


}