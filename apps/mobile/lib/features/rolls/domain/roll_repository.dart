import 'package:coriolis_companion/features/rolls/domain/roll.dart';

/// Repository contract for the dice-roller (Phase 4 Feature 7.1).
///
/// Implementations live in `data/`. Presentation depends on this interface
/// only — it never imports `app_api_client` types.
abstract class RollRepository {
  /// Creates a new roll for [characterId]. Server holds the RNG; the
  /// returned roll carries the freshly generated dice + hit count.
  ///
  /// [pool] must be 1..10 inclusive (server enforces). [gameSessionId] is
  /// nullable — when present, a future push will broadcast a `roll.pushed`
  /// event to that session's Centrifugo channel.
  Future<Roll> createRoll({
    required String characterId,
    required String label,
    required int pool,
    String? gameSessionId,
  });

  /// Returns up to [limit] rolls for [characterId], newest first.
  Future<List<Roll>> listRolls(String characterId, {int limit = 50});

  /// Pushes a roll once (rerolls non-sixes server-side). Throws on a
  /// 422 `ROLL_NOT_PUSHABLE` — happens when the roll was already pushed
  /// or the character is `exhausted`.
  Future<Roll> pushRoll(String rollId);
}
