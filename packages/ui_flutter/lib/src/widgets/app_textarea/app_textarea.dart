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

/// Visual size for [AppTextarea].
enum AppTextareaSize { sm, md, lg }

/// Coriolis-branded multi-line text input.
///
/// Mirrors the Vue AppTextarea prop surface.  Uses [TextField] with
/// `minLines: rows` and `maxLines: null` (unbounded growth) so the field
/// expands as content grows — this matches the Vue `rows` prop behaviour
/// (fixed initial height that expands on overflow).
///
/// [controller] and [focusNode] are optional; supply them when external
/// coordination is needed.
class AppTextarea extends StatelessWidget {
  const AppTextarea({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.placeholder,
    this.size = AppTextareaSize.md,
    this.disabled = false,
    this.readonly = false,
    this.invalid = false,
    this.rows = 4,
    this.maxLength,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final AppTextareaSize size;
  final bool disabled;
  final bool readonly;
  final bool invalid;
  final int rows;
  final int? maxLength;

  double get _fontSize => switch (size) {
        AppTextareaSize.sm => AppTypography.bodySm.fontSize!,
        AppTextareaSize.md => AppTypography.bodyMd.fontSize!,
        AppTextareaSize.lg => AppTypography.bodyLg.fontSize!,
      };

  EdgeInsets get _contentPadding => switch (size) {
        AppTextareaSize.sm =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s2),
        AppTextareaSize.md =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
        AppTextareaSize.lg =>
          const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
      };

  Color get _borderColor => invalid ? AppColors.stateCrimson : AppColors.brandBrassShadow;
  Color get _focusBorderColor =>
      invalid ? AppColors.stateCrimsonBright : AppColors.brandBrass;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontFamily: AppFontFamily.body,
      fontSize: _fontSize,
      color: disabled
          ? AppColors.textSecondary.withOpacity(AppOpacity.disabled)
          : AppColors.brandBrass,
    );

    return Opacity(
      opacity: disabled ? AppOpacity.disabled : AppOpacity.o100,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: !disabled,
        readOnly: readonly,
        maxLines: null,  // unbounded upward growth
        minLines: rows,
        maxLength: maxLength,
        style: textStyle,
        onChanged: onChanged,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: placeholder,
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
        ),
      ),
    );
  }
}
