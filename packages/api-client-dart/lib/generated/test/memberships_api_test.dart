import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';


/// tests for MembershipsApi
void main() {
  final instance = AppApiClient().getMembershipsApi();

  group(MembershipsApi, () {
    // Accept an invite link and join the session
    //
    // Validates the invite token and creates a membership for the authenticated caller. Idempotent — if the caller is already an active member the existing membership is returned with 200. Returns 410 when the invite has been revoked. An optional `characterId` may be supplied to link a character at join time. 
    //
    //Future<AcceptInviteResponse> acceptInvite(String token, { AcceptInviteBody acceptInviteBody }) async
    test('test acceptInvite', () async {
      // TODO
    });

    // Public invite preview
    //
    // Returns session name + GM display name. Does not require authentication. If the caller is authenticated and already an active member, alreadyJoined is true. Returns 404 if the token is unknown or the invite is revoked. 
    //
    //Future<InvitePreview> getInvitePreview(String token) async
    test('test getInvitePreview', () async {
      // TODO
    });

  });
}
