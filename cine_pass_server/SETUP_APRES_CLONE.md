# 🚀 CinePass — Guide d'installation et de lancement

Ce guide explique **pas à pas** comment cloner le projet et le faire tourner en local, depuis zéro.

---

## 📋 Prérequis

| Outil | Version minimale | Vérification |
|-------|-----------------|-------------|
| Flutter SDK | 3.32+ | `flutter --version` |
| Dart SDK | 3.8+ | `dart --version` |
| Docker Desktop | Dernière version | `docker --version` |
| Serverpod CLI | 3.4+ | `serverpod --version` |

Pour installer Serverpod CLI :
```bash
dart pub global activate serverpod_cli
```

---

## 1️⃣ Cloner le projet

```bash
git clone <url-du-repo>
cd cine_pass
```

---

## 2️⃣ Configurer les mots de passe et secrets

> ⚠️ `passwords.yaml` n'est **jamais** versionné. Il faut le créer après chaque clone.

```bash
cd cine_pass_server
cp config/passwords.yaml.example config/passwords.yaml
```

Édite `config/passwords.yaml` et remplace les valeurs :

```yaml
development:
  database: "mervy"       # mot de passe Postgres Docker (voir docker-compose.yaml)
  jwtRefreshTokenHashPepper: "au-moins-10-caracteres-secrets"
  jwtHmacSha512PrivateKey: "cle-hmac-sha512-minimum-64-caracteres-xxxxxxxxxxxxxxxx"
  emailSecretHashPepper: "au-moins-10-caracteres"
  # Colle ici le JSON du client OAuth Web Google (avec redirect_uris !)
  googleClientSecret: '{"web":{"client_id":"TON_CLIENT_ID_WEB.apps.googleusercontent.com","project_id":"ton-projet","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_secret":"TON_CLIENT_SECRET","redirect_uris":["http://localhost:9080/auth/google/callback"]}}'
```

> 💡 Le JSON `googleClientSecret` s'obtient dans **Google Cloud Console → APIs & Services → Credentials** → télécharger le JSON du client OAuth **Web application**.
> Il doit obligatoirement contenir `redirect_uris`.

---

## 3️⃣ Configurer Google Cloud Console

Pour que l'authentification Google fonctionne, il faut deux clients OAuth :

### Client Web (utilisé par le serveur et Flutter Web)
- Type : **Web application**
- **Authorized redirect URIs** : `http://localhost:9080/auth/google/callback`
- **Authorized JavaScript origins** : `http://localhost:7357`

### Client Android
- Type : **Android**
- Package name : `com.example.cine_pass_flutter` (voir `android/app/build.gradle.kts`)
- SHA-1 : ton SHA-1 de debug (`keytool -list -v -keystore ~/.android/debug.keystore`)

---

## 4️⃣ Démarrer la base de données (Docker)

```bash
cd cine_pass_server
docker compose up --build --detach
```

Vérifie que Postgres tourne sur le port `8090` :
```bash
docker ps
```

---

## 5️⃣ Installer les dépendances

```bash
# À la racine du monorepo
cd cine_pass
dart pub get

# Puis Flutter
cd cine_pass_flutter
flutter pub get
```

---

## 6️⃣ Appliquer les migrations Serverpod

```bash
cd cine_pass_server
dart run bin/main.dart --apply-migrations
```

> C'est obligatoire après un premier clone ou après l'ajout de nouvelles migrations.

---

## 7️⃣ Charger les données métier (schéma + seed)

```powershell
# Windows PowerShell
type schema\drop_cine_pass_tables.sql | docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass
type schema\cine_pass_schema.sql      | docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass
type schema\seed_data.sql             | docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass
```

```bash
# macOS / Linux
docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass < schema/drop_cine_pass_tables.sql
docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass < schema/cine_pass_schema.sql
docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass < schema/seed_data.sql
```

---

## 8️⃣ Lancer le serveur

```bash
cd cine_pass_server
dart run bin/main.dart --mode development
```

Ports utilisés :
- API : `http://localhost:9080`
- Web : `http://localhost:9082`

> ℹ️ Le message `Invalid serviceSecret in password file, Insights server disabled` est **normal** en dev.

---

## 9️⃣ Lancer l'application Flutter

### Sur Web
```bash
cd cine_pass_flutter
flutter run -d chrome \
  --web-hostname localhost --web-port 7357 \
  --dart-define=GOOGLE_CLIENT_ID=TON_CLIENT_ID_ANDROID.apps.googleusercontent.com \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=TON_CLIENT_ID_WEB.apps.googleusercontent.com
```

### Sur Android
```bash
cd cine_pass_flutter
flutter run -d <device-id> \
  --dart-define=GOOGLE_CLIENT_ID=TON_CLIENT_ID_ANDROID.apps.googleusercontent.com \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=TON_CLIENT_ID_WEB.apps.googleusercontent.com
```

---

## 🔄 Regénérer le code Serverpod

Après toute modification d'un modèle `.yaml` :

```bash
cd cine_pass_server
serverpod generate
```

> ⚠️ Ne **jamais** modifier manuellement `cine_pass_server/lib/src/generated/` ni `cine_pass_client/`.

---

## 🔁 Reset complet de la base

```bash
docker compose down -v
docker compose up --build --detach
# Reprendre depuis l'étape 6
```

---

## 🧯 Problèmes courants

| Erreur | Cause | Solution |
|--------|-------|---------|
| `Missing "redirect_uris"` au démarrage | `googleClientSecret` sans `redirect_uris` | Ajouter `"redirect_uris":["http://localhost:9080/auth/google/callback"]` dans le JSON |
| `401 invalid_client` Google | Mauvais `client_id` ou secret expiré | Vérifier que le JSON dans `googleClientSecret` correspond au client Web actif dans Google Console |
| Port 9080/9082 déjà utilisé | Un serveur précédent tourne encore | Tuer le process Dart précédent |
| `Only one usage of each socket` | Même cause | `Get-Process dart | Stop-Process` sous PowerShell |
| Kotlin cache crash sur Windows | Projets sur lecteurs différents (D: vs C:) | Déjà configuré dans `android/gradle.properties` avec `kotlin.incremental=false` |

---

## 📁 Fichiers importants

| Fichier | Rôle |
|---------|------|
| `config/passwords.yaml` | Secrets locaux — **ne pas commiter** |
| `config/development.yaml` | Config ports et DB pour le dev |
| `config/google_client_secret.json` | Secret OAuth Google — **ne pas commiter** |
| `cine_pass_flutter/web/index.html` | Meta `google-signin-client_id` pour Flutter Web |
| `cine_pass_flutter/lib/main.dart` | Init client + Google Sign-In |
| `cine_pass_flutter/android/gradle.properties` | Fix Kotlin incremental cache Windows |

---

# Pourquoi il y a des problèmes à chaque clone (migrations, config…)

Quand on clone le dépôt, **plusieurs choses ne sont pas dans Git** (volontairement) ou **dépendent de l’environnement**. D’où les erreurs si on ne refait pas un minimum de setup.

## Ce qui n’est pas versionné (et pourquoi)

| Élément | Raison | À faire après clone |
|--------|--------|----------------------|
| **`config/passwords.yaml`** | Contient des mots de passe → ne doit **jamais** être commité. | Copier `config/passwords.yaml.example` en `config/passwords.yaml`, puis remplir **toutes** les clés : `development.database`, `jwtRefreshTokenHashPepper`, `jwtHmacSha512PrivateKey`, `emailSecretHashPepper` (voir l’example). |
| **Base de données** | La base (Postgres) et les tables ne sont pas dans le repo. | Lancer Docker puis appliquer les migrations (voir ci‑dessous). |
| **Migrations appliquées** | L’état “quelle migration a été appliquée” est dans la base, pas dans Git. | Toujours exécuter `dart run bin/main.dart --apply-migrations` une fois Postgres + `passwords.yaml` en place. |

## Ordre à respecter après un clone

1. **Démarrer Postgres (et Redis si besoin)**  
   Depuis `cine_pass_server` :
   ```bash
   docker compose up --build --detach
   ```

2. **Créer le fichier des mots de passe**  
   ```bash
   cp config/passwords.yaml.example config/passwords.yaml
   ```  
   Le fichier example contient toutes les clés nécessaires (base + auth JWT/Email). Avec Docker, le mot de passe Postgres est `mervy`. Les peppers JWT/Email peuvent rester les valeurs de l’example en dev, ou être remplacés par des chaînes secrètes (≥ 10 caractères pour les peppers, ≥ 64 pour `jwtHmacSha512PrivateKey`).

3. **Vérifier la config**  
   `config/development.yaml` est déjà réglé pour Docker :  
   - base sur le port **8090** (car Docker expose Postgres en 8090 sur la machine).  
   Si tu utilises un Postgres **local** sur le port 5432, change `database.port` en `5432` dans `development.yaml`.

4. **Installer les deps et appliquer les migrations**  
   À la racine du monorepo (ou dans chaque package) :
   ```bash
   dart pub get   # ou depuis la racine : melos bootstrap / pub get selon le projet
   cd cine_pass_server
   dart run bin/main.dart --apply-migrations
   ```

5. **Optionnel : schéma métier**  
   Si le projet utilise aussi `schema/cine_pass_schema.sql`, l’exécuter une fois sur la base (après les migrations Serverpod) :
   ```bash
   psql -h localhost -p 8090 -U postgres -d cine_pass -f schema/cine_pass_schema.sql
   ```
   (Mot de passe : celui dans `passwords.yaml`, avec Docker : `mervy`.)

Ensuite tu peux lancer le serveur et le frontend comme d’habitude.

## En résumé

- **Migrations** : normales après un clone, car la base est vide → il faut appliquer les migrations une fois.
- **passwords.yaml** : normal qu’il manque → copier l’example et remplir le mot de passe.
- **Port 8090** : nécessaire si tu utilises le `docker-compose` du projet (Postgres exposé en 8090).

Si tu suis cet ordre à chaque clone, les “problèmes de migrations et plusieurs choses” disparaissent, car tout est refait de façon cohérente.


type schema\drop_cine_pass_tables.sql | docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass
type schema\cine_pass_schema.sql | docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass
type schema\seed_data.sql | docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass