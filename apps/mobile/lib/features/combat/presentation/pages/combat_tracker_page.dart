import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/characters/domain/character_repository.dart';
import 'package:coriolis_companion/features/characters/domain/character_summary.dart';
import 'package:coriolis_companion/features/npcs/domain/npc_repository.dart';
import 'package:coriolis_companion/features/npcs/domain/npc_summary.dart';
import 'package:coriolis_companion/features/combat/domain/combatant.dart';
import 'package:coriolis_companion/features/combat/domain/encounter.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/active_combat/active_combat_cubit.dart';
import 'package:coriolis_companion/features/combat/presentation/blocs/tracker_dp/tracker_dp_cubit.dart';
import 'package:coriolis_companion/features/sessions/domain/session_repository.dart';
import 'package:coriolis_companion/i18n/strings.g.dart';
import 'package:coriolis_companion/shared/di/injector.dart';
import 'package:coriolis_companion/shared/realtime/session_realtime.dart';
import 'package:app_api_client/app_api_client.dart' as api_client show RealtimeApi;
import 'package:coriolis_companion/shared/config/app_config.dart';
import 'dart:async';

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
    this.sessionCharacterIds = const [],
    this.cubitFactory,
    this.cubitOverride,
    this.dpCubitOverride,
    this.realtimeFactory,
    this.disableRealtime = false,
  });

  /// Game session that owns the encounter.
  final String sessionId;

  /// Whether the current user is the session GM. Hides write actions when
  /// false — the page becomes a read-only initiative viewer for players.
  final bool isGm;

  /// Session-level Darkness Points count. Read-only here; GM controls live
  /// on the session detail page.
  final int dpCount;

  /// Character ids assigned to the parent session. The Add-Combatant picker
  /// filters the user's character list by this set.
  final List<String> sessionCharacterIds;

  /// Factory used in production to obtain a fresh cubit and trigger the
  /// initial load. `routes.dart` passes one that calls into `getIt`.
  final ActiveCombatCubit Function()? cubitFactory;

  /// Direct override for widget tests. When non-null the page mounts the
  /// passed cubit via `BlocProvider.value` and bypasses [cubitFactory].
  final ActiveCombatCubit? cubitOverride;

  /// Optional override for the DP cubit. When null the page resolves the
  /// session repository via [getIt] and seeds the cubit with [dpCount].
  final TrackerDpCubit? dpCubitOverride;

  /// Optional factory for the realtime adapter used by the tracker. When
  /// null the page resolves `RealtimeApi` + `AppConfig` via [getIt] and
  /// builds a fresh [SessionRealtime]. Widget tests pass a stub here or
  /// set [disableRealtime] to skip the binding entirely.
  final SessionRealtime Function()? realtimeFactory;

  /// When true the page skips the realtime binding entirely. Used by
  /// widget tests where no Centrifugo client is available.
  final bool disableRealtime;

  @override
  Widget build(BuildContext context) {
    final view = _CombatTrackerView(
      sessionId: sessionId,
      isGm: isGm,
      sessionCharacterIds: sessionCharacterIds,
      realtimeFactory: disableRealtime
          ? null
          : (realtimeFactory ?? _defaultRealtimeFactory),
    );
    final dp = dpCubitOverride ?? _defaultDpCubit();
    if (cubitOverride != null) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<ActiveCombatCubit>.value(value: cubitOverride!),
          BlocProvider<TrackerDpCubit>.value(value: dp),
        ],
        child: view,
      );
    }
    final factory = cubitFactory;
    if (factory == null) {
      throw StateError(
        'CombatTrackerPage requires either cubitFactory or cubitOverride',
      );
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<ActiveCombatCubit>(
          create: (_) => factory()..load(sessionId),
        ),
        BlocProvider<TrackerDpCubit>.value(value: dp),
      ],
      child: view,
    );
  }

  /// Production DP cubit — uses `getIt` to resolve `SessionRepository`.
  /// Widget tests inject [dpCubitOverride] instead.
  TrackerDpCubit _defaultDpCubit() => TrackerDpCubit(
        repository: getIt<SessionRepository>(),
        sessionId: sessionId,
        initialCount: dpCount,
      );

  /// Production realtime factory — pulls `RealtimeApi` + `AppConfig` from
  /// the injector. Each call mints a fresh [SessionRealtime] so the
  /// tracker owns its own subscription independently of the session
  /// detail page (which keeps its own subscription alive in the back stack).
  static SessionRealtime _defaultRealtimeFactory() => SessionRealtime(
        realtimeApi: getIt<api_client.RealtimeApi>(),
        config: getIt<AppConfig>(),
      );
}

class _CombatTrackerView extends StatefulWidget {
  const _CombatTrackerView({
    required this.sessionId,
    required this.isGm,
    required this.sessionCharacterIds,
    required this.realtimeFactory,
  });

  final String sessionId;
  final bool isGm;
  final List<String> sessionCharacterIds;

  /// Builds the realtime adapter; null disables the binding (widget tests).
  final SessionRealtime Function()? realtimeFactory;

  @override
  State<_CombatTrackerView> createState() => _CombatTrackerViewState();
}

class _CombatTrackerViewState extends State<_CombatTrackerView> {
  SessionRealtime? _realtime;
  StreamSubscription<CombatUpdatedPayload>? _combatSub;
  StreamSubscription<DpChangedPayload>? _dpSub;

  @override
  void initState() {
    super.initState();
    final factory = widget.realtimeFactory;
    if (factory == null) return;
    // Bind realtime in a post-frame callback so the cubits are mounted by
    // the time the first publication arrives.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final realtime = factory();
      _realtime = realtime;
      _combatSub = realtime.combatUpdated.listen(_onCombatUpdated);
      _dpSub = realtime.dpChanged.listen(_onDpChanged);
      try {
        await realtime.start(widget.sessionId);
      } on Object {
        // Live updates being unavailable shouldn't sink the page; the
        // initial load already populated the snapshot. Errors during the
        // session lifetime surface via the existing error banners.
      }
    });
  }

  @override
  void dispose() {
    _combatSub?.cancel();
    _dpSub?.cancel();
    // The realtime client owns the websocket — close it explicitly so the
    // session detail's own subscription remains the canonical one once
    // the tracker is popped.
    unawaited(_realtime?.dispose());
    super.dispose();
  }

  void _onCombatUpdated(CombatUpdatedPayload payload) {
    if (!mounted || payload.snapshot.encounter.sessionId != widget.sessionId) {
      return;
    }
    context.read<ActiveCombatCubit>().replaceSnapshot(payload.snapshot);
  }

  void _onDpChanged(DpChangedPayload payload) {
    if (!mounted || payload.gameSessionId != widget.sessionId) return;
    context.read<TrackerDpCubit>().applyDpChanged(payload.dpCount);
  }

  String get sessionId => widget.sessionId;
  bool get isGm => widget.isGm;
  List<String> get sessionCharacterIds => widget.sessionCharacterIds;

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
                padding: const EdgeInsets.only(right: AppSpacing.s2),
                child: Center(
                  child: _DpControls(isGm: isGm),
                ),
              ),
              // Add Combatant action — GM-gated; hidden once the encounter
              // has ended (it would 422). Live for both setup and active
              // statuses since the server allows roster mutations through
              // both before initiative is rolled and during play.
              if (isGm &&
                  encounter != null &&
                  encounter.state != 'ended')
                IconButton(
                  key: const Key('tracker-add-combatant'),
                  icon: const Icon(Icons.person_add_alt_1_outlined,
                      color: AppColors.brandBrassLight),
                  tooltip: t.addCombatantTooltip,
                  onPressed: () => _openAddCombatant(context),
                ),
            ],
          ),
          body: _Body(
            state: state,
            sessionId: sessionId,
            isGm: isGm,
          ),
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

  Future<void> _openAddCombatant(BuildContext context) async {
    final cubit = context.read<ActiveCombatCubit>();
    final state = cubit.state;
    if (state is! ActiveCombatReady) return;
    final existingSourceIds = {
      for (final c in state.snapshot.combatants) c.sourceId,
    };
    final pick = await showModalBottomSheet<_AddCombatantPick>(
      context: context,
      backgroundColor: AppColors.surfaceNight,
      isScrollControlled: true,
      builder: (_) => _AddCombatantSheet(
        sessionCharacterIds: sessionCharacterIds,
        existingSourceIds: existingSourceIds,
      ),
    );
    if (pick == null || !context.mounted) return;
    if (pick.kind == 'pc') {
      await cubit.addPcCombatant(pick.sourceId);
    } else {
      await cubit.addNpcCombatant(pick.sourceId);
    }
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.sessionId,
    required this.isGm,
  });

  final ActiveCombatState state;
  final String sessionId;
  final bool isGm;

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
          isGm: isGm,
        ),
    };
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({
    required this.encounter,
    required this.combatants,
    required this.actionError,
    required this.isGm,
  });

  final Encounter encounter;
  final List<Combatant> combatants;
  final String? actionError;
  final bool isGm;

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
                    isGm: isGm,
                    encounterEnded: encounter.state == 'ended',
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
  const _CombatantRow({
    required this.combatant,
    required this.isActive,
    required this.isGm,
    required this.encounterEnded,
  });

  final Combatant combatant;
  final bool isActive;
  final bool isGm;
  final bool encounterEnded;

  static const _canonicalFlags = <String>['incapacitated', 'prone', 'covered'];

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

    final canEditFlags = isGm && !encounterEnded;
    final canRemove = isGm && !encounterEnded;

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
                const SizedBox(height: AppSpacing.s1),
                Wrap(
                  spacing: AppSpacing.s1,
                  runSpacing: 2,
                  children: [
                    // Canonical toggleable chips (GM only). Players see the
                    // current set in the same chips but they're inert.
                    for (final flag in _canonicalFlags)
                      _StatusFlag(
                        key: Key(
                            'tracker-combatant-${combatant.id}-flag-$flag'),
                        flag: flag,
                        active: combatant.statusFlags.contains(flag),
                        onTap: canEditFlags
                            ? () => context
                                .read<ActiveCombatCubit>()
                                .toggleCanonicalFlag(
                                  combatantId: combatant.id,
                                  flag: flag,
                                )
                            : null,
                      ),
                    // Free-form server-side flags surface as inert chips.
                    for (final freeform in combatant.statusFlags
                        .where((f) => !_canonicalFlags.contains(f)))
                      _StatusFlag(flag: freeform, active: true),
                  ],
                ),
              ],
            ),
          ),
          if (canRemove)
            IconButton(
              key: Key('tracker-combatant-${combatant.id}-remove'),
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.stateCrimsonBright, size: 18),
              tooltip: t.removeCombatantTooltip,
              onPressed: () => context
                  .read<ActiveCombatCubit>()
                  .removeCombatant(combatant.id),
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
  const _StatusFlag({
    super.key,
    required this.flag,
    this.active = true,
    this.onTap,
  });

  final String flag;

  /// When false the chip renders muted to indicate the flag is not set
  /// on the current combatant — used for the canonical-flag toggle chips
  /// that always appear in the row, even when inactive.
  final bool active;

  /// Tap callback. When null the chip is inert (player viewer, or a
  /// free-form chip that doesn't toggle).
  final VoidCallback? onTap;

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

    final color = active
        ? AppColors.stateCrimsonBright
        : AppColors.brandBrassDeep;
    final bg = active
        ? AppColors.stateCrimson.withValues(alpha: 0.12)
        : AppColors.surfaceNight.withValues(alpha: 0.4);
    final borderColor = active
        ? AppColors.stateCrimson
        : AppColors.brandBrassDeep;

    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              fontSize: 11,
              color: color,
              fontWeight: AppFontWeight.medium,
              height: 1,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label: t.semanticsStatusPrefix(flag: label),
      excludeSemantics: true,
      button: onTap != null,
      child: onTap == null
          ? chip
          : GestureDetector(onTap: onTap, child: chip),
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
                    key: const Key('tracker-end-round'),
                    label: t.endRoundButton,
                    onPressed: actionInFlight
                        ? null
                        : () => _confirmEndRound(context, cubit, encounter),
                    variant: AppButtonVariant.secondary,
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

  Future<void> _confirmEndRound(
    BuildContext context,
    ActiveCombatCubit cubit,
    Encounter encounter,
  ) async {
    final t = context.t.combat;
    final nextRound = encounter.round + 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceNight,
        title: Text(
          t.endRoundConfirmTitle,
          style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          t.endRoundConfirmBody(next: nextRound),
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              t.endRoundConfirmCancel,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.brandBrassLight),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              t.endRoundConfirm,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.stateCrimsonBright),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await cubit.advanceRound();
    }
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

// ── DP +/- controls ────────────────────────────────────────────────────────

class _DpControls extends StatelessWidget {
  const _DpControls({required this.isGm});

  /// Player viewer surfaces just the read-only chip. GM gets the
  /// `-1` / `+1` IconButtons flanking it.
  final bool isGm;

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;
    return BlocConsumer<TrackerDpCubit, TrackerDpState>(
      listenWhen: (prev, next) => prev.errorMessage != next.errorMessage,
      listener: (context, state) {
        final err = state.errorMessage;
        if (err != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err)),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<TrackerDpCubit>();
        final chip = Semantics(
          label: t.semanticsDpChip(value: state.count),
          excludeSemantics: true,
          child: AppBadge(
            label: '${t.dpChipLabel} ${state.count}',
            tone: AppBadgeTone.darkness,
            size: AppBadgeSize.sm,
          ),
        );
        if (!isGm) return chip;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('tracker-dp-minus'),
              icon: const Icon(Icons.remove,
                  size: 18, color: AppColors.brandBrassLight),
              tooltip: t.dpDecrementTooltip,
              onPressed:
                  state.busy || state.count <= 0
                      ? null
                      : () => cubit.adjustDp(-1),
              constraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
            chip,
            IconButton(
              key: const Key('tracker-dp-plus'),
              icon: const Icon(Icons.add,
                  size: 18, color: AppColors.brandBrassLight),
              tooltip: t.dpIncrementTooltip,
              onPressed: state.busy ? null : () => cubit.adjustDp(1),
              constraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        );
      },
    );
  }
}

// ── Add Combatant picker result ───────────────────────────────────────────────

/// Discriminated result returned by [_AddCombatantSheet].
class _AddCombatantPick {
  const _AddCombatantPick({required this.kind, required this.sourceId});

  /// `'pc'` for a player character, `'npc'` for an NPC.
  final String kind;
  final String sourceId;
}

// ── Add Combatant sheet ────────────────────────────────────────────────────

class _AddCombatantSheet extends StatefulWidget {
  const _AddCombatantSheet({
    required this.sessionCharacterIds,
    required this.existingSourceIds,
  });

  /// Character ids assigned to the session; the PC picker only surfaces these.
  /// Empty list means "show all of the user's characters" — useful when
  /// the tracker was opened without session context.
  final List<String> sessionCharacterIds;

  /// `sourceId`s already attached to the encounter; filtered out so each
  /// source can only be added once.
  final Set<String> existingSourceIds;

  @override
  State<_AddCombatantSheet> createState() => _AddCombatantSheetState();
}

class _AddCombatantSheetState extends State<_AddCombatantSheet>
    with SingleTickerProviderStateMixin {
  late final Future<List<CharacterSummary>> _pcFuture;
  late final Future<List<NpcSummary>> _npcFuture;

  @override
  void initState() {
    super.initState();
    // Reach into DI directly — see the matching pattern in
    // `ShipSheetPage._CrewPickerSheet`. Keeps the page-level test
    // harness off the broken `character_repository_impl` graph.
    _pcFuture = getIt<CharacterRepository>().list(limit: 200);
    _npcFuture = getIt<NpcRepository>().list(limit: 200);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.addCombatantTitle,
                style: AppTypography.bodyLg
                    .copyWith(color: AppColors.brandBrassLight),
              ),
              const SizedBox(height: AppSpacing.s3),
              TabBar(
                indicatorColor: AppColors.brandBrass,
                labelColor: AppColors.brandBrass,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: [
                  Tab(text: t.addCombatantTabPc),
                  Tab(text: t.addCombatantTabNpc),
                ],
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 480),
                child: TabBarView(
                  children: [
                    _PcPickerTab(
                      future: _pcFuture,
                      sessionCharacterIds: widget.sessionCharacterIds,
                      existingSourceIds: widget.existingSourceIds,
                    ),
                    _NpcPickerTab(
                      future: _npcFuture,
                      existingSourceIds: widget.existingSourceIds,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s3),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t.addCombatantCancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PC tab ────────────────────────────────────────────────────────────────────

class _PcPickerTab extends StatelessWidget {
  const _PcPickerTab({
    required this.future,
    required this.sessionCharacterIds,
    required this.existingSourceIds,
  });

  final Future<List<CharacterSummary>> future;
  final List<String> sessionCharacterIds;
  final Set<String> existingSourceIds;

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;
    return FutureBuilder<List<CharacterSummary>>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData && snap.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.s4),
              child: CircularProgressIndicator(color: AppColors.brandBrass),
            ),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.s3),
            child: Text(
              snap.error.toString(),
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.stateCrimsonBright),
            ),
          );
        }
        final chars = snap.data ?? const <CharacterSummary>[];
        final sessionFilter = sessionCharacterIds.toSet();
        final pickable = chars
            .where((c) =>
                sessionFilter.isEmpty || sessionFilter.contains(c.id))
            .where((c) => !existingSourceIds.contains(c.id))
            .toList();
        if (pickable.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.s3),
            child: Text(
              t.addCombatantEmpty,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: pickable.length,
          itemBuilder: (ctx, i) {
            final c = pickable[i];
            return ListTile(
              key: Key('tracker-add-pc-pick-${c.id}'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                c.name,
                style: AppTypography.bodyMd
                    .copyWith(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.of(context).pop(
                _AddCombatantPick(kind: 'pc', sourceId: c.id),
              ),
            );
          },
        );
      },
    );
  }
}

// ── NPC tab ───────────────────────────────────────────────────────────────────

class _NpcPickerTab extends StatelessWidget {
  const _NpcPickerTab({
    required this.future,
    required this.existingSourceIds,
  });

  final Future<List<NpcSummary>> future;
  final Set<String> existingSourceIds;

  @override
  Widget build(BuildContext context) {
    final t = context.t.combat;
    return FutureBuilder<List<NpcSummary>>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData && snap.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.s4),
              child: CircularProgressIndicator(color: AppColors.brandBrass),
            ),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.s3),
            child: Text(
              snap.error.toString(),
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.stateCrimsonBright),
            ),
          );
        }
        final npcs = snap.data ?? const <NpcSummary>[];
        final pickable =
            npcs.where((n) => !existingSourceIds.contains(n.id)).toList();
        if (pickable.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.s3),
            child: Text(
              t.addCombatantNpcEmpty,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: pickable.length,
          itemBuilder: (ctx, i) {
            final n = pickable[i];
            return ListTile(
              key: Key('tracker-add-npc-pick-${n.id}'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                n.name,
                style: AppTypography.bodyMd
                    .copyWith(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.of(context).pop(
                _AddCombatantPick(kind: 'npc', sourceId: n.id),
              ),
            );
          },
        );
      },
    );
  }
}

