import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Tone options for the divider line color.
enum AppDividerTone { brassDeep, brassShadow, brass }

/// Weight controls the pixel thickness of the line.
enum AppDividerWeight {
  /// 1 logical pixel — lightest.
  hairline,

  /// 1 logical pixel — standard.
  thin,

  /// 2 logical pixels — medium emphasis.
  medium,
}

/// Horizontal divider line.
///
/// [tone] controls color; [weight] controls thickness; [inset] adds horizontal
/// padding so the line doesn't reach the container edges.
class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.tone = AppDividerTone.brassDeep,
    this.weight = AppDividerWeight.thin,
    this.inset = false,
  });

  final AppDividerTone tone;
  final AppDividerWeight weight;
  final bool inset;

  Color get _color => switch (tone) {
        AppDividerTone.brassDeep => AppColors.brandBrassDeep,
        AppDividerTone.brassShadow => AppColors.brandBrassShadow,
        AppDividerTone.brass => AppColors.brandBrass,
      };

  double get _thickness => switch (weight) {
        AppDividerWeight.hairline => 1.0,
        AppDividerWeight.thin => 1.0,
        AppDividerWeight.medium => 2.0,
      };

  @override
  Widget build(BuildContext context) {
    Widget line = Container(
      height: _thickness,
      color: _color,
    );

    if (inset) {
      line = Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
        child: line,
      );
    }

    return line;
  }
}
