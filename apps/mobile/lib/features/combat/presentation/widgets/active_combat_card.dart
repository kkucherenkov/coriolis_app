import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/combat/domain/combatant.dart';
import 'package:coriolis_companion/features/combat/domain/encounter.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/active_combat/active_combat_cubit.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

/// Read-only card that reflects the current [ActiveCombatState].
///
/// - [ActiveCombatLoading] → spinner.
/// - [ActiveCombatEmpty]   → empty-state illustration.
/// - [ActiveCombatError]   → error heading + retry button.
/// - [ActiveCombatReady]   → header row + combatant list.
///
/// The card does NOT own the cubit — mount [BlocProvider] above in
/// [SessionDetailPage] and pass [sessionId] for the retry callback.
class ActiveCombatCard extends StatelessWidget {
  const ActiveCombatCard({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveCombatCubit, ActiveCombatState>(
      builder: (context, state) {
        return switch (state) {
          ActiveCombatLoading() => _LoadingView(),
          ActiveCombatEmpty() => _EmptyView(),
          ActiveCombatError(:final message) =>
            _ErrorView(message: message, sessionId: sessionId),
          ActiveCombatReady(:final snapshot) => _ReadyView(
              encounter: snapshot.encounter,
              combatants: snapshot.combatants,
            ),
        };
      },
    );
  }
}

// ── Loading ──────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s4),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

// ── Empty ────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 40,
            color: AppColors.brandBrassDeep,
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            t.emptyHeading,
            style: AppTypography.displaySm.copyWith(
              color: AppColors.brandBrassLight,
              fontSize: 16,
              letterSpacing: 0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(
            t.emptyBody,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Error ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.sessionId});

  final String message;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.errorHeading,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.stateCrimsonBright,
              fontWeight: AppFontWeight.semibold,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            message,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s3),
          TextButton(
            onPressed: () =>
                context.read<ActiveCombatCubit>().load(sessionId),
            child: Text(
              t.retryButton,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.brandBrass,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ready ────────────────────────────────────────────────────────────────────

class _ReadyView extends StatelessWidget {
  const _ReadyView({
    required this.encounter,
    required this.combatants,
  });

  final Encounter encounter;
  final List<Combatant> combatants;

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;

    // Sort by turnOrder; nulls last.
    final sorted = List<Combatant>.from(combatants)
      ..sort((a, b) {
        final ao = a.turnOrder;
        final bo = b.turnOrder;
        if (ao == null && bo == null) return 0;
        if (ao == null) return 1;
        if (bo == null) return -1;
        return ao.compareTo(bo);
      });

    return AppCard(
      header: _Header(encounter: encounter),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sorted.isEmpty)
            Text(
              t.emptyBody,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            for (final combatant in sorted) ...[
              _CombatantRow(
                combatant: combatant,
                isActive: combatant.id == encounter.activeCombatantId,
              ),
              if (combatant != sorted.last)
                const Divider(
                  height: 1,
                  color: AppColors.brandBrassDeep,
                ),
            ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.encounter});

  final Encounter encounter;

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;
    final statePill = _statePill(encounter.state, t);
    final isEnded = encounter.state == 'ended';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.cardTitle.toUpperCase(),
                style: AppTypography.displaySm.copyWith(
                  color: AppColors.brandBrassLight,
                  fontSize: 12,
                  letterSpacing: 0.08 * 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                encounter.name,
                style: AppTypography.bodyMd.copyWith(
                  color: isEnded
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.s2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            statePill,
            if (encounter.round > 0) ...[
              const SizedBox(height: 2),
              Text(
                '${t.roundLabel} ${encounter.round}',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _statePill(String state, TranslationsCombatEn t) {
    final (label, tone) = switch (state) {
      'setup' => (t.stateSetup, AppBadgeTone.brass),
      'active' => (t.stateActive, AppBadgeTone.success),
      'ended' => (t.stateEnded, AppBadgeTone.darkness),
      _ => (t.stateUnknown, AppBadgeTone.brass),
    };
    return AppBadge(label: label, tone: tone, size: AppBadgeSize.sm);
  }
}

class _CombatantRow extends StatelessWidget {
  const _CombatantRow({
    required this.combatant,
    required this.isActive,
  });

  final Combatant combatant;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active-turn indicator.
          SizedBox(
            width: AppSpacing.s3,
            child: isActive
                ? Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: const BoxDecoration(
                      color: AppColors.stateSuccess,
                      shape: BoxShape.circle,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: AppSpacing.s1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  combatant.displayName,
                  style: AppTypography.bodySm.copyWith(
                    color: isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: isActive
                        ? AppFontWeight.semibold
                        : AppFontWeight.regular,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _StatLabel(label: t.hp, value: combatant.hpCurrent, max: combatant.hpMax),
                    const SizedBox(width: AppSpacing.s3),
                    _StatLabel(label: t.mp, value: combatant.signature, max: null),
                  ],
                ),
                if (combatant.statusFlags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s1),
                  Wrap(
                    spacing: AppSpacing.s1,
                    runSpacing: 2,
                    children: combatant.statusFlags
                        .map((f) => _StatusFlag(flag: f))
                        .toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  const _StatLabel({
    required this.label,
    required this.value,
    required this.max,
  });

  final String label;
  final int value;
  final int? max;

  @override
  Widget build(BuildContext context) {
    final display = max != null ? '$value/$max' : '$value';
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.brandBrassDeep,
              fontSize: 11,
              fontWeight: AppFontWeight.medium,
            ),
          ),
          TextSpan(
            text: display,
            style: AppTypography.monoStatMd.copyWith(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFlag extends StatelessWidget {
  const _StatusFlag({required this.flag});

  final String flag;

  static const _canonicalIcons = <String, IconData>{
    'incapacitated': Icons.personal_injury_outlined,
    'prone': Icons.airline_seat_flat_outlined,
    'covered': Icons.shield_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;
    final icon = _canonicalIcons[flag];

    final label = switch (flag) {
      'incapacitated' => t.flagIncapacitated,
      'prone' => t.flagProne,
      'covered' => t.flagCovered,
      _ => flag,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.stateCrimson.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.stateCrimson),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 10,
              color: AppColors.stateCrimsonBright,
            ),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              fontSize: 10,
              color: AppColors.stateCrimsonBright,
              fontWeight: AppFontWeight.medium,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
