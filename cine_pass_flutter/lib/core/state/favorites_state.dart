import 'package:flutter/foundation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../../main.dart';

/// État des favoris événements — cœur cliquable.
class FavoritesState extends ChangeNotifier {
  static FavoritesState? _instance;
  static FavoritesState get instance => _instance ??= FavoritesState._();

  FavoritesState._();

  final Set<String> _eventIds = {};

  Set<String> get eventIds => Set.from(_eventIds);

  Future<void> syncFromServer() async {
    if (!client.auth.isAuthenticated) {
      clearAll();
      return;
    }

    try {
      final eventList = await client.cinePass.getMyFavoriteEventIds();
      final eventNext = eventList
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet();
      final eventsChanged = !_setEquals(_eventIds, eventNext);
      if (eventsChanged) {
        _eventIds
          ..clear()
          ..addAll(eventNext);
      }
      if (eventsChanged) {
        notifyListeners();
      }
    } catch (_) {
      // Ne casse pas l'UI si l'API des favoris échoue.
    }
  }

  // Compat legacy: la logique film est désormais désactivée.
  bool isFilmFavorite(String id) => false;
  bool isEventFavorite(String id) => _eventIds.contains(id);

  Future<void> toggleFilm(String id) async {
    // no-op (films retirés du flux API)
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
    final changed = _eventIds.isNotEmpty;
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
