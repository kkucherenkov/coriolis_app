import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_1_biography.dart'
    show WizardStepHeader;
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/wizard_shared.dart';

/// Wizard step 5 — Skill distribution.
///
/// One shared pool sized by upbringing (ST3001 ch.2 table 2.4):
/// plebeian 8 / stationary 10 / aristocrat 12. Per-skill cap at
/// creation: 3 ranks for the concept's key skills, 1 rank for
/// every other skill. The visible General / Advanced split below
/// is purely a layout grouping reflecting the ch.3 action-economy
/// rule (advanced skills require ≥1 rank to roll), not a budget
/// partition.
class Step5Skills extends StatelessWidget {
  const Step5Skills({super.key});

  static const Map<String, int> _skillBudget = {
    'plebeian': 8,
    'stationary': 10,
    'aristocrat': 12,
  };

  static const int _defaultBudget = 10; // stationary

  static const int _keySkillMax = 3;
  static const int _nonKeySkillMax = 1;

  static const Map<String, Set<String>> _conceptKeySkills = {
    'artist': {'manipulation', 'culture', 'dexterity', 'observation', 'infiltration'},
    'networker': {'dataDjinn', 'culture', 'manipulation', 'observation', 'infiltration'},
    'fugitive': {'meleeCombat', 'infiltration', 'culture', 'mysticPowers', 'manipulation'},
    'negotiator': {'manipulation', 'culture', 'observation', 'command', 'infiltration'},
    'operative': {'meleeCombat', 'rangedCombat', 'infiltration', 'observation', 'manipulation'},
    'pilot': {'pilot', 'rangedCombat', 'technology', 'observation', 'dataDjinn'},
    'pioneer': {'survival', 'observation', 'technology', 'infiltration', 'science'},
    'preacher': {'culture', 'mysticPowers', 'manipulation', 'command', 'observation'},
    'scientist': {'science', 'culture', 'technology', 'medicurgy', 'dataDjinn'},
    'sailor': {'meleeCombat', 'force', 'technology', 'observation', 'pilot'},
    'soldier': {'rangedCombat', 'meleeCombat', 'force', 'command', 'observation'},
  };

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;

    return BlocBuilder<CharacterWizardCubit, CharacterWizardState>(
      builder: (context, state) {
        final d = state.draft;
        final total = _skillBudget[d.upbringing] ?? _defaultBudget;
        final remaining = total - d.skillPointsSpent;
        final keySet = _conceptKeySkills[d.concept] ?? const <String>{};
        int rankCapFor(String key) =>
            keySet.contains(key) ? _keySkillMax : _nonKeySkillMax;

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
              WizardStepHeader(
                title: t.wizard.step.skills.title,
                blurb: t.wizard.step.skills.blurb,
              ),
              const SizedBox(height: AppSpacing.s4),
              _SkillSection(
                title: t.sectionGeneral.toUpperCase(),
                poolLabel: t.wizardSkillPointsRemaining,
                remaining: remaining,
                total: total,
                skills: generalSkills,
                rankCapFor: rankCapFor,
                canIncrementAny: remaining > 0,
                onChanged: (key, delta) =>
                    context.read<CharacterWizardCubit>().updateSkill(key, delta),
              ),
              const SizedBox(height: AppSpacing.s4),
              _SkillSection(
                title: t.sectionAdvanced.toUpperCase(),
                poolLabel: t.wizardSkillPointsRemaining,
                remaining: remaining,
                total: total,
                skills: advancedSkills,
                rankCapFor: rankCapFor,
                canIncrementAny: remaining > 0,
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
    required this.rankCapFor,
    required this.canIncrementAny,
    required this.onChanged,
  });

  final String title;
  final String poolLabel;
  final int remaining;
  final int total;
  final List<({String key, String label, int value})> skills;
  final int Function(String key) rankCapFor;
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
          ...skills.map((s) {
            final cap = rankCapFor(s.key);
            return _SkillRow(
              label: s.label,
              value: s.value,
              maxRank: cap,
              canIncrement: canIncrementAny && s.value < cap,
              canDecrement: s.value > 0,
              onIncrement: () => onChanged(s.key, 1),
              onDecrement: () => onChanged(s.key, -1),
            );
          }),
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
          WizardStepperButton(
            icon: '−',
            enabled: canDecrement,
            onTap: onDecrement,
          ),
          const SizedBox(width: 4),
          WizardStepperButton(
            icon: '+',
            enabled: canIncrement,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}
