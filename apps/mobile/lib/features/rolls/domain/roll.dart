import 'package:equatable/equatable.dart';

/// A Coriolis dice roll as the mobile UI sees it.
///
/// Domain model — the presentation layer never imports `app_api_client`'s
/// generated `Roll` directly. The `data/roll_repository_impl.dart` adapter
/// translates between the two and contains the SDK type to that file.
///
/// `dice` always has length `pool`; on push the non-six values are replaced
/// in-place server-side and the response carries the new array. `hits` is
/// authoritative — count `dice` against 6 only as a sanity check.
///
/// Extends `Equatable` so list-of-Roll state diffs (e.g. inside
/// `RollHistoryState.rolls`) compare structurally — `bloc_test` uses
/// equality and would otherwise compare by reference.
class Roll extends Equatable {
  const Roll({
    required this.id,
    required this.characterId,
    required this.label,
    required this.pool,
    required this.dice,
    required this.hits,
    required this.pushed,
    required this.createdAt,
    this.gameSessionId,
  });

  final String id;
  final String characterId;
  final String? gameSessionId;
  final String label;
  final int pool;
  final List<int> dice;
  final int hits;
  final bool pushed;
  final DateTime createdAt;

  /// Indices of dice that were rerolled on push — by Coriolis convention
  /// the kept 6s are the ones whose value is still 6, the rerolled dice
  /// are the non-6 values. UI uses this list to dim the failed pushes.
  /// Returns an empty list when the roll has never been pushed.
  List<int> get pushedDieIndices {
    if (!pushed) return const [];
    final out = <int>[];
    for (var i = 0; i < dice.length; i++) {
      if (dice[i] != 6) out.add(i);
    }
    return out;
  }

  @override
  List<Object?> get props => [
        id,
        characterId,
        gameSessionId,
        label,
        pool,
        dice,
        hits,
        pushed,
        createdAt,
      ];
}
