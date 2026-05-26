/**
 * Unit tests for CharacterRepo read-boundary clamp.
 * PrismaService is replaced with a vi.fn() stub — no DB required.
 *
 * The critical invariant under test: toReadModel() must never return
 * hp.current > hp.max or mp.current > mp.max, regardless of what is
 * stored in the DB.
 */
import { describe, expect, it, vi } from 'vitest';

import type { PrismaService } from '../../../common/prisma/prisma.service';
import { CharacterRepo } from './character.repo';

// --------------- Minimal Prisma row stub ---------------

function makePrismaRow(
  overrides: {
    hpCurrent?: number;
    mpCurrent?: number;
    strength?: number;
    agility?: number;
    wits?: number;
    empathy?: number;
  } = {},
) {
  const strength = overrides.strength ?? 3;
  const agility = overrides.agility ?? 3;
  const wits = overrides.wits ?? 3;
  const empathy = overrides.empathy ?? 3;
  return {
    id: 'char-1',
    ownerId: 'user-1',
    name: 'Test Character',
    concept: null,
    role: null,
    roleUnmigrated: false,
    iconId: null,
    upbringing: 'plebeian',
    origin: null,
    reputation: 2,
    startingWealth: 500,
    birr: 500,
    crewConcept: null,
    mutant: false,
    mutantLineage: null,
    attributes: { strength, agility, wits, empathy },
    skills: {
      dexterity: 0,
      force: 0,
      infiltration: 0,
      manipulation: 0,
      meleeCombat: 0,
      observation: 0,
      rangedCombat: 0,
      survival: 0,
      command: 0,
      culture: 0,
      dataDjinn: 0,
      medicurgy: 0,
      mysticPowers: 0,
      pilot: 0,
      science: 0,
      technology: 0,
    },
    hpCurrent: overrides.hpCurrent ?? strength + agility,
    mpCurrent: overrides.mpCurrent ?? wits + empathy,
    experience: 0,
    conditions: { exhausted: false, sleepless: false, thirsty: false, hungry: false },
    notes: null,
    status: 'ACTIVE',
    createdAt: new Date('2026-01-15T00:00:00.000Z'),
    updatedAt: new Date('2026-01-15T00:00:00.000Z'),
    items: [],
    talents: [],
    relationships: [],
    criticalInjuries: [],
  };
}

function makePrisma(row: ReturnType<typeof makePrismaRow> | null) {
  return {
    character: {
      findFirst: vi.fn().mockResolvedValue(row),
    },
  } as unknown as PrismaService;
}

// --------------- Tests ---------------

describe('CharacterRepo read-boundary clamp', () => {
  let repo: CharacterRepo;

  describe('findActiveById', () => {
    it('returns hp.current === hp.max when stored value equals derived max', async () => {
      // default stub: strength=3, agility=3 → hpMax=6; stored=6
      const row = makePrismaRow({ strength: 3, agility: 3, hpCurrent: 6 });
      repo = new CharacterRepo(makePrisma(row));

      const result = await repo.findActiveById('char-1');

      expect(result?.hp.max).toBe(6);
      expect(result?.hp.current).toBe(6);
    });

    it('clamps hp.current to hp.max when stored value exceeds derived max (legacy seed 14)', async () => {
      // strength=3, agility=3 → hpMax=6; legacy stored value=14
      const row = makePrismaRow({ strength: 3, agility: 3, hpCurrent: 14 });
      repo = new CharacterRepo(makePrisma(row));

      const result = await repo.findActiveById('char-1');

      expect(result?.hp.max).toBe(6);
      expect(result?.hp.current).toBe(6);
      expect(result?.hp.current).toBeLessThanOrEqual(result?.hp.max ?? 0);
    });

    it('clamps mp.current to mp.max when stored value exceeds derived max (legacy seed 10)', async () => {
      // wits=3, empathy=3 → mpMax=6; legacy stored value=10
      const row = makePrismaRow({ wits: 3, empathy: 3, mpCurrent: 10 });
      repo = new CharacterRepo(makePrisma(row));

      const result = await repo.findActiveById('char-1');

      expect(result?.mp.max).toBe(6);
      expect(result?.mp.current).toBe(6);
      expect(result?.mp.current).toBeLessThanOrEqual(result?.mp.max ?? 0);
    });

    it('does not clamp when stored value is below the derived max', async () => {
      // strength=3, agility=3 → hpMax=6; stored=4 → should remain 4
      const row = makePrismaRow({ strength: 3, agility: 3, hpCurrent: 4 });
      repo = new CharacterRepo(makePrisma(row));

      const result = await repo.findActiveById('char-1');

      expect(result?.hp.current).toBe(4);
      expect(result?.hp.max).toBe(6);
    });

    it('computes higher hpMax for higher attributes and does not clamp a valid current', async () => {
      // strength=4, agility=4 → hpMax=8; stored=7 → passes through
      const row = makePrismaRow({ strength: 4, agility: 4, hpCurrent: 7 });
      repo = new CharacterRepo(makePrisma(row));

      const result = await repo.findActiveById('char-1');

      expect(result?.hp.max).toBe(8);
      expect(result?.hp.current).toBe(7);
    });

    it('returns null when no character is found', async () => {
      repo = new CharacterRepo(makePrisma(null));

      const result = await repo.findActiveById('missing');

      expect(result).toBeNull();
    });
  });
});
