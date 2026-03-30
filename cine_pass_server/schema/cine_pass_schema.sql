-- =============================================================================
-- CinePass — SCHÉMA MÉTIER UNIQUE (PostgreSQL)
-- Source de vérité : reset DB, seed, alignement avec le backend (cine_pass_endpoint).
-- À exécuter après les migrations Serverpod (auth : serverpod_auth_core_user).
--
-- Colonnes camelCase sur les tables Serverpod (evenement, structure, etc.).
-- =============================================================================

BEGIN;

-- =============================================================================
-- PHASE 0 — Reset complet (commenter cette section pour ne pas tout supprimer)
-- =============================================================================
DROP VIEW IF EXISTS "cine_pass_event_search_v" CASCADE;
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

DROP TABLE IF EXISTS "cine_pass_favori_evenement" CASCADE;

DROP TABLE IF EXISTS "cine_pass_role_change_approval" CASCADE;
DROP TABLE IF EXISTS "cine_pass_role_change_request" CASCADE;

DROP TABLE IF EXISTS "cine_pass_evenement" CASCADE;

DROP TABLE IF EXISTS "cine_pass_faq" CASCADE;
DROP TABLE IF EXISTS "cine_pass_user_profile" CASCADE;
DROP TABLE IF EXISTS "cine_pass_user_role" CASCADE;
DROP TABLE IF EXISTS "cine_pass_admin_user" CASCADE;

DROP TABLE IF EXISTS "cine_pass_responsable_assignment" CASCADE;
DROP TABLE IF EXISTS "cine_pass_responsable_user" CASCADE;
DROP TABLE IF EXISTS "cine_pass_structure" CASCADE;
DROP TABLE IF EXISTS "cine_pass_cinema" CASCADE;
DROP TABLE IF EXISTS "cine_pass_responsable_request" CASCADE;

-- =============================================================================
-- STRUCTURES (avant EVENEMENT : FK structureId)
-- =============================================================================
CREATE TABLE "cine_pass_structure" (
    "id"       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "type"     text NOT NULL,
    "name"     text NOT NULL,
    "city"     text NOT NULL,
    "address"  text,
    "website"  text,
    "phone"    text
);

CREATE INDEX "cine_pass_structure_type_city_idx"
    ON "cine_pass_structure" ("type", "city");

-- =============================================================================
-- ÉVÉNEMENTS (+ types / archive — aligné evenement.spy.yaml)
-- =============================================================================
CREATE TABLE "cine_pass_evenement" (
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
    "archived"         boolean NOT NULL DEFAULT false,
    "structureId"      uuid,
    CONSTRAINT "cine_pass_evenement_event_type_check"
        CHECK ("event_type" IN ('FILM', 'FESTIVAL', 'STANDUP', 'CONCERT', 'THEATRE', 'AUTRE'))
);

CREATE INDEX "cine_pass_evenement_event_type_idx"
    ON "cine_pass_evenement" ("event_type");
CREATE INDEX "cine_pass_evenement_event_subtype_idx"
    ON "cine_pass_evenement" ("event_subtype");
CREATE INDEX "cine_pass_evenement_archived_idx"
    ON "cine_pass_evenement" ("archived");

ALTER TABLE "cine_pass_evenement"
    ADD CONSTRAINT "cine_pass_evenement_fk_0"
    FOREIGN KEY ("structureId") REFERENCES "cine_pass_structure"("id")
    ON DELETE SET NULL ON UPDATE NO ACTION;

-- =============================================================================
-- Détails par type d’événement (backend : upsert par type)
-- =============================================================================
CREATE TABLE "cine_pass_event_film_details" (
    "event_id"           uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "film_genre"         text NOT NULL,
    "synopsis"           text,
    "director"           text,
    "duration_min"       integer,
    "film_format"        text,
    "original_language"  text,
    "age_rating"         text,
    "created_at"         timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"         timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT "cine_pass_event_film_duration_check"
        CHECK ("duration_min" IS NULL OR "duration_min" > 0)
);

CREATE INDEX "cine_pass_event_film_genre_idx"
    ON "cine_pass_event_film_details" ("film_genre");
CREATE INDEX "cine_pass_event_film_director_idx"
    ON "cine_pass_event_film_details" ("director");

CREATE TABLE "cine_pass_event_festival_details" (
    "event_id"           uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "theme"              text,
    "edition_label"      text,
    "program_summary"    text,
    "headliners"         text,
    "pass_info"          text,
    "created_at"         timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"         timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_event_festival_theme_idx"
    ON "cine_pass_event_festival_details" ("theme");

CREATE TABLE "cine_pass_event_standup_details" (
    "event_id"           uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "main_artist"        text NOT NULL,
    "guests"             text,
    "language"           text,
    "show_format"        text,
    "created_at"         timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"         timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_event_standup_main_artist_idx"
    ON "cine_pass_event_standup_details" ("main_artist");

CREATE TABLE "cine_pass_event_concert_details" (
    "event_id"           uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "artist"             text NOT NULL,
    "music_genre"        text,
    "opening_act"        text,
    "lineup"             text,
    "created_at"         timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"         timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_event_concert_artist_idx"
    ON "cine_pass_event_concert_details" ("artist");
CREATE INDEX "cine_pass_event_concert_genre_idx"
    ON "cine_pass_event_concert_details" ("music_genre");

CREATE TABLE "cine_pass_event_theatre_details" (
    "event_id"           uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "author"             text,
    "stage_director"     text,
    "troupe"             text,
    "play_style"         text,
    "created_at"         timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"         timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_event_theatre_author_idx"
    ON "cine_pass_event_theatre_details" ("author");

CREATE TABLE "cine_pass_event_other_details" (
    "event_id"           uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "custom_fields_json" jsonb,
    "created_at"         timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"         timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_event_other_details_json_idx"
    ON "cine_pass_event_other_details" USING GIN ("custom_fields_json");

-- =============================================================================
-- Config réservation / types de billets / options (événements)
-- =============================================================================
CREATE TABLE "cine_pass_event_reservation_config" (
    "event_id"               uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "reservation_mode"       text NOT NULL DEFAULT 'LIBRE',
    "max_tickets_per_order"  integer NOT NULL DEFAULT 8,
    "adjacent_best_effort"   boolean NOT NULL DEFAULT false,
    "updated_at"             timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TABLE "cine_pass_event_ticket_type" (
    "id"          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "event_id"    uuid NOT NULL REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "code"        text NOT NULL,
    "label"       text NOT NULL,
    "price"       double precision NOT NULL,
    "quota"       integer NOT NULL DEFAULT 0,
    "active"      boolean NOT NULL DEFAULT true,
    "sort_order"  integer NOT NULL DEFAULT 0,
    "updated_at"  timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT "cine_pass_event_ticket_type_event_code_uniq" UNIQUE ("event_id", "code")
);

CREATE INDEX "cine_pass_event_ticket_type_event_idx"
    ON "cine_pass_event_ticket_type" ("event_id");

CREATE TABLE "cine_pass_event_ticket_option" (
    "id"                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "event_id"           uuid NOT NULL REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "ticket_type_code"   text NOT NULL,
    "option_code"        text NOT NULL,
    "label"              text NOT NULL,
    "price"              double precision NOT NULL,
    "included"           boolean NOT NULL DEFAULT false,
    "active"             boolean NOT NULL DEFAULT true,
    "sort_order"         integer NOT NULL DEFAULT 0,
    "updated_at"         timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT "cine_pass_event_ticket_option_event_ticket_opt_uniq"
        UNIQUE ("event_id", "ticket_type_code", "option_code")
);

CREATE INDEX "cine_pass_event_ticket_option_event_idx"
    ON "cine_pass_event_ticket_option" ("event_id");

-- =============================================================================
-- Plan de sièges (mode AVEC_SIEGES)
-- =============================================================================
CREATE TABLE "cine_pass_event_seat" (
    "id"         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "event_id"   uuid NOT NULL REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "label"      text NOT NULL,
    "row_index"  integer NOT NULL DEFAULT 0,
    "col_index"  integer NOT NULL DEFAULT 0,
    "blocked"    boolean NOT NULL DEFAULT false,
    "zone"       text NOT NULL DEFAULT '',
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX "cine_pass_event_seat_event_label_lower_uniq"
    ON "cine_pass_event_seat" ("event_id", lower(trim("label")));
CREATE INDEX "cine_pass_event_seat_event_idx"
    ON "cine_pass_event_seat" ("event_id");

-- =============================================================================
-- RÉSERVATIONS & BILLETS & PAIEMENTS
-- =============================================================================
CREATE TABLE "cine_pass_reservation" (
    "id"           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id"      uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "evenement_id" uuid NOT NULL REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "numero"       text NOT NULL,
    "statut"       text NOT NULL DEFAULT 'pending',
    "total_amount" numeric(10,2) NOT NULL,
    "session_at"   timestamp without time zone,
    "created_at"   timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at"   timestamp without time zone NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX "cine_pass_reservation_numero_idx"
    ON "cine_pass_reservation" USING btree ("numero");
CREATE INDEX "cine_pass_reservation_user_idx"
    ON "cine_pass_reservation" USING btree ("user_id");
CREATE INDEX "cine_pass_reservation_evenement_idx"
    ON "cine_pass_reservation" USING btree ("evenement_id");
CREATE INDEX "cine_pass_reservation_created_idx"
    ON "cine_pass_reservation" USING btree ("created_at");

CREATE TABLE "cine_pass_billet" (
    "id"              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "reservation_id"  uuid NOT NULL REFERENCES "cine_pass_reservation"("id") ON DELETE CASCADE,
    "ticket_type"     text NOT NULL DEFAULT 'normal',
    "option_parking"  boolean NOT NULL DEFAULT false,
    "option_popcorn"  boolean NOT NULL DEFAULT false,
    "option_boisson"  boolean NOT NULL DEFAULT false,
    "prix"            numeric(10,2) NOT NULL,
    "statut"          text NOT NULL DEFAULT 'paid',
    "placement_label" text,
    "created_at"      timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_billet_reservation_idx"
    ON "cine_pass_billet" USING btree ("reservation_id");

-- =============================================================================
-- FAVORIS (événements uniquement)
-- =============================================================================
CREATE TABLE "cine_pass_favori_evenement" (
    "id"         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id"    uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "event_id"   uuid NOT NULL REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
    "created_at" timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT "cine_pass_favori_evenement_user_event_uniq" UNIQUE ("user_id", "event_id")
);

CREATE INDEX "cine_pass_favori_evenement_user_idx"
    ON "cine_pass_favori_evenement" ("user_id");

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
-- Rôles & profil
-- =============================================================================
CREATE TABLE "cine_pass_user_role" (
    "id"         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id"    uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "role"       text NOT NULL,
    "status"     text NOT NULL DEFAULT 'actif',
    "created_at" timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at" timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT "cine_pass_user_role_role_check"
        CHECK ("role" IN ('client', 'responsable', 'admin')),
    CONSTRAINT "cine_pass_user_role_status_check"
        CHECK ("status" IN ('actif', 'inactif', 'bloqué', 'banni'))
);

CREATE UNIQUE INDEX "cine_pass_user_role_user_role_uniq"
    ON "cine_pass_user_role" ("user_id", "role");

CREATE INDEX "cine_pass_user_role_user_idx"
    ON "cine_pass_user_role" ("user_id");

CREATE INDEX "cine_pass_user_role_status_idx"
    ON "cine_pass_user_role" ("status");

CREATE TABLE "cine_pass_role_change_request" (
    "id"                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id"           uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "from_role"         text NOT NULL,
    "to_role"           text NOT NULL,
    "requested_by"      uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "status"            text NOT NULL DEFAULT 'pending',
    "approvals_count"   integer NOT NULL DEFAULT 0,
    "rejection_reason"  text,
    "created_at"        timestamp without time zone NOT NULL DEFAULT now(),
    "expires_at"        timestamp without time zone NOT NULL DEFAULT (now() + interval '7 days')
);

CREATE INDEX "cine_pass_role_change_request_user_idx"
    ON "cine_pass_role_change_request" ("user_id");

CREATE INDEX "cine_pass_role_change_request_status_idx"
    ON "cine_pass_role_change_request" ("status");

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

CREATE TABLE "cine_pass_user_profile" (
    "user_id" uuid PRIMARY KEY REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "display_name" text,
    "phone" text,
    "birth_date" date
);

-- =============================================================================
-- Responsables
-- =============================================================================
CREATE TABLE "cine_pass_responsable_request" (
    "id"                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id"           uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "structure_type"    text NOT NULL,
    "structure_name"    text NOT NULL,
    "structure_city"    text NOT NULL,
    "structure_address" text,
    "structure_website" text,
    "structure_siret"   text,
    "structure_phone"   text,
    "contact_role"      text,
    "description"       text NOT NULL,
    "social_links"      text,
    "professional_email" text,
    "password_hash"      text,
    "status"            text NOT NULL DEFAULT 'PENDING',
    "created_at"        timestamp without time zone NOT NULL DEFAULT now(),
    "decided_at"        timestamp without time zone,
    "admin_id"          uuid REFERENCES "serverpod_auth_core_user"("id") ON DELETE SET NULL,
    "rejection_reason"  text
);

CREATE UNIQUE INDEX "cine_pass_responsable_request_pro_email_idx"
    ON "cine_pass_responsable_request" ("professional_email")
    WHERE "professional_email" IS NOT NULL;

CREATE INDEX "cine_pass_responsable_request_user_idx"
    ON "cine_pass_responsable_request" ("user_id");
CREATE INDEX "cine_pass_responsable_request_status_idx"
    ON "cine_pass_responsable_request" ("status");

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
-- Tables « effectives » admin / responsable (lus par le backend)
-- =============================================================================
CREATE TABLE "cine_pass_admin_user" (
    "id"         bigserial PRIMARY KEY,
    "user_id"    uuid NOT NULL UNIQUE REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_admin_user_user_idx"
    ON "cine_pass_admin_user" ("user_id");

CREATE TABLE "cine_pass_responsable_user" (
    "id"         bigserial PRIMARY KEY,
    "user_id"    uuid NOT NULL UNIQUE REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
    "active"     boolean NOT NULL DEFAULT true,
    "created_at" timestamp without time zone NOT NULL DEFAULT now(),
    "updated_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX "cine_pass_responsable_user_active_idx"
    ON "cine_pass_responsable_user" ("active");

-- =============================================================================
-- Triggers updated_at (détails événement)
-- =============================================================================
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

-- =============================================================================
-- Vue recherche / filtres (optionnelle)
-- =============================================================================
CREATE OR REPLACE VIEW "cine_pass_event_search_v" AS
SELECT
  e."id"                              AS event_id,
  e."event_type"                      AS event_type,
  e."event_subtype"                   AS event_subtype,
  e."custom_type_label"               AS custom_type_label,
  e."titre"                           AS title,
  e."description"                     AS description,
  e."lieu"                            AS location,
  e."ville"                           AS city,
  e."eventDate"                       AS event_date,
  e."eventTime"                       AS event_time,
  e."structureId"                     AS structure_id,
  f."film_genre"                      AS film_genre,
  f."director"                        AS film_director,
  f."film_format"                     AS film_format,
  fe."theme"                          AS festival_theme,
  s."main_artist"                     AS standup_main_artist,
  c."artist"                          AS concert_artist,
  c."music_genre"                     AS concert_music_genre,
  t."author"                          AS theatre_author
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
-- Sync rôles SQL (cine_pass_user_role → admin_user / responsable_user)
-- =============================================================================
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

  IF v_is_admin THEN
    INSERT INTO "cine_pass_admin_user" ("user_id")
    VALUES (p_user_id)
    ON CONFLICT ("user_id") DO NOTHING;
  ELSE
    DELETE FROM "cine_pass_admin_user"
    WHERE "user_id" = p_user_id;
  END IF;

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

CREATE TRIGGER "cine_pass_user_role_sync_trg"
    AFTER INSERT OR UPDATE OR DELETE ON "cine_pass_user_role"
    FOR EACH ROW
    EXECUTE FUNCTION "cine_pass_user_role_sync_trigger_fn"();

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
