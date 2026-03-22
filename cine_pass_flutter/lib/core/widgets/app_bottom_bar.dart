import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../theme/app_theme.dart';

/// Bandeau bas d’écran présent sur toutes les pages (zone sécurisée + repères utiles).
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({super.key, this.compactLinks = false});

  /// Moins de liens (sidebar déjà présente à gauche).
  final bool compactLinks;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Material(
      color: AppTheme.sidebarDark.withValues(alpha: 0.92),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomInset),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.textSecondary.withValues(alpha: 0.25),
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              'CinePass',
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),

            SizedBox(width: compactLinks ? 8 : 12),
            Expanded(
              child: Text(
                'Réservez vos événements en toute simplicité',
                style: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.65),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!compactLinks) ...[
              TextButton(
                onPressed: () => context.go(AppRouter.faq),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppTheme.textSecondary,
                ),
                child: const Text('FAQ', style: TextStyle(fontSize: 12)),
              ),
              TextButton(
                onPressed: () => context.go(AppRouter.support),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppTheme.textSecondary,
                ),
                child: const Text('Support', style: TextStyle(fontSize: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
