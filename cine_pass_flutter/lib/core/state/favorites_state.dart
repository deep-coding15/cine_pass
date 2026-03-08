import 'package:flutter/foundation.dart';

/// État des favoris (films et événements) — cœur cliquable.
class FavoritesState extends ChangeNotifier {
  static FavoritesState? _instance;
  static FavoritesState get instance => _instance ??= FavoritesState._();

  FavoritesState._();

  final Set<String> _filmIds = {};
  final Set<String> _eventIds = {};

  Set<String> get filmIds => Set.from(_filmIds);
  Set<String> get eventIds => Set.from(_eventIds);

  bool isFilmFavorite(String id) => _filmIds.contains(id);
  bool isEventFavorite(String id) => _eventIds.contains(id);

  void toggleFilm(String id) {
    if (_filmIds.contains(id)) {
      _filmIds.remove(id);
    } else {
      _filmIds.add(id);
    }
    notifyListeners();
  }

  void toggleEvent(String id) {
    if (_eventIds.contains(id)) {
      _eventIds.remove(id);
    } else {
      _eventIds.add(id);
    }
    notifyListeners();
  }
}
