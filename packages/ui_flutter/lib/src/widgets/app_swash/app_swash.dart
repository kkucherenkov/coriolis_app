import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Stroke colour token for [AppSwash].
enum AppSwashColor { brass, brassDeep, brassLight }

/// Calligraphic underline swash — the Flutter mirror of `@app/ui` `AppSwash`.
///
/// Pairs with [AppPanelTitle] and any Forum display heading ≥ 20 logical px.
/// Decorative — wrapped in [ExcludeSemantics] so screen readers skip it.
///
/// Geometry mirrors `packages/ui/src/components/AppSwash/AppSwash.vue`:
/// a single open stroke with three quadratic curves on a 120×10 internal
/// canvas plus a centre dot at (60, 5).
class AppSwash extends StatelessWidget {
  const AppSwash({
    super.key,
    this.width = 80.0,
    this.color = AppSwashColor.brass,
  });

  /// Rendered width in logical pixels. Height scales proportionally to the
  /// internal 120:10 aspect ratio.
  final double width;

  /// Stroke colour token.
  final AppSwashColor color;

  Color get _color => switch (color) {
        AppSwashColor.brass => AppColors.brandBrass,
        AppSwashColor.brassDeep => AppColors.brandBrassDeep,
        AppSwashColor.brassLight => AppColors.brandBrassLight,
      };

  @override
  Widget build(BuildContext context) {
    final height = width * (10.0 / 120.0);
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(painter: _SwashPainter(color: _color)),
      ),
    );
  }
}

class _SwashPainter extends CustomPainter {
  const _SwashPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 120.0;
    final sy = size.height / 10.0;

    Offset p(double x, double y) => Offset(x * sx, y * sy);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(p(2, 5).dx, p(2, 5).dy)
      ..quadraticBezierTo(p(12, 2).dx, p(12, 2).dy, p(24, 5).dx, p(24, 5).dy)
      ..quadraticBezierTo(p(40, 9).dx, p(40, 9).dy, p(60, 5).dx, p(60, 5).dy)
      ..quadraticBezierTo(p(80, 1).dx, p(80, 1).dy, p(96, 5).dx, p(96, 5).dy)
      ..quadraticBezierTo(
        p(108, 8).dx,
        p(108, 8).dy,
        p(118, 5).dx,
        p(118, 5).dy,
      );
    canvas.drawPath(path, stroke);

    final dot = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(p(60, 5), 1.6 * sy, dot);
  }

  @override
  bool shouldRepaint(covariant _SwashPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
