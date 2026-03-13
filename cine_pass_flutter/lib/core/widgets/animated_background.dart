import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animation de fond discrète (dégradé animé + particules légères).
/// À envelopper derrière le contenu des pages pour un rendu pro.
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    required this.child,
    this.opacity = 0.08,
  });

  final Widget child;
  final double opacity;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _gradientAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _gradientAnimation,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(
                    0.3 +
                        0.4 * math.sin(_gradientAnimation.value * 2 * math.pi),
                    0.4 +
                        0.3 * math.cos(_gradientAnimation.value * 2 * math.pi),
                  ),
                  radius: 1.2,
                  colors: [
                    AppTheme.primaryRed.withValues(alpha: widget.opacity),
                    AppTheme.accentGreen.withValues(
                      alpha: widget.opacity * 0.5,
                    ),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            );
          },
        ),
        CustomPaint(
          painter: _ParticlesPainter(
            animation: _gradientAnimation,
            opacity: widget.opacity,
          ),
          size: Size.infinite,
        ),
        widget.child,
      ],
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter({required this.animation, this.opacity = 0.06});

  final Animation<double> animation;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: opacity)
      ..strokeWidth = 1;
    const count = 40;
    final rng = math.Random(42);
    for (var i = 0; i < count; i++) {
      final x =
          (rng.nextDouble() * size.width + animation.value * 50) %
              (size.width + 50) -
          25;
      final y =
          (rng.nextDouble() * size.height + animation.value * 30 * (i % 3)) %
              (size.height + 30) -
          15;
      canvas.drawCircle(Offset(x, y), 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.animation.value != animation.value;
}
