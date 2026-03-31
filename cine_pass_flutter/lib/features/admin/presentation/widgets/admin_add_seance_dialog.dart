import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Dialog legacy gardé pour compatibilité.
/// Les anciennes séances sont désormais créées comme événements / représentations.
class AdminAddSeanceDialog extends StatefulWidget {
  const AdminAddSeanceDialog({super.key, this.onSaved});
  final VoidCallback? onSaved;

  @override
  State<AdminAddSeanceDialog> createState() => _AdminAddSeanceDialogState();
}

class _AdminAddSeanceDialogState extends State<AdminAddSeanceDialog> {
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
              'Ancien formulaire séance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Les séances classiques sont désormais gérées via les événements et leurs représentations.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
              ),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }
}
