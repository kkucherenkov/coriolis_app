import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';


/// tests for SharingApi
void main() {
  final instance = AppApiClient().getSharingApi();

  group(SharingApi, () {
    // Create a share link for a character
    //
    // Creates a new share link for the authenticated user's character. The link is identified by a 24-character unguessable slug. Multiple links per character are allowed — useful for different audiences or different `includeGmNotes` settings.  The optional `label` (1–80 characters) helps the owner distinguish links. The optional `expiresAt` is an ISO-8601 instant; omit (or set to null) for a permanent link. The optional `includeGmNotes` flag (default false) controls whether the top-level `notes` field is included in the public character read. 
    //
    //Future<ShareLink> createShareLink(String id, ShareLinkCreate shareLinkCreate) async
    test('test createShareLink', () async {
      // TODO
    });

    // List share links for a character
    //
    // Returns all non-revoked share links for the authenticated user's character, ordered newest-first. Revoked links are excluded by default. A `?includeRevoked` query parameter may be added in a future version. 
    //
    //Future<ShareLinkList> listShareLinks(String id) async
    test('test listShareLinks', () async {
      // TODO
    });

    // Revoke a share link
    //
    // Soft-revokes a share link by setting its `revokedAt` timestamp. After revocation, `GET /api/v1/public/character/{slug}` returns 410 Gone. The link row is not deleted — historical view counts are preserved. The caller must own the character the link belongs to. 
    //
    //Future revokeShareLink(String id) async
    test('test revokeShareLink', () async {
      // TODO
    });

  });
}
