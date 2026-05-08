import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';
import '../app_icon/app_icon.dart';

/// Visual tone for [AppBanner].
enum AppBannerTone { info, success, warning, danger, parchment }

/// Inline notice panel with 5 tones.
///
/// - [tone] — visual/semantic tone (info / success / warning / danger / parchment).
/// - [title] — optional bolded heading.
/// - [child] — body content (required).
/// - [dismissible] — shows ×-button; fires [onDismiss] when tapped.
/// - [actions] — optional trailing action slot (e.g. a row of [AppButton]s).
///
/// `danger` tone sets `role="alert"` semantics via [Semantics.liveRegion].
/// All others use a status live region.
class AppBanner extends StatelessWidget {
  const AppBanner({
    super.key,
    required this.child,
    this.tone = AppBannerTone.info,
    this.title,
    this.dismissible = false,
    this.onDismiss,
    this.actions,
    this.icon,
  });

  final AppBannerTone tone;
  final String? title;
  final Widget child;
  final bool dismissible;
  final VoidCallback? onDismiss;
  final Widget? actions;
  final String? icon;

  // ── Token mapping ──────────────────────────────────────────────────────────

  Color get _borderColor => switch (tone) {
        AppBannerTone.info => AppColors.stateMysticTeal,
        AppBannerTone.success => AppColors.stateSuccess,
        AppBannerTone.warning => AppColors.brandBrass,
        AppBannerTone.danger => AppColors.stateCrimson,
        AppBannerTone.parchment => AppColors.brandBrassDeep,
      };

  Color get _backgroundColor => switch (tone) {
        AppBannerTone.parchment => AppColors.surfaceParchment,
        _ => AppColors.surfaceNight,
      };

  Color get _textColor => switch (tone) {
        AppBannerTone.parchment => AppColors.textInk,
        _ => AppColors.textPrimary,
      };

  String get _defaultIcon => switch (tone) {
        AppBannerTone.info => 'info-circle',
        AppBannerTone.success => 'check-circle',
        AppBannerTone.warning => 'triangle-alert',
        AppBannerTone.danger => 'octagon-alert',
        AppBannerTone.parchment => 'eye',
      };

  AppIconColor get _iconColorEnum => switch (tone) {
        AppBannerTone.info => AppIconColor.mystic,
        AppBannerTone.success => AppIconColor.success,
        AppBannerTone.warning => AppIconColor.brass,
        AppBannerTone.danger => AppIconColor.crimson,
        AppBannerTone.parchment => AppIconColor.brass,
      };

  @override
  Widget build(BuildContext context) {
    final resolvedIcon = icon ?? _defaultIcon;
    final isDanger = tone == AppBannerTone.danger;

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s1),
            child: Text(
              title!,
              style: AppTypography.bodySm.copyWith(
                color: _textColor,
                fontWeight: AppFontWeight.semibold,
              ),
            ),
          ),
        DefaultTextStyle(
          style: AppTypography.bodySm.copyWith(color: _textColor),
          child: child,
        ),
        if (actions != null) ...[
          const SizedBox(height: AppSpacing.s3),
          actions!,
        ],
      ],
    );

    Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: AppIcon(
            name: resolvedIcon,
            size: AppIconSize.md,
            color: _iconColorEnum,
          ),
        ),
        const SizedBox(width: AppSpacing.s3),
        Expanded(child: body),
        if (dismissible) ...[
          const SizedBox(width: AppSpacing.s2),
          GestureDetector(
            onTap: onDismiss,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              child: Center(
                child: ExcludeSemantics(
                  child: AppIcon(
                    name: 'x',
                    size: AppIconSize.sm,
                    color: _iconColorEnum,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );

    Widget banner = Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: row,
    );

    // danger → liveRegion so screen readers announce immediately.
    return Semantics(
      liveRegion: isDanger,
      child: banner,
    );
  }
}
