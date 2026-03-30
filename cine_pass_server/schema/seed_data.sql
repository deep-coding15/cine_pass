-- =============================================================================
-- CinePass — Données de test (seed)
-- À exécuter APRÈS cine_pass_schema.sql, sur la base cine_pass.
-- Permet de travailler avec des données réelles depuis l'app.
-- =============================================================================
-- Usage (depuis cine_pass_server) :
--   psql -U postgres -d cine_pass -f schema/seed_data.sql
-- Ou dans pgAdmin : ouvrir et exécuter ce fichier.
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- STRUCTURES
-- -----------------------------------------------------------------------------
INSERT INTO "cine_pass_structure" (
  "id", "type", "name", "city", "address", "website", "phone"
) VALUES
  ('b2000001-2000-7000-8000-000000000001', 'VENUE', 'Gaumont Opéra', 'Paris', '2 Boulevard des Capucines, 75009 Paris', 'https://example.com/opera', '+33 1 40 00 00 01'),
  ('b2000002-2000-7000-8000-000000000002', 'VENUE', 'Salle Pleyel', 'Paris', '252 Rue du Faubourg Saint-Honoré, 75008 Paris', 'https://example.com/pleyel', '+33 1 40 00 00 02'),
  ('b2000003-2000-7000-8000-000000000003', 'VENUE', 'Confluence Live', 'Lyon', '112 Cours Charlemagne, 69002 Lyon', 'https://example.com/confluence', '+33 4 70 00 00 03')
ON CONFLICT ("id") DO NOTHING;

-- -----------------------------------------------------------------------------
-- ÉVÉNEMENTS
-- -----------------------------------------------------------------------------
INSERT INTO "cine_pass_evenement" (
  "id", "titre", "categorie", "event_type", "description", "lieu", "adresse", "ville",
  "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor", "structureId"
) VALUES
  ('d4000001-4000-7000-8000-000000000001', 'Concert Électro Night', 'Concert', 'CONCERT',
   'Soirée exceptionnelle avec les meilleurs DJs de la scène électronique.',
   'Gaumont Opéra', '2 Boulevard des Capucines, 75009 Paris', 'Paris',
   '2026-03-20 00:00:00', '2026-03-20 21:00:00', 300, 35.00, 5130011, 'b2000001-2000-7000-8000-000000000001'),
  ('d4000002-4000-7000-8000-000000000002', 'Festival Jazz Live', 'Concert', 'FESTIVAL',
   'Grande soirée jazz avec des artistes internationaux.',
   'Salle Pleyel', '252 Rue du Faubourg Saint-Honoré, 75008 Paris', 'Paris',
   '2026-03-22 00:00:00', '2026-03-22 20:00:00', 200, 45.00, 1792334, 'b2000002-2000-7000-8000-000000000002'),
  ('d4000003-4000-7000-8000-000000000003', 'Spectacle Théâtral - Hamlet', 'Théâtre', 'THEATRE',
   'Représentation classique de Hamlet.',
   'Confluence Live', '112 Cours Charlemagne, 69002 Lyon', 'Lyon',
   '2026-03-25 00:00:00', '2026-03-25 19:30:00', 150, 28.00, 4010780, 'b2000003-2000-7000-8000-000000000003')
ON CONFLICT (id) DO NOTHING;

INSERT INTO "cine_pass_event_concert_details" ("event_id", "artist", "music_genre")
VALUES ('d4000001-4000-7000-8000-000000000001', 'DJ Nova', 'Electro')
ON CONFLICT ("event_id") DO NOTHING;

INSERT INTO "cine_pass_event_festival_details" ("event_id", "theme", "headliners")
VALUES ('d4000002-4000-7000-8000-000000000002', 'Jazz & Impro', 'Quartet Lumiere')
ON CONFLICT ("event_id") DO NOTHING;

INSERT INTO "cine_pass_event_theatre_details" ("event_id", "author", "play_style")
VALUES ('d4000003-4000-7000-8000-000000000003', 'William Shakespeare', 'Classique')
ON CONFLICT ("event_id") DO NOTHING;

-- -----------------------------------------------------------------------------
-- FAQ
-- -----------------------------------------------------------------------------
INSERT INTO cine_pass_faq (id, question, reponse, ordre) VALUES
  ('e5000001-5000-7000-8000-000000000001', 'Comment annuler une réservation ?', 'Vous pouvez annuler depuis "Mes billets" jusqu''à 2h avant la séance. Le remboursement dépend du délai (voir conditions).', 1),
  ('e5000002-5000-7000-8000-000000000002', 'Quels moyens de paiement sont acceptés ?', 'Carte bancaire, PayPal et les pass CinePass sont acceptés.', 2),
  ('e5000003-5000-7000-8000-000000000003', 'Puis-je modifier mes places après achat ?', 'Non, une fois la réservation validée, les places ne peuvent pas être modifiées. Vous pouvez annuler et reprendre une nouvelle réservation.', 3),
  ('e5000004-5000-7000-8000-000000000004', 'Où trouver mon billet ?', 'Dans l''onglet "Mes billets" de l''application. Un QR code unique par réservation vous sera demandé à l''entrée.', 4)
ON CONFLICT (id) DO NOTHING;

COMMIT;
