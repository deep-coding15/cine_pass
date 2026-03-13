import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../../../films/presentation/widgets/film_card.dart';
import '../widgets/event_card.dart';

/// Page unifiée : films + événements avec filtres qui s'adaptent au type choisi.
/// - Type "Film" → filtre Genre (et Ville si disponible).
/// - Type catégorie (Concert, Théâtre...) → filtre Ville, Catégorie.
/// - Type "Tous" → tous les filtres.
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
  String _selectedCategory = 'Toutes';

  List<FilmResponse> _films = [];
  List<EventResponse> _events = [];
  List<String> _cities = ['Toutes'];
  List<String> _genres = ['Tous'];
  List<String> _categories = ['Toutes'];
  List<String> _typeOptions = ['Tous', 'Film'];

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

      final typeOpts = [
        'Tous',
        'Film',
        ...categories.where((c) => c != 'Toutes'),
      ];

      setState(() {
        _films = films;
        _events = events;
        _cities = cities;
        _genres = genres;
        _categories = categories;
        _typeOptions = typeOpts;
        _loading = false;
        _applyFilters();
      });
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

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    List<FilmResponse> films = _films;
    List<EventResponse> events = _events;

    if (_selectedType == 'Film') {
      events = [];
      if (_selectedGenre != 'Tous') {
        films = films.where((f) => f.genre == _selectedGenre).toList();
      }
      if (query.isNotEmpty) {
        films = films
            .where(
              (f) =>
                  f.title.toLowerCase().contains(query) ||
                  (f.genre.toLowerCase().contains(query)),
            )
            .toList();
      }
    } else if (_selectedType == 'Tous') {
      if (_selectedGenre != 'Tous') {
        films = films.where((f) => f.genre == _selectedGenre).toList();
      }
      if (_selectedCategory != 'Toutes') {
        events = events.where((e) => e.category == _selectedCategory).toList();
      }
      if (_selectedCity != 'Toutes') {
        events = events.where((e) => e.city == _selectedCity).toList();
      }
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
                  e.location.toLowerCase().contains(query) ||
                  e.city.toLowerCase().contains(query),
            )
            .toList();
      }
    } else {
      films = [];
      events = events.where((e) => e.category == _selectedType).toList();
      if (_selectedCity != 'Toutes') {
        events = events.where((e) => e.city == _selectedCity).toList();
      }
      if (query.isNotEmpty) {
        events = events
            .where(
              (e) =>
                  e.title.toLowerCase().contains(query) ||
                  e.location.toLowerCase().contains(query) ||
                  e.city.toLowerCase().contains(query),
            )
            .toList();
      }
    }

    setState(() {
      _filteredFilms = films;
      _filteredEvents = events;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedType = 'Tous';
      _selectedCity = 'Toutes';
      _selectedGenre = 'Tous';
      _selectedCategory = 'Toutes';
      _searchController.clear();
    });
    _applyFilters();
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
    final showCategory = _selectedType == 'Tous';
    final showCity = _selectedType == 'Tous' || _selectedType != 'Film';

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
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => _applyFilters(),
                          decoration: InputDecoration(
                            hintText: 'Titre, lieu...',
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
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 140,
                        child: _DropdownFilter<String>(
                          value: _selectedType,
                          items: _typeOptions,
                          label: 'Type',
                          onChanged: (v) {
                            setState(() {
                              _selectedType = v ?? 'Tous';
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                      if (showGenre) ...[
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 130,
                          child: _DropdownFilter<String>(
                            value: _selectedGenre,
                            items: _genres,
                            label: 'Genre',
                            onChanged: (v) {
                              setState(() {
                                _selectedGenre = v ?? 'Tous';
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                      ],
                      if (showCategory) ...[
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 130,
                          child: _DropdownFilter<String>(
                            value: _selectedCategory,
                            items: _categories,
                            label: 'Catégorie',
                            onChanged: (v) {
                              setState(() {
                                _selectedCategory = v ?? 'Toutes';
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                      ],
                      if (showCity) ...[
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
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
                      ],
                      const SizedBox(width: 12),
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
                final crossCount = constraints.maxWidth > 800
                    ? 4
                    : (constraints.maxWidth > 500 ? 3 : 2);
                final list = <Widget>[
                  ..._filteredFilms.map(
                    (film) => Column(
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
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(height: 6),
                        FilmCard(film: film),
                      ],
                    ),
                  ),
                  ..._filteredEvents.map(
                    (event) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(
                          label: Text(event.category),
                          backgroundColor: AppTheme.accentGreen.withValues(
                            alpha: 0.3,
                          ),
                          labelStyle: const TextStyle(
                            color: AppTheme.accentGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(height: 6),
                        EventCard(event: event),
                      ],
                    ),
                  ),
                ];
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossCount,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.72,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppTheme.cardDark,
          style: const TextStyle(color: AppTheme.textPrimary),
          hint: label != null ? Text(label!) : null,
          items: items
              .map((e) => DropdownMenuItem<T>(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
