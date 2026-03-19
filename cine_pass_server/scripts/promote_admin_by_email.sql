-- Promote a user to admin role in DB (Serverpod auth user id based).
-- Usage:
--   1) Replace the email below.
--   2) Execute this script on your postgres database.

BEGIN;

CREATE TABLE IF NOT EXISTS "cine_pass_admin_user" (
  "id" bigserial PRIMARY KEY,
  "user_id" uuid NOT NULL UNIQUE,
  "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

INSERT INTO "cine_pass_admin_user" ("user_id")
SELECT p."authUserId"
FROM "serverpod_auth_core_profile" p
WHERE lower(p."email") = lower('tsafackmerveille15@gmail.com')
ON CONFLICT ("user_id") DO NOTHING;

COMMIT;

-- Verify:
-- SELECT a."id", a."user_id", p."email", a."created_at"
-- FROM "cine_pass_admin_user" a
-- JOIN "serverpod_auth_core_profile" p ON p."authUserId" = a."user_id"
-- ORDER BY a."created_at" DESC;

