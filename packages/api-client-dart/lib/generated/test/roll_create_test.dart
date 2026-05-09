import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for RollCreate
void main() {
  final instance = RollCreateBuilder();
  // TODO add properties to the builder and call build()

  group(RollCreate, () {
    // Human-readable roll label, e.g. \"Pilot · Evade\"
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // Number of d6 to roll. Must be between 1 and 10 inclusive. Condition pool penalties must be pre-applied by the caller before submitting. 
    // int pool
    test('to test the property `pool`', () async {
      // TODO
    });

    // Optional game session identifier. Reserved for Feature 7.2. Pass null or omit until GameSession lands. 
    // String gameSessionId
    test('to test the property `gameSessionId`', () async {
      // TODO
    });

  });
}
