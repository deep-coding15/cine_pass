-- Backfill responsable role in v2 table (cine_pass_user_role).
-- Run once on existing databases.

BEGIN;

CREATE TABLE IF NOT EXISTS "cine_pass_user_role" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
  "role" text NOT NULL,
  "status" text NOT NULL DEFAULT 'actif',
  "created_at" timestamp without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS "cine_pass_user_role_user_role_uniq"
  ON "cine_pass_user_role" ("user_id", "role");

-- Backfill: any user with an active assignment becomes actif responsable.
INSERT INTO "cine_pass_user_role" ("user_id", "role", "status", "updated_at")
SELECT DISTINCT a."user_id", 'responsable', 'actif', now()
FROM "cine_pass_responsable_assignment" a
WHERE a."active" = true
ON CONFLICT ("user_id", "role") DO UPDATE SET
  "status" = 'actif',
  "updated_at" = now();

COMMIT;
