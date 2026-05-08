import 'package:flutter/material.dart'
    show
        InputDecoration,
        OutlineInputBorder,
        TextField,
        TextInputType,
        TextEditingController,
        FocusNode;
import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Text-input types mirroring the Vue AppInput prop.
enum AppInputType { text, email, password, number }

/// Visual size.
enum AppInputSize { sm, md, lg }

/// Coriolis-branded text input.
///
/// Wraps [TextField] with Coriolis token styling. Mirrors the Vue AppInput
/// prop surface: [inputType], [size], [disabled], [readOnly], [invalid],
/// [hintText], [errorText].
///
/// The [controller] and [focusNode] are optional — callers supply them when
/// coordination between multiple inputs or with [AppField] is needed.
class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    this.controller,
    this.focusNode,
    this.inputType = AppInputType.text,
    this.size = AppInputSize.md,
    this.disabled = false,
    this.readOnly = false,
    this.invalid = false,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final AppInputType inputType;
  final AppInputSize size;
  final bool disabled;
  final bool readOnly;
  final bool invalid;
  final String? hintText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  TextInputType get _keyboardType => switch (inputType) {
        AppInputType.email => TextInputType.emailAddress,
        AppInputType.number => TextInputType.number,
        _ => TextInputType.text,
      };

  double get _fontSize => switch (size) {
        AppInputSize.sm => AppTypography.bodySm.fontSize!,
        AppInputSize.md => AppTypography.bodyMd.fontSize!,
        AppInputSize.lg => AppTypography.bodyLg.fontSize!,
      };

  EdgeInsets get _contentPadding => switch (size) {
        AppInputSize.sm =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s2),
        AppInputSize.md =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
        AppInputSize.lg =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
      };

  Color get _borderColor => invalid ? AppColors.stateCrimson : AppColors.brandBrassShadow;

  Color get _focusBorderColor => invalid ? AppColors.stateCrimsonBright : AppColors.brandBrass;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontFamily: AppFontFamily.body,
      fontSize: _fontSize,
      color: disabled
          ? AppColors.textSecondary.withOpacity(AppOpacity.disabled)
          : AppColors.brandBrass,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: disabled ? AppOpacity.disabled : AppOpacity.o100,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: !disabled,
            readOnly: readOnly,
            obscureText: inputType == AppInputType.password,
            keyboardType: _keyboardType,
            autofocus: autofocus,
            style: textStyle,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: textStyle.copyWith(
                color: AppColors.textSecondary.withOpacity(AppOpacity.muted),
              ),
              contentPadding: _contentPadding,
              filled: true,
              fillColor: AppColors.surfaceNight,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: _borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: _focusBorderColor, width: 2),
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
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.stateCrimsonBright, width: 2),
              ),
              errorText: null, // error displayed below via separate Text widget
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.s1),
          Text(
            errorText!,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.stateCrimsonBright,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
