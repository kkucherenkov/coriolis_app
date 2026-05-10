/**
 * T-7.4.1.f — Integration test: publish dp.changed → subscriber receives it
 *
 * Requires the Docker Compose stack (centrifugo) to be running.
 * The test suite is skipped automatically when Centrifugo is not reachable.
 *
 * To run manually with the Docker stack:
 *   docker compose -f docker/compose.yml up -d
 *   pnpm --filter @app/backend test:e2e
 *
 * Environment (defaults match docker/compose.yml):
 *   INTEGRATION_CENTRIFUGO_URL          http://localhost:8000
 *   INTEGRATION_CENTRIFUGO_WS_URL       ws://localhost:8000
 *   INTEGRATION_CENTRIFUGO_API_KEY      dev-api-key
 *   INTEGRATION_CENTRIFUGO_TOKEN_SECRET dev-hmac-secret
 *
 * What this test does:
 *   1. Signs a short-lived Centrifugo JWT for a fake user with `session.test-gs-1`
 *      in its `channels` claim.
 *   2. Opens a WebSocket connection to Centrifugo (native WS, Node 22+) and
 *      subscribes to the channel.
 *   3. Publishes a dp.changed payload via the Centrifugo HTTP API.
 *   4. Asserts the subscriber receives the message within 500ms.
 *
 * The backend-to-Centrifugo publish path (CentrifugoClient) is covered by
 * unit tests. This test proves the channel subscription + delivery contract.
 */

import * as crypto from 'node:crypto';

import { beforeAll, describe, expect, it } from 'vitest';

const CENTRIFUGO_API_URL = process.env['INTEGRATION_CENTRIFUGO_URL'] ?? 'http://localhost:8000';
const CENTRIFUGO_WS_URL = process.env['INTEGRATION_CENTRIFUGO_WS_URL'] ?? 'ws://localhost:8000';
const CENTRIFUGO_API_KEY = process.env['INTEGRATION_CENTRIFUGO_API_KEY'] ?? 'dev-api-key';
const CENTRIFUGO_TOKEN_SECRET =
  process.env['INTEGRATION_CENTRIFUGO_TOKEN_SECRET'] ?? 'dev-hmac-secret';

let centrifugoUp = false;

beforeAll(async () => {
  try {
    const ctrl = new AbortController();
    const id = setTimeout(() => {
      ctrl.abort();
    }, 800);
    const res = await fetch(`${CENTRIFUGO_API_URL}/health`, { signal: ctrl.signal });
    clearTimeout(id);
    centrifugoUp = res.ok;
  } catch {
    centrifugoUp = false;
  }
});

/**
 * Produces a minimal Centrifugo connection JWT signed with HS256.
 * Uses only Node.js built-ins — no external jwt library needed.
 */
function makeCentrifugoJwt(userId: string, channels: string[]): string {
  const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url');
  const exp = Math.floor(Date.now() / 1000) + 300;
  const payload = Buffer.from(JSON.stringify({ sub: userId, exp, channels })).toString('base64url');
  const sig = crypto
    .createHmac('sha256', CENTRIFUGO_TOKEN_SECRET)
    .update(`${header}.${payload}`)
    .digest('base64url');
  return `${header}.${payload}.${sig}`;
}

/**
 * Publishes a message to a Centrifugo channel via the HTTP API.
 */
async function centrifugoPublish(channel: string, data: Record<string, unknown>): Promise<void> {
  const res = await fetch(`${CENTRIFUGO_API_URL}/api`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `apikey ${CENTRIFUGO_API_KEY}`,
    },
    body: JSON.stringify({ method: 'publish', params: { channel, data } }),
  });
  if (!res.ok) {
    throw new Error(`Centrifugo publish failed: ${res.status.toString()}`);
  }
}

describe('T-7.4.1.f — realtime dp.changed channel delivery', () => {
  it('subscriber receives dp.changed within 500ms of HTTP publish', async () => {
    if (!centrifugoUp) {
      console.log('[SKIP] Centrifugo not reachable — start the Docker stack to run this test.');
      return;
    }

    const sessionId = 'test-gs-realtime-1';
    const channel = `session.${sessionId}`;
    const userId = 'test-user-gm';
    const token = makeCentrifugoJwt(userId, [channel]);

    const received = await new Promise<Record<string, unknown>>((resolve, reject) => {
      const ws = new WebSocket(`${CENTRIFUGO_WS_URL}/connection/websocket?cf_token=${token}`);
      const timeout = setTimeout(() => {
        ws.close();
        reject(new Error('Timed out waiting for dp.changed within 500ms'));
      }, 500);

      ws.addEventListener('open', () => {
        // Centrifugo protocol v1: connect message
        ws.send(JSON.stringify({ id: 1, connect: {} }));
      });

      let connected = false;
      ws.addEventListener('message', (event: MessageEvent) => {
        const msg = JSON.parse(event.data as string) as Record<string, unknown>;

        if (!connected && 'connect' in msg) {
          connected = true;
          // Subscribe to the session channel
          ws.send(JSON.stringify({ id: 2, subscribe: { channel } }));
          return;
        }

        if ('subscribe' in msg) {
          // Subscription confirmed — publish via HTTP to trigger delivery
          centrifugoPublish(channel, {
            gameSessionId: sessionId,
            dpCount: 5,
            delta: 1,
            source: 'gm-manual',
            at: new Date().toISOString(),
          }).catch((error: unknown) => {
            clearTimeout(timeout);
            ws.close();
            reject(error instanceof Error ? error : new Error(String(error)));
          });
          return;
        }

        if ('push' in msg) {
          const push = msg['push'] as Record<string, unknown>;
          const pub = push['pub'] as Record<string, unknown> | undefined;
          if (pub && push['channel'] === channel) {
            clearTimeout(timeout);
            ws.close();
            resolve(pub['data'] as Record<string, unknown>);
          }
        }
      });

      ws.addEventListener('error', (err: Event) => {
        clearTimeout(timeout);
        reject(new Error(`WebSocket error: ${String(err)}`));
      });
    });

    expect(received).toMatchObject({
      gameSessionId: sessionId,
      dpCount: 5,
      delta: 1,
      source: 'gm-manual',
    });
    expect(typeof received['at']).toBe('string');
  });
});
