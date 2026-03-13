-- Vérifie que la base a les contraintes attendues par le protocole (protocol.dart).
-- Noms = fk_0, fk_1, etc. Générés par Serverpod.
-- À lancer avec: Get-Content schema\verif_same_db.sql -Raw | docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass -t
-- Tu dois voir 7 lignes. Sinon, relancer schema\reset_and_seed.cmd puis dart run bin/main.dart.

SELECT 'salle_fk_0', conname FROM pg_constraint c JOIN pg_class t ON t.oid = c.conrelid WHERE t.relname = 'cine_pass_salle' AND c.conname = 'cine_pass_salle_fk_0'
UNION ALL
SELECT 'siege_fk_0', conname FROM pg_constraint c JOIN pg_class t ON t.oid = c.conrelid WHERE t.relname = 'cine_pass_siege' AND c.conname = 'cine_pass_siege_fk_0'
UNION ALL
SELECT 'seance_fk_0', conname FROM pg_constraint c JOIN pg_class t ON t.oid = c.conrelid WHERE t.relname = 'cine_pass_seance' AND c.conname = 'cine_pass_seance_fk_0'
UNION ALL
SELECT 'seance_fk_1', conname FROM pg_constraint c JOIN pg_class t ON t.oid = c.conrelid WHERE t.relname = 'cine_pass_seance' AND c.conname = 'cine_pass_seance_fk_1'
UNION ALL
SELECT 'evenement_fk_0', conname FROM pg_constraint c JOIN pg_class t ON t.oid = c.conrelid WHERE t.relname = 'cine_pass_evenement' AND c.conname = 'cine_pass_evenement_fk_0'
UNION ALL
SELECT 'structure_fk_0', conname FROM pg_constraint c JOIN pg_class t ON t.oid = c.conrelid WHERE t.relname = 'cine_pass_structure' AND c.conname = 'cine_pass_structure_fk_0'
UNION ALL
SELECT 'structure_idx', indexname FROM pg_indexes WHERE tablename = 'cine_pass_structure' AND indexname = 'cine_pass_structure_type_city_idx';
