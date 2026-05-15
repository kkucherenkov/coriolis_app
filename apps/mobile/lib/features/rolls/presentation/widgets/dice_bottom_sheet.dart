import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coriolis_companion/features/rolls/domain/roll.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/dice_roller/dice_roller_cubit.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/dice_roller/dice_roller_state.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/roll_history/roll_history_cubit.dart';
import 'package:coriolis_companion/features/rolls/presentation/widgets/roll_history_list.dart';
import 'package:coriolis_companion/features/rolls/presentation/widgets/roll_result_strip.dart';
import 'package:coriolis_companion/shared/di/injector.dart';

/// Bottom sheet hosting the dice roller (Phase 4 Block 1).
///
/// `show()` mounts a draggable scrollable sheet so it co-exists with the
/// soft keyboard when the player taps the label field. The sheet provides
/// its own `BlocProvider<DiceRollerCubit>` rather than reusing one from
/// the surrounding page — each open is a fresh roll context. Roll results
/// bubble back to the caller via the optional `onRoll` / `onPush`
/// callbacks; Block 2 wires those to the history cubit.
class DiceBottomSheet {
  static Future<void> show(
    BuildContext context, {
    required String characterId,
    required bool exhausted,
    String? gameSessionId,
    void Function(Roll roll)? onRoll,
    void Function(Roll roll)? onPush,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetCtx) {
        // Two cubits live for the lifetime of the sheet: the roller is
        // ephemeral (a fresh state each open) and the history is the
        // canonical view of the last 50 rolls. Keeping both in one
        // MultiBlocProvider lets the listener forward roller events
        // directly into history without a parent owning the bridge.
        return MultiBlocProvider(
          providers: [
            BlocProvider<DiceRollerCubit>(
              create: (_) => getIt<DiceRollerCubit>(),
            ),
            BlocProvider<RollHistoryCubit>(
              create: (_) => getIt<RollHistoryCubit>(),
            ),
          ],
          child: _DiceBottomSheetContent(
            characterId: characterId,
            exhausted: exhausted,
            gameSessionId: gameSessionId,
            onRoll: onRoll,
            onPush: onPush,
          ),
        );
      },
    );
  }
}

class _DiceBottomSheetContent extends StatefulWidget {
  const _DiceBottomSheetContent({
    required this.characterId,
    required this.exhausted,
    this.gameSessionId,
    this.onRoll,
    this.onPush,
  });

  final String characterId;
  final bool exhausted;
  final String? gameSessionId;
  final void Function(Roll roll)? onRoll;
  final void Function(Roll roll)? onPush;

  @override
  State<_DiceBottomSheetContent> createState() => _DiceBottomSheetContentState();
}

class _DiceBottomSheetContentState extends State<_DiceBottomSheetContent> {
  final _labelController = TextEditingController();
  Roll? _emittedRollId;
  Roll? _emittedPushId;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DiceRollerCubit>();

    return BlocConsumer<DiceRollerCubit, DiceRollerState>(
      listenWhen: (prev, next) => prev.lastRoll?.id != next.lastRoll?.id ||
          prev.lastRoll?.pushed != next.lastRoll?.pushed,
      listener: (ctx, state) {
        final roll = state.lastRoll;
        if (roll == null) return;
        final history = ctx.read<RollHistoryCubit>();
        // Distinguish between a fresh roll (new id) and a push update
        // (same id, pushed flag flipped) so the parent's callbacks fire
        // exactly once per server-side action — and so the history list
        // gets the right method (prepend vs in-place update).
        if (_emittedRollId?.id != roll.id) {
          widget.onRoll?.call(roll);
          history.prependRoll(roll);
          _emittedRollId = roll;
        } else if (roll.pushed && _emittedPushId?.id != roll.id) {
          widget.onPush?.call(roll);
          history.updateRoll(roll);
          _emittedPushId = roll;
        }
      },
      builder: (ctx, state) {
        final canRoll = state.label.trim().isNotEmpty &&
            state.status != DiceRollerStatus.rolling;
        final lastRoll = state.lastRoll;
        final canPush = lastRoll != null &&
            !lastRoll.pushed &&
            !widget.exhausted &&
            state.status != DiceRollerStatus.pushing;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle.
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Roll dice', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),

              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(ctx).colorScheme.error,
                    ),
                  ),
                ),

              TextField(
                controller: _labelController,
                onChanged: cubit.setLabel,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  hintText: 'Pilot · Evade',
                  border: OutlineInputBorder(),
                ),
                maxLength: 80,
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Text('Pool'),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: state.pool > DiceRollerCubit.poolMin
                        ? cubit.decrementPool
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    tooltip: 'Decrease pool',
                  ),
                  SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(
                        '${state.pool}',
                        style: Theme.of(ctx).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: state.pool < DiceRollerCubit.poolMax
                        ? cubit.incrementPool
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Increase pool',
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: canRoll
                        ? () => cubit.roll(
                              characterId: widget.characterId,
                              gameSessionId: widget.gameSessionId,
                            )
                        : null,
                    icon: state.status == DiceRollerStatus.rolling
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.casino),
                    label: const Text('Roll'),
                  ),
                ],
              ),

              if (lastRoll != null) ...[
                const SizedBox(height: 16),
                _LastRollCard(
                  roll: lastRoll,
                  exhausted: widget.exhausted,
                  pushBusy: state.status == DiceRollerStatus.pushing,
                  canPush: canPush,
                  onPush: cubit.push,
                  pushDelta: state.pushDelta,
                ),
              ],

              const SizedBox(height: 16),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'History',
                  style: Theme.of(ctx).textTheme.titleSmall,
                ),
              ),
              RollHistoryList(characterId: widget.characterId),
            ],
          ),
        );
      },
    );
  }
}

class _LastRollCard extends StatelessWidget {
  const _LastRollCard({
    required this.roll,
    required this.exhausted,
    required this.pushBusy,
    required this.canPush,
    required this.onPush,
    this.pushDelta,
  });

  final Roll roll;
  final bool exhausted;
  final bool pushBusy;
  final bool canPush;
  final VoidCallback onPush;

  /// SURFACES.md §9 — in-session count of new 6s gained by the most
  /// recent push. Null when no push has happened in this session;
  /// `0` for the fail branch ("no new successes"); `> 0` for the
  /// happy branch ("+N new successes").
  final int? pushDelta;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    roll.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (roll.pushed)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Chip(
                      label: Text('Pushed'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            RollResultStrip(
              dice: roll.dice,
              pushedIndices: roll.pushedDieIndices,
            ),
            if (pushDelta != null) ...[
              const SizedBox(height: 8),
              _PushOutcomeLine(delta: pushDelta!),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${roll.hits} hit${roll.hits == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                if (exhausted && !roll.pushed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      'Exhausted — push not available',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: canPush ? onPush : null,
                  icon: pushBusy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 18),
                  label: const Text('Push'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// SURFACES.md §9 — pushed-state outcome line. `delta == 0` is the
/// "prayer goes unanswered" fail branch (darker top border, italic);
/// `delta > 0` is the success branch (mystic teal accent).
///
/// Strings are intentionally English-only for now to match the rest of
/// `dice_bottom_sheet.dart` — the file is awaiting a broader i18n pass
/// (see open audit gap T-MOBILE-DICE-I18N).
class _PushOutcomeLine extends StatelessWidget {
  const _PushOutcomeLine({required this.delta});

  final int delta;

  @override
  Widget build(BuildContext context) {
    final fail = delta == 0;
    final divider = Divider(
      key: ValueKey<bool>(fail),
      height: 1,
      thickness: 1,
      color: fail
          ? Theme.of(context).colorScheme.outlineVariant
          : Theme.of(context).colorScheme.outline,
    );
    final text = fail
        ? 'The prayer goes unanswered — no new successes.'
        : '+$delta new successes';
    final style = TextStyle(
      fontSize: 12,
      fontStyle: fail ? FontStyle.italic : FontStyle.normal,
      color: fail
          ? Theme.of(context).colorScheme.outline
          : Theme.of(context).colorScheme.tertiary,
    );
    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          divider,
          const SizedBox(height: 6),
          Text(
            text,
            key: ValueKey<String>(fail ? 'push-fail' : 'push-success'),
            textAlign: TextAlign.center,
            style: style,
          ),
        ],
      ),
    );
  }
}
