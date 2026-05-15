import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/tokens.g.dart';

/// Coriolis Icon medallion — Forum monogram letter inside a radial-gradient
/// brass disc with concentric astrolabe rings and 16 tick marks. Flutter
/// mirror of `@app/ui` `AppIconMedallion`.
///
/// Used by the wizard "Pick your Icon" step (step 5 in the canonical 8-step
/// inventory) and any "chosen Icon" hero treatment.
///
/// Handoff reference: `primitives.jsx:L54-L100` + `COMPONENTS.md:L45-L55`.
///
/// **Distinct from any `AppIconCoriolis` sprite** — this widget renders the
/// Nine Icons as a monogram letter on a brass medallion, the celebratory
/// presentation used in the wizard. Consumers pick by surface (sprite for
/// inline / dense, medallion for hero / picker).
class AppIconMedallion extends StatelessWidget {
  const AppIconMedallion({
    super.key,
    required this.letter,
    this.size = 64.0,
    this.glow = false,
    this.semanticsLabel,
  });

  /// Single-letter monogram of the Nine Icons (e.g. `"T"` for The Traveler).
  final String letter;

  /// Medallion diameter in logical pixels. Handoff defaults: 48 / 56 / 60 / 64.
  final double size;

  /// When `true`, layers a mystic-teal halo to mark the selected Icon.
  final bool glow;

  /// Accessible label, e.g. `"The Traveler"`. When omitted the medallion is
  /// decorative and hidden from semantics.
  final String? semanticsLabel;

  /// Halo expansion outside the disc — handoff `inset: -6` for any size.
  static const double _haloInset = 6.0;

  @override
  Widget build(BuildContext context) {
    final letterStyle = TextStyle(
      fontFamily: AppFontFamily.display,
      fontSize: size * 0.5,
      fontWeight: AppFontWeight.regular,
      height: 1.0,
      letterSpacing: 0.04 * (size * 0.5),
      color: AppColors.surfaceVoid,
    );

    final medallion = SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (glow)
            Positioned(
              left: -_haloInset,
              top: -_haloInset,
              right: -_haloInset,
              bottom: -_haloInset,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.iconGlow,
                  gradient: RadialGradient(
                    radius: 0.5,
                    colors: [
                      AppColors.stateMysticTeal.withValues(alpha: 0.25),
                      AppColors.stateMysticTeal.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
          CustomPaint(size: Size(size, size), painter: _MedallionPainter()),
          Padding(
            // Mirror the Vue letter's `y=40` (slightly below centre on a 64
            // viewBox) so the Forum glyph optically lands on the disc axis.
            padding: EdgeInsets.only(top: size * 0.04),
            child: Text(letter, style: letterStyle),
          ),
        ],
      ),
    );

    final hasLabel = semanticsLabel != null && semanticsLabel!.isNotEmpty;
    return Semantics(
      image: hasLabel,
      label: hasLabel ? semanticsLabel : null,
      // The Forum monogram is a visual cue; the combined accessible name is
      // the Icon's full name ("The Traveler"), so the child Text never reads
      // separately. Exclude descendant semantics in both states.
      excludeSemantics: true,
      child: medallion,
    );
  }
}

/// Paints the brass disc + concentric astrolabe rings + 16 tick marks. All
/// colours come from [AppColors]; no hex literals.
class _MedallionPainter extends CustomPainter {
  static const double _viewBox = 64.0;
  static const double _cx = 32.0;
  static const double _cy = 32.0;
  static const double _discRadius = 30.0;
  static const double _outerRing = 28.0;
  static const double _innerRing = 24.0;
  static const double _tickInner = 26.0;
  static const int _tickCount = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    canvas.save();
    canvas.scale(scale);

    final discRect = Rect.fromCircle(
      center: const Offset(_cx, _cy),
      radius: _discRadius,
    );
    final discPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.2),
        radius: 0.6,
        colors: [
          AppColors.brandBrassLight,
          AppColors.brandBrass,
          AppColors.brandBrassDeep,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(discRect);
    canvas.drawCircle(const Offset(_cx, _cy), _discRadius, discPaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.brandBrassShadow
      ..strokeWidth = 0.6;
    canvas.drawCircle(const Offset(_cx, _cy), _outerRing, ringPaint);

    final innerRingPaint = Paint.from(ringPaint)..strokeWidth = 0.4;
    canvas.drawCircle(const Offset(_cx, _cy), _innerRing, innerRingPaint);

    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.brandBrassShadow
      ..strokeWidth = 0.5;
    for (var i = 0; i < _tickCount; i++) {
      final angle = (i / _tickCount) * math.pi * 2;
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);
      canvas.drawLine(
        Offset(_cx + cosA * _outerRing, _cy + sinA * _outerRing),
        Offset(_cx + cosA * _tickInner, _cy + sinA * _tickInner),
        tickPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_MedallionPainter oldDelegate) => false;
}
