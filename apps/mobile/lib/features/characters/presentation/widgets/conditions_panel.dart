import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:app_mobile/features/characters/domain/character.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:app_mobile/i18n/strings.g.dart';

/// Conditions + Critical Injuries panel for the Stats tab.
///
/// - Conditions: four toggle chips.
/// - Critical injuries: dismissible list rows.
/// - Inline add form at the bottom.
class ConditionsPanel extends StatefulWidget {
  const ConditionsPanel({
    super.key,
    required this.conditions,
    required this.criticalInjuries,
  });

  final CharacterConditions conditions;
  final List<DomainCriticalInjury> criticalInjuries;

  @override
  State<ConditionsPanel> createState() => _ConditionsPanelState();
}

class _ConditionsPanelState extends State<ConditionsPanel> {
  final _injuryController = TextEditingController();

  @override
  void dispose() {
    _injuryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    final cubit = context.read<CharacterSheetCubit>();

    final conditionEntries = [
      (key: 'exhausted', label: t.conditionExhausted, active: widget.conditions.exhausted),
      (key: 'sleepless', label: t.conditionSleepless, active: widget.conditions.sleepless),
      (key: 'thirsty', label: t.conditionThirsty, active: widget.conditions.thirsty),
      (key: 'hungry', label: t.conditionHungry, active: widget.conditions.hungry),
    ];

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conditions section
          Text(
            t.sectionConditions.toUpperCase(),
            style: AppTypography.displaySm.copyWith(
              color: AppColors.brandBrassLight,
              fontSize: 14,
              letterSpacing: 0.08 * 14,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Wrap(
            spacing: AppSpacing.s2,
            runSpacing: AppSpacing.s1,
            children: [
              for (final c in conditionEntries)
                AppChip(
                  label: c.label,
                  isActive: c.active,
                  tone: AppBadgeTone.crimson,
                  size: AppBadgeSize.sm,
                  onToggle: () => cubit.toggleCondition(c.key),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          // Critical injuries section
          Text(
            t.sectionCriticalInjuries.toUpperCase(),
            style: AppTypography.displaySm.copyWith(
              color: AppColors.brandBrassLight,
              fontSize: 14,
              letterSpacing: 0.08 * 14,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          if (widget.criticalInjuries.isEmpty)
            const SizedBox.shrink()
          else
            ...widget.criticalInjuries.asMap().entries.map((entry) {
              final idx = entry.key;
              final injury = entry.value;
              return _InjuryRow(
                injury: injury,
                onRemove: () => cubit.removeCriticalInjury(idx),
              );
            }),
          const SizedBox(height: AppSpacing.s2),
          // Add injury inline form
          Row(
            children: [
              Expanded(
                child: AppInput(
                  controller: _injuryController,
                  hintText: t.addInjuryHint,
                  size: AppInputSize.sm,
                  onSubmitted: (_) => _addInjury(cubit),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              AppButton(
                label: t.addInjuryButton,
                size: AppButtonSize.sm,
                onPressed: () => _addInjury(cubit),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addInjury(CharacterSheetCubit cubit) {
    final name = _injuryController.text.trim();
    if (name.isEmpty) return;
    cubit.addCriticalInjury(name);
    _injuryController.clear();
  }
}

class _InjuryRow extends StatelessWidget {
  const _InjuryRow({required this.injury, required this.onRemove});

  final DomainCriticalInjury injury;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s1),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: AppSpacing.s2),
            decoration: const BoxDecoration(
              color: AppColors.stateCrimson,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              injury.name,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Remove ${injury.name}',
            child: GestureDetector(
              onTap: onRemove,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Icon(
                    Icons.close,
                    color: AppColors.stateCrimsonBright,
                    size: AppSpacing.s4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
