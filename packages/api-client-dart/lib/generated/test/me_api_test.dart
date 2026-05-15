import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';


/// tests for MeApi
void main() {
  final instance = AppApiClient().getMeApi();

  group(MeApi, () {
    // List the caller's active session memberships
    //
    // Returns all active (non-left) session memberships for the authenticated user across all game sessions. Leaver rows (non-null `leftAt`) are excluded. Includes the linked character name and ID for each membership when set. 
    //
    //Future<GetMyMemberships200Response> getMyMemberships() async
    test('test getMyMemberships', () async {
      // TODO
    });

  });
}
