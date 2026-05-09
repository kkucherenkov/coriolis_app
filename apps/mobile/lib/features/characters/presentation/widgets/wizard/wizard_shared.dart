import 'package:flutter/widgets.dart';
import 'package:app_ui/app_ui.dart';

/// Point-pool status banner shared between wizard step 4 (attributes) and
/// step 5 (skills).
class PointPoolBanner extends StatelessWidget {
  const PointPoolBanner({
    super.key,
    required this.label,
    required this.remaining,
    required this.total,
  });

  final String label;
  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isComplete = remaining == 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceNight,
        border: Border.all(color: AppColors.brandBrassDeep),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.bodySm.copyWith(
                fontSize: 11,
                letterSpacing: 0.18 * 11,
                color: AppColors.brandBrass,
              ),
            ),
            Text(
              '$remaining',
              style: AppTypography.monoStatMd.copyWith(
                color: isComplete
                    ? AppColors.stateSuccess
                    : AppColors.brandBrassLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small stepper button (−/+) shared between wizard step 4 and step 5.
/// Tap target is 44×44. [icon] is a display string (e.g. '−' or '+').
class WizardStepperButton extends StatelessWidget {
  const WizardStepperButton({
    super.key,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? AppOpacity.o100 : AppOpacity.disabled,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.brandBrassDeep),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Text(
                icon,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.brandBrass,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
