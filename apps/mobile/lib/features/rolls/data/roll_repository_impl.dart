import 'package:app_api_client/app_api_client.dart' as api_client
    show DiceApi, Roll, RollCreate;

import 'package:coriolis_companion/features/rolls/domain/roll.dart';
import 'package:coriolis_companion/features/rolls/domain/roll_repository.dart';

/// Adapter bridging `DiceApi` with the domain `RollRepository`.
///
/// All `app_api_client` types stay in this file. The presentation layer
/// uses domain `Roll` exclusively — same boundary as
/// `character_repository_impl.dart`.
class RollRepositoryImpl implements RollRepository {
  const RollRepositoryImpl({required api_client.DiceApi api}) : _api = api;

  final api_client.DiceApi _api;

  @override
  Future<Roll> createRoll({
    required String characterId,
    required String label,
    required int pool,
    String? gameSessionId,
  }) async {
    final body = api_client.RollCreate(
      (b) => b
        ..label = label
        ..pool = pool
        ..gameSessionId = gameSessionId,
    );
    final res = await _api.createRoll(id: characterId, rollCreate: body);
    final roll = res.data;
    if (roll == null) {
      throw StateError('Roll create returned an empty body');
    }
    return _toDomain(roll);
  }

  @override
  Future<List<Roll>> listRolls(String characterId, {int limit = 50}) async {
    final res = await _api.listRolls(id: characterId, limit: limit);
    final list = res.data;
    if (list == null) return const [];
    return list.items.map(_toDomain).toList(growable: false);
  }

  @override
  Future<Roll> pushRoll(String rollId) async {
    final res = await _api.pushRoll(id: rollId);
    final roll = res.data;
    if (roll == null) {
      throw StateError('Roll push returned an empty body');
    }
    return _toDomain(roll);
  }

  static Roll _toDomain(api_client.Roll src) => Roll(
        id: src.id,
        characterId: src.characterId,
        gameSessionId: src.gameSessionId,
        label: src.label,
        pool: src.pool,
        // `BuiltList<int>` → mutable List for the domain layer.
        dice: src.dice.toList(growable: false),
        hits: src.hits,
        pushed: src.pushed,
        createdAt: src.createdAt,
      );
}
