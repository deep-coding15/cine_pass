-- Supprime toutes les tables métier CinePass pour pouvoir réappliquer le schéma.
-- À utiliser quand la structure en base ne correspond plus aux modèles (.spy.yaml).
-- N'affecte pas les tables serverpod_* ni serverpod_auth_*.

BEGIN;

DROP TABLE IF EXISTS "cine_pass_user_role" CASCADE;
DROP TABLE IF EXISTS "cine_pass_favori" CASCADE;
DROP TABLE IF EXISTS "cine_pass_faq" CASCADE;
DROP TABLE IF EXISTS "cine_pass_paiement" CASCADE;
DROP TABLE IF EXISTS "cine_pass_billet" CASCADE;
DROP TABLE IF EXISTS "cine_pass_reservation" CASCADE;
DROP TABLE IF EXISTS "cine_pass_evenement" CASCADE;
DROP TABLE IF EXISTS "cine_pass_seance" CASCADE;
DROP TABLE IF EXISTS "cine_pass_siege" CASCADE;
DROP TABLE IF EXISTS "cine_pass_salle" CASCADE;
DROP TABLE IF EXISTS "cine_pass_cinema" CASCADE;
DROP TABLE IF EXISTS "cine_pass_film" CASCADE;

COMMIT;
