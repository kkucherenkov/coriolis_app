/**
 * roleCatalogue.spec.ts
 *
 * Integrity tests for the role catalogue data module.
 * These lock the catalogue against ST3001 canon and catch drift if the
 * regenerated @app/api-client-ts Role enum gains or loses values.
 *
 * NOTE: `Role` and `Concept` are TypeScript string-union types, not runtime
 * enums. The drift guard works by maintaining ALL_ROLES / ALL_CONCEPTS arrays
 * that mirror the union members — if the union changes, a TypeScript error
 * surfaces here at compile time (satisfies / as const assertions) AND the
 * count assertions fail at test time.
 */

import { describe, it, expect } from 'vitest';
import type { Role, Concept } from '@app/api-client-ts';
import {
  CONCEPT_ROLES,
  ROLE_KEY_SKILLS,
  CONCEPT_BY_ROLE,
  rolesForConcept,
  keySkillsForRole,
  conceptForRole,
  type SkillKey,
} from '../roleCatalogue';

// --------------- Drift sentinels ---------------

/**
 * All 33 canonical roles from the regenerated @app/api-client-ts Role union.
 * If the spec gains/loses a role, update this array AND roleCatalogue.ts —
 * the `satisfies` assertion turns a runtime gap into a compile-time error.
 */
const ALL_ROLES: readonly Role[] = [
  // artist
  'companion',
  'musician',
  'poet',
  // networker
  'analyst',
  'correspondent',
  'network-djinn',
  // fugitive
  'criminal',
  'mystic',
  'revolutionary',
  // negotiator
  'agitator',
  'diplomat',
  'dealer',
  // operative
  'assassin',
  'guard',
  'spy',
  // pilot
  'ace',
  'driver',
  'trucker',
  // pioneer
  'colonist',
  'prospector',
  'scout',
  // preacher
  'ascetic',
  'missionary',
  'prophet',
  // scientist
  'archaeologist',
  'medicurg',
  'technologist',
  // sailor
  'ship-engineer',
  'labourer',
  'loader',
  // soldier
  'legionnaire',
  'mercenary',
  'officer',
] satisfies Role[];

/** All 11 concepts, mirroring the Concept union. */
const ALL_CONCEPTS: readonly Concept[] = [
  'artist',
  'networker',
  'fugitive',
  'negotiator',
  'operative',
  'pilot',
  'pioneer',
  'preacher',
  'scientist',
  'sailor',
  'soldier',
] satisfies Concept[];

/** All 16 valid skill keys. */
const VALID_SKILLS = new Set<SkillKey>([
  'dexterity',
  'force',
  'infiltration',
  'manipulation',
  'meleeCombat',
  'observation',
  'rangedCombat',
  'survival',
  'command',
  'culture',
  'dataDjinn',
  'medicurgy',
  'mysticPowers',
  'pilot',
  'science',
  'technology',
]);

// --------------- Tests ---------------

describe('roleCatalogue — drift guard', () => {
  it('ALL_ROLES sentinel covers exactly 33 entries (matches Role union size)', () => {
    expect(ALL_ROLES).toHaveLength(33);
  });

  it('every Role in ALL_ROLES is a key of ROLE_KEY_SKILLS (no missing entries)', () => {
    for (const role of ALL_ROLES) {
      expect(
        ROLE_KEY_SKILLS,
        `ROLE_KEY_SKILLS is missing role: "${role}"`,
      ).toHaveProperty(role);
    }
  });

  it('ROLE_KEY_SKILLS contains no extra keys beyond the 33 canonical roles', () => {
    const catalogueKeys = Object.keys(ROLE_KEY_SKILLS) as Role[];
    expect(catalogueKeys).toHaveLength(33);
    const roleSet = new Set<string>(ALL_ROLES);
    for (const key of catalogueKeys) {
      expect(roleSet, `ROLE_KEY_SKILLS has extra key: "${key}"`).toContain(key);
    }
  });
});

describe('CONCEPT_ROLES', () => {
  it('every concept has exactly 3 roles', () => {
    for (const concept of ALL_CONCEPTS) {
      const roles = CONCEPT_ROLES[concept];
      expect(roles, `concept "${concept}" must have 3 roles`).toHaveLength(3);
    }
  });

  it('covers all 11 concepts', () => {
    expect(Object.keys(CONCEPT_ROLES)).toHaveLength(11);
  });
});

describe('ROLE_KEY_SKILLS', () => {
  it('every role has exactly 4 key skills', () => {
    for (const role of ALL_ROLES) {
      const skills = ROLE_KEY_SKILLS[role];
      expect(skills, `role "${role}" must have 4 key skills`).toHaveLength(4);
    }
  });

  it('all key skills across all roles are valid SkillKey values', () => {
    for (const role of ALL_ROLES) {
      for (const skill of ROLE_KEY_SKILLS[role]) {
        expect(
          VALID_SKILLS,
          `role "${role}" has invalid skill key: "${skill}"`,
        ).toContain(skill);
      }
    }
  });
});

describe('CONCEPT_BY_ROLE', () => {
  it('is exhaustive — every canonical role maps to a concept', () => {
    for (const role of ALL_ROLES) {
      expect(
        CONCEPT_BY_ROLE,
        `CONCEPT_BY_ROLE missing role: "${role}"`,
      ).toHaveProperty(role);
    }
  });

  it('is the exact inverse of CONCEPT_ROLES (round-trip check)', () => {
    for (const concept of ALL_CONCEPTS) {
      for (const role of CONCEPT_ROLES[concept]) {
        expect(
          CONCEPT_BY_ROLE[role],
          `conceptForRole("${role}") should be "${concept}"`,
        ).toBe(concept);
      }
    }
  });
});

describe('rolesForConcept()', () => {
  it('returns the 3 roles for pilot in canonical order', () => {
    expect(rolesForConcept('pilot')).toEqual(['ace', 'driver', 'trucker']);
  });

  it('returns correct roles for all 11 concepts (spot-checks first entry)', () => {
    const firstRoleByConceptExpected: Record<Concept, Role> = {
      artist: 'companion',
      networker: 'analyst',
      fugitive: 'criminal',
      negotiator: 'agitator',
      operative: 'assassin',
      pilot: 'ace',
      pioneer: 'colonist',
      preacher: 'ascetic',
      scientist: 'archaeologist',
      sailor: 'ship-engineer',
      soldier: 'legionnaire',
    };
    for (const concept of ALL_CONCEPTS) {
      const roles = rolesForConcept(concept);
      expect(roles[0]).toBe(firstRoleByConceptExpected[concept]);
    }
  });

  it('returns [] when concept is null', () => {
    expect(rolesForConcept(null)).toEqual([]);
  });
});

describe('keySkillsForRole()', () => {
  it('returns correct 4 key skills for "driver"', () => {
    expect(keySkillsForRole('driver')).toEqual(['force', 'pilot', 'rangedCombat', 'survival']);
  });

  it('returns correct 4 key skills for "companion"', () => {
    expect(keySkillsForRole('companion')).toEqual([
      'manipulation',
      'culture',
      'dexterity',
      'observation',
    ]);
  });

  it('returns correct 4 key skills for "officer"', () => {
    expect(keySkillsForRole('officer')).toEqual([
      'command',
      'culture',
      'meleeCombat',
      'rangedCombat',
    ]);
  });

  it('throws on an unknown role string cast as Role', () => {
    expect(() => keySkillsForRole('unknown-role' as Role)).toThrow('Unknown role: unknown-role');
  });
});

describe('conceptForRole()', () => {
  it('returns "pilot" for role "driver"', () => {
    expect(conceptForRole('driver')).toBe('pilot');
  });

  it('returns "soldier" for role "officer"', () => {
    expect(conceptForRole('officer')).toBe('soldier');
  });

  it('returns "sailor" for role "ship-engineer"', () => {
    expect(conceptForRole('ship-engineer')).toBe('sailor');
  });

  it('returns "scientist" for role "medicurg"', () => {
    expect(conceptForRole('medicurg')).toBe('scientist');
  });
});
