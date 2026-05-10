import 'dart:async';
import 'dart:convert';

import 'package:app_api_client/app_api_client.dart' as api_client show RealtimeApi;
import 'package:centrifuge/centrifuge.dart' as cf;

import 'package:coriolis_companion/shared/config/app_config.dart';
import 'package:coriolis_companion/shared/realtime/combat_updated_payload.dart';

export 'package:coriolis_companion/shared/realtime/combat_updated_payload.dart';

/// Payload of a `dp.changed` Centrifugo publication.
class DpChangedPayload {
  const DpChangedPayload({
    required this.gameSessionId,
    required this.dpCount,
    required this.delta,
    required this.source,
    this.at,
  });

  final String gameSessionId;
  final int dpCount;
  final int delta;
  final String source;
  final DateTime? at;
}

/// Payload of a `roll.pushed` Centrifugo publication.
class RollPushedPayload {
  const RollPushedPayload({
    required this.rollId,
    required this.characterId,
    required this.hits,
    this.gameSessionId,
    this.at,
  });

  final String rollId;
  final String characterId;
  final String? gameSessionId;
  final int hits;
  final DateTime? at;
}

/// Subscription handle for a single `session.{id}` channel (Phase 4
/// Block 4 mobile).
///
/// Mints a JWT via `RealtimeApi.issueRealtimeToken`, opens the
/// websocket, subscribes, and surfaces the three domain payloads
/// (`dp.changed`, `roll.pushed`, `combat.updated`) as broadcast streams.
/// The page wires `dpChanged` → `SessionDetailCubit.applyDpChanged`,
/// surfaces `rollPushed` as a SnackBar, and feeds `combatUpdated`
/// snapshots into `ActiveCombatCubit.replaceSnapshot`.
///
/// Token rotation is handled automatically by the Centrifuge client
/// via `ClientConfig.getToken` — the callback fires before the
/// current token nears expiry and re-mints from the same endpoint.
class SessionRealtime {
  SessionRealtime({
    required api_client.RealtimeApi realtimeApi,
    required AppConfig config,
  })  : _realtimeApi = realtimeApi,
        _config = config;

  final api_client.RealtimeApi _realtimeApi;
  final AppConfig _config;

  cf.Client? _client;
  cf.Subscription? _sub;
  StreamSubscription<cf.PublicationEvent>? _pubSub;

  final _dpChangedController = StreamController<DpChangedPayload>.broadcast();
  final _rollPushedController = StreamController<RollPushedPayload>.broadcast();
  final _combatUpdatedController =
      StreamController<CombatUpdatedPayload>.broadcast();
  final _connectedController = StreamController<bool>.broadcast();

  Stream<DpChangedPayload> get dpChanged => _dpChangedController.stream;
  Stream<RollPushedPayload> get rollPushed => _rollPushedController.stream;

  /// Emits a domain snapshot on every `combat.updated` publication.
  /// Malformed payloads are silently dropped — the stream never errors.
  Stream<CombatUpdatedPayload> get combatUpdated =>
      _combatUpdatedController.stream;

  Stream<bool> get connected => _connectedController.stream;

  Future<String> _fetchToken() async {
    final res = await _realtimeApi.issueRealtimeToken();
    final token = res.data?.token;
    if (token == null || token.isEmpty) {
      throw StateError('Realtime token endpoint returned empty token');
    }
    return token;
  }

  /// Open the websocket and subscribe to `session.{id}`. Idempotent —
  /// repeated calls while connected are no-ops.
  Future<void> start(String gameSessionId) async {
    if (_client != null) return;
    final token = await _fetchToken();
    final config = cf.ClientConfig(
      token: token,
      getToken: (_) => _fetchToken(),
    );
    final client = cf.createClient(_config.realtimeWsUrl, config);
    _client = client;

    client.connected.listen((_) => _connectedController.add(true));
    client.disconnected.listen((_) => _connectedController.add(false));

    final sub = client.newSubscription('session.$gameSessionId');
    _sub = sub;
    _pubSub = sub.publication.listen(_onPublication);
    sub.subscribe();

    await client.connect();
  }

  void _onPublication(cf.PublicationEvent event) {
    final raw = utf8.decode(event.data, allowMalformed: true);
    if (raw.isEmpty) return;
    Map<String, dynamic> data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
    } on Object {
      // Centrifugo can publish bytes that aren't JSON (e.g. presence
      // pings); ignore them silently rather than crashing the page.
      return;
    }

    // `combat.updated` carries an explicit `type` discriminator field.
    // Check it first so the structural fallbacks below never misfire on
    // a combat payload that happens to contain numeric fields.
    if (data['type'] == 'combat.updated') {
      final payload = CombatUpdatedPayload.tryParse(data);
      if (payload != null) _combatUpdatedController.add(payload);
      return;
    }

    // Discriminate by structural shape — `dpCount` is dp.changed-only;
    // `rollId` is roll.pushed-only. The two events share gameSessionId.
    if (data.containsKey('dpCount') && data['dpCount'] is int) {
      _dpChangedController.add(DpChangedPayload(
        gameSessionId: data['gameSessionId'] as String,
        dpCount: data['dpCount'] as int,
        delta: data['delta'] as int? ?? 0,
        source: data['source'] as String? ?? 'system',
        at: _parseAt(data['at']),
      ));
      return;
    }

    if (data.containsKey('rollId') && data['rollId'] is String) {
      _rollPushedController.add(RollPushedPayload(
        rollId: data['rollId'] as String,
        characterId: data['characterId'] as String,
        gameSessionId: data['gameSessionId'] as String?,
        hits: data['hits'] as int? ?? 0,
        at: _parseAt(data['at']),
      ));
    }
  }

  DateTime? _parseAt(Object? value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  /// Close the subscription and the websocket. Safe to call multiple
  /// times. Streams remain open so late listeners aren't surprised.
  Future<void> stop() async {
    await _pubSub?.cancel();
    _pubSub = null;
    if (_sub != null) {
      try {
        await _sub!.unsubscribe();
      } on Object {
        // Best-effort; swallow any errors during teardown.
      }
      _sub = null;
    }
    if (_client != null) {
      try {
        await _client!.disconnect();
      } on Object {
        // ignore
      }
      _client = null;
    }
    _connectedController.add(false);
  }

  /// Tear down all streams; call when the host page is permanently
  /// destroyed (not just navigated away from). For now the
  /// SessionRealtime is registered as a factory in DI so each
  /// detail-page instance gets its own — `dispose` runs on
  /// `Cubit.close()`.
  Future<void> dispose() async {
    await stop();
    await _dpChangedController.close();
    await _rollPushedController.close();
    await _combatUpdatedController.close();
    await _connectedController.close();
  }
}
