import 'package:app_api_client/app_api_client.dart' as api
    show
        MembershipsApi,
        MeApi,
        GameSessionsApi,
        AcceptInviteBody,
        MyMembershipSummary,
        GameSessionMembership;

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

  // ── Mapping helpers ─────────────────────────────────────────────────────

  static PlayerMembership _fromSummary(api.MyMembershipSummary src) =>
      PlayerMembership(
        membershipId: src.membershipId,
        gameSessionId: src.gameSessionId,
        sessionName: src.sessionName,
        // EnumClass.name returns the Dart identifier ('gm' / 'player').
        role: src.role.name,
        characterId: src.characterId,
        characterName: src.characterName,
        joinedAt: src.joinedAt,
      );

  static PlayerMembership _fromMembership(
    api.GameSessionMembership m,
    String sessionName,
  ) =>
      PlayerMembership(
        membershipId: m.id,
        gameSessionId: m.gameSessionId,
        // Server returns GameSessionMembership after accept; sessionName is
        // not included. Callers may re-fetch via getMyMemberships() when the
        // full name is required; pages that only need IDs use the stub value.
        sessionName: sessionName,
        role: m.role.name,
        characterId: m.characterId,
        characterName: m.characterName,
        joinedAt: m.joinedAt,
      );

  // ── Interface impl ──────────────────────────────────────────────────────

  @override
  Future<List<PlayerMembership>> getMyMemberships() async {
    final res = await _meApi.getMyMemberships();
    final data = res.data;
    if (data == null) return const [];
    return data.items.map(_fromSummary).toList(growable: false);
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
    return _fromMembership(data.membership, '');
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
