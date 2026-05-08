import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for ShipModuleWeapon
void main() {
  final instance = ShipModuleWeaponBuilder();
  // TODO add properties to the builder and call build()

  group(ShipModuleWeapon, () {
    // Opaque module identifier (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // String slot
    test('to test the property `slot`', () async {
      // TODO
    });

    // Module name (e.g. \"Graviton Projector\", \"Smuggler hold\")
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // Energy points consumed by this module when active
    // int energyUse
    test('to test the property `energyUse`', () async {
      // TODO
    });

    // Free-text notes; used for damage state, special conditions, etc.
    // String notes
    test('to test the property `notes`', () async {
      // TODO
    });

    // Modifier dice added to the attack pool (Мод. column in Table 7.9)
    // int weaponBonus
    test('to test the property `weaponBonus`', () async {
      // TODO
    });

    // ShipWeaponRange weaponRange
    test('to test the property `weaponRange`', () async {
      // TODO
    });

    // Structural damage dealt on a hit
    // int weaponDamage
    test('to test the property `weaponDamage`', () async {
      // TODO
    });

    // Number of successes required to trigger a critical effect
    // int weaponCritThreshold
    test('to test the property `weaponCritThreshold`', () async {
      // TODO
    });

  });
}
