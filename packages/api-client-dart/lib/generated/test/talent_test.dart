import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for Talent
void main() {
  final instance = TalentBuilder();
  // TODO add properties to the builder and call build()

  group(Talent, () {
    // Opaque identifier (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Talent name (e.g. \"Wing-Mate\", \"Stunt Pilot\")
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // Rules text or flavour description of the talent
    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // Talent rank (1 = basic, 2 = journeyman, 3 = master)
    // int rank
    test('to test the property `rank`', () async {
      // TODO
    });

    // ISO-8601 instant when the talent was recorded on the sheet
    // DateTime acquiredAt
    test('to test the property `acquiredAt`', () async {
      // TODO
    });

  });
}
