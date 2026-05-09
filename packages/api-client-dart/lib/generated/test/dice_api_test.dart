import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';


/// tests for DiceApi
void main() {
  final instance = AppApiClient().getDiceApi();

  group(DiceApi, () {
    // Roll dice for a character
    //
    // Rolls `pool` d6 server-side using a cryptographically secure RNG. Hits are counted as the number of 6s. The caller provides a human-readable `label` (e.g. \"Pilot · Evade\") and an optional `gameSessionId` (reserved for Feature 7.2 — pass null until GameSession lands).  Pool is clamped by the server from the submitted value. Condition penalties must be pre-applied by the caller before sending `pool`; the server does not re-apply them from character state. 
    //
    //Future<Roll> createRoll(String id, RollCreate rollCreate) async
    test('test createRoll', () async {
      // TODO
    });

    // List roll history for a character
    //
    // Returns the most recent rolls for the character, ordered newest-first. Default limit is 50; maximum is 100. 
    //
    //Future<RollList> listRolls(String id, { int limit }) async
    test('test listRolls', () async {
      // TODO
    });

    // Push (reroll) a roll
    //
    // Rerolls all non-6 dice exactly once. After a push the roll cannot be pushed again (`pushed` becomes `true`). Returns 422 with code `ROLL_NOT_PUSHABLE` if: - The roll has already been pushed. - The owning character has the Exhausted condition (PRD §10). 
    //
    //Future<Roll> pushRoll(String id) async
    test('test pushRoll', () async {
      // TODO
    });

  });
}
