import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for CriticalInjury
void main() {
  final instance = CriticalInjuryBuilder();
  // TODO add properties to the builder and call build()

  group(CriticalInjury, () {
    // Opaque identifier (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Short name of the injury (e.g. \"Broken arm\")
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // CriticalInjurySeverity severity
    test('to test the property `severity`', () async {
      // TODO
    });

    // Free-text description of the mechanical or narrative effect
    // String effect
    test('to test the property `effect`', () async {
      // TODO
    });

    // ISO-8601 instant when the injury was recorded
    // DateTime acquiredAt
    test('to test the property `acquiredAt`', () async {
      // TODO
    });

  });
}
