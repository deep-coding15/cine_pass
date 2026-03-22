-- DOUBLON / RÉFÉRENCE : la logique ci-dessous est incluse dans `cine_pass_schema.sql`
-- (phase 2). Ne l’exécutez seul que pour réparer une base existante sans tout rejouer.
--
-- CinePass — Synchronisation des rôles (admin / responsable / client)
-- Objectif
--  1) Que les tables utilisées par le backend existent et soient cohérentes.
--     - cine_pass_admin_user
--     - cine_pass_responsable_user
--     - cine_pass_responsable_assignment.active (privilèges responsable)
--  2) Permettre une gestion "par colonne role" via cine_pass_user_role (source de vérité).
--  3) Avoir des helpers SQL pour promouvoir admin / responsable et assigner une structure.
--
-- Usage
--  - Exécuter après le schéma principal (cine_pass_schema.sql), ou sur une base déjà en place.
--  - Ce script est idempotent.
--
-- IMPORTANT
--  - Le backend actuel vérifie l'admin dans cine_pass_admin_user.
--  - Il vérifie le responsable dans cine_pass_responsable_assignment.active=true.
--  - Donc, quand role != 'responsable', on met aussi les assignments à active=false.

BEGIN;

-- -----------------------------------------------------------------------------
-- Tables nécessaires (backend)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "cine_pass_admin_user" (
  "id" bigserial PRIMARY KEY,
  "user_id" uuid NOT NULL UNIQUE,
  "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS "cine_pass_admin_user_user_idx"
  ON "cine_pass_admin_user" ("user_id");

CREATE TABLE IF NOT EXISTS "cine_pass_responsable_user" (
  "id" bigserial PRIMARY KEY,
  "user_id" uuid NOT NULL UNIQUE,
  "active" boolean NOT NULL DEFAULT true,
  "created_at" timestamp without time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp without time zone NOT NULL DEFAULT now(),
  -- Si la table serverpod_auth_core_user n'existe pas encore, cette FK sera
  -- ignorée lors de l'exécution (selon l'ordre). On s'appuie surtout sur
  -- l'id métier côté backend.
  CONSTRAINT "cine_pass_responsable_user_user_fk"
    FOREIGN KEY ("user_id") REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS "cine_pass_responsable_user_active_idx"
  ON "cine_pass_responsable_user" ("active");

-- -----------------------------------------------------------------------------
-- Source de vérité : cine_pass_user_role
-- -----------------------------------------------------------------------------
-- Note: cine_pass_schema.sql crée déjà cette table, mais on la garde ici
-- pour rendre le script autonome.
CREATE TABLE IF NOT EXISTS "cine_pass_user_role" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL REFERENCES "serverpod_auth_core_user"("id") ON DELETE CASCADE,
  "role" text NOT NULL DEFAULT 'client' -- client | responsable | admin
);

CREATE INDEX IF NOT EXISTS "cine_pass_user_role_user_idx"
  ON "cine_pass_user_role" ("user_id");

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'cine_pass_user_role_role_check'
  ) THEN
    ALTER TABLE "cine_pass_user_role"
      ADD CONSTRAINT "cine_pass_user_role_role_check"
      CHECK ("role" IN ('client', 'responsable', 'admin'));
  END IF;
END $$;

-- -----------------------------------------------------------------------------
-- Fonction de synchronisation (trigger & helpers)
-- -----------------------------------------------------------------------------
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

  -- Admin -> cine_pass_admin_user
  IF v_is_admin THEN
    INSERT INTO "cine_pass_admin_user" ("user_id")
    VALUES (p_user_id)
    ON CONFLICT ("user_id") DO NOTHING;
  ELSE
    DELETE FROM "cine_pass_admin_user"
    WHERE "user_id" = p_user_id;
  END IF;

  -- Responsable -> cine_pass_responsable_user (+ assignments)
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

    -- IMPORTANT:
    -- Le backend responsable utilise cine_pass_responsable_assignment.active=true.
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

-- -----------------------------------------------------------------------------
-- Trigger : synchronise au moindre changement de rôle
-- -----------------------------------------------------------------------------
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

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'cine_pass_user_role_sync_trg'
  ) THEN
    CREATE TRIGGER "cine_pass_user_role_sync_trg"
    AFTER INSERT OR UPDATE OR DELETE ON "cine_pass_user_role"
    FOR EACH ROW
    EXECUTE FUNCTION "cine_pass_user_role_sync_trigger_fn"();
  END IF;
END $$;

-- -----------------------------------------------------------------------------
-- Helpers : promouvoir / assigner via email & structureId
-- -----------------------------------------------------------------------------
-- 1) Promote admin by email
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

  -- Nettoyer uniquement le rôle passé / ou au contraire ajouter le rôle ?
  -- Ici on fait simple : on supprime les lignes rôle-> et on insère une ligne.
  DELETE FROM "cine_pass_user_role"
  WHERE "user_id" = v_uid;

  INSERT INTO "cine_pass_user_role" ("user_id", "role")
  VALUES (v_uid, lower(trim(p_role)));

  PERFORM "cine_pass_sync_effective_roles"(v_uid);
END;
$$;

-- 2) Assign responsible to a structure (creates/activates assignment row)
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

  -- Mettre le rôle responsable si pas déjà fait
  PERFORM "cine_pass_set_role_by_email"(p_email, 'responsable');

  INSERT INTO "cine_pass_responsable_assignment" ("user_id", "structure_id", "active")
  VALUES (v_uid, p_structure_id, p_active)
  ON CONFLICT ("user_id", "structure_id") DO UPDATE
    SET "active" = EXCLUDED."active";

  PERFORM "cine_pass_sync_effective_roles"(v_uid);
END;
$$;

-- -----------------------------------------------------------------------------
-- Role effective (colonne unique)
-- -----------------------------------------------------------------------------
-- Cette vue reflète la logique backend "réelle" :
-- - admin via cine_pass_admin_user
-- - responsable via cine_pass_responsable_assignment.active=true
-- - sinon client

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

