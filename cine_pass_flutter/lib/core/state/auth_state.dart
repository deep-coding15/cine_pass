import 'dart:async';

import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/foundation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../main.dart';

/// Etat d'authentification synchronise avec Serverpod `client.auth`.
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
      final provisionalName = _displayNameForStrategy(strategy);
      final changed = _isLoggedIn != true ||
          (_userName.trim().isEmpty && provisionalName.isNotEmpty);

      _isLoggedIn = true;
      // Show a temporary label until backend profile is loaded.
      if (_userName.trim().isEmpty && provisionalName.isNotEmpty) {
        _userName = provisionalName;
      }
      if (_isGenericEmailLabel(_userEmail)) {
        _userEmail = '';
      }

      if (notify && changed) {
        notifyListeners();
      }

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

  /// Charge les infos reelles depuis l'API (profil + roles backend).
  Future<void> refreshProfileFromServer({bool notify = true}) async {
    if (!client.auth.isAuthenticated) return;
    if (_isRefreshingProfile) return;
    _isRefreshingProfile = true;
    try {
      final ProfileResponse? profile = await client.cinePass.getProfile();
      final bool isAdmin = await client.cinePass.isCurrentUserAdmin();
      final bool isResponsable =
          await client.cinePass.isCurrentUserResponsable();

      final nextEmail = (profile?.email ?? '').trim();
      final backendName = (profile?.displayName ?? '').trim();
      final fallbackNameFromEmail = _nameFromEmail(nextEmail);
      final nextName = backendName.isNotEmpty
          ? backendName
          : (fallbackNameFromEmail.isNotEmpty
              ? fallbackNameFromEmail
              : (_userName.trim().isNotEmpty ? _userName.trim() : 'Utilisateur'));

      var changed = false;
      if (nextName != _userName) {
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

  bool _isGenericEmailLabel(String emailLabel) {
    final value = emailLabel.trim().toLowerCase();
    return value.isEmpty ||
        value == 'compte google connecte' ||
        value == 'connexion par sms';
  }

  String _nameFromEmail(String email) {
    final value = email.trim();
    if (value.isEmpty || !value.contains('@')) return '';
    final localPart = value.split('@').first.trim();
    if (localPart.isEmpty) return '';
    return _capitalizeWords(localPart.replaceAll(RegExp(r'[._-]+'), ' '));
  }

  String _displayNameForStrategy(String strategy) {
    // Legacy helper kept for compatibility; real name comes from backend profile.
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

  /// Deconnexion reelle (backend/session) + reset state local.
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
