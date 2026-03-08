import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AdminAddEventDialog extends StatefulWidget {
  const AdminAddEventDialog({super.key});

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
  String _venueType = 'other'; // 'cinema' | 'other'
  DateTime? _date;
  // ignore: unused_field - utilisé pour envoi futur
  String _time = '';

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
                                onChanged: (v) => setState(() => _time = v),
                                decoration: _decoration('--:--'),
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
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ==
                                      true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Événement enregistré (démo)',
                                        ),
                                        backgroundColor: AppTheme.accentGreen,
                                      ),
                                    );
                                    Navigator.of(context).pop();
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
