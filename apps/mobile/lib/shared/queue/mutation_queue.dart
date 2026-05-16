import 'dart:math';

import 'package:equatable/equatable.dart';

/// Value-object representing a single queued mutation.
///
/// Fields mirror the web `QueueEntry` shape from
/// `apps/web/app/utils/offlineQueue.ts` so that both clients produce
/// semantically identical entries (id format, header-stripping semantics).
///
/// `headers` is decoded in-memory; the Drift layer stores the JSON form.
/// `body` is null for DELETE requests and for any request without a body.
class PendingMutation extends Equatable {
  const PendingMutation({
    required this.id,
    required this.method,
    required this.path,
    this.body,
    required this.headers,
    required this.createdAt,
  });

  /// Unique id: `<base36-timestamp>-<6-char-base36-random>`.
  /// Same algorithm as the web `newId()` in `offlineQueue.ts`.
  final String id;

  /// HTTP method — one of `'PATCH'`, `'PUT'`, `'DELETE'`.
  final String method;

  /// Request path, e.g. `/characters/abc/talents/xyz`.
  /// Does not include the scheme or host — relative to the API base URL.
  final String path;

  /// Serialised request body; null for DELETE or body-less requests.
  final String? body;

  /// Request headers with Authorization stripped.
  /// Authorization is re-injected at replay time so a stale token is never
  /// replayed verbatim.
  final Map<String, String> headers;

  /// Local UTC timestamp of when the request was queued.
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, method, path, body, headers, createdAt];
}

/// Generates a unique id in the same format as the web `newId()`:
/// `<base36-timestamp>-<6-char-base36-random>`.
String generateMutationId() {
  final timestamp =
      DateTime.now().toUtc().millisecondsSinceEpoch.toRadixString(36);
  const chars = '0123456789abcdefghijklmnopqrstuvwxyz';
  final rng = Random.secure();
  final suffix = List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  return '$timestamp-$suffix';
}

/// FIFO queue of mutations that couldn't reach the server.
///
/// Block 2 (`MutationQueueInterceptor`) calls [enqueue] for every
/// PATCH / PUT / DELETE that fails while offline.
/// Block 3 (`MutationQueueDrainer`) calls [list] + [remove] on reconnect
/// to replay pending mutations in causal order.
abstract class LocalMutationQueue {
  /// Returns all pending mutations ordered oldest-first (FIFO).
  Future<List<PendingMutation>> list();

  /// Persists a new entry and returns the stored [PendingMutation].
  ///
  /// [headers] should already have Authorization stripped by the caller
  /// (the interceptor in Block 2).
  Future<PendingMutation> enqueue({
    required String method,
    required String path,
    String? body,
    required Map<String, String> headers,
  });

  /// Removes the entry with the given [id]. No-op if not found.
  Future<void> remove(String id);

  /// Clears all pending mutations.
  Future<void> clear();

  /// Returns the number of pending mutations.
  Future<int> count();
}
