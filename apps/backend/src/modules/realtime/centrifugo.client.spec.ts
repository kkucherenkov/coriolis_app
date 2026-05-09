/**
 * Unit tests for CentrifugoClient.
 *
 * Mocks global fetch so no real HTTP calls are made.
 * Verifies the Authorization header, request body shape, and that
 * HTTP errors / network failures are swallowed without re-throwing.
 */
import { describe, expect, it, vi, afterEach } from 'vitest';

import { CentrifugoClient } from './centrifugo.client';

import type { AppConfig, CentrifugoConfig } from '../../common/config/app-config';

function makeConfig(overrides: Partial<CentrifugoConfig> = {}): AppConfig {
  return {
    centrifugo: {
      apiUrl: 'http://centrifugo:8000',
      apiKey: 'test-api-key',
      tokenHmacSecret: 'test-secret',
      tokenTtlSeconds: 300,
      ...overrides,
    },
  } as AppConfig;
}

function makeFetchSpy(status = 200, ok = true) {
  const spy = vi.fn().mockResolvedValue({
    ok,
    status,
  } as Response);
  vi.stubGlobal('fetch', spy);
  return spy;
}

describe('CentrifugoClient', () => {
  afterEach(() => {
    vi.unstubAllGlobals();
    vi.useRealTimers();
  });

  it('POSTs to apiUrl/api with correct Authorization header', async () => {
    const fetchSpy = makeFetchSpy();
    const client = new CentrifugoClient(makeConfig());

    await client.publish('session.gs-1', { type: 'dp.changed' });

    expect(fetchSpy).toHaveBeenCalledOnce();
    const [url, init] = fetchSpy.mock.calls[0] as [string, RequestInit];
    expect(url).toBe('http://centrifugo:8000/api');
    expect((init.headers as Record<string, string>)['Authorization']).toBe('apikey test-api-key');
  });

  it('sends correct JSON-RPC publish body', async () => {
    const fetchSpy = makeFetchSpy();
    const client = new CentrifugoClient(makeConfig());
    const payload = { gameSessionId: 'gs-1', dpCount: 5, delta: 1, source: 'gm-manual' };

    await client.publish('session.gs-1', payload);

    const [, init] = fetchSpy.mock.calls[0] as [string, RequestInit];
    const body = JSON.parse(init.body as string) as unknown;
    expect(body).toEqual({
      method: 'publish',
      params: { channel: 'session.gs-1', data: payload },
    });
  });

  it('does not throw when Centrifugo returns non-OK status', async () => {
    makeFetchSpy(500, false);
    const client = new CentrifugoClient(makeConfig());

    await expect(client.publish('session.gs-1', {})).resolves.toBeUndefined();
  });

  it('does not throw when fetch rejects (network error)', async () => {
    vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new Error('ECONNREFUSED')));
    const client = new CentrifugoClient(makeConfig());

    await expect(client.publish('session.gs-1', {})).resolves.toBeUndefined();
  });

  it('does not throw on AbortError (timeout)', async () => {
    vi.useFakeTimers();
    const abortError = new DOMException('The user aborted a request.', 'AbortError');
    vi.stubGlobal(
      'fetch',
      vi.fn().mockImplementation(
        () =>
          new Promise((_, reject) =>
            // Reject after 300ms (longer than the 250ms internal timeout)
            setTimeout(() => reject(abortError), 300),
          ),
      ),
    );

    const client = new CentrifugoClient(makeConfig());
    const promise = client.publish('session.gs-1', {});
    // Advance past the 250ms abort timeout
    vi.advanceTimersByTime(300);
    await expect(promise).resolves.toBeUndefined();
  });
});
