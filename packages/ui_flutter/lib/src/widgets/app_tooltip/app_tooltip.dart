import 'package:flutter/material.dart' show Tooltip, TooltipTriggerMode;
import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Preferred placement direction for [AppTooltip].
///
/// Flutter's [Tooltip] does not expose a full four-sided placement API; it
/// only has [Tooltip.preferBelow] (top vs bottom).  Left/right placements
/// fall back to bottom silently.  This is a known platform limitation and is
/// documented here so callers are aware.
enum TooltipPlacement { top, right, bottom, left }

/// Coriolis-styled tooltip wrapper.
///
/// Wraps Flutter's built-in [Tooltip] with `surfaceNight` background,
/// `brandBrassShadow` 1 px border, `AppTypography.bodySm` text.
///
/// **Placement limitation**: Flutter's [Tooltip] only supports vertical
/// preference (`preferBelow`).  [TooltipPlacement.left] and
/// [TooltipPlacement.right] are accepted but behave identically to
/// [TooltipPlacement.bottom].  Horizontal placement would require a custom
/// overlay; deferred to a future iteration.
///
/// Hover and long-press show/hide is handled by Flutter natively.
class AppTooltip extends StatelessWidget {
  const AppTooltip({
    super.key,
    required this.message,
    required this.child,
    this.placement = TooltipPlacement.top,
    this.delay = AppDuration.dDefault,
  });

  final String message;
  final Widget child;
  final TooltipPlacement placement;
  final Duration delay;

  bool get _preferBelow => switch (placement) {
        TooltipPlacement.top => false,
        TooltipPlacement.bottom => true,
        TooltipPlacement.left => false,
        TooltipPlacement.right => false,
      };

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      preferBelow: _preferBelow,
      waitDuration: delay,
      triggerMode: TooltipTriggerMode.longPress,
      decoration: BoxDecoration(
        color: AppColors.surfaceNight,
        border: Border.all(color: AppColors.brandBrassShadow),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      textStyle: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
      child: child,
    );
  }
}
