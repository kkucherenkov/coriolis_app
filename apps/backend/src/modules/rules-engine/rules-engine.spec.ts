/**
 * Unit tests for the Coriolis rules-engine pure functions.
 *
 * Formula citations:
 *   computeHpMax         — PRD §5.2: "HP max = STR + AGI"
 *   computeMpMax         — PRD §5.2: "MP max = WIT + EMP"
 *   computeEncumbranceMax — PRD §5.2: "Encumbrance limit = STR × 2"
 *   computeEncumbranceCurrent — PRD §5.3: sum of item weights
 *   canPush              — PRD §10: not exhausted, not already pushed
 */
import { describe, expect, it } from 'vitest';

import {
  applyConditions,
  canPush,
  computeEncumbranceCurrent,
  computeEncumbranceMax,
  computeHpMax,
  computeMpMax,
} from './rules-engine';
import type { ConditionFlags } from './rules-engine';

import type { ItemReadModel } from '../characters/domain/character.ports';

// --------------- helpers ---------------

function makeItem(overrides: Partial<ItemReadModel> & { weight?: number } = {}): ItemReadModel {
  const { weight = 1, ...rest } = overrides;
  return { id: 'item-1', type: 'GEAR', weight, ...rest };
}

// --------------- computeHpMax ---------------

describe('computeHpMax', () => {
  it('returns STR + AGI for minimum attributes (1+1=2)', () => {
    expect(computeHpMax(1, 1)).toBe(2);
  });

  it('returns STR + AGI for maximum attributes (5+5=10)', () => {
    expect(computeHpMax(5, 5)).toBe(10);
  });

  it('returns STR + AGI for typical starting character (2+2=4)', () => {
    expect(computeHpMax(2, 2)).toBe(4);
  });

  it('is asymmetric — STR 3 AGI 1 = 4', () => {
    expect(computeHpMax(3, 1)).toBe(4);
  });

  it('is asymmetric — STR 1 AGI 3 = 4', () => {
    expect(computeHpMax(1, 3)).toBe(4);
  });

  it('returns STR + AGI for mixed common values (3+3=6)', () => {
    expect(computeHpMax(3, 3)).toBe(6);
  });

  it('returns STR + AGI for high combat build (4+5=9)', () => {
    expect(computeHpMax(4, 5)).toBe(9);
  });
});

// --------------- computeMpMax ---------------

describe('computeMpMax', () => {
  it('returns WIT + EMP for minimum attributes (1+1=2)', () => {
    expect(computeMpMax(1, 1)).toBe(2);
  });

  it('returns WIT + EMP for maximum attributes (5+5=10)', () => {
    expect(computeMpMax(5, 5)).toBe(10);
  });

  it('returns WIT + EMP for typical starting character (2+2=4)', () => {
    expect(computeMpMax(2, 2)).toBe(4);
  });

  it('is asymmetric — WIT 4 EMP 1 = 5', () => {
    expect(computeMpMax(4, 1)).toBe(5);
  });

  it('returns correct value for pilot build (3+2=5)', () => {
    expect(computeMpMax(3, 2)).toBe(5);
  });

  it('returns correct value for mystic build (3+5=8)', () => {
    expect(computeMpMax(3, 5)).toBe(8);
  });
});

// --------------- computeEncumbranceMax ---------------

describe('computeEncumbranceMax', () => {
  it('returns STR × 2 for minimum strength (1×2=2)', () => {
    expect(computeEncumbranceMax(1)).toBe(2);
  });

  it('returns STR × 2 for maximum strength (5×2=10)', () => {
    expect(computeEncumbranceMax(5)).toBe(10);
  });

  it('returns STR × 2 for default strength (2×2=4)', () => {
    expect(computeEncumbranceMax(2)).toBe(4);
  });

  it('returns STR × 2 for strength 3 (3×2=6)', () => {
    expect(computeEncumbranceMax(3)).toBe(6);
  });

  it('returns STR × 2 for strength 4 (4×2=8)', () => {
    expect(computeEncumbranceMax(4)).toBe(8);
  });
});

// --------------- computeEncumbranceCurrent ---------------

describe('computeEncumbranceCurrent', () => {
  it('returns 0 for empty inventory', () => {
    expect(computeEncumbranceCurrent([])).toBe(0);
  });

  it('returns weight for single item', () => {
    expect(computeEncumbranceCurrent([makeItem({ weight: 2 })])).toBe(2);
  });

  it('sums weights for multiple items', () => {
    const items = [makeItem({ weight: 1 }), makeItem({ id: 'item-2', weight: 2 }), makeItem({ id: 'item-3', weight: 3 })];
    expect(computeEncumbranceCurrent(items)).toBe(6);
  });

  it('handles fractional weights (0.5 increments per PRD §5.3)', () => {
    const items = [makeItem({ weight: 0.5 }), makeItem({ id: 'item-2', weight: 1.5 })];
    expect(computeEncumbranceCurrent(items)).toBeCloseTo(2.0);
  });

  it('handles zero-weight items (contributes nothing)', () => {
    const items = [makeItem({ weight: 0 }), makeItem({ id: 'item-2', weight: 2 })];
    expect(computeEncumbranceCurrent(items)).toBe(2);
  });

  it('handles items without weight field (treated as 0)', () => {
    const noWeightItem: ItemReadModel = { id: 'item-1', type: 'GEAR' };
    expect(computeEncumbranceCurrent([noWeightItem])).toBe(0);
  });

  it('sums weapons, armor, and gear correctly', () => {
    const weapon: ItemReadModel = { id: 'w-1', type: 'WEAPON', weight: 1 };
    const armor: ItemReadModel = { id: 'a-1', type: 'ARMOR', weight: 2 };
    const gear: ItemReadModel = { id: 'g-1', type: 'GEAR', weight: 0.5 };
    expect(computeEncumbranceCurrent([weapon, armor, gear])).toBeCloseTo(3.5);
  });

  it('includes CYBERNETIC items by their weight field (PRD does not explicitly exempt them; weight=0 assumed if cybernetic adds no load)', () => {
    const cyb: ItemReadModel = { id: 'c-1', type: 'CYBERNETIC', weight: 1 };
    const gear: ItemReadModel = { id: 'g-1', type: 'GEAR', weight: 1 };
    expect(computeEncumbranceCurrent([cyb, gear])).toBe(2);
  });

  it('CYBERNETIC with weight 0 does not add encumbrance', () => {
    const cyb: ItemReadModel = { id: 'c-1', type: 'CYBERNETIC', weight: 0 };
    const gear: ItemReadModel = { id: 'g-1', type: 'GEAR', weight: 2 };
    expect(computeEncumbranceCurrent([cyb, gear])).toBe(2);
  });

  it('handles SHIP_MODULE items', () => {
    const module: ItemReadModel = { id: 'm-1', type: 'SHIP_MODULE', weight: 3 };
    expect(computeEncumbranceCurrent([module])).toBe(3);
  });
});

// --------------- applyConditions ---------------

describe('applyConditions', () => {
  const none: ConditionFlags = { exhausted: false, sleepless: false, thirsty: false, hungry: false };
  const all: ConditionFlags = { exhausted: true, sleepless: true, thirsty: true, hungry: true };

  it('no conditions active → pool unchanged', () => {
    expect(applyConditions(none, 6)).toBe(6);
  });

  it('one condition (exhausted) → pool − 1', () => {
    expect(applyConditions({ ...none, exhausted: true }, 5)).toBe(4);
  });

  it('one condition (sleepless) → pool − 1', () => {
    expect(applyConditions({ ...none, sleepless: true }, 3)).toBe(2);
  });

  it('one condition (thirsty) → pool − 1', () => {
    expect(applyConditions({ ...none, thirsty: true }, 4)).toBe(3);
  });

  it('one condition (hungry) → pool − 1', () => {
    expect(applyConditions({ ...none, hungry: true }, 2)).toBe(1);
  });

  it('all four conditions → pool − 4', () => {
    expect(applyConditions(all, 6)).toBe(2);
  });

  it('pool of 0 with all conditions → still 0 (clamped)', () => {
    expect(applyConditions(all, 0)).toBe(0);
  });

  it('pool of 2 with three conditions → 0 (clamped, not negative)', () => {
    expect(applyConditions({ exhausted: true, sleepless: true, thirsty: true, hungry: false }, 2)).toBe(0);
  });

  it('pool of 1 with all four conditions → 0 (clamped)', () => {
    expect(applyConditions(all, 1)).toBe(0);
  });

  it('partial: two conditions out of four → pool − 2', () => {
    expect(applyConditions({ ...none, exhausted: true, hungry: true }, 7)).toBe(5);
  });

  it('three conditions → pool − 3', () => {
    expect(applyConditions({ exhausted: true, sleepless: true, thirsty: true, hungry: false }, 5)).toBe(2);
  });

  it('pool exactly equal to active conditions → result is 0', () => {
    expect(applyConditions({ ...none, sleepless: true, thirsty: true }, 2)).toBe(0);
  });
});

// --------------- canPush ---------------

describe('canPush', () => {
  it('returns true when not exhausted and not already pushed', () => {
    expect(canPush({ exhausted: false }, false)).toBe(true);
  });

  it('returns false when exhausted (PRD §10: Exhausted blocks push)', () => {
    expect(canPush({ exhausted: true }, false)).toBe(false);
  });

  it('returns false when already pushed (PRD §10: one push per roll)', () => {
    expect(canPush({ exhausted: false }, true)).toBe(false);
  });

  it('returns false when both exhausted and already pushed', () => {
    expect(canPush({ exhausted: true }, true)).toBe(false);
  });

  it('is independent of other condition flags — only exhausted matters', () => {
    // sleepless, thirsty, hungry do not block push per PRD §10
    expect(canPush({ exhausted: false }, false)).toBe(true);
  });
});
