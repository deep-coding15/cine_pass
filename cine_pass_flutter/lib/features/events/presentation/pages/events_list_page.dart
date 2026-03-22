import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../../../films/presentation/widgets/film_card.dart';
import '../widgets/event_card.dart';
import '../widgets/event_type_badge.dart';

/// Page unifiée : films + événements avec filtres qui s’adaptent au type choisi.
/// - Menu « Type » = catégories API + Film (pas de doublon dans la liste).
/// - Type "Film" → catalogue films + événements ciné (genre, ville, dates).
/// - Autre type → filtre par libellé catégorie ou badge type + ville + filtre dynamique.
/// - Type "Tous" → genre film, ville, dates.
class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  final _searchController = TextEditingController();

  String _selectedType = 'Tous';
  String _selectedCity = 'Toutes';
  String _selectedGenre = 'Tous';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String _selectedDynamicFilterKey = '';
  String _selectedDynamicFilterLabel = '';
  String _selectedDynamicFilterValue = 'Tous';
  List<String> _dynamicFilterValues = ['Tous'];

  List<FilmResponse> _films = [];
  List<EventResponse> _events = [];
  List<String> _cities = ['Toutes'];
  List<String> _genres = ['Tous'];
  /// Résultat brut de [getGenres] (recalcul des options avec films + événements ciné).
  List<String> _genrePoolFromApi = const [];

  /// Genres du formulaire création (même liste que l’espace responsable) — évite liste vide sans BDD.
  static const List<String> _fallbackFilmGenres = [
    'Action',
    'Comédie',
    'Drame',
    'Thriller',
    'Animation',
    'Documentaire',
    'Science-fiction',
    'Romance',
    'Horreur',
    'Aventure',
  ];

  /// Valeurs fixes alignées sur les libellés affichés (badge type), sans doublon catégorie/API.
  static const List<String> _typeFilterChoices = [
    'Tous',
    'Film',
    'Festival',
    'Stand-up',
    'Concert',
    'Théâtre',
    'Autre',
  ];

  List<String> _typeOptions = List<String>.from(_typeFilterChoices);

  List<FilmResponse> _filteredFilms = [];
  List<EventResponse> _filteredEvents = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        client.cinePass.getFilms(),
        client.cinePass.getEvents(),
        client.cinePass.getCities(),
        client.cinePass.getGenres(),
        client.cinePass.getEventCategories(),
      ]);
      if (!mounted) return;
      final films = results[0] as List<FilmResponse>;
      final events = results[1] as List<EventResponse>;
      final cities = results[2] as List<String>;
      final genres = results[3] as List<String>;
      final categories = results[4] as List<String>;

      // Éviter les doublons (ex. API renvoie aussi « Film ») → crash DropdownButton.
      final typeOpts = <String>[];
      final seen = <String>{};
      for (final t in [
        'Tous',
        'Film',
        ...categories.where((c) => c != 'Toutes'),
      ]) {
        if (seen.add(t)) typeOpts.add(t);
      }

      setState(() {
        _films = films;
        _events = events;
        _cities = cities;
        _genrePoolFromApi = genres;
        _genres = _mergedGenreDropdown();
        _typeOptions = typeOpts;
        if (!typeOpts.contains(_selectedType)) {
          _selectedType = 'Tous';
        }
        if (!_genres.contains(_selectedGenre)) {
          _selectedGenre = 'Tous';
        }
        if (!_cities.contains(_selectedCity)) {
          _selectedCity = 'Toutes';
        }
        _loading = false;
        _applyFilters();
      });
      await _refreshDynamicFilterOptions();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
        _filteredFilms = [];
        _filteredEvents = [];
      });
    }
  }

  bool _eventMatchesCity(EventResponse e) {
    if (_selectedCity == 'Toutes') return true;
    return e.city.trim().toLowerCase() ==
        _selectedCity.trim().toLowerCase();
  }

  /// Même logique que le serveur (`_extractPrefixedValue` / lignes « Genre: … »).
  String? _genreLineFromDescription(String? description) {
    if (description == null || description.trim().isEmpty) return null;
    const needle = 'genre:';
    for (final line in description.split('\n')) {
      final t = line.trim();
      if (t.toLowerCase().startsWith(needle)) {
        final value = t.substring(needle.length).trim();
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }

  /// Genre film affiché / filtré : API (`filmGenre`) ou repli sur la description.
  String _resolvedFilmGenre(EventResponse e) {
    final fromApi = (e.filmGenre ?? '').trim();
    if (fromApi.isNotEmpty) return fromApi;
    return (_genreLineFromDescription(e.description) ?? '').trim();
  }

  /// Genres pour le menu « Genre film » : API + catalogue + événements ciné + liste par défaut.
  List<String> _mergedGenreDropdown() {
    final set = <String>{};
    for (final g in _fallbackFilmGenres) {
      set.add(g);
    }
    for (final g in _genrePoolFromApi) {
      if (g != 'Tous' && g.trim().isNotEmpty) {
        set.add(g.trim());
      }
    }
    for (final f in _films) {
      if (f.genre.trim().isNotEmpty) {
        set.add(f.genre.trim());
      }
    }
    for (final e in _events) {
      if (!_eventMatchesDisplayType(e, 'Film')) continue;
      final fg = _resolvedFilmGenre(e);
      if (fg.isNotEmpty) {
        set.add(fg);
      }
    }
    final list = set.toList()
      ..sort(
        (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
      );
    return ['Tous', ...list];
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    List<FilmResponse> films = _films;
    List<EventResponse> events = _events;

    if (_selectedType == 'Film') {
      events = events.where((e) => _eventMatchesDisplayType(e, 'Film')).toList();
      if (_selectedCity != 'Toutes') {
        events = events.where(_eventMatchesCity).toList();
      }
      events = _filterEventsByDate(events);
      if (_selectedGenre != 'Tous') {
        final gSel = _selectedGenre.toLowerCase();
        films = films
            .where((f) => f.genre.toLowerCase() == gSel)
            .toList();
        events = events
            .where(
              (e) => _resolvedFilmGenre(e).toLowerCase() == gSel,
            )
            .toList();
      }
      if (query.isNotEmpty) {
        final q = query;
        films = films
            .where(
              (f) =>
                  f.title.toLowerCase().contains(q) ||
                  (f.genre.toLowerCase().contains(q)),
            )
            .toList();
        events = events
            .where(
              (e) =>
                  e.title.toLowerCase().contains(q) ||
                  e.category.toLowerCase().contains(q) ||
                  (e.description?.toLowerCase().contains(q) ?? false) ||
                  e.location.toLowerCase().contains(q) ||
                  e.city.toLowerCase().contains(q) ||
                  (e.filmDirector?.toLowerCase().contains(q) ?? false) ||
                  _resolvedFilmGenre(e).toLowerCase().contains(q),
            )
            .toList();
      }
      if (_selectedDynamicFilterKey.isNotEmpty &&
          _selectedDynamicFilterValue != 'Tous') {
        events = events.where((e) {
          final v = _eventDynamicValue(e, _selectedDynamicFilterKey);
          return v.toLowerCase() == _selectedDynamicFilterValue.toLowerCase();
        }).toList();
      }
    } else if (_selectedType == 'Tous') {
      if (_selectedGenre != 'Tous') {
        final gSel = _selectedGenre.toLowerCase();
        films = films
            .where((f) => f.genre.toLowerCase() == gSel)
            .toList();
        events = events.where((e) {
          if (!_eventMatchesDisplayType(e, 'Film')) return true;
          return _resolvedFilmGenre(e).toLowerCase() == gSel;
        }).toList();
      }
      if (_selectedCity != 'Toutes') {
        events = events.where(_eventMatchesCity).toList();
      }
      // Filtre par date (événements)
      events = _filterEventsByDate(events);
      if (query.isNotEmpty) {
        films = films
            .where(
              (f) =>
                  f.title.toLowerCase().contains(query) ||
                  f.genre.toLowerCase().contains(query),
            )
            .toList();
        events = events
            .where(
              (e) =>
                  e.title.toLowerCase().contains(query) ||
                  e.category.toLowerCase().contains(query) ||
                  (e.description?.toLowerCase().contains(query) ?? false) ||
                  e.location.toLowerCase().contains(query) ||
                  e.city.toLowerCase().contains(query),
            )
            .toList();
      }
    } else {
      films = [];
      events = events.where(_eventMatchesSelectedType).toList();
      if (_selectedCity != 'Toutes') {
        events = events.where(_eventMatchesCity).toList();
      }
      events = _filterEventsByDate(events);
      if (query.isNotEmpty) {
        events = events
            .where(
              (e) =>
                  e.title.toLowerCase().contains(query) ||
                  (e.description?.toLowerCase().contains(query) ?? false) ||
                  e.location.toLowerCase().contains(query) ||
                  e.city.toLowerCase().contains(query),
            )
            .toList();
      }
      if (_selectedDynamicFilterKey.isNotEmpty &&
          _selectedDynamicFilterValue != 'Tous') {
        events = events.where((e) {
          final v = _eventDynamicValue(e, _selectedDynamicFilterKey);
          return v.toLowerCase() == _selectedDynamicFilterValue.toLowerCase();
        }).toList();
      }
    }

    setState(() {
      _filteredFilms = films;
      _filteredEvents = events;
    });
  }

  /// Filtre type : priorité à `eventType` en base, puis catégorie / détails / libellé affiché.
  bool _eventMatchesSelectedType(EventResponse e) =>
      _eventMatchesDisplayType(e, _selectedType);

  bool _eventMatchesDisplayType(EventResponse e, String displayType) {
    if (displayType == 'Autre') {
      final t = (e.eventType ?? '').trim().toUpperCase();
      if (t == 'AUTRE') return true;
      if (t.isNotEmpty &&
          !const {
            'FILM',
            'FESTIVAL',
            'STANDUP',
            'CONCERT',
            'THEATRE',
          }.contains(t)) {
        return true;
      }
      final cat = e.category.trim().toLowerCase();
      const known = {
        'film',
        'festival',
        'stand-up',
        'standup',
        'concert',
        'théâtre',
        'theatre',
        'autre',
      };
      return cat.isNotEmpty && !known.contains(cat);
    }
    final sel = displayType.trim();
    final code = _eventTypeCodeFromLabel(sel);
    final typeUpper = (e.eventType ?? '').trim().toUpperCase();
    if (code == 'FILM') {
      if (typeUpper == 'FILM') return true;
      final cat = e.category.trim().toLowerCase();
      if (cat.contains('film') ||
          cat.contains('cinéma') ||
          cat.contains('cinema')) {
        return true;
      }
      if (_resolvedFilmGenre(e).isNotEmpty ||
          (e.filmDirector ?? '').trim().isNotEmpty) {
        return true;
      }
    }
    if (code.isNotEmpty && typeUpper == code) return true;
    if (e.category.trim().toLowerCase() == sel.toLowerCase()) return true;
    return eventTypeDisplayLabel(e) == sel;
  }

  String _eventTypeCodeFromLabel(String type) {
    switch (type.toLowerCase()) {
      case 'film':
        return 'FILM';
      case 'festival':
        return 'FESTIVAL';
      case 'stand-up':
      case 'standup':
        return 'STANDUP';
      case 'concert':
        return 'CONCERT';
      case 'théâtre':
      case 'theatre':
        return 'THEATRE';
      default:
        return '';
    }
  }

  String _eventDynamicValue(EventResponse e, String key) {
    switch (key) {
      case 'director':
        return e.filmDirector ?? '';
      case 'genre':
        return _resolvedFilmGenre(e);
      case 'language':
        return e.eventLanguage ?? '';
      case 'artist':
        return e.concertArtist ?? '';
      case 'music_genre':
        return e.concertMusicGenre ?? '';
      case 'theme':
        return e.festivalTheme ?? '';
      case 'main_artist':
        return e.standupMainArtist ?? '';
      case 'author':
        return e.theatreAuthor ?? '';
      default:
        return '';
    }
  }

  Future<void> _refreshDynamicFilterOptions() async {
    final typeCode = _eventTypeCodeFromLabel(_selectedType);
    if (typeCode.isEmpty || _selectedType == 'Tous') {
      if (!mounted) return;
      setState(() {
        _selectedDynamicFilterKey = '';
        _selectedDynamicFilterLabel = '';
        _selectedDynamicFilterValue = 'Tous';
        _dynamicFilterValues = ['Tous'];
      });
      return;
    }
    final defs = <(String, String)>[];
    if (typeCode == 'FILM') {
      // « Genre film » est le menu dédié ; ici : réalisateur + langue (données détail).
      defs.add(('director', 'Réalisateur'));
      defs.add(('language', 'Langue'));
    } else if (typeCode == 'CONCERT') {
      defs.add(('artist', 'Artiste'));
      defs.add(('music_genre', 'Genre musical'));
    } else if (typeCode == 'FESTIVAL') {
      defs.add(('theme', 'Thématique'));
    } else if (typeCode == 'STANDUP') {
      defs.add(('main_artist', 'Humoriste'));
    } else if (typeCode == 'THEATRE') {
      defs.add(('author', 'Auteur'));
    }
    if (defs.isEmpty) return;
    try {
      /// Un seul filtre dynamique (le plus important) pour garder l’UI lisible.
      final def = defs.first;
      final values = await client.cinePass.getEventDynamicFilterValues(
        eventType: typeCode,
        filterKey: def.$1,
      );
      if (!mounted) return;
      setState(() {
        _selectedDynamicFilterKey = def.$1;
        _selectedDynamicFilterLabel = def.$2;
        _dynamicFilterValues = values.isEmpty ? ['Tous'] : values;
        _selectedDynamicFilterValue = 'Tous';
      });
      _applyFilters();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedDynamicFilterKey = '';
        _selectedDynamicFilterLabel = '';
        _selectedDynamicFilterValue = 'Tous';
        _dynamicFilterValues = ['Tous'];
      });
    }
  }

  List<EventResponse> _filterEventsByDate(List<EventResponse> list) {
    if (_dateFrom == null && _dateTo == null) return list;
    return list.where((e) {
      final d = DateTime.tryParse(e.date);
      if (d == null) return true;
      final day = DateTime(d.year, d.month, d.day);
      if (_dateFrom != null &&
          day.isBefore(
            DateTime(_dateFrom!.year, _dateFrom!.month, _dateFrom!.day),
          )) {
        return false;
      }
      if (_dateTo != null &&
          day.isAfter(DateTime(_dateTo!.year, _dateTo!.month, _dateTo!.day))) {
        return false;
      }
      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedType = 'Tous';
      _selectedCity = 'Toutes';
      _selectedGenre = 'Tous';
      _dateFrom = null;
      _dateTo = null;
      _selectedDynamicFilterKey = '';
      _selectedDynamicFilterLabel = '';
      _selectedDynamicFilterValue = 'Tous';
      _dynamicFilterValues = ['Tous'];
      _searchController.clear();
    });
    _applyFilters();
  }

  Future<void> _pickDateFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) {
      setState(() {
        _dateFrom = picked;
        if (_dateTo != null && picked.isAfter(_dateTo!)) _dateTo = null;
        _applyFilters();
      });
    }
  }

  Future<void> _pickDateTo() async {
    final initial = _dateTo ?? _dateFrom ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _dateFrom ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) {
      setState(() {
        _dateTo = picked;
        _applyFilters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryRed),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Erreur: $_error',
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    final showGenre = _selectedType == 'Tous' || _selectedType == 'Film';
    // « Film » inclut aussi les événements ciné : ville + dates utiles.
    final showCity = true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'À l\'affiche',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Films et événements publiés sur la plateforme',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rechercher avec filtres',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilters(),
                    decoration: InputDecoration(
                      hintText: 'Titre, lieu, ville…',
                      hintStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        child: _DropdownFilter<String>(
                          value: _selectedType,
                          items: _typeOptions,
                          label: 'Type',
                          onChanged: (v) {
                            setState(() {
                              _selectedType = v ?? 'Tous';
                              if (_selectedType == 'Tous' ||
                                  _selectedType == 'Film') {
                                _genres = _mergedGenreDropdown();
                                if (!_genres.contains(_selectedGenre)) {
                                  _selectedGenre = 'Tous';
                                }
                              }
                              _applyFilters();
                            });
                            _refreshDynamicFilterOptions();
                          },
                        ),
                      ),
                      if (showGenre)
                        SizedBox(
                          width: 150,
                          child: _DropdownFilter<String>(
                            value: _selectedGenre,
                            items: _genres,
                            label: 'Genre film',
                            onChanged: (v) {
                              setState(() {
                                _selectedGenre = v ?? 'Tous';
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                      if (showCity)
                        SizedBox(
                          width: 150,
                          child: _DropdownFilter<String>(
                            value: _selectedCity,
                            items: _cities,
                            label: 'Ville',
                            onChanged: (v) {
                              setState(() {
                                _selectedCity = v ?? 'Toutes';
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                      _DateFilterChip(
                        label: 'Du',
                        date: _dateFrom,
                        onTap: _pickDateFrom,
                        onClear: () {
                          setState(() {
                            _dateFrom = null;
                            _applyFilters();
                          });
                        },
                      ),
                      _DateFilterChip(
                        label: 'Au',
                        date: _dateTo,
                        onTap: _pickDateTo,
                        onClear: () {
                          setState(() {
                            _dateTo = null;
                            _applyFilters();
                          });
                        },
                      ),
                      // N’affiche le menu que s’il existe au moins une valeur autre que « Tous ».
                      if (_selectedDynamicFilterKey.isNotEmpty &&
                          _dynamicFilterValues.any((v) => v != 'Tous'))
                        SizedBox(
                          width: 180,
                          child: _DropdownFilter<String>(
                            value: _selectedDynamicFilterValue,
                            items: _dynamicFilterValues,
                            label: _selectedDynamicFilterLabel,
                            onChanged: (v) {
                              setState(() {
                                _selectedDynamicFilterValue = v ?? 'Tous';
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                      TextButton.icon(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Réinitialiser'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_filteredFilms.isEmpty && _filteredEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  'Aucun résultat pour ces filtres.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final crossCount = w > 1200
                    ? 6
                    : (w > 900 ? 5 : (w > 600 ? 4 : (w > 400 ? 3 : 2)));
                final list = <Widget>[
                  ..._filteredFilms.map(
                    (film) => ClipRect(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Chip(
                            label: const Text('Film'),
                            backgroundColor: AppTheme.primaryRed.withValues(
                              alpha: 0.3,
                            ),
                            labelStyle: const TextStyle(
                              color: AppTheme.primaryRed,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(height: 4),
                          FilmCard(film: film),
                        ],
                      ),
                    ),
                  ),
                  ..._filteredEvents.map(
                    (event) => ClipRect(child: EventCard(event: event)),
                  ),
                ];
                // Cartes compactes : ratio pour éviter overflow
                // Plus haut : évite le débordement des cartes événement (prix + bouton).
                // Cartes avec affiche plus haute (2/3) : cellule un peu plus haute.
                final childAspectRatio = w > 900 ? 0.48 : 0.44;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossCount,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 14,
                  childAspectRatio: childAspectRatio,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: list,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DropdownFilter<T extends String> extends StatelessWidget {
  const _DropdownFilter({
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
  });

  final T value;
  final List<T> items;
  final void Function(T?) onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    // Toujours au moins une entrée + mêmes valeurs que le bouton (évite liste vide).
    final safeItems = items.isEmpty ? <T>[value] : items;
    final effective = safeItems.contains(value) ? value : safeItems.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: effective,
              isExpanded: true,
              dropdownColor: AppTheme.cardDark,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              items: safeItems
                  .map(
                    (e) => DropdownMenuItem<T>(value: e, child: Text(e)),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final text = date == null
        ? label
        : '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}';
    return Material(
      color: AppTheme.surfaceDark,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                ),
              ),
              if (date != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onClear,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
