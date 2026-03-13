import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum LogoSize { small, medium, large }

/// Logo CinePass : icône billets + texte, utilisé dans l'app bar et le drawer.
class CinePassLogo extends StatelessWidget {
  const CinePassLogo({super.key, this.size = LogoSize.small});

  final LogoSize size;

  double get _iconSize {
    switch (size) {
      case LogoSize.small:
        return 28;
      case LogoSize.medium:
        return 40;
      case LogoSize.large:
        return 52;
    }
  }

  double get _fontSize {
    switch (size) {
      case LogoSize.small:
        return 20;
      case LogoSize.medium:
        return 24;
      case LogoSize.large:
        return 28;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LogoIcon(size: _iconSize),
        SizedBox(width: size == LogoSize.small ? 8 : 12),
        Text(
          'CinePass',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: _fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _LogoIcon extends StatelessWidget {
  const _LogoIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TicketLogoPainter(),
        size: Size(size, size),
      ),
    );
  }
}

/// Icône type billet de cinéma (forme ticket).
class _TicketLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryRed
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final r = w * 0.22;

    final path = Path();
    path.moveTo(r, 0);
    path.lineTo(w - r, 0);
    path.arcTo(
      Rect.fromCircle(center: Offset(w - r, r), radius: r),
      -0.5 * 3.14159,
      3.14159,
      false,
    );
    path.lineTo(w, h - r);
    path.arcTo(
      Rect.fromCircle(center: Offset(w - r, h - r), radius: r),
      0,
      3.14159,
      false,
    );
    path.lineTo(r, h);
    path.arcTo(
      Rect.fromCircle(center: Offset(r, h - r), radius: r),
      3.14159,
      3.14159,
      false,
    );
    path.lineTo(0, r);
    path.arcTo(
      Rect.fromCircle(center: Offset(r, r), radius: r),
      1.5 * 3.14159,
      3.14159,
      false,
    );
    path.close();
    canvas.drawPath(path, paint);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = size.width * 0.06
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(w * 0.48, h * 0.2),
      Offset(w * 0.48, h * 0.8),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
