/**
 * Unit tests for sortInitiative pure function.
 */
import { describe, expect, it } from 'vitest';

import { sortInitiative } from './initiative';

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
  agility: number,
  createdAt = '2026-05-10T10:00:00.000Z',
  combatantType: 'pc' | 'npc' = 'pc',
): CombatantWithSnapshot {
  const combatant = makeCombatant({ id, initiative, combatantType, createdAt });

  if (combatantType === 'pc') {
    return {
      combatant,
      pcSnapshot: {
        attributes: { strength: 2, agility, wits: 2, empathy: 2 },
        skills: {},
        hpMax: 4,
      },
      npcSnapshot: null,
    };
  }

  return {
    combatant,
    pcSnapshot: null,
    npcSnapshot: {
      attributes: { strength: 2, agility, wits: 2, empathy: 2 },
      skills: {},
      hpMax: 4,
      signature: 0,
    },
  };
}

describe('sortInitiative', () => {
  it('sorts by initiative descending', () => {
    const items = [makeItem('cb-low', 3, 2), makeItem('cb-high', 9, 2), makeItem('cb-mid', 6, 2)];

    const result = sortInitiative(items);

    expect(result.map((i) => i.combatant.id)).toEqual(['cb-high', 'cb-mid', 'cb-low']);
  });

  it('breaks ties by agility descending', () => {
    const items = [makeItem('cb-low-agi', 7, 2), makeItem('cb-high-agi', 7, 4)];

    const result = sortInitiative(items);

    expect(result.map((i) => i.combatant.id)).toEqual(['cb-high-agi', 'cb-low-agi']);
  });

  it('breaks agility ties by createdAt ascending (stable)', () => {
    const items = [
      makeItem('cb-later', 5, 3, '2026-05-10T10:01:00.000Z'),
      makeItem('cb-earlier', 5, 3, '2026-05-10T09:00:00.000Z'),
    ];

    const result = sortInitiative(items);

    expect(result.map((i) => i.combatant.id)).toEqual(['cb-earlier', 'cb-later']);
  });

  it('works with NPC snapshots for agility tiebreak', () => {
    const items = [
      makeItem('npc-low', 6, 1, '2026-05-10T10:00:00.000Z', 'npc'),
      makeItem('npc-high', 6, 5, '2026-05-10T10:00:00.000Z', 'npc'),
    ];

    const result = sortInitiative(items);

    expect(result.at(0)?.combatant.id).toBe('npc-high');
  });

  it('does not mutate the input array', () => {
    const items = [makeItem('cb-1', 5, 2), makeItem('cb-2', 9, 2)];
    const originalFirst = items.at(0)?.combatant.id;
    const originalSecond = items.at(1)?.combatant.id;

    sortInitiative(items);

    expect(items.at(0)?.combatant.id).toBe(originalFirst);
    expect(items.at(1)?.combatant.id).toBe(originalSecond);
  });

  it('handles a single combatant', () => {
    const items = [makeItem('cb-solo', 7, 3)];
    const result = sortInitiative(items);
    expect(result).toHaveLength(1);
    expect(result.at(0)?.combatant.id).toBe('cb-solo');
  });

  it('falls back to 0 agility when snapshot is absent', () => {
    const items: CombatantWithSnapshot[] = [
      {
        combatant: makeCombatant({ id: 'cb-no-snap', initiative: 5 }),
        pcSnapshot: null,
        npcSnapshot: null,
      },
      makeItem('cb-with-snap', 5, 3),
    ];

    const result = sortInitiative(items);

    // cb-with-snap has agility 3, cb-no-snap has agility 0 → cb-with-snap first
    expect(result.at(0)?.combatant.id).toBe('cb-with-snap');
  });
});
