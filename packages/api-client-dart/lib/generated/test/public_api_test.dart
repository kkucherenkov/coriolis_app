import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';


/// tests for PublicApi
void main() {
  final instance = AppApiClient().getPublicApi();

  group(PublicApi, () {
    // OG image for a shared character (Feature 6.3 — not yet implemented)
    //
    // Returns a PNG Open Graph image for the shared character. Intended for social-media preview unfurling.  **This endpoint is not yet implemented.** It will always return 501 until Feature 6.3 lands the server-side renderer. Consumers should plan for the following cache headers on the eventual 200 response: `Cache-Control: public, max-age=3600, stale-while-revalidate=86400`. 
    //
    //Future<Uint8List> getCharacterOgImage(String slug) async
    test('test getCharacterOgImage', () async {
      // TODO
    });

    // Get a publicly-shared character by slug
    //
    // Returns the character associated with the given share-link slug. No authentication is required.  The `notes` field (top-level GM notes) is included only when the share link was created with `includeGmNotes: true`. If the link does not include GM notes, `notes` is always returned as `null` regardless of whether the character actually has notes.  Error semantics: - `404` — slug does not exist or was never created. - `410` — slug existed but has been revoked or has expired. 
    //
    //Future<Character> getPublicCharacter(String slug) async
    test('test getPublicCharacter', () async {
      // TODO
    });

  });
}
