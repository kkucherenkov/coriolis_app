import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:app_mobile/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:app_mobile/i18n/strings.g.dart';
import 'step_1_concept.dart' show _StepHeader;
import 'step_4_attributes.dart' show _PointPoolBanner, _StepperButton;

/// Wizard step 5 — Skill distribution.
///
/// Two sections:
/// - General skills (8 skills, 8 points total, max rank 5).
/// - Advanced skills (8 skills, 2 points total, max rank 3).
///
/// Each row uses the shared [_StepperButton] from step 4.
class Step5Skills extends StatelessWidget {
  const Step5Skills({super.key});

  static const int _generalTotal = 8;
  static const int _advancedTotal = 2;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;

    return BlocBuilder<CharacterWizardCubit, CharacterWizardState>(
      builder: (context, state) {
        final d = state.draft;
        final genRemaining = _generalTotal - d.generalSkillPointsSpent;
        final advRemaining = _advancedTotal - d.advancedSkillPointsSpent;

        final generalSkills = [
          (key: 'dexterity', label: t.skillDexterity, value: d.dexterity ?? 0),
          (key: 'force', label: t.skillForce, value: d.force ?? 0),
          (key: 'infiltration', label: t.skillInfiltration, value: d.infiltration ?? 0),
          (key: 'manipulation', label: t.skillManipulation, value: d.manipulation ?? 0),
          (key: 'meleeCombat', label: t.skillMeleeCombat, value: d.meleeCombat ?? 0),
          (key: 'observation', label: t.skillObservation, value: d.observation ?? 0),
          (key: 'rangedCombat', label: t.skillRangedCombat, value: d.rangedCombat ?? 0),
          (key: 'survival', label: t.skillSurvival, value: d.survival ?? 0),
        ];

        final advancedSkills = [
          (key: 'command', label: t.skillCommand, value: d.command ?? 0),
          (key: 'culture', label: t.skillCulture, value: d.culture ?? 0),
          (key: 'dataDjinn', label: t.skillDataDjinn, value: d.dataDjinn ?? 0),
          (key: 'medicurgy', label: t.skillMedicurgy, value: d.medicurgy ?? 0),
          (key: 'mysticPowers', label: t.skillMysticPowers, value: d.mysticPowers ?? 0),
          (key: 'pilot', label: t.skillPilot, value: d.pilot ?? 0),
          (key: 'science', label: t.skillScience, value: d.science ?? 0),
          (key: 'technology', label: t.skillTechnology, value: d.technology ?? 0),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepHeader(
                title: t.wizardStep5Title,
                blurb: t.wizardStep5Blurb,
              ),
              const SizedBox(height: AppSpacing.s4),
              // General section
              _SkillSection(
                title: t.sectionGeneral.toUpperCase(),
                poolLabel: t.wizardSkillPointsRemaining,
                remaining: genRemaining,
                total: _generalTotal,
                skills: generalSkills,
                maxRank: 5,
                canIncrementAny: genRemaining > 0,
                onChanged: (key, delta) =>
                    context.read<CharacterWizardCubit>().updateSkill(key, delta),
              ),
              const SizedBox(height: AppSpacing.s4),
              // Advanced section
              _SkillSection(
                title: t.sectionAdvanced.toUpperCase(),
                poolLabel: t.wizardSkillPointsRemaining,
                remaining: advRemaining,
                total: _advancedTotal,
                skills: advancedSkills,
                maxRank: 3,
                canIncrementAny: advRemaining > 0,
                onChanged: (key, delta) =>
                    context.read<CharacterWizardCubit>().updateSkill(key, delta),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkillSection extends StatelessWidget {
  const _SkillSection({
    required this.title,
    required this.poolLabel,
    required this.remaining,
    required this.total,
    required this.skills,
    required this.maxRank,
    required this.canIncrementAny,
    required this.onChanged,
  });

  final String title;
  final String poolLabel;
  final int remaining;
  final int total;
  final List<({String key, String label, int value})> skills;
  final int maxRank;
  final bool canIncrementAny;
  final void Function(String key, int delta) onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodySm.copyWith(
                  fontSize: 12,
                  letterSpacing: 0.18 * 12,
                  color: AppColors.brandBrassLight,
                  fontWeight: AppFontWeight.semibold,
                ),
              ),
              Text(
                '$remaining / $total',
                style: AppTypography.monoStatMd.copyWith(
                  color: remaining == 0
                      ? AppColors.stateSuccess
                      : AppColors.brandBrass,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          ...skills.map((s) => _SkillRow(
                label: s.label,
                value: s.value,
                maxRank: maxRank,
                canIncrement: canIncrementAny && s.value < maxRank,
                canDecrement: s.value > 0,
                onIncrement: () => onChanged(s.key, 1),
                onDecrement: () => onChanged(s.key, -1),
              )),
        ],
      ),
    );
  }
}

/// One skill row: name | dots | rank | − / +.
class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.label,
    required this.value,
    required this.maxRank,
    required this.canIncrement,
    required this.canDecrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String label;
  final int value;
  final int maxRank;
  final bool canIncrement;
  final bool canDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s1),
      child: Row(
        children: [
          // Skill name
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: AppTypography.bodyMd.copyWith(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Rank dots
          Expanded(
            flex: 3,
            child: Wrap(
              spacing: 4,
              children: List.generate(maxRank, (i) {
                final filled = i < value;
                return Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? AppColors.brandBrass
                        : AppColors.surfaceDawn,
                    border: Border.all(
                      color: filled
                          ? AppColors.brandBrass
                          : AppColors.brandBrassDeep,
                    ),
                  ),
                );
              }),
            ),
          ),
          // Numeric rank
          SizedBox(
            width: AppSpacing.s6,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // − / +
          _StepperButton(
            icon: '−',
            enabled: canDecrement,
            onTap: onDecrement,
          ),
          const SizedBox(width: 4),
          _StepperButton(
            icon: '+',
            enabled: canIncrement,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}
