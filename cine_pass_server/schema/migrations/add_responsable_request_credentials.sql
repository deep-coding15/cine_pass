-- Intégré dans `schema/cine_pass_schema.sql` (colonnes sur cine_pass_responsable_request).
-- Migration : email professionnel + hash mot de passe pour la demande responsable.
-- L'accès à l'espace responsable se fait avec cet email pro + mot de passe.
-- À exécuter après le schéma principal si la table existe déjà.

ALTER TABLE "cine_pass_responsable_request"
  ADD COLUMN IF NOT EXISTS "professional_email" text,
  ADD COLUMN IF NOT EXISTS "password_hash" text;

CREATE UNIQUE INDEX IF NOT EXISTS "cine_pass_responsable_request_pro_email_idx"
  ON "cine_pass_responsable_request" ("professional_email")
  WHERE "professional_email" IS NOT NULL;

COMMENT ON COLUMN "cine_pass_responsable_request"."professional_email" IS
  'Email professionnel : utilisé pour se connecter à l''espace responsable.';
COMMENT ON COLUMN "cine_pass_responsable_request"."password_hash" IS
  'Hash du mot de passe pour la connexion espace responsable (stocké à la soumission).';
