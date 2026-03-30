import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Configuration de l'application CinePass
///
/// Cette classe gère la configuration de l'API serveur.
/// L'URL est chargée depuis le fichier assets/config.json
class AppConfig {
  final String apiUrl;

  AppConfig({required this.apiUrl});

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      apiUrl: json['apiUrl'] as String? ?? 'http://localhost:9080',
    );
  }

  @override
  String toString() => 'AppConfig(apiUrl: $apiUrl)';
}

/// Charge la configuration de l'application depuis assets/config.json
///
/// Le fichier config.json doit contenir:
/// {
///     "apiUrl": "http://YOUR_MACHINE_IP:9080"
/// }
///
/// Pour utiliser l'adresse IP réelle de votre machine:
/// 1. Trouvez votre adresse IP:
///    - Windows: ipconfig (cherchez "IPv4 Address")
///    - Linux/Mac: ifconfig ou ip addr
/// 2. Remplacez "YOUR_MACHINE_IP" dans assets/config.json
/// 3. Exemples:
///    - "http://192.168.1.100:9080"
///    - "http://10.0.0.5:9080"
Future<AppConfig> loadAppConfig() async {
  try {
    final configString = await rootBundle.loadString('assets/config.json');
    final jsonData = jsonDecode(configString) as Map<String, dynamic>;
    final config = AppConfig.fromJson(jsonData);
    debugPrint('✓ Configuration chargée: ${config.apiUrl}');
    return config;
  } catch (e) {
    debugPrint('✗ Erreur lors du chargement de config.json: $e');
    // Retourne la configuration par défaut en cas d'erreur
    return AppConfig(apiUrl: 'http://localhost:9080');
  }
}

/// Récupère l'URL du serveur API
///
/// Priorité :
/// 1. `--dart-define=API_URL=http://...` (tous les modes)
/// 2. [loadAppConfig] via `assets/config.json`
/// 3. Sur **Android** (hors web), si l’URL vise `localhost` ou `127.0.0.1`, on
///    remplace l’hôte par `10.0.2.2` pour joindre le PC depuis l’**émulateur**.
///    Sur un **téléphone physique**, mettez l’IPv4 du PC dans `config.json` ou
///    passez `API_URL` (ex. `http://192.168.x.x:9080`).
Future<String> getServerUrl() async {
  const fromDefine = String.fromEnvironment('API_URL', defaultValue: '');
  final trimmedDefine = fromDefine.trim();
  if (trimmedDefine.isNotEmpty) {
    return trimmedDefine;
  }

  final config = await loadAppConfig();
  var url = config.apiUrl;

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.host.isNotEmpty) {
      final host = uri.host.toLowerCase();
      if (host == '127.0.0.1' || host == 'localhost') {
        url = uri.replace(host: '10.0.2.2').toString();
        debugPrint('✓ Android : API remappée vers émulateur → $url');
      }
    }
  }

  return url;
}
