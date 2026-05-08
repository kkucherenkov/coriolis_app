import 'package:flutter/material.dart'
    show
        DropdownButton,
        DropdownMenuItem,
        DropdownButtonHideUnderline,
        InputDecoration,
        OutlineInputBorder,
        InputDecorator;
import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';
import '../app_icon/app_icon.dart';

/// One entry in the [AppSelect] dropdown.
class AppSelectOption<T> {
  const AppSelectOption({
    required this.value,
    required this.label,
    this.disabled = false,
  });

  final T value;
  final String label;
  final bool disabled;
}

/// Visual size for [AppSelect].
enum AppSelectSize { sm, md, lg }

/// Coriolis-branded dropdown selector.
///
/// Wraps Material [DropdownButton] with Coriolis token decoration.
///
/// **Material menu styling**: the popup list inherits Material defaults
/// (white/system surface background).  For v1 the menu colours are not
/// overridden; a custom overlay is deferred.  This is documented here so
/// callers are aware.
class AppSelect<T> extends StatelessWidget {
  const AppSelect({
    super.key,
    required this.options,
    required this.onChanged,
    this.value,
    this.placeholder,
    this.size = AppSelectSize.md,
    this.disabled = false,
    this.invalid = false,
  });

  final T? value;
  final List<AppSelectOption<T>> options;
  final String? placeholder;
  final AppSelectSize size;
  final bool disabled;
  final bool invalid;
  final ValueChanged<T?>? onChanged;

  double get _fontSize => switch (size) {
        AppSelectSize.sm => AppTypography.bodySm.fontSize!,
        AppSelectSize.md => AppTypography.bodyMd.fontSize!,
        AppSelectSize.lg => AppTypography.bodyLg.fontSize!,
      };

  EdgeInsets get _contentPadding => switch (size) {
        AppSelectSize.sm =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s2),
        AppSelectSize.md =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
        AppSelectSize.lg =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
      };

  Color get _borderColor => invalid ? AppColors.stateCrimson : AppColors.brandBrassShadow;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontFamily: AppFontFamily.body,
      fontSize: _fontSize,
      color: disabled
          ? AppColors.textSecondary.withOpacity(AppOpacity.disabled)
          : AppColors.brandBrass,
    );

    final hintStyle = textStyle.copyWith(
      color: AppColors.textSecondary.withOpacity(AppOpacity.muted),
    );

    // Build items — disabled items are rendered but non-interactive.
    final items = options.map((opt) {
      return DropdownMenuItem<T>(
        value: opt.value,
        enabled: !opt.disabled,
        child: Opacity(
          opacity: opt.disabled ? AppOpacity.disabled : AppOpacity.o100,
          child: Text(opt.label, style: textStyle),
        ),
      );
    }).toList();

    Widget dropdown = Opacity(
      opacity: disabled ? AppOpacity.disabled : AppOpacity.o100,
      child: InputDecorator(
          decoration: InputDecoration(
            contentPadding: _contentPadding,
            filled: true,
            fillColor: AppColors.surfaceNight,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: _borderColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.brandBrassShadow.withOpacity(AppOpacity.disabled),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.stateCrimson, width: 2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: _borderColor),
            ),
            isDense: true,
          ),
          isEmpty: value == null,
          isFocused: false,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: placeholder != null ? Text(placeholder!, style: hintStyle) : null,
              items: items,
              onChanged: disabled ? null : onChanged,
              isExpanded: true,
              style: textStyle,
              icon: const AppIcon(
                name: 'chevron-down',
                size: AppIconSize.sm,
                color: AppIconColor.brass,
              ),
              dropdownColor: AppColors.surfaceNight,
            ),
          ),
        ),
    );

    return dropdown;
  }
}
