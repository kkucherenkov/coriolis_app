import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/rank_stepper_sheet.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

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
      builder: (_) => RankStepperSheet(
        title: full,
        currentValue: value,
        min: 1,
        max: 5,
        onChanged: (v) => cubit.updateAttribute(attrKey, v),
      ),
    );
  }
}

