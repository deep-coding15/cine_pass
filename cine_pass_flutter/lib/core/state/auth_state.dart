import 'dart:async';

import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/foundation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../main.dart';

class _CinePassRoleEndpoint extends EndpointRef {
  _CinePassRoleEndpoint(super.caller);

  @override
  String get name => 'cinePass';

  Future<bool> isCurrentUserAdmin() {
    return caller.callServerEndpoint<bool>(
      name,
      'isCurrentUserAdmin',
      {},
    );
  }

  Future<bool> isCurrentUserResponsable() {
    return caller.callServerEndpoint<bool>(
      name,
      'isCurrentUserResponsable',
      {},
    );
  }
}

/// État d'authentification synchronisé avec Serverpod `client.auth`.
class AuthState extends ChangeNotifier {
  static AuthState? _instance;
  static AuthState get instance => _instance ??= AuthState._();

  AuthState._();

  bool _isBoundToClientAuth = false;
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  bool _isResponsable = false;
  String _userName = '';
  String _userEmail = '';
  bool _isRefreshingProfile = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  bool get isResponsable => _isResponsable;
  String get userName => _userName;
  String get userEmail => _userEmail;

  void bindToClientAuth() {
    if (_isBoundToClientAuth) {
      _syncFromClientAuth(notify: false);
      return;
    }

    client.auth.authInfoListenable.addListener(_onAuthChanged);
    _isBoundToClientAuth = true;
    _syncFromClientAuth(notify: false);
  }

  void _onAuthChanged() {
    _syncFromClientAuth();
  }

  void unbindFromClientAuth() {
    if (_isBoundToClientAuth) {
      client.auth.authInfoListenable.removeListener(_onAuthChanged);
      _isBoundToClientAuth = false;
    }
  }

  void _syncFromClientAuth({bool notify = true}) {
    final authInfo = client.auth.authInfo;

    if (client.auth.isAuthenticated && authInfo is AuthSuccess) {
      final strategy = authInfo.authStrategy.toLowerCase();
      // Roles are refreshed from backend profile access checks.
      final nextUserName = _displayNameForStrategy(strategy);
      final nextUserEmail = _emailLabelForStrategy(strategy);

      final changed =
          _isLoggedIn != true ||
          _userName != nextUserName ||
          _userEmail != nextUserEmail;

      _isLoggedIn = true;
      _userName = nextUserName;
      _userEmail = nextUserEmail;

      if (notify && changed) {
        notifyListeners();
      }

      // After we know we're authenticated, pull real user data and role flags.
      unawaited(refreshProfileFromServer(notify: true));
      return;
    }

    final changed =
        _isLoggedIn ||
        _isAdmin ||
        _isResponsable ||
        _userName.isNotEmpty ||
        _userEmail.isNotEmpty;

    _isLoggedIn = false;
    _isAdmin = false;
    _isResponsable = false;
    _userName = '';
    _userEmail = '';

    if (notify && changed) {
      notifyListeners();
    }
  }

  /// Charge les infos "réelles" depuis l'API (profil + rôles).
  Future<void> refreshProfileFromServer({bool notify = true}) async {
    if (!client.auth.isAuthenticated) return;
    if (_isRefreshingProfile) return;
    _isRefreshingProfile = true;
    try {
      final roleEndpoint = _CinePassRoleEndpoint(client);
      final ProfileResponse? profile = await client.cinePass.getProfile();
      final bool isAdmin = await roleEndpoint.isCurrentUserAdmin();
      final bool isResponsable = await roleEndpoint.isCurrentUserResponsable();

      final nextName = (profile?.displayName ?? '').trim();
      final nextEmail = (profile?.email ?? '').trim();

      var changed = false;
      if (nextName.isNotEmpty && nextName != _userName) {
        _userName = nextName;
        changed = true;
      }
      if (nextEmail.isNotEmpty && nextEmail != _userEmail) {
        _userEmail = nextEmail;
        changed = true;
      }
      if (_isAdmin != isAdmin) {
        _isAdmin = isAdmin;
        changed = true;
      }
      if (_isResponsable != isResponsable) {
        _isResponsable = isResponsable;
        changed = true;
      }

      if (notify && changed) {
        notifyListeners();
      }
    } catch (_) {
      // Keep auth usable even if one of these endpoints fails.
    } finally {
      _isRefreshingProfile = false;
    }
  }

  String _displayNameForStrategy(String strategy) {
    if (_userName.trim().isNotEmpty) {
      return _userName.trim();
    }
    if (strategy.contains('google')) {
      return 'Utilisateur Google';
    }
    if (strategy.contains('phone') || strategy.contains('sms')) {
      return 'Utilisateur mobile';
    }
    return 'Utilisateur';
  }

  String _emailLabelForStrategy(String strategy) {
    if (_userEmail.trim().isNotEmpty) {
      return _userEmail.trim();
    }
    if (strategy.contains('google')) {
      return 'Compte Google connecté';
    }
    if (strategy.contains('phone') || strategy.contains('sms')) {
      return 'Connexion par SMS';
    }
    return '';
  }

  /// Simule une connexion en tant qu'utilisateur.
  /// Pour le frontend de test : [email] et [name] optionnels (ex. formulaire Connexion/Inscription).
  void loginAsUser({String? email, String? name}) {
    _isLoggedIn = true;
    _isAdmin = false;
    _isResponsable = false;
    _userName = name?.trim().isNotEmpty == true ? name!.trim() : 'Marie Dubois';
    _userEmail = email?.trim().isNotEmpty == true
        ? email!.trim()
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

  /// Connexion locale temporaire pour l'espace responsable.
  void loginAsResponsable({String? email, String? name}) {
    final normalizedEmail = email?.trim().toLowerCase();
    final derivedName = name?.trim();
    final fallbackName = normalizedEmail != null && normalizedEmail.isNotEmpty
        ? normalizedEmail.split('@').first.replaceAll('.', ' ')
        : 'Responsable';

    _isLoggedIn = true;
    _isAdmin = false;
    _isResponsable = true;
    _userName = derivedName != null && derivedName.isNotEmpty
        ? derivedName
        : _capitalizeWords(fallbackName);
    _userEmail = normalizedEmail?.isNotEmpty == true
        ? normalizedEmail!
        : 'responsable@cinepass.com';
    notifyListeners();
  }

  void logout() {
    if (client.auth.isAuthenticated) {
      unawaited(client.auth.signOutDevice());
    }

    _isLoggedIn = false;
    _isAdmin = false;
    _isResponsable = false;
    _userName = '';
    _userEmail = '';
    notifyListeners();
  }

  String _capitalizeWords(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              part.substring(0, 1).toUpperCase() +
              part.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  String get userInitials {
    if (_userName.isEmpty) return '?';
    final parts = _userName.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _userName.substring(0, 1).toUpperCase();
  }

  @override
  void dispose() {
    unbindFromClientAuth();
    super.dispose();
  }
}
