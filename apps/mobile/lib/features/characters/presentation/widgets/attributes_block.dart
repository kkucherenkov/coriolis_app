import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:app_mobile/features/characters/domain/character.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:app_mobile/i18n/strings.g.dart';

/// 4-attribute grid (STR / AGI / WIT / EMP).
///
/// Tapping an attribute card opens a bottom-sheet stepper to adjust the value.
class AttributesBlock extends StatelessWidget {
  const AttributesBlock({super.key, required this.attributes});

  final CharacterAttributes attributes;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    final attrs = [
      (key: 'strength', abbr: t.attrStrength, full: t.attrStrengthFull, value: attributes.strength),
      (key: 'agility', abbr: t.attrAgility, full: t.attrAgilityFull, value: attributes.agility),
      (key: 'wits', abbr: t.attrWits, full: t.attrWitsFull, value: attributes.wits),
      (key: 'empathy', abbr: t.attrEmpathy, full: t.attrEmpathyFull, value: attributes.empathy),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.sectionAttributes.toUpperCase(),
            style: AppTypography.displaySm.copyWith(
              color: AppColors.brandBrassLight,
              fontSize: 14,
              letterSpacing: 0.08 * 14,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              for (int i = 0; i < attrs.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.s2),
                Expanded(
                  child: _AttributeCard(
                    attrKey: attrs[i].key,
                    abbr: attrs[i].abbr,
                    full: attrs[i].full,
                    value: attrs[i].value,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AttributeCard extends StatelessWidget {
  const _AttributeCard({
    required this.attrKey,
    required this.abbr,
    required this.full,
    required this.value,
  });

  final String attrKey;
  final String abbr;
  final String full;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$full: $value',
      child: GestureDetector(
        onTap: () => _openStepper(context),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s1,
            vertical: AppSpacing.s2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVoid,
            border: Border.all(
              color: AppColors.brandBrassDeep.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                abbr,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.brandBrass,
                  fontSize: 9,
                  letterSpacing: 0.14 * 9,
                ),
              ),
              Text(
                '$value',
                style: AppTypography.monoStatMd.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: AppSpacing.s1),
              // Pip row (5 pips)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < value;
                  return Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppColors.brandBrass : Colors.transparent,
                      border: Border.all(color: AppColors.brandBrassDeep),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openStepper(BuildContext context) {
    final cubit = context.read<CharacterSheetCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceNight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (_) => _RankStepperSheet(
        title: full,
        currentValue: value,
        min: 1,
        max: 5,
        onChanged: (v) => cubit.updateAttribute(attrKey, v),
      ),
    );
  }
}

/// Reusable bottom-sheet stepper for rank values (1–5 or 0–5).
class _RankStepperSheet extends StatefulWidget {
  const _RankStepperSheet({
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
  State<_RankStepperSheet> createState() => _RankStepperSheetState();
}

class _RankStepperSheetState extends State<_RankStepperSheet> {
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
            // Pip row
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
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
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
