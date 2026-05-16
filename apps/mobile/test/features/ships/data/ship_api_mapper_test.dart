import 'package:app_api_client/app_api_client.dart' as api_client;
import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_of/one_of.dart';

import 'package:coriolis_companion/features/ships/data/ship_api_mapper.dart';
import 'package:coriolis_companion/features/ships/domain/ship.dart';

api_client.Ship _wire({
  String id = 'ship-1',
  String name = 'Tannhauser Gate',
}) =>
    api_client.Ship((b) => b
      ..id = id
      ..ownerId = 'user-1'
      ..name = name
      ..class_ = api_client.ShipClass.lightFreighter
      ..armor = 1
      ..maneuverability = 0
      ..signature = -1
      ..speed = 3
      ..cargoCapacity = 50
      ..hull.replace(api_client.ShipHull((h) => h
        ..current = 8
        ..max = 8))
      ..energy.replace(api_client.ShipEnergy((e) => e
        ..current = 6
        ..max = 6))
      ..modules.replace(BuiltList<api_client.ShipModule>())
      ..crew.replace(BuiltList<api_client.CrewSlot>())
      ..problems.replace(BuiltList<String>())
      ..createdAt = DateTime.utc(2026, 5, 17)
      ..updatedAt = DateTime.utc(2026, 5, 17));

api_client.ShipModule _weaponModule() => api_client.ShipModule((b) => b
  ..oneOf = OneOfDynamic(
    typeIndex: 0,
    types: [api_client.ShipModuleWeapon],
    value: api_client.ShipModuleWeapon((w) => w
      ..id = 'mod-1'
      ..slot = api_client.ShipModuleSlot.WEAPON
      ..name = 'Laser Cannon'
      ..energyUse = 2
      ..weaponDamage = 3
      ..weaponBonus = 1
      ..weaponRange = api_client.ShipWeaponRange.close
      ..weaponCritThreshold = 6),
  ));

void main() {
  test('toDomain maps scalar fields correctly', () {
    final Ship domain = ShipApiMapper.toDomain(_wire(name: 'Veiled Sun'));

    expect(domain.id, 'ship-1');
    expect(domain.name, 'Veiled Sun');
    expect(domain.shipClass, 'lightFreighter');
    expect(domain.armor, 1);
    expect(domain.signature, -1);
    expect(domain.hull, const ShipPoints(current: 8, max: 8));
    expect(domain.energy, const ShipPoints(current: 6, max: 6));
    expect(domain.modules, isEmpty);
    expect(domain.crew, isEmpty);
  });

  test('toSummary extracts id + name + shipClass', () {
    final summary = ShipApiMapper.toSummary(_wire());

    expect(summary.id, 'ship-1');
    expect(summary.name, 'Tannhauser Gate');
    expect(summary.shipClass, 'lightFreighter');
    expect(summary.model, isNull);
    expect(summary.registry, isNull);
  });

  test('moduleToDomain maps WEAPON variant fields', () {
    final DomainShipModule mod = ShipApiMapper.moduleToDomain(_weaponModule());

    expect(mod.id, 'mod-1');
    expect(mod.slot, 'WEAPON');
    expect(mod.name, 'Laser Cannon');
    expect(mod.energyUse, 2);
    expect(mod.weaponDamage, 3);
    expect(mod.weaponBonus, 1);
    expect(mod.weaponRange, 'close');
    expect(mod.weaponCritThreshold, 6);
    // Hold / torpedo / sensor fields must be null for a weapon module.
    expect(mod.cargoTons, isNull);
    expect(mod.torpedoCount, isNull);
    expect(mod.detectionBonus, isNull);
  });
}
