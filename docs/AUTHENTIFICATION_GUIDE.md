# Guide d'implémentation de l'authentification Google + SMS dans CinePass

## 📋 Vue d'ensemble

Ce guide explique comment l'authentification par Google et SMS a été implémentée dans le projet CinePass, incluant la configuration complète du serveur et du client Flutter.

## 🔍 Architecture de l'authentification

### Composants principaux

1. **Backend (Serverpod)**
   - `cine_pass_server/lib/src/auth/google_idp_endpoint.dart` - Endpoint Google OAuth
   - `cine_pass_server/lib/src/auth/phone_auth_endpoint.dart` - Endpoint SMS/Phone
   - `cine_pass_server/server.dart` - Configuration des providers d'authentification

2. **Frontend (Flutter)**
   - `lib/core/state/auth_state.dart` - Gestion d'état d'authentification
   - `lib/features/auth/presentation/pages/connexion_page.dart` - UI de connexion mixte
   - `lib/core/config/app_config.dart` - Chargement de la configuration (URL serveur)

## ⚙️ Configuration complète

### Côté serveur

#### 1. Configuration Google OAuth

**Étapes complétées:**

✅ Création d'un projet Google Cloud Console
✅ Configuration des identifiants OAuth 2.0 (Web et Android)
✅ Stockage du secret client dans `config/passwords.yaml`

**Fichier: `cine_pass_server/config/passwords.yaml`**
```yaml
development:
  googleClientSecret: '{"web":{"client_id":"...","client_secret":"...","redirect_uris":["http://localhost:9080/auth/google/callback"]}}'
```

Le format doit être strictement JSON avec les clés suivantes:
- `client_id` - ID client web de Google
- `client_secret` - Secret client web
- `redirect_uris` - Array avec l'URI de redirection (http://localhost:9080/auth/google/callback)

#### 2. Configuration Serverpod

**Fichier: `cine_pass_server/lib/server.dart`**

Les providers d'authentification sont initialisés ainsi:
```dart
pod.initializeAuthServices(
  tokenManagerBuilders: [
    JwtConfig(...) // Gestion des tokens JWT
  ],
  identityProviderBuilders: [
    GoogleIdpConfigFromPasswords(), // Google OAuth depuis passwords.yaml
  ],
);
```

### Côté client Flutter

#### 1. Configuration Google Sign-In

**Web (HTML):**
```html
<!-- web/index.html -->
<meta name="google-signin-client_id" content="780713404787-qgeac9u7gn7an6kntv5kg24ntp30u2dq.apps.googleusercontent.com">
```

**Android (main.dart):**
```dart
const _defaultGoogleAndroidClientId = '780713404787-th1oi0uk8pvtuofjmap99bc1o7num427.apps.googleusercontent.com';

// Initialization du client Google
if (!kIsWeb) {
  await client.auth.initializeGoogleSignIn(
    clientId: googleClientId,
    serverClientId: googleServerClientId,
  );
}
```

#### 2. Configuration de l'URL du serveur

**Fichier: `assets/config.json`**
```json
{
    "apiUrl": "http://localhost:9080"
}
```

**Charger la configuration (main.dart):**
```dart
import 'core/config/app_config.dart';

final serverUrl = await getServerUrl();
client = Client(serverUrl)...;
```

#### 3. Gestion d'état avec AuthState

**Fichier: `lib/core/state/auth_state.dart`**

La classe `AuthState` synchronise l'état d'authentification avec le client Serverpod:

```dart
void bindToClientAuth() {
  client.auth.authInfoListenable.addListener(_onAuthChanged);
  _syncFromClientAuth(notify: false);
}

void _syncFromClientAuth({bool notify = true}) {
  // Récupère les infos d'auth du client et met à jour l'état local
}
```

## 🔌 Flux d'authentification

### 1. Connexion Google

```
Utilisateur clique "Se connecter avec Google"
        ↓
GoogleSignInWidget déclenche l'authentification
        ↓
Serverpod valide le token Google avec Google API
        ↓
Création/récupération de l'utilisateur
        ↓
Emission d'un JWT de session
        ↓
FlutterAuthSessionManager stocke le JWT localement
        ↓
AuthState.instance notifie les listeners
        ↓
Navigation automatique vers la page suivante
```

### 2. Connexion par SMS

```
Utilisateur entre son numéro + clique "Envoyer code"
        ↓
PhoneAuthEndpoint.sendVerificationCode()
        ↓
Génération OTP 6 chiffres + stockage en base
        ↓
Utilisateur reçoit le code par SMS (TODO: intégrer Twilio/autre)
        ↓
Utilisateur entre le code + clique "Vérifier"
        ↓
PhoneAuthEndpoint.verifyCode()
        ↓
Validation du code (existence, expiration, tentatives)
        ↓
Création/récupération utilisateur
        ↓
Emission d'un JWT de session
        ↓
AuthState.instance notifie les listeners
```

## 📱 Implémentation UI

**Fichier: `lib/features/auth/presentation/pages/connexion_page.dart`**

Page combinant 3 méthodes de connexion:

1. **Google Sign-In**
   - Widget `GoogleSignInWidget` from `serverpod_auth_idp_flutter`
   - Callback `_onGoogleAuthenticated()` gère la redirection post-connexion

2. **SMS + Code**
   - TextField pour le numéro de téléphone
   - Bouton "Envoyer le code SMS"
   - TextField pour le code (conditionnel, après envoi du code)
   - Bouton "Vérifier le code"

3. **Gestion d'erreurs**
   - Messages d'erreur en temps réel
   - Affichage des états de chargement (isSendingCode, isVerifyingCode)

## 🐛 Dépannage

### Erreur: "Connexion Google échouée: Connection refused"

**Cause:** Le serveur n'est pas démarré ou l'URL est incorrecte.

**Solution:**
```bash
# Démarrer le serveur
cd cine_pass_server
dart run bin/main.dart

# Vérifier que l'URL est correcte dans assets/config.json
# Pour Android sur émulateur: "http://10.0.2.2:9080"
# Pour Android physique: "http://<votre-ip>:9080"
```

### Erreur: "Invalid client_id"

**Cause:** Le client ID Android n'est pas correct ou n'est pas lié à l'app.

**Solution:**
1. Vérifier que le package name (`com.example.cine_pass_flutter`) correspond à Google Cloud
2. Générer et ajouter le SHA-1 signing key dans Google Cloud Console
3. Redémarrer l'app

### Erreur: "Missing redirect_uris" lors du démarrage du serveur

**Cause:** Le JSON `googleClientSecret` dans `passwords.yaml` est invalide.

**Solution:**
```yaml
googleClientSecret: '{"web":{"client_id":"...","client_secret":"...","redirect_uris":["http://localhost:9080/auth/google/callback"]}}'
```

Les guillemets doivent être simples (`'`) autour du JSON, et les `redirect_uris` doivent être un array.

## 📦 Dépendances utilisées

- `serverpod_auth_idp_server` - Authentification côté serveur
- `serverpod_auth_idp_flutter` - Widgets d'authentification Flutter
- `serverpod_flutter` - Client Serverpod
- `provider` - Gestion d'état
- `go_router` - Navigation

## 🔐 Sécurité

- Les tokens JWT sont signés avec HMAC SHA-512
- Les refresh tokens sont hachés avant stockage
- Les codes SMS expirent après 5 minutes
- Limite de 5 tentatives avant expiration du code
- Les passwords.yaml ne sont jamais commitées (dans .gitignore)

## 📝 Prochaines étapes

1. **Intégration SMS réelle**
   - Remplacer le log par appel API Twilio/autre provider
   - Configurer les clés API dans passwords.yaml

2. **Amélioration UX**
   - Animation entre les étapes
   - Meilleur gestion des erreurs réseau
   - Sauvegarde du numéro pour reconnexion rapide

3. **Authentification par email**
   - Réactiver le `EmailIdpConfigFromPasswords()`
   - Ajouter des templates d'emails

4. **Tests**
   - Tests unitaires pour AuthState
   - Tests d'intégration pour les endpoints
   - Tests E2E pour les flux de connexion

