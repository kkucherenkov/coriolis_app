import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for Ship
void main() {
  final instance = ShipBuilder();
  // TODO add properties to the builder and call build()

  group(Ship, () {
    // Opaque ship identifier (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Identifier of the owning user (cuid2)
    // String ownerId
    test('to test the property `ownerId`', () async {
      // TODO
    });

    // Ship name (1–80 characters)
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // ShipClass class_
    test('to test the property `class_`', () async {
      // TODO
    });

    // Model / shipyard name (e.g. \"Helebian Class III freighter\")
    // String model
    test('to test the property `model`', () async {
      // TODO
    });

    // Registry number / transponder code (e.g. \"KUA-7741-M\")
    // String registry
    test('to test the property `registry`', () async {
      // TODO
    });

    // ShipHull hull
    test('to test the property `hull`', () async {
      // TODO
    });

    // ShipEnergy energy
    test('to test the property `energy`', () async {
      // TODO
    });

    // Armor rating — number of dice rolled for the armor check (Броня)
    // int armor
    test('to test the property `armor`', () async {
      // TODO
    });

    // Maneuverability modifier (Манёвренность). Signed integer — negative for large classes (Class IV is −1, Class V is −2). Affects pilot skill checks in ship combat per ST3001 ГЛАВА 7. 
    // int maneuverability
    test('to test the property `maneuverability`', () async {
      // TODO
    });

    // Signature modifier (Заметность). Signed integer. Negative values mean the ship is harder to detect; positive values mean it is more visible. Applied to opponent sensor checks per ГЛАВА 7. 
    // int signature
    test('to test the property `signature`', () async {
      // TODO
    });

    // Speed in astronomical units per day (Скорость per ГЛАВА 7 Table 7.5)
    // int speed
    test('to test the property `speed`', () async {
      // TODO
    });

    // Total cargo capacity in tonnes across all hold modules (Вместимость per ГЛАВА 7 Table 7.6: Class III = 50 tonnes). 
    // int cargoCapacity
    test('to test the property `cargoCapacity`', () async {
      // TODO
    });

    // Installed modules including the three mandatory ones (BRIDGE, REACTOR, DRIVE). Optional modules consume the class module-slot budget. 
    // BuiltList<ShipModule> modules
    test('to test the property `modules`', () async {
      // TODO
    });

    // Crew assignment roster
    // BuiltList<CrewSlot> crew
    test('to test the property `crew`', () async {
      // TODO
    });

    // List of active ship problems (free-text entries, e.g. damage effects or wear-and-tear notes per ГЛАВА 7 wear table). 
    // BuiltList<String> problems
    test('to test the property `problems`', () async {
      // TODO
    });

    // Free-form ship history / background text (Markdown)
    // String history
    test('to test the property `history`', () async {
      // TODO
    });

    // GM / player operational notes (Markdown)
    // String notes
    test('to test the property `notes`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

    // DateTime updatedAt
    test('to test the property `updatedAt`', () async {
      // TODO
    });

  });
}
