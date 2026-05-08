import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for Me
void main() {
  final instance = MeBuilder();
  // TODO add properties to the builder and call build()

  group(Me, () {
    // Opaque user identifier issued by Better Auth (cuid2)
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Primary email address. Read-only via this API.
    // String email
    test('to test the property `email`', () async {
      // TODO
    });

    // User-chosen display name shown in share-link banners and the avatar menu. Null when the user has not set one yet. 
    // String displayName
    test('to test the property `displayName`', () async {
      // TODO
    });

    // ISO-8601 instant when the account was created. Read-only via this API.
    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

  });
}
