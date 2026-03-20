-- Promote a user to admin role in DB (v2: cine_pass_user_role only).
-- Usage:
--   1) Replace the email below.
--   2) Execute this script on your postgres database.

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

INSERT INTO "cine_pass_user_role" ("user_id", "role", "status", "updated_at")
SELECT p."authUserId", 'admin', 'actif', now()
FROM "serverpod_auth_core_profile" p
WHERE lower(p."email") = lower('tsafackmerveille15@gmail.com')
ON CONFLICT ("user_id", "role") DO UPDATE SET
  "status" = 'actif',
  "updated_at" = now();

COMMIT;

-- Verify:
-- SELECT ur."user_id", p."email", ur."role", ur."status", ur."updated_at"
-- FROM "cine_pass_user_role" ur
-- JOIN "serverpod_auth_core_profile" p ON p."authUserId" = ur."user_id"
-- WHERE ur."role" = 'admin'
-- ORDER BY ur."updated_at" DESC;
