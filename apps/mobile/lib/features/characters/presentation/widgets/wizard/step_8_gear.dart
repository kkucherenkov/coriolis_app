import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/data/starter_kits_catalog.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_wizard/character_wizard_state.dart';
import 'package:coriolis_companion/features/characters/presentation/widgets/wizard/step_1_biography.dart'
    show WizardStepHeader;
import 'package:coriolis_companion/i18n/strings.g.dart';

/// Wizard Step 8 — Gear.
///
/// Renders the per-amplua starter-kit picker sourced from
/// [kStarterKitCatalog]. Five rows × two options each; player picks one
/// per row (all rows are optional — Step 8 is lenient).
///
/// Picks are memory-only until [CharacterWizardCubit.forge] fires.
class Step8Gear extends StatelessWidget {
  const Step8Gear({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return BlocBuilder<CharacterWizardCubit, CharacterWizardState>(
      buildWhen: (p, n) =>
          p.draft.concept != n.draft.concept ||
          p.draft.role != n.draft.role ||
          p.draft.pendingGearPicks != n.draft.pendingGearPicks,
      builder: (context, state) {
        final kit = (state.draft.concept != null && state.draft.role != null)
            ? findStarterKit(state.draft.concept!, state.draft.role!)
            : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WizardStepHeader(
                title: t.wizard.step.gear.title,
                blurb: t.wizard.step.gear.blurb,
              ),
              const SizedBox(height: AppSpacing.s4),
              if (kit == null) ...[
                _PlaceholderCard(message: t.wizard.step.gear.placeholderNoConcept),
              ] else ...[
                for (final choice in kit.choices) ...[
                  _GearRow(
                    choice: choice,
                    pickedOptionId: state.draft.pendingGearPicks[choice.id],
                    onPick: (optionId) => context
                        .read<CharacterWizardCubit>()
                        .selectGearPick(choice.id, optionId),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                ],
                const SizedBox(height: AppSpacing.s2),
                _ProgressCounter(
                  picked: state.draft.pendingGearPicks.values
                      .where((v) => v != null)
                      .length,
                  total: kit.choices.length,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Placeholder ──────────────────────────────────────────────────────────────

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.defaultVariant,
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              color: AppColors.brandBrassLight, size: 20),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── One gear-choice row ───────────────────────────────────────────────────────

class _GearRow extends StatelessWidget {
  const _GearRow({
    required this.choice,
    required this.pickedOptionId,
    required this.onPick,
  });

  final StarterKitChoice choice;
  final String? pickedOptionId;
  final void Function(String? optionId) onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRow = constraints.maxWidth >= 480;
        final cards = choice.options
            .map(
              (option) => _GearOptionCard(
                option: option,
                isPicked: pickedOptionId == option.id,
                onTap: () => onPick(option.id),
              ),
            )
            .toList();

        if (useRow) {
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: AppSpacing.s3),
              Expanded(child: cards[1]),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cards[0],
              const SizedBox(height: AppSpacing.s2),
              cards[1],
            ],
          );
        }
      },
    );
  }
}

// ── One option card ───────────────────────────────────────────────────────────

class _GearOptionCard extends StatelessWidget {
  const _GearOptionCard({
    required this.option,
    required this.isPicked,
    required this.onTap,
  });

  final StarterKitItem option;
  final bool isPicked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = LocaleSettings.currentLocale.languageCode;
    final displayName = pickStarterKitItemName(option, locale);
    final kindLabel = _kindLabel(context, option.template.kind);

    return Semantics(
      button: true,
      selected: isPicked,
      label: '$displayName, $kindLabel',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: AppCard(
          variant: isPicked
              ? AppCardVariant.featured
              : AppCardVariant.defaultVariant,
          padding: const EdgeInsets.all(AppSpacing.s3),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTypography.bodySm.copyWith(
                        color: isPicked
                            ? AppColors.brandBrassLight
                            : AppColors.textPrimary,
                        fontWeight: isPicked
                            ? AppFontWeight.semibold
                            : AppFontWeight.regular,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _KindBadge(label: kindLabel, kind: option.template.kind),
                  ],
                ),
              ),
              if (isPicked) ...[
                const SizedBox(width: AppSpacing.s2),
                const Icon(
                  Icons.check_circle,
                  color: AppColors.stateMysticTeal,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _kindLabel(BuildContext context, StarterKitItemKind kind) {
    final g = context.t.characters.wizard.step.gear.kind;
    return switch (kind) {
      StarterKitItemKind.weapon => g.weapon,
      StarterKitItemKind.armor => g.armor,
      StarterKitItemKind.gear => g.gear,
      StarterKitItemKind.cybernetic => g.cybernetic,
      StarterKitItemKind.other => g.other,
    };
  }
}

// ── Kind badge ────────────────────────────────────────────────────────────────

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.label, required this.kind});

  final String label;
  final StarterKitItemKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: _badgeColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTypography.bodySm.copyWith(
          fontSize: 10,
          color: _badgeColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Color get _badgeColor => switch (kind) {
        StarterKitItemKind.weapon => AppColors.stateCrimson,
        StarterKitItemKind.armor => AppColors.brandBrass,
        StarterKitItemKind.gear => AppColors.stateMysticTeal,
        StarterKitItemKind.cybernetic => AppColors.brandBrassLight,
        StarterKitItemKind.other => AppColors.textSecondary,
      };
}

// ── Progress counter ──────────────────────────────────────────────────────────

class _ProgressCounter extends StatelessWidget {
  const _ProgressCounter({required this.picked, required this.total});

  final int picked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters.wizard.step.gear;
    return Text(
      t.progress(picked: picked, total: total),
      textAlign: TextAlign.center,
      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
    );
  }
}
