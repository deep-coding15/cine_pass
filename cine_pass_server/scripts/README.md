# Scripts CinePass

## Ordre des opérations

### 1. Créer la base PostgreSQL

**Option A – pgAdmin (recommandé sous Windows)**  
- Connexion à PostgreSQL (utilisateur `postgres`, mot de passe celui dans `config/passwords.yaml` → `development.database`).  
- Clic droit sur « Databases » → Create → Database.  
- Nom : `cine_pass`. Valider.

**Option B – Ligne de commande**  
Si `psql` est dans le PATH :
```bash
psql -U postgres -c "CREATE DATABASE cine_pass;"
```
Sinon, avec le chemin complet (adapter la version 15/16 si besoin) :
```bash
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE cine_pass;"
```

### 2. Appliquer les migrations Serverpod

Depuis la racine du repo :
```bash
cd cine_pass_server
dart run bin/main.dart --apply-migrations
```
Cela crée les tables Serverpod (auth, sessions, etc.) dans `cine_pass`.

### 3. Créer les tables métier CinePass

Depuis `cine_pass_server`, avec `psql` dans le PATH :
```bash
psql -U postgres -d cine_pass -f schema/cine_pass_schema.sql
```
Avec chemin complet :
```bash
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d cine_pass -f schema/cine_pass_schema.sql
```
Ou dans pgAdmin : ouvrir `schema/cine_pass_schema.sql`, se connecter à la base `cine_pass`, puis exécuter le script.

### 4. Démarrer le serveur

```bash
cd cine_pass_server
dart run bin/main.dart
```

---

**Config** : `config/development.yaml` utilise le port **5432**, la base **cine_pass** et l’utilisateur **postgres**. Le mot de passe est dans `config/passwords.yaml` (clé `development.database`).
