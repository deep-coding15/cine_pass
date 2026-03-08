# Schéma SQL CinePass

Ce dossier contient le **schéma SQL métier** de CinePass pour des **données réelles** (plus de mocks).

## Utilisation

- **PostgreSQL** requis (même instance que Serverpod).
- Les tables Serverpod (dont `serverpod_auth_core_user`) doivent déjà exister (migrations Serverpod déjà appliquées).
- Exécuter `cine_pass_schema.sql` sur la base (manuellement ou via un script de déploiement).

Exemple :

```bash
psql -U postgres -d votre_base -f schema/cine_pass_schema.sql
```

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
