import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:coriolis_companion/features/characters/presentation/blocs/character_sheet/character_sheet_state.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

/// Sticky header rendered inside a [SliverPersistentHeader] (or plain Column
/// inside a scroll view). Displays:
/// - portrait avatar + name + concept
/// - AppSavePulse status dot
/// - HP / MP mini counters
/// - condition chip strip
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.character,
    required this.saveStatus,
  });

  final Character character;
  final CharacterSheetSaveStatus saveStatus;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfaceNight, AppColors.surfaceVoid],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.brandBrassDeep),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s4,
          AppSpacing.s3,
          AppSpacing.s4,
          AppSpacing.s3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AppAvatar(
                  name: character.name,
                  size: AppAvatarSize.sm,
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        style: AppTypography.displaySm.copyWith(
                          color: AppColors.brandBrassLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (character.concept != null &&
                          character.concept!.isNotEmpty)
                        Text(
                          character.concept!,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                // Save pulse dot
                AppSavePulse(
                  state: _toSavePulseState(saveStatus),
                  semanticLabel: _semanticLabel(t, saveStatus),
                ),
                const SizedBox(width: AppSpacing.s3),
                // HP / MP mini counters
                _MiniCounter(
                  label: t.heroHp,
                  current: character.hp.current,
                  max: character.hp.max,
                  isMystic: false,
                ),
                const SizedBox(width: AppSpacing.s3),
                _MiniCounter(
                  label: t.heroMp,
                  current: character.mp.current,
                  max: character.mp.max,
                  isMystic: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s2),
            // Condition chips
            _ConditionStrip(conditions: character.conditions),
          ],
        ),
      ),
    );
  }

  static AppSavePulseState _toSavePulseState(CharacterSheetSaveStatus s) =>
      switch (s) {
        CharacterSheetSaveStatus.idle => AppSavePulseState.idle,
        CharacterSheetSaveStatus.saving => AppSavePulseState.saving,
        CharacterSheetSaveStatus.saved => AppSavePulseState.saved,
        CharacterSheetSaveStatus.error => AppSavePulseState.error,
      };

  static String _semanticLabel(
      TranslationsCharactersEn t, CharacterSheetSaveStatus s) =>
      switch (s) {
        CharacterSheetSaveStatus.idle => t.saveStatusIdle,
        CharacterSheetSaveStatus.saving => t.saveStatusSaving,
        CharacterSheetSaveStatus.saved => t.saveStatusSaved,
        CharacterSheetSaveStatus.error => t.saveStatusError,
      };
}

class _MiniCounter extends StatelessWidget {
  const _MiniCounter({
    required this.label,
    required this.current,
    required this.max,
    required this.isMystic,
  });

  final String label;
  final int current;
  final int max;
  final bool isMystic;

  @override
  Widget build(BuildContext context) {
    final accent =
        isMystic ? AppColors.stateMysticTeal : AppColors.brandBrass;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: accent,
            fontSize: 9,
            letterSpacing: 0.14 * 9,
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$current',
                style: AppTypography.monoStatMd.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: '/$max',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConditionStrip extends StatelessWidget {
  const _ConditionStrip({required this.conditions});

  final CharacterConditions conditions;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    final cubit = context.read<CharacterSheetCubit>();

    final chips = [
      (key: 'exhausted', label: t.conditionExhausted, active: conditions.exhausted),
      (key: 'sleepless', label: t.conditionSleepless, active: conditions.sleepless),
      (key: 'thirsty', label: t.conditionThirsty, active: conditions.thirsty),
      (key: 'hungry', label: t.conditionHungry, active: conditions.hungry),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final chip in chips) ...[
            AppChip(
              label: chip.label,
              isActive: chip.active,
              tone: AppBadgeTone.crimson,
              size: AppBadgeSize.sm,
              onToggle: () => cubit.toggleCondition(chip.key),
            ),
            const SizedBox(width: AppSpacing.s1),
          ],
        ],
      ),
    );
  }
}
