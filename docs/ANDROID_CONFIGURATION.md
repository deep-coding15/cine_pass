# Configuration Android - CinePass

## 📱 Configuration pour l'émulateur

### Issue: Connection refused sur localhost:36214

**Cause:** L'émulateur Android ne peut pas accéder à `localhost:9080` directement.

**Solution:**

1. **Modifier `assets/config.json` pour l'émulateur:**
```json
{
    "apiUrl": "http://10.0.2.2:9080"
}
```

2. **Pour un device physique sur le même réseau:**
```json
{
    "apiUrl": "http://192.168.1.XX:9080"
```
(Remplacer `192.168.1.XX` par votre IP locale)

3. **Vérifier votre IP locale:**
```bash
# Windows
ipconfig

# macOS/Linux
ifconfig
```

### Configuration Google Sign-In pour Android

#### Étape 1: Obtenir le SHA-1 de votre app

```bash
cd cine_pass_flutter/android
./gradlew signingReport
```

Cherchez dans le résultat:
```
Variant: debug
Config: debug
Store: ...
Alias: androiddebugkey
MD5: ...
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

#### Étape 2: Ajouter le SHA-1 dans Google Cloud Console

1. Aller à [Google Cloud Console](https://console.cloud.google.com/)
2. Sélectionner votre projet (ex: "cine-pass-gi2-ensa-tetouan")
3. Aller à **Identifiants** → **Identifiants OAuth 2.0**
4. Créer une nouvelle identité de type **Application Android**
   - Package name: `com.example.cine_pass_flutter`
   - SHA-1: (Coller le SHA-1 obtenu à l'étape 1)
5. Cliquer sur **Créer**

#### Étape 3: Vérifier la configuration dans main.dart

Le client ID Android est déjà configuré dans `lib/main.dart`:
```dart
const _defaultGoogleAndroidClientId = '780713404787-th1oi0uk8pvtuofjmap99bc1o7num427.apps.googleusercontent.com';
```

### AndroidManifest.xml

Vérifier que les permissions necessaires sont présentes dans `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

(Cela devrait être géré automatiquement par les plugins)

### Gradle Configuration

Le fichier `android/app/build.gradle.kts` doit avoir:
```kotlin
android {
    namespace = "com.example.cine_pass_flutter"
    compileSdk = flutter.compileSdkVersion
    
    defaultConfig {
        applicationId = "com.example.cine_pass_flutter"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
    }
}
```

## 🧪 Tester sur Android

### Émulateur

```bash
# Lancer l'émulateur
emulator -avd <nom_device>

# Ou depuis Android Studio
# Device Manager → Play button

# Lancer l'app
cd cine_pass_flutter
flutter run
```

**Important:** 
- Utiliser `http://10.0.2.2:9080` dans `config.json`
- Démarrer le serveur Serverpod avant de lancer l'app
- L'émulateur doit avoir une connexion internet (pour Google)

### Device physique

```bash
# Activer le USB Debugging sur le device
# Connecter le device en USB

# Vérifier que le device est reconnu
flutter devices

# Lancer l'app
flutter run -d <device-id>
```

**Important:**
- Utiliser l'IP locale du serveur: `http://192.168.X.X:9080`
- S'assurer que le device et le PC sont sur le même réseau WiFi
- Désactiver le firewall si nécessaire

## 🔧 Troubleshooting

### ❌ "Could not find an Android device"

```bash
# Vérifier les devices connectés
flutter devices

# Si vide, vérifier:
# 1. L'émulateur est lancé
# 2. Le USB Debugging est activé
# 3. Les drivers USB sont installés
```

### ❌ "GoogleSignIn initialization failed"

- Vérifier que le SHA-1 est correct dans Google Cloud Console
- Vérifier que le client ID dans `main.dart` est correct
- Redémarrer l'app

### ❌ "Connection refused" ou "Network error"

- Vérifier que le serveur tourne: `dart run bin/main.dart`
- Vérifier l'URL dans `assets/config.json`
- Pour émulateur: utiliser `10.0.2.2` au lieu de `localhost`
- Pour device physique: vérifier l'IP locale

### ❌ "BUILD FAILED" (Gradle error)

```bash
# Nettoyer les builds
./gradlew clean
cd ../..
flutter clean

# Relancer
flutter pub get
flutter run
```

## 📦 Dépendances Android

Les dépendances suivantes sont gérées automatiquement par les plugins Flutter:

- `google_sign_in_android` - Google Sign-In
- `flutter_web_auth_2` - Authentification web
- `connectivity_plus` - Détection de connexion
- `flutter_secure_storage` - Stockage sécurisé des tokens

Vérifier dans `android/app/build.gradle.kts` que les plugins Flutter sont appliqués:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
```

## 🔐 Sécurité

- **Ne jamais** commiter le SHA-1 en dur
- **Ne jamais** commiter la clé privée de signature
- Les tokens JWT sont stockés localement par `FlutterAuthSessionManager`
- Les tokens sont supprimés lors du logout

## 📚 Ressources

- [Documentation Google Sign-In pour Flutter](https://pub.dev/packages/google_sign_in)
- [Documentation Android Studio](https://developer.android.com/studio)
- [Documentation Flutter](https://flutter.dev/)

