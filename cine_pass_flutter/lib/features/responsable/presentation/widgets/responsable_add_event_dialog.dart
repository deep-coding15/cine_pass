import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

/// Structure minimale pour le dropdown (id + nom).
class ResponsableStructureItem {
  const ResponsableStructureItem({required this.id, required this.name});
  final String id;
  final String name;
}

/// Une séance dans le cadre de la création d'événement.
class _SeanceItem {
  _SeanceItem({
    required this.date,
    required this.timeStr,
    required this.lieu,
  });
  DateTime date;
  String timeStr;
  String lieu;
}

/// Dialog en 2 étapes : 1) Formulaire événement, 2) Programmation des séances (au moins une).
class ResponsableAddEventDialog extends StatefulWidget {
  const ResponsableAddEventDialog({
    super.key,
    required this.structures,
    this.onSaved,
  });

  final List<ResponsableStructureItem> structures;
  final VoidCallback? onSaved;

  @override
  State<ResponsableAddEventDialog> createState() =>
      _ResponsableAddEventDialogState();
}

class _ResponsableAddEventDialogState extends State<ResponsableAddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _cityController = TextEditingController(text: 'Paris');
  final _venueNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController(text: '35.00');
  final _placesController = TextEditingController(text: '300');
  final _posterUrlController = TextEditingController();
  final _timeController = TextEditingController(text: '20:00');
  String? _selectedStructureId;
  DateTime? _date;
  bool _saving = false;
  final List<_SeanceItem> _seances = [];

  @override
  void initState() {
    super.initState();
    if (widget.structures.isNotEmpty) {
      _selectedStructureId = widget.structures.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _cityController.dispose();
    _venueNameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _placesController.dispose();
    _posterUrlController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  static InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppTheme.surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
      );

  void _goToStepSeances() {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedStructureId == null && widget.structures.isNotEmpty) return;
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisissez une date'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }
    if (widget.structures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Aucune structure. Vos structures seront disponibles après approbation.'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }
    setState(() {
      _seances.clear();
      _seances.add(_SeanceItem(
        date: _date!,
        timeStr: _timeController.text.trim().isEmpty ? '20:00' : _timeController.text.trim(),
        lieu: _venueNameController.text.trim().isEmpty ? 'Lieu' : _venueNameController.text.trim(),
      ));
      _currentStep = 1;
    });
  }

  void _addSeance() {
    setState(() {
      _seances.add(_SeanceItem(
        date: _date ?? DateTime.now(),
        timeStr: _timeController.text.trim().isEmpty ? '20:00' : _timeController.text.trim(),
        lieu: _venueNameController.text.trim().isEmpty ? 'Lieu' : _venueNameController.text.trim(),
      ));
    });
  }

  void _removeSeance(int index) {
    if (_seances.length <= 1) return;
    setState(() => _seances.removeAt(index));
  }

  Future<void> _submit() async {
    if (_seances.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins une séance'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }
    final first = _seances.first;
    setState(() => _saving = true);
    try {
      final created = await client.cinePass.createEvent(
        titre: _titleController.text.trim(),
        categorie: _categoryController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        lieu: first.lieu,
        adresse: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        ville: _cityController.text.trim(),
        eventDate: first.date,
        eventTimeStr: first.timeStr,
        placesTotal: int.tryParse(_placesController.text.trim()) ?? 300,
        prixBase: double.tryParse(
              _priceController.text.trim().replaceAll(',', '.'),
            ) ??
            35.0,
        posterColor: null,
        structureId: _selectedStructureId,
      );
      if (!mounted) return;
      if (created != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Événement créé avec au moins une séance'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        widget.onSaved?.call();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'enregistrement'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardDark,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
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
                    'Créer un événement',
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
              const SizedBox(height: 8),
              Row(
                children: [
                  _stepChip(0, 'Formulaire'),
                  const SizedBox(width: 8),
                  _stepChip(1, 'Séances'),
                ],
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: _currentStep == 0 ? _buildStepForm() : _buildStepSeances(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepChip(int step, String label) {
    final active = _currentStep == step;
    return GestureDetector(
      onTap: () {
        if (step == 0) {
          setState(() => _currentStep = 0);
        } else if (_formKey.currentState?.validate() == true && _date != null) {
          _goToStepSeances();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.accentGreen : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Étape ${step + 1} : $label',
          style: TextStyle(
            color: active ? Colors.white : AppTheme.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStepForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.structures.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Aucune structure disponible.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: _selectedStructureId,
              decoration: _decoration('Structure'),
              dropdownColor: AppTheme.cardDark,
              items: widget.structures
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedStructureId = v),
            ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _titleController,
            decoration: _decoration('Titre de l\'événement'),
            style: const TextStyle(color: AppTheme.textPrimary),
            validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: _decoration('Description'),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _categoryController,
                  decoration: _decoration('Concert, Théâtre...'),
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: _decoration('Ville'),
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _venueNameController,
            decoration: _decoration('Lieu / Salle'),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: _decoration('Adresse complète'),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (d != null) setState(() => _date = d);
                  },
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    _date != null
                        ? '${_date!.day}/${_date!.month}/${_date!.year}'
                        : 'Date',
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _timeController,
                  decoration: _decoration('HH:mm'),
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: _decoration('Prix (€)'),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  validator: (v) => v == null ||
                          double.tryParse(v.replaceAll(',', '.')) == null
                      ? 'Nombre requis'
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _placesController,
                  keyboardType: TextInputType.number,
                  decoration: _decoration('Places'),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  validator: (v) =>
                      v == null || int.tryParse(v) == null ? 'Nombre requis' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _posterUrlController,
            decoration: _decoration('URL affiche (optionnel)'),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _goToStepSeances,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                  ),
                  child: const Text('Suivant — Programmer les séances'),
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
    );
  }

  Widget _buildStepSeances() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Programmation des séances (au moins une)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ajoutez au moins une séance avec date, heure et lieu. Vous pourrez en ajouter d\'autres après la création.',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_seances.length, (index) {
          final s = _seances[index];
          return Card(
            color: AppTheme.surfaceDark,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, color: AppTheme.accentGreen, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${s.date.day}/${s.date.month}/${s.date.year} ${s.timeStr}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          s.lieu,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_seances.length > 1)
                    IconButton(
                      onPressed: () => _removeSeance(index),
                      icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primaryRed),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _addSeance,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Ajouter une séance'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.accentGreen,
            side: const BorderSide(color: AppTheme.accentGreen),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('Retour'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Créer l\'événement'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
