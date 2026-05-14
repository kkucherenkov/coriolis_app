import 'package:flutter/widgets.dart';

import '../../theme/tokens.g.dart';
import '../app_badge/app_badge.dart' show AppBadgeTone;
import '../app_dots/app_dots.dart';

/// Visual tone for [AppSkillRow] — colours the attribute eyebrow and the
/// underlying dot meter. `brass` for general skills, `mystic` for advanced.
enum AppSkillRowTone { brass, mystic }

/// Dense skill row — `name + attr eyebrow + dot row + monospace rank`.
/// Flutter mirror of `@app/ui` `AppSkillRow`.
///
/// Used inside the character-sheet Skills card (desktop + mobile) and wizard
/// step 6 (Skills).
///
/// Handoff reference: `primitives.jsx:L165-L181` + `COMPONENTS.md:L96-L103`.
///
/// The [nameBuilder] override lets callers inject in-line decorations (e.g.
/// the "key" chip on advanced key-skills); the default fallback renders
/// [name] as plain body text. Surface decorations that depend on parent
/// context — for instance the teal accent rail on the Advanced column —
/// stay with the consumer so this atom remains composable.
class AppSkillRow extends StatelessWidget {
  const AppSkillRow({
    super.key,
    required this.name,
    required this.attr,
    required this.rank,
    this.rankMax = 5,
    this.tone = AppSkillRowTone.brass,
    this.nameBuilder,
  }) : assert(rankMax > 0, 'rankMax must be > 0');

  /// Skill name, e.g. `"Pilot"`. Overridable via [nameBuilder].
  final String name;

  /// Attribute eyebrow, e.g. `"Agility"`. Rendered uppercase.
  final String attr;

  /// Rank — number of filled dots (`0`…`rankMax`). Clamped on render.
  final int rank;

  /// Total dots in the meter. Defaults to the rulebook cap of `5`.
  final int rankMax;

  /// Visual tone (brass for general, mystic for advanced).
  final AppSkillRowTone tone;

  /// Optional builder for rich name content (e.g. inline chips).
  final WidgetBuilder? nameBuilder;

  /// Eyebrow font-size in logical pixels (handoff: 10px).
  static const double _attrFontSize = 10.0;

  /// Monospace rank font-size in logical pixels (handoff: 14px).
  static const double _rankFontSize = 14.0;

  /// Right-aligned rank column minimum width (handoff: 14px).
  static const double _rankMinWidth = 14.0;

  /// Minimum tap target — WCAG 2.5.5 (44×44). The row itself isn't tappable
  /// in the v1 sheet, but the height floor keeps the dot meter reachable
  /// when callers wrap the row in a `GestureDetector` for edit affordance.
  static const double _minRowHeight = 44.0;

  int get _clampedRank => rank.clamp(0, rankMax);

  AppBadgeTone get _dotsTone => switch (tone) {
    AppSkillRowTone.brass => AppBadgeTone.brass,
    AppSkillRowTone.mystic => AppBadgeTone.mystic,
  };

  Color get _attrColor => switch (tone) {
    AppSkillRowTone.brass => AppColors.brandBrass,
    AppSkillRowTone.mystic => AppColors.stateMysticTeal,
  };

  Color get _dividerColor => switch (tone) {
    AppSkillRowTone.brass => AppColors.brandBrassDeep.withValues(alpha: 0.25),
    AppSkillRowTone.mystic => AppColors.stateMysticTeal.withValues(alpha: 0.25),
  };

  @override
  Widget build(BuildContext context) {
    final nameStyle = TextStyle(
      fontFamily: AppFontFamily.body,
      fontSize: 14.0,
      fontWeight: AppFontWeight.regular,
      height: 1.0,
      color: AppColors.textPrimary,
    );

    final attrStyle = TextStyle(
      fontFamily: AppFontFamily.body,
      fontSize: _attrFontSize,
      fontWeight: AppFontWeight.medium,
      height: 1.0,
      letterSpacing: 0.1 * _attrFontSize,
      color: _attrColor,
    );

    final rankStyle = TextStyle(
      fontFamily: AppFontFamily.mono,
      fontSize: _rankFontSize,
      fontWeight: AppFontWeight.medium,
      height: 1.0,
      color: AppColors.textPrimary,
    );

    final semanticLabel = '$name, $attr, $_clampedRank of $rankMax';

    return Semantics(
      container: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minRowHeight),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s1,
            vertical: AppSpacing.s2,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: _dividerColor, width: 1.0),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: nameBuilder != null
                    ? nameBuilder!(context)
                    : Text(
                        name,
                        style: nameStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Text(attr.toUpperCase(), style: attrStyle),
              const SizedBox(width: AppSpacing.s3),
              AppDots(
                value: _clampedRank,
                max: rankMax,
                size: AppDotsSize.sm,
                tone: _dotsTone,
                label: name,
              ),
              const SizedBox(width: AppSpacing.s3),
              SizedBox(
                width: _rankMinWidth,
                child: Text(
                  '$_clampedRank',
                  style: rankStyle,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
