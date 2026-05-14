import 'package:equatable/equatable.dart';

/// Current / max pair used for `hull` and `energy` on a ship.
class ShipPoints extends Equatable {
  const ShipPoints({required this.current, required this.max});

  final int current;
  final int max;

  ShipPoints copyWith({int? current, int? max}) =>
      ShipPoints(current: current ?? this.current, max: max ?? this.max);

  @override
  List<Object?> get props => [current, max];
}

/// One assigned position on a ship's crew roster.
class DomainCrewSlot extends Equatable {
  const DomainCrewSlot({required this.position, this.assignedCharacterId});

  /// `captain | pilot | sensorOp | gunner | engineer | serviceCrew`.
  final String position;

  /// Null when the berth is vacant.
  final String? assignedCharacterId;

  @override
  List<Object?> get props => [position, assignedCharacterId];
}

/// One installed module on a ship. Variant-specific fields (weapon, hold,
/// sensor, torpedo) are flattened into nullable fields — the active subset
/// depends on [slot].
class DomainShipModule extends Equatable {
  const DomainShipModule({
    required this.id,
    required this.slot,
    required this.name,
    required this.energyUse,
    this.notes,
    this.weaponDamage,
    this.weaponBonus,
    this.weaponRange,
    this.weaponCritThreshold,
    this.cargoTons,
    this.concealed,
    this.torpedoCount,
    this.mineCount,
    this.detectionBonus,
  });

  final String id;

  /// Wire-form slot identifier (`BRIDGE`, `REACTOR`, `DRIVE`, `WEAPON`,
  /// `SENSOR`, `HOLD`, `TORPEDO`, `OTHER`, …).
  final String slot;
  final String name;
  final int energyUse;
  final String? notes;

  // Weapon
  final int? weaponDamage;
  final int? weaponBonus;
  final String? weaponRange;
  final int? weaponCritThreshold;

  // Hold
  final int? cargoTons;
  final bool? concealed;

  // Torpedo
  final int? torpedoCount;
  final int? mineCount;

  // Sensor
  final int? detectionBonus;

  @override
  List<Object?> get props => [
        id,
        slot,
        name,
        energyUse,
        notes,
        weaponDamage,
        weaponBonus,
        weaponRange,
        weaponCritThreshold,
        cargoTons,
        concealed,
        torpedoCount,
        mineCount,
        detectionBonus,
      ];
}

/// Full ship aggregate consumed by the sheet page.
class Ship extends Equatable {
  const Ship({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.shipClass,
    required this.model,
    required this.registry,
    required this.hull,
    required this.energy,
    required this.armor,
    required this.maneuverability,
    required this.signature,
    required this.speed,
    required this.cargoCapacity,
    required this.modules,
    required this.crew,
    required this.problems,
    required this.history,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String name;

  /// Wire-form class identifier (e.g. `light-freighter`, `heavy-cruiser`).
  final String shipClass;
  final String? model;
  final String? registry;
  final ShipPoints hull;
  final ShipPoints energy;
  final int armor;
  final int maneuverability;
  final int signature;
  final int speed;
  final int cargoCapacity;
  final List<DomainShipModule> modules;
  final List<DomainCrewSlot> crew;
  final List<String> problems;
  final String? history;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ship copyWith({
    String? name,
    String? model,
    String? registry,
    ShipPoints? hull,
    ShipPoints? energy,
    int? armor,
    int? maneuverability,
    int? signature,
    int? speed,
    int? cargoCapacity,
    List<DomainShipModule>? modules,
    List<DomainCrewSlot>? crew,
    List<String>? problems,
    String? history,
    String? notes,
  }) =>
      Ship(
        id: id,
        ownerId: ownerId,
        name: name ?? this.name,
        shipClass: shipClass,
        model: model ?? this.model,
        registry: registry ?? this.registry,
        hull: hull ?? this.hull,
        energy: energy ?? this.energy,
        armor: armor ?? this.armor,
        maneuverability: maneuverability ?? this.maneuverability,
        signature: signature ?? this.signature,
        speed: speed ?? this.speed,
        cargoCapacity: cargoCapacity ?? this.cargoCapacity,
        modules: modules ?? this.modules,
        crew: crew ?? this.crew,
        problems: problems ?? this.problems,
        history: history ?? this.history,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        shipClass,
        model,
        registry,
        hull,
        energy,
        armor,
        maneuverability,
        signature,
        speed,
        cargoCapacity,
        modules,
        crew,
        problems,
        history,
        notes,
        createdAt,
        updatedAt,
      ];
}

/// Light projection used by the ships list page.
class ShipSummary extends Equatable {
  const ShipSummary({
    required this.id,
    required this.name,
    required this.shipClass,
    this.model,
    this.registry,
  });

  final String id;
  final String name;
  final String shipClass;
  final String? model;
  final String? registry;

  @override
  List<Object?> get props => [id, name, shipClass, model, registry];
}
