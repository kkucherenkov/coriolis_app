import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:app_mobile/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:app_mobile/i18n/strings.g.dart';
import 'step_1_concept.dart' show _StepHeader;

/// Wizard step 4 — Attribute distribution.
///
/// - 4 stepper rows (Strength / Agility / Wits / Empathy).
/// - Point pool: 13 total, min 2, max 5 per attribute.
/// - Running "points remaining" counter.
class Step4Attributes extends StatelessWidget {
  const Step4Attributes({super.key});

  static const int _total = 13;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return BlocBuilder<CharacterWizardCubit, CharacterWizardState>(
      buildWhen: (p, n) =>
          p.draft.strength != n.draft.strength ||
          p.draft.agility != n.draft.agility ||
          p.draft.wits != n.draft.wits ||
          p.draft.empathy != n.draft.empathy,
      builder: (context, state) {
        final d = state.draft;
        final spent = d.attributePointsSpent;
        final remaining = _total - spent;

        final attrs = [
          (key: 'strength', label: t.attrStrengthFull, abbr: t.attrStrength, value: d.strength ?? 2),
          (key: 'agility', label: t.attrAgilityFull, abbr: t.attrAgility, value: d.agility ?? 2),
          (key: 'wits', label: t.attrWitsFull, abbr: t.attrWits, value: d.wits ?? 2),
          (key: 'empathy', label: t.attrEmpathyFull, abbr: t.attrEmpathy, value: d.empathy ?? 2),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepHeader(
                title: t.wizardStep4Title,
                blurb: t.wizardStep4Blurb,
              ),
              const SizedBox(height: AppSpacing.s4),
              // ── Point pool banner ──────────────────────────────────────
              _PointPoolBanner(
                label: t.wizardAttrPointsRemaining,
                remaining: remaining,
                total: _total,
              ),
              const SizedBox(height: AppSpacing.s4),
              // ── Attribute rows ──────────────────────────────────────────
              ...attrs.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s3),
                    child: _AttributeRow(
                      label: a.label,
                      abbr: a.abbr,
                      value: a.value,
                      canIncrement: remaining > 0 && a.value < 5,
                      canDecrement: a.value > 2,
                      onIncrement: () => context
                          .read<CharacterWizardCubit>()
                          .updateAttribute(a.key, 1),
                      onDecrement: () => context
                          .read<CharacterWizardCubit>()
                          .updateAttribute(a.key, -1),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}

/// Point-pool status banner.
class _PointPoolBanner extends StatelessWidget {
  const _PointPoolBanner({
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

/// One attribute row: label / stepper dots / value / − + buttons.
class _AttributeRow extends StatelessWidget {
  const _AttributeRow({
    required this.label,
    required this.abbr,
    required this.value,
    required this.canIncrement,
    required this.canDecrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String label;
  final String abbr;
  final int value;
  final bool canIncrement;
  final bool canDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s3,
      ),
      child: Row(
        children: [
          // Label + abbreviation
          SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.brandBrassLight,
                  ),
                ),
                Text(
                  abbr,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 10,
                    letterSpacing: 0.16 * 10,
                    color: AppColors.brandBrass,
                  ),
                ),
              ],
            ),
          ),
          // Stepper dots (5 max)
          Expanded(
            child: Wrap(
              spacing: AppSpacing.s1,
              children: List.generate(5, (i) {
                final filled = i < value;
                return Container(
                  width: AppSpacing.s3,
                  height: AppSpacing.s3,
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
          // Numeric value
          SizedBox(
            width: AppSpacing.s7,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTypography.monoStatMd.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // − / + buttons
          _StepperButton(
            icon: '−',
            enabled: canDecrement,
            onTap: onDecrement,
          ),
          const SizedBox(width: AppSpacing.s1),
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

/// Small stepper button (−/+). Tap target ≥ 44×44.
class _StepperButton extends StatelessWidget {
  const _StepperButton({
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
