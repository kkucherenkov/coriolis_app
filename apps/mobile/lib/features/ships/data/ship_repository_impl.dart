import 'package:app_api_client/app_api_client.dart'
    show
        ShipsApi,
        ShipClass,
        ShipCreate,
        ShipUpdate,
        ShipUpdateHull,
        ShipModule,
        ShipModuleHold,
        ShipModuleSensor,
        ShipModuleTorpedo,
        ShipModuleWeapon,
        ShipModuleOther,
        AssignCrewRequest,
        CrewPosition,
        CrewSlot,
        ShipWeaponRange;
import 'package:app_api_client/app_api_client.dart' as api_client show Ship;
import 'package:built_collection/built_collection.dart';

import 'package:coriolis_companion/features/ships/domain/ship.dart';
import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';

/// Adapter bridging the generated [ShipsApi] with the domain
/// [ShipRepository]. All API types are contained to this file.
class ShipRepositoryImpl implements ShipRepository {
  const ShipRepositoryImpl({required ShipsApi api}) : _api = api;

  final ShipsApi _api;

  // ── Mapping: API → Domain ────────────────────────────────────────────────

  static Ship _toDomain(api_client.Ship src) => Ship(
        id: src.id,
        ownerId: src.ownerId,
        name: src.name,
        shipClass: src.class_.name,
        model: src.model,
        registry: src.registry,
        hull: ShipPoints(current: src.hull.current, max: src.hull.max),
        energy: ShipPoints(current: src.energy.current, max: src.energy.max),
        armor: src.armor,
        maneuverability: src.maneuverability,
        signature: src.signature,
        speed: src.speed,
        cargoCapacity: src.cargoCapacity,
        modules: src.modules.map(_moduleToDomain).toList(growable: false),
        crew: src.crew.map(_crewToDomain).toList(growable: false),
        problems: src.problems.toList(growable: false),
        history: src.history,
        notes: src.notes,
        createdAt: src.createdAt,
        updatedAt: src.updatedAt,
      );

  static ShipSummary _toSummary(api_client.Ship src) => ShipSummary(
        id: src.id,
        name: src.name,
        shipClass: src.class_.name,
        model: src.model,
        registry: src.registry,
      );

  static DomainCrewSlot _crewToDomain(CrewSlot src) => DomainCrewSlot(
        position: src.position.name,
        assignedCharacterId: src.assignedCharacterId,
      );

  static DomainShipModule _moduleToDomain(ShipModule src) {
    final raw = src.oneOf.value;
    if (raw is ShipModuleWeapon) {
      return DomainShipModule(
        id: raw.id,
        slot: raw.slot.name,
        name: raw.name,
        energyUse: raw.energyUse,
        notes: raw.notes,
        weaponDamage: raw.weaponDamage,
        weaponBonus: raw.weaponBonus,
        weaponRange: raw.weaponRange.name,
        weaponCritThreshold: raw.weaponCritThreshold,
      );
    }
    if (raw is ShipModuleHold) {
      return DomainShipModule(
        id: raw.id,
        slot: raw.slot.name,
        name: raw.name,
        energyUse: raw.energyUse,
        notes: raw.notes,
        cargoTons: raw.cargoTons,
        concealed: raw.concealed,
      );
    }
    if (raw is ShipModuleTorpedo) {
      return DomainShipModule(
        id: raw.id,
        slot: raw.slot.name,
        name: raw.name,
        energyUse: raw.energyUse,
        notes: raw.notes,
        torpedoCount: raw.torpedoCount,
        mineCount: raw.mineCount,
      );
    }
    if (raw is ShipModuleSensor) {
      return DomainShipModule(
        id: raw.id,
        slot: raw.slot.name,
        name: raw.name,
        energyUse: raw.energyUse,
        notes: raw.notes,
        detectionBonus: raw.detectionBonus,
      );
    }
    final other = raw as ShipModuleOther;
    return DomainShipModule(
      id: other.id,
      slot: other.slot.name,
      name: other.name,
      energyUse: other.energyUse,
      notes: other.notes,
    );
  }

  // Unused imports guard — keeps the explicit `show` list aligned with the
  // production wiring; the analyzer would otherwise flag them.
  // ignore: unused_field
  static const _kUsedRangeMarker = ShipWeaponRange;

  // ── ShipRepository ───────────────────────────────────────────────────────

  @override
  Future<List<ShipSummary>> list({int limit = 20}) async {
    final response = await _api.listShips(limit: limit);
    final body = response.data;
    if (body == null) return [];
    return body.items.map(_toSummary).toList(growable: false);
  }

  @override
  Future<Ship> get(String id) async {
    final response = await _api.getShip(id: id);
    final body = response.data;
    if (body == null) throw StateError('Empty response for ship $id');
    return _toDomain(body);
  }

  @override
  Future<Ship> create({
    required String name,
    required String shipClass,
    String? model,
    String? registry,
  }) async {
    final payload = ShipCreate((b) => b
      ..name = name
      ..class_ = ShipClass.valueOf(shipClass)
      ..model = model
      ..registry = registry);
    final response = await _api.createShip(shipCreate: payload);
    final body = response.data;
    if (body == null) throw StateError('Empty response after create');
    return _toDomain(body);
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
    final payload = ShipUpdate((b) {
      if (name != null) b.name = name;
      if (model != null) b.model = model;
      if (registry != null) b.registry = registry;
      if (hull != null) {
        b.hull.replace(ShipUpdateHull((hb) => hb
          ..current = hull.current
          ..max = hull.max));
      }
      if (energy != null) {
        b.energy.replace(ShipUpdateHull((eb) => eb
          ..current = energy.current
          ..max = energy.max));
      }
      if (armor != null) b.armor = armor;
      if (maneuverability != null) b.maneuverability = maneuverability;
      if (signature != null) b.signature = signature;
      if (speed != null) b.speed = speed;
      if (problems != null) {
        b.problems.replace(BuiltList<String>.from(problems));
      }
      if (history != null) b.history = history;
      if (notes != null) b.notes = notes;
    });
    final response = await _api.updateShip(id: id, shipUpdate: payload);
    final body = response.data;
    if (body == null) throw StateError('Empty response after update');
    return _toDomain(body);
  }

  @override
  Future<void> delete(String id) async {
    await _api.deleteShip(id: id);
  }

  @override
  Future<Ship> duplicate(String id) async {
    final response = await _api.duplicateShip(id: id);
    final body = response.data;
    if (body == null) throw StateError('Empty response after duplicate');
    return _toDomain(body);
  }

  @override
  Future<Ship> exportSnapshot(String id) async {
    final response = await _api.exportShip(id: id);
    final body = response.data;
    if (body == null) throw StateError('Empty response after export');
    return _toDomain(body);
  }

  @override
  Future<void> assignCrew({
    required String shipId,
    required String position,
    required String characterId,
  }) async {
    final payload = AssignCrewRequest((b) => b
      ..position = CrewPosition.valueOf(position)
      ..characterId = characterId);
    await _api.assignCrew(id: shipId, assignCrewRequest: payload);
  }

  @override
  Future<void> unassignCrew({
    required String shipId,
    required String characterId,
  }) async {
    await _api.unassignCrew(id: shipId, characterId: characterId);
  }
}
