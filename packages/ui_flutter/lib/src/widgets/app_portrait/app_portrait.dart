import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/tokens.g.dart';

/// Character portrait medallion — Forum initials inside a brass-rimmed
/// indigo disc with 24 concentric astrolabe ticks. Flutter mirror of
/// `@app/ui` `AppPortrait`.
///
/// Used as the canonical character / NPC portrait across the sheet hero,
/// combat tracker, GM crew list, and chat bubbles. Distinct from any
/// generic avatar — this atom never carries an image and always renders
/// the indigo + brass treatment.
///
/// Handoff reference: `primitives.jsx:L202-L224` + `COMPONENTS.md:L64-L73`.
class AppPortrait extends StatelessWidget {
  const AppPortrait({
    super.key,
    this.name,
    this.initials,
    this.size = 96.0,
    this.semanticsLabel,
  });

  /// Display name used to derive initials when [initials] is omitted.
  final String? name;

  /// Explicit initials override (e.g. `"NA"`). Trimmed to the first 2 chars.
  final String? initials;

  /// Medallion diameter in logical pixels. Handoff default: 96.
  final double size;

  /// Accessible label override. Falls back to [name], then to the initials.
  final String? semanticsLabel;

  /// Initials font-size ratio relative to disc diameter (handoff: 0.36).
  static const double _initialsRatio = 0.36;

  /// Count of astrolabe ticks ringing the disc (handoff: 24).
  static const int _tickCount = 24;

  String get _resolvedInitials {
    final override = initials?.trim();
    if (override != null && override.isNotEmpty) {
      // Take up to the first two code-point characters.
      final chars = override.runes.toList();
      return String.fromCharCodes(chars.take(2)).toUpperCase();
    }
    final trimmedName = name?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      final words = trimmedName.split(RegExp(r'\s+'));
      final firsts = words.take(2).map((w) {
        final runes = w.runes.toList();
        return runes.isEmpty ? '' : String.fromCharCode(runes.first);
      });
      return firsts.join().toUpperCase();
    }
    return 'NA';
  }

  String get _resolvedLabel =>
      semanticsLabel ??
      (name != null && name!.isNotEmpty ? name! : _resolvedInitials);

  @override
  Widget build(BuildContext context) {
    final initialsStyle = TextStyle(
      fontFamily: AppFontFamily.display,
      fontSize: size * _initialsRatio,
      fontWeight: AppFontWeight.regular,
      height: 1.0,
      letterSpacing: 0.04 * (size * _initialsRatio),
      color: AppColors.brandBrassLight,
    );

    return Semantics(
      image: true,
      label: _resolvedLabel,
      // The Forum initials are a visual cue; the medallion already speaks
      // the player / NPC name through its label.
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Handoff: linear 160deg dawn → night → void.
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(160 * math.pi / 180.0),
              colors: [
                AppColors.surfaceDawn,
                AppColors.surfaceNight,
                AppColors.surfaceVoid,
              ],
              stops: [0.0, 0.6, 1.0],
            ),
            border: Border.fromBorderSide(
              BorderSide(color: AppColors.brandBrassDeep, width: 1.0),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandBrassShadow,
                blurRadius: 0.0,
                spreadRadius: -1.0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _PortraitRingPainter(),
              ),
              Text(_resolvedInitials, style: initialsStyle),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints the brass outer-ring circle + 24 astrolabe tick marks. All colours
/// come from [AppColors]; no hex literals.
class _PortraitRingPainter extends CustomPainter {
  static const double _viewBox = 100.0;
  static const double _cx = 50.0;
  static const double _cy = 50.0;
  static const double _ringRadius = 46.0;
  static const double _tickInner = 43.0;
  static const int _tickCount = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    canvas.save();
    canvas.scale(scale);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.brandBrassDeep
      ..strokeWidth = 0.4;
    canvas.drawCircle(const Offset(_cx, _cy), _ringRadius, strokePaint);

    for (var i = 0; i < _tickCount; i++) {
      final angle = (i / _tickCount) * math.pi * 2;
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);
      canvas.drawLine(
        Offset(_cx + cosA * _ringRadius, _cy + sinA * _ringRadius),
        Offset(_cx + cosA * _tickInner, _cy + sinA * _tickInner),
        strokePaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PortraitRingPainter oldDelegate) => false;
}
