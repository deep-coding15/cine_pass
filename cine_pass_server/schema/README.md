# Schéma SQL CinePass

Ce dossier contient le **schéma SQL métier** de CinePass pour des **données réelles** (plus de mocks).

## Utilisation

- **PostgreSQL** requis (même instance que Serverpod).
- Les tables Serverpod (dont `serverpod_auth_core_user`) doivent déjà exister (migrations Serverpod déjà appliquées).
- Exécuter `cine_pass_schema.sql` sur la base (manuellement ou via un script de déploiement).

**Si le serveur signale que les tables ne correspondent pas au schéma cible** (colonnes ou index manquants), supprimer les tables métier puis réappliquer le schéma :

```bash
# Avec Docker (depuis cine_pass_server)
Get-Content schema/drop_cine_pass_tables.sql -Raw | docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass
Get-Content schema/cine_pass_schema.sql -Raw | docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass
```

Exemple sans Docker :

```bash
psql -U postgres -d votre_base -f schema/drop_cine_pass_tables.sql
psql -U postgres -d votre_base -f schema/cine_pass_schema.sql
```

Pour **remplir la base avec des données de test** (films, cinémas, salles, sièges, séances, événements, FAQ) :

```bash
psql -U postgres -d cine_pass -f schema/seed_data.sql
```

À exécuter après le schéma. Le script est ré-exécutable (pas de doublons sur films, cinémas, salles, événements, FAQ).

## Utilisateurs

- **Utilisateurs** = `serverpod_auth_core_user` (UUID) + `serverpod_auth_core_profile` (nom, email, etc.).
- Les tables CinePass qui référencent un utilisateur utilisent `user_id` → `serverpod_auth_core_user.id` (uuid).
- Rôle admin optionnel : `cine_pass_user_role` (role = `client` | `admin`).

## Tables créées

| Table | Rôle |
|-------|------|
| `cine_pass_film` | Films (titre, genre, durée, synopsis, etc.) |
| `cine_pass_cinema` | Cinémas (nom, ville, adresse) |
| `cine_pass_salle` | Salles d’un cinéma (capacité) |
| `cine_pass_siege` | Sièges par salle (rangée, numéro) |
| `cine_pass_seance` | Séance film (film + salle + date/heure, format, type, prix, options) |
| `cine_pass_evenement` | Événements (concert, théâtre : lieu, date, places, prix, options) |
| `cine_pass_reservation` | Réservation (user, seance OU evenement, numéro, statut, total) |
| `cine_pass_billet` | Billets (réservation, siège optionnel, type normal/vip, options, prix) |
| `cine_pass_paiement` | Paiement (réservation, montant, méthode, statut) |
| `cine_pass_favori` | Favoris (user + film OU cinema) |
| `cine_pass_faq` | FAQ (question, réponse, ordre) |
| `cine_pass_user_role` | Rôle utilisateur (client / admin) |

## Suite

- Créer les **modèles Serverpod** (`.spy.yaml`) correspondants dans `lib/src/models/` pour générer le client et les endpoints.
- Remplacer les **mocks Flutter** par des appels au backend (données réelles).
