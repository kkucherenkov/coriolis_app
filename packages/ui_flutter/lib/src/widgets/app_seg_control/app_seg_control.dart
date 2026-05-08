import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// One option in an [AppSegControl].
class AppSegOption<T> {
  const AppSegOption({
    required this.value,
    required this.label,
    this.disabled = false,
  });

  final T value;
  final String label;
  final bool disabled;
}

/// Visual size for [AppSegControl].
enum AppSegSize { sm, md, lg }

/// Segmented control — mutually exclusive single-select.
///
/// Generic over [T] so consumers can use `String`, `int`, or an enum.
/// Supports 2–5 options.
///
/// Accessibility: each segment carries `Semantics(button: true, selected: …)`.
/// Roving keyboard focus is the consumer's responsibility.
class AppSegControl<T> extends StatelessWidget {
  const AppSegControl({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.size = AppSegSize.md,
    this.disabled = false,
  }) : assert(
          options.length >= 2 && options.length <= 5,
          'AppSegControl requires 2–5 options',
        );

  final T value;
  final List<AppSegOption<T>> options;
  final ValueChanged<T>? onChanged;
  final AppSegSize size;
  final bool disabled;

  EdgeInsets get _padding => switch (size) {
        AppSegSize.sm =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s1),
        AppSegSize.md =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
        AppSegSize.lg =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s5, vertical: AppSpacing.s3),
      };

  TextStyle get _textStyle => switch (size) {
        AppSegSize.sm => AppTypography.bodySm,
        AppSegSize.md => AppTypography.bodyMd,
        AppSegSize.lg => AppTypography.bodyLg,
      };

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? AppOpacity.disabled : AppOpacity.o100,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceNight,
          border: Border.all(color: AppColors.brandBrassDeep),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(options.length, (i) {
              final option = options[i];
              final isSelected = option.value == value;
              final isFirst = i == 0;
              final isLast = i == options.length - 1;
              return _SegmentButton(
                option: option,
                selected: isSelected,
                disabled: disabled || option.disabled,
                padding: _padding,
                textStyle: _textStyle,
                isFirst: isFirst,
                isLast: isLast,
                onTap: (disabled || option.disabled)
                    ? null
                    : () => onChanged?.call(option.value),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _SegmentButton<T> extends StatelessWidget {
  const _SegmentButton({
    required this.option,
    required this.selected,
    required this.disabled,
    required this.padding,
    required this.textStyle,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final AppSegOption<T> option;
  final bool selected;
  final bool disabled;
  final EdgeInsets padding;
  final TextStyle textStyle;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  BorderRadius get _borderRadius {
    final r = AppRadius.md - 1;
    return BorderRadius.only(
      topLeft: isFirst ? Radius.circular(r) : Radius.zero,
      bottomLeft: isFirst ? Radius.circular(r) : Radius.zero,
      topRight: isLast ? Radius.circular(r) : Radius.zero,
      bottomRight: isLast ? Radius.circular(r) : Radius.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget segment = AnimatedContainer(
      duration: AppDuration.fast,
      curve: AppEasing.standard,
      padding: padding,
      decoration: BoxDecoration(
        color: selected ? AppColors.brandBrass : const Color(0x00000000),
        border: Border(
          left: isFirst
              ? BorderSide.none
              : const BorderSide(color: AppColors.brandBrassDeep),
        ),
        borderRadius: _borderRadius,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        child: Center(
          child: Text(
            option.label,
            style: textStyle.copyWith(
              color: selected ? AppColors.textOnBrass : AppColors.textSecondary,
              fontWeight: selected ? AppFontWeight.semibold : AppFontWeight.regular,
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      enabled: !disabled,
      label: option.label,
      child: GestureDetector(
        onTap: onTap,
        child: segment,
      ),
    );
  }
}
