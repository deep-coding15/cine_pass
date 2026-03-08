import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../widgets/event_card.dart';

class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  final _searchController = TextEditingController();
  String _selectedCity = 'Toutes';
  String _selectedCategory = 'Toutes';
  List<EventResponse> _events = [];
  List<String> _cities = ['Toutes'];
  List<String> _categories = ['Toutes'];
  List<EventResponse> _filteredEvents = [];
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
      final events = await client.cinePass.getEvents();
      final cities = await client.cinePass.getCities();
      final categories = await client.cinePass.getEventCategories();
      if (!mounted) return;
      setState(() {
        _events = events;
        _cities = cities;
        _categories = categories;
        _loading = false;
        _applyFilters();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
        _filteredEvents = [];
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredEvents = _events.where((e) {
        final matchCity = _selectedCity == 'Toutes' || e.city == _selectedCity;
        final matchCategory = _selectedCategory == 'Toutes' || e.category == _selectedCategory;
        final matchSearch = query.isEmpty ||
            e.title.toLowerCase().contains(query) ||
            e.category.toLowerCase().contains(query) ||
            e.location.toLowerCase().contains(query);
        return matchCity && matchCategory && matchSearch;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCity = 'Toutes';
      _selectedCategory = 'Toutes';
      _searchController.clear();
      _filteredEvents = List.from(_events);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erreur: $_error', style: const TextStyle(color: AppTheme.textSecondary), textAlign: TextAlign.center),
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
            'Événements à venir',
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
                    hintText: 'Rechercher un événement...',
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
              _DropdownFilter<String>(
                value: _selectedCategory,
                items: _categories,
                onChanged: (v) {
                  setState(() {
                    _selectedCategory = v ?? 'Toutes';
                    _applyFilters();
                  });
                },
              ),
              const SizedBox(width: 12),
              TextButton(onPressed: _resetFilters, child: const Text('Réinitialiser')),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _filteredEvents.length,
                itemBuilder: (context, index) => EventCard(event: _filteredEvents[index]),
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
