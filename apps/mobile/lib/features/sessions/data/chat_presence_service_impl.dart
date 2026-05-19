import 'dart:async';
import 'dart:convert';

import 'package:app_api_client/app_api_client.dart' show RealtimeApi;
import 'package:centrifuge/centrifuge.dart' as cf;
import 'package:meta/meta.dart';

import 'package:coriolis_companion/shared/config/app_config.dart';
import 'package:coriolis_companion/features/sessions/domain/chat_presence_service.dart';

/// Centrifugo-backed [ChatPresenceService].
///
/// Subscribes to the `session.<gameSessionId>` channel — the same channel
/// that already carries `dp.changed`, `roll.pushed`, and `combat.updated`
/// publications. Because Centrifugo presence is per-channel (not
/// per-publication), a dedicated subscription here is the cleanest approach;
/// the centrifuge_dart SDK supports multiple `Subscription` objects on the
/// same `Client`, so a separate client is NOT required to do so — but we
/// follow the project convention of one `Client` per service to keep
/// lifecycle management self-contained.
///
/// ### JWT `info` claim shape (Block 1 contract, AsyncAPI 0.13.0)
///
/// ```json
/// {
///   "memberships": [
///     { "gameSessionId": "gs-1", "membershipId": "m-a1b2" }
///   ]
/// }
/// ```
///
/// This value is carried in the `connInfo` field (`List<int>` bytes) of every
/// `JoinEvent`, `LeaveEvent`, and `ClientInfo` entry in `PresenceResult`.
class ChatPresenceServiceImpl implements ChatPresenceService {
  ChatPresenceServiceImpl({
    required RealtimeApi realtimeApi,
    required AppConfig config,
  })  : _realtimeApi = realtimeApi,
        _config = config;

  final RealtimeApi _realtimeApi;
  final AppConfig _config;

  cf.Client? _client;
  cf.Subscription? _sub;
  StreamSubscription<cf.JoinEvent>? _joinSub;
  StreamSubscription<cf.LeaveEvent>? _leaveSub;

  /// Active mapping of Centrifugo client_id → membershipId for the current
  /// session. Updated by the presence snapshot + join/leave deltas.
  ///
  /// Exposed as [clientToMembership] for testing.
  final Map<String, String> _clientToMembership = {};

  String? _currentGameSessionId;

  final _controller = StreamController<Set<String>>.broadcast();

  @override
  Stream<Set<String>> get onlineIds => _controller.stream;

  Future<String> _fetchToken() async {
    final res = await _realtimeApi.issueRealtimeToken();
    final token = res.data?.token;
    if (token == null || token.isEmpty) {
      throw StateError('Realtime token endpoint returned empty token');
    }
    return token;
  }

  @override
  Future<void> start({
    required String gameSessionId,
    required String myMembershipId,
  }) async {
    if (_client != null) return;

    _currentGameSessionId = gameSessionId;

    final token = await _fetchToken();
    final clientConfig = cf.ClientConfig(
      token: token,
      getToken: (_) => _fetchToken(),
    );
    final client = cf.createClient(_config.realtimeWsUrl, clientConfig);
    _client = client;

    final sub = client.newSubscription('session.$gameSessionId');
    _sub = sub;

    // Subscribe to join/leave events before subscribing so no events are
    // missed between subscribe() and the subscribed callback.
    _joinSub = sub.join.listen(_onJoin);
    _leaveSub = sub.leave.listen(_onLeave);

    // Fetch the initial presence snapshot after the subscription is established.
    sub.subscribed.listen((_) => _fetchPresenceSnapshot(sub, gameSessionId));

    sub.subscribe();
    await client.connect();
  }

  Future<void> _fetchPresenceSnapshot(
    cf.Subscription sub,
    String gameSessionId,
  ) async {
    try {
      final result = await sub.presence();
      _clientToMembership.clear();
      for (final entry in result.clients.entries) {
        final membershipId = _membershipIdFromConnInfo(
          entry.value.connInfo,
          gameSessionId,
        );
        if (membershipId != null) {
          _clientToMembership[entry.key] = membershipId;
        }
      }
      _emitSnapshot();
    } on Object {
      // Presence call can fail if the channel isn't configured for presence
      // (shouldn't happen post-Block-1, but silently degrade rather than
      // crash the chat panel).
      _emitSnapshot();
    }
  }

  void _onJoin(cf.JoinEvent event) {
    final membershipId = _membershipIdFromConnInfo(
      event.connInfo,
      _currentGameSessionId,
    );
    if (membershipId != null) {
      _clientToMembership[event.client] = membershipId;
      _emitSnapshot();
    }
  }

  void _onLeave(cf.LeaveEvent event) {
    _clientToMembership.remove(event.client);
    _emitSnapshot();
  }

  void _emitSnapshot() {
    if (_controller.isClosed) return;
    _controller.add(Set<String>.unmodifiable(_clientToMembership.values.toSet()));
  }

  // ── Test hooks ──────────────────────────────────────────────────────────

  /// Direct access to the internal client→membership map for tests.
  @visibleForTesting
  Map<String, String> get clientToMembership => _clientToMembership;

  /// Re-emit the current snapshot. Exposed for instrumented test subclasses.
  @visibleForTesting
  void emitSnapshot() => _emitSnapshot();

  /// Decode `connInfo` bytes for a given session. Exposed for unit tests.
  @visibleForTesting
  String? membershipIdFromConnInfo(
    List<int>? connInfo,
    String? gameSessionId,
  ) =>
      _membershipIdFromConnInfo(connInfo, gameSessionId);

  // ── Internal helpers ─────────────────────────────────────────────────────

  /// Decodes `connInfo` bytes (raw UTF-8 JSON) into a membershipId for the
  /// given session. Returns `null` and swallows any decode/shape errors.
  ///
  /// Expected shape: `{ "memberships": [{ "gameSessionId": "...", "membershipId": "..." }] }`
  String? _membershipIdFromConnInfo(
    List<int>? connInfo,
    String? gameSessionId,
  ) {
    if (connInfo == null || connInfo.isEmpty || gameSessionId == null) {
      return null;
    }
    try {
      final raw = utf8.decode(connInfo, allowMalformed: false);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final memberships = decoded['memberships'];
      if (memberships is! List) return null;
      for (final entry in memberships) {
        if (entry is! Map<String, dynamic>) continue;
        if (entry['gameSessionId'] == gameSessionId) {
          final membershipId = entry['membershipId'];
          if (membershipId is String) return membershipId;
        }
      }
      return null;
    } on Object {
      // Malformed bytes, invalid JSON, or unexpected shape — silently skip.
      return null;
    }
  }

  @override
  Future<void> stop() async {
    await _joinSub?.cancel();
    await _leaveSub?.cancel();
    _joinSub = null;
    _leaveSub = null;

    if (_sub != null) {
      try {
        await _sub!.unsubscribe();
      } on Object {
        // Best-effort.
      }
      _sub = null;
    }

    if (_client != null) {
      try {
        await _client!.disconnect();
      } on Object {
        // Ignore.
      }
      _client = null;
    }

    _clientToMembership.clear();
    _currentGameSessionId = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
