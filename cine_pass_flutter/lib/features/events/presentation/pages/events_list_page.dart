import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../widgets/event_card.dart';

/// Page événements uniquement (source API `getEvents`).
class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  final _searchController = TextEditingController();

  String _selectedType = 'Tous';
  String _selectedCity = 'Toutes';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  List<EventResponse> _events = [];
  List<String> _cities = ['Toutes'];

  List<String> _typeOptions = const ['Tous'];
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
      final results = await Future.wait<dynamic>([
        client.cinePass.getEvents(),
        client.cinePass.getCities(),
        client.cinePass.getEventCategories(),
      ]);
      if (!mounted) return;
      final events = results[0] as List<EventResponse>;
      final cities = results[1] as List<String>;
      final categories = results[2] as List<String>;
      final typeOpts = ['Tous', ...categories.where((c) => c != 'Toutes')];

      setState(() {
        _events = events;
        _cities = cities;
        _typeOptions = typeOpts;
        if (!typeOpts.contains(_selectedType)) {
          _selectedType = 'Tous';
        }
        if (!_cities.contains(_selectedCity)) {
          _selectedCity = 'Toutes';
        }
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

  bool _eventMatchesCity(EventResponse e) {
    if (_selectedCity == 'Toutes') return true;
    return e.city.trim().toLowerCase() == _selectedCity.trim().toLowerCase();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    List<EventResponse> events = _events;

    if (_selectedType != 'Tous') {
      events = events.where(_eventMatchesSelectedType).toList();
    }
    if (_selectedCity != 'Toutes') {
      events = events.where(_eventMatchesCity).toList();
    }
    events = _filterEventsByDate(events);
    if (query.isNotEmpty) {
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

    setState(() {
      _filteredEvents = events;
    });
  }

  bool _eventMatchesSelectedType(EventResponse e) =>
      _eventMatchesDisplayType(e, _selectedType);

  bool _eventMatchesDisplayType(EventResponse e, String displayType) {
    final sel = displayType.trim();
    final code = _eventTypeCodeFromLabel(sel);
    final typeUpper = (e.eventType ?? '').trim().toUpperCase();
    if (code.isNotEmpty && typeUpper == code) return true;
    if (e.category.trim().toLowerCase() == sel.toLowerCase()) return true;
    return false;
  }

  String _eventTypeCodeFromLabel(String type) {
    switch (type.toLowerCase()) {
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
      _dateFrom = null;
      _dateTo = null;
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

    const showCity = true;

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
            'Événements publiés sur la plateforme',
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
          if (_filteredEvents.isEmpty)
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
                  ..._filteredEvents.map(
                    (event) => ClipRect(child: EventCard(event: event)),
                  ),
                ];
                // Cartes compactes : ratio pour éviter overflow
                // Plus haut : évite le débordement des cartes événement (prix + bouton).
                // Cartes avec affiche plus haute (2/3) : cellule un peu plus haute.
                // Ratio plus bas = cellules plus hautes (évite overflow bas des EventCard).
                final childAspectRatio = w > 900 ? 0.48 : 0.40;
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
