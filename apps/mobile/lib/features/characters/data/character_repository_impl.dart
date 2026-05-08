import 'package:app_api_client/app_api_client.dart'
    show
        CharactersApi,
        CharacterCreate,
        CharacterUpdate,
        Character as ApiCharacter;

import 'package:app_mobile/features/characters/domain/character.dart';
import 'package:app_mobile/features/characters/domain/character_repository.dart';
import 'package:app_mobile/features/characters/domain/character_summary.dart';

/// Adapter that bridges [CharactersApi] (generated built_value client) with
/// the domain [CharacterRepository] interface.
///
/// Mapping convention: `app_api_client.Character` → domain `Character`.
/// The domain type is the sole currency within `presentation/`; the API types
/// stay contained in this file.
class CharacterRepositoryImpl implements CharacterRepository {
  const CharacterRepositoryImpl({required CharactersApi api})
      : _api = api;

  final CharactersApi _api;

  // ── mapping ──────────────────────────────────────────────────────────────

  static Character _toDomain(ApiCharacter src) => Character(
        id: src.id,
        ownerId: src.ownerId,
        name: src.name,
        concept: src.concept,
        updatedAt: src.updatedAt,
        createdAt: src.createdAt,
      );

  static CharacterSummary _toSummary(ApiCharacter src) => CharacterSummary(
        id: src.id,
        name: src.name,
        concept: src.concept,
      );

  // ── CharacterRepository ──────────────────────────────────────────────────

  @override
  Future<List<CharacterSummary>> list({int limit = 20}) async {
    final response = await _api.listCharacters(limit: limit);
    final body = response.data;
    if (body == null) return [];
    return body.items.map(_toSummary).toList();
  }

  @override
  Future<Character> get(String id) async {
    final response = await _api.getCharacter(id: id);
    final body = response.data;
    if (body == null) throw StateError('Empty response for character $id');
    return _toDomain(body);
  }

  @override
  Future<Character> create({required String name}) async {
    final payload = CharacterCreate((b) => b..name = name);
    final response = await _api.createCharacter(characterCreate: payload);
    final body = response.data;
    if (body == null) throw StateError('Empty response after create');
    return _toDomain(body);
  }

  @override
  Future<Character> update(
    String id, {
    String? name,
    String? concept,
  }) async {
    final payload = CharacterUpdate(
      (b) {
        if (name != null) b.name = name;
        if (concept != null) b.concept = concept;
      },
    );
    final response = await _api.updateCharacter(
      id: id,
      characterUpdate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after update');
    return _toDomain(body);
  }

  @override
  Future<void> delete(String id) async {
    await _api.deleteCharacter(id: id);
  }
}
