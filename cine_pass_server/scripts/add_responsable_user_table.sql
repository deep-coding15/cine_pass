-- Add responsable role table and backfill from active assignments.
-- Run once on existing databases.

BEGIN;

CREATE TABLE IF NOT EXISTS "cine_pass_responsable_user" (
  "id" bigserial PRIMARY KEY,
  "user_id" uuid NOT NULL UNIQUE REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
  "active" boolean NOT NULL DEFAULT true,
  "created_at" timestamp without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_responsable_user_active_idx"
  ON "cine_pass_responsable_user" ("active");

-- Backfill: any user with an active assignment becomes an active responsable.
INSERT INTO "cine_pass_responsable_user" ("user_id", "active", "updated_at")
SELECT DISTINCT a."user_id", true, now()
FROM "cine_pass_responsable_assignment" a
WHERE a."active" = true
ON CONFLICT ("user_id") DO UPDATE SET
  "active" = true,
  "updated_at" = now();

COMMIT;

