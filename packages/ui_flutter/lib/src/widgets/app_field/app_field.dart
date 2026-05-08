import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';
import '../app_label/app_label.dart';

/// Form-row composer: [AppLabel] + [child] + optional help/error text.
///
/// Mirrors the Vue AppField scoped-slot pattern. [label] and [child] are
/// required; [helpText] and [errorText] render below the child. When
/// [errorText] is non-null it takes precedence over [helpText].
///
/// [labelFocusNode] is forwarded to [AppLabel] so that a tap on the label
/// requests focus on the associated input (mirrors HTML `<label for>`).
class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.label,
    required this.child,
    this.labelTone = AppLabelTone.defaultTone,
    this.required = false,
    this.helpText,
    this.errorText,
    this.labelFocusNode,
  });

  final String label;
  final Widget child;
  final AppLabelTone labelTone;
  final bool required;
  final String? helpText;
  final String? errorText;

  /// When supplied, tapping the label moves focus to this node (the input's FocusNode).
  final FocusNode? labelFocusNode;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final subText = hasError ? errorText : helpText;
    final subColor =
        hasError ? AppColors.stateCrimsonBright : AppColors.textSecondary;

    Widget labelWidget = AppLabel(
      text: label,
      tone: labelTone,
      required: required,
    );

    if (labelFocusNode != null) {
      labelWidget = GestureDetector(
        onTap: () => labelFocusNode!.requestFocus(),
        child: labelWidget,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        labelWidget,
        const SizedBox(height: AppSpacing.s1),
        child,
        if (subText != null) ...[
          const SizedBox(height: AppSpacing.s1),
          Text(
            subText,
            style: AppTypography.bodySm.copyWith(
              color: subColor,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
