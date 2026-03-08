import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../films/data/mock_films_data.dart';
import '../../data/mock_admin_data.dart';

class AdminAddSeanceDialog extends StatefulWidget {
  const AdminAddSeanceDialog({super.key});

  @override
  State<AdminAddSeanceDialog> createState() => _AdminAddSeanceDialogState();
}

class _AdminAddSeanceDialogState extends State<AdminAddSeanceDialog> {
  String? _selectedFilmId;
  String? _selectedCinemaId;
  String? _selectedRoomId;
  String? _selectedSlot;
  DateTime? _date;
  String _langue = 'VF';
  String _type = '2D';
  final _priceController = TextEditingController(text: '12.50');
  final _placesController = TextEditingController(text: '150');

  @override
  void dispose() {
    _priceController.dispose();
    _placesController.dispose();
    super.dispose();
  }

  MockCinema? get _selectedCinema {
    if (_selectedCinemaId == null) return null;
    for (final c in mockCinemas) {
      if (c.id == _selectedCinemaId) return c;
    }
    return null;
  }

  MockRoom? get _selectedRoom {
    final cinema = _selectedCinema;
    if (cinema == null || _selectedRoomId == null) return null;
    for (final r in cinema.rooms) {
      if (r.id == _selectedRoomId) return r;
    }
    return null;
  }

  List<MockRoom> get _rooms => _selectedCinema?.rooms ?? [];
  List<String> get _slots => _selectedRoom?.availableSlots ?? [];

  @override
  Widget build(BuildContext context) {
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
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
                        items: mockFilms.map((f) => DropdownMenuItem(value: f.id, child: Text(f.title))).toList(),
                        onChanged: (v) => setState(() {
                          _selectedFilmId = v;
                        }),
                      ),
                      const SizedBox(height: 12),
                      _dropdown<String>(
                        label: 'Cinéma',
                        value: _selectedCinemaId,
                        hint: 'Sélectionner un cinéma',
                        items: mockCinemas.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.name} - ${c.city}'))).toList(),
                        onChanged: (v) => setState(() {
                          _selectedCinemaId = v;
                          _selectedRoomId = null;
                          _selectedSlot = null;
                        }),
                      ),
                      const SizedBox(height: 12),
                      _dropdown<String>(
                        label: 'Salle',
                        value: _selectedRoomId,
                        hint: 'Sélectionner une salle',
                        items: _rooms.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
                        onChanged: (v) => setState(() {
                          _selectedRoomId = v;
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
                        label: Text(_date != null ? '${_date!.day}/${_date!.month}/${_date!.year}' : 'Date (mm/jj/aaaa)'),
                      ),
                      const SizedBox(height: 12),
                      _dropdown<String>(
                        label: 'Heure',
                        value: _selectedSlot,
                        hint: '--:--',
                        items: _slots.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _selectedSlot = v),
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
                        onChanged: (v) => setState(() => _langue = v ?? 'VF'),
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
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Prix (€)',
                          filled: true,
                          fillColor: AppTheme.surfaceDark,
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                        ),
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _placesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Places disponibles',
                          filled: true,
                          fillColor: AppTheme.surfaceDark,
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                        ),
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                if (_selectedFilmId == null || _selectedCinemaId == null || _selectedRoomId == null || _selectedSlot == null || _date == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Remplissez tous les champs'), backgroundColor: AppTheme.primaryRed),
                                  );
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Séance enregistrée (démo)'), backgroundColor: AppTheme.accentGreen),
                                );
                                Navigator.of(context).pop();
                              },
                              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
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
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      ),
      dropdownColor: AppTheme.cardDark,
      hint: Text(hint, style: const TextStyle(color: AppTheme.textSecondary)),
      items: items,
      onChanged: onChanged,
    );
  }
}
