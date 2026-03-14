import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';

class HomeHero extends StatefulWidget {
  const HomeHero({super.key});

  @override
  State<HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<HomeHero> with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _colorController;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _buttonFade;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );
    _titleSlide =
        Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0, 0.4, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
      ),
    );
    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
      ),
    );
    _glowPulse = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.5, 1, curve: Curves.easeInOut),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _colorController.stop();
    _colorController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorController,
      builder: (context, child) {
        final t = _colorController.value;
        final redMix = Color.lerp(
          const Color(0xFF1A1A2E),
          AppTheme.primaryRed.withValues(alpha: 0.15),
          t * 0.5,
        )!;
        final greenMix = Color.lerp(
          const Color(0xFF16213E),
          AppTheme.accentGreen.withValues(alpha: 0.12),
          0.5 - (t - 0.5).abs(),
        )!;
        return Container(
          height: 340,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                redMix,
                greenMix,
                const Color(0xFF0D0D0D),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Formes de profondeur
          Positioned(
            right: -80,
            bottom: -60,
            child: Container(
              width: 320,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.03),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            right: -40,
            bottom: -20,
            child: Container(
              width: 240,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.04),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 48, 40, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _titleFade.value,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            children: [
                              const TextSpan(text: 'Réservez l\'expérience. '),
                              TextSpan(
                                text: 'Pas seulement le billet.',
                                style: TextStyle(
                                  color: AppTheme.accentGreen.withValues(
                                    alpha: _glowPulse.value,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: AppTheme.accentGreen.withValues(
                                        alpha: 0.3 * _glowPulse.value,
                                      ),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _subtitleFade,
                  child: Text(
                    'Cinéma, concerts, spectacles — vos billets en quelques secondes.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _buttonFade,
                  child: FilledButton.icon(
                    onPressed: () => context.go(AppRouter.events),
                    icon: const Icon(Icons.search_rounded, size: 22),
                    label: const Text('Rechercher'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
