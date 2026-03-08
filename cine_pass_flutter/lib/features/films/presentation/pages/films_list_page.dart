import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/mock_films_data.dart';
import '../widgets/film_card.dart';

class FilmsListPage extends StatefulWidget {
  const FilmsListPage({super.key});

  @override
  State<FilmsListPage> createState() => _FilmsListPageState();
}

class _FilmsListPageState extends State<FilmsListPage> {
  final _searchController = TextEditingController();
  String _selectedGenre = 'Tous';
  String _selectedCity = 'Paris';
  List<MockFilm> _filteredFilms = List.from(mockFilms);

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredFilms = mockFilms.where((f) {
        final matchGenre = _selectedGenre == 'Tous' || f.genre == _selectedGenre;
        final matchSearch = query.isEmpty ||
            f.title.toLowerCase().contains(query) ||
            f.genre.toLowerCase().contains(query);
        return matchGenre && matchSearch;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedGenre = 'Tous';
      _selectedCity = 'Paris';
      _searchController.clear();
      _filteredFilms = List.from(mockFilms);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
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
                items: mockGenres,
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
                items: mockCities,
                onChanged: (v) {
                  setState(() {
                    _selectedCity = v ?? 'Paris';
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
                itemBuilder: (context, index) => FilmCard(film: _filteredFilms[index]),
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
          items: items.map((e) => DropdownMenuItem<T>(value: e as T, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
