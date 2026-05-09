import 'package:flutter/material.dart';
import 'package:app_ui/app_ui.dart';

/// Reusable bottom-sheet stepper for rank values (0–5 or 1–5).
///
/// Displays a large numeric value with − / + buttons and a pip row.
/// The caller is responsible for opening the sheet via [showModalBottomSheet].
class RankStepperSheet extends StatefulWidget {
  const RankStepperSheet({
    super.key,
    required this.title,
    required this.currentValue,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String title;
  final int currentValue;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  State<RankStepperSheet> createState() => _RankStepperSheetState();
}

class _RankStepperSheetState extends State<RankStepperSheet> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: AppSpacing.s11,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.brandBrassDeep,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              widget.title,
              style: AppTypography.displaySm.copyWith(
                color: AppColors.brandBrass,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepperIconButton(
                  icon: Icons.remove,
                  enabled: _value > widget.min,
                  onTap: () => setState(() {
                    _value = (_value - 1).clamp(widget.min, widget.max);
                    widget.onChanged(_value);
                  }),
                ),
                const SizedBox(width: AppSpacing.s6),
                Text(
                  '$_value',
                  style: AppTypography.monoStatXl.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.s6),
                _StepperIconButton(
                  icon: Icons.add,
                  enabled: _value < widget.max,
                  onTap: () => setState(() {
                    _value = (_value + 1).clamp(widget.min, widget.max);
                    widget.onChanged(_value);
                  }),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s3),
            // Pip row — tappable
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.max - widget.min + 1, (i) {
                final rank = widget.min + i;
                final filled = rank <= _value;
                return GestureDetector(
                  onTap: () => setState(() {
                    _value = rank;
                    widget.onChanged(_value);
                  }),
                  child: Container(
                    width: AppSpacing.s4,
                    height: AppSpacing.s4,
                    margin:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppColors.brandBrass : Colors.transparent,
                      border: Border.all(color: AppColors.brandBrassDeep),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.s4),
            AppButton(
              label: 'OK',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperIconButton extends StatelessWidget {
  const _StepperIconButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Opacity(
              opacity: enabled ? AppOpacity.o100 : AppOpacity.disabled,
              child: Icon(icon, color: AppColors.brandBrass, size: AppSpacing.s6),
            ),
          ),
        ),
      ),
    );
  }
}
