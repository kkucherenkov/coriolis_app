import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';

// tests for ShareLink
void main() {
  final instance = ShareLinkBuilder();
  // TODO add properties to the builder and call build()

  group(ShareLink, () {
    // Opaque share-link identifier (cuid2). Used for revocation.
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // 24-character URL-safe slug. Use in the public URL: `/api/v1/public/character/{slug}`. 
    // String slug
    test('to test the property `slug`', () async {
      // TODO
    });

    // ID of the character this link exposes.
    // String characterId
    test('to test the property `characterId`', () async {
      // TODO
    });

    // Whether the `notes` field is included in the public character response. Always false if not set at creation time. 
    // bool includeGmNotes
    test('to test the property `includeGmNotes`', () async {
      // TODO
    });

    // Owner-assigned label for this link.
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // Expiry instant. Null for permanent links.
    // DateTime expiresAt
    test('to test the property `expiresAt`', () async {
      // TODO
    });

    // Revocation instant. Null if active. When set, the public endpoint returns 410 Gone. 
    // DateTime revokedAt
    test('to test the property `revokedAt`', () async {
      // TODO
    });

    // ISO-8601 instant of the last recorded public view. Updated asynchronously (up to 60 seconds lag) via the view-tracker flush job. Null until the first view is flushed. 
    // DateTime lastViewedAt
    test('to test the property `lastViewedAt`', () async {
      // TODO
    });

    // Cumulative count of public views. Updated asynchronously; may lag by up to 60 seconds. 
    // int viewCount
    test('to test the property `viewCount`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

    // DateTime updatedAt
    test('to test the property `updatedAt`', () async {
      // TODO
    });

  });
}
