import 'package:app_mobile/features/characters/domain/character.dart';
import 'package:app_mobile/features/characters/domain/character_summary.dart';

/// Repository contract for character operations.
///
/// Implementations live in `data/`. The presentation layer depends on this
/// interface only — it never imports `app_api_client` types directly.
abstract class CharacterRepository {
  /// Returns up to [limit] characters owned by the current user, ordered
  /// newest-first. Throws on network / auth failure.
  Future<List<CharacterSummary>> list({int limit = 20});

  /// Fetches the full character DTO for [id]. Throws if not found or not owned.
  Future<Character> get(String id);

  /// Creates a new character with the given [name]. Returns the created entity.
  Future<Character> create({required String name});

  /// Partially updates the character identified by [id]. Only non-null fields
  /// in [name] and [concept] are sent to the API.
  Future<Character> update(
    String id, {
    String? name,
    String? concept,
  });

  /// Permanently deletes the character identified by [id].
  Future<void> delete(String id);
}
