import 'package:flutter/foundation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../../main.dart';

/// État des favoris (films et événements) — cœur cliquable.
class FavoritesState extends ChangeNotifier {
  static FavoritesState? _instance;
  static FavoritesState get instance => _instance ??= FavoritesState._();

  FavoritesState._();

  final Set<String> _filmIds = {};
  final Set<String> _eventIds = {};

  Set<String> get filmIds => Set.from(_filmIds);
  Set<String> get eventIds => Set.from(_eventIds);

  Future<void> syncFromServer() async {
    if (!client.auth.isAuthenticated) {
      clearAll();
      return;
    }

    try {
      final filmList = await client.cinePass.getMyFavoriteFilmIds();
      final eventList = await client.cinePass.getMyFavoriteEventIds();
      final filmNext = filmList
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet();
      final eventNext = eventList
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet();
      final filmsChanged = !_setEquals(_filmIds, filmNext);
      final eventsChanged = !_setEquals(_eventIds, eventNext);
      if (filmsChanged) {
        _filmIds
          ..clear()
          ..addAll(filmNext);
      }
      if (eventsChanged) {
        _eventIds
          ..clear()
          ..addAll(eventNext);
      }
      if (filmsChanged || eventsChanged) {
        notifyListeners();
      }
    } catch (_) {
      // Ne casse pas l'UI si l'API des favoris échoue.
    }
  }

  bool isFilmFavorite(String id) => _filmIds.contains(id);
  bool isEventFavorite(String id) => _eventIds.contains(id);

  Future<void> toggleFilm(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) return;

    final willBeFavorite = !_filmIds.contains(normalized);
    if (willBeFavorite) {
      _filmIds.add(normalized);
    } else {
      _filmIds.remove(normalized);
    }
    notifyListeners();

    if (!client.auth.isAuthenticated) return;

    try {
      final ok = await client.cinePass.setMyFilmFavorite(
        filmId: normalized,
        isFavorite: willBeFavorite,
      );
      if (!ok) {
        // rollback si le serveur refuse.
        if (willBeFavorite) {
          _filmIds.remove(normalized);
        } else {
          _filmIds.add(normalized);
        }
        notifyListeners();
      }
    } catch (_) {
      if (willBeFavorite) {
        _filmIds.remove(normalized);
      } else {
        _filmIds.add(normalized);
      }
      notifyListeners();
    }
  }

  Future<void> toggleEvent(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) return;

    final willBeFavorite = !_eventIds.contains(normalized);
    if (willBeFavorite) {
      _eventIds.add(normalized);
    } else {
      _eventIds.remove(normalized);
    }
    notifyListeners();

    if (!client.auth.isAuthenticated) return;

    try {
      final ok = await client.cinePass.setMyEventFavorite(
        eventId: normalized,
        isFavorite: willBeFavorite,
      );
      if (!ok) {
        if (willBeFavorite) {
          _eventIds.remove(normalized);
        } else {
          _eventIds.add(normalized);
        }
        notifyListeners();
      }
    } catch (_) {
      if (willBeFavorite) {
        _eventIds.remove(normalized);
      } else {
        _eventIds.add(normalized);
      }
      notifyListeners();
    }
  }

  void clearAll() {
    final changed = _filmIds.isNotEmpty || _eventIds.isNotEmpty;
    _filmIds.clear();
    _eventIds.clear();
    if (changed) {
      notifyListeners();
    }
  }

  bool _setEquals(Set<String> a, Set<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final value in a) {
      if (!b.contains(value)) return false;
    }
    return true;
  }
}
