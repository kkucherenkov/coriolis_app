import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/combat/domain/combatant.dart';
import 'package:coriolis_companion/features/combat/domain/encounter.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/active_combat/active_combat_cubit.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';

/// Combat tracker page — parity with web `CombatTracker.vue`.
///
/// Layout:
///  - AppBar: encounter name + round badge + DP chip
///  - Body: initiative list (active row highlighted) with HP/MP + flags
///  - bottomNavigationBar: sticky toolbar (Roll Initiative / Next Turn /
///    End Encounter), GM-gated, state-driven
///
/// Owns its own [ActiveCombatCubit] via [getIt] — the session-detail
/// page's cubit does NOT survive the route push.
///
/// Follow-ups (deliberately deferred from Block 1):
///  - End-Round shortcut (single tap that advances until `isNewRound`)
///  - DP +/- controls (currently GM uses session detail for this)
///  - Combatant add / remove / status flag toggles
///  - Realtime channel re-bind (parent currently owns the subscription)
class CombatTrackerPage extends StatelessWidget {
  /// Resolves the [ActiveCombatCubit] for the production route. Wired by
  /// `routes.dart` so the tracker page itself stays free of `getIt`.
  /// Widget tests inject a seeded cubit via [cubitOverride] and skip this
  /// path entirely.
  const CombatTrackerPage({
    super.key,
    required this.sessionId,
    required this.isGm,
    required this.dpCount,
    this.cubitFactory,
    this.cubitOverride,
  });

  /// Game session that owns the encounter.
  final String sessionId;

  /// Whether the current user is the session GM. Hides write actions when
  /// false — the page becomes a read-only initiative viewer for players.
  final bool isGm;

  /// Session-level Darkness Points count. Read-only here; GM controls live
  /// on the session detail page.
  final int dpCount;

  /// Factory used in production to obtain a fresh cubit and trigger the
  /// initial load. `routes.dart` passes one that calls into `getIt`.
  final ActiveCombatCubit Function()? cubitFactory;

  /// Direct override for widget tests. When non-null the page mounts the
  /// passed cubit via `BlocProvider.value` and bypasses [cubitFactory].
  final ActiveCombatCubit? cubitOverride;

  @override
  Widget build(BuildContext context) {
    final view = _CombatTrackerView(
      sessionId: sessionId,
      isGm: isGm,
      dpCount: dpCount,
    );
    if (cubitOverride != null) {
      return BlocProvider<ActiveCombatCubit>.value(
        value: cubitOverride!,
        child: view,
      );
    }
    final factory = cubitFactory;
    if (factory == null) {
      throw StateError(
        'CombatTrackerPage requires either cubitFactory or cubitOverride',
      );
    }
    return BlocProvider<ActiveCombatCubit>(
      create: (_) => factory()..load(sessionId),
      child: view,
    );
  }
}

class _CombatTrackerView extends StatelessWidget {
  const _CombatTrackerView({
    required this.sessionId,
    required this.isGm,
    required this.dpCount,
  });

  final String sessionId;
  final bool isGm;
  final int dpCount;

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;
    return BlocBuilder<ActiveCombatCubit, ActiveCombatState>(
      builder: (context, state) {
        final encounter = switch (state) {
          ActiveCombatReady(:final snapshot) => snapshot.encounter,
          _ => null,
        };
        return Scaffold(
          backgroundColor: AppColors.surfaceVoid,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceNight,
            title: Text(
              encounter?.name ?? t.trackerTitle,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.brandBrassLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              if (encounter != null && encounter.round > 0)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s2),
                  child: Center(
                    child: AppBadge(
                      label: '${t.roundLabel} ${encounter.round}',
                      tone: AppBadgeTone.brass,
                      size: AppBadgeSize.sm,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s3),
                child: Center(
                  child: Semantics(
                    label: t.semanticsDpChip(value: dpCount),
                    excludeSemantics: true,
                    child: AppBadge(
                      label: '${t.dpChipLabel} $dpCount',
                      tone: AppBadgeTone.darkness,
                      size: AppBadgeSize.sm,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: _Body(state: state, sessionId: sessionId),
          bottomNavigationBar: encounter == null
              ? null
              : _StickyToolbar(
                  encounter: encounter,
                  isGm: isGm,
                  actionInFlight: state is ActiveCombatReady
                      ? state.actionInFlight
                      : false,
                ),
        );
      },
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.sessionId});

  final ActiveCombatState state;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;
    return switch (state) {
      ActiveCombatLoading() => const Center(
          child: CircularProgressIndicator(color: AppColors.brandBrass),
        ),
      ActiveCombatEmpty() => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 48,
                  color: AppColors.brandBrassDeep,
                ),
                const SizedBox(height: AppSpacing.s3),
                Text(
                  t.emptyHeading,
                  style: AppTypography.displaySm.copyWith(
                    color: AppColors.brandBrassLight,
                    fontSize: 18,
                    letterSpacing: 0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  t.emptyBody,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ActiveCombatError(:final message) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.errorHeading,
                  style: AppTypography.bodyMd.copyWith(
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
                    style: AppTypography.bodySm
                        .copyWith(color: AppColors.brandBrass),
                  ),
                ),
              ],
            ),
          ),
        ),
      final ActiveCombatReady ready => _ReadyBody(
          encounter: ready.snapshot.encounter,
          combatants: ready.snapshot.combatants,
          actionError: ready.actionError,
        ),
    };
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({
    required this.encounter,
    required this.combatants,
    required this.actionError,
  });

  final Encounter encounter;
  final List<Combatant> combatants;
  final String? actionError;

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;

    // Sort by turnOrder; nulls last (setup state).
    final sorted = List<Combatant>.from(combatants)
      ..sort((a, b) {
        final ao = a.turnOrder;
        final bo = b.turnOrder;
        if (ao == null && bo == null) return 0;
        if (ao == null) return 1;
        if (bo == null) return -1;
        return ao.compareTo(bo);
      });

    final err = actionError;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s4),
      children: [
        if (err != null) ...[
          AppBanner(
            tone: AppBannerTone.danger,
            child: Text(err),
          ),
          const SizedBox(height: AppSpacing.s3),
        ],
        if (sorted.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
            child: Center(
              child: Text(
                t.trackerNoCombatants,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          ),
        const SizedBox(height: AppSpacing.s8),
      ],
    );
  }
}

// ── Combatant row ───────────────────────────────────────────────────────────

class _CombatantRow extends StatelessWidget {
  const _CombatantRow({required this.combatant, required this.isActive});

  final Combatant combatant;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;

    final nameWidget = isActive
        ? Semantics(
            label: t.semanticsCurrentTurn(name: combatant.displayName),
            liveRegion: true,
            excludeSemantics: true,
            child: Text(
              combatant.displayName,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: AppFontWeight.semibold,
              ),
            ),
          )
        : Text(
            combatant.displayName,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSpacing.s3,
            child: isActive
                ? Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsetsDirectional.only(top: 6),
                    decoration: const BoxDecoration(
                      color: AppColors.stateSuccess,
                      shape: BoxShape.circle,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                nameWidget,
                const SizedBox(height: 2),
                Row(
                  children: [
                    _StatLabel(
                      label: t.hp,
                      value: combatant.hpCurrent,
                      max: combatant.hpMax,
                      semanticsLabel: t.semanticsHp(
                        current: combatant.hpCurrent,
                        max: combatant.hpMax,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    _StatLabel(
                      label: t.mp,
                      value: combatant.signature,
                      max: null,
                      semanticsLabel:
                          t.semanticsMp(value: combatant.signature),
                    ),
                    if (combatant.initiative != null) ...[
                      const SizedBox(width: AppSpacing.s3),
                      _StatLabel(
                        label: t.initiative,
                        value: combatant.initiative!,
                        max: null,
                        semanticsLabel:
                            t.semanticsInitiative(value: combatant.initiative!),
                      ),
                    ],
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
    required this.semanticsLabel,
  });

  final String label;
  final int value;
  final int? max;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final display = max != null ? '$value/$max' : '$value';
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: RichText(
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
                fontSize: 13,
              ),
            ),
          ],
        ),
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

    return Semantics(
      label: t.semanticsStatusPrefix(flag: label),
      excludeSemantics: true,
      child: Container(
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
                size: 11,
                color: AppColors.stateCrimsonBright,
              ),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                fontSize: 11,
                color: AppColors.stateCrimsonBright,
                fontWeight: AppFontWeight.medium,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sticky toolbar ──────────────────────────────────────────────────────────

class _StickyToolbar extends StatelessWidget {
  const _StickyToolbar({
    required this.encounter,
    required this.isGm,
    required this.actionInFlight,
  });

  final Encounter encounter;
  final bool isGm;
  final bool actionInFlight;

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;

    // Players see a read-only viewer; no actions.
    if (!isGm) {
      return const SizedBox.shrink();
    }

    // Encounter is `ended` — no controls.
    if (encounter.state == 'ended') {
      return const SizedBox.shrink();
    }

    final cubit = context.read<ActiveCombatCubit>();

    return Material(
      color: AppColors.surfaceNight,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
          child: Row(
            children: [
              if (encounter.state == 'setup')
                Expanded(
                  child: AppButton(
                    key: const Key('tracker-roll-initiative'),
                    label: t.rollInitiativeButton,
                    onPressed: actionInFlight
                        ? null
                        : () => cubit.rollInitiative(),
                    variant: AppButtonVariant.primary,
                    loading: actionInFlight,
                  ),
                )
              else if (encounter.state == 'active') ...[
                Expanded(
                  child: AppButton(
                    key: const Key('tracker-next-turn'),
                    label: t.nextTurnButton,
                    onPressed:
                        actionInFlight ? null : () => cubit.advanceTurn(),
                    variant: AppButtonVariant.primary,
                    loading: actionInFlight,
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                Expanded(
                  child: AppButton(
                    key: const Key('tracker-end-encounter'),
                    label: t.endEncounterButton,
                    onPressed: actionInFlight
                        ? null
                        : () => _confirmEndEncounter(context, cubit),
                    variant: AppButtonVariant.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmEndEncounter(
    BuildContext context,
    ActiveCombatCubit cubit,
  ) async {
    final t = context.t.combat;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceNight,
        title: Text(
          t.endEncounterConfirmTitle,
          style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          t.endEncounterConfirmBody,
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              t.endEncounterCancel,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.brandBrassLight),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              t.endEncounterConfirm,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.stateCrimsonBright),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await cubit.endEncounter();
    }
  }
}
