import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

enum AuthModeTab { connexion, inscription }

class AuthModeTabs extends StatelessWidget {
  const AuthModeTabs({
    super.key,
    required this.activeTab,
  });

  final AuthModeTab activeTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AuthTabButton(
              label: 'Connexion',
              isActive: activeTab == AuthModeTab.connexion,
              onTap: () {
                if (activeTab != AuthModeTab.connexion) {
                  context.go(AppRouter.connexion);
                }
              },
            ),
          ),
          Expanded(
            child: _AuthTabButton(
              label: 'Inscription',
              isActive: activeTab == AuthModeTab.inscription,
              onTap: () {
                if (activeTab != AuthModeTab.inscription) {
                  context.go(AppRouter.inscription);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTabButton extends StatelessWidget {
  const _AuthTabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryRed : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

