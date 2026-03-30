BEGIN;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'cine_pass_evenement'
  ) THEN
    CREATE TABLE IF NOT EXISTS "cine_pass_favori_evenement" (
      "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      "user_id" uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
      "event_id" uuid NOT NULL REFERENCES "cine_pass_evenement"("id") ON DELETE CASCADE,
      "created_at" timestamp without time zone NOT NULL DEFAULT now(),
      CONSTRAINT "cine_pass_favori_evenement_user_event_uniq" UNIQUE ("user_id", "event_id")
    );

    CREATE INDEX IF NOT EXISTS "cine_pass_favori_evenement_user_idx"
      ON "cine_pass_favori_evenement" ("user_id");
  END IF;
END $$;

COMMIT;
