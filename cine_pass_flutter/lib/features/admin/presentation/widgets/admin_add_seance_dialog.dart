import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

class AdminAddSeanceDialog extends StatefulWidget {
  const AdminAddSeanceDialog({
    super.key,
    required this.films,
    this.onSaved,
  });

  final List<FilmResponse> films;
  final VoidCallback? onSaved;

  @override
  State<AdminAddSeanceDialog> createState() => _AdminAddSeanceDialogState();
}

class _AdminAddSeanceDialogState extends State<AdminAddSeanceDialog> {
  String? _selectedFilmId;
  String? _selectedCinemaId;
  String? _selectedSalleId;
  String? _selectedSlot;
  DateTime? _date;
  String _langue = 'VF';
  String _type = '2D';
  final _priceController = TextEditingController(text: '12.50');

  List<CinemaResponse> _cinemas = [];
  List<Salle> _salles = [];
  bool _loading = true;

  static const List<String> _slots = [
    '10:00', '12:00', '14:00', '16:00', '18:00', '20:00', '22:00',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final cinemas = await client.cinePass.getCinemas();
      final salles = await client.cinePass.getSalles();
      if (!mounted) return;
      setState(() {
        _cinemas = cinemas;
        _salles = salles;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<Salle> get _roomsForCinema {
    if (_selectedCinemaId == null) return [];
    return _salles
        .where((s) => s.cinemaId.toString() == _selectedCinemaId)
        .toList();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryRed),
          ),
        ),
      );
    }
    return Dialog(
      backgroundColor: AppTheme.cardDark,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ajouter une nouvelle séance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _dropdown<String>(
                        label: 'Film',
                        value: _selectedFilmId,
                        hint: 'Sélectionner un film',
                        items: widget.films
                            .map(
                              (f) => DropdownMenuItem(
                                value: f.id,
                                child: Text(f.title),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedFilmId = v),
                      ),
                      const SizedBox(height: 12),
                      _dropdown<String>(
                        label: 'Cinéma',
                        value: _selectedCinemaId,
                        hint: 'Sélectionner un cinéma',
                        items: _cinemas
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text('${c.name} - ${c.city}'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedCinemaId = v;
                          _selectedSalleId = null;
                          _selectedSlot = null;
                        }),
                      ),
                      const SizedBox(height: 12),
                      _dropdown<String>(
                        label: 'Salle',
                        value: _selectedSalleId,
                        hint: 'Sélectionner une salle',
                        items: _roomsForCinema
                            .map(
                              (r) => DropdownMenuItem(
                                value: r.id.toString(),
                                child: Text(r.nom),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedSalleId = v;
                          _selectedSlot = null;
                        }),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (d != null) setState(() => _date = d);
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          _date != null
                              ? '${_date!.day}/${_date!.month}/${_date!.year}'
                              : 'Date (jj/mm/aaaa)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _dropdown<String>(
                        label: 'Heure',
                        value: _selectedSlot,
                        hint: '--:--',
                        items: _slots
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedSlot = v),
                      ),
                      const SizedBox(height: 12),
                      _dropdown<String>(
                        label: 'Langue',
                        value: _langue,
                        hint: 'Langue',
                        items: const [
                          DropdownMenuItem(value: 'VF', child: Text('VF')),
                          DropdownMenuItem(value: 'VO', child: Text('VO')),
                        ],
                        onChanged: (v) =>
                            setState(() => _langue = v ?? 'VF'),
                      ),
                      const SizedBox(height: 12),
                      _dropdown<String>(
                        label: 'Type de projection',
                        value: _type,
                        hint: 'Type',
                        items: const [
                          DropdownMenuItem(value: '2D', child: Text('2D')),
                          DropdownMenuItem(value: '3D', child: Text('3D')),
                          DropdownMenuItem(value: 'IMAX', child: Text('IMAX')),
                        ],
                        onChanged: (v) => setState(() => _type = v ?? '2D'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Prix (€)',
                          filled: true,
                          fillColor: AppTheme.surfaceDark,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () async {
                                if (_selectedFilmId == null ||
                                    _selectedCinemaId == null ||
                                    _selectedSalleId == null ||
                                    _selectedSlot == null ||
                                    _date == null) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Remplissez tous les champs',
                                      ),
                                      backgroundColor: AppTheme.primaryRed,
                                    ),
                                  );
                                  return;
                                }
                                final price = double.tryParse(
                                      _priceController.text.trim(),
                                    ) ??
                                    12.50;
                                final parts = _selectedSlot!.split(':');
                                final hour = int.tryParse(parts[0]) ?? 20;
                                final minute =
                                    parts.length > 1
                                        ? int.tryParse(parts[1]) ?? 0
                                        : 0;
                                final debutAt = DateTime(
                                  _date!.year,
                                  _date!.month,
                                  _date!.day,
                                  hour,
                                  minute,
                                );
                                try {
                                  final created =
                                      await client.cinePass.createSeance(
                                    filmId: _selectedFilmId!,
                                    salleId: _selectedSalleId!,
                                    debutAt: debutAt,
                                    format: _langue,
                                    type: _type,
                                    prixBase: price,
                                  );
                                  if (!context.mounted) return;
                                  if (created != null) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text('Séance enregistrée'),
                                        backgroundColor: AppTheme.accentGreen,
                                      ),
                                    );
                                    widget.onSaved?.call();
                                    Navigator.of(context).pop();
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Erreur lors de l\'enregistrement',
                                        ),
                                        backgroundColor: AppTheme.primaryRed,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur: $e'),
                                      backgroundColor: AppTheme.primaryRed,
                                    ),
                                  );
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.primaryRed,
                              ),
                              child: const Text('Enregistrer'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Annuler'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.surfaceDark,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      dropdownColor: AppTheme.cardDark,
      hint: Text(
        hint,
        style: const TextStyle(color: AppTheme.textSecondary),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
