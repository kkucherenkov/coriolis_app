import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';
import '../app_badge/app_badge.dart' show AppBadgeTone;

/// Visual size of each dot.
enum AppDotsSize { sm, md, lg }

/// Rank meter — a horizontal row of [max] dots, [value] filled.
///
/// Used for stat blocks (attribute/skill ranks). Mirrors DESIGN §6.3 / §11.1
/// AppDots with `aria-valuenow` / `aria-valuemax` equivalents via [Semantics].
class AppDots extends StatelessWidget {
  const AppDots({
    super.key,
    required this.value,
    this.max = 5,
    this.size = AppDotsSize.md,
    this.tone = AppBadgeTone.brass,
    this.label,
  }) : assert(value >= 0, 'value must be >= 0'),
       assert(max > 0, 'max must be > 0'),
       assert(value <= max, 'value must be <= max');

  final int value;
  final int max;
  final AppDotsSize size;
  final AppBadgeTone tone;

  /// Optional accessible label, e.g. "Strength". Combines with the value/max
  /// semantic annotation.
  final String? label;

  double get _dotSize => switch (size) {
        AppDotsSize.sm => 8.0,
        AppDotsSize.md => 12.0,
        AppDotsSize.lg => 16.0,
      };

  double get _gap => switch (size) {
        AppDotsSize.sm => 3.0,
        AppDotsSize.md => 4.0,
        AppDotsSize.lg => 5.0,
      };

  Color get _filledColor => switch (tone) {
        AppBadgeTone.brass => AppColors.brandBrass,
        AppBadgeTone.mystic => AppColors.stateMysticTeal,
        AppBadgeTone.crimson => AppColors.stateCrimson,
        AppBadgeTone.success => AppColors.stateSuccess,
        AppBadgeTone.darkness => AppColors.stateDarkness,
      };

  Color get _emptyColor => AppColors.surfaceDawn;

  @override
  Widget build(BuildContext context) {
    final semanticValue = '${label ?? ''} $value of $max'.trim();

    return Semantics(
      label: semanticValue,
      // maxValueLength maps to aria-valuemax; value maps to aria-valuenow.
      value: value.toString(),
      maxValueLength: max,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(max, (index) {
          final filled = index < value;
          return Padding(
            padding: EdgeInsets.only(right: index < max - 1 ? _gap : 0),
            child: AnimatedContainer(
              duration: AppDuration.fast,
              curve: AppEasing.standard,
              width: _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                color: filled ? _filledColor : _emptyColor,
                shape: BoxShape.circle,
                border: filled
                    ? null
                    : Border.all(color: AppColors.brandBrassShadow),
              ),
            ),
          );
        }),
      ),
    );
  }
}
