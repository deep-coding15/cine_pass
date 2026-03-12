import 'package:flutter/foundation.dart';

/// État d'authentification (mock pour l'instant).
/// Utiliser [loginAsUser] / [loginAsAdmin] pour simuler une connexion.
class AuthState extends ChangeNotifier {
  static AuthState? _instance;
  static AuthState get instance => _instance ??= AuthState._();

  AuthState._();

  bool _isLoggedIn = false;
  bool _isAdmin = false;
  bool _isResponsable = false;
  String _userName = '';
  String _userEmail = '';

  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  bool get isResponsable => _isResponsable;
  String get userName => _userName;
  String get userEmail => _userEmail;

  /// Simule une connexion en tant qu'utilisateur.
  void loginAsUser({String? email, String? name}) {
    _isLoggedIn = true;
    _isAdmin = false;
    _isResponsable = false;
    _userName = name?.trim().isNotEmpty == true ? name! : 'Marie Dubois';
    _userEmail = email?.trim().isNotEmpty == true
        ? email!
        : 'marie.dubois@email.com';
    notifyListeners();
  }

  /// Simule une connexion en tant qu'admin (Jean Admin).
  void loginAsAdmin() {
    _isLoggedIn = true;
    _isAdmin = true;
    _isResponsable = false;
    _userName = 'Jean Admin';
    _userEmail = 'admin@cinepass.com';
    notifyListeners();
  }

  /// Simule une connexion en tant que responsable (email pro + mot de passe).
  /// En production : connexion avec l'email professionnel validé à l'approbation.
  void loginAsResponsable({String? email, String? name}) {
    _isLoggedIn = true;
    _isAdmin = false;
    _isResponsable = true;
    _userName = name?.trim().isNotEmpty == true ? name! : 'Responsable Central';
    _userEmail = email?.trim().isNotEmpty == true
        ? email!
        : 'contact@lecentral.fr';
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _isAdmin = false;
    _isResponsable = false;
    _userName = '';
    _userEmail = '';
    notifyListeners();
  }

  String get userInitials {
    if (_userName.isEmpty) return '?';
    final parts = _userName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _userName.substring(0, 1).toUpperCase();
  }
}
