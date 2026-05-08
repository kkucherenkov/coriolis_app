import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';
import '../app_badge/app_badge.dart' show AppBadgeTone, AppBadgeSize;

/// Interactive toggle chip. Mirrors the Vue AppChip with [isActive], [onToggle],
/// optional [removable] / [onRemove], and same variant/size surface as [AppBadge].
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.tone = AppBadgeTone.brass,
    this.size = AppBadgeSize.md,
    this.disabled = false,
    this.removable = false,
    this.onToggle,
    this.onRemove,
  });

  final String label;
  final bool isActive;
  final AppBadgeTone tone;
  final AppBadgeSize size;
  final bool disabled;
  final bool removable;
  final VoidCallback? onToggle;
  final VoidCallback? onRemove;

  // ── Colors ──────────────────────────────────────────────────────────────

  Color get _accentColor => switch (tone) {
        AppBadgeTone.brass => AppColors.brandBrass,
        AppBadgeTone.mystic => AppColors.stateMysticTeal,
        AppBadgeTone.crimson => AppColors.stateCrimson,
        AppBadgeTone.success => AppColors.stateSuccess,
        AppBadgeTone.darkness => AppColors.stateDarkness,
      };

  Color get _inactiveTextColor => switch (tone) {
        AppBadgeTone.brass => AppColors.brandBrassLight,
        AppBadgeTone.mystic => AppColors.stateMysticTeal,
        AppBadgeTone.crimson => AppColors.stateCrimsonBright,
        AppBadgeTone.success => AppColors.stateSuccess,
        AppBadgeTone.darkness => AppColors.textPrimary,
      };

  Color get _activeTextColor => switch (tone) {
        AppBadgeTone.brass => AppColors.textOnBrass,
        _ => AppColors.textPrimary,
      };

  Color get _bgColor => isActive
      ? _accentColor
      : const Color(0x00000000);

  Color get _textColor => isActive ? _activeTextColor : _inactiveTextColor;

  // ── Size ─────────────────────────────────────────────────────────────────

  double get _fontSize => size == AppBadgeSize.sm ? 10.0 : 12.0;

  EdgeInsets get _padding => size == AppBadgeSize.sm
      ? const EdgeInsets.symmetric(horizontal: AppSpacing.s2, vertical: 2)
      : const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: 3);

  @override
  Widget build(BuildContext context) {
    final effectiveOpacity = disabled ? AppOpacity.disabled : AppOpacity.o100;

    Widget chip = AnimatedContainer(
      duration: AppDuration.fast,
      curve: AppEasing.standard,
      padding: _padding,
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border.all(color: _accentColor),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              fontSize: _fontSize,
              color: _textColor,
              fontWeight: AppFontWeight.medium,
              height: 1,
            ),
          ),
          if (removable) ...[
            const SizedBox(width: AppSpacing.s1),
            GestureDetector(
              onTap: disabled ? null : onRemove,
              child: Semantics(
                button: true,
                label: 'Remove',
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: Center(
                    child: Text(
                      '×', // ×
                      style: TextStyle(
                        fontFamily: AppFontFamily.body,
                        fontSize: 14,
                        color: _textColor,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    // Ensure minimum 44×44 tap target
    chip = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      child: Center(widthFactor: 1, child: chip),
    );

    return Semantics(
      button: true,
      toggled: isActive,
      enabled: !disabled,
      label: label,
      child: GestureDetector(
        onTap: disabled ? null : onToggle,
        child: Opacity(opacity: effectiveOpacity, child: chip),
      ),
    );
  }
}
