import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for InitiativeRollResult
void main() {
  final instance = InitiativeRollResultBuilder();
  // TODO add properties to the builder and call build()

  group(InitiativeRollResult, () {
    // Full updated combatant list sorted by `turnOrder` ascending (0 = acts first). Every combatant carries a non-null `initiative` and `turnOrder` after this operation. 
    // BuiltList<Combatant> combatants
    test('to test the property `combatants`', () async {
      // TODO
    });

    // Current combat round after the operation. For `rollInitiative` this is always 1 (the `setup → active` transition sets `round` from 0 to 1). For `reorderInitiative` this reflects the encounter's current round (unchanged by a reorder). 
    // int round
    test('to test the property `round`', () async {
      // TODO
    });

  });
}
