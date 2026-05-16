import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:coriolis_companion/shared/cache/app_database.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue.dart';

/// Drift-backed [LocalMutationQueue].
///
/// Each [PendingMutation] maps 1-to-1 to a [PendingMutationsData] row.
/// [headers] are stored as a JSON-encoded `Map<String, String>` in
/// [PendingMutationsData.headersJson] and round-tripped via `dart:convert`.
class DriftMutationQueue implements LocalMutationQueue {
  DriftMutationQueue(this._db);

  final AppDatabase _db;

  @override
  Future<List<PendingMutation>> list() async {
    final rows = await (_db.select(_db.pendingMutations)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<PendingMutation> enqueue({
    required String method,
    required String path,
    String? body,
    required Map<String, String> headers,
  }) async {
    final id = generateMutationId();
    final now = DateTime.now().toUtc();
    final headersJson = jsonEncode(headers);

    await _db.into(_db.pendingMutations).insert(
          PendingMutationsCompanion.insert(
            id: id,
            method: method,
            path: path,
            body: body == null ? const Value.absent() : Value(body),
            headersJson: headersJson,
            createdAt: now,
          ),
        );

    return PendingMutation(
      id: id,
      method: method,
      path: path,
      body: body,
      headers: headers,
      createdAt: now,
    );
  }

  @override
  Future<void> remove(String id) async {
    await (_db.delete(_db.pendingMutations)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.pendingMutations).go();
  }

  @override
  Future<int> count() async {
    final rows = await _db.select(_db.pendingMutations).get();
    return rows.length;
  }

  PendingMutation _fromRow(PendingMutationsData row) {
    final headers = (jsonDecode(row.headersJson) as Map<String, dynamic>)
        .cast<String, String>();
    return PendingMutation(
      id: row.id,
      method: row.method,
      path: row.path,
      body: row.body,
      headers: headers,
      createdAt: row.createdAt,
    );
  }
}
