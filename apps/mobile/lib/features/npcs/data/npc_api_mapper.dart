import 'package:app_api_client/app_api_client.dart' as api_client;

import 'package:coriolis_companion/features/npcs/domain/npc_summary.dart';

/// Single source of truth for the wire→domain transform for [NpcSummary].
///
/// Used by [NpcRepositoryImpl] for live API responses and by
/// [CachedNpcRepository] for hydrating cached payloads.
final class NpcApiMapper {
  const NpcApiMapper._();

  static NpcSummary fromWire(api_client.Npc src) =>
      NpcSummary(id: src.id, name: src.name);
}
