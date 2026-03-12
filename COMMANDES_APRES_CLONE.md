# Commandes à lancer après avoir cloné le projet CinePass

À donner à quelqu’un qui clone le repo pour la première fois. **Ordre à respecter.**

---

## Prérequis

- **Git** installé
- **Docker Desktop** installé et démarré (Postgres + Redis)
- **Dart** installé (SDK 3.8+)
- **Flutter** installé

---

## 1. Cloner le projet

```bash
git clone <URL_DU_REPO> cine_pass
cd cine_pass
```

---

## 2. Backend (serveur Serverpod)

Toutes les commandes suivantes sont à lancer **depuis le dossier `cine_pass_server`**, sauf indication contraire.

### 2.1 Démarrer Docker (Postgres + Redis)

```bash
cd cine_pass_server
docker compose up --build --detach
```

**Windows (CMD) :**
```cmd
cd cine_pass_server
docker compose up --build --detach
```

### 2.2 Fichier des mots de passe (obligatoire)

Le fichier `config/passwords.yaml` n’est pas versionné. Il faut le créer à partir de l’exemple :

**Windows (CMD) :**
```cmd
copy config\passwords.yaml.example config\passwords.yaml
```

**Windows (PowerShell) / Linux / Mac :**
```bash
cp config/passwords.yaml.example config/passwords.yaml
```

Puis **éditer** `config/passwords.yaml` et mettre au minimum :
- `development.database` : mot de passe Postgres (avec Docker = **mervy**)
- Les autres clés (JWT, email) peuvent rester comme dans l’example en dev

### 2.3 Dépendances Dart

**À la racine du projet** (dossier `cine_pass`) ou dans chaque package :

```bash
cd cine_pass
dart pub get
```

Puis :

```bash
cd cine_pass_server
dart pub get
```

### 2.4 Générer le protocole Serverpod (client + code)

```bash
cd cine_pass_server
dart run serverpod_cli generate
```

### 2.5 Migrations Serverpod (tables auth, etc.)

```bash
cd cine_pass_server
dart run bin/main.dart --apply-migrations
```

### 2.6 Schéma métier + données de test

```bash
cd cine_pass_server
schema\reset_and_seed.cmd
```

**Sous PowerShell :** tu peux lancer le même script : `.\schema\reset_and_seed.cmd`

### 2.7 Lancer le serveur

```bash
cd cine_pass_server
dart run bin/main.dart
```

Laisser ce terminal ouvert (serveur en cours d’exécution).

---

## 3. Frontend Flutter (autre terminal)

Ouvrir un **nouveau terminal**, à la racine du projet :

```bash
cd cine_pass
cd cine_pass_flutter
flutter pub get
flutter run -d chrome
```

**Windows (CMD) :**
```cmd
cd cine_pass\cine_pass_flutter
flutter pub get
flutter run -d chrome
```

---

## Récap en une liste (ordre exact)

| # | Où          | Commande |
|---|-------------|----------|
| 1 | `cine_pass` | `git clone <url> cine_pass` puis `cd cine_pass` |
| 2 | `cine_pass_server` | `docker compose up --build --detach` |
| 3 | `cine_pass_server` | `copy config\passwords.yaml.example config\passwords.yaml` (Windows) ou `cp config/passwords.yaml.example config/passwords.yaml` (Mac/Linux) |
| 4 | - | Éditer `cine_pass_server/config/passwords.yaml` → `development.database: "mervy"` (si Docker) |
| 5 | `cine_pass_server` | `dart pub get` |
| 6 | `cine_pass_server` | `dart run serverpod_cli generate` |
| 7 | `cine_pass_server` | `dart run bin/main.dart --apply-migrations` |
| 8 | `cine_pass_server` | `schema\reset_and_seed.cmd` (Windows) ou exécuter le script équivalent |
| 9 | `cine_pass_server` | `dart run bin/main.dart` **(garder ce terminal ouvert)** |
| 10 | **Nouveau terminal** → `cine_pass_flutter` | `flutter pub get` puis `flutter run -d chrome` |

---

## En cas de problème

- **Docker** : vérifier que Docker Desktop est bien démarré.
- **Port 8090** : le serveur attend Postgres sur `localhost:8090` (voir `cine_pass_server/config/development.yaml`). C’est le port exposé par le `docker-compose` du projet.
- **Erreur "database" / mot de passe** : vérifier que `passwords.yaml` existe et que `development.database` correspond au mot de passe Postgres (Docker = `mervy`).
- **Warning "database does not match"** au démarrage du serveur : relancer `schema\reset_and_seed.cmd` puis `dart run bin/main.dart`.
