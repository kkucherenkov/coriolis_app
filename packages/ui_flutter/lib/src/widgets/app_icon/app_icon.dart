import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Icon sizes matching the Vue AppIcon size variants.
enum AppIconSize {
  xs, // 12 px
  sm, // 16 px
  md, // 20 px
  lg, // 24 px
  xl, // 32 px
}

/// Color tones for AppIcon.
enum AppIconColor {
  brass,
  mystic,
  crimson,
  success,
  darkness,
  inherit,
}

/// Coriolis-tokenized icon wrapper.
///
/// Renders icons as [CustomPaint] using a static set of built-in Coriolis
/// stroke icons (sword, shield, heart, star, zap, cog, eye, info, check,
/// alert-triangle, alert-octagon, x, plus, minus, chevron-down, chevron-up,
/// chevron-right, chevron-left, user, clock).
///
/// Using [CustomPaint] over a third-party icon font eliminates any external
/// dependency while keeping every icon on-token. Add new icons to [_iconMap]
/// as the app requires them.
///
/// - [name] — kebab-case icon name (e.g. `'check-circle'`).
/// - [size] — [AppIconSize] variant; maps to a fixed px dimension.
/// - [color] — [AppIconColor] tone; defaults to [AppIconColor.brass].
/// - [strokeWidth] — forwarded to every icon path; default `1.5`.
/// - [semanticLabel] — if set, wraps in [Semantics] with `label`; otherwise
///   the icon is decorative (`excludeSemantics: true`).
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.name,
    this.size = AppIconSize.md,
    this.color = AppIconColor.brass,
    this.strokeWidth = 1.5,
    this.semanticLabel,
  });

  final String name;
  final AppIconSize size;
  final AppIconColor color;
  final double strokeWidth;
  final String? semanticLabel;

  static const Map<AppIconSize, double> _sizePx = {
    AppIconSize.xs: 12,
    AppIconSize.sm: 16,
    AppIconSize.md: 20,
    AppIconSize.lg: 24,
    AppIconSize.xl: 32,
  };

  Color _resolveColor() => switch (color) {
        AppIconColor.brass => AppColors.brandBrass,
        AppIconColor.mystic => AppColors.stateMysticTeal,
        AppIconColor.crimson => AppColors.stateCrimson,
        AppIconColor.success => AppColors.stateSuccess,
        AppIconColor.darkness => AppColors.stateDarkness,
        AppIconColor.inherit => AppColors.textPrimary,
      };

  @override
  Widget build(BuildContext context) {
    final px = _sizePx[size]!;
    final painter = _AppIconPainter(
      name: name,
      color: _resolveColor(),
      strokeWidth: strokeWidth,
    );
    final icon = SizedBox(
      width: px,
      height: px,
      child: CustomPaint(painter: painter),
    );

    if (semanticLabel != null) {
      return Semantics(label: semanticLabel, child: icon);
    }
    return ExcludeSemantics(child: icon);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

/// Draws the named icon onto a [Canvas].  All paths are defined in a 24×24
/// viewport and are scaled to whatever [size] is provided.
class _AppIconPainter extends CustomPainter {
  const _AppIconPainter({
    required this.name,
    required this.color,
    required this.strokeWidth,
  });

  final String name;
  final Color color;
  final double strokeWidth;

  static final Map<String, _IconDrawFn> _iconMap = {
    'sword': _drawSword,
    'shield': _drawShield,
    'heart': _drawHeart,
    'star': _drawStar,
    'zap': _drawZap,
    'cog': _drawCog,
    'eye': _drawEye,
    'info': _drawInfo,
    'info-circle': _drawInfoCircle,
    'check': _drawCheck,
    'check-circle': _drawCheckCircle,
    'triangle-alert': _drawTriangleAlert,
    'octagon-alert': _drawOctagonAlert,
    'x': _drawX,
    'plus': _drawPlus,
    'minus': _drawMinus,
    'chevron-down': _drawChevronDown,
    'chevron-up': _drawChevronUp,
    'chevron-right': _drawChevronRight,
    'chevron-left': _drawChevronLeft,
    'user': _drawUser,
    'clock': _drawClock,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final drawFn = _iconMap[name];
    if (drawFn != null) {
      drawFn(canvas, paint);
    } else {
      // Fallback: question-mark box.
      _drawFallback(canvas, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_AppIconPainter old) =>
      old.name != name || old.color != color || old.strokeWidth != strokeWidth;
}

typedef _IconDrawFn = void Function(Canvas canvas, Paint paint);

// ── Icon path implementations (24×24 viewport) ───────────────────────────────

void _drawSword(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(14.5, 17.5)
    ..lineTo(19, 22)
    ..lineTo(22, 19)
    ..lineTo(17.5, 14.5)
    ..moveTo(2, 12)
    ..lineTo(12, 2)
    ..lineTo(22, 12)
    ..lineTo(12, 22)
    ..close()
    ..moveTo(2, 2)
    ..lineTo(7, 7);
  c.drawPath(path, p);
}

void _drawShield(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(12, 2)
    ..lineTo(20, 6)
    ..lineTo(20, 12)
    ..cubicTo(20, 17, 16, 21, 12, 22)
    ..cubicTo(8, 21, 4, 17, 4, 12)
    ..lineTo(4, 6)
    ..close();
  c.drawPath(path, p);
}

void _drawHeart(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(12, 21)
    ..cubicTo(12, 21, 3, 14, 3, 8.5)
    ..cubicTo(3, 5.42, 5.42, 3, 8.5, 3)
    ..cubicTo(10.24, 3, 11.91, 3.81, 13, 5.08)
    ..cubicTo(14.09, 3.81, 15.76, 3, 17.5, 3)
    ..cubicTo(20.58, 3, 23, 5.42, 23, 8.5)
    ..cubicTo(23, 14, 14, 21, 12, 21)
    ..close();
  c.drawPath(path, p);
}

void _drawStar(Canvas c, Paint p) {
  // 5-pointed star
  const cx = 12.0, cy = 12.0, outerR = 10.0, innerR = 4.0;
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? outerR : innerR;
    final angle = (3.14159 * i / 5) - 3.14159 / 2;
    final x = cx + r * _cos(angle);
    final y = cy + r * _sin(angle);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  c.drawPath(path, p);
}

void _drawZap(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(13, 2)
    ..lineTo(3, 14)
    ..lineTo(12, 14)
    ..lineTo(11, 22)
    ..lineTo(21, 10)
    ..lineTo(12, 10)
    ..close();
  c.drawPath(path, p);
}

void _drawCog(Canvas c, Paint p) {
  c.drawCircle(const Offset(12, 12), 3, p);
  final outerPath = Path();
  for (var i = 0; i < 8; i++) {
    final angle = (3.14159 * i / 4);
    final innerX = 12 + 4.5 * _cos(angle);
    final innerY = 12 + 4.5 * _sin(angle);
    final outerX = 12 + 6.5 * _cos(angle);
    final outerY = 12 + 6.5 * _sin(angle);
    outerPath
      ..moveTo(innerX, innerY)
      ..lineTo(outerX, outerY);
  }
  c.drawPath(outerPath, p);
}

void _drawEye(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(1, 12)
    ..cubicTo(1, 12, 5, 5, 12, 5)
    ..cubicTo(19, 5, 23, 12, 23, 12)
    ..cubicTo(23, 12, 19, 19, 12, 19)
    ..cubicTo(5, 19, 1, 12, 1, 12)
    ..close();
  c.drawPath(path, p);
  c.drawCircle(const Offset(12, 12), 3, p);
}

void _drawInfo(Canvas c, Paint p) {
  // Dot — rendered as a filled circle so no strokeWidth mutation needed.
  final dotPaint = Paint()
    ..color = p.color
    ..style = PaintingStyle.fill;
  c.drawCircle(const Offset(12, 8), p.strokeWidth * 0.8, dotPaint);
  c.drawLine(const Offset(12, 11), const Offset(12, 17), p);
}

void _drawInfoCircle(Canvas c, Paint p) {
  c.drawCircle(const Offset(12, 12), 10, p);
  // dot at top
  final dotPaint = Paint()
    ..color = p.color
    ..style = PaintingStyle.fill;
  c.drawCircle(const Offset(12, 8), p.strokeWidth * 0.7, dotPaint);
  c.drawLine(const Offset(12, 11), const Offset(12, 17), p);
}

void _drawCheck(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(4, 12)
    ..lineTo(9, 17)
    ..lineTo(20, 7);
  c.drawPath(path, p);
}

void _drawCheckCircle(Canvas c, Paint p) {
  c.drawCircle(const Offset(12, 12), 10, p);
  final path = Path()
    ..moveTo(7, 12)
    ..lineTo(10, 15)
    ..lineTo(17, 9);
  c.drawPath(path, p);
}

void _drawTriangleAlert(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(12, 2)
    ..lineTo(22, 21)
    ..lineTo(2, 21)
    ..close();
  c.drawPath(path, p);
  c.drawLine(const Offset(12, 9), const Offset(12, 14), p);
  final dotPaint = Paint()
    ..color = p.color
    ..style = PaintingStyle.fill;
  c.drawCircle(const Offset(12, 17.5), p.strokeWidth * 0.7, dotPaint);
}

void _drawOctagonAlert(Canvas c, Paint p) {
  final path = Path();
  for (var i = 0; i < 8; i++) {
    final angle = (3.14159 * i / 4) - (3.14159 / 8);
    final x = 12 + 9 * _cos(angle);
    final y = 12 + 9 * _sin(angle);
    if (i == 0) path.moveTo(x, y);
    else path.lineTo(x, y);
  }
  path.close();
  c.drawPath(path, p);
  c.drawLine(const Offset(12, 8), const Offset(12, 13), p);
  final dotPaint = Paint()
    ..color = p.color
    ..style = PaintingStyle.fill;
  c.drawCircle(const Offset(12, 16.5), p.strokeWidth * 0.7, dotPaint);
}

void _drawX(Canvas c, Paint p) {
  c.drawLine(const Offset(4, 4), const Offset(20, 20), p);
  c.drawLine(const Offset(20, 4), const Offset(4, 20), p);
}

void _drawPlus(Canvas c, Paint p) {
  c.drawLine(const Offset(12, 4), const Offset(12, 20), p);
  c.drawLine(const Offset(4, 12), const Offset(20, 12), p);
}

void _drawMinus(Canvas c, Paint p) {
  c.drawLine(const Offset(4, 12), const Offset(20, 12), p);
}

void _drawChevronDown(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(6, 9)
    ..lineTo(12, 15)
    ..lineTo(18, 9);
  c.drawPath(path, p);
}

void _drawChevronUp(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(6, 15)
    ..lineTo(12, 9)
    ..lineTo(18, 15);
  c.drawPath(path, p);
}

void _drawChevronRight(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(9, 6)
    ..lineTo(15, 12)
    ..lineTo(9, 18);
  c.drawPath(path, p);
}

void _drawChevronLeft(Canvas c, Paint p) {
  final path = Path()
    ..moveTo(15, 6)
    ..lineTo(9, 12)
    ..lineTo(15, 18);
  c.drawPath(path, p);
}

void _drawUser(Canvas c, Paint p) {
  c.drawCircle(const Offset(12, 8), 4, p);
  final path = Path()
    ..moveTo(4, 21)
    ..cubicTo(4, 17, 7.58, 14, 12, 14)
    ..cubicTo(16.42, 14, 20, 17, 20, 21);
  c.drawPath(path, p);
}

void _drawClock(Canvas c, Paint p) {
  c.drawCircle(const Offset(12, 12), 10, p);
  final path = Path()
    ..moveTo(12, 7)
    ..lineTo(12, 12)
    ..lineTo(16, 14);
  c.drawPath(path, p);
}

void _drawFallback(Canvas c, Paint p) {
  c.drawRect(const Rect.fromLTWH(3, 3, 18, 18), p);
  c.drawLine(const Offset(9, 9), const Offset(15, 15), p);
}

// Minimal trig helpers to avoid dart:math import in widget layer.
double _cos(double rad) {
  // Taylor series approximation good enough for icon paths.
  rad = rad % (2 * 3.14159265358979);
  double result = 1.0;
  double term = 1.0;
  for (var n = 1; n <= 8; n++) {
    term *= -rad * rad / ((2 * n - 1) * (2 * n));
    result += term;
  }
  return result;
}

double _sin(double rad) {
  rad = rad % (2 * 3.14159265358979);
  double result = rad;
  double term = rad;
  for (var n = 1; n <= 8; n++) {
    term *= -rad * rad / ((2 * n) * (2 * n + 1));
    result += term;
  }
  return result;
}
