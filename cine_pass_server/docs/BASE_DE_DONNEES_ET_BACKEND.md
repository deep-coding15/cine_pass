# Base de données et liaison avec le backend CinePass

## 1. Créer la base de données PostgreSQL

Le backend utilise **PostgreSQL**. La config est dans `config/development.yaml` (base `cine_pass`, utilisateur `postgres`).

### Option A : PostgreSQL installé localement

1. **Créer la base** (port par défaut 5432) :
   ```bash
   psql -U postgres -c "CREATE DATABASE cine_pass;"
   ```

2. **Adapter la config** dans `config/development.yaml` :
   - `database.port` : en général `5432` (pas 8090 sauf si ton Postgres écoute là).
   - `database.host` : `localhost`.
   - `database.name` : `cine_pass`.
   - `database.user` : `postgres`.

3. **Mot de passe** : à mettre dans `config/passwords.yaml` (clé `database`).  
   Ne pas commiter ce fichier (il est ignoré par git).

### Option B : Docker (PostgreSQL + Redis)

Si tu utilises `docker compose` à la racine du serveur :

- Le fichier `docker-compose.yml` (s’il existe) définit un conteneur Postgres.
- Une fois les conteneurs démarrés, la base est créée automatiquement si le script le prévoit, sinon :
  ```bash
  docker exec -it <nom_conteneur_postgres> psql -U postgres -c "CREATE DATABASE cine_pass;"
  ```
- Dans `development.yaml`, mets `database.host` sur `localhost` (ou le nom du service si Flutter tourne dans Docker) et le port exposé par le conteneur.

## 2. Lier le backend à la base

1. **Mots de passe**  
   Crée `config/passwords.yaml` (tu peux t’inspirer de `passwords.yaml.example` s’il existe) et ajoute la clé pour la base :
   ```yaml
   database: 'ton_mot_de_passe_postgres'
   ```
   Et les clés pour l’auth (JWT, email, etc.) si tu utilises l’auth Serverpod.

2. **Migrations Serverpod**  
   Les tables **Serverpod** (auth, sessions, etc.) sont créées en appliquant les migrations :
   ```bash
   cd cine_pass_server
   dart run bin/main.dart --apply-migrations
   ```
   Cela crée les tables `serverpod_*` et `serverpod_auth_*` dans la base `cine_pass`.

3. **Tables métier CinePass (films, séances, salles, etc.)**  
   Deux possibilités :

   - **Méthode A – Migrations Serverpod (recommandé)**  
     - Installer la CLI Serverpod : `dart pub global activate serverpod_cli`  
     - Depuis la racine du monorepo (où se trouve le workspace) ou depuis `cine_pass_server` :
       ```bash
       serverpod create-migration
       ```
     - Puis relancer :
       ```bash
       dart run bin/main.dart --apply-migrations
       ```
     - Les tables `cine_pass_*` seront créées ou mises à jour selon les modèles dans `lib/src/models/*.spy.yaml`.

   - **Méthode B – Script SQL à la main**  
     - Après avoir appliqué les migrations Serverpod (étape 2), exécuter le script des tables métier :
       ```bash
       psql -U postgres -d cine_pass -f schema/cine_pass_schema.sql
       ```
     - Le schéma dans `schema/cine_pass_schema.sql` doit rester cohérent avec les modèles `.spy.yaml` (noms de tables et colonnes).

## 3. Modèles liés à la Programmation (films, séances, salles, cinémas)

Les modèles sont dans **`lib/src/models/`** :

| Fichier               | Classe      | Table SQL             | Rôle |
|-----------------------|------------|------------------------|------|
| `cine_pass_row.spy.yaml` | CinePassRow | (aucune, base commune) | id UUID, createdAt |
| `film.spy.yaml`       | Film       | cine_pass_film        | Film (titre, genre, durée, synopsis, etc.) |
| `cinema.spy.yaml`     | Cinema     | cine_pass_cinema      | Cinéma (nom, ville, adresse) |
| `salle.spy.yaml`      | Salle      | cine_pass_salle       | Salle (cinéma, nom, capacité) |
| `siege.spy.yaml`      | Siege      | cine_pass_siege       | Siège (salle, rangée, numéro) |
| `seance.spy.yaml`     | Seance     | cine_pass_seance     | Séance (film, salle, date/heure, prix, options) |
| `evenement.spy.yaml`  | Evenement  | cine_pass_evenement   | Événement (concert, théâtre, etc.) |

Après modification d’un `.spy.yaml` :

1. Lancer **`serverpod generate`** (depuis le projet où la CLI est dispo, souvent à la racine du repo).
2. Puis **`serverpod create-migration`** pour générer une migration.
3. Enfin **`dart run bin/main.dart --apply-migrations`** dans `cine_pass_server` pour appliquer en base.

Le client généré (`cine_pass_client`) et le protocole du serveur sont mis à jour par `serverpod generate`, ce qui permet à l’app Flutter d’utiliser les mêmes types (Film, Seance, etc.) et de faire des réservations réelles via le backend.

## 4. Résumé des étapes

1. Créer la base PostgreSQL `cine_pass`.
2. Renseigner `config/passwords.yaml` (au minimum `database`).
3. Vérifier `config/development.yaml` (host, port, name, user).
4. Appliquer les migrations : `dart run bin/main.dart --apply-migrations`.
5. Soit exécuter `schema/cine_pass_schema.sql` à la main, soit créer une migration à partir des modèles puis réappliquer les migrations.
6. Démarrer le serveur : `dart run bin/main.dart`.

Ensuite, tu peux brancher l’app Flutter sur ce backend (URL du serveur dans `cine_pass_flutter`) pour afficher films/événements et gérer les réservations avec de vraies données.
