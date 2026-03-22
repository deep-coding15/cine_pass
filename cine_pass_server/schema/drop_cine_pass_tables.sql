-- Supprime toutes les tables métier CinePass.
-- Pour un reset + recréation en une seule passe, utilisez plutôt
-- `cine_pass_schema.sql` (Phase 0 inclut ce DROP puis recrée tout).
-- N'affecte pas serverpod_* ni serverpod_auth_*.
--
-- Inclut explicitement les tables cine_pass_event_*_details : sans elles, une base
-- « orpheline » (détails sans événement) fait échouer CREATE TABLE ... already exists
-- et la 1re transaction du schéma fait ROLLBACK — la 2e moitié (rôles / vue) échoue ensuite.

BEGIN;

-- Vue créée en fin de schéma (dépend de plusieurs tables)
DROP VIEW IF EXISTS "cine_pass_effective_roles" CASCADE;

-- Feuilles → racines (réservations / billets / config événement)
DROP TABLE IF EXISTS "cine_pass_paiement" CASCADE;
DROP TABLE IF EXISTS "cine_pass_billet" CASCADE;
DROP TABLE IF EXISTS "cine_pass_reservation" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_ticket_option" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_ticket_type" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_seat" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_reservation_config" CASCADE;

-- Détails par type d’événement (FK vers cine_pass_evenement)
DROP TABLE IF EXISTS "cine_pass_event_film_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_festival_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_standup_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_concert_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_theatre_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_other_details" CASCADE;

DROP TABLE IF EXISTS "cine_pass_evenement" CASCADE;

-- Cinéma / films / séances
DROP TABLE IF EXISTS "cine_pass_seance" CASCADE;
DROP TABLE IF EXISTS "cine_pass_siege" CASCADE;
DROP TABLE IF EXISTS "cine_pass_salle" CASCADE;
DROP TABLE IF EXISTS "cine_pass_favori" CASCADE;
DROP TABLE IF EXISTS "cine_pass_cinema" CASCADE;
DROP TABLE IF EXISTS "cine_pass_film" CASCADE;

-- Autres
DROP TABLE IF EXISTS "cine_pass_faq" CASCADE;
DROP TABLE IF EXISTS "cine_pass_user_profile" CASCADE;
DROP TABLE IF EXISTS "cine_pass_user_role" CASCADE;
DROP TABLE IF EXISTS "cine_pass_admin_user" CASCADE;

-- Responsables / structures
DROP TABLE IF EXISTS "cine_pass_responsable_assignment" CASCADE;
DROP TABLE IF EXISTS "cine_pass_responsable_user" CASCADE;
DROP TABLE IF EXISTS "cine_pass_structure" CASCADE;
DROP TABLE IF EXISTS "cine_pass_responsable_request" CASCADE;

COMMIT;
