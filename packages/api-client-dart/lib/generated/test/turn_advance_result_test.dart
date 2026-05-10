import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for TurnAdvanceResult
void main() {
  final instance = TurnAdvanceResultBuilder();
  // TODO add properties to the builder and call build()

  group(TurnAdvanceResult, () {
    // Id of the combatant whose turn is now active (the new `encounter.activeCombatantId` after the advance). 
    // String activeCombatantId
    test('to test the property `activeCombatantId`', () async {
      // TODO
    });

    // Current combat round after the advance. Incremented by 1 when the turn wraps from the last combatant back to index 0. 
    // int round
    test('to test the property `round`', () async {
      // TODO
    });

    // `true` when the advance wrapped past the last combatant and started a new round; `false` when the next combatant is within the same round. 
    // bool isNewRound
    test('to test the property `isNewRound`', () async {
      // TODO
    });

  });
}
