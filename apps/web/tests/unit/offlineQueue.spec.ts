/**
 * offlineQueue.spec.ts
 *
 * IDB-backed FIFO for mutations that couldn't reach the server.
 * `fake-indexeddb/auto` polyfills the browser IDB APIs in happy-dom
 * (no real disk involved), so each test starts from a clean store via
 * `clearQueue()`.
 */

import 'fake-indexeddb/auto';

import { afterEach, beforeEach, describe, expect, it } from 'vitest';

import {
  clearQueue,
  count,
  enqueue,
  listQueue,
  removeEntry,
  serializeHeaders,
} from '../../app/utils/offlineQueue';

const SAMPLE = {
  method: 'PATCH' as const,
  url: 'http://localhost:3010/api/v1/ships/abc',
  body: '{"name":"Sirius"}',
  headers: { 'Content-Type': 'application/json' },
};

describe('offlineQueue', () => {
  beforeEach(async () => {
    await clearQueue();
  });

  afterEach(async () => {
    await clearQueue();
  });

  it('starts empty', async () => {
    expect(await listQueue()).toEqual([]);
    expect(await count()).toBe(0);
  });

  it('enqueue assigns an id + createdAt and persists', async () => {
    const entry = await enqueue(SAMPLE);
    expect(entry.id).toBeTypeOf('string');
    expect(entry.id.length).toBeGreaterThan(0);
    expect(entry.createdAt).toBeTypeOf('number');

    const stored = await listQueue();
    expect(stored).toHaveLength(1);
    expect(stored[0]?.url).toBe(SAMPLE.url);
    expect(stored[0]?.body).toBe(SAMPLE.body);
  });

  it('preserves FIFO order across multiple enqueues', async () => {
    const a = await enqueue({ ...SAMPLE, body: '{"step":1}' });
    const b = await enqueue({ ...SAMPLE, body: '{"step":2}' });
    const c = await enqueue({ ...SAMPLE, body: '{"step":3}' });

    const stored = await listQueue();
    expect(stored.map((e) => e.id)).toEqual([a.id, b.id, c.id]);
    expect(stored.map((e) => e.body)).toEqual([a.body, b.body, c.body]);
  });

  it('removeEntry drops only the named entry', async () => {
    const a = await enqueue({ ...SAMPLE, body: '{"step":1}' });
    const b = await enqueue({ ...SAMPLE, body: '{"step":2}' });

    await removeEntry(a.id);
    const stored = await listQueue();
    expect(stored).toHaveLength(1);
    expect(stored[0]?.id).toBe(b.id);
  });

  it('clearQueue empties everything', async () => {
    await enqueue(SAMPLE);
    await enqueue(SAMPLE);
    expect(await count()).toBe(2);
    await clearQueue();
    expect(await count()).toBe(0);
  });

  it('serializeHeaders drops Authorization (case-insensitive) and keeps the rest', () => {
    const headers = new Headers({
      'Content-Type': 'application/json',
      Authorization: 'Bearer leak',
      'X-Request-Id': 'abc-123',
    });
    const out = serializeHeaders(headers);
    // Headers polyfill preserves whatever casing the runtime gives us
    // (Node's `Headers` lowercases; happy-dom's preserves original).
    // We only care about (a) Authorization is gone, (b) the other keys
    // round-trip in some casing.
    const normalised = Object.fromEntries(
      Object.entries(out).map(([k, v]) => [k.toLowerCase(), v]),
    );
    expect(normalised).toEqual({
      'content-type': 'application/json',
      'x-request-id': 'abc-123',
    });
    expect(Object.keys(out).map((k) => k.toLowerCase())).not.toContain('authorization');
  });

  it('serializeHeaders handles undefined input', () => {
    expect(serializeHeaders(undefined)).toEqual({});
  });
});
