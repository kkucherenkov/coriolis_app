import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for CombatantUpdate
void main() {
  final instance = CombatantUpdateBuilder();
  // TODO add properties to the builder and call build()

  group(CombatantUpdate, () {
    // Update the combatant display name.
    // String displayName
    test('to test the property `displayName`', () async {
      // TODO
    });

    // Update current hit points (may go negative).
    // int hpCurrent
    test('to test the property `hpCurrent`', () async {
      // TODO
    });

    // Update armor rating.
    // int armor
    test('to test the property `armor`', () async {
      // TODO
    });

    // Update the mystic signature value.
    // int signature
    test('to test the property `signature`', () async {
      // TODO
    });

    // Replace the full set of status flags. Well-known values: `broken`, `exposed`, `covered`, `prone`. 
    // BuiltList<String> statusFlags
    test('to test the property `statusFlags`', () async {
      // TODO
    });

    // Update GM notes in Markdown (max 500 characters).
    // String notes
    test('to test the property `notes`', () async {
      // TODO
    });

    // Read-only. Initiative is set exclusively by the Block 4 initiative-roll operation. This field is listed here for documentation purposes only; any value supplied in a PATCH request will be ignored. 
    // int initiative
    test('to test the property `initiative`', () async {
      // TODO
    });

    // Read-only. Turn order index is set exclusively by the Block 4 initiative operations. This field is listed here for documentation purposes only; any value supplied in a PATCH request will be ignored. 
    // int turnOrder
    test('to test the property `turnOrder`', () async {
      // TODO
    });

  });
}
