import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../main.dart';

/// État d'authentification synchronisé avec Serverpod `client.auth`.
class AuthState extends ChangeNotifier {
  static AuthState? _instance;
  static AuthState get instance => _instance ??= AuthState._();

  AuthState._();

  bool _isBoundToClientAuth = false;
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  String _userName = '';
  String _userEmail = '';

  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  String get userName => _userName;
  String get userEmail => _userEmail;

  /// Connecte cet état au gestionnaire d'auth Serverpod.
  void bindToClientAuth() {
    if (_isBoundToClientAuth) {
      _syncFromClientAuth();
      return;
    }

    client.auth.authInfoListenable.addListener(_onAuthChanged);
    _isBoundToClientAuth = true;
    _syncFromClientAuth();
  }

  void _onAuthChanged() {
    _syncFromClientAuth();
  }

  void _syncFromClientAuth() {
    final previousLoggedIn = _isLoggedIn;
    final previousAdmin = _isAdmin;
    final previousName = _userName;
    final previousEmail = _userEmail;

    _isLoggedIn = client.auth.isAuthenticated;
    _isAdmin = false;

    if (!_isLoggedIn) {
      _userName = '';
      _userEmail = '';
    } else {
      final authInfo = client.auth.authInfo;
      final json = _toJsonMap(authInfo);

      _userName = _readString(json, ['fullName', 'userName', 'name']);
      _userEmail = _readString(json, ['email']);

      if (_userName.isEmpty && _userEmail.isNotEmpty) {
        _userName = _userEmail;
      }
      if (_userName.isEmpty) {
        _userName = 'Utilisateur';
      }
    }

    final hasChanged = previousLoggedIn != _isLoggedIn ||
        previousAdmin != _isAdmin ||
        previousName != _userName ||
        previousEmail != _userEmail;

    if (hasChanged) {
      notifyListeners();
    }
  }

  Map<String, dynamic> _toJsonMap(dynamic authInfo) {
    try {
      final value = (authInfo as dynamic).toJson();
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map(
          (key, val) => MapEntry(key.toString(), val),
        );
      }
    } catch (_) {
      // Intentionally ignored; fall back to empty map.
    }
    return const <String, dynamic>{};
  }

  String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  @Deprecated('Use Google / SMS endpoints and client.auth session updates.')
  void loginAsUser({String? email, String? name}) {
    debugPrint('loginAsUser is deprecated. Use provider-based authentication.');
  }

  @Deprecated('Use Google / SMS endpoints and client.auth session updates.')
  void loginAsAdmin() {
    debugPrint('loginAsAdmin is deprecated. Use provider-based authentication.');
  }

  void logout() {
    unawaited(_logoutInternal());
  }

  Future<void> _logoutInternal() async {
    await client.auth.signOutDevice();
    _syncFromClientAuth();
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
    if (_isBoundToClientAuth) {
      client.auth.authInfoListenable.removeListener(_onAuthChanged);
      _isBoundToClientAuth = false;
    }
    super.dispose();
  }
}
