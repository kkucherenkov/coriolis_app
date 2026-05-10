import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:coriolis_companion/features/rolls/domain/roll.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/roll_history/roll_history_cubit.dart';
import 'package:coriolis_companion/features/rolls/presentation/blocs/roll_history/roll_history_state.dart';
import 'package:coriolis_companion/features/rolls/presentation/widgets/roll_result_strip.dart';

/// Compact roll history rendered inside the dice bottom sheet (Phase 4
/// Block 2). One row per roll: trimmed label, hits chip, "Pushed" chip
/// if applicable, and a relative timestamp. Tap opens an `AlertDialog`
/// with the full dice strip + label + pool + absolute datetime.
///
/// The list expects a parent `BlocProvider<RollHistoryCubit>` and
/// drives load on mount. Subsequent state mutations come from the
/// dice roller's `rollCreated` / `rollPushed` callbacks via the
/// parent's listener.
class RollHistoryList extends StatefulWidget {
  const RollHistoryList({super.key, required this.characterId});

  final String characterId;

  @override
  State<RollHistoryList> createState() => _RollHistoryListState();
}

class _RollHistoryListState extends State<RollHistoryList> {
  bool _loadKicked = false;

  @override
  void initState() {
    super.initState();
    // Schedule the load after the first frame so the BlocProvider
    // has wired everything up. didChangeDependencies could fire
    // multiple times during a hot-reload — guard with `_loadKicked`.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadKicked) {
      _loadKicked = true;
      context.read<RollHistoryCubit>().load(widget.characterId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RollHistoryCubit, RollHistoryState>(
      builder: (ctx, state) {
        switch (state.status) {
          case RollHistoryStatus.loading:
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          case RollHistoryStatus.error:
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                state.errorMessage ?? 'Couldn\'t load roll history.',
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
            );
          case RollHistoryStatus.loaded:
            if (state.rolls.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No rolls yet — describe one above.',
                  style: TextStyle(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final roll in state.rolls)
                  _RollHistoryTile(
                    key: ValueKey(roll.id),
                    roll: roll,
                    onTap: () => _openDetail(ctx, roll),
                  ),
              ],
            );
        }
      },
    );
  }

  Future<void> _openDetail(BuildContext context, Roll roll) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => _RollDetailDialog(roll: roll),
    );
  }
}

class _RollHistoryTile extends StatelessWidget {
  const _RollHistoryTile({super.key, required this.roll, required this.onTap});

  final Roll roll;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      onTap: onTap,
      title: Text(
        roll.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(_relativeTime(roll.createdAt)),
      trailing: Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Chip(
            label: Text('${roll.hits} hit${roll.hits == 1 ? '' : 's'}'),
            visualDensity: VisualDensity.compact,
          ),
          if (roll.pushed)
            const Chip(
              label: Text('Pushed'),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  /// Compact relative timestamp — "just now", "3m", "2h", "yesterday",
  /// then a `MMM d` formatted date for older rolls.
  String _relativeTime(DateTime when) {
    final now = DateTime.now();
    final delta = now.difference(when);
    if (delta.inSeconds < 45) return 'just now';
    if (delta.inMinutes < 60) return '${delta.inMinutes}m ago';
    if (delta.inHours < 24) return '${delta.inHours}h ago';
    if (delta.inDays < 2) return 'yesterday';
    if (delta.inDays < 7) return '${delta.inDays}d ago';
    return DateFormat('MMM d').format(when);
  }
}

class _RollDetailDialog extends StatelessWidget {
  const _RollDetailDialog({required this.roll});

  final Roll roll;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, y · HH:mm');
    return AlertDialog(
      title: Text(roll.label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(
                label: Text('Pool ${roll.pool}'),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 6),
              Chip(
                label: Text('${roll.hits} hit${roll.hits == 1 ? '' : 's'}'),
                visualDensity: VisualDensity.compact,
              ),
              if (roll.pushed) ...[
                const SizedBox(width: 6),
                const Chip(
                  label: Text('Pushed'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          RollResultStrip(
            dice: roll.dice,
            pushedIndices: roll.pushedDieIndices,
          ),
          const SizedBox(height: 12),
          Text(
            fmt.format(roll.createdAt.toLocal()),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
