-- Plan de sièges par événement (si la table n'existe pas encore).
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
