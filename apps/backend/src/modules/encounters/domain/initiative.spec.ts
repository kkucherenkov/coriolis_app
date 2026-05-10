/**
 * Unit tests for the pure initiative domain functions.
 */
import { describe, expect, it, vi } from 'vitest';

import {
  MAX_REROLL_PASSES,
  clampInitiative,
  rerollTies,
  sortInitiative,
  sumWeaponInitiative,
} from './initiative';

import type {
  CombatantWithSnapshot,
  CombatantReadModel,
} from '../../combatants/domain/combatant.ports';

function makeCombatant(overrides: Partial<CombatantReadModel> = {}): CombatantReadModel {
  return {
    id: 'cb-1',
    encounterId: 'enc-1',
    combatantType: 'pc',
    sourceId: 'char-1',
    displayName: 'Test',
    initiative: null,
    turnOrder: null,
    hpCurrent: 4,
    hpMax: 4,
    armor: 0,
    signature: 0,
    statusFlags: [],
    notes: null,
    createdAt: '2026-05-10T10:00:00.000Z',
    updatedAt: '2026-05-10T10:00:00.000Z',
    ...overrides,
  };
}

function makeItem(
  id: string,
  initiative: number,
  createdAt = '2026-05-10T10:00:00.000Z',
): CombatantWithSnapshot {
  return {
    combatant: makeCombatant({ id, initiative, createdAt }),
    pcSnapshot: {
      attributes: { strength: 2, agility: 2, wits: 2, empathy: 2 },
      skills: {},
      hpMax: 4,
    },
    npcSnapshot: null,
  };
}

describe('sumWeaponInitiative', () => {
  it('returns 0 for an empty array', () => {
    expect(sumWeaponInitiative([])).toBe(0);
  });

  it('returns the initiative of a single equipped weapon', () => {
    expect(sumWeaponInitiative([{ initiative: 1, equipped: true }])).toBe(1);
  });

  it('ignores unequipped weapons', () => {
    expect(sumWeaponInitiative([{ initiative: 1, equipped: false }])).toBe(0);
  });

  it('sums initiative for multiple equipped weapons', () => {
    expect(
      sumWeaponInitiative([
        { initiative: 2, equipped: true },
        { initiative: 1, equipped: true },
      ]),
    ).toBe(3);
  });

  it('defaults missing initiative to 0 for equipped weapon', () => {
    expect(sumWeaponInitiative([{ equipped: true }])).toBe(0);
  });

  it('ignores weapons where equipped is undefined (not equipped)', () => {
    expect(sumWeaponInitiative([{ initiative: 3 }])).toBe(0);
  });
});

describe('clampInitiative', () => {
  it('clamps values below 1 up to 1', () => {
    expect(clampInitiative(0)).toBe(1);
    expect(clampInitiative(-5)).toBe(1);
  });

  it('clamps values above 10 down to 10', () => {
    expect(clampInitiative(11)).toBe(10);
    expect(clampInitiative(20)).toBe(10);
  });

  it('passes through in-range values unchanged', () => {
    expect(clampInitiative(1)).toBe(1);
    expect(clampInitiative(7)).toBe(7);
    expect(clampInitiative(10)).toBe(10);
  });
});

describe('sortInitiative', () => {
  it('sorts by initiative descending', () => {
    const items = [makeItem('cb-low', 2), makeItem('cb-high', 6), makeItem('cb-mid', 4)];

    const result = sortInitiative(items);

    expect(result.map((i) => i.combatant.id)).toEqual(['cb-high', 'cb-mid', 'cb-low']);
  });

  it('breaks lingering ties by createdAt ascending (stable fallback)', () => {
    const items = [
      makeItem('cb-later', 4, '2026-05-10T10:01:00.000Z'),
      makeItem('cb-earlier', 4, '2026-05-10T09:00:00.000Z'),
    ];

    const result = sortInitiative(items);

    expect(result.map((i) => i.combatant.id)).toEqual(['cb-earlier', 'cb-later']);
  });

  it('does not mutate the input array', () => {
    const items = [makeItem('cb-1', 3), makeItem('cb-2', 6)];
    const originalFirst = items.at(0)?.combatant.id;
    const originalSecond = items.at(1)?.combatant.id;

    sortInitiative(items);

    expect(items.at(0)?.combatant.id).toBe(originalFirst);
    expect(items.at(1)?.combatant.id).toBe(originalSecond);
  });

  it('handles a single combatant', () => {
    const items = [makeItem('cb-solo', 5)];
    const result = sortInitiative(items);
    expect(result).toHaveLength(1);
    expect(result.at(0)?.combatant.id).toBe('cb-solo');
  });
});

describe('rerollTies', () => {
  it('returns the input unchanged when there are no ties', () => {
    const items = [makeItem('cb-1', 5), makeItem('cb-2', 3), makeItem('cb-3', 6)];
    const rollD6 = vi.fn(() => 4);

    const result = rerollTies(items, rollD6);

    expect(rollD6).not.toHaveBeenCalled();
    expect(result.map((i) => i.combatant.initiative)).toEqual([5, 3, 6]);
  });

  it('rerolls only the tied combatants and resolves on the first pass', () => {
    const items = [makeItem('cb-tied-a', 4), makeItem('cb-tied-b', 4), makeItem('cb-loner', 6)];
    // Two tied → two reroll calls; produce distinct values.
    const rollD6 = vi.fn<() => number>().mockReturnValueOnce(2).mockReturnValueOnce(5);

    const result = rerollTies(items, rollD6);

    expect(rollD6).toHaveBeenCalledTimes(2);
    expect(result.find((i) => i.combatant.id === 'cb-tied-a')?.combatant.initiative).toBe(2);
    expect(result.find((i) => i.combatant.id === 'cb-tied-b')?.combatant.initiative).toBe(5);
    expect(result.find((i) => i.combatant.id === 'cb-loner')?.combatant.initiative).toBe(6);
  });

  it('keeps re-rolling tied combatants across passes until ties resolve', () => {
    const items = [makeItem('cb-a', 3), makeItem('cb-b', 3)];
    // Pass 1: both reroll to 4 → still tied.
    // Pass 2: rerolls to 5 and 1 → resolved.
    const rollD6 = vi
      .fn<() => number>()
      .mockReturnValueOnce(4)
      .mockReturnValueOnce(4)
      .mockReturnValueOnce(5)
      .mockReturnValueOnce(1);

    const result = rerollTies(items, rollD6);

    expect(rollD6).toHaveBeenCalledTimes(4);
    const values = result.map((i) => i.combatant.initiative).toSorted();
    expect(values).toEqual([1, 5]);
  });

  it('gives up after MAX_REROLL_PASSES and leaves the (still-tied) values in place', () => {
    const items = [makeItem('cb-a', 3), makeItem('cb-b', 3)];
    // Always roll the same number → never resolves.
    const rollD6 = vi.fn<() => number>().mockReturnValue(2);

    const result = rerollTies(items, rollD6);

    // 2 combatants × MAX_REROLL_PASSES passes
    expect(rollD6).toHaveBeenCalledTimes(2 * MAX_REROLL_PASSES);
    expect(result.every((i) => i.combatant.initiative === 2)).toBe(true);
  });

  it('does not mutate the input array', () => {
    const items = [makeItem('cb-1', 4), makeItem('cb-2', 4)];
    const originalInitiatives = items.map((i) => i.combatant.initiative);
    const rollD6 = vi.fn<() => number>().mockReturnValue(6).mockReturnValueOnce(2);

    rerollTies(items, rollD6);

    expect(items.map((i) => i.combatant.initiative)).toEqual(originalInitiatives);
  });

  it('handles a single combatant (no ties possible)', () => {
    const items = [makeItem('cb-solo', 4)];
    const rollD6 = vi.fn(() => 1);

    const result = rerollTies(items, rollD6);

    expect(rollD6).not.toHaveBeenCalled();
    expect(result.map((i) => i.combatant.id)).toEqual(['cb-solo']);
  });

  it('resolves a partial tie among three combatants without rolling for the loner', () => {
    const items = [makeItem('cb-a', 5), makeItem('cb-b', 5), makeItem('cb-c', 6)];
    const rollD6 = vi.fn<() => number>().mockReturnValueOnce(2).mockReturnValueOnce(4);

    const result = rerollTies(items, rollD6);

    expect(rollD6).toHaveBeenCalledTimes(2);
    expect(result.find((i) => i.combatant.id === 'cb-c')?.combatant.initiative).toBe(6);
  });
});
