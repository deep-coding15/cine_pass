import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Dialog legacy gardé pour compatibilité.
/// La création se fait désormais depuis le formulaire événement.
class AdminAddFilmDialog extends StatefulWidget {
  const AdminAddFilmDialog({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  State<AdminAddFilmDialog> createState() => _AdminAddFilmDialogState();
}

class _AdminAddFilmDialogState extends State<AdminAddFilmDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardDark,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ancien formulaire film',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'La création séparée de films a été remplacée par la création d’événements de type Film.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }
}
