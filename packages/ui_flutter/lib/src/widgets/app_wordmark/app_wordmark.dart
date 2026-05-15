import 'package:flutter/widgets.dart';

import '../../theme/tokens.g.dart';
import '../app_swash/app_swash.dart';

/// Brand wordmark lockup — Forum "CORIOLIS" uppercase + brass swash + Inter
/// "COMPANION" eyebrow. Flutter mirror of `@app/ui` `AppWordmark`.
///
/// Used by the landing hero, dashboard hero, and the session-join card. The
/// [size] prop controls the brand font-size in logical pixels; the eyebrow
/// auto-scales at `size × 0.18` (floored at 10) and the swash at `size × 2.4`.
///
/// Handoff reference: `primitives.jsx:L263-L290` + `COMPONENTS.md:L75-L80`.
///
/// The lockup exposes a single header semantics node with the combined
/// accessible name `"$brand $eyebrow"` so assistive tech reads the brand as one
/// unit rather than two disconnected strings.
class AppWordmark extends StatelessWidget {
  const AppWordmark({
    super.key,
    this.size = 48.0,
    this.brand = 'Coriolis',
    this.eyebrow = 'Companion',
  });

  /// Brand font-size in logical pixels. Handoff defaults: 48 (compact),
  /// 88 (landing hero). Eyebrow + swash auto-scale.
  final double size;

  /// Brand text — defaults to `"Coriolis"`. Override for stress-tests only.
  final String brand;

  /// Eyebrow text — defaults to `"Companion"`. Localizable.
  final String eyebrow;

  /// Eyebrow / brand size ratio from the handoff (`size × 0.18`).
  static const double _eyebrowRatio = 0.18;

  /// Swash / brand width ratio from the handoff (`size × 2.4`).
  static const double _swashRatio = 2.4;

  /// Floor for eyebrow font-size so tiny lockups stay legible.
  static const double _eyebrowMinPx = 10.0;

  double get _eyebrowSize {
    final scaled = size * _eyebrowRatio;
    return scaled < _eyebrowMinPx ? _eyebrowMinPx : scaled;
  }

  double get _swashWidth => size * _swashRatio;

  @override
  Widget build(BuildContext context) {
    final brandStyle = TextStyle(
      fontFamily: AppFontFamily.display,
      fontSize: size,
      fontWeight: AppFontWeight.regular,
      height: 1.0,
      letterSpacing: 0.1 * size,
      color: AppColors.brandBrassLight,
    );

    final eyebrowStyle = TextStyle(
      fontFamily: AppFontFamily.body,
      fontSize: _eyebrowSize,
      fontWeight: AppFontWeight.regular,
      height: 1.0,
      letterSpacing: 0.4 * _eyebrowSize,
      color: AppColors.brandBrass,
    );

    return Semantics(
      header: true,
      label: '$brand $eyebrow',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(brand.toUpperCase(), style: brandStyle),
          const SizedBox(height: AppSpacing.s1),
          AppSwash(width: _swashWidth),
          const SizedBox(height: AppSpacing.s1),
          // Pad the trailing edge by the tracking advance so the eyebrow stays
          // optically centred under the swash (mirrors the Vue `text-indent`).
          Padding(
            padding: EdgeInsets.only(left: 0.4 * _eyebrowSize),
            child: Text(eyebrow.toUpperCase(), style: eyebrowStyle),
          ),
        ],
      ),
    );
  }
}
