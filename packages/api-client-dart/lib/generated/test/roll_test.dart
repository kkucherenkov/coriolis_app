import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for Roll
void main() {
  final instance = RollBuilder();
  // TODO add properties to the builder and call build()

  group(Roll, () {
    // Opaque roll identifier (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Identifier of the character who made the roll
    // String characterId
    test('to test the property `characterId`', () async {
      // TODO
    });

    // Game session this roll belongs to. Null until Feature 7.2 (GameSession resource) ships. Clients should tolerate null. 
    // String gameSessionId
    test('to test the property `gameSessionId`', () async {
      // TODO
    });

    // Human-readable roll label, e.g. \"Pilot · Evade\"
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // Number of d6 rolled (after condition penalties applied by caller)
    // int pool
    test('to test the property `pool`', () async {
      // TODO
    });

    // Current face values of all dice. After a push, rerolled non-6 values are updated in place; the array always has `pool` elements. 
    // BuiltList<int> dice
    test('to test the property `dice`', () async {
      // TODO
    });

    // Number of 6s in the current dice array
    // int hits
    test('to test the property `hits`', () async {
      // TODO
    });

    // Whether this roll has been pushed. Once true, further pushes are rejected.
    // bool pushed
    test('to test the property `pushed`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

  });
}
