# 🎬 CinePass — Architecture & Répartition des tâches

## Structure générale

```
cine_pass/
├── cine_pass_server/     # Backend Serverpod
├── cine_pass_client/     # Client généré automatiquement (ne pas modifier !)
└── cine_pass_flutter/    # Application Flutter (frontend)
```

---

## 📁 cine_pass_server — Backend

```
cine_pass_server/
├── bin/
│   └── main.dart
├── config/
│   ├── development.yaml
│   └── passwords.yaml        # ⚠️ Ne pas commiter !
└── lib/
    └── src/
        ├── models/           # Modèles .spy.yaml → définissent les tables BD
        ├── endpoints/        # Fonctions appelables depuis Flutter
        └── generated/        # ⚠️ Généré automatiquement, ne pas modifier !
```

---

## 📁 cine_pass_client — Client généré

> ⚠️ **Ne jamais modifier ce dossier manuellement !**
> Il est regénéré automatiquement à chaque `serverpod generate`.

---

## 📁 cine_pass_flutter — Frontend Flutter

```
cine_pass_flutter/
└── lib/
    ├── main.dart
    ├── core/
    │   ├── router/            # Navigation (go_router)
    │   └── constants/         # URL, configurations
    └── features/
        ├── auth/              # Personne 1
        ├── profil/            # Personne 1
        ├── home/              # Personne 2
        ├── programmation/     # Personne 2
        ├── reservation/       # Personne 3
        ├── paiement/          # Personne 3
        ├── billets/           # Personne 3
        ├── admin/             # Personne 4
        └── support/           # Personne 4
```

---

## 🔄 Flux de travail

```
1. Modifier un modèle dans cine_pass_server/lib/src/models/
           ↓
2. Lancer : serverpod generate
           ↓
3. Le client cine_pass_client est mis à jour automatiquement
           ↓
4. Flutter utilise les nouvelles classes via le client
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Comment le projet a été conçu : stack, auth Google + SMS, IDP, schéma |
| **[cine_pass_server/SETUP_APRES_CLONE.md](cine_pass_server/SETUP_APRES_CLONE.md)** | Guide complet pour installer et lancer le projet depuis zéro |

---

## 🚀 Lancer le projet

**Après un clone**, il faut une fois refaire la config et les migrations (mot de passe non versionné, base vide). → Voir **[cine_pass_server/SETUP_APRES_CLONE.md](cine_pass_server/SETUP_APRES_CLONE.md)** pour le guide complet.

```bash
# 1. Démarrer Postgres (Docker)
cd cine_pass_server
docker compose up --build --detach

# 2. Configurer les mots de passe (fichier non versionné)
cp config/passwords.yaml.example config/passwords.yaml
# Éditer config/passwords.yaml : development.database = mervy (mot de passe Docker)

# 3. Installer les dépendances (à la racine ou dans chaque package)
dart pub get
cd ../cine_pass_flutter && flutter pub get
cd ../cine_pass_server

# 4. Appliquer les migrations (obligatoire après un clone)
dart run bin/main.dart --apply-migrations

# 5. Lancer le serveur
dart run bin/main.dart

# 6. Lancer Flutter (autre terminal)
cd cine_pass_flutter
flutter run -d chrome
```

---

## ⚠️ Règles importantes

1. **Ne jamais modifier** les fichiers dans `generated/` et `cine_pass_client/`
2. **Toujours lancer** `serverpod generate` après modification d'un `.spy.yaml`
3. **Ne jamais commiter** `passwords.yaml` (après un clone : copier `passwords.yaml.example` en `passwords.yaml`)
4. **Toujours créer une branche** avant de travailler : `git checkout -b feature/ma-fonctionnalite`
5. **Tester le serveur** avant de pousser sur `main`
6. **Ne pas mélanger** les tâches des autres personnes

---

## 👥 Répartition des tâches

---

### 👤 Personne 1 — Auth, profil, utilisateurs

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

---

### 👤 Personne 2 — Programmation (films, séances, salles, cinémas)

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

---

### 👤 Personne 3 — Réservation, paiement, billets

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

---

### 👤 Personne 4 — Admin, support, rapports

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
