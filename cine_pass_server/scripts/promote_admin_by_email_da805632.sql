-- Promote admin role for a specific email.
-- Usage: execute this file inside the postgres container.

BEGIN;

CREATE TABLE IF NOT EXISTS "cine_pass_admin_user" (
  "id" bigserial PRIMARY KEY,
  "user_id" uuid NOT NULL UNIQUE,
  "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

INSERT INTO "cine_pass_admin_user" ("user_id")
SELECT p."authUserId"
FROM "serverpod_auth_core_profile" p
WHERE lower(p."email") = lower('da805632@gmail.com')
ON CONFLICT ("user_id") DO NOTHING;

COMMIT;

