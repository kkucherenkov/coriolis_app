import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:coriolis_companion/shared/queue/mutation_queue.dart';

/// Reactive state of the mutation queue exposed to the UI.
///
/// - `idle` — nothing pending OR offline-with-empty-queue. Banner hidden.
/// - `syncing` — [MutationQueueDrainer.drainNow] is walking the queue.
/// - `synced` — last drain finished with zero failures. Pulses for ~2 s
///   then drops back to `idle`.
/// - `error` — at least one replay failed and entries remain in the queue.
enum MutationQueueStatus { idle, syncing, synced, error }

/// Engine that replays queued mutations on reconnect.
///
/// Singleton — a single instance owns the connectivity subscription and
/// the 2 s `synced` fade timer. Wire in `injector.dart` as a lazy singleton.
///
/// Mirrors `apps/web/app/composables/useOfflineQueue.ts` from T-2026-05-11-008.
class MutationQueueDrainer {
  MutationQueueDrainer({
    required LocalMutationQueue queue,
    required Dio dio,
    required Connectivity connectivity,
    Duration syncedFadeDuration = const Duration(seconds: 2),
  })  : _queue = queue,
        _dio = dio,
        _connectivity = connectivity,
        _syncedFadeDuration = syncedFadeDuration;

  final LocalMutationQueue _queue;
  final Dio _dio;
  final Connectivity _connectivity;
  final Duration _syncedFadeDuration;

  /// Number of mutations currently held in the persistent queue.
  final ValueNotifier<int> pending = ValueNotifier<int>(0);

  /// Current drain state; drive the offline banner from this notifier.
  final ValueNotifier<MutationQueueStatus> status =
      ValueNotifier<MutationQueueStatus>(MutationQueueStatus.idle);

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _syncedFadeTimer;
  bool _draining = false;
  bool _started = false;

  /// Begin listening to connectivity changes and hydrate [pending] from the
  /// queue. Idempotent — subsequent calls are a no-op.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _refreshPending();
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChange);
  }

  /// Cancel the connectivity subscription and release notifiers.
  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    _syncedFadeTimer?.cancel();
    _syncedFadeTimer = null;
    pending.dispose();
    status.dispose();
    _started = false;
  }

  /// Re-read [pending] from storage. Call after an external [enqueue] to keep
  /// the banner count accurate.
  Future<void> refresh() => _refreshPending();

  /// Trigger a drain manually (e.g. from a retry button). Safe to call from
  /// any state; bails out silently if a drain is already in progress.
  Future<void> drainNow() => _drain();

  // ---------------------------------------------------------------------------

  Future<void> _refreshPending() async {
    pending.value = await _queue.count();
  }

  bool _isOffline(List<ConnectivityResult> results) {
    if (results.isEmpty) return true;
    return results.every((r) => r == ConnectivityResult.none);
  }

  void _onConnectivityChange(List<ConnectivityResult> results) {
    if (!_isOffline(results)) {
      // Transition to online → kick off a drain; errors are absorbed inside.
      unawaited(_drain());
    }
  }

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    try {
      final entries = await _queue.list();
      pending.value = entries.length;
      if (entries.isEmpty) {
        status.value = MutationQueueStatus.idle;
        return;
      }
      status.value = MutationQueueStatus.syncing;
      var anyFailed = false;
      for (final entry in entries) {
        final ok = await _replay(entry);
        if (ok) {
          await _queue.remove(entry.id);
        } else {
          anyFailed = true;
          // Keep walking — later entries may still succeed independently.
        }
      }
      await _refreshPending();
      if (anyFailed) {
        status.value = MutationQueueStatus.error;
      } else {
        status.value = MutationQueueStatus.synced;
        _syncedFadeTimer?.cancel();
        _syncedFadeTimer = Timer(_syncedFadeDuration, () {
          if (status.value == MutationQueueStatus.synced) {
            status.value = MutationQueueStatus.idle;
          }
          _syncedFadeTimer = null;
        });
      }
    } finally {
      _draining = false;
    }
  }

  Future<bool> _replay(PendingMutation entry) async {
    try {
      final response = await _dio.request<dynamic>(
        entry.path,
        data: _decodeBody(entry.body, entry.headers),
        options: Options(
          method: entry.method,
          headers: {...entry.headers},
          // Bypass `MutationQueueInterceptor` so a failure here doesn't
          // re-enqueue the same row forever. The bearer-token interceptor
          // ahead in the chain re-injects a fresh Authorization header.
          extra: const {'skipMutationQueue': true},
          // Accept any status code so we can decide success ourselves.
          validateStatus: (_) => true,
        ),
      );
      final code = response.statusCode ?? 0;
      // 2xx + 3xx = success; 4xx / 5xx keeps the entry queued for the user.
      return code >= 200 && code < 400;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Decode [body] to a native object when the content-type is JSON so that
  /// Dio serialises it correctly; otherwise return the raw string.
  dynamic _decodeBody(String? body, Map<String, String> headers) {
    if (body == null || body.isEmpty) return null;
    final contentType = headers.entries
        .firstWhere(
          (e) => e.key.toLowerCase() == 'content-type',
          orElse: () => const MapEntry('', ''),
        )
        .value
        .toLowerCase();
    if (contentType.contains('application/json')) {
      try {
        return jsonDecode(body);
      } catch (_) {
        return body;
      }
    }
    return body;
  }
}
