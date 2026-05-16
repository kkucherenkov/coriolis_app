import 'dart:async';
import 'dart:convert';

import 'package:app_api_client/app_api_client.dart'
    show ChatMessage, ChatMessageKind, RealtimeApi;
import 'package:centrifuge/centrifuge.dart' as cf;

import 'package:coriolis_companion/shared/config/app_config.dart';
import 'package:coriolis_companion/features/sessions/presentation/blocs/chat/chat_realtime_service.dart';

/// Centrifugo-backed [ChatRealtimeService].
///
/// Subscribes to two channel families:
/// - `session.<gameSessionId>.chat` — broadcast and whisper events visible to
///   this membership (server filters by JWT subject).
/// - `session.<gameSessionId>.member.<myMembershipId>` — private whispers and
///   system messages addressed to this member specifically.
///
/// Publication format mirrors the AsyncAPI contract from Stream C:
/// ```json
/// { "type": "chat.posted",  "message": { ...ChatMessage } }
/// { "type": "chat.edited",  "message": { ...ChatMessage } }
/// { "type": "chat.deleted", "messageId": "...", "deletedAt": "ISO8601" }
/// ```
class ChatRealtimeServiceImpl implements ChatRealtimeService {
  ChatRealtimeServiceImpl({
    required RealtimeApi realtimeApi,
    required AppConfig config,
  })  : _realtimeApi = realtimeApi,
        _config = config;

  final RealtimeApi _realtimeApi;
  final AppConfig _config;

  cf.Client? _client;
  cf.Subscription? _broadcastSub;
  cf.Subscription? _memberSub;
  StreamSubscription<cf.PublicationEvent>? _broadcastPubSub;
  StreamSubscription<cf.PublicationEvent>? _memberPubSub;

  final _controller = StreamController<ChatRealtimeEvent>.broadcast();

  @override
  Stream<ChatRealtimeEvent> get events => _controller.stream;

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

    final token = await _fetchToken();
    final config = cf.ClientConfig(
      token: token,
      getToken: (_) => _fetchToken(),
    );
    final client = cf.createClient(_config.realtimeWsUrl, config);
    _client = client;

    // Broadcast channel.
    final bSub = client.newSubscription('session.$gameSessionId.chat');
    _broadcastSub = bSub;
    _broadcastPubSub = bSub.publication.listen(_onPublication);
    bSub.subscribe();

    // Private member channel.
    final mSub = client
        .newSubscription('session.$gameSessionId.member.$myMembershipId');
    _memberSub = mSub;
    _memberPubSub = mSub.publication.listen(_onPublication);
    mSub.subscribe();

    await client.connect();
  }

  void _onPublication(cf.PublicationEvent event) {
    final raw = utf8.decode(event.data, allowMalformed: true);
    if (raw.isEmpty) return;

    Map<String, dynamic> data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
    } on Object {
      return;
    }

    final type = data['type'] as String?;
    switch (type) {
      case 'chat.posted':
        final msg = _parseMessage(data['message']);
        if (msg != null) _controller.add(ChatRealtimePosted(msg));
      case 'chat.edited':
        final msg = _parseMessage(data['message']);
        if (msg != null) _controller.add(ChatRealtimeEdited(msg));
      case 'chat.deleted':
        final id = data['messageId'] as String?;
        final deletedAtRaw = data['deletedAt'] as String?;
        if (id != null && deletedAtRaw != null) {
          try {
            _controller.add(ChatRealtimeDeleted(
              messageId: id,
              deletedAt: DateTime.parse(deletedAtRaw),
            ));
          } on FormatException {
            // Malformed date — skip.
          }
        }
      default:
        // Unknown event type — silently ignore.
        break;
    }
  }

  ChatMessage? _parseMessage(Object? raw) {
    if (raw == null) return null;
    try {
      final m = raw as Map<String, dynamic>;
      return ChatMessage((b) => b
        ..id = m['id'] as String
        ..gameSessionId = m['gameSessionId'] as String
        ..authorMembershipId = m['authorMembershipId'] as String?
        ..authorDisplayName = m['authorDisplayName'] as String?
        ..targetMembershipId = m['targetMembershipId'] as String?
        ..kind = m['kind'] == 'system'
            ? ChatMessageKind.system
            : ChatMessageKind.text
        ..body = m['body'] as String?
        ..systemKey = m['systemKey'] as String?
        ..createdAt = DateTime.parse(m['createdAt'] as String)
        ..editedAt = m['editedAt'] != null
            ? DateTime.parse(m['editedAt'] as String)
            : null
        ..deletedAt = m['deletedAt'] != null
            ? DateTime.parse(m['deletedAt'] as String)
            : null);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> stop() async {
    await _broadcastPubSub?.cancel();
    await _memberPubSub?.cancel();
    _broadcastPubSub = null;
    _memberPubSub = null;

    for (final sub in [_broadcastSub, _memberSub]) {
      if (sub != null) {
        try {
          await sub.unsubscribe();
        } on Object {
          // Best-effort.
        }
      }
    }
    _broadcastSub = null;
    _memberSub = null;

    if (_client != null) {
      try {
        await _client!.disconnect();
      } on Object {
        // Ignore.
      }
      _client = null;
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
