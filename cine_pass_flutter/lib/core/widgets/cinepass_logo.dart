import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum LogoSize { small, medium, large }

/// Icône seule (billet) pour splash avec rotation.
class CinePassLogoIcon extends StatelessWidget {
  const CinePassLogoIcon({super.key, this.size = 56});

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
    _drawTicket(canvas, size, filled: true, lineOpacity: 0.4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dessine un ticket (pour barre de progression).
void _drawTicket(Canvas canvas, Size size,
    {required bool filled, double lineOpacity = 0.4}) {
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

  if (filled) {
    canvas.drawPath(
      path,
      Paint()..color = AppTheme.primaryRed..style = PaintingStyle.fill,
    );
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: lineOpacity)
      ..strokeWidth = size.width * 0.06
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(w * 0.48, h * 0.2),
      Offset(w * 0.48, h * 0.8),
      linePaint,
    );
  } else {
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.primaryRed.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }
}

/// Barre de chargement en forme de tickets qui se remplissent (progress 0 → 1).
class TicketProgressBar extends StatelessWidget {
  const TicketProgressBar({super.key, required this.progress});

  final double progress;

  static const int _count = 5;
  static const double _ticketWidth = 28;
  static const double _ticketHeight = 18;
  static const double _spacing = 6;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_count, (i) {
        final threshold = (i + 1) / _count;
        final filled = progress >= threshold;
        return Padding(
          padding: EdgeInsets.only(right: i < _count - 1 ? _spacing : 0),
          child: SizedBox(
            width: _ticketWidth,
            height: _ticketHeight,
            child: CustomPaint(
              painter: _TicketProgressPainter(filled: filled),
              size: const Size(_ticketWidth, _ticketHeight),
            ),
          ),
        );
      }),
    );
  }
}

class _TicketProgressPainter extends CustomPainter {
  _TicketProgressPainter({required this.filled});

  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    _drawTicket(canvas, size, filled: filled, lineOpacity: 0.5);
  }

  @override
  bool shouldRepaint(covariant _TicketProgressPainter oldDelegate) =>
      oldDelegate.filled != filled;
}
