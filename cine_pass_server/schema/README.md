# Schéma SQL CinePass

## Lancer le backend avec une base propre (méthode simple)

Depuis **cine_pass_server** (avec Docker déjà démarré) :

```cmd
schema\reset_and_seed.cmd
```

Puis lancer le serveur :

```cmd
dart run bin/main.dart
```

Le script `reset_and_seed.cmd` exécute `cine_pass_schema.sql` (qui **supprime puis recrée** tout le schéma métier en un seul fichier) puis le seed. Aucun warning Serverpod si la base est cohérente.

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

3. **Migrations Serverpod** (tables auth, etc.)  
   ```cmd
   dart run bin/main.dart --apply-migrations
   ```

4. **Schéma métier + seed**  
   ```cmd
   schema\reset_and_seed.cmd
   ```

5. **Lancer le serveur**  
   ```cmd
   dart run bin/main.dart
   ```

---

## Commandes manuelles (si besoin)

**Windows (CMD)** — depuis `cine_pass_server` :

| Étape   | Commande |
|--------|----------|
| Schéma complet (drop + tables + rôles) | `type schema\cine_pass_schema.sql \| docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass` |
| Seed   | `type schema\seed_data.sql \| docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass` |
| Drop seul (sans recréer) | `type schema\drop_cine_pass_tables.sql \| docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass` |

**FK manquante sur `structureId`** : déjà gérée dans `cine_pass_schema.sql` (bloc DO). Inutile d’exécuter un script à part.

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
