import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for ShareLinkCreate
void main() {
  final instance = ShareLinkCreateBuilder();
  // TODO add properties to the builder and call build()

  group(ShareLinkCreate, () {
    // When true, the public character endpoint returns the top-level `notes` field. When false (default), `notes` is always null in the public response regardless of the character's actual notes value. 
    // bool includeGmNotes (default value: false)
    test('to test the property `includeGmNotes`', () async {
      // TODO
    });

    // ISO-8601 instant after which the link stops resolving. Omit or set to null for a permanent link. 
    // DateTime expiresAt
    test('to test the property `expiresAt`', () async {
      // TODO
    });

    // Optional human-readable label to distinguish this link from others in the owner's list (e.g. \"GM copy\", \"public preview\"). 
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

  });
}
