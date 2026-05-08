import 'package:test/test.dart';
import 'package:app_api_client/app_api_client.dart';


/// tests for UsersApi
void main() {
  final instance = AppApiClient().getUsersApi();

  group(UsersApi, () {
    // Get the authenticated user's profile.
    //
    // Returns the current user's profile fields sourced from the Better Auth `user` table. `email` and `createdAt` are read-only in this DTO — they are managed by Better Auth and cannot be changed via this endpoint.  See PRD §4.1 for full product context. Soft-deleted users receive a `404` because their sessions are revoked on deletion; this endpoint will therefore never return a user whose `deletedAt` is set (that field is an internal flag and is not exposed in this DTO). 
    //
    //Future<Me> getMe() async
    test('test getMe', () async {
      // TODO
    });

    // Update the authenticated user's mutable profile fields.
    //
    // Applies a partial update (PATCH semantics) to the authenticated user's profile. Only `displayName` is mutable via this endpoint.  `email` and `createdAt` are managed by Better Auth and are silently ignored if included in the request body — attempting to send them is treated as a `400` so the contract is unambiguous.  `displayName` constraints: - Must be between 1 and 80 characters when non-null (80 matches the   character-name guidance in PRD §5.2). - May be set to `null` to clear the field. - An empty string (`\"\"`) is rejected with `400`. 
    //
    //Future<Me> updateMe(MeUpdate meUpdate) async
    test('test updateMe', () async {
      // TODO
    });

  });
}
