import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Label tone — default / eyebrow / stat-block per DESIGN §6.2 / §6.3.
enum AppLabelTone { defaultTone, eyebrow, statBlock }

/// Form/section label widget.
///
/// - [defaultTone]: `bodySm`, brass color, normal case.
/// - [eyebrow]: `bodySm`, brass-light, uppercase, wider tracking — used above
///   section headings.
/// - [statBlock]: `displaySm` (Forum), uppercase — used for stat-block labels.
///
/// Optional [required] star and [helpText] below.
class AppLabel extends StatelessWidget {
  const AppLabel({
    super.key,
    required this.text,
    this.tone = AppLabelTone.defaultTone,
    this.required = false,
    this.helpText,
  });

  final String text;
  final AppLabelTone tone;
  final bool required;
  final String? helpText;

  TextStyle get _style => switch (tone) {
        AppLabelTone.defaultTone => AppTypography.bodySm.copyWith(
            color: AppColors.brandBrass,
          ),
        AppLabelTone.eyebrow => AppTypography.bodySm.copyWith(
            color: AppColors.brandBrassLight,
            letterSpacing: 1.2,
          ),
        AppLabelTone.statBlock => AppTypography.displaySm.copyWith(
            color: AppColors.brandBrassLight,
          ),
      };

  String get _displayText =>
      tone == AppLabelTone.eyebrow || tone == AppLabelTone.statBlock
          ? text.toUpperCase()
          : text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_displayText, style: _style),
            if (required) ...[
              const SizedBox(width: 2),
              Text(
                '*',
                style: _style.copyWith(color: AppColors.stateCrimsonBright),
              ),
            ],
          ],
        ),
        if (helpText != null) ...[
          const SizedBox(height: 2),
          Text(
            helpText!,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
