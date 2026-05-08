import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Visual size for [AppTab].
enum AppTabSize { sm, md }

/// Tone of the active underline for [AppTab].
enum AppTabTone { brass, mystic }

/// Single tab button with Coriolis brass/mystic underline-on-active styling.
///
/// Consumer is responsible for composing a list of [AppTab] widgets in a [Row]
/// — this widget represents a single tab item, mirroring the Vue AppTab.
///
/// Accessibility:
/// - `Semantics(selected: active, button: true, enabled: !disabled)` is applied.
/// - The underline uses [AnimatedContainer] with [AppDuration.fast] /
///   [AppEasing.standard].
class AppTab extends StatelessWidget {
  const AppTab({
    super.key,
    required this.child,
    this.active = false,
    this.disabled = false,
    this.size = AppTabSize.md,
    this.tone = AppTabTone.brass,
    this.iconLeading,
    this.onTap,
  });

  final Widget child;
  final bool active;
  final bool disabled;
  final AppTabSize size;
  final AppTabTone tone;
  final Widget? iconLeading;
  final VoidCallback? onTap;

  // 2 px underline + 3 px gap
  static const double _underlineH = 2.0;
  static const double _underlineGap = 3.0;

  EdgeInsets get _padding => switch (size) {
        AppTabSize.sm => EdgeInsets.fromLTRB(
            AppSpacing.s2,
            AppSpacing.s1,
            AppSpacing.s2,
            AppSpacing.s1 + _underlineGap + _underlineH,
          ),
        AppTabSize.md => EdgeInsets.fromLTRB(
            AppSpacing.s3,
            AppSpacing.s2,
            AppSpacing.s3,
            AppSpacing.s2 + _underlineGap + _underlineH,
          ),
      };

  TextStyle get _textStyle => switch (size) {
        AppTabSize.sm => AppTypography.bodySm,
        AppTabSize.md => AppTypography.bodyMd,
      };

  Color get _activeUnderlineColor => switch (tone) {
        AppTabTone.brass => AppColors.brandBrass,
        AppTabTone.mystic => AppColors.stateMysticTeal,
      };

  Color get _activeTextColor => switch (tone) {
        AppTabTone.brass => AppColors.brandBrassLight,
        AppTabTone.mystic => AppColors.stateMysticTeal,
      };

  @override
  Widget build(BuildContext context) {
    final textColor = active ? _activeTextColor : AppColors.textSecondary;
    final underlineColor = active ? _activeUnderlineColor : const Color(0x00000000);

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconLeading != null) ...[
          iconLeading!,
          const SizedBox(width: AppSpacing.s2),
        ],
        DefaultTextStyle(
          style: _textStyle.copyWith(color: textColor),
          child: child,
        ),
      ],
    );

    // Stack the underline at the bottom using a Column + AnimatedContainer.
    Widget tab = AnimatedContainer(
      duration: AppDuration.fast,
      curve: AppEasing.standard,
      padding: _padding,
      color: const Color(0x00000000),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          const SizedBox(height: _underlineGap),
          AnimatedContainer(
            duration: AppDuration.fast,
            curve: AppEasing.standard,
            height: _underlineH,
            decoration: BoxDecoration(
              color: underlineColor,
              borderRadius: BorderRadius.circular(_underlineH),
            ),
          ),
        ],
      ),
    );

    // Ensure minimum 44×44 tap target.
    tab = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      child: Center(widthFactor: 1, child: tab),
    );

    return Semantics(
      button: true,
      selected: active,
      enabled: !disabled,
      child: Opacity(
        opacity: disabled ? AppOpacity.disabled : AppOpacity.o100,
        child: GestureDetector(
          onTap: disabled ? null : onTap,
          child: tab,
        ),
      ),
    );
  }
}
