# 🚀 Projet Full Stack Dart (Serverpod)

Ce projet est une application Full Stack développée intégralement en **Dart**. Elle utilise **Serverpod** pour le backend et la synchronisation des données, et **Flutter** pour l'interface utilisateur.

---

## 🛠️ Structure du Projet

Le projet est divisé en trois parties principales :

*   **`cine_pass_server`** : Le serveur backend (API, logique métier, accès base de données).
*   **`cine_pass_client`** : Le code généré automatiquement facilitant la communication entre le front et le back.
*   **`cine_pass_flutter`** : L'application mobile/web/desktop.

---

## 🚀 Démarrage Rapide

### 1. Prérequis
*   [Flutter SDK](https://docs.flutter.dev) installé.
*   [Docker Desktop](https://www.docker.com) (pour la base de données PostgreSQL).
*   CLI Serverpod : `dart pub global activate serverpod_cli`

### 2. Lancer la Base de Données
Naviguez dans le dossier serveur et démarrez les conteneurs Docker :
```bash
cd cine_pass_server
docker compose up --build --detach
```

### 3. Lancer le serveur backend
Naviguez dans le dossier serveur et démarrez le serveur backend :
```bash
dart bin/main.dart --apply-migrations
```

### 4. Lancer le frontend
```bash
cd cine_pass_flutter
flutter run
```

### 5. Flux de Développement (Modèles de données)
#### a. Pour modifier la structure de vos données :
Modifiez les fichiers .yaml dans cine_pass_server/lib/src/models.
Générez le code client :
```bash
cd cine_pass_server
serverpod generate
```

#### b. Appliquez les changements en base de données :
```bash
serverpod create-migration
dart bin/main.dart --apply-migrations
```