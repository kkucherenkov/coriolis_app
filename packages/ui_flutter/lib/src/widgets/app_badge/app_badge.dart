import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Tones matching the Vue AppBadge / AppChip variant set.
enum AppBadgeTone { brass, mystic, crimson, success, darkness }

/// Decorative label chip. Not interactive — use [AppChip] for toggles.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.tone = AppBadgeTone.brass,
    this.size = AppBadgeSize.md,
  });

  final String label;
  final AppBadgeTone tone;
  final AppBadgeSize size;

  // ── Tone palette ────────────────────────────────────────────────────────

  Color get _borderColor => switch (tone) {
        AppBadgeTone.brass => AppColors.brandBrass,
        AppBadgeTone.mystic => AppColors.stateMysticTeal,
        AppBadgeTone.crimson => AppColors.stateCrimson,
        AppBadgeTone.success => AppColors.stateSuccess,
        AppBadgeTone.darkness => AppColors.stateDarkness,
      };

  Color get _textColor => switch (tone) {
        AppBadgeTone.brass => AppColors.brandBrassLight,
        AppBadgeTone.mystic => AppColors.stateMysticTeal,
        AppBadgeTone.crimson => AppColors.stateCrimsonBright,
        AppBadgeTone.success => AppColors.stateSuccess,
        AppBadgeTone.darkness => AppColors.textPrimary,
      };

  Color get _bgColor => switch (tone) {
        AppBadgeTone.brass => AppColors.brandBrass.withOpacity(0.12),
        AppBadgeTone.mystic => AppColors.stateMysticTeal.withOpacity(0.12),
        AppBadgeTone.crimson => AppColors.stateCrimson.withOpacity(0.12),
        AppBadgeTone.success => AppColors.stateSuccess.withOpacity(0.12),
        AppBadgeTone.darkness => AppColors.stateDarkness.withOpacity(0.30),
      };

  // ── Size geometry ────────────────────────────────────────────────────────

  double get _fontSize => size == AppBadgeSize.sm ? 10.0 : 12.0;

  EdgeInsets get _padding => size == AppBadgeSize.sm
      ? const EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: 2)
      : const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: 3);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTypography.bodySm.copyWith(
          fontSize: _fontSize,
          color: _textColor,
          fontWeight: AppFontWeight.medium,
          height: 1,
        ),
      ),
    );
  }
}

enum AppBadgeSize { sm, md }
