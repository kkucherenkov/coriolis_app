import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Variants matching the Vue AppButton.
///
/// - `primary` — brass-fill hero CTA.
/// - `secondary` — transparent + brass-bordered Cancel / Skip / Reroll.
/// - `ghost` — borderless tertiary affordance.
/// - `danger` — crimson-fill destructive action.
/// - `mystic` — mystic-teal ritual CTA (Push the Roll, Pray).
enum AppButtonVariant { primary, secondary, ghost, danger, mystic }

/// Visual size — tap target is always ≥ 44×44 regardless of size.
enum AppButtonSize { sm, md, lg }

/// Coriolis-branded button primitive.
///
/// Mirrors the Vue `AppButton` prop surface: [variant], [size], [disabled],
/// [loading]. All colors come from [AppColors]; no hex literals here.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.disabled = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool disabled;
  final bool loading;

  bool get _isDisabled => disabled || loading;

  // ── Size geometry ────────────────────────────────────────────────────────

  EdgeInsets get _padding => switch (size) {
    AppButtonSize.sm => const EdgeInsets.symmetric(
      horizontal: AppSpacing.s3,
      vertical: AppSpacing.s1,
    ),
    AppButtonSize.md => const EdgeInsets.symmetric(
      horizontal: AppSpacing.s4,
      vertical: AppSpacing.s2,
    ),
    AppButtonSize.lg => const EdgeInsets.symmetric(
      horizontal: AppSpacing.s5,
      vertical: AppSpacing.s3,
    ),
  };

  TextStyle get _textStyle => switch (size) {
    AppButtonSize.sm => AppTypography.bodySm,
    AppButtonSize.md => AppTypography.bodyMd,
    AppButtonSize.lg => AppTypography.bodyLg,
  };

  // ── Colors per variant ───────────────────────────────────────────────────

  Color get _backgroundColor => switch (variant) {
    AppButtonVariant.primary => AppColors.brandBrass,
    AppButtonVariant.secondary => const Color(0x00000000),
    AppButtonVariant.ghost => const Color(0x00000000),
    AppButtonVariant.danger => AppColors.stateCrimson,
    AppButtonVariant.mystic => AppColors.stateMysticTeal,
  };

  Color get _textColor => switch (variant) {
    AppButtonVariant.primary => AppColors.textOnBrass,
    AppButtonVariant.secondary => AppColors.brandBrass,
    AppButtonVariant.ghost => AppColors.brandBrassLight,
    AppButtonVariant.danger => AppColors.textPrimary,
    AppButtonVariant.mystic => AppColors.textOnBrass,
  };

  Color get _borderColor => switch (variant) {
    AppButtonVariant.primary => const Color(0x00000000),
    AppButtonVariant.secondary => AppColors.brandBrass,
    AppButtonVariant.ghost => AppColors.brandBrassDeep,
    AppButtonVariant.danger => const Color(0x00000000),
    AppButtonVariant.mystic => AppColors.stateMysticTeal,
  };

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = _textStyle.copyWith(color: _textColor);

    Widget content = loading
        ? SizedBox(
            width: 16,
            height: 16,
            child: _SpinnerPainter(color: _textColor),
          )
        : Text(label, style: effectiveStyle);

    Widget button = AnimatedContainer(
      duration: AppDuration.fast,
      curve: AppEasing.standard,
      decoration: BoxDecoration(
        color: _isDisabled
            ? _backgroundColor.withOpacity(AppOpacity.disabled)
            : _backgroundColor,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: _padding,
      child: content,
    );

    // Enforce minimum 44×44 tap target by constraining with a SizedBox.
    button = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      child: Center(widthFactor: 1, child: button),
    );

    return Semantics(
      button: true,
      enabled: !_isDisabled,
      label: label,
      child: GestureDetector(
        onTap: _isDisabled ? null : onPressed,
        child: Opacity(
          opacity: _isDisabled ? AppOpacity.disabled : AppOpacity.o100,
          child: button,
        ),
      ),
    );
  }
}

/// Animated spinner for the loading state.
/// Separate widget so it can have its own [AnimationController].
class _SpinnerPainter extends StatefulWidget {
  const _SpinnerPainter({required this.color});
  final Color color;

  @override
  State<_SpinnerPainter> createState() => _SpinnerPainterState();
}

class _SpinnerPainterState extends State<_SpinnerPainter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: CustomPaint(painter: _ArcPainter(color: widget.color)),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    // 270° arc — matches the CSS border-right-color:transparent spinner trick.
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0,
      4.71239, // 3/4 of 2π
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color;
}
