/**
 * T-007 Block 5 — Integration test: combat.updated channel delivery
 *
 * Requires the Docker Compose stack (centrifugo) to be running.
 * The test suite is skipped automatically when Centrifugo is not reachable.
 *
 * To run manually with the Docker stack:
 *   docker compose -f docker/compose.yml up -d
 *   pnpm --filter @app/backend test
 *
 * Environment (defaults match docker/compose.yml):
 *   INTEGRATION_CENTRIFUGO_URL          http://localhost:8000
 *   INTEGRATION_CENTRIFUGO_WS_URL       ws://localhost:8000
 *   INTEGRATION_CENTRIFUGO_API_KEY      dev-api-key
 *   INTEGRATION_CENTRIFUGO_TOKEN_SECRET dev-hmac-secret
 *
 * What this test does:
 *   1. Signs a short-lived Centrifugo JWT for a fake user.
 *   2. Opens a WebSocket and subscribes to session.{id}.
 *   3. Uses CentrifugoCombatPublisher directly to publish a combat.updated snapshot.
 *   4. Asserts the subscriber receives the message within 1000ms.
 *   5. Verifies the envelope shape (gameSessionId, encounterId, encounter, combatants, at).
 *
 * The backend-to-Centrifugo publish path is the same one all mutation handlers use.
 * This test proves the channel subscription + delivery contract without booting NestJS.
 */

import * as crypto from 'node:crypto';

import { beforeAll, describe, expect, it } from 'vitest';

import { CentrifugoClient } from '../../src/modules/realtime/centrifugo.client';
import { CentrifugoCombatPublisher } from '../../src/modules/encounters/infra/combat.publisher';

import type { AppConfig } from '../../src/common/config/app-config';
import type { EncounterReadModel } from '../../src/modules/encounters/domain/encounter.ports';
import type { CombatantReadModel } from '../../src/modules/combatants/domain/combatant.ports';

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

  if (!centrifugoUp) {
    console.warn(
      '[SKIP] Centrifugo not reachable — start the Docker stack to run combat publisher e2e tests.',
    );
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

function makeAppConfig(): AppConfig {
  return {
    centrifugo: {
      apiUrl: CENTRIFUGO_API_URL,
      apiKey: CENTRIFUGO_API_KEY,
      tokenHmacSecret: CENTRIFUGO_TOKEN_SECRET,
      tokenTtlSeconds: 300,
    },
  } as AppConfig;
}

function makeEncounterSnapshot(gameSessionId: string, encounterId: string): EncounterReadModel {
  return {
    id: encounterId,
    gameSessionId,
    name: 'Combat E2E Test',
    notes: null,
    status: 'active',
    round: 1,
    activeCombatantId: 'test-comb-1',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
}

function makeCombatantSnapshot(encounterId: string): CombatantReadModel {
  return {
    id: 'test-comb-1',
    encounterId,
    combatantType: 'npc',
    sourceId: 'test-npc-1',
    displayName: 'Test Guard',
    initiative: 7,
    turnOrder: 0,
    hpCurrent: 6,
    hpMax: 6,
    armor: 2,
    signature: 1,
    statusFlags: [],
    notes: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
}

describe('T-007 Block 5 — combat.updated channel delivery', () => {
  it('subscriber receives combat.updated within 1000ms of publish', async () => {
    if (!centrifugoUp) {
      console.log('[SKIP] Centrifugo not reachable — start the Docker stack to run this test.');
      return;
    }

    const sessionId = 'test-gs-combat-e2e-1';
    const encounterId = 'test-enc-e2e-1';
    const channel = `session.${sessionId}`;
    const userId = 'test-user-gm-combat';
    const token = makeCentrifugoJwt(userId, [channel]);

    // Build publisher with the real CentrifugoClient (talks to Docker stack)
    const config = makeAppConfig();
    const centrifugoClient = new CentrifugoClient(config);
    const publisher = new CentrifugoCombatPublisher(centrifugoClient);

    const encounter = makeEncounterSnapshot(sessionId, encounterId);
    const combatants = [makeCombatantSnapshot(encounterId)];

    const received = await new Promise<Record<string, unknown>>((resolve, reject) => {
      const ws = new WebSocket(`${CENTRIFUGO_WS_URL}/connection/websocket?cf_token=${token}`);
      const timeout = setTimeout(() => {
        ws.close();
        reject(new Error('Timed out waiting for combat.updated within 1000ms'));
      }, 1000);

      ws.addEventListener('open', () => {
        ws.send(JSON.stringify({ id: 1, connect: {} }));
      });

      let connected = false;
      ws.addEventListener('message', (event: MessageEvent) => {
        const msg = JSON.parse(event.data as string) as Record<string, unknown>;

        if (!connected && 'connect' in msg) {
          connected = true;
          ws.send(JSON.stringify({ id: 2, subscribe: { channel } }));
          return;
        }

        if ('subscribe' in msg) {
          // Subscription confirmed — trigger publish via the real publisher
          publisher.publishUpdated(sessionId, encounter, combatants).catch((error: unknown) => {
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

    // Verify envelope shape matches AsyncAPI CombatUpdated schema
    expect(received).toMatchObject({
      gameSessionId: sessionId,
      encounterId,
      encounter: expect.objectContaining({
        id: encounterId,
        gameSessionId: sessionId,
        status: 'active',
        round: 1,
      }),
      combatants: expect.arrayContaining([
        expect.objectContaining({
          id: 'test-comb-1',
          name: 'Test Guard', // displayName → name mapping
          referenceId: 'test-npc-1', // sourceId → referenceId mapping
          initiative: 7,
          turnOrder: 0,
          hpCurrent: 6,
          hpMax: 6,
        }),
      ]),
    });
    expect(typeof received['at']).toBe('string');
    expect(new Date(received['at'] as string).toISOString()).toBe(received['at']);
  });
});
