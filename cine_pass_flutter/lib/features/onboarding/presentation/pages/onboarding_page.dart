import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';

/// Parcours d'intro : Bonjour, présentation de l'app en steps, Next, puis "Voir l'app".
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _steps = [
    _OnboardingStep(
      title: 'Bonjour !',
      body:
          'Bienvenue sur CinePass. Réservez vos billets de cinéma et vos places '
          'pour vos événements préférés en quelques clics.',
      icon: Icons.waving_hand_rounded,
    ),
    _OnboardingStep(
      title: 'Films & Événements',
      body:
          'Découvrez les films à l\'affiche et les événements (concerts, théâtre, '
          'spectacles) proposés par nos partenaires.',
      icon: Icons.movie_rounded,
    ),
    _OnboardingStep(
      title: 'Réservation simple',
      body:
          'Choisissez votre séance ou votre événement, sélectionnez vos places '
          'et validez en toute sécurité. Vos billets sont dans l\'app.',
      icon: Icons.confirmation_number_rounded,
    ),
    _OnboardingStep(
      title: 'C\'est parti',
      body:
          'Vous êtes prêt à réserver. Cliquez sur "Voir l\'app" pour accéder '
          'à l\'accueil et commencer.',
      icon: Icons.rocket_launch_rounded,
    ),
  ];

  int _currentIndex = 0;

  Future<void> _goToApp() async {
    AppRouter.markSplashDone();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_seen', true);
    } catch (_) {}
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentIndex];
    final isLast = _currentIndex == _steps.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step.icon,
                  size: 56,
                  color: AppTheme.primaryRed,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                step.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                step.body,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentIndex ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentIndex
                          ? AppTheme.primaryRed
                          : AppTheme.textSecondary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  if (isLast) {
                    _goToApp();
                  } else {
                    setState(() => _currentIndex++);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isLast ? 'Voir l\'app' : 'Suivant',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

class _OnboardingStep {
  const _OnboardingStep({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}
