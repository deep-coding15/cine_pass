-- OBSOLÈTE : le schéma complet est dans `cine_pass_schema.sql` (un seul fichier).
-- =============================================================================
-- CinePass - Event Types Full Schema (conservé pour référence / diff)
-- Objectif: stockage relationnel complet des différents types d'événements
-- (Film, Festival, Stand-up, Concert, Théâtre, Autre) avec champs spécifiques.
--
-- Ce script est idempotent (IF NOT EXISTS / DO blocks).
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- 1) Table principale: extension de cine_pass_evenement
-- -----------------------------------------------------------------------------
ALTER TABLE "cine_pass_evenement"
  ADD COLUMN IF NOT EXISTS "event_type" text NOT NULL DEFAULT 'AUTRE',
  ADD COLUMN IF NOT EXISTS "event_subtype" text,
  ADD COLUMN IF NOT EXISTS "custom_type_label" text,
  ADD COLUMN IF NOT EXISTS "event_language" text,
  ADD COLUMN IF NOT EXISTS "archived" boolean NOT NULL DEFAULT false;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'cine_pass_evenement_event_type_check'
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

CREATE INDEX IF NOT EXISTS "cine_pass_evenement_archived_idx"
  ON "cine_pass_evenement" ("archived");

-- -----------------------------------------------------------------------------
-- 2) Détails spécifiques Film
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "cine_pass_event_film_details" (
  "event_id"           uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
  "film_genre"         text NOT NULL,         -- Action, Comédie, Drame...
  "synopsis"           text,
  "director"           text,
  "duration_min"       integer,
  "film_format"        text,                  -- Long métrage, Court métrage, Documentaire...
  "original_language"  text,
  "age_rating"         text,
  "created_at"         timestamp without time zone NOT NULL DEFAULT now(),
  "updated_at"         timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "cine_pass_event_film_duration_check" CHECK ("duration_min" IS NULL OR "duration_min" > 0)
);

CREATE INDEX IF NOT EXISTS "cine_pass_event_film_genre_idx"
  ON "cine_pass_event_film_details" ("film_genre");

CREATE INDEX IF NOT EXISTS "cine_pass_event_film_director_idx"
  ON "cine_pass_event_film_details" ("director");

-- -----------------------------------------------------------------------------
-- 3) Détails spécifiques Festival
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "cine_pass_event_festival_details" (
  "event_id"           uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
  "theme"              text,
  "edition_label"      text,                  -- Ex: 2026, 5e édition
  "program_summary"    text,
  "headliners"         text,
  "pass_info"          text,
  "created_at"         timestamp without time zone NOT NULL DEFAULT now(),
  "updated_at"         timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_event_festival_theme_idx"
  ON "cine_pass_event_festival_details" ("theme");

-- -----------------------------------------------------------------------------
-- 4) Détails spécifiques Stand-up
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "cine_pass_event_standup_details" (
  "event_id"           uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
  "main_artist"        text NOT NULL,
  "guests"             text,
  "language"           text,
  "show_format"        text,                  -- Solo, plateau, impro...
  "created_at"         timestamp without time zone NOT NULL DEFAULT now(),
  "updated_at"         timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_event_standup_main_artist_idx"
  ON "cine_pass_event_standup_details" ("main_artist");

-- -----------------------------------------------------------------------------
-- 5) Détails spécifiques Concert
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "cine_pass_event_concert_details" (
  "event_id"           uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
  "artist"             text NOT NULL,
  "music_genre"        text,
  "opening_act"        text,
  "lineup"             text,
  "created_at"         timestamp without time zone NOT NULL DEFAULT now(),
  "updated_at"         timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_event_concert_artist_idx"
  ON "cine_pass_event_concert_details" ("artist");

CREATE INDEX IF NOT EXISTS "cine_pass_event_concert_genre_idx"
  ON "cine_pass_event_concert_details" ("music_genre");

-- -----------------------------------------------------------------------------
-- 6) Détails spécifiques Théâtre
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "cine_pass_event_theatre_details" (
  "event_id"           uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
  "author"             text,
  "stage_director"     text,
  "troupe"             text,
  "play_style"         text,                  -- Classique, contemporain, musical...
  "created_at"         timestamp without time zone NOT NULL DEFAULT now(),
  "updated_at"         timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_event_theatre_author_idx"
  ON "cine_pass_event_theatre_details" ("author");

-- -----------------------------------------------------------------------------
-- 7) Détails spécifiques Autre
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "cine_pass_event_other_details" (
  "event_id"           uuid PRIMARY KEY REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
  "custom_fields_json" jsonb,                 -- Champs libres personnalisés
  "created_at"         timestamp without time zone NOT NULL DEFAULT now(),
  "updated_at"         timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_event_other_details_json_idx"
  ON "cine_pass_event_other_details" USING GIN ("custom_fields_json");

-- -----------------------------------------------------------------------------
-- 8) Trigger utilitaire updated_at
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION "cine_pass_touch_updated_at"()
RETURNS trigger AS $$
BEGIN
  NEW."updated_at" = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_film_details_touch_updated_at') THEN
    CREATE TRIGGER "trg_film_details_touch_updated_at"
      BEFORE UPDATE ON "cine_pass_event_film_details"
      FOR EACH ROW
      EXECUTE FUNCTION "cine_pass_touch_updated_at"();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_festival_details_touch_updated_at') THEN
    CREATE TRIGGER "trg_festival_details_touch_updated_at"
      BEFORE UPDATE ON "cine_pass_event_festival_details"
      FOR EACH ROW
      EXECUTE FUNCTION "cine_pass_touch_updated_at"();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_standup_details_touch_updated_at') THEN
    CREATE TRIGGER "trg_standup_details_touch_updated_at"
      BEFORE UPDATE ON "cine_pass_event_standup_details"
      FOR EACH ROW
      EXECUTE FUNCTION "cine_pass_touch_updated_at"();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_concert_details_touch_updated_at') THEN
    CREATE TRIGGER "trg_concert_details_touch_updated_at"
      BEFORE UPDATE ON "cine_pass_event_concert_details"
      FOR EACH ROW
      EXECUTE FUNCTION "cine_pass_touch_updated_at"();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_theatre_details_touch_updated_at') THEN
    CREATE TRIGGER "trg_theatre_details_touch_updated_at"
      BEFORE UPDATE ON "cine_pass_event_theatre_details"
      FOR EACH ROW
      EXECUTE FUNCTION "cine_pass_touch_updated_at"();
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_other_details_touch_updated_at') THEN
    CREATE TRIGGER "trg_other_details_touch_updated_at"
      BEFORE UPDATE ON "cine_pass_event_other_details"
      FOR EACH ROW
      EXECUTE FUNCTION "cine_pass_touch_updated_at"();
  END IF;
END $$;

-- -----------------------------------------------------------------------------
-- 9) Vue de lecture unifiée (utile pour filtres + search)
-- -----------------------------------------------------------------------------
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

COMMIT;

-- =============================================================================
-- Notes d'intégration backend (à appliquer dans CinePassEndpoint):
-- 1) createEvent/updateEvent:
--    - enregistrer event_type + table détail correspondante (upsert)
-- 2) getEvents/getEventById:
--    - exposer les champs spécifiques au type
-- 3) filtres:
--    - type + genre film + artiste concert + director film + etc.
-- =============================================================================

