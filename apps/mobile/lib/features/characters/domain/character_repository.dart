import 'package:app_mobile/features/characters/domain/character.dart';
import 'package:app_mobile/features/characters/domain/character_summary.dart';

/// Repository contract for character operations.
///
/// Implementations live in `data/`. Presentation depends on this interface
/// only — it never imports `app_api_client` types.
abstract class CharacterRepository {
  // ── List / CRUD ─────────────────────────────────────────────────────────

  /// Returns up to [limit] characters owned by the current user.
  Future<List<CharacterSummary>> list({int limit = 20});

  /// Fetches the full character DTO for [id].
  Future<Character> get(String id);

  /// Creates a new character with [name].
  ///
  /// [status] defaults to `active`; pass `draft` from the creation wizard
  /// so the character does not surface in the dashboard until forged.
  Future<Character> create({required String name, String? status});

  /// Partially updates the character identified by [id].
  ///
  /// [status] is the lifecycle transition: only `draft → active` (forge) is
  /// permitted by the server; `active → draft` returns 422
  /// `INVALID_STATUS_TRANSITION`.
  Future<Character> update(
    String id, {
    String? name,
    String? concept,
    CharacterAttributes? attributes,
    CharacterSkills? skills,
    CharacterHp? hp,
    CharacterMp? mp,
    int? experience,
    CharacterConditions? conditions,
    List<DomainCriticalInjury>? criticalInjuries,
    String? notes,
    String? status,
  });

  /// Permanently deletes the character identified by [id].
  Future<void> delete(String id);

  // ── Talents ──────────────────────────────────────────────────────────────

  Future<DomainTalent> addTalent(
    String characterId, {
    required String name,
    required String description,
    int rank = 1,
  });

  Future<DomainTalent> updateTalent(
    String characterId,
    String talentId, {
    String? name,
    String? description,
    int? rank,
  });

  Future<void> removeTalent(String characterId, String talentId);

  // ── Inventory ────────────────────────────────────────────────────────────

  Future<DomainItem> addItem(String characterId, DomainItem draft);

  Future<DomainItem> updateItem(
      String characterId, String itemId, DomainItem patch);

  Future<void> removeItem(String characterId, String itemId);
}
