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

-- FILMS
-- -----------------------------------------------------------------------------
INSERT INTO "cine_pass_film" (
  "id", "titre", "genre", "dureeMinutes", "synopsis", "directeur", "casting",
  "posterColor", "dateSortie", "dateFin", "audience"
) VALUES
  ('a1000001-1000-7000-8000-000000000001', 'Horizon Quantique', 'Science-Fiction', 128,
   'En 2157, une physicienne doit traverser un trou de ver pour sauver l''humanité.', 'Jean Dupont', 'Marie Martin, Paul Bernard', 2955054,
   '2026-01-15', '2026-04-30', 'Tous publics'),
  ('a1000002-1000-7000-8000-000000000002', 'Les Gardiens du Temps', 'Action', 112,
   'Une équipe de soldats voyage dans le temps pour empêcher une catastrophe.', 'Sophie Leroy', 'Thomas Dubois, Julie Petit', 1792334,
   '2026-02-01', '2026-05-15', 'Tous publics'),
  ('a1000003-1000-7000-8000-000000000003', 'Rire et Préjugés', 'Comédie', 98,
   'Adaptation moderne d''un classique dans le monde du travail.', 'Marc Fontaine', 'Léa Blanc, Lucas Moreau', 5130011,
   '2026-02-14', '2026-05-31', 'Tous publics'),
  ('a1000004-1000-7000-8000-000000000004', 'Le Dernier Refuge', 'Drame', 105,
   'Un père et sa fille tentent de survivre dans un monde post-apocalyptique.', 'Claire Mercier', 'Pierre Durand, Emma Roux', 3026474,
   '2026-03-01', '2026-06-15', 'Tous publics')
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- CINÉMAS
-- -----------------------------------------------------------------------------
INSERT INTO "cine_pass_cinema" ("id", "nom", "ville", "adresse", "codePostal") VALUES
  ('b2000001-2000-7000-8000-000000000001', 'Gaumont Opéra', 'Paris', '2 Boulevard des Capucines', '75009'),
  ('b2000002-2000-7000-8000-000000000002', 'UGC Ciné Cité Confluence', 'Lyon', '112 Cours Charlemagne', '69002')
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- SALLES
-- -----------------------------------------------------------------------------
INSERT INTO "cine_pass_salle" ("id", "cinemaId", "nom", "capacite") VALUES
  ('c3000001-3000-7000-8000-000000000001', 'b2000001-2000-7000-8000-000000000001', 'Salle 1', 120),
  ('c3000002-3000-7000-8000-000000000002', 'b2000001-2000-7000-8000-000000000001', 'Salle 2', 80),
  ('c3000003-3000-7000-8000-000000000003', 'b2000002-2000-7000-8000-000000000002', 'Salle 1', 150)
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- SIÈGES (rangées A–E, numéros 1–5 par salle)
-- -----------------------------------------------------------------------------
DO $$
DECLARE
  salle_rec RECORD;
  r TEXT;
  n INT;
BEGIN
  FOR salle_rec IN SELECT "id" FROM "cine_pass_salle"
  LOOP
    FOR r IN SELECT unnest(ARRAY['A','B','C','D','E'])
    LOOP
      FOR n IN 1..5
      LOOP
        INSERT INTO "cine_pass_siege" ("salleId", "rangee", "numero")
        VALUES (salle_rec.id, r, n);
      END LOOP;
    END LOOP;
  END LOOP;
END $$;

-- -----------------------------------------------------------------------------
-- SÉANCES (films + salles + créneaux)
-- -----------------------------------------------------------------------------
INSERT INTO "cine_pass_seance" ("filmId", "salleId", "debutAt", "finAt", "format", "type", "prixBase") VALUES
  ('a1000001-1000-7000-8000-000000000001', 'c3000001-3000-7000-8000-000000000001', '2026-03-15 14:00:00', '2026-03-15 16:08:00', 'VF', '2D', 12.50),
  ('a1000001-1000-7000-8000-000000000001', 'c3000001-3000-7000-8000-000000000001', '2026-03-15 18:30:00', '2026-03-15 20:38:00', 'VF', '2D', 12.50),
  ('a1000002-1000-7000-8000-000000000002', 'c3000002-3000-7000-8000-000000000002', '2026-03-15 20:00:00', '2026-03-15 21:52:00', 'VOSTFR', '2D', 13.00),
  ('a1000003-1000-7000-8000-000000000003', 'c3000001-3000-7000-8000-000000000001', '2026-03-16 10:30:00', '2026-03-16 12:08:00', 'VF', '2D', 10.00),
  ('a1000004-1000-7000-8000-000000000004', 'c3000003-3000-7000-8000-000000000003', '2026-03-16 14:00:00', '2026-03-16 15:45:00', 'VF', '2D', 11.00),
  ('a1000001-1000-7000-8000-000000000001', 'c3000003-3000-7000-8000-000000000003', '2026-03-17 21:00:00', '2026-03-17 23:08:00', 'VF', '2D', 12.50);

-- -----------------------------------------------------------------------------
-- ÉVÉNEMENTS
-- -----------------------------------------------------------------------------
INSERT INTO "cine_pass_evenement" ("id", "titre", "categorie", "description", "lieu", "adresse", "ville", "eventDate", "eventTime", "placesTotal", "prixBase", "posterColor") VALUES
  ('d4000001-4000-7000-8000-000000000001', 'Concert Électro Night', 'Concert', 'Soirée exceptionnelle avec les meilleurs DJs de la scène électronique.', 'Gaumont Opéra', '2 Boulevard des Capucines, 75009 Paris', 'Paris', '2026-03-20 00:00:00', '2026-03-20 21:00:00', 300, 35.00, 5130011),
  ('d4000002-4000-7000-8000-000000000002', 'Festival Jazz Live', 'Concert', 'Grande soirée jazz avec des artistes internationaux.', 'Salle Pleyel', 'Paris', 'Paris', '2026-03-22 00:00:00', '2026-03-22 20:00:00', 200, 45.00, 1792334),
  ('d4000003-4000-7000-8000-000000000003', 'Spectacle Théâtral - Hamlet', 'Théâtre', 'Représentation classique de Hamlet.', 'UGC Ciné Cité Confluence', 'Lyon', 'Lyon', '2026-03-25 00:00:00', '2026-03-25 19:30:00', 150, 28.00, 4010780)
ON CONFLICT (id) DO NOTHING;

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
