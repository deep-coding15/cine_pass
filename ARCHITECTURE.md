# 📐 CinePass — Comment le projet a été conçu

Ce document explique les choix techniques, l'architecture et comment les principales fonctionnalités ont été implémentées.

---

## 🗂️ Structure du monorepo

```
cine_pass/
├── cine_pass_server/     # Backend Dart — Serverpod
├── cine_pass_client/     # Client généré automatiquement (NE PAS MODIFIER)
└── cine_pass_flutter/    # Application Flutter (Web + Android + iOS)
```

Le projet utilise un **workspace Dart** (déclaré dans `pubspec.yaml` racine) pour partager les dépendances entre `server`, `client`, et `flutter`.

---

## ⚙️ Backend — `cine_pass_server`

### Stack
- **Serverpod 3.4** : framework backend Dart avec génération de code automatique
- **PostgreSQL** : base de données relationnelle (via Docker en dev)
- **JWT (HMAC-SHA512)** : gestion des tokens d'authentification

### Architecture du serveur

```
cine_pass_server/lib/
├── server.dart                    # Point d'entrée : initialise Serverpod, auth, routes
└── src/
    ├── auth/                      # Endpoints d'authentification
    │   ├── google_idp_endpoint.dart    # Connexion Google (OAuth 2.0)
    │   ├── phone_auth_endpoint.dart    # Connexion par SMS (OTP)
    │   └── jwt_refresh_endpoint.dart   # Refresh des tokens JWT
    ├── cine_pass/
    │   └── cine_pass_endpoint.dart     # Films, séances, cinémas, événements
    ├── models/                    # Définitions YAML des modèles/tables
    │   └── phone_auth_code.yaml        # Modèle OTP SMS
    └── generated/                 # Généré par serverpod generate (NE PAS MODIFIER)
        ├── endpoints.dart
        └── protocol.dart
```

### Authentification serveur

L'authentification repose sur **Serverpod Auth IDP** (`serverpod_auth_idp_server`) :

```
Utilisateur
    │
    ├── Google Sign-In ──→ GoogleIdpEndpoint ──→ google_idp_server
    │                          ↓
    │                   Valide le idToken Google
    │                          ↓
    └── SMS OTP ──────→ PhoneAuthEndpoint
                               ↓
                        Vérifie le code OTP
                               ↓
                    AuthServices.tokenManager.issueToken()
                               ↓
                       JWT (access + refresh)
```

### Google IDP côté serveur
Le serveur lit la configuration Google depuis `config/passwords.yaml` via `GoogleIdpConfigFromPasswords()` :
- Nécessite la clé `googleClientSecret` avec le JSON du **client OAuth Web** (pas Android)
- Le JSON doit contenir `redirect_uris` (obligatoire par Serverpod)

### SMS OTP côté serveur
- Table `phone_auth_code` : stocke le code haché + expiration
- Endpoint `sendVerificationCode` : génère et envoie (log en dev, Twilio en prod)
- Endpoint `verifyCode` : vérifie, crée/retrouve `AuthUser` + `UserProfile`, retourne JWT

---

## 📱 Frontend — `cine_pass_flutter`

### Stack
- **Flutter 3.32** — cible Web, Android, iOS
- **go_router** : navigation déclarative
- **provider** : gestion d'état
- **serverpod_auth_idp_flutter** : widgets d'authentification (Google, OTP)

### Architecture Flutter

```
cine_pass_flutter/lib/
├── main.dart                         # Initialisation client + Google Sign-In
├── core/
│   ├── router/app_router.dart        # Routes go_router
│   ├── state/auth_state.dart         # État auth (lié à client.auth)
│   ├── theme/app_theme.dart          # Thème sombre CinePass
│   └── widgets/                      # Widgets partagés
└── features/
    ├── auth/                         # Connexion (Google + SMS)
    ├── home/                         # Page d'accueil
    ├── films/                        # Liste et détail films
    ├── events/                       # Événements
    ├── reservation/                  # Réservation sièges
    ├── billets/                      # Billets / QR code
    ├── profil/                       # Profil utilisateur
    ├── admin/                        # Espace admin
    ├── faq/                          # FAQ
    └── support/                      # Support utilisateur
```

### Initialisation Google Sign-In (`main.dart`)

```dart
// Sur mobile : utilise le client Android pour le sign-in natif,
// et le client Web comme serverClientId pour la validation backend
if (!kIsWeb) {
  await client.auth.initializeGoogleSignIn(
    clientId: _defaultGoogleAndroidClientId,  // th1oi... (Android)
    serverClientId: _defaultGoogleWebClientId, // qgeac... (Web, valide idToken)
  );
}
// Sur Web : la meta tag <google-signin-client_id> dans index.html suffit
```

### Gestion de l'état auth (`auth_state.dart`)

```
AuthState (singleton)
    │
    └── bindToClientAuth()
              │
              └── écoute client.auth.authInfoListenable
                          │
                          ├── isAuthenticated → notifyListeners()
                          ├── récupère userName / email depuis authInfo
                          └── rafraîchit le profil via API server
```

### Page de connexion (`connexion_page.dart`)

```
ConnexionPage
    ├── GoogleSignInWidget      → sign-in Google (Web: popup, Android: natif)
    │       └── onAuthenticated → _handlePostAuthRedirect()
    ├── TextFormField (téléphone)
    ├── Bouton "Envoyer SMS"    → client.phoneAuth.sendVerificationCode()
    ├── TextFormField (code)
    └── Bouton "Vérifier"       → client.phoneAuth.verifyCode()
                                       ↓
                                client.auth.updateSignedInUser(authSuccess)
```

---

## 🔐 Authentification — Résumé des IDs Google

| Élément | Client ID | Rôle |
|---------|-----------|------|
| Flutter Web (`index.html` meta) | `qgeac...` (Web) | Initialise Google Sign-In JS |
| Flutter Android (`clientId`) | `th1oi...` (Android) | Authentification native Android |
| Flutter Android (`serverClientId`) | `qgeac...` (Web) | Audience attendue pour idToken |
| Serverpod (`googleClientSecret`) | `qgeac...` (Web) | Valide l'idToken reçu de Flutter |

---

## 🗃️ Base de données

### Gestion des migrations
Serverpod gère les migrations via le dossier `migrations/`.
- Chaque modification de modèle `.yaml` → `serverpod generate` → `--apply-migrations`

### Tables métier (schéma SQL)
Le schéma custom (`schema/cine_pass_schema.sql`) contient les tables métier :
- `films`, `seances`, `cinemas`, `salles`
- `evenements`, `reservations`, `billets`
- `phone_auth_codes` (OTP SMS)

---

## 🔄 Flux de développement

```
1. Modifier un modèle dans cine_pass_server/lib/src/models/*.yaml
           ↓
2. cd cine_pass_server && serverpod generate
           ↓
3. cine_pass_client/ est mis à jour automatiquement
           ↓
4. Flutter utilise les nouvelles classes via le client
```

---

## 🏗️ Décisions techniques importantes

| Décision | Raison |
|----------|--------|
| Pas d'auth email/password | Remplacé par Google + SMS pour simplifier la gestion des comptes |
| Client Web comme `serverClientId` | Le backend ne peut valider que les idTokens dont l'audience correspond au client Web |
| `!kIsWeb` pour `initializeGoogleSignIn` | Évite la double initialisation GSI sur Flutter Web |
| `serverpod_auth_idp_server` | Package officiel Serverpod, gère `AuthUser`, `UserProfile`, JWT |
| `passwords.yaml` non versionné | Sécurité : contient secrets Google, JWT pepper, mot de passe DB |

