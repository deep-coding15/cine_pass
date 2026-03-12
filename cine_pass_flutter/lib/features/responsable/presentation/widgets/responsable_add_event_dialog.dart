import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

/// Structure minimale pour le dropdown (id + nom).
class ResponsableStructureItem {
  const ResponsableStructureItem({required this.id, required this.name});
  final String id;
  final String name;
}

/// Dialog pour créer un événement depuis l'espace responsable.
/// Affiche un dropdown "Structure" (mes structures) puis les mêmes champs que l'admin.
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

  Future<void> _submit() async {
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
          content: Text('Aucune structure. Vos structures seront disponibles après approbation.'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final created = await client.cinePass.createEvent(
        titre: _titleController.text.trim(),
        categorie: _categoryController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        lieu: _venueNameController.text.trim().isEmpty
            ? 'Lieu'
            : _venueNameController.text.trim(),
        adresse: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        ville: _cityController.text.trim(),
        eventDate: _date!,
        eventTimeStr: _timeController.text.trim().isEmpty
            ? '20:00'
            : _timeController.text.trim(),
        placesTotal: int.tryParse(_placesController.text.trim()) ?? 300,
        prixBase: double.tryParse(
              _priceController.text.trim().replaceAll(',', '.'),
            ) ??
            35.0,
        posterColor: null,
      );
      if (!mounted) return;
      if (created != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Événement créé'),
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
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
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
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.structures.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Aucune structure disponible. Ajoutez une structure dans "Mes structures" (après approbation de votre demande).',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            value: _selectedStructureId,
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
                            onChanged: (v) =>
                                setState(() => _selectedStructureId = v),
                          ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _titleController,
                          decoration: _decoration('Titre de l\'événement'),
                          style: const TextStyle(color: AppTheme.textPrimary),
                          validator: (v) =>
                              v?.trim().isEmpty == true ? 'Requis' : null,
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
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                decoration: _decoration('Ville'),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                ),
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
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _timeController,
                                decoration: _decoration('HH:mm'),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                ),
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
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: _decoration('Prix (€)'),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                ),
                                validator: (v) => v == null ||
                                        double.tryParse(
                                              v.replaceAll(',', '.'),
                                            ) ==
                                            null
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
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                ),
                                validator: (v) =>
                                    v == null || int.tryParse(v) == null
                                        ? 'Nombre requis'
                                        : null,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
