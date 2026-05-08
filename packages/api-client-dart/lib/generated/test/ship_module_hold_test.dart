import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for ShipModuleHold
void main() {
  final instance = ShipModuleHoldBuilder();
  // TODO add properties to the builder and call build()

  group(ShipModuleHold, () {
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

  });
}
