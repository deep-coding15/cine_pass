-- Intégré dans `schema/cine_pass_schema.sql`. Ne plus utiliser seul sauf base très ancienne.
-- Migration : plan de sièges événements (AVEC_SIEGES) + libellé de placement
-- Idempotente (IF NOT EXISTS) : sûre à relancer.

-- Colonne lisible côté client (libellé exact choisi dans le plan).
ALTER TABLE "cine_pass_billet"
  ADD COLUMN IF NOT EXISTS "placement_label" text;

-- Plan de sièges défini par le responsable.
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
  ON "cine_pass_event_seat" ( "event_id", lower(trim("label")) );

CREATE INDEX IF NOT EXISTS "cine_pass_event_seat_event_idx"
  ON "cine_pass_event_seat" ( "event_id" );

