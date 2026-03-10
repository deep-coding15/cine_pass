# Pourquoi « The database does not match the target database » ?

## Explication courte

Serverpod compare la base de données à une **cible** dérivée de tes modèles (fichiers `.spy.yaml`).  
Si les **noms des colonnes** en base ne sont pas **exactement** ceux attendus, tu obtiens des erreurs du type :

- `Missing Column "code_postal"`
- `Missing Column "created_at"`
- etc.

## La cause : camelCase vs snake_case

- En **Dart** (et dans le code généré), les champs sont en **camelCase** : `codePostal`, `createdAt`, `filmId`, `salleId`, `debutAt`, `prixBase`, `dureeMinutes`, `dateSortie`, `eventDate`, `placesTotal`, etc.
- Serverpod utilise **ces mêmes noms** pour les colonnes **PostgreSQL** (avec des guillemets pour garder la casse).
- Si tu crées les tables à la main avec du **snake_case** (`code_postal`, `created_at`, `film_id`), PostgreSQL considère que ce sont des colonnes **différentes** de `codePostal`, `createdAt`, `filmId`. Du coup Serverpod ne les trouve pas et signale qu’elles sont « manquantes ».

Donc : **en base, les colonnes doivent être en camelCase**, comme dans les modèles Dart / le code généré.

## Où voir la « cible » attendue

La structure attendue est définie par :

1. Les fichiers **`lib/src/models/*.spy.yaml`** (modèles métier).
2. Le code **généré** dans `lib/src/generated/` (ex. `cinema.dart`, `film.dart`) : chaque colonne est créée avec un nom explicite, ex. `ColumnString('codePostal', this)`.
3. Le **`protocol.dart`** : `targetTableDefinitions` décrit exactement les tables et colonnes que Serverpod attend.

Si tu ouvres `protocol.dart` et que tu regardes une table (ex. `cine_pass_cinema`), tu vois les colonnes attendues : `id`, `createdAt`, `nom`, `ville`, `adresse`, `codePostal`. Ce sont ces noms qu’il faut utiliser en base.

## Que faire pour que ça marche « pour la dernière fois »

1. **Utiliser le schéma SQL fourni** (`schema/cine_pass_schema.sql`) qui a été aligné sur ces noms : **colonnes en camelCase** pour les tables gérées par Serverpod (film, cinema, salle, siege, seance, evenement).
2. **Après un clone ou une base vide** :
   - Lancer les migrations Serverpod : `dart run bin/main.dart --apply-migrations`
   - Puis exécuter le schéma métier (voir `schema/README.md`), par exemple :
     - Avec Docker :  
       `Get-Content schema/drop_cine_pass_tables.sql -Raw | docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass`  
       puis  
       `Get-Content schema/cine_pass_schema.sql -Raw | docker exec -i cine_pass_server-postgres-1 psql -U postgres -d cine_pass`
3. **Ne pas mélanger** un ancien schéma en snake_case avec le code actuel : soit tout est géré par le schéma aligné (camelCase), soit tu laisses Serverpod créer les tables via `serverpod create-migration` + `--apply-migrations`.

En résumé : le message veut dire « la structure réelle de la base ne correspond pas à ce que les modèles définissent ». La correction est d’utiliser **exactement** les mêmes noms de colonnes que Serverpod (camelCase), comme dans le `cine_pass_schema.sql` à jour.
