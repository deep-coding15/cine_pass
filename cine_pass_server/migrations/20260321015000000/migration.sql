BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE IF NOT EXISTS "cine_pass_reservation" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id" uuid NOT NULL,
    "seance_id" uuid,
    "evenement_id" uuid,
    "numero" text NOT NULL,
    "statut" text NOT NULL DEFAULT 'paid',
    "total_amount" double precision NOT NULL DEFAULT 0,
    "session_at" timestamp without time zone,
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE IF NOT EXISTS "cine_pass_billet" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "reservation_id" uuid NOT NULL,
    "siege_id" uuid,
    "ticket_type" text NOT NULL DEFAULT 'normal',
    "option_parking" boolean NOT NULL DEFAULT false,
    "option_popcorn" boolean NOT NULL DEFAULT false,
    "option_boisson" boolean NOT NULL DEFAULT false,
    "prix" double precision NOT NULL DEFAULT 0,
    "statut" text NOT NULL DEFAULT 'paid',
    "created_at" timestamp without time zone NOT NULL DEFAULT now()
);

ALTER TABLE "cine_pass_billet"
    ADD COLUMN IF NOT EXISTS "statut" text NOT NULL DEFAULT 'paid';

--
-- ACTION CREATE INDEX
--
CREATE UNIQUE INDEX IF NOT EXISTS "cine_pass_reservation_numero_uniq"
    ON "cine_pass_reservation" USING btree ("numero");

CREATE INDEX IF NOT EXISTS "cine_pass_reservation_user_idx"
    ON "cine_pass_reservation" USING btree ("user_id", "created_at");

CREATE INDEX IF NOT EXISTS "cine_pass_reservation_event_idx"
    ON "cine_pass_reservation" USING btree ("evenement_id");

CREATE INDEX IF NOT EXISTS "cine_pass_billet_reservation_idx"
    ON "cine_pass_billet" USING btree ("reservation_id");

CREATE INDEX IF NOT EXISTS "cine_pass_billet_siege_idx"
    ON "cine_pass_billet" USING btree ("siege_id");

--
-- ACTION CREATE CHECK CONSTRAINT
--
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'cine_pass_reservation_target_chk'
  ) THEN
    ALTER TABLE ONLY "cine_pass_reservation"
      ADD CONSTRAINT "cine_pass_reservation_target_chk"
      CHECK (("seance_id" IS NOT NULL AND "evenement_id" IS NULL)
          OR ("seance_id" IS NULL AND "evenement_id" IS NOT NULL));
  END IF;
END $$;

--
-- ACTION CREATE FOREIGN KEY
--
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'cine_pass_reservation_user_fk_0'
  ) THEN
    ALTER TABLE ONLY "cine_pass_reservation"
      ADD CONSTRAINT "cine_pass_reservation_user_fk_0"
      FOREIGN KEY("user_id")
      REFERENCES "serverpod_auth_core_user"("id")
      ON DELETE CASCADE
      ON UPDATE NO ACTION;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'cine_pass_reservation_seance_fk_0'
  ) THEN
    ALTER TABLE ONLY "cine_pass_reservation"
      ADD CONSTRAINT "cine_pass_reservation_seance_fk_0"
      FOREIGN KEY("seance_id")
      REFERENCES "cine_pass_seance"("id")
      ON DELETE SET NULL
      ON UPDATE NO ACTION;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'cine_pass_reservation_evenement_fk_0'
  ) THEN
    ALTER TABLE ONLY "cine_pass_reservation"
      ADD CONSTRAINT "cine_pass_reservation_evenement_fk_0"
      FOREIGN KEY("evenement_id")
      REFERENCES "cine_pass_evenement"("id")
      ON DELETE SET NULL
      ON UPDATE NO ACTION;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'cine_pass_billet_reservation_fk_0'
  ) THEN
    ALTER TABLE ONLY "cine_pass_billet"
      ADD CONSTRAINT "cine_pass_billet_reservation_fk_0"
      FOREIGN KEY("reservation_id")
      REFERENCES "cine_pass_reservation"("id")
      ON DELETE CASCADE
      ON UPDATE NO ACTION;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'cine_pass_billet_siege_fk_0'
  ) THEN
    ALTER TABLE ONLY "cine_pass_billet"
      ADD CONSTRAINT "cine_pass_billet_siege_fk_0"
      FOREIGN KEY("siege_id")
      REFERENCES "cine_pass_siege"("id")
      ON DELETE SET NULL
      ON UPDATE NO ACTION;
  END IF;
END $$;

--
-- MIGRATION VERSION FOR cine_pass
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('cine_pass', '20260321015000000', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260321015000000', "timestamp" = now();

COMMIT;
