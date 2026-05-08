import 'package:flutter/widgets.dart';
import '../../theme/tokens.g.dart';

/// Boolean toggle with brass-on-night Coriolis styling.
///
/// Does not depend on Material [Switch] to stay token-driven. The thumb is a
/// 20×20 circle; the track is 40×22 — both meet the 44×44 minimum tap target
/// via the outer [GestureDetector] / [ConstrainedBox].
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.disabled = false,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool disabled;
  final String? semanticLabel;

  static const double _trackW = 40.0;
  static const double _trackH = 22.0;
  static const double _thumbD = 18.0;
  static const double _thumbInset = 2.0;

  Color get _trackColor =>
      value ? AppColors.brandBrass : AppColors.surfaceDawn;

  Color get _thumbColor => value ? AppColors.textOnBrass : AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      enabled: !disabled,
      label: semanticLabel,
      child: GestureDetector(
        onTap: disabled ? null : () => onChanged?.call(!value),
        child: Opacity(
          opacity: disabled ? AppOpacity.disabled : AppOpacity.o100,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: Center(
              child: SizedBox(
                width: _trackW,
                height: _trackH,
                child: AnimatedContainer(
                  duration: AppDuration.fast,
                  curve: AppEasing.standard,
                  decoration: BoxDecoration(
                    color: _trackColor,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: value ? AppColors.brandBrass : AppColors.brandBrassShadow,
                    ),
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: AppDuration.fast,
                        curve: AppEasing.standard,
                        top: _thumbInset,
                        left: value
                            ? _trackW - _thumbD - _thumbInset
                            : _thumbInset,
                        child: Container(
                          width: _thumbD,
                          height: _thumbD,
                          decoration: BoxDecoration(
                            color: _thumbColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
