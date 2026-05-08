import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

import 'package:app_mobile/features/characters/domain/character.dart';
import 'package:app_mobile/features/characters/presentation/blocs/character_sheet/character_sheet_cubit.dart';
import 'package:app_mobile/i18n/strings.g.dart';

/// HP / MP / Encumbrance counters rendered as a horizontal row of cards.
///
/// Each counter has − and + buttons (minimum tap target 44×44) clamped to
/// [0, max]. Encumbrance is read-only (derived by the rules engine) but shows
/// a warning when at capacity.
class HeroCounters extends StatelessWidget {
  const HeroCounters({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final t = context.t.characters;
    final cubit = context.read<CharacterSheetCubit>();

    return Row(
      children: [
        Expanded(
          child: _CounterCard(
            label: t.heroHp,
            current: character.hp.current,
            max: character.hp.max,
            accent: AppColors.stateCrimsonBright,
            onDecrement: () => cubit.adjustHp(-1),
            onIncrement: () => cubit.adjustHp(1),
          ),
        ),
        const SizedBox(width: AppSpacing.s2),
        Expanded(
          child: _CounterCard(
            label: t.heroMp,
            current: character.mp.current,
            max: character.mp.max,
            accent: AppColors.stateMysticTeal,
            onDecrement: () => cubit.adjustMp(-1),
            onIncrement: () => cubit.adjustMp(1),
          ),
        ),
        const SizedBox(width: AppSpacing.s2),
        Expanded(
          child: _EncumbranceCard(
            label: t.heroEnc,
            current: character.encumbrance.current,
            max: character.encumbrance.max,
            warningLabel: t.encumbranceWarning,
          ),
        ),
      ],
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.label,
    required this.current,
    required this.max,
    required this.accent,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int current;
  final int max;
  final Color accent;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: AppSpacing.s3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: accent,
              fontSize: 10,
              letterSpacing: 0.14 * 10,
            ),
          ),
          const SizedBox(height: AppSpacing.s1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CounterButton(
                icon: Icons.remove,
                onTap: current > 0 ? onDecrement : null,
              ),
              const SizedBox(width: AppSpacing.s2),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$current',
                      style: AppTypography.monoStatMd.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: '/$max',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              _CounterButton(
                icon: Icons.add,
                onTap: current < max ? onIncrement : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EncumbranceCard extends StatelessWidget {
  const _EncumbranceCard({
    required this.label,
    required this.current,
    required this.max,
    required this.warningLabel,
  });

  final String label;
  final num current;
  final int max;
  final String warningLabel;

  bool get _isOverloaded => current >= max;

  @override
  Widget build(BuildContext context) {
    final accent = _isOverloaded ? AppColors.stateCrimsonBright : AppColors.brandBrass;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: AppSpacing.s3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: accent,
              fontSize: 10,
              letterSpacing: 0.14 * 10,
            ),
          ),
          const SizedBox(height: AppSpacing.s1),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$current',
                  style: AppTypography.monoStatMd.copyWith(color: AppColors.textPrimary),
                ),
                TextSpan(
                  text: '/$max',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (_isOverloaded) ...[
            const SizedBox(height: AppSpacing.s1),
            Text(
              warningLabel,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.stateCrimsonBright,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Small icon button that enforces a 44×44 minimum tap target.
class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Opacity(
              opacity: onTap != null ? AppOpacity.o100 : AppOpacity.disabled,
              child: Icon(
                icon,
                color: AppColors.brandBrass,
                size: AppSpacing.s4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
