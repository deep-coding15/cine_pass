-- À exécuter sur une base existante si la table cine_pass_billet existe déjà sans cette colonne.
ALTER TABLE "cine_pass_billet"
  ADD COLUMN IF NOT EXISTS "placement_label" text;
