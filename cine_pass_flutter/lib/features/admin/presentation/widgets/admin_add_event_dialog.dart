import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

class AdminAddEventDialog extends StatefulWidget {
  const AdminAddEventDialog({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  State<AdminAddEventDialog> createState() => _AdminAddEventDialogState();
}

class _AdminAddEventDialogState extends State<AdminAddEventDialog> {
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
  String _venueType = 'other';
  DateTime? _date;
  final _timeController = TextEditingController(text: '20:00');

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
    super.dispose();
  }

  static InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppTheme.surfaceDark,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    labelStyle: const TextStyle(color: AppTheme.textSecondary),
  );

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
                    'Ajouter un nouvel événement',
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
                          decoration: _decoration(
                            'Description de l\'événement',
                          ),
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
                        DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: _venueType,
                          decoration: _decoration('Type de lieu'),
                          dropdownColor: AppTheme.cardDark,
                          items: const [
                            DropdownMenuItem(
                              value: 'cinema',
                              child: Text('Cinéma'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Autre lieu'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _venueType = v ?? 'other'),
                        ),
                        if (_venueType == 'cinema') ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: _decoration('Sélectionner un cinéma'),
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        ],
                        if (_venueType == 'other') ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _venueNameController,
                            decoration: _decoration('Salle Pleyel...'),
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        ],
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
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                ),
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
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: _decoration('Prix (€)'),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                ),
                                validator: (v) =>
                                    v == null ||
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
                                decoration: _decoration('Places disponibles'),
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
                          decoration: _decoration('https://...'),
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() != true || _date == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Remplissez tous les champs requis'), backgroundColor: AppTheme.primaryRed),
                                    );
                                    return;
                                  }
                                  try {
                                    final created = await client.cinePass.createEvent(
                                      titre: _titleController.text.trim(),
                                      categorie: _categoryController.text.trim(),
                                      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                                      lieu: _venueNameController.text.trim().isEmpty ? 'Lieu' : _venueNameController.text.trim(),
                                      adresse: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
                                      ville: _cityController.text.trim(),
                                      eventDate: _date!,
                                      eventTimeStr: _timeController.text.trim().isEmpty ? '20:00' : _timeController.text.trim(),
                                      placesTotal: int.tryParse(_placesController.text.trim()) ?? 300,
                                      prixBase: double.tryParse(_priceController.text.trim().replaceAll(',', '.')) ?? 35.0,
                                      posterColor: null,
                                    );
                                    if (!context.mounted) return;
                                    if (created != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Événement enregistré'), backgroundColor: AppTheme.accentGreen),
                                      );
                                      widget.onSaved?.call();
                                      Navigator.of(context).pop();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Erreur lors de l\'enregistrement'), backgroundColor: AppTheme.primaryRed),
                                      );
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.primaryRed),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
