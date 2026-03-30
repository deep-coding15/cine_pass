-- Équivalent à la « phase 0 » en tête de `cine_pass_schema.sql` (DROP des tables métier).
-- Pour un reset complet + recréation : exécuter uniquement `cine_pass_schema.sql`.
-- Ce fichier reste utile si vous voulez seulement vider les tables sans relire tout le CREATE.

BEGIN;

DROP VIEW IF EXISTS "cine_pass_event_search_v" CASCADE;
DROP VIEW IF EXISTS "cine_pass_effective_roles" CASCADE;

DROP TABLE IF EXISTS "cine_pass_paiement" CASCADE;
DROP TABLE IF EXISTS "cine_pass_billet" CASCADE;
DROP TABLE IF EXISTS "cine_pass_reservation" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_ticket_option" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_ticket_type" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_seat" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_reservation_config" CASCADE;

DROP TABLE IF EXISTS "cine_pass_event_film_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_festival_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_standup_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_concert_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_theatre_details" CASCADE;
DROP TABLE IF EXISTS "cine_pass_event_other_details" CASCADE;

DROP TABLE IF EXISTS "cine_pass_favori_evenement" CASCADE;

DROP TABLE IF EXISTS "cine_pass_role_change_approval" CASCADE;
DROP TABLE IF EXISTS "cine_pass_role_change_request" CASCADE;

DROP TABLE IF EXISTS "cine_pass_evenement" CASCADE;

DROP TABLE IF EXISTS "cine_pass_seance" CASCADE;
DROP TABLE IF EXISTS "cine_pass_siege" CASCADE;
DROP TABLE IF EXISTS "cine_pass_salle" CASCADE;
DROP TABLE IF EXISTS "cine_pass_favori" CASCADE;
DROP TABLE IF EXISTS "cine_pass_film" CASCADE;

DROP TABLE IF EXISTS "cine_pass_faq" CASCADE;
DROP TABLE IF EXISTS "cine_pass_user_profile" CASCADE;
DROP TABLE IF EXISTS "cine_pass_user_role" CASCADE;
DROP TABLE IF EXISTS "cine_pass_admin_user" CASCADE;

DROP TABLE IF EXISTS "cine_pass_responsable_assignment" CASCADE;
DROP TABLE IF EXISTS "cine_pass_responsable_user" CASCADE;
DROP TABLE IF EXISTS "cine_pass_structure" CASCADE;
DROP TABLE IF EXISTS "cine_pass_cinema" CASCADE;
DROP TABLE IF EXISTS "cine_pass_responsable_request" CASCADE;

COMMIT;
