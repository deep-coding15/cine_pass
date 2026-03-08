import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../widgets/film_card.dart';

class FilmsListPage extends StatefulWidget {
  const FilmsListPage({super.key});

  @override
  State<FilmsListPage> createState() => _FilmsListPageState();
}

class _FilmsListPageState extends State<FilmsListPage> {
  final _searchController = TextEditingController();
  String _selectedGenre = 'Tous';
  String _selectedCity = 'Toutes';
  List<FilmResponse> _films = [];
  List<String> _cities = ['Toutes'];
  List<String> _genres = ['Tous'];
  List<FilmResponse> _filteredFilms = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final films = await client.cinePass.getFilms();
      final cities = await client.cinePass.getCities();
      final genres = await client.cinePass.getGenres();
      if (!mounted) return;
      setState(() {
        _films = films;
        _cities = cities;
        _genres = genres;
        _loading = false;
        _applyFilters();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
        _filteredFilms = [];
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredFilms = _films.where((f) {
        final matchGenre =
            _selectedGenre == 'Tous' || f.genre == _selectedGenre;
        final matchCity = _selectedCity == 'Toutes';
        final matchSearch =
            query.isEmpty ||
            f.title.toLowerCase().contains(query) ||
            f.genre.toLowerCase().contains(query);
        return matchGenre && matchCity && matchSearch;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedGenre = 'Tous';
      _selectedCity = 'Toutes';
      _searchController.clear();
      _filteredFilms = List.from(_films);
    });
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Films à l'affiche",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un film...',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppTheme.cardDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              _DropdownFilter<String>(
                value: _selectedGenre,
                items: _genres,
                onChanged: (v) {
                  setState(() {
                    _selectedGenre = v ?? 'Tous';
                    _applyFilters();
                  });
                },
              ),
              const SizedBox(width: 12),
              _DropdownFilter<String>(
                value: _selectedCity,
                items: _cities,
                onChanged: (v) {
                  setState(() {
                    _selectedCity = v ?? 'Toutes';
                    _applyFilters();
                  });
                },
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              const crossAxisCount = 4;
              const childAspectRatio = 0.55;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _filteredFilms.length,
                itemBuilder: (context, index) =>
                    FilmCard(film: _filteredFilms[index]),
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
  });

  final T value;
  final List<T> items;
  final void Function(T?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: AppTheme.cardDark,
          style: const TextStyle(color: AppTheme.textPrimary),
          items: items
              .map((e) => DropdownMenuItem<T>(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
