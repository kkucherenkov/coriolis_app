import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/attributes_block.dart'
    show _RankStepperSheet;
import 'package:coriolis_companion/i18n/strings.g.dart';

/// Skills block rendered inside the Stats tab.
///
/// Splits into General (8 skills) and Advanced (8 skills) sections,
/// matching the mockup layout.
class SkillsBlock extends StatelessWidget {
  const SkillsBlock({
    super.key,
    required this.skills,
    required this.attributes,
  });

  final CharacterSkills skills;
  final CharacterAttributes attributes;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;

    final generalSkills = [
      (key: 'dexterity', name: t.skillDexterity, attr: t.attrAgility, value: skills.dexterity),
      (key: 'force', name: t.skillForce, attr: t.attrStrength, value: skills.force),
      (key: 'infiltration', name: t.skillInfiltration, attr: t.attrAgility, value: skills.infiltration),
      (key: 'manipulation', name: t.skillManipulation, attr: t.attrEmpathy, value: skills.manipulation),
      (key: 'meleeCombat', name: t.skillMeleeCombat, attr: t.attrStrength, value: skills.meleeCombat),
      (key: 'observation', name: t.skillObservation, attr: t.attrWits, value: skills.observation),
      (key: 'rangedCombat', name: t.skillRangedCombat, attr: t.attrAgility, value: skills.rangedCombat),
      (key: 'survival', name: t.skillSurvival, attr: t.attrWits, value: skills.survival),
    ];

    final advancedSkills = [
      (key: 'pilot', name: t.skillPilot, attr: t.attrAgility, value: skills.pilot),
      (key: 'technology', name: t.skillTechnology, attr: t.attrWits, value: skills.technology),
      (key: 'dataDjinn', name: t.skillDataDjinn, attr: t.attrWits, value: skills.dataDjinn),
      (key: 'command', name: t.skillCommand, attr: t.attrEmpathy, value: skills.command),
      (key: 'science', name: t.skillScience, attr: t.attrWits, value: skills.science),
      (key: 'culture', name: t.skillCulture, attr: t.attrEmpathy, value: skills.culture),
      (key: 'medicurgy', name: t.skillMedicurgy, attr: t.attrWits, value: skills.medicurgy),
      (key: 'mysticPowers', name: t.skillMysticPowers, attr: t.attrEmpathy, value: skills.mysticPowers),
    ];

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.sectionSkills.toUpperCase(),
            style: AppTypography.displaySm.copyWith(
              color: AppColors.brandBrassLight,
              fontSize: 14,
              letterSpacing: 0.08 * 14,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          // General section header
          _SectionDivider(label: t.sectionGeneral, isMystic: false),
          const SizedBox(height: AppSpacing.s1),
          ...generalSkills.map((s) => _SkillRow(
                skillKey: s.key,
                name: s.name,
                attr: s.attr,
                value: s.value,
                isAdvanced: false,
              )),
          const SizedBox(height: AppSpacing.s3),
          // Advanced section header
          _SectionDivider(label: t.sectionAdvanced, isMystic: true),
          const SizedBox(height: AppSpacing.s1),
          ...advancedSkills.map((s) => _SkillRow(
                skillKey: s.key,
                name: s.name,
                attr: s.attr,
                value: s.value,
                isAdvanced: true,
              )),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label, required this.isMystic});
  final String label;
  final bool isMystic;

  @override
  Widget build(BuildContext context) {
    final color = isMystic ? AppColors.stateMysticTeal : AppColors.brandBrass;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: color),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s1),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.displaySm.copyWith(
            color: color,
            fontSize: 10,
            letterSpacing: 0.18 * 10,
          ),
        ),
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.skillKey,
    required this.name,
    required this.attr,
    required this.value,
    required this.isAdvanced,
  });

  final String skillKey;
  final String name;
  final String attr;
  final int value;
  final bool isAdvanced;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$name: $value',
      child: GestureDetector(
        onTap: () => _openStepper(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s1),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.brandBrassDeep.withOpacity(0.15),
              ),
            ),
          ),
          child: Row(
            children: [
              if (isAdvanced)
                Container(
                  width: 2,
                  height: AppSpacing.s4,
                  margin: const EdgeInsets.only(right: AppSpacing.s2),
                  decoration: BoxDecoration(
                    color: value > 0
                        ? AppColors.stateMysticTeal
                        : AppColors.stateMysticTeal.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(1),
                  ),
                )
              else
                const SizedBox(width: AppSpacing.s1),
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              Text(
                attr,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.brandBrass,
                  fontSize: 9,
                  letterSpacing: 0.14 * 9,
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              // Pip dots
              Row(
                children: List.generate(5, (i) {
                  final filled = i < value;
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? (isAdvanced
                              ? AppColors.stateMysticTeal
                              : AppColors.brandBrass)
                          : Colors.transparent,
                      border: Border.all(
                        color: isAdvanced
                            ? AppColors.stateMysticTeal
                            : AppColors.brandBrassDeep,
                      ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => _RankStepperSheet(
        title: name,
        currentValue: value,
        min: 0,
        max: 5,
        onChanged: (v) => cubit.updateSkill(skillKey, v),
      ),
    );
  }
}
