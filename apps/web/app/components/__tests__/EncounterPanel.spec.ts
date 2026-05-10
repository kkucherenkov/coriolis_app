/**
 * EncounterPanel.spec.ts — smoke + logic unit tests (T-2026-05-10-008 Block 3).
 *
 * The component requires a full Nuxt + vue-i18n environment to mount.
 * These tests validate the underlying logic extracted from the SFC without
 * mounting it directly, following the pattern established in RoleCardGrid.spec.ts.
 *
 * Mount-level interaction tests (create form submit, delete click, empty state
 * render) are covered via structural assertions in use-encounters-api.spec.ts
 * and the Playwright smoke spec scheduled for Block 5.
 */

import { describe, it, expect } from 'vitest';
import type { Encounter, EncounterStatus } from '@app/api-client-ts';

// ── Fixture ───────────────────────────────────────────────────────────────────

function makeEncounter(overrides: Partial<Encounter> = {}): Encounter {
  return {
    id: 'enc-panel-001',
    gameSessionId: 'session-panel-001',
    name: 'Forest Ambush',
    status: 'setup',
    round: 0,
    activeCombatantId: null,
    notes: null,
    createdAt: '2026-05-11T12:00:00Z',
    updatedAt: '2026-05-11T12:00:00Z',
    ...overrides,
  };
}

// ── State badge variant ────────────────────────────────────────────────────────
// Mirrors EncounterPanel.stateBadgeVariant

function stateBadgeVariant(status: EncounterStatus): 'brass' | 'mystic' | 'success' {
  if (status === 'active') return 'success';
  if (status === 'ended') return 'mystic';
  return 'brass';
}

describe('EncounterPanel — stateBadgeVariant', () => {
  it('returns brass for setup', () => {
    expect(stateBadgeVariant('setup')).toBe('brass');
  });

  it('returns success for active', () => {
    expect(stateBadgeVariant('active')).toBe('success');
  });

  it('returns mystic for ended', () => {
    expect(stateBadgeVariant('ended')).toBe('mystic');
  });
});

// ── showSetupHint ─────────────────────────────────────────────────────────────
// Mirrors EncounterPanel.showSetupHint

function showSetupHint(encounter: Encounter, combatantCount: number): boolean {
  return encounter.status === 'setup' && combatantCount === 0;
}

describe('EncounterPanel — showSetupHint', () => {
  it('returns true when status=setup and combatantCount=0', () => {
    const enc = makeEncounter({ status: 'setup' });
    expect(showSetupHint(enc, 0)).toBe(true);
  });

  it('returns false when status=setup but combatantCount=1', () => {
    const enc = makeEncounter({ status: 'setup' });
    expect(showSetupHint(enc, 1)).toBe(false);
  });

  it('returns false when status=active regardless of combatant count', () => {
    const enc = makeEncounter({ status: 'active' });
    expect(showSetupHint(enc, 0)).toBe(false);
    expect(showSetupHint(enc, 3)).toBe(false);
  });

  it('returns false when status=ended regardless of combatant count', () => {
    const enc = makeEncounter({ status: 'ended' });
    expect(showSetupHint(enc, 0)).toBe(false);
  });
});

// ── Create form validation ─────────────────────────────────────────────────────
// Mirrors the inline validation in submitCreate

function validateCreateName(name: string): string | null {
  const trimmed = name.trim();
  if (!trimmed) return 'Name is required.';
  if (trimmed.length > 80) return 'Name exceeds 80 characters.';
  return null;
}

describe('EncounterPanel — create form validation', () => {
  it('returns null for a valid name', () => {
    expect(validateCreateName('Ambush in the Spire')).toBeNull();
  });

  it('returns error for empty name', () => {
    expect(validateCreateName('')).not.toBeNull();
  });

  it('returns error for whitespace-only name', () => {
    expect(validateCreateName('   ')).not.toBeNull();
  });

  it('returns error for name exceeding 80 chars', () => {
    expect(validateCreateName('x'.repeat(81))).not.toBeNull();
  });

  it('accepts name of exactly 80 chars', () => {
    expect(validateCreateName('a'.repeat(80))).toBeNull();
  });
});

// ── combatantCount defaults ───────────────────────────────────────────────────
// The panel stores counts in a Map; missing entries default to 0

function combatantCountFor(map: Map<string, number>, id: string): number {
  return map.get(id) ?? 0;
}

describe('EncounterPanel — combatantCountFor', () => {
  it('returns the stored count for a known encounter', () => {
    const m = new Map([['enc-a', 3]]);
    expect(combatantCountFor(m, 'enc-a')).toBe(3);
  });

  it('returns 0 when encounter is not yet in the map', () => {
    const m = new Map<string, number>();
    expect(combatantCountFor(m, 'enc-unknown')).toBe(0);
  });

  it('returns 0 when map explicitly holds 0', () => {
    const m = new Map([['enc-b', 0]]);
    expect(combatantCountFor(m, 'enc-b')).toBe(0);
  });
});

// ── Encounter card rendering conditions ──────────────────────────────────────

describe('EncounterPanel — card rendering', () => {
  it('active encounter: round > 0 and activeCombatantId set', () => {
    const enc = makeEncounter({
      status: 'active',
      round: 1,
      activeCombatantId: 'cbt-001',
    });
    expect(enc.status).toBe('active');
    expect(enc.round).toBeGreaterThan(0);
    expect(enc.activeCombatantId).not.toBeNull();
    // No setup hint for active encounters
    expect(showSetupHint(enc, 0)).toBe(false);
  });

  it('ended encounter: activeCombatantId is null per spec', () => {
    const enc = makeEncounter({
      status: 'ended',
      activeCombatantId: null,
    });
    expect(enc.status).toBe('ended');
    expect(enc.activeCombatantId).toBeNull();
    expect(stateBadgeVariant(enc.status)).toBe('mystic');
  });

  it('multiple encounters: each gets its own state badge', () => {
    const setup = makeEncounter({ id: 'enc-1', status: 'setup' });
    const active = makeEncounter({ id: 'enc-2', status: 'active' });
    const ended = makeEncounter({ id: 'enc-3', status: 'ended' });

    expect(stateBadgeVariant(setup.status)).toBe('brass');
    expect(stateBadgeVariant(active.status)).toBe('success');
    expect(stateBadgeVariant(ended.status)).toBe('mystic');
  });
});

// ── notes trimming ────────────────────────────────────────────────────────────
// The panel trims notes before submitting; empty string converts to undefined

function prepareNotes(raw: string): string | undefined {
  const trimmed = raw.trim();
  return trimmed || undefined;
}

describe('EncounterPanel — notes preparation', () => {
  it('returns the trimmed string when non-empty', () => {
    expect(prepareNotes('  some notes  ')).toBe('some notes');
  });

  it('returns undefined when notes is empty string', () => {
    expect(prepareNotes('')).toBeUndefined();
  });

  it('returns undefined when notes is whitespace only', () => {
    expect(prepareNotes('   ')).toBeUndefined();
  });
});
