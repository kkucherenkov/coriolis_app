import 'package:dio/dio.dart';

import 'package:coriolis_companion/features/ships/data/ship_api_mapper.dart';
import 'package:coriolis_companion/features/ships/data/ship_cache.dart';
import 'package:coriolis_companion/features/ships/domain/ship.dart';
import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';

/// Read-through cache decorator over a remote [ShipRepository].
///
/// **Reads** — `list()` and `get(id)` first try the remote. On a network
/// `DioException` the call falls back to [LocalShipCache]. Non-network
/// failures propagate unchanged.
///
/// **Writes** — every mutation forwards to the remote; on remote success the
/// cache row for the affected ship is invalidated (the next `get()` will
/// re-fetch and the cache interceptor refills). Mutations while offline are
/// NOT queued — that is handled by the write-queue layer (Phase 7 T-10.2.b).
class CachedShipRepository implements ShipRepository {
  CachedShipRepository({
    required ShipRepository remote,
    required LocalShipCache cache,
  })  : _remote = remote,
        _cache = cache;

  final ShipRepository _remote;
  final LocalShipCache _cache;

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
  Future<List<ShipSummary>> list({int limit = 20}) async {
    try {
      return await _remote.list(limit: limit);
    } catch (e) {
      if (!_isNetwork(e)) rethrow;
      final cached = await _cache.readAll();
      return cached.map(ShipApiMapper.toSummary).toList(growable: false);
    }
  }

  @override
  Future<Ship> get(String id) async {
    try {
      return await _remote.get(id);
    } catch (e) {
      if (!_isNetwork(e)) rethrow;
      final cached = await _cache.read(id);
      if (cached == null) rethrow;
      return ShipApiMapper.toDomain(cached);
    }
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  @override
  Future<Ship> create({
    required String name,
    required String shipClass,
    String? model,
    String? registry,
  }) async {
    final created = await _remote.create(
      name: name,
      shipClass: shipClass,
      model: model,
      registry: registry,
    );
    await _cache.delete(created.id);
    return created;
  }

  @override
  Future<Ship> update(
    String id, {
    String? name,
    String? model,
    String? registry,
    ShipPoints? hull,
    ShipPoints? energy,
    int? armor,
    int? maneuverability,
    int? signature,
    int? speed,
    List<String>? problems,
    String? history,
    String? notes,
  }) async {
    final updated = await _remote.update(
      id,
      name: name,
      model: model,
      registry: registry,
      hull: hull,
      energy: energy,
      armor: armor,
      maneuverability: maneuverability,
      signature: signature,
      speed: speed,
      problems: problems,
      history: history,
      notes: notes,
    );
    await _cache.delete(id);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _remote.delete(id);
    await _cache.delete(id);
  }

  @override
  Future<Ship> duplicate(String id) async {
    final ship = await _remote.duplicate(id);
    await _cache.delete(id);
    return ship;
  }

  @override
  Future<Ship> exportSnapshot(String id) async {
    // exportSnapshot is read-like; no cache invalidation needed.
    return _remote.exportSnapshot(id);
  }

  @override
  Future<void> assignCrew({
    required String shipId,
    required String position,
    required String characterId,
  }) async {
    await _remote.assignCrew(
      shipId: shipId,
      position: position,
      characterId: characterId,
    );
    await _cache.delete(shipId);
  }

  @override
  Future<void> unassignCrew({
    required String shipId,
    required String characterId,
  }) async {
    await _remote.unassignCrew(shipId: shipId, characterId: characterId);
    await _cache.delete(shipId);
  }

  @override
  Future<DomainShipModule> addOtherModule({
    required String shipId,
    required String slot,
    required String name,
    int energyUse = 0,
    String? notes,
  }) async {
    final module = await _remote.addOtherModule(
      shipId: shipId,
      slot: slot,
      name: name,
      energyUse: energyUse,
      notes: notes,
    );
    await _cache.delete(shipId);
    return module;
  }

  @override
  Future<DomainShipModule> addWeaponModule({
    required String shipId,
    required String name,
    int energyUse = 0,
    int weaponBonus = 0,
    String weaponRange = 'close',
    int weaponDamage = 0,
    int weaponCritThreshold = 1,
    String? notes,
  }) async {
    final module = await _remote.addWeaponModule(
      shipId: shipId,
      name: name,
      energyUse: energyUse,
      weaponBonus: weaponBonus,
      weaponRange: weaponRange,
      weaponDamage: weaponDamage,
      weaponCritThreshold: weaponCritThreshold,
      notes: notes,
    );
    await _cache.delete(shipId);
    return module;
  }

  @override
  Future<DomainShipModule> addHoldModule({
    required String shipId,
    required String name,
    int energyUse = 0,
    int? cargoTons,
    bool? concealed,
    String? notes,
  }) async {
    final module = await _remote.addHoldModule(
      shipId: shipId,
      name: name,
      energyUse: energyUse,
      cargoTons: cargoTons,
      concealed: concealed,
      notes: notes,
    );
    await _cache.delete(shipId);
    return module;
  }

  @override
  Future<DomainShipModule> addTorpedoModule({
    required String shipId,
    required String name,
    int energyUse = 0,
    int? torpedoCount,
    int? mineCount,
    String? notes,
  }) async {
    final module = await _remote.addTorpedoModule(
      shipId: shipId,
      name: name,
      energyUse: energyUse,
      torpedoCount: torpedoCount,
      mineCount: mineCount,
      notes: notes,
    );
    await _cache.delete(shipId);
    return module;
  }

  @override
  Future<DomainShipModule> addSensorModule({
    required String shipId,
    required String name,
    int energyUse = 0,
    int? detectionBonus,
    String? notes,
  }) async {
    final module = await _remote.addSensorModule(
      shipId: shipId,
      name: name,
      energyUse: energyUse,
      detectionBonus: detectionBonus,
      notes: notes,
    );
    await _cache.delete(shipId);
    return module;
  }

  @override
  Future<DomainShipModule> updateOtherModule({
    required String moduleId,
    String? name,
    int? energyUse,
    String? notes,
  }) async {
    final module = await _remote.updateOtherModule(
      moduleId: moduleId,
      name: name,
      energyUse: energyUse,
      notes: notes,
    );
    // updateModule methods receive only a moduleId (no shipId on the port);
    // the next get() will refetch and the interceptor will refill the cache.
    return module;
  }

  @override
  Future<DomainShipModule> updateWeaponModule({
    required String moduleId,
    String? name,
    int? energyUse,
    int? weaponBonus,
    String? weaponRange,
    int? weaponDamage,
    int? weaponCritThreshold,
    String? notes,
  }) async {
    final module = await _remote.updateWeaponModule(
      moduleId: moduleId,
      name: name,
      energyUse: energyUse,
      weaponBonus: weaponBonus,
      weaponRange: weaponRange,
      weaponDamage: weaponDamage,
      weaponCritThreshold: weaponCritThreshold,
      notes: notes,
    );
    // No shipId available — cache staleness cleared on next get().
    return module;
  }

  @override
  Future<DomainShipModule> updateHoldModule({
    required String moduleId,
    String? name,
    int? energyUse,
    int? cargoTons,
    bool? concealed,
    String? notes,
  }) async {
    final module = await _remote.updateHoldModule(
      moduleId: moduleId,
      name: name,
      energyUse: energyUse,
      cargoTons: cargoTons,
      concealed: concealed,
      notes: notes,
    );
    // No shipId available — cache staleness cleared on next get().
    return module;
  }

  @override
  Future<DomainShipModule> updateTorpedoModule({
    required String moduleId,
    String? name,
    int? energyUse,
    int? torpedoCount,
    int? mineCount,
    String? notes,
  }) async {
    final module = await _remote.updateTorpedoModule(
      moduleId: moduleId,
      name: name,
      energyUse: energyUse,
      torpedoCount: torpedoCount,
      mineCount: mineCount,
      notes: notes,
    );
    // No shipId available — cache staleness cleared on next get().
    return module;
  }

  @override
  Future<DomainShipModule> updateSensorModule({
    required String moduleId,
    String? name,
    int? energyUse,
    int? detectionBonus,
    String? notes,
  }) async {
    final module = await _remote.updateSensorModule(
      moduleId: moduleId,
      name: name,
      energyUse: energyUse,
      detectionBonus: detectionBonus,
      notes: notes,
    );
    // No shipId available — cache staleness cleared on next get().
    return module;
  }

  @override
  Future<void> deleteModule(String moduleId) async {
    // deleteModule has no shipId parameter on the port — just forward.
    // The next get() will refetch and the interceptor will refill the cache.
    await _remote.deleteModule(moduleId);
  }
}
