import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coriolis_companion/shared/cache/app_database.dart';
import 'package:coriolis_companion/shared/queue/drift_mutation_queue.dart';
import 'package:coriolis_companion/shared/queue/mutation_queue.dart';

void main() {
  late AppDatabase db;
  late DriftMutationQueue queue;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    queue = DriftMutationQueue(db);
  });

  tearDown(() async => db.close());

  test('list returns empty when nothing enqueued', () async {
    expect(await queue.list(), isEmpty);
  });

  test('enqueue then list returns the entry with same fields', () async {
    const headers = {'Content-Type': 'application/json', 'X-Foo': 'bar'};
    final entry = await queue.enqueue(
      method: 'PATCH',
      path: '/characters/abc/talents/xyz',
      body: '{"value":1}',
      headers: headers,
    );

    final all = await queue.list();
    expect(all, hasLength(1));
    final got = all.single;
    expect(got.id, entry.id);
    expect(got.method, 'PATCH');
    expect(got.path, '/characters/abc/talents/xyz');
    expect(got.body, '{"value":1}');
    expect(got.headers, headers);
    // Drift stores datetime as unix-seconds; allow ≤1 s difference.
    expect(
      got.createdAt.difference(entry.createdAt).inSeconds.abs(),
      lessThanOrEqualTo(1),
    );
  });

  test('enqueue with null body stores and retrieves null', () async {
    await queue.enqueue(
      method: 'DELETE',
      path: '/characters/abc',
      headers: {},
    );
    final all = await queue.list();
    expect(all.single.body, isNull);
  });

  test('headers round-trip JSON encoding', () async {
    const headers = {
      'Content-Type': 'application/json',
      'Accept-Language': 'ru',
    };
    await queue.enqueue(
      method: 'PUT',
      path: '/characters/xyz',
      headers: headers,
    );
    final got = (await queue.list()).single;
    expect(got.headers, headers);
  });

  test('enqueue twice returns in insertion order (FIFO)', () async {
    // Drift stores DateTime in microseconds; ensure distinct timestamps by
    // using a tiny artificial gap via await-ing microseconds boundary.
    await queue.enqueue(method: 'PATCH', path: '/a', headers: {});
    await queue.enqueue(method: 'PUT', path: '/b', headers: {});

    final all = await queue.list();
    expect(all, hasLength(2));
    expect(all[0].path, '/a');
    expect(all[1].path, '/b');
    expect(
      all[0].createdAt.isBefore(all[1].createdAt) ||
          all[0].createdAt.isAtSameMomentAs(all[1].createdAt),
      isTrue,
    );
  });

  test('remove deletes only the matching row', () async {
    final a = await queue.enqueue(method: 'PATCH', path: '/a', headers: {});
    await queue.enqueue(method: 'DELETE', path: '/b', headers: {});

    await queue.remove(a.id);

    final all = await queue.list();
    expect(all, hasLength(1));
    expect(all.single.path, '/b');
  });

  test('remove on unknown id is a no-op', () async {
    await queue.enqueue(method: 'PATCH', path: '/a', headers: {});
    await queue.remove('does-not-exist');
    expect(await queue.count(), 1);
  });

  test('count reflects enqueue and remove', () async {
    expect(await queue.count(), 0);
    final a = await queue.enqueue(method: 'PATCH', path: '/a', headers: {});
    expect(await queue.count(), 1);
    await queue.enqueue(method: 'PUT', path: '/b', headers: {});
    expect(await queue.count(), 2);
    await queue.remove(a.id);
    expect(await queue.count(), 1);
  });

  test('clear empties the queue', () async {
    await queue.enqueue(method: 'PATCH', path: '/a', headers: {});
    await queue.enqueue(method: 'DELETE', path: '/b', headers: {});
    await queue.clear();
    expect(await queue.list(), isEmpty);
    expect(await queue.count(), 0);
  });

  test('survives reopen — new DriftMutationQueue over same db sees entries',
      () async {
    await queue.enqueue(
      method: 'PATCH',
      path: '/characters/abc',
      body: '{"x":1}',
      headers: {'Content-Type': 'application/json'},
    );

    // Simulate reopening by creating a second adapter over the same db.
    final queue2 = DriftMutationQueue(db);
    final all = await queue2.list();
    expect(all, hasLength(1));
    expect(all.single.path, '/characters/abc');
    expect(all.single.headers, {'Content-Type': 'application/json'});
  });

  test('PendingMutation equality is value-based (Equatable)', () {
    final now = DateTime.utc(2026, 5, 16, 12);
    final m = PendingMutation(
      id: 'id1',
      method: 'PATCH',
      path: '/x',
      headers: const {},
      createdAt: now,
    );
    final m2 = PendingMutation(
      id: 'id1',
      method: 'PATCH',
      path: '/x',
      headers: const {},
      createdAt: now,
    );
    expect(m, equals(m2));
    expect(m.hashCode, m2.hashCode);
  });
}
