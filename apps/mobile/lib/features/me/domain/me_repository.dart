import 'package:coriolis_companion/features/me/domain/me_profile.dart';

/// Port for reading and patching the authenticated user's server profile.
abstract class MeRepository {
  /// Fetches the caller's profile from `GET /api/v1/me`.
  Future<MeProfile> getMe();

  /// Sends a partial update to `PATCH /api/v1/me`.
  ///
  /// Only [chatDockedCollapsed] is needed by mobile today; the parameter list
  /// is intentionally narrow — expand when other fields are consumed.
  Future<MeProfile> patchMe({required bool chatDockedCollapsed});
}
