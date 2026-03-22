-- =============================================================================
-- CinePass — SCHÉMA COMPLET (un seul fichier)
-- =============================================================================
-- Prérequis : PostgreSQL, extension pgcrypto si besoin de gen_random_uuid(),
-- et migrations Serverpod déjà appliquées sur cette base
-- (tables serverpod_*, serverpod_auth_core_user, serverpod_auth_core_profile, …).
--
-- Ce script :
--   1) Supprime toutes les tables / vues métier cine_pass_* (données perdues).
--   2) Recrée l’intégralité du schéma + fonctions / triggers / vue des rôles.
--
-- Exemple Docker :
--   Get-Content schema\cine_pass_schema.sql -Raw | docker exec -i <container> psql -U postgres -d <db>
--
-- IMPORTANT : Serverpod attend le camelCase (createdAt, filmId, …) sur les
-- tables modélisées ; les champs métier événement restent en snake_case
-- (event_type, …) comme dans les modèles .spy.yaml.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Phase 0 — Nettoyage (ne touche pas aux tables serverpod_* / auth)
-- Pour conserver les données métier : commentez toute cette transaction
-- (du BEGIN ci-dessous jusqu’au COMMIT correspondant), sachant que le reste
-- du script peut alors échouer si les objets existent déjà.
-- ---------------------------------------------------------------------------
BEGIN;

DROP VIEW IF EXISTS "cine_pass_effective_roles" CASCADE;

DROP TABLE IF EXISTS "cine_pass_paiement" CASCADE;
DROP TABLE IF EXISTS "cine_pass_billet" CASCADE;
DROP TABLE IF EXISTS "cine_pass_reservation" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_ticket_option" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_ticket_type" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_seat" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_reservation_config" CASCADE;

DROP TABLE IF EXISTS "cine_pass_event_film_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_festival_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_standup_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_concert_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_theatre_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_other_details" CASCADE;

DROP TABLE IF EXISTS "cine_pass_evenement" CASCADE;

DROP TABLE IF EXISTS "cine_pass_seance" CASCADE;
DROP TABLE IF EXISTS "cine_pass_siege" CASCADE;
DROP TABLE IF EXISTS "cine_pass_salle" CASCADE;
DROP TABLE IF EXISTS "cine_pass_favori" CASCADE;
DROP TABLE IF EXISTS "cine_pass_cinema" CASCADE;
DROP TABLE IF EXISTS "cine_pass_film" CASCADE;

DROP TABLE IF EXISTS "cine_pass_faq" CASCADE;
DROP TABLE IF EXISTS "cine_pass_user_profile" CASCADE;
DROP TABLE IF EXISTS "cine_pass_user_role" CASCADE;
DROP TABLE IF EXISTS "cine_pass_admin_user" CASCADE;

DROP TABLE IF EXISTS "cine_pass_responsable_assignment" CASCADE;
DROP TABLE IF EXISTS "cine_pass_responsable_user" CASCADE;
DROP TABLE IF EXISTS "cine_pass_structure" CASCADE;
DROP TABLE IF EXISTS "cine_pass_responsable_request" CASCADE;

COMMIT;

-- ---------------------------------------------------------------------------
-- Phase 1 — Tables, index, FK
-- ---------------------------------------------------------------------------
BEGIN;

-- =============================================================================
-- FILMS (colonnes en camelCase pour correspondre au protocole Serverpod)
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_film" (
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
CREATE TABLE IF NOT EXISTS "cine_pass_cinema" (
    "id"         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "createdAt"  timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "nom"        text NOT NULL,
    "ville"      text NOT NULL,
    "adresse"    text,
    "codePostal" text
);

CREATE TABLE IF NOT EXISTS "cine_pass_salle" (
    "id"        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "cinemaId"  uuid NOT NULL,
    "nom"       text NOT NULL,
    "capacite"  bigint NOT NULL
);

-- =============================================================================
-- SIÈGES (plan de salle, pour films)
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_siege" (
    "id"      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "salleId" uuid NOT NULL,
    "rangee"  text NOT NULL,
    "numero"  bigint NOT NULL
);

-- =============================================================================
-- SÉANCES (film + salle + créneau)
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_seance" (
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
CREATE TABLE IF NOT EXISTS "cine_pass_structure" (
    "id"       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "type"     text NOT NULL,   -- 'CINEMA' | 'VENUE' | 'ORGANIZER'
    "name"     text NOT NULL,
    "city"     text NOT NULL,
    "address"  text,
    "website"  text,
    "phone"    text,
    "cinemaId" uuid
);

CREATE INDEX IF NOT EXISTS "cine_pass_structure_type_city_idx"
    ON "cine_pass_structure" ("type", "city");

-- FK sur cinemaId (camelCase, aligné Serverpod)
ALTER TABLE "cine_pass_structure"
    ADD CONSTRAINT "cine_pass_structure_fk_0"
    FOREIGN KEY ("cinemaId") REFERENCES "cine_pass_cinema"("id")
    ON DELETE SET NULL ON UPDATE NO ACTION;

-- =============================================================================
-- ÉVÉNEMENTS (concerts, théâtre, etc. — colonnes en camelCase)
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_evenement" (
    "id"               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "createdAt"        timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "titre"            text NOT NULL,
    "categorie"        text NOT NULL,
    "event_type"       text NOT NULL DEFAULT 'AUTRE',
    "event_subtype"    text,
    "custom_type_label" text,
    "event_language"   text,
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
    "structureId"      uuid,   -- FK ajoutée ci-dessous après les contraintes Serverpod
    "archived"         boolean NOT NULL DEFAULT false
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'cine_pass_evenement_event_type_check'
  ) THEN
    ALTER TABLE "cine_pass_evenement"
      ADD CONSTRAINT "cine_pass_evenement_event_type_check"
      CHECK ("event_type" IN ('FILM', 'FESTIVAL', 'STANDUP', 'CONCERT', 'THEATRE', 'AUTRE'));
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS "cine_pass_evenement_event_type_idx"
    ON "cine_pass_evenement" ("event_type");

CREATE INDEX IF NOT EXISTS "cine_pass_evenement_event_subtype_idx"
    ON "cine_pass_evenement" ("event_subtype");

-- Archivage logique (masqué du catalogue public, visible responsable).
CREATE INDEX IF NOT EXISTS "cine_pass_evenement_archived_idx"
    ON "cine_pass_evenement" ("archived");

-- Détails spécifiques par type d'événement.
CREATE TABLE IF NOT EXISTS "cine_pass_event_film_details" (
    "event_id"          uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "film_genre"        text NOT NULL,
    "synopsis"          text,
    "director"          text,
    "duration_min"      integer,
    "film_format"       text,
    "original_language" text,
    "age_rating"        text,
    "created_at"        timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"        timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT "cine_pass_event_film_duration_check" CHECK ("duration_min" IS NULL OR "duration_min" > 0)
);

CREATE INDEX IF NOT EXISTS "cine_pass_event_film_genre_idx"
    ON "cine_pass_event_film_details" ("film_genre");

CREATE INDEX IF NOT EXISTS "cine_pass_event_film_director_idx"
    ON "cine_pass_event_film_details" ("director");

CREATE TABLE IF NOT EXISTS "cine_pass_event_festival_details" (
    "event_id"        uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "theme"           text,
    "edition_label"   text,
    "program_summary" text,
    "headliners"      text,
    "pass_info"       text,
    "created_at"      timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"      timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_event_festival_theme_idx"
    ON "cine_pass_event_festival_details" ("theme");

CREATE TABLE IF NOT EXISTS "cine_pass_event_standup_details" (
    "event_id"     uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "main_artist"  text NOT NULL,
    "guests"       text,
    "language"     text,
    "show_format"  text,
    "created_at"   timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"   timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_event_standup_main_artist_idx"
    ON "cine_pass_event_standup_details" ("main_artist");

CREATE TABLE IF NOT EXISTS "cine_pass_event_concert_details" (
    "event_id"     uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "artist"       text NOT NULL,
    "music_genre"  text,
    "opening_act"  text,
    "lineup"       text,
    "created_at"   timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"   timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_event_concert_artist_idx"
    ON "cine_pass_event_concert_details" ("artist");

CREATE INDEX IF NOT EXISTS "cine_pass_event_concert_genre_idx"
    ON "cine_pass_event_concert_details" ("music_genre");

CREATE TABLE IF NOT EXISTS "cine_pass_event_theatre_details" (
    "event_id"        uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "author"          text,
    "stage_director"  text,
    "troupe"          text,
    "play_style"      text,
    "created_at"      timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"      timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_event_theatre_author_idx"
    ON "cine_pass_event_theatre_details" ("author");

CREATE TABLE IF NOT EXISTS "cine_pass_event_other_details" (
    "event_id"           uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "custom_fields_json" jsonb,
    "created_at"         timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"         timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_event_other_details_json_idx"
    ON "cine_pass_event_other_details" USING GIN ("custom_fields_json");

CREATE OR REPLACE FUNCTION "cine_pass_touch_updated_at"()
RETURNS trigger AS $$
BEGIN
    NEW."updated_at" = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trg_film_details_touch_updated_at"
    BEFORE UPDATE ON "cine_pass_event_film_details"
    FOR EACH ROW
    EXECUTE FUNCTION "cine_pass_touch_updated_at"();

CREATE TRIGGER "trg_festival_details_touch_updated_at"
    BEFORE UPDATE ON "cine_pass_event_festival_details"
    FOR EACH ROW
    EXECUTE FUNCTION "cine_pass_touch_updated_at"();

CREATE TRIGGER "trg_standup_details_touch_updated_at"
    BEFORE UPDATE ON "cine_pass_event_standup_details"
    FOR EACH ROW
    EXECUTE FUNCTION "cine_pass_touch_updated_at"();

CREATE TRIGGER "trg_concert_details_touch_updated_at"
    BEFORE UPDATE ON "cine_pass_event_concert_details"
    FOR EACH ROW
    EXECUTE FUNCTION "cine_pass_touch_updated_at"();

CREATE TRIGGER "trg_theatre_details_touch_updated_at"
    BEFORE UPDATE ON "cine_pass_event_theatre_details"
    FOR EACH ROW
    EXECUTE FUNCTION "cine_pass_touch_updated_at"();

CREATE TRIGGER "trg_other_details_touch_updated_at"
    BEFORE UPDATE ON "cine_pass_event_other_details"
    FOR EACH ROW
    EXECUTE FUNCTION "cine_pass_touch_updated_at"();

CREATE OR REPLACE VIEW "cine_pass_event_search_v" AS
SELECT
    e."id"                AS event_id,
    e."event_type"        AS event_type,
    e."event_subtype"     AS event_subtype,
    e."custom_type_label" AS custom_type_label,
    e."event_language"    AS event_language,
    e."titre"             AS title,
    e."description"       AS description,
    e."lieu"              AS location,
    e."ville"             AS city,
    e."eventDate"         AS event_date,
    e."eventTime"         AS event_time,
    e."structureId"       AS structure_id,
    f."film_genre"        AS film_genre,
    f."director"          AS film_director,
    f."film_format"       AS film_format,
    fe."theme"            AS festival_theme,
    s."main_artist"       AS standup_main_artist,
    c."artist"            AS concert_artist,
    c."music_genre"       AS concert_music_genre,
    t."author"            AS theatre_author
FROM "cine_pass_evenement" e
LEFT JOIN "cine_pass_event_film_details" f
    ON f."event_id" = e."id"
LEFT JOIN "cine_pass_event_festival_details" fe
    ON fe."event_id" = e."id"
LEFT JOIN "cine_pass_event_standup_details" s
    ON s."event_id" = e."id"
LEFT JOIN "cine_pass_event_concert_details" c
    ON c."event_id" = e."id"
LEFT JOIN "cine_pass_event_theatre_details" t
    ON t."event_id" = e."id";

-- =============================================================================
-- CONFIG RÉSERVATION ÉVÉNEMENT (mode, types de billets, options)
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_event_reservation_config" (
    "id"                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "event_id"             uuid NOT NULL UNIQUE REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "reservation_mode"     text NOT NULL DEFAULT 'SANS_SIEGES', -- SANS_SIEGES | AVEC_SIEGES
    "max_tickets_per_order" integer NOT NULL DEFAULT 8,
    "adjacent_best_effort" boolean NOT NULL DEFAULT true,
    "created_at"           timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"           timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS "cine_pass_event_ticket_type" (
    "id"               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "event_id"         uuid NOT NULL REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "code"             text NOT NULL,      -- STANDARD | VIP | EARLY_BIRD | etc.
    "label"            text NOT NULL,      -- Libellé affiché au client
    "price"            numeric(10,2) NOT NULL,
    "quota"            integer NOT NULL,
    "active"           boolean NOT NULL DEFAULT true,
    "sort_order"       integer NOT NULL DEFAULT 0,
    "created_at"       timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"       timestamp without time zone NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS "cine_pass_event_ticket_type_event_code_uniq"
    ON "cine_pass_event_ticket_type" ("event_id", "code");

CREATE TABLE IF NOT EXISTS "cine_pass_event_ticket_option" (
    "id"               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "event_id"         uuid NOT NULL REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "ticket_type_code" text NOT NULL,      -- Référence logique à cine_pass_event_ticket_type.code
    "option_code"      text NOT NULL,      -- PARKING | POPCORN | BOISSON | etc.
    "label"            text NOT NULL,
    "price"            numeric(10,2) NOT NULL DEFAULT 0, -- 0 => inclus
    "included"         boolean NOT NULL DEFAULT false,   -- true => inclus
    "active"           boolean NOT NULL DEFAULT true,
    "sort_order"       integer NOT NULL DEFAULT 0,
    "created_at"       timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"       timestamp without time zone NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS "cine_pass_event_ticket_option_uniq"
    ON "cine_pass_event_ticket_option" ("event_id", "ticket_type_code", "option_code");

-- =============================================================================
-- PLAN DE SIÈGES ÉVÉNEMENT (AVEC_SIEGES) — défini par le responsable
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_event_seat" (
    "id"         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "event_id"   uuid NOT NULL REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "label"      text NOT NULL,
    "row_index"  integer NOT NULL DEFAULT 0,
    "col_index"  integer NOT NULL DEFAULT 0,
    "blocked"    boolean NOT NULL DEFAULT false,
    "zone"       text NOT NULL DEFAULT '',
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS "cine_pass_event_seat_event_label_lower_uniq"
    ON "cine_pass_event_seat" ("event_id", lower(trim("label")));

CREATE INDEX IF NOT EXISTS "cine_pass_event_seat_event_idx"
    ON "cine_pass_event_seat" ("event_id");

-- FK : structureId (camelCase, aligné Serverpod)
ALTER TABLE "cine_pass_evenement"
    ADD CONSTRAINT "cine_pass_evenement_fk_0"
    FOREIGN KEY ("structureId") REFERENCES "cine_pass_structure"("id")
    ON DELETE SET NULL ON UPDATE NO ACTION;

-- =============================================================================
-- RÉSERVATIONS (film OU événement)
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_reservation" (
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

CREATE UNIQUE INDEX IF NOT EXISTS "cine_pass_reservation_numero_idx"
    ON "cine_pass_reservation" USING btree ("numero");
CREATE INDEX IF NOT EXISTS "cine_pass_reservation_user_idx"
    ON "cine_pass_reservation" USING btree ("user_id");
CREATE INDEX IF NOT EXISTS "cine_pass_reservation_seance_idx"
    ON "cine_pass_reservation" USING btree ("seance_id");
CREATE INDEX IF NOT EXISTS "cine_pass_reservation_evenement_idx"
    ON "cine_pass_reservation" USING btree ("evenement_id");
CREATE INDEX IF NOT EXISTS "cine_pass_reservation_created_idx"
    ON "cine_pass_reservation" USING btree ("created_at");

-- =============================================================================
-- BILLETS (un par place ; pour événement pas de siège)
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_billet" (
    "id"              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "reservation_id"  uuid NOT NULL REFERENCES "cine_pass_reservation"("id") ON DELETE CASCADE,
    "siege_id"        uuid REFERENCES "cine_pass_siege"("id") ON DELETE SET NULL,
    "ticket_type"     text NOT NULL DEFAULT 'normal',
    "option_parking"  boolean NOT NULL DEFAULT false,
    "option_popcorn"  boolean NOT NULL DEFAULT false,
    "option_boisson"  boolean NOT NULL DEFAULT false,
    "prix"            numeric(10,2) NOT NULL,
    -- Libellé siège / placement pour événements (AVEC_SIEGES), sans lien cine_pass_siege.
    "placement_label" text,
    "created_at"      timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_billet_reservation_idx"
    ON "cine_pass_billet" USING btree ("reservation_id");
CREATE INDEX IF NOT EXISTS "cine_pass_billet_siege_idx"
    ON "cine_pass_billet" USING btree ("siege_id");

-- =============================================================================
-- PAIEMENTS
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_paiement" (
    "id"             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "reservation_id" uuid NOT NULL REFERENCES "cine_pass_reservation"("id") ON DELETE CASCADE,
    "montant"        numeric(10,2) NOT NULL,
    "methode"        text,
    "statut"         text NOT NULL DEFAULT 'pending',
    "external_id"    text,
    "created_at"     timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_paiement_reservation_idx"
    ON "cine_pass_paiement" USING btree ("reservation_id");

-- =============================================================================
-- FAVORIS (film ou cinéma)
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_favori" (
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

CREATE UNIQUE INDEX IF NOT EXISTS "cine_pass_favori_user_film_idx"
    ON "cine_pass_favori" USING btree ("user_id", "film_id")   WHERE "film_id"   IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS "cine_pass_favori_user_cinema_idx"
    ON "cine_pass_favori" USING btree ("user_id", "cinema_id") WHERE "cinema_id" IS NOT NULL;
CREATE INDEX IF NOT EXISTS "cine_pass_favori_user_idx"
    ON "cine_pass_favori" USING btree ("user_id");

-- =============================================================================
-- FAQ
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_faq" (
    "id"         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "question"   text NOT NULL,
    "reponse"    text NOT NULL,
    "ordre"      integer NOT NULL DEFAULT 0,
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_faq_ordre_idx"
    ON "cine_pass_faq" USING btree ("ordre");

-- =============================================================================
-- RÔLE ADMIN (lien user -> rôle)
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_user_role" (
    "id"      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id" uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "role"    text NOT NULL DEFAULT 'client'   -- client | responsable | admin
);

CREATE INDEX IF NOT EXISTS "cine_pass_user_role_user_idx"
    ON "cine_pass_user_role" USING btree ("user_id");

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'cine_pass_user_role_role_check'
  ) THEN
    ALTER TABLE "cine_pass_user_role"
      ADD CONSTRAINT "cine_pass_user_role_role_check"
      CHECK ("role" IN ('client', 'responsable', 'admin'));
  END IF;
END $$;

-- =============================================================================
-- ADMIN (table utilisée par le backend ; synchro via cine_pass_user_role)
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_admin_user" (
    "id"         bigserial PRIMARY KEY,
    "user_id"    uuid NOT NULL UNIQUE,
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_admin_user_user_idx"
    ON "cine_pass_admin_user" ("user_id");

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
CREATE TABLE IF NOT EXISTS "cine_pass_responsable_request" (
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
    "rejection_reason" text,
    "professional_email" text,
    "password_hash"      text
);

CREATE INDEX IF NOT EXISTS "cine_pass_responsable_request_user_idx"
    ON "cine_pass_responsable_request" ("user_id");
CREATE INDEX IF NOT EXISTS "cine_pass_responsable_request_status_idx"
    ON "cine_pass_responsable_request" ("status");

CREATE UNIQUE INDEX IF NOT EXISTS "cine_pass_responsable_request_pro_email_idx"
    ON "cine_pass_responsable_request" ("professional_email")
    WHERE "professional_email" IS NOT NULL;

COMMENT ON COLUMN "cine_pass_responsable_request"."professional_email" IS
  'Email professionnel : connexion espace responsable.';
COMMENT ON COLUMN "cine_pass_responsable_request"."password_hash" IS
  'Hash mot de passe (soumission demande responsable).';

-- =============================================================================
-- RESPONSABLES — ROLE USER (source de verite du role)
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_responsable_user" (
    "id"         bigserial PRIMARY KEY,
    "user_id"    uuid NOT NULL UNIQUE,
    "active"     boolean NOT NULL DEFAULT true,
    "created_at" timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at" timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT "cine_pass_responsable_user_user_fk"
      FOREIGN KEY ("user_id") REFERENCES "serverpod_auth_core_user"("id")
      ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS "cine_pass_responsable_user_active_idx"
    ON "cine_pass_responsable_user" ("active");

-- =============================================================================
-- RESPONSABLES — ASSIGNMENTS (lien user <-> structure)
-- =============================================================================
CREATE TABLE IF NOT EXISTS "cine_pass_responsable_assignment" (
    "id"           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id"      uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "structure_id" uuid NOT NULL REFERENCES "cine_pass_structure"("id")      ON DELETE CASCADE,
    "active"       boolean NOT NULL DEFAULT true,
    "created_at"   timestamp without time zone NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS "cine_pass_responsable_assignment_uniq"
    ON "cine_pass_responsable_assignment" ("user_id", "structure_id");
CREATE INDEX IF NOT EXISTS "cine_pass_responsable_assignment_struct_idx"
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

-- ---------------------------------------------------------------------------
-- Phase 2 — Fonctions, trigger de synchro des rôles, vue, helpers SQL
-- (les tables cine_pass_admin_user, cine_pass_user_role, etc. sont déjà créées.)
-- ---------------------------------------------------------------------------
BEGIN;

CREATE OR REPLACE FUNCTION "cine_pass_sync_effective_roles"(p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_is_admin boolean := false;
  v_is_responsable boolean := false;
  v_has_assignment_table boolean := false;
BEGIN
  SELECT EXISTS(
    SELECT 1
    FROM "cine_pass_user_role"
    WHERE "user_id" = p_user_id AND "role" = 'admin'
  ) INTO v_is_admin;

  SELECT EXISTS(
    SELECT 1
    FROM "cine_pass_user_role"
    WHERE "user_id" = p_user_id AND "role" = 'responsable'
  ) INTO v_is_responsable;

  -- Admin -> cine_pass_admin_user
  IF v_is_admin THEN
    INSERT INTO "cine_pass_admin_user" ("user_id")
    VALUES (p_user_id)
    ON CONFLICT ("user_id") DO NOTHING;
  ELSE
    DELETE FROM "cine_pass_admin_user"
    WHERE "user_id" = p_user_id;
  END IF;

  -- Responsable -> cine_pass_responsable_user (+ assignments)
  IF v_is_responsable THEN
    INSERT INTO "cine_pass_responsable_user" ("user_id", "active", "updated_at")
    VALUES (p_user_id, true, now())
    ON CONFLICT ("user_id") DO UPDATE
      SET "active" = true,
          "updated_at" = now();
  ELSE
    UPDATE "cine_pass_responsable_user"
      SET "active" = false,
          "updated_at" = now()
      WHERE "user_id" = p_user_id;

    -- IMPORTANT: backend responsable utilise cine_pass_responsable_assignment.active=true.
    SELECT EXISTS(
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public' AND table_name = 'cine_pass_responsable_assignment'
    ) INTO v_has_assignment_table;

    IF v_has_assignment_table THEN
      UPDATE "cine_pass_responsable_assignment"
        SET "active" = false
        WHERE "user_id" = p_user_id;
    END IF;
  END IF;
END;
$$;

-- -----------------------------------------------------------------------------
-- Trigger : synchronise au moindre changement de rôle
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION "cine_pass_user_role_sync_trigger_fn"()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_uid uuid;
BEGIN
  v_uid := COALESCE(NEW."user_id", OLD."user_id");
  IF v_uid IS NOT NULL THEN
    PERFORM "cine_pass_sync_effective_roles"(v_uid);
  END IF;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'cine_pass_user_role_sync_trg'
  ) THEN
    CREATE TRIGGER "cine_pass_user_role_sync_trg"
    AFTER INSERT OR UPDATE OR DELETE ON "cine_pass_user_role"
    FOR EACH ROW
    EXECUTE FUNCTION "cine_pass_user_role_sync_trigger_fn"();
  END IF;
END $$;

-- -----------------------------------------------------------------------------
-- Helpers : promouvoir / assigner via email & structureId
-- -----------------------------------------------------------------------------
-- 1) Promote admin by email
CREATE OR REPLACE FUNCTION "cine_pass_set_role_by_email"(p_email text, p_role text)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_uid uuid;
BEGIN
  IF p_email IS NULL OR trim(p_email) = '' THEN
    RAISE EXCEPTION 'email vide';
  END IF;
  IF p_role IS NULL OR trim(p_role) = '' THEN
    RAISE EXCEPTION 'role vide';
  END IF;

  SELECT "authUserId" INTO v_uid
  FROM "serverpod_auth_core_profile"
  WHERE lower("email") = lower(p_email)
  LIMIT 1;

  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'aucun user auth pour email=%', p_email;
  END IF;

  DELETE FROM "cine_pass_user_role"
  WHERE "user_id" = v_uid;

  INSERT INTO "cine_pass_user_role" ("user_id", "role")
  VALUES (v_uid, lower(trim(p_role)));

  PERFORM "cine_pass_sync_effective_roles"(v_uid);
END;
$$;

-- 2) Assign responsible to a structure
CREATE OR REPLACE FUNCTION "cine_pass_assign_responsable_to_structure"(
  p_email text,
  p_structure_id uuid,
  p_active boolean DEFAULT true
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_uid uuid;
BEGIN
  SELECT "authUserId" INTO v_uid
  FROM "serverpod_auth_core_profile"
  WHERE lower("email") = lower(p_email)
  LIMIT 1;

  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'aucun user auth pour email=%', p_email;
  END IF;

  PERFORM "cine_pass_set_role_by_email"(p_email, 'responsable');

  INSERT INTO "cine_pass_responsable_assignment" ("user_id", "structure_id", "active")
  VALUES (v_uid, p_structure_id, p_active)
  ON CONFLICT ("user_id", "structure_id") DO UPDATE
    SET "active" = EXCLUDED."active";

  PERFORM "cine_pass_sync_effective_roles"(v_uid);
END;
$$;

-- -----------------------------------------------------------------------------
-- Vue utile
-- -----------------------------------------------------------------------------
-- Role effective (colonne unique) via logique backend
CREATE OR REPLACE FUNCTION "cine_pass_effective_role"(p_user_id uuid)
RETURNS text
LANGUAGE plpgsql
AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM "cine_pass_admin_user" a WHERE a."user_id" = p_user_id
  ) THEN
    RETURN 'admin';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM "cine_pass_responsable_assignment" ra
    WHERE ra."user_id" = p_user_id AND ra."active" = true
  ) THEN
    RETURN 'responsable';
  END IF;

  RETURN 'client';
END;
$$;

CREATE OR REPLACE VIEW "cine_pass_effective_roles" AS
SELECT
  x."user_id",
  "cine_pass_effective_role"(x."user_id") AS "role",
  ("cine_pass_effective_role"(x."user_id") = 'admin') AS "is_admin",
  ("cine_pass_effective_role"(x."user_id") = 'responsable') AS "is_responsable"
FROM (
  SELECT "user_id" FROM "cine_pass_user_role"
  UNION
  SELECT "user_id" FROM "cine_pass_admin_user"
  UNION
  SELECT "user_id" FROM "cine_pass_responsable_assignment"
) x;

COMMIT;