import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for ShipModuleSensor
void main() {
  final instance = ShipModuleSensorBuilder();
  // TODO add properties to the builder and call build()

  group(ShipModuleSensor, () {
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

    // Modifier added to sensor / dataDjinn checks
    // int detectionBonus (default value: 1)
    test('to test the property `detectionBonus`', () async {
      // TODO
    });

  });
}
