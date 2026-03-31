import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Carte legacy conservée pour compatibilité de compilation.
/// Le catalogue principal repose désormais sur `EventCard`.
class FilmCard extends StatelessWidget {
  const FilmCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.movie_rounded, color: AppTheme.textSecondary, size: 32),
            SizedBox(height: 12),
            Text(
              'Film intégré aux événements',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Utilisez désormais les cartes événement.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
