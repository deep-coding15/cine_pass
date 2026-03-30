# CinePass

Application de **billetterie et de gestion d’événements** (cinéma, concerts, spectacles) : parcours visiteur, réservation, paiement, billets avec QR, espaces **responsable de structure** et **administrateur**.

Monorepo **Dart / Flutter** avec backend [**Serverpod**](https://serverpod.dev) et **PostgreSQL** sous Docker.

---

## Sommaire

- [Fonctionnalités](#fonctionnalités)
- [Stack technique](#stack-technique)
- [Structure du dépôt](#structure-du-dépôt)
- [Prérequis](#prérequis)
- [Démarrage rapide](#démarrage-rapide)
- [Application mobile (API)](#application-mobile-api)
- [Documentation](#documentation)
- [Workflow Serverpod](#workflow-serverpod)
- [Règles et sécurité](#règles-et-sécurité)
- [Répartition des tâches (équipe)](#répartition-des-tâches-équipe)

---

## Fonctionnalités

- Parcours **visiteur / client** : accueil, catalogue d’événements et films, filtres, fiche détail, réservation (places / tarifs selon configuration), paiement, **mes billets** et QR.
- **Devenir responsable** : demande soumise puis validation par un admin.
- **Espace responsable** : structure, événements, réservations, rapports / exports.
- **Espace admin** : utilisateurs, structures, événements, demandes responsable, statistiques.
- Authentification (email, Google selon configuration) — voir `SETUP_APRES_CLONE.md`.

---

## Stack technique

| Couche | Technologie |
|--------|-------------|
| Frontend | Flutter (SDK ^3.35), `go_router`, workspace Dart |
| Backend | Serverpod, endpoints Dart, migrations intégrées |
| Données | PostgreSQL (image `pgvector`), schéma métier SQL + scripts dans `cine_pass_server/schema/` |
| Outils | Docker Compose, `serverpod_cli` pour `serverpod generate` |

---

## Structure du dépôt

```
cine_pass/
├── cine_pass_server/      # Backend Serverpod (API, modèles .spy.yaml, config)
├── cine_pass_client/      # Client généré — ne pas éditer à la main
├── cine_pass_flutter/     # Application Flutter
├── guide_d_installation.txt
├── guide_d'installation.txt   # même contenu ; nom avec apostrophe si exigé par l’enseignant
└── pubspec.yaml           # Workspace racine
```

**Modules Flutter principaux** (`cine_pass_flutter/lib/features/`) : `auth`, `home`, `events`, `films`, `reservation`, `billets`, `profil`, `admin`, `responsable`, `devenir_responsable`, `support`, `faq`, etc.

---

## Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) (stable) et Dart
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)
- Pour iOS : macOS, Xcode, CocoaPods

Vérifications : `flutter doctor`, `docker --version`.

---

## Démarrage rapide

Après un **clone**, la base est vide et les secrets ne sont pas versionnés. Le détail (schéma métier, seed, dépannage) est dans les guides listés [ci-dessous](#documentation).

```bash
# 1. Postgres + Redis (depuis le serveur)
cd cine_pass_server
docker compose up --build -d

# 2. Secrets locaux (une fois)
cp config/passwords.yaml.example config/passwords.yaml
# Éditer passwords.yaml : au minimum development.database = mervy (voir docker-compose.yaml)

# 3. Dépendances workspace
cd ..
dart pub get
cd cine_pass_flutter && flutter pub get
cd ../cine_pass_server && dart pub get

# 4. Migrations Serverpod
dart run bin/main.dart --apply-migrations --mode development

# 5. Schéma métier + données de test (recommandé)
# Voir guide_d_installation.txt section 7 (docker exec + fichiers SQL dans schema/)

# 6. Lancer l’API
dart run bin/main.dart --mode development
# API : http://localhost:9080 — Web Serverpod : http://localhost:9082
```

**Flutter (web)** — autre terminal :

```bash
cd cine_pass_flutter
flutter run -d chrome --web-hostname localhost --web-port 7357
```

Connexion **Google** côté client : variables `GOOGLE_CLIENT_ID` / `GOOGLE_SERVER_CLIENT_ID` — voir [cine_pass_server/SETUP_APRES_CLONE.md](cine_pass_server/SETUP_APRES_CLONE.md).

---

## Application mobile (API)

Sur **émulateur Android**, `localhost` pointe vers l’émulateur, pas vers le PC. Utiliser l’hôte :

```bash
flutter run -d <device_id> --dart-define=API_URL=http://10.0.2.2:9080
```

Sur un **téléphone** (même Wi-Fi que la machine qui héberge le serveur) :

```bash
flutter run -d <device_id> --dart-define=API_URL=http://<IP_LAN_DU_PC>:9080
```

---

## Documentation

| Document | Rôle |
|----------|------|
| [guide_d_installation.txt](guide_d_installation.txt) | Installation complète (Docker, migrations, SQL, web, Android, iOS, pièges courants) |
| [guide_d'installation.txt](guide_d'installation.txt) | Identique ; nom avec apostrophe si demandé pour un rendu |
| [cine_pass_server/SETUP_APRES_CLONE.md](cine_pass_server/SETUP_APRES_CLONE.md) | Clone, OAuth Google, commandes détaillées |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Vision d’ensemble du projet (si présent à la racine) |
| [cine_pass_server/README.md](cine_pass_server/README.md) | Notes spécifiques au package serveur |
| [cine_pass_server/schema/README.md](cine_pass_server/schema/README.md) | Scripts SQL métier |

---

## Workflow Serverpod

```
Modifier un modèle *.spy.yaml dans cine_pass_server/lib/src/models/
        ↓
serverpod generate   (depuis cine_pass_server, CLI installée : dart pub global activate serverpod_cli)
        ↓
Mise à jour de cine_pass_client/ et des fichiers generated/
        ↓
Utilisation des types côté Flutter via le client généré
```

---

## Règles et sécurité

1. **Ne pas modifier** `cine_pass_client/` ni les dossiers `generated/` à la main.
2. Après changement de modèles `.spy.yaml`, lancer **`serverpod generate`** puis appliquer les migrations si besoin.
3. **Ne jamais commiter** `cine_pass_server/config/passwords.yaml`, `google_client_secret.json`, ni de clés API — utiliser `passwords.yaml.example` comme modèle.
4. Travailler sur une **branche** dédiée ; vérifier le serveur avant fusion sur `main`.
5. **Ne pas publier** de secrets dans le README, les issues ou le chat : GitHub bloque les pushes contenant des identifiants OAuth / SMTP réels.

---

## Répartition des tâches (équipe)

Le tableau ci-dessous est une **référence de partage initial** ; les chemins de fichiers peuvent avoir évolué. Pour l’état actuel du code, explorer `cine_pass_flutter/lib/features/` et `cine_pass_server/lib/src/`.

<details>
<summary><strong>Afficher la répartition détaillée (Personnes 1 à 4)</strong></summary>

### Personne 1 — Auth, profil, utilisateurs

#### Frontend (`cine_pass_flutter/lib/`)

| Tâche | Fichier |
|-------|---------|
| Inscription | `features/auth/presentation/pages/register_page.dart` |
| Connexion | `features/auth/presentation/pages/login_page.dart` |
| Réinitialisation MDP | `features/auth/presentation/pages/forgot_password_page.dart` |
| Déconnexion | `features/auth/` (bouton dans app bar) |
| Écran profil | `features/profil/presentation/pages/profil_page.dart` |
| Modification profil | `features/profil/presentation/pages/edit_profil_page.dart` |
| Cinémas favoris | `features/profil/presentation/pages/favoris_page.dart` |
| Historique réservations | `features/profil/presentation/pages/historique_reservations_page.dart` |
| Providers | `features/auth/presentation/providers/auth_provider.dart` |
| Providers | `features/profil/presentation/providers/profil_provider.dart` |
| Repository impl | `features/auth/data/repositories/auth_repository_impl.dart` |
| Repository impl | `features/profil/data/repositories/profil_repository_impl.dart` |
| Contrats domain | `features/auth/domain/repositories/auth_repository.dart` |
| Contrats domain | `features/profil/domain/repositories/profil_repository.dart` |

#### Backend (`cine_pass_server/lib/src/`)

| Tâche | Fichier |
|-------|---------|
| Modèle Utilisateur | `models/utilisateur.spy.yaml` |
| Modèle Favori | `models/favori.spy.yaml` |
| Endpoint auth (isAdmin, saveProfile) | `endpoints/auth_endpoint.dart` |
| Endpoint profil (getProfil, updateProfil) | `endpoints/profil_endpoint.dart` |
| Endpoint favoris (getFavoris, ajouterFavori, supprimerFavori) | `endpoints/profil_endpoint.dart` |
| Endpoint historique réservations | `endpoints/profil_endpoint.dart` |

### Personne 2 — Programmation (films, séances, salles, cinémas)

#### Frontend (`cine_pass_flutter/lib/`)

| Tâche | Fichier |
|-------|---------|
| Page d'accueil | `features/home/presentation/pages/home_page.dart` |
| Recherche / filtres | `features/home/presentation/pages/search_page.dart` |
| Liste films | `features/programmation/presentation/pages/films_list_page.dart` |
| Détail film | `features/programmation/presentation/pages/film_detail_page.dart` |
| Liste séances | `features/programmation/presentation/pages/seances_page.dart` |
| Cinémas proches | `features/programmation/presentation/pages/cinemas_proches_page.dart` |
| Providers | `features/programmation/presentation/providers/films_provider.dart` |
| Providers | `features/programmation/presentation/providers/seances_provider.dart` |
| Providers | `features/programmation/presentation/providers/cinemas_provider.dart` |
| Repositories | `features/programmation/data/repositories/film_repository_impl.dart` |
| Entités domain | `features/programmation/domain/entities/film.dart` |
| Entités domain | `features/programmation/domain/entities/seance.dart` |
| Entités domain | `features/programmation/domain/entities/cinema.dart` |

#### Backend (`cine_pass_server/lib/src/`)

| Tâche | Fichier |
|-------|---------|
| Modèle Film | `models/film.spy.yaml` |
| Modèle Cinema | `models/cinema.spy.yaml` |
| Modèle Salle | `models/salle.spy.yaml` |
| Modèle Seance | `models/seance.spy.yaml` |
| Endpoint films (getFilms, getFilmById) | `endpoints/films_endpoint.dart` |
| Endpoint séances (getSeancesByFilm) | `endpoints/seances_endpoint.dart` |
| Endpoint cinémas (getCinemas, getCinemasProches) | `endpoints/cinemas_endpoint.dart` |
| Endpoint salles (getSallesByCinema) | `endpoints/salles_endpoint.dart` |

### Personne 3 — Réservation, paiement, billets

#### Frontend (`cine_pass_flutter/lib/`)

| Tâche | Fichier |
|-------|---------|
| Plan des sièges | `features/reservation/presentation/pages/seat_selection_page.dart` |
| Panier / récap | `features/reservation/presentation/pages/cart_page.dart` |
| Options supplémentaires | `features/reservation/presentation/widgets/options_supplementaires_widget.dart` |
| Page paiement | `features/paiement/presentation/pages/payment_page.dart` |
| Intégration Stripe | `features/paiement/data/services/stripe_service.dart` |
| Page confirmation | `features/paiement/presentation/pages/confirmation_page.dart` |
| Liste billets | `features/billets/presentation/pages/billets_page.dart` |
| Détail billet + QR | `features/billets/presentation/pages/billet_detail_page.dart` |
| Providers | `features/reservation/presentation/providers/reservation_provider.dart` |
| Repositories | `features/reservation/data/repositories/reservation_repository_impl.dart` |

#### Backend (`cine_pass_server/lib/src/`)

| Tâche | Fichier |
|-------|---------|
| Modèle Reservation | `models/reservation.spy.yaml` |
| Modèle Billet | `models/billet.spy.yaml` |
| Modèle Siege | `models/siege.spy.yaml` |
| Modèle Paiement | `models/paiement.spy.yaml` |
| Endpoint réservations (creerReservation, getSiegesDisponibles) | `endpoints/reservations_endpoint.dart` |
| Endpoint paiement (effectuerPaiement, appliquerCodePromo) | `endpoints/paiement_endpoint.dart` |
| Endpoint billets (genererBillet, getBilletsByUser) | `endpoints/billets_endpoint.dart` |

### Personne 4 — Admin, support, rapports

#### Frontend (`cine_pass_flutter/lib/`)

| Tâche | Fichier |
|-------|---------|
| Tableau de bord | `features/admin/presentation/pages/dashboard_page.dart` |
| Gestion films | `features/admin/presentation/pages/admin_films_page.dart` |
| Gestion séances | `features/admin/presentation/pages/admin_seances_page.dart` |
| Gestion salles | `features/admin/presentation/pages/admin_salles_page.dart` |
| Réservations temps réel | `features/admin/presentation/pages/admin_reservations_page.dart` |
| Gestion utilisateurs | `features/admin/presentation/pages/admin_users_page.dart` |
| Codes promo | `features/admin/presentation/pages/admin_promos_page.dart` |
| FAQ | `features/support/presentation/pages/faq_page.dart` |
| Contact support | `features/support/presentation/pages/contact_support_page.dart` |
| Providers | `features/admin/presentation/providers/` |

#### Backend (`cine_pass_server/lib/src/`)

| Tâche | Fichier |
|-------|---------|
| Modèle FAQ | `models/faq.spy.yaml` |
| Endpoint dashboard | `endpoints/admin_endpoint.dart` |
| CRUD films/séances/salles admin | `endpoints/admin_endpoint.dart` |
| Gestion utilisateurs admin | `endpoints/admin_endpoint.dart` |
| Codes promo | `endpoints/promos_endpoint.dart` |
| Support (creerDemande, repondreDemande) | `endpoints/support_endpoint.dart` |
| FAQ | `endpoints/faq_endpoint.dart` |
| Rapports | `endpoints/rapports_endpoint.dart` |
| Export Excel/CSV/PDF | `services/export_service.dart` |
| Envoi emails | `services/email_service.dart` |

</details>
