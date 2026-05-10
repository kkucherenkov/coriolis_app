/**
 * Vitest unit specs for useShipCrewApi + structural assertions on the crew
 * widget wiring in [id].vue (T-2026-05-10-005 Block 4).
 *
 * Pattern mirrors use-ship-modules-api.spec.ts: inline mock of SDK delegation
 * logic, no Nuxt runtime needed. Structural assertions on the SFC source
 * verify the crew widget imports useShipCrewApi and renders six position rows.
 */

import { describe, it, expect, vi, beforeAll } from 'vitest';
import type { CrewSlot, CrewPosition, Problem } from '@app/api-client-ts';

// ── Fixtures ──────────────────────────────────────────────────────────────────

function makeCrewSlotFixture(overrides: Partial<CrewSlot> = {}): CrewSlot {
  return {
    position: 'captain',
    assignedCharacterId: 'char-001',
    ...overrides,
  };
}

// ── Inline mock helpers matching composable delegation logic ──────────────────

interface MockResult<T> {
  data: T | undefined;
  error: Problem | undefined;
}

async function callAssign(
  mockFn: (opts: unknown) => Promise<MockResult<CrewSlot>>,
  shipId: string,
  body: { position: CrewPosition; characterId: string },
): Promise<CrewSlot> {
  const res = await mockFn({ path: { id: shipId }, body });

  if (res.error) throw res.error as Problem;
  return res.data!;
}

async function callUnassign(
  mockFn: (opts: unknown) => Promise<MockResult<void>>,
  shipId: string,
  characterId: string,
): Promise<void> {
  const res = await mockFn({ path: { id: shipId, characterId } });

  if (res.error) throw res.error as Problem;
}

// ── assign — happy path ───────────────────────────────────────────────────────

describe('useShipCrewApi.assign', () => {
  it('returns CrewSlot on 201 response', async () => {
    const fixture = makeCrewSlotFixture({ position: 'pilot', assignedCharacterId: 'char-002' });
    const mockAssign = vi.fn().mockResolvedValue({ data: fixture, error: undefined });

    const result = await callAssign(mockAssign, 'ship-001', {
      position: 'pilot',
      characterId: 'char-002',
    });

    expect(result.position).toBe('pilot');
    expect(result.assignedCharacterId).toBe('char-002');
    expect(mockAssign).toHaveBeenCalledWith({
      path: { id: 'ship-001' },
      body: { position: 'pilot', characterId: 'char-002' },
    });
  });

  it('throws Problem on 400 — CREW_POSITION_TAKEN', async () => {
    const problem: Problem = {
      type: null,
      status: 400,
      detail: 'CREW_POSITION_TAKEN',
      title: 'Bad Request',
    };
    const mockAssign = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(
      callAssign(mockAssign, 'ship-001', { position: 'captain', characterId: 'char-x' }),
    ).rejects.toMatchObject({ status: 400, detail: 'CREW_POSITION_TAKEN' });
  });

  it('throws Problem on 403 — caller does not own ship', async () => {
    const problem: Problem = {
      type: null,
      status: 403,
      detail: 'Forbidden',
      title: 'Forbidden',
    };
    const mockAssign = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(
      callAssign(mockAssign, 'ship-other', { position: 'gunner', characterId: 'char-001' }),
    ).rejects.toMatchObject({ status: 403 });
  });

  it('throws Problem on 404 — ship not found', async () => {
    const problem: Problem = {
      type: null,
      status: 404,
      detail: 'Ship not found',
      title: 'Not Found',
    };
    const mockAssign = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(
      callAssign(mockAssign, 'no-such-ship', { position: 'engineer', characterId: 'char-001' }),
    ).rejects.toMatchObject({ status: 404 });
  });
});

// ── unassign — happy path ─────────────────────────────────────────────────────

describe('useShipCrewApi.unassign', () => {
  it('resolves void on 204 response', async () => {
    const mockUnassign = vi.fn().mockResolvedValue({ data: undefined, error: undefined });

    await expect(callUnassign(mockUnassign, 'ship-001', 'char-001')).resolves.toBeUndefined();
    expect(mockUnassign).toHaveBeenCalledWith({
      path: { id: 'ship-001', characterId: 'char-001' },
    });
  });

  it('throws Problem on 404 — assignment not found', async () => {
    const problem: Problem = {
      type: null,
      status: 404,
      detail: 'Crew assignment not found',
      title: 'Not Found',
    };
    const mockUnassign = vi.fn().mockResolvedValue({ data: undefined, error: problem });

    await expect(callUnassign(mockUnassign, 'ship-001', 'char-nobody')).rejects.toMatchObject({
      status: 404,
    });
  });
});

// ── Structural assertions on [id].vue — Block 4 wiring ───────────────────────

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import nodePath from 'node:path';

const { resolve, dirname } = nodePath;
// WHY: unicorn/prefer-module forbids __dirname in ESM .ts files.
const _dirname = dirname(fileURLToPath(import.meta.url));

const PAGE_PATH = resolve(_dirname, '../../pages/app/ships/[id].vue');

describe('[id].vue Block 4 — crew widget wiring', () => {
  let src: string;

  beforeAll(() => {
    src = readFileSync(PAGE_PATH, 'utf8');
  });

  it('imports useShipCrewApi', () => {
    expect(src).toContain("from '~/composables/useShipCrewApi'");
  });

  it('imports useCharactersApi for character name lookup', () => {
    expect(src).toContain("from '~/composables/useCharactersApi'");
  });

  it('defines the six CREW_POSITIONS in fixed order', () => {
    expect(src).toContain("'captain'");
    expect(src).toContain("'pilot'");
    expect(src).toContain("'sensorOp'");
    expect(src).toContain("'gunner'");
    expect(src).toContain("'engineer'");
    expect(src).toContain("'serviceCrew'");
    expect(src).toContain('CREW_POSITIONS');
  });

  it('has onAssign function for the assign action', () => {
    expect(src).toContain('onAssign');
  });

  it('has onUnassign function for the remove action', () => {
    expect(src).toContain('onUnassign');
  });

  it('has positionLabel helper function', () => {
    expect(src).toContain('positionLabel');
  });

  it('has characterName helper function', () => {
    expect(src).toContain('characterName');
  });

  it('renders a picker with optgroup for characters already on the ship (move semantics hint)', () => {
    expect(src).toContain('crewPickerGroupOnShip');
    expect(src).toContain('onShip');
  });

  it('calls crewApi.assign on confirm', () => {
    expect(src).toContain('crewApi.assign');
  });

  it('calls crewApi.unassign on remove', () => {
    expect(src).toContain('crewApi.unassign');
  });

  it('refetches full ship after assign/unassign (refetchShip)', () => {
    expect(src).toContain('refetchShip');
  });

  it('surfaces crew errors via crewError + AppBanner', () => {
    expect(src).toContain('crewError');
    expect(src).toContain('crewErrorAssign');
    expect(src).toContain('crewErrorUnassign');
  });
});
