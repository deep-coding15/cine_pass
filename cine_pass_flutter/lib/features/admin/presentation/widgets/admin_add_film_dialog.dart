import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

class AdminAddFilmDialog extends StatefulWidget {
  const AdminAddFilmDialog({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  State<AdminAddFilmDialog> createState() => _AdminAddFilmDialogState();
}

class _AdminAddFilmDialogState extends State<AdminAddFilmDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _genreController = TextEditingController();
  final _durationController = TextEditingController(text: '120');
  final _directorController = TextEditingController();
  final _classificationController = TextEditingController();
  final _castingController = TextEditingController();
  final _posterUrlController = TextEditingController();
  final _trailerUrlController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _titleController.dispose();
    _synopsisController.dispose();
    _genreController.dispose();
    _durationController.dispose();
    _directorController.dispose();
    _classificationController.dispose();
    _castingController.dispose();
    _posterUrlController.dispose();
    _trailerUrlController.dispose();
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
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
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
                    'Ajouter un nouveau film',
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
                          decoration: _decoration('Titre du film'),
                          style: const TextStyle(color: AppTheme.textPrimary),
                          validator: (v) =>
                              v?.trim().isEmpty == true ? 'Requis' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _synopsisController,
                          maxLines: 3,
                          decoration: _decoration('Description du film'),
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _genreController,
                          decoration: _decoration('Action, Drame...'),
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: _decoration('Durée (min)'),
                          style: const TextStyle(color: AppTheme.textPrimary),
                          validator: (v) => v == null || int.tryParse(v) == null
                              ? 'Nombre requis'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _directorController,
                          decoration: _decoration('Nom du réalisateur'),
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _classificationController,
                          decoration: _decoration('Tous publics, -12...'),
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _castingController,
                          decoration: _decoration('Acteur 1, Acteur 2...'),
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _posterUrlController,
                          decoration: _decoration('https://...'),
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _trailerUrlController,
                          decoration: _decoration('https://youtube.com/...'),
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
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (d != null) setState(() => _startDate = d);
                                },
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                ),
                                label: Text(
                                  _startDate != null
                                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                      : 'Date de début',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (d != null) setState(() => _endDate = d);
                                },
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                ),
                                label: Text(
                                  _endDate != null
                                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : 'Date de fin',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() != true)
                                    return;
                                  final title = _titleController.text.trim();
                                  final genre = _genreController.text.trim();
                                  final durationMinutes =
                                      int.tryParse(
                                        _durationController.text.trim(),
                                      ) ??
                                      120;
                                  try {
                                    final created = await client.cinePass
                                        .createFilm(
                                          title: title,
                                          genre: genre,
                                          durationMinutes: durationMinutes,
                                          synopsis:
                                              _synopsisController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _synopsisController.text.trim(),
                                          director:
                                              _directorController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _directorController.text.trim(),
                                          casting:
                                              _castingController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _castingController.text.trim(),
                                          posterColor: null,
                                          dateSortie: _startDate,
                                          dateFin: _endDate,
                                          audience:
                                              _classificationController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _classificationController.text
                                                    .trim(),
                                        );
                                    if (!context.mounted) return;
                                    if (created != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Film enregistré'),
                                          backgroundColor: AppTheme.accentGreen,
                                        ),
                                      );
                                      widget.onSaved?.call();
                                      Navigator.of(context).pop();
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
