import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';
import '../app_badge/app_badge.dart' show AppBadgeTone;

/// Size variants for the progress bar height.
enum AppProgressSize { sm, md, lg }

/// Linear progress bar. Mirrors Vue AppProgress: [value]/[max], five [tone]s,
/// three [size]s.
class AppProgress extends StatelessWidget {
  const AppProgress({
    super.key,
    required this.value,
    this.max = 100.0,
    this.tone = AppBadgeTone.brass,
    this.size = AppProgressSize.md,
    this.semanticLabel,
  }) : assert(value >= 0, 'value must be >= 0'),
       assert(max > 0, 'max must be > 0');

  final double value;
  final double max;
  final AppBadgeTone tone;
  final AppProgressSize size;
  final String? semanticLabel;

  double get _fraction => (value / max).clamp(0.0, 1.0);

  double get _height => switch (size) {
        AppProgressSize.sm => 4.0,
        AppProgressSize.md => 8.0,
        AppProgressSize.lg => 12.0,
      };

  Color get _fillColor => switch (tone) {
        AppBadgeTone.brass => AppColors.brandBrass,
        AppBadgeTone.mystic => AppColors.stateMysticTeal,
        AppBadgeTone.crimson => AppColors.stateCrimson,
        AppBadgeTone.success => AppColors.stateSuccess,
        AppBadgeTone.darkness => AppColors.stateDarkness,
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: '${(value).toStringAsFixed(0)} of ${max.toStringAsFixed(0)}',
      label: semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackW = constraints.maxWidth;
          return Container(
            height: _height,
            decoration: BoxDecoration(
              color: AppColors.surfaceDawn,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: AppDuration.dDefault,
                  curve: AppEasing.standard,
                  width: trackW * _fraction,
                  height: _height,
                  decoration: BoxDecoration(
                    color: _fillColor,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
