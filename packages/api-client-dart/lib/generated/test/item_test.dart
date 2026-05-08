import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for Item
void main() {
  final instance = ItemBuilder();
  // TODO add properties to the builder and call build()

  group(Item, () {
    // Opaque identifier (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // String type
    test('to test the property `type`', () async {
      // TODO
    });

    // Item name
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // Base damage dice
    // int damage
    test('to test the property `damage`', () async {
      // TODO
    });

    // ItemRangeEnum range
    test('to test the property `range`', () async {
      // TODO
    });

    // Bonus dice added to the attack pool
    // int bonus
    test('to test the property `bonus`', () async {
      // TODO
    });

    // Critical threshold (roll this many successes to crit)
    // int crit
    test('to test the property `crit`', () async {
      // TODO
    });

    // Encumbrance weight in slots
    // num weight
    test('to test the property `weight`', () async {
      // TODO
    });

    // Feature tags (e.g. \"Vacuum Sealed\", \"Exo-Skeleton\")
    // BuiltList<String> features
    test('to test the property `features`', () async {
      // TODO
    });

    // bool equipped
    test('to test the property `equipped`', () async {
      // TODO
    });

    // Armor rating — reduces incoming damage
    // int armorRating
    test('to test the property `armorRating`', () async {
      // TODO
    });

    // Number of units
    // int quantity
    test('to test the property `quantity`', () async {
      // TODO
    });

    // Optional free-text notes
    // String notes
    test('to test the property `notes`', () async {
      // TODO
    });

    // System strain points consumed (0–6)
    // int bodyPoints
    test('to test the property `bodyPoints`', () async {
      // TODO
    });

    // Description of the module's effect and energy use
    // String effect
    test('to test the property `effect`', () async {
      // TODO
    });

    // ItemSlotType slot
    test('to test the property `slot`', () async {
      // TODO
    });

  });
}
