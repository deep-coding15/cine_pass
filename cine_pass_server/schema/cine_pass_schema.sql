-- =============================================================================
-- Schéma SQL CinePass — Données réelles (backend)
-- PostgreSQL. À exécuter après les migrations Serverpod (auth déjà en place).
-- Les utilisateurs sont serverpod_auth_core_user (uuid).
--
-- IMPORTANT: Serverpod attend des colonnes en CAMELCASE (createdAt, codePostal,
-- filmId, etc.) pour les tables validées par Serverpod (film, cinema, salle,
-- siege, seance, evenement). Ne pas revenir en snake_case pour ces colonnes.
-- =============================================================================

BEGIN;

-- =============================================================================
-- FILMS (colonnes en camelCase pour correspondre au protocole Serverpod)
-- =============================================================================
CREATE TABLE "cine_pass_film" (
    "id"             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "createdAt"      timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "titre"          text NOT NULL,
    "genre"          text NOT NULL,
    "dureeMinutes"   bigint NOT NULL,
    "synopsis"       text,
    "directeur"      text,
    "casting"        text,
    "posterColor"    bigint,
    "posterUrl"      text,
    "dateSortie"     timestamp without time zone,
    "dateFin"        timestamp without time zone,
    "audience"       text,
    "updatedAt"      timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- CINÉMAS & SALLES (colonnes en camelCase)
-- =============================================================================
CREATE TABLE "cine_pass_cinema" (
    "id"         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "createdAt"  timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "nom"        text NOT NULL,
    "ville"      text NOT NULL,
    "adresse"    text,
    "codePostal" text
);

CREATE TABLE "cine_pass_salle" (
    "id"        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "cinemaId"  uuid NOT NULL,
    "nom"       text NOT NULL,
    "capacite"  bigint NOT NULL
);

-- =============================================================================
-- SIÈGES (plan de salle, pour films)
-- =============================================================================
CREATE TABLE "cine_pass_siege" (
    "id"      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "salleId" uuid NOT NULL,
    "rangee"  text NOT NULL,
    "numero"  bigint NOT NULL
);

-- =============================================================================
-- SÉANCES (film + salle + créneau)
-- =============================================================================
CREATE TABLE "cine_pass_seance" (
    "id"               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "createdAt"        timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "filmId"           uuid NOT NULL,
    "salleId"          uuid NOT NULL,
    "debutAt"          timestamp without time zone NOT NULL,
    "finAt"            timestamp without time zone,
    "format"           text NOT NULL DEFAULT 'VF',
    "type"             text NOT NULL DEFAULT '2D',
    "prixBase"         double precision NOT NULL,
    "availableOptions" json
);

-- =============================================================================
-- STRUCTURES (cinéma, salle de spectacle, organisateur)
-- Colonne "cinemaId" en camelCase pour Serverpod.
-- Déclarée avant EVENEMENT car EVENEMENT y fait référence.
-- =============================================================================
CREATE TABLE "cine_pass_structure" (
    "id"       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "type"     text NOT NULL,   -- 'CINEMA' | 'VENUE' | 'ORGANIZER'
    "name"     text NOT NULL,
    "city"     text NOT NULL,
    "address"  text,
    "website"  text,
    "phone"    text,
    "cinemaId" uuid
);

CREATE INDEX "cine_pass_structure_type_city_idx"
    ON "cine_pass_structure" ("type", "city");

-- FK sur cinemaId (camelCase, aligné Serverpod)
ALTER TABLE "cine_pass_structure"
    ADD CONSTRAINT "cine_pass_structure_fk_0"
    FOREIGN KEY ("cinemaId") REFERENCES "cine_pass_cinema"("id")
    ON DELETE SET NULL ON UPDATE NO ACTION;

-- =============================================================================
-- ÉVÉNEMENTS (concerts, théâtre, etc. — colonnes en camelCase)
-- =============================================================================
CREATE TABLE "cine_pass_evenement" (
    "id"               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "createdAt"        timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "titre"            text NOT NULL,
    "categorie"        text NOT NULL,
    "description"      text,
    "lieu"             text NOT NULL,
    "adresse"          text,
    "ville"            text NOT NULL,
    "eventDate"        timestamp without time zone NOT NULL,
    "eventTime"        timestamp without time zone NOT NULL,
    "placesTotal"      bigint NOT NULL,
    "prixBase"         double precision NOT NULL,
    "posterColor"      bigint,
    "posterUrl"        text,
    "availableOptions" json,
    "structureId"      uuid   -- FK ajoutée ci-dessous après les contraintes Serverpod
);

-- FK : structureId (camelCase, aligné Serverpod)
ALTER TABLE "cine_pass_evenement"
    ADD CONSTRAINT "cine_pass_evenement_fk_0"
    FOREIGN KEY ("structureId") REFERENCES "cine_pass_structure"("id")
    ON DELETE SET NULL ON UPDATE NO ACTION;

-- =============================================================================
-- RÉSERVATIONS (film OU événement)
-- =============================================================================
CREATE TABLE "cine_pass_reservation" (
    "id"           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id"      uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "seance_id"    uuid REFERENCES "cine_pass_seance"("id")   ON DELETE SET NULL,
    "evenement_id" uuid REFERENCES "cine_pass_evenement"("id") ON DELETE SET NULL,
    "numero"       text NOT NULL,
    "statut"       text NOT NULL DEFAULT 'pending',
    "total_amount" numeric(10,2) NOT NULL,
    "session_at"   timestamp without time zone,
    "created_at"   timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"   timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT "cine_pass_reservation_seance_ou_evenement"
        CHECK (
            ("seance_id"    IS NOT NULL AND "evenement_id" IS NULL)
            OR ("seance_id" IS NULL     AND "evenement_id" IS NOT NULL)
        )
);

CREATE UNIQUE INDEX "cine_pass_reservation_numero_idx"
    ON "cine_pass_reservation" USING btree ("numero");
CREATE INDEX "cine_pass_reservation_user_idx"
    ON "cine_pass_reservation" USING btree ("user_id");
CREATE INDEX "cine_pass_reservation_seance_idx"
    ON "cine_pass_reservation" USING btree ("seance_id");
CREATE INDEX "cine_pass_reservation_evenement_idx"
    ON "cine_pass_reservation" USING btree ("evenement_id");
CREATE INDEX "cine_pass_reservation_created_idx"
    ON "cine_pass_reservation" USING btree ("created_at");

-- =============================================================================
-- BILLETS (un par place ; pour événement pas de siège)
-- =============================================================================
CREATE TABLE "cine_pass_billet" (
    "id"              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "reservation_id"  uuid NOT NULL REFERENCES "cine_pass_reservation"("id") ON DELETE CASCADE,
    "siege_id"        uuid REFERENCES "cine_pass_siege"("id") ON DELETE SET NULL,
    "ticket_type"     text NOT NULL DEFAULT 'normal',
    "option_parking"  boolean NOT NULL DEFAULT false,
    "option_popcorn"  boolean NOT NULL DEFAULT false,
    "option_boisson"  boolean NOT NULL DEFAULT false,
    "prix"            numeric(10,2) NOT NULL,
    "created_at"      timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_billet_reservation_idx"
    ON "cine_pass_billet" USING btree ("reservation_id");
CREATE INDEX "cine_pass_billet_siege_idx"
    ON "cine_pass_billet" USING btree ("siege_id");

-- =============================================================================
-- PAIEMENTS
-- =============================================================================
CREATE TABLE "cine_pass_paiement" (
    "id"             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "reservation_id" uuid NOT NULL REFERENCES "cine_pass_reservation"("id") ON DELETE CASCADE,
    "montant"        numeric(10,2) NOT NULL,
    "methode"        text,
    "statut"         text NOT NULL DEFAULT 'pending',
    "external_id"    text,
    "created_at"     timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_paiement_reservation_idx"
    ON "cine_pass_paiement" USING btree ("reservation_id");

-- =============================================================================
-- FAVORIS (film ou cinéma)
-- =============================================================================
CREATE TABLE "cine_pass_favori" (
    "id"         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id"    uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "film_id"    uuid REFERENCES "cine_pass_film"("id")   ON DELETE CASCADE,
    "cinema_id"  uuid REFERENCES "cine_pass_cinema"("id") ON DELETE CASCADE,
    "created_at" timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT "cine_pass_favori_film_ou_cinema"
        CHECK (
            ("film_id"    IS NOT NULL AND "cinema_id" IS NULL)
            OR ("film_id" IS NULL     AND "cinema_id" IS NOT NULL)
        )
);

CREATE UNIQUE INDEX "cine_pass_favori_user_film_idx"
    ON "cine_pass_favori" USING btree ("user_id", "film_id")   WHERE "film_id"   IS NOT NULL;
CREATE UNIQUE INDEX "cine_pass_favori_user_cinema_idx"
    ON "cine_pass_favori" USING btree ("user_id", "cinema_id") WHERE "cinema_id" IS NOT NULL;
CREATE INDEX "cine_pass_favori_user_idx"
    ON "cine_pass_favori" USING btree ("user_id");

-- =============================================================================
-- FAQ
-- =============================================================================
CREATE TABLE "cine_pass_faq" (
    "id"         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "question"   text NOT NULL,
    "reponse"    text NOT NULL,
    "ordre"      integer NOT NULL DEFAULT 0,
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_faq_ordre_idx"
    ON "cine_pass_faq" USING btree ("ordre");

-- =============================================================================
-- RÔLE UTILISATEUR (avec status : actif, inactif, bloqué, banni)
-- =============================================================================
CREATE TABLE "cine_pass_user_role" (
    "id"         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id"    uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "role"       text NOT NULL,  -- 'client' | 'responsable' | 'admin'
    "status"     text NOT NULL DEFAULT 'actif',  -- 'actif' | 'inactif' | 'bloqué' | 'banni'
    "created_at" timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX "cine_pass_user_role_user_role_uniq"
    ON "cine_pass_user_role" ("user_id", "role");

CREATE INDEX "cine_pass_user_role_user_idx"
    ON "cine_pass_user_role" ("user_id");

CREATE INDEX "cine_pass_user_role_status_idx"
    ON "cine_pass_user_role" ("status");

-- =============================================================================
-- DEMANDES DE CHANGEMENT RÔLE CRITIQUE (admin ↔ responsable)
-- Nécessite 2 confirmations minimum avant changement
-- =============================================================================
CREATE TABLE "cine_pass_role_change_request" (
    "id"                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id"           uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "from_role"         text NOT NULL,  -- Rôle actuel ('admin' | 'responsable' | 'client')
    "to_role"           text NOT NULL,  -- Rôle cible ('admin' | 'responsable' | 'client')
    "requested_by"      uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "status"            text NOT NULL DEFAULT 'pending',  -- 'pending' | 'approved' | 'rejected' | 'cancelled'
    "approvals_count"   integer NOT NULL DEFAULT 0,  -- Nombre d'approbations (min 2 requis)
    "rejection_reason"  text,
    "created_at"        timestamp without time zone NOT NULL DEFAULT now(),
    "expires_at"        timestamp without time zone NOT NULL DEFAULT (now() + interval '7 days')
);

CREATE INDEX "cine_pass_role_change_request_user_idx"
    ON "cine_pass_role_change_request" ("user_id");

CREATE INDEX "cine_pass_role_change_request_status_idx"
    ON "cine_pass_role_change_request" ("status");

-- =============================================================================
-- APPROBATIONS DE CHANGEMENT RÔLE (audit trail)
-- =============================================================================
CREATE TABLE "cine_pass_role_change_approval" (
    "id"           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "change_id"    uuid NOT NULL REFERENCES "cine_pass_role_change_request"("id") ON DELETE CASCADE,
    "approver_id"  uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "approval_at"  timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_role_change_approval_change_idx"
    ON "cine_pass_role_change_approval" ("change_id");

CREATE INDEX "cine_pass_role_change_approval_approver_idx"
    ON "cine_pass_role_change_approval" ("approver_id");

-- =============================================================================
-- PROFIL UTILISATEUR (nom affiché, téléphone, date de naissance)
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_user_profile" (
    "user_id" uuid PRIMARY KEY REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "display_name" text,
    "phone" text,
    "birth_date" date
);

-- =============================================================================
-- RESPONSABLES — DEMANDES
-- =============================================================================
CREATE TABLE "cine_pass_responsable_request" (
    "id"               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id"          uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "structure_type"   text NOT NULL,   -- 'CINEMA' | 'VENUE' | 'ORGANIZER' | 'OTHER'
    "structure_name"   text NOT NULL,
    "structure_city"   text NOT NULL,
    "structure_address" text,
    "structure_website" text,
    "structure_siret"  text,
    "structure_phone"  text,
    "contact_role"     text,
    "description"      text NOT NULL,
    "social_links"     text,
    "status"           text NOT NULL DEFAULT 'PENDING',  -- PENDING | APPROVED | REJECTED
    "created_at"       timestamp without time zone NOT NULL DEFAULT now(),
    "decided_at"       timestamp without time zone,
    "admin_id"         uuid REFERENCES "serverpod_auth_core_user"("id") ON DELETE SET NULL,
    "rejection_reason" text
);

CREATE INDEX "cine_pass_responsable_request_user_idx"
    ON "cine_pass_responsable_request" ("user_id");
CREATE INDEX "cine_pass_responsable_request_status_idx"
    ON "cine_pass_responsable_request" ("status");


-- =============================================================================
-- RESPONSABLES — ASSIGNMENTS (lien user <-> structure)
-- =============================================================================
CREATE TABLE "cine_pass_responsable_assignment" (
    "id"           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id"      uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "structure_id" uuid NOT NULL REFERENCES "cine_pass_structure"("id")      ON DELETE CASCADE,
    "active"       boolean NOT NULL DEFAULT true,
    "created_at"   timestamp without time zone NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX "cine_pass_responsable_assignment_uniq"
    ON "cine_pass_responsable_assignment" ("user_id", "structure_id");
CREATE INDEX "cine_pass_responsable_assignment_struct_idx"
    ON "cine_pass_responsable_assignment" ("structure_id");

-- =============================================================================
-- FOREIGN KEYS Serverpod (noms fk_0/fk_1, onDelete/onUpdate alignés .spy.yaml)
-- =============================================================================
ALTER TABLE "cine_pass_salle"
    ADD CONSTRAINT "cine_pass_salle_fk_0"
    FOREIGN KEY ("cinemaId") REFERENCES "cine_pass_cinema"("id")
    ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "cine_pass_siege"
    ADD CONSTRAINT "cine_pass_siege_fk_0"
    FOREIGN KEY ("salleId") REFERENCES "cine_pass_salle"("id")
    ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "cine_pass_seance"
    ADD CONSTRAINT "cine_pass_seance_fk_0"
    FOREIGN KEY ("filmId")  REFERENCES "cine_pass_film"("id")
    ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "cine_pass_seance"
    ADD CONSTRAINT "cine_pass_seance_fk_1"
    FOREIGN KEY ("salleId") REFERENCES "cine_pass_salle"("id")
    ON DELETE CASCADE ON UPDATE NO ACTION;

COMMIT;