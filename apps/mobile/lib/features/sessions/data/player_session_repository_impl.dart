import 'package:app_api_client/app_api_client.dart' as api
    show
        MembershipsApi,
        MeApi,
        GameSessionsApi,
        AcceptInviteBody;

import 'package:coriolis_companion/features/sessions/data/player_membership_api_mapper.dart';
import 'package:coriolis_companion/features/sessions/domain/invite_preview.dart'
    as domain;
import 'package:coriolis_companion/features/sessions/domain/player_membership.dart';
import 'package:coriolis_companion/features/sessions/domain/player_session_repository.dart';

/// Bridges the generated `app_api_client` classes with the domain interface.
///
/// SDK types are confined to this file — the presentation layer never
/// imports `app_api_client` directly.
class PlayerSessionRepositoryImpl implements PlayerSessionRepository {
  const PlayerSessionRepositoryImpl({
    required api.MembershipsApi membershipsApi,
    required api.MeApi meApi,
    required api.GameSessionsApi gameSessionsApi,
  })  : _membershipsApi = membershipsApi,
        _meApi = meApi,
        _gameSessionsApi = gameSessionsApi;

  final api.MembershipsApi _membershipsApi;
  final api.MeApi _meApi;
  final api.GameSessionsApi _gameSessionsApi;

  // ── Interface impl ──────────────────────────────────────────────────────

  @override
  Future<List<PlayerMembership>> getMyMemberships() async {
    final res = await _meApi.getMyMemberships();
    final data = res.data;
    if (data == null) return const [];
    return data.items
        .map(PlayerMembershipApiMapper.fromSummary)
        .toList(growable: false);
  }

  @override
  Future<domain.InvitePreview> getInvitePreview(String token) async {
    final res = await _membershipsApi.getInvitePreview(token: token);
    final data = res.data;
    if (data == null) throw StateError('getInvitePreview returned empty body');
    return domain.InvitePreview(
      sessionName: data.sessionName,
      gmDisplayName: data.gmDisplayName,
      alreadyJoined: data.alreadyJoined,
    );
  }

  @override
  Future<PlayerMembership> acceptInvite(
    String token, {
    String? characterId,
  }) async {
    final body = api.AcceptInviteBody((b) => b..characterId = characterId);
    final res = await _membershipsApi.acceptInvite(
      token: token,
      acceptInviteBody: body,
    );
    final data = res.data;
    if (data == null) throw StateError('acceptInvite returned empty body');
    // AcceptInviteResponse.membership is GameSessionMembership (no sessionName).
    // The caller (JoinSessionCubit) holds the sessionName from the preview step.
    return PlayerMembershipApiMapper.fromMembership(data.membership, sessionName: '');
  }

  @override
  Future<void> leaveSession(String membershipId, String gameSessionId) async {
    // GameSessionsApi.removeMembership takes `id` (session id) + `membershipId`.
    await _gameSessionsApi.removeMembership(
      id: gameSessionId,
      membershipId: membershipId,
    );
  }
}
