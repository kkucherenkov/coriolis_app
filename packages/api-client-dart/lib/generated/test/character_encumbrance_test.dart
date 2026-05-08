import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for CharacterEncumbrance
void main() {
  final instance = CharacterEncumbranceBuilder();
  // TODO add properties to the builder and call build()

  group(CharacterEncumbrance, () {
    // Sum of non-stowed item weights; set by the server
    // num current
    test('to test the property `current`', () async {
      // TODO
    });

    // Derived from STR × 2; set by the server
    // int max
    test('to test the property `max`', () async {
      // TODO
    });

  });
}
