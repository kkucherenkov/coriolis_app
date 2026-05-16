import 'package:app_api_client/app_api_client.dart'
    show
        CrewSlot,
        ShipModule,
        ShipModuleHold,
        ShipModuleSensor,
        ShipModuleTorpedo,
        ShipModuleWeapon,
        ShipModuleOther;
import 'package:app_api_client/app_api_client.dart' as api_client show Ship;

import 'package:coriolis_companion/features/ships/domain/ship.dart';

/// Single source of truth for the wire→domain transform.
///
/// Used by [ShipRepositoryImpl] for live API responses and by
/// [CachedShipRepository] for hydrating cached payloads.
final class ShipApiMapper {
  const ShipApiMapper._();

  static Ship toDomain(api_client.Ship src) => Ship(
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
        modules: src.modules.map(moduleToDomain).toList(growable: false),
        crew: src.crew.map(crewToDomain).toList(growable: false),
        problems: src.problems.toList(growable: false),
        history: src.history,
        notes: src.notes,
        createdAt: src.createdAt,
        updatedAt: src.updatedAt,
      );

  static ShipSummary toSummary(api_client.Ship src) => ShipSummary(
        id: src.id,
        name: src.name,
        shipClass: src.class_.name,
        model: src.model,
        registry: src.registry,
      );

  static DomainCrewSlot crewToDomain(CrewSlot src) => DomainCrewSlot(
        position: src.position.name,
        assignedCharacterId: src.assignedCharacterId,
      );

  static DomainShipModule moduleToDomain(ShipModule src) {
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
}
