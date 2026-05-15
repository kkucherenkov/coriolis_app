import 'package:coriolis_companion/features/npcs/domain/npc_summary.dart';

/// Repository contract for the NPC library (Phase 6 T-MOBILE-NPC-PICKER scope).
///
/// Only `list` is exposed here — sufficient for the combat tracker NPC picker.
/// Full NPC CRUD (create, get, update, delete) and a rich domain entity wait
/// on the dedicated NPC feature shell which is out of scope for this task.
abstract class NpcRepository {
  /// Returns up to [limit] NPC summaries owned by the authenticated user,
  /// newest-first (server ordering).
  Future<List<NpcSummary>> list({int limit = 20});
}
