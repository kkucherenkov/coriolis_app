import 'package:app_api_client/app_api_client.dart'
    show
        ShipsApi,
        ShipClass,
        ShipCreate,
        ShipUpdate,
        ShipUpdateHull,
        ShipModuleCreate,
        ShipModuleUpdate,
        ShipModuleOtherCreate,
        ShipModuleOtherUpdate,
        ShipModuleHoldCreate,
        ShipModuleHoldUpdate,
        ShipModuleHoldCreateSlotEnum,
        ShipModuleTorpedoCreate,
        ShipModuleTorpedoUpdate,
        ShipModuleTorpedoCreateSlotEnum,
        ShipModuleSensorCreate,
        ShipModuleSensorUpdate,
        ShipModuleSensorCreateSlotEnum,
        ShipModuleWeaponCreate,
        ShipModuleWeaponUpdate,
        ShipModuleWeaponCreateSlotEnum,
        ShipModuleSlot,
        AssignCrewRequest,
        CrewPosition,
        ShipWeaponRange;
import 'package:one_of/one_of.dart';
import 'package:built_collection/built_collection.dart';

import 'package:coriolis_companion/features/ships/data/ship_api_mapper.dart';
import 'package:coriolis_companion/features/ships/domain/ship.dart';
import 'package:coriolis_companion/features/ships/domain/ship_repository.dart';

/// Adapter bridging the generated [ShipsApi] with the domain
/// [ShipRepository]. All API types are contained to this file.
class ShipRepositoryImpl implements ShipRepository {
  const ShipRepositoryImpl({required ShipsApi api}) : _api = api;

  final ShipsApi _api;

  // ── ShipRepository ───────────────────────────────────────────────────────

  @override
  Future<List<ShipSummary>> list({int limit = 20}) async {
    final response = await _api.listShips(limit: limit);
    final body = response.data;
    if (body == null) return [];
    return body.items.map(ShipApiMapper.toSummary).toList(growable: false);
  }

  @override
  Future<Ship> get(String id) async {
    final response = await _api.getShip(id: id);
    final body = response.data;
    if (body == null) throw StateError('Empty response for ship $id');
    return ShipApiMapper.toDomain(body);
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
    return ShipApiMapper.toDomain(body);
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
    return ShipApiMapper.toDomain(body);
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
    return ShipApiMapper.toDomain(body);
  }

  @override
  Future<Ship> exportSnapshot(String id) async {
    final response = await _api.exportShip(id: id);
    final body = response.data;
    if (body == null) throw StateError('Empty response after export');
    return ShipApiMapper.toDomain(body);
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

  /// `oneOf` discriminator subtype lists for ShipModule mutations.
  ///
  /// The ordering mirrors the SDK's generated `oneOfTypes` list so that
  /// `OneOfDynamic.typeIndex` (= `indexOf(type)`) resolves correctly.
  /// Canonical slot order (from the generated deserialiser):
  ///   BRIDGE CHAPEL COMMS CONCEALED-HOLD CRYO DOCKING DRIVE ESCAPE-PODS
  ///   HANGAR HOLD MEDICAL MINING OTHER PROXY-DECK QUARTERS REACTOR REPAIR
  ///   SENSOR TORPEDO WEAPON WORKSHOP
  static final _moduleCreateTypes = <Type>[
    ShipModuleOtherCreate,  // BRIDGE   [0]
    ShipModuleOtherCreate,  // CHAPEL   [1]
    ShipModuleOtherCreate,  // COMMS    [2]
    ShipModuleOtherCreate,  // CONCEALED-HOLD [3]
    ShipModuleOtherCreate,  // CRYO     [4]
    ShipModuleOtherCreate,  // DOCKING  [5]
    ShipModuleOtherCreate,  // DRIVE    [6]
    ShipModuleOtherCreate,  // ESCAPE-PODS [7]
    ShipModuleOtherCreate,  // HANGAR   [8]
    ShipModuleHoldCreate,   // HOLD     [9]
    ShipModuleOtherCreate,  // MEDICAL  [10]
    ShipModuleOtherCreate,  // MINING   [11]
    ShipModuleOtherCreate,  // OTHER    [12]
    ShipModuleOtherCreate,  // PROXY-DECK [13]
    ShipModuleOtherCreate,  // QUARTERS [14]
    ShipModuleOtherCreate,  // REACTOR  [15]
    ShipModuleOtherCreate,  // REPAIR   [16]
    ShipModuleSensorCreate, // SENSOR   [17]
    ShipModuleTorpedoCreate,// TORPEDO  [18]
    ShipModuleWeaponCreate, // WEAPON   [19]
    ShipModuleOtherCreate,  // WORKSHOP [20]
  ];
  static final _moduleUpdateTypes = <Type>[
    ShipModuleOtherUpdate,  // BRIDGE   [0]
    ShipModuleOtherUpdate,  // CHAPEL   [1]
    ShipModuleOtherUpdate,  // COMMS    [2]
    ShipModuleOtherUpdate,  // CONCEALED-HOLD [3]
    ShipModuleOtherUpdate,  // CRYO     [4]
    ShipModuleOtherUpdate,  // DOCKING  [5]
    ShipModuleOtherUpdate,  // DRIVE    [6]
    ShipModuleOtherUpdate,  // ESCAPE-PODS [7]
    ShipModuleOtherUpdate,  // HANGAR   [8]
    ShipModuleHoldUpdate,   // HOLD     [9]
    ShipModuleOtherUpdate,  // MEDICAL  [10]
    ShipModuleOtherUpdate,  // MINING   [11]
    ShipModuleOtherUpdate,  // OTHER    [12]
    ShipModuleOtherUpdate,  // PROXY-DECK [13]
    ShipModuleOtherUpdate,  // QUARTERS [14]
    ShipModuleOtherUpdate,  // REACTOR  [15]
    ShipModuleOtherUpdate,  // REPAIR   [16]
    ShipModuleSensorUpdate, // SENSOR   [17]
    ShipModuleTorpedoUpdate,// TORPEDO  [18]
    ShipModuleWeaponUpdate, // WEAPON   [19]
    ShipModuleOtherUpdate,  // WORKSHOP [20]
  ];

  @override
  Future<DomainShipModule> addOtherModule({
    required String shipId,
    required String slot,
    required String name,
    int energyUse = 0,
    String? notes,
  }) async {
    final inner = ShipModuleOtherCreate((b) => b
      ..slot = ShipModuleSlot.valueOf(slot)
      ..name = name
      ..energyUse = energyUse
      ..notes = notes);
    final payload = ShipModuleCreate((b) => b
      ..oneOf = OneOfDynamic(
        typeIndex: _moduleCreateTypes.indexOf(ShipModuleOtherCreate),
        types: _moduleCreateTypes,
        value: inner,
      ));
    final response = await _api.addShipModule(
      id: shipId,
      shipModuleCreate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after addShipModule');
    return ShipApiMapper.moduleToDomain(body);
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
    final inner = ShipModuleWeaponCreate((b) => b
      ..slot = ShipModuleWeaponCreateSlotEnum.WEAPON
      ..name = name
      ..energyUse = energyUse
      ..weaponBonus = weaponBonus
      ..weaponRange = ShipWeaponRange.valueOf(weaponRange)
      ..weaponDamage = weaponDamage
      ..weaponCritThreshold = weaponCritThreshold
      ..notes = notes);
    final payload = ShipModuleCreate((b) => b
      ..oneOf = OneOfDynamic(
        typeIndex: _moduleCreateTypes.indexOf(ShipModuleWeaponCreate),
        types: _moduleCreateTypes,
        value: inner,
      ));
    final response = await _api.addShipModule(
      id: shipId,
      shipModuleCreate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after addShipModule (WEAPON)');
    return ShipApiMapper.moduleToDomain(body);
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
    final inner = ShipModuleHoldCreate((b) => b
      ..slot = ShipModuleHoldCreateSlotEnum.HOLD
      ..name = name
      ..energyUse = energyUse
      ..cargoTons = cargoTons
      ..concealed = concealed
      ..notes = notes);
    final payload = ShipModuleCreate((b) => b
      ..oneOf = OneOfDynamic(
        typeIndex: _moduleCreateTypes.indexOf(ShipModuleHoldCreate),
        types: _moduleCreateTypes,
        value: inner,
      ));
    final response = await _api.addShipModule(
      id: shipId,
      shipModuleCreate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after addShipModule (HOLD)');
    return ShipApiMapper.moduleToDomain(body);
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
    final inner = ShipModuleTorpedoCreate((b) => b
      ..slot = ShipModuleTorpedoCreateSlotEnum.TORPEDO
      ..name = name
      ..energyUse = energyUse
      ..torpedoCount = torpedoCount
      ..mineCount = mineCount
      ..notes = notes);
    final payload = ShipModuleCreate((b) => b
      ..oneOf = OneOfDynamic(
        typeIndex: _moduleCreateTypes.indexOf(ShipModuleTorpedoCreate),
        types: _moduleCreateTypes,
        value: inner,
      ));
    final response = await _api.addShipModule(
      id: shipId,
      shipModuleCreate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after addShipModule (TORPEDO)');
    return ShipApiMapper.moduleToDomain(body);
  }

  @override
  Future<DomainShipModule> addSensorModule({
    required String shipId,
    required String name,
    int energyUse = 0,
    int? detectionBonus,
    String? notes,
  }) async {
    final inner = ShipModuleSensorCreate((b) => b
      ..slot = ShipModuleSensorCreateSlotEnum.SENSOR
      ..name = name
      ..energyUse = energyUse
      ..detectionBonus = detectionBonus
      ..notes = notes);
    final payload = ShipModuleCreate((b) => b
      ..oneOf = OneOfDynamic(
        typeIndex: _moduleCreateTypes.indexOf(ShipModuleSensorCreate),
        types: _moduleCreateTypes,
        value: inner,
      ));
    final response = await _api.addShipModule(
      id: shipId,
      shipModuleCreate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after addShipModule (SENSOR)');
    return ShipApiMapper.moduleToDomain(body);
  }

  @override
  Future<DomainShipModule> updateOtherModule({
    required String moduleId,
    String? name,
    int? energyUse,
    String? notes,
  }) async {
    final inner = ShipModuleOtherUpdate((b) {
      if (name != null) b.name = name;
      if (energyUse != null) b.energyUse = energyUse;
      if (notes != null) b.notes = notes;
    });
    final payload = ShipModuleUpdate((b) => b
      ..oneOf = OneOfDynamic(
        typeIndex: _moduleUpdateTypes.indexOf(ShipModuleOtherUpdate),
        types: _moduleUpdateTypes,
        value: inner,
      ));
    final response = await _api.updateShipModule(
      id: moduleId,
      shipModuleUpdate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after updateShipModule');
    return ShipApiMapper.moduleToDomain(body);
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
    final inner = ShipModuleWeaponUpdate((b) {
      if (name != null) b.name = name;
      if (energyUse != null) b.energyUse = energyUse;
      if (weaponBonus != null) b.weaponBonus = weaponBonus;
      if (weaponRange != null) b.weaponRange = ShipWeaponRange.valueOf(weaponRange);
      if (weaponDamage != null) b.weaponDamage = weaponDamage;
      if (weaponCritThreshold != null) b.weaponCritThreshold = weaponCritThreshold;
      if (notes != null) b.notes = notes;
    });
    final payload = ShipModuleUpdate((b) => b
      ..oneOf = OneOfDynamic(
        typeIndex: _moduleUpdateTypes.indexOf(ShipModuleWeaponUpdate),
        types: _moduleUpdateTypes,
        value: inner,
      ));
    final response = await _api.updateShipModule(
      id: moduleId,
      shipModuleUpdate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after updateShipModule (WEAPON)');
    return ShipApiMapper.moduleToDomain(body);
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
    final inner = ShipModuleHoldUpdate((b) {
      if (name != null) b.name = name;
      if (energyUse != null) b.energyUse = energyUse;
      if (cargoTons != null) b.cargoTons = cargoTons;
      if (concealed != null) b.concealed = concealed;
      if (notes != null) b.notes = notes;
    });
    final payload = ShipModuleUpdate((b) => b
      ..oneOf = OneOfDynamic(
        typeIndex: _moduleUpdateTypes.indexOf(ShipModuleHoldUpdate),
        types: _moduleUpdateTypes,
        value: inner,
      ));
    final response = await _api.updateShipModule(
      id: moduleId,
      shipModuleUpdate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after updateShipModule (HOLD)');
    return ShipApiMapper.moduleToDomain(body);
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
    final inner = ShipModuleTorpedoUpdate((b) {
      if (name != null) b.name = name;
      if (energyUse != null) b.energyUse = energyUse;
      if (torpedoCount != null) b.torpedoCount = torpedoCount;
      if (mineCount != null) b.mineCount = mineCount;
      if (notes != null) b.notes = notes;
    });
    final payload = ShipModuleUpdate((b) => b
      ..oneOf = OneOfDynamic(
        typeIndex: _moduleUpdateTypes.indexOf(ShipModuleTorpedoUpdate),
        types: _moduleUpdateTypes,
        value: inner,
      ));
    final response = await _api.updateShipModule(
      id: moduleId,
      shipModuleUpdate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after updateShipModule (TORPEDO)');
    return ShipApiMapper.moduleToDomain(body);
  }

  @override
  Future<DomainShipModule> updateSensorModule({
    required String moduleId,
    String? name,
    int? energyUse,
    int? detectionBonus,
    String? notes,
  }) async {
    final inner = ShipModuleSensorUpdate((b) {
      if (name != null) b.name = name;
      if (energyUse != null) b.energyUse = energyUse;
      if (detectionBonus != null) b.detectionBonus = detectionBonus;
      if (notes != null) b.notes = notes;
    });
    final payload = ShipModuleUpdate((b) => b
      ..oneOf = OneOfDynamic(
        typeIndex: _moduleUpdateTypes.indexOf(ShipModuleSensorUpdate),
        types: _moduleUpdateTypes,
        value: inner,
      ));
    final response = await _api.updateShipModule(
      id: moduleId,
      shipModuleUpdate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after updateShipModule (SENSOR)');
    return ShipApiMapper.moduleToDomain(body);
  }

  @override
  Future<void> deleteModule(String moduleId) async {
    await _api.deleteShipModule(id: moduleId);
  }
}
