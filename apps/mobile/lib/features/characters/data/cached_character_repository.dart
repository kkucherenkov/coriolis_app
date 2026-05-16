import 'package:dio/dio.dart';

import 'package:coriolis_companion/features/characters/data/character_api_mapper.dart';
import 'package:coriolis_companion/features/characters/data/character_cache.dart';
import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/domain/character_repository.dart';
import 'package:coriolis_companion/features/characters/domain/character_summary.dart';

/// Read-through cache decorator over a remote [CharacterRepository].
///
/// **Reads** — `list()` and `get(id)` first try the remote. On a network
/// `DioException` the call falls back to [LocalCharacterCache]. Non-network
/// failures propagate unchanged.
///
/// **Writes** — every mutation forwards to the remote; on remote success the
/// cache row for the affected character is invalidated (the next `get()` will
/// re-fetch and the cache interceptor refills). Mutations while offline are
/// NOT queued — that is a separate follow-up block (Task 5b+).
class CachedCharacterRepository implements CharacterRepository {
  CachedCharacterRepository({
    required CharacterRepository remote,
    required LocalCharacterCache cache,
  })  : _remote = remote,
        _cache = cache;

  final CharacterRepository _remote;
  final LocalCharacterCache _cache;

  static const _networkTypes = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
  };

  bool _isNetwork(Object e) =>
      e is DioException && _networkTypes.contains(e.type);

  // ── Reads ─────────────────────────────────────────────────────────────────

  @override
  Future<List<CharacterSummary>> list({int limit = 20}) async {
    try {
      return await _remote.list(limit: limit);
    } catch (e) {
      if (!_isNetwork(e)) rethrow;
      final cached = await _cache.readAll();
      return cached.map(CharacterApiMapper.toSummary).toList(growable: false);
    }
  }

  @override
  Future<Character> get(String id) async {
    try {
      return await _remote.get(id);
    } catch (e) {
      if (!_isNetwork(e)) rethrow;
      final cached = await _cache.read(id);
      if (cached == null) rethrow;
      return CharacterApiMapper.toDomain(cached);
    }
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  @override
  Future<Character> create({
    required String name,
    required String upbringing,
    String? status,
  }) async {
    final created = await _remote.create(
      name: name,
      upbringing: upbringing,
      status: status,
    );
    await _cache.delete(created.id);
    return created;
  }

  @override
  Future<Character> update(
    String id, {
    String? name,
    String? concept,
    String? role,
    String? iconId,
    String? upbringing,
    String? origin,
    String? crewConcept,
    bool? mutant,
    String? mutantLineage,
    int? reputation,
    int? birr,
    CharacterAttributes? attributes,
    CharacterSkills? skills,
    CharacterHp? hp,
    CharacterMp? mp,
    int? experience,
    CharacterConditions? conditions,
    List<DomainCriticalInjury>? criticalInjuries,
    String? notes,
    String? status,
  }) async {
    final updated = await _remote.update(
      id,
      name: name,
      concept: concept,
      role: role,
      iconId: iconId,
      upbringing: upbringing,
      origin: origin,
      crewConcept: crewConcept,
      mutant: mutant,
      mutantLineage: mutantLineage,
      reputation: reputation,
      birr: birr,
      attributes: attributes,
      skills: skills,
      hp: hp,
      mp: mp,
      experience: experience,
      conditions: conditions,
      criticalInjuries: criticalInjuries,
      notes: notes,
      status: status,
    );
    await _cache.delete(id);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _remote.delete(id);
    await _cache.delete(id);
  }

  // ── Talents ───────────────────────────────────────────────────────────────

  @override
  Future<DomainTalent> addTalent(
    String characterId, {
    required String name,
    required String description,
    int rank = 1,
  }) async {
    final talent = await _remote.addTalent(
      characterId,
      name: name,
      description: description,
      rank: rank,
    );
    await _cache.delete(characterId);
    return talent;
  }

  @override
  Future<DomainTalent> updateTalent(
    String characterId,
    String talentId, {
    String? name,
    String? description,
    int? rank,
  }) async {
    final talent = await _remote.updateTalent(
      characterId,
      talentId,
      name: name,
      description: description,
      rank: rank,
    );
    await _cache.delete(characterId);
    return talent;
  }

  @override
  Future<void> removeTalent(String characterId, String talentId) async {
    await _remote.removeTalent(characterId, talentId);
    await _cache.delete(characterId);
  }

  // ── Inventory ─────────────────────────────────────────────────────────────

  @override
  Future<DomainItem> addItem(String characterId, DomainItem draft) async {
    final item = await _remote.addItem(characterId, draft);
    await _cache.delete(characterId);
    return item;
  }

  @override
  Future<DomainItem> updateItem(
    String characterId,
    String itemId,
    DomainItem patch,
  ) async {
    final item = await _remote.updateItem(characterId, itemId, patch);
    await _cache.delete(characterId);
    return item;
  }

  @override
  Future<void> removeItem(String characterId, String itemId) async {
    await _remote.removeItem(characterId, itemId);
    await _cache.delete(characterId);
  }
}
