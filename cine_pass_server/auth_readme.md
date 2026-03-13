# Partie Serveur
## tokens JWT

Architecture
```scss
Utilisateur
     │
     │ login
     ▼
Identity Provider
     │
     │ génère
     ▼
JWT Access Token
Refresh Token
```
```dart
JwtConfig(
  refreshTokenHashPepper: pod.getPassword('jwtRefreshTokenHashPepper')!,
  algorithm: JwtAlgorithm.hmacSha512(
    SecretKey(pod.getPassword('jwtHmacSha512PrivateKey')!),
  )
)
```

## Identity Provider

Architecture
```scss
Register
   │
   ▼
EmailIdp
   │
   ▼
Code de vérification envoyé
   │
   ▼
Compte activé
```

Permet d'envoyer le code par email
```dart
EmailIdpConfigFromPasswords(
  sendRegistrationVerificationCode: _sendRegistrationCode,
  sendPasswordResetVerificationCode: _sendPasswordResetCode,
) 
```

# Partie Flutter

Architecture

```dart
client = Client(serverUrl)
  ..connectivityMonitor = FlutterConnectivityMonitor()
  ..authSessionManager = FlutterAuthSessionManager();
```

```scss
Client Serverpod
      │
      ▼
AuthSessionManager
```

Le FlutterAuthSessionManager :

- stocke les tokens

- recharge la session au démarrage

- gère refresh token

Chargement de la session existante: 
```dart
await client.auth.initialize();
```

Rôle:
```scss
Storage Flutter
      │
      ▼
Recherche session
      │
      ▼
Reconnexion automatique
```
L'utilisateur reste connecté.