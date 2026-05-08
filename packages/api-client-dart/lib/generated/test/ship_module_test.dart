import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for ShipModule
void main() {
  final instance = ShipModuleBuilder();
  // TODO add properties to the builder and call build()

  group(ShipModule, () {
    // Opaque module identifier (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // ShipModuleSlot slot
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

    // Number of torpedoes currently loaded
    // int torpedoCount
    test('to test the property `torpedoCount`', () async {
      // TODO
    });

    // Number of mines currently loaded
    // int mineCount
    test('to test the property `mineCount`', () async {
      // TODO
    });

    // Cargo capacity in tonnes (class-dependent per Table 7.6)
    // int cargoTons
    test('to test the property `cargoTons`', () async {
      // TODO
    });

    // True for a потайной грузовой отсек (concealed hold)
    // bool concealed (default value: false)
    test('to test the property `concealed`', () async {
      // TODO
    });

    // Modifier added to sensor / dataDjinn checks
    // int detectionBonus (default value: 1)
    test('to test the property `detectionBonus`', () async {
      // TODO
    });

  });
}
