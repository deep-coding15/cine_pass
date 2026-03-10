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
