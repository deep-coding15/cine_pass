import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/cinepass_logo.dart';

/// Splash 3 s : logo + titre "CinePass" une seule fois + barre de tickets qui se remplissent. Pas bloquant.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  static const String _appName = 'CinePass';
  static const Duration _duration = Duration(milliseconds: 3000);

  late AnimationController _mainController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;
  bool? _onboardingSeen;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Charger les préférences en parallèle sans bloquer l'UI
    _loadPrefs();

    _mainController = AnimationController(
      vsync: this,
      duration: _duration,
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _opacityAnimation = Tween<double>(begin: 1, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0, 1, curve: Curves.easeOut),
      ),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0, 0.85, curve: Curves.easeInOutCubic),
      ),
    );

    _mainController.forward();

    // Navigation après 3 s : on ne bloque jamais sur SharedPreferences
    Future<void>.delayed(_duration, () {
      if (!mounted || _navigated) return;
      _navigateAway();
    });
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _onboardingSeen = false);
      }
    }
  }

  void _navigateAway() {
    if (_navigated) return;
    _navigated = true;
    AppRouter.markSplashDone();
    if (!mounted) return;
    if (_onboardingSeen == true) {
      context.go('/');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              AppTheme.primaryRed.withValues(alpha: 0.06),
              AppTheme.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              final progress = _mainController.value;
              final letterCount = (progress * _appName.length)
                  .floor()
                  .clamp(0, _appName.length);
              final visibleName = _appName.substring(0, letterCount);
              final angle = _rotationAnimation.value * 2 * math.pi;

              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      Transform.rotate(
                        angle: angle,
                        child: const CinePassLogoIcon(size: 56),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        visibleName,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TicketProgressBar(progress: progress),
                      const Spacer(flex: 3),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
