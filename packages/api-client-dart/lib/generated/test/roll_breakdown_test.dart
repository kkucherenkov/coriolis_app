import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for RollBreakdown
void main() {
  final instance = RollBreakdownBuilder();
  // TODO add properties to the builder and call build()

  group(RollBreakdown, () {
    // Attribute contribution (e.g. STR 4 → 4).
    // int attribute
    test('to test the property `attribute`', () async {
      // TODO
    });

    // Skill rank contribution (e.g. Force 2 → 2).
    // int skill
    test('to test the property `skill`', () async {
      // TODO
    });

    // Bonus dice from equipment (weapon `bonus`, armor +1, gear-specific dice).
    // int gear
    test('to test the property `gear`', () async {
      // TODO
    });

    // Situational positive modifier (cover, range, ambush, etc).
    // int modifier
    test('to test the property `modifier`', () async {
      // TODO
    });

    // Dice from cooperative helpers (ST3001 ГЛАВА 3 §«Помощь»).
    // int helpers
    test('to test the property `helpers`', () async {
      // TODO
    });

  });
}
