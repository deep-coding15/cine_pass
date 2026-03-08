-- =============================================================================
-- Schéma SQL CinePass — Données réelles (backend)
-- PostgreSQL. À exécuter après les migrations Serverpod (auth déjà en place).
-- Les utilisateurs sont serverpod_auth_core_user (uuid).
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- FILMS
-- -----------------------------------------------------------------------------
CREATE TABLE "cine_pass_film" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "titre" text NOT NULL,
    "genre" text NOT NULL,
    "duree_minutes" integer NOT NULL,
    "synopsis" text,
    "directeur" text,
    "casting" text,
    "poster_color" integer,
    "poster_url" text,
    "date_sortie" date,
    "date_fin" date,
    "audience" text DEFAULT 'Tous publics',
    "created_at" timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_film_genre_idx" ON "cine_pass_film" USING btree ("genre");
CREATE INDEX "cine_pass_film_titre_idx" ON "cine_pass_film" USING btree ("titre");

-- -----------------------------------------------------------------------------
-- CINÉMAS & SALLES
-- -----------------------------------------------------------------------------
CREATE TABLE "cine_pass_cinema" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "nom" text NOT NULL,
    "ville" text NOT NULL,
    "adresse" text,
    "code_postal" text,
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TABLE "cine_pass_salle" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "cinema_id" uuid NOT NULL REFERENCES "cine_pass_cinema"("id") ON DELETE CASCADE,
    "nom" text NOT NULL,
    "capacite" integer NOT NULL,
    UNIQUE ("cinema_id", "nom")
);

CREATE INDEX "cine_pass_salle_cinema_idx" ON "cine_pass_salle" USING btree ("cinema_id");

-- -----------------------------------------------------------------------------
-- SIÈGES (plan de salle, pour films)
-- -----------------------------------------------------------------------------
CREATE TABLE "cine_pass_siege" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "salle_id" uuid NOT NULL REFERENCES "cine_pass_salle"("id") ON DELETE CASCADE,
    "rangee" text NOT NULL,
    "numero" integer NOT NULL,
    UNIQUE ("salle_id", "rangee", "numero")
);

CREATE INDEX "cine_pass_siege_salle_idx" ON "cine_pass_siege" USING btree ("salle_id");

-- -----------------------------------------------------------------------------
-- SÉANCES (film + salle + créneau)
-- -----------------------------------------------------------------------------
CREATE TABLE "cine_pass_seance" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "film_id" uuid NOT NULL REFERENCES "cine_pass_film"("id") ON DELETE CASCADE,
    "salle_id" uuid NOT NULL REFERENCES "cine_pass_salle"("id") ON DELETE CASCADE,
    "debut_at" timestamp without time zone NOT NULL,
    "fin_at" timestamp without time zone,
    "format" text NOT NULL DEFAULT 'VF',
    "type" text NOT NULL DEFAULT '2D',
    "prix_base" numeric(10,2) NOT NULL,
    "available_options" jsonb NOT NULL DEFAULT '["parking", "popcorn", "boisson"]',
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_seance_film_idx" ON "cine_pass_seance" USING btree ("film_id");
CREATE INDEX "cine_pass_seance_salle_idx" ON "cine_pass_seance" USING btree ("salle_id");
CREATE INDEX "cine_pass_seance_debut_idx" ON "cine_pass_seance" USING btree ("debut_at");

-- -----------------------------------------------------------------------------
-- ÉVÉNEMENTS (concerts, théâtre, etc.)
-- -----------------------------------------------------------------------------
CREATE TABLE "cine_pass_evenement" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "titre" text NOT NULL,
    "categorie" text NOT NULL,
    "description" text,
    "lieu" text NOT NULL,
    "adresse" text,
    "ville" text NOT NULL,
    "event_date" date NOT NULL,
    "event_time" time without time zone NOT NULL,
    "places_total" integer NOT NULL,
    "prix_base" numeric(10,2) NOT NULL,
    "poster_color" integer,
    "poster_url" text,
    "available_options" jsonb NOT NULL DEFAULT '["parking", "popcorn", "boisson"]',
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_evenement_ville_idx" ON "cine_pass_evenement" USING btree ("ville");
CREATE INDEX "cine_pass_evenement_date_idx" ON "cine_pass_evenement" USING btree ("event_date");

-- -----------------------------------------------------------------------------
-- RÉSERVATIONS (film OU événement)
-- -----------------------------------------------------------------------------
CREATE TABLE "cine_pass_reservation" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "user_id" uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "seance_id" uuid REFERENCES "cine_pass_seance"("id") ON DELETE SET NULL,
    "evenement_id" uuid REFERENCES "cine_pass_evenement"("id") ON DELETE SET NULL,
    "numero" text NOT NULL,
    "statut" text NOT NULL DEFAULT 'pending',
    "total_amount" numeric(10,2) NOT NULL,
    "session_at" timestamp without time zone,
    "created_at" timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at" timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT "cine_pass_reservation_seance_ou_evenement"
        CHECK (
            ("seance_id" IS NOT NULL AND "evenement_id" IS NULL)
            OR ("seance_id" IS NULL AND "evenement_id" IS NOT NULL)
        )
);

CREATE UNIQUE INDEX "cine_pass_reservation_numero_idx" ON "cine_pass_reservation" USING btree ("numero");
CREATE INDEX "cine_pass_reservation_user_idx" ON "cine_pass_reservation" USING btree ("user_id");
CREATE INDEX "cine_pass_reservation_seance_idx" ON "cine_pass_reservation" USING btree ("seance_id");
CREATE INDEX "cine_pass_reservation_evenement_idx" ON "cine_pass_reservation" USING btree ("evenement_id");
CREATE INDEX "cine_pass_reservation_created_idx" ON "cine_pass_reservation" USING btree ("created_at");

-- -----------------------------------------------------------------------------
-- BILLETS (un par place ; pour événement pas de siège)
-- -----------------------------------------------------------------------------
CREATE TABLE "cine_pass_billet" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "reservation_id" uuid NOT NULL REFERENCES "cine_pass_reservation"("id") ON DELETE CASCADE,
    "siege_id" uuid REFERENCES "cine_pass_siege"("id") ON DELETE SET NULL,
    "ticket_type" text NOT NULL DEFAULT 'normal',
    "option_parking" boolean NOT NULL DEFAULT false,
    "option_popcorn" boolean NOT NULL DEFAULT false,
    "option_boisson" boolean NOT NULL DEFAULT false,
    "prix" numeric(10,2) NOT NULL,
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_billet_reservation_idx" ON "cine_pass_billet" USING btree ("reservation_id");
CREATE INDEX "cine_pass_billet_siege_idx" ON "cine_pass_billet" USING btree ("siege_id");

-- -----------------------------------------------------------------------------
-- PAIEMENTS
-- -----------------------------------------------------------------------------
CREATE TABLE "cine_pass_paiement" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "reservation_id" uuid NOT NULL REFERENCES "cine_pass_reservation"("id") ON DELETE CASCADE,
    "montant" numeric(10,2) NOT NULL,
    "methode" text,
    "statut" text NOT NULL DEFAULT 'pending',
    "external_id" text,
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_paiement_reservation_idx" ON "cine_pass_paiement" USING btree ("reservation_id");

-- -----------------------------------------------------------------------------
-- FAVORIS (film ou cinéma selon besoin métier)
-- -----------------------------------------------------------------------------
CREATE TABLE "cine_pass_favori" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "user_id" uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "film_id" uuid REFERENCES "cine_pass_film"("id") ON DELETE CASCADE,
    "cinema_id" uuid REFERENCES "cine_pass_cinema"("id") ON DELETE CASCADE,
    "created_at" timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT "cine_pass_favori_film_ou_cinema"
        CHECK (
            ("film_id" IS NOT NULL AND "cinema_id" IS NULL)
            OR ("film_id" IS NULL AND "cinema_id" IS NOT NULL)
        )
);

CREATE UNIQUE INDEX "cine_pass_favori_user_film_idx" ON "cine_pass_favori" USING btree ("user_id", "film_id") WHERE "film_id" IS NOT NULL;
CREATE UNIQUE INDEX "cine_pass_favori_user_cinema_idx" ON "cine_pass_favori" USING btree ("user_id", "cinema_id") WHERE "cinema_id" IS NOT NULL;
CREATE INDEX "cine_pass_favori_user_idx" ON "cine_pass_favori" USING btree ("user_id");

-- -----------------------------------------------------------------------------
-- FAQ
-- -----------------------------------------------------------------------------
CREATE TABLE "cine_pass_faq" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "question" text NOT NULL,
    "reponse" text NOT NULL,
    "ordre" integer NOT NULL DEFAULT 0,
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_faq_ordre_idx" ON "cine_pass_faq" USING btree ("ordre");

-- -----------------------------------------------------------------------------
-- RÔLE ADMIN (optionnel : lien user -> admin)
-- -----------------------------------------------------------------------------
CREATE TABLE "cine_pass_user_role" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "user_id" uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "role" text NOT NULL DEFAULT 'client',
    UNIQUE ("user_id")
);

CREATE INDEX "cine_pass_user_role_user_idx" ON "cine_pass_user_role" USING btree ("user_id");

COMMIT;
