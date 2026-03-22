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
Future<String> getServerUrl() async {
  final config = await loadAppConfig();
  return config.apiUrl;
}
