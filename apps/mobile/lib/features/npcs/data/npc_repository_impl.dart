import 'package:app_api_client/app_api_client.dart' show NpcsApi;

import 'package:coriolis_companion/features/npcs/domain/npc_repository.dart';
import 'package:coriolis_companion/features/npcs/domain/npc_summary.dart';

/// Adapter bridging [NpcsApi] with the domain [NpcRepository].
///
/// All API types are contained to this file. The presentation layer uses
/// domain types exclusively.
class NpcRepositoryImpl implements NpcRepository {
  const NpcRepositoryImpl({required NpcsApi api}) : _api = api;

  final NpcsApi _api;

  @override
  Future<List<NpcSummary>> list({int limit = 20}) async {
    final response = await _api.listNpcs(limit: limit);
    final body = response.data;
    if (body == null) throw StateError('listNpcs returned empty body');
    return body.items
        .map((n) => NpcSummary(id: n.id, name: n.name))
        .toList(growable: false);
  }
}
