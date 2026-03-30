# Schéma SQL CinePass

## Ordre obligatoire (sinon erreur `serverpod_auth_core_user` / `serverpod_migrations`)

Le fichier `cine_pass_schema.sql` contient des **FOREIGN KEY** vers `serverpod_auth_core_user`.  
Si tu exécutes ce SQL **avant** d’avoir créé les tables Serverpod (auth), PostgreSQL répond :  
`relation "serverpod_auth_core_user" does not exist` puis **ROLLBACK** de toute la transaction.

**Séquence correcte (base vide ou après `docker compose down -v`)** — depuis `cine_pass_server` :

1. Docker : `docker compose up --build --detach`
2. Mot de passe : `config/passwords.yaml` avec `development.database` = `mervy` (Docker du projet)
3. **Migrations « dépendances » auth (comme en CI)** — nécessite **Git Bash** ou WSL (le script est en `.sh`) :
   ```bash
   export PGPASSWORD=mervy
   bash scripts/apply_serverpod_dependency_migrations.sh
   ```
4. Migrations du module projet : `dart run bin/main.dart --apply-migrations`
5. Schéma métier + seed : `schema\reset_and_seed.cmd`
6. Serveur : `dart run bin/main.dart` (sans `--apply-migrations` si tu n’en veux pas à chaque démarrage)

Tu peux aussi enchaîner **3 → 4 → 5** sans lancer le SQL à la main : `reset_and_seed.cmd` enchaîne déjà `cine_pass_schema.sql` + `seed_data.sql` **après** que la base ait les tables auth (étapes 3–4).

---

## Lancer le backend avec une base propre (méthode simple)

Depuis **cine_pass_server** (avec Docker déjà démarré) :

```cmd
schema\reset_and_seed.cmd
```

Puis lancer le serveur :

```cmd
dart run bin/main.dart
```

Le script `reset_and_seed.cmd` exécute `cine_pass_schema.sql` (phase 0 = **DROP** des tables métier, puis **CREATE** complet : événements, détails par type, config billets, sièges, rôles, vues, triggers) puis le seed. Pour une base déjà remplie sans tout effacer, commentez la phase 0 en tête de `cine_pass_schema.sql` avant d’exécuter.

---

## Démarrer from scratch (première fois ou après clone)

1. **Démarrer Docker** (Postgres + Redis)  
   ```cmd
   docker compose up --build --detach
   ```

2. **Configurer les mots de passe**  
   ```cmd
   copy config\passwords.yaml.example config\passwords.yaml
   ```  
   Éditer `config\passwords.yaml` (mot de passe Postgres = `mervy` avec Docker).

3. **Migrations dépendances auth** (Git Bash / WSL, depuis `cine_pass_server`)  
   ```bash
   export PGPASSWORD=mervy
   bash scripts/apply_serverpod_dependency_migrations.sh
   ```

4. **Migrations module CinePass**  
   ```cmd
   dart run bin/main.dart --apply-migrations
   ```

5. **Schéma métier + seed**  
   ```cmd
   schema\reset_and_seed.cmd
   ```

6. **Lancer le serveur**  
   ```cmd
   dart run bin/main.dart
   ```

---

## Commandes manuelles (si besoin)

**Windows (CMD)** — depuis `cine_pass_server` :

| Étape   | Commande |
|--------|----------|
| Schéma complet (drop + tables + rôles) | **Uniquement après** migrations auth + `--apply-migrations` — puis `type schema\cine_pass_schema.sql \| docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass` |
| Seed   | `type schema\seed_data.sql \| docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass` |
| Drop seul (sans recréer) | `type schema\drop_cine_pass_tables.sql \| docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass` |

**FK `structureId` sur événements** : déjà dans `cine_pass_schema.sql` (`cine_pass_evenement_fk_0`).

---

**Note :** `drop_cine_pass_tables.sql` supprime uniquement les tables métier CinePass. Il ne touche pas aux tables Serverpod ni auth.

---

## Protocole vs base : même base

Le **protocole** (code généré dans `lib/src/generated/`) décrit ce que Serverpod **attend** comme schéma. Au démarrage, le serveur se connecte à la base (celle de `config/development.yaml` : `localhost:8090`, base `cine_pass`) et **lit** les tables, contraintes et index réels. Il compare « base réelle » vs « protocole ». Si ça ne colle pas → warning.

Donc :
- **Une seule base** : celle du conteneur Postgres mappée sur le port 8090. Les scripts `schema\*.sql` et le serveur Dart utilisent la même (via `docker exec … -d cine_pass` et `development.yaml`).
- Si le warning s’affiche, en général la base n’a **pas** été recréée avec le dernier `cine_pass_schema.sql` (drop + schema + seed).

**Vérifier que la base a bien les FK et l’index attendus** (PowerShell, depuis `cine_pass_server`) :

```powershell
Get-Content schema\verif_same_db.sql -Raw | docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass -t
```

Tu dois voir **7 lignes** (une par contrainte/index). Si tu en as moins, relancer `schema\reset_and_seed.cmd` puis `dart run bin/main.dart`.
