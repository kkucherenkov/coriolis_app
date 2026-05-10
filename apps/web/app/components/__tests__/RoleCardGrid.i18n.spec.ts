import { describe, it, expect } from 'vitest';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { CONCEPT_ROLES } from '../../utils/roleCatalogue';

const here = path.dirname(fileURLToPath(import.meta.url));
const gridSfc = readFileSync(
  path.resolve(here, '..', 'RoleCardGrid.vue'),
  'utf8',
);

function extractI18nBlock(source: string, locale: string): Record<string, unknown> {
  const i18nMatch = source.match(/<i18n[^>]*>([\s\S]*?)<\/i18n>/);
  if (!i18nMatch?.[1]) {
    throw new Error('RoleCardGrid.vue: <i18n> block not found');
  }
  const json = JSON.parse(i18nMatch[1]) as Record<string, Record<string, unknown>>;
  if (!json[locale]) {
    throw new Error(`RoleCardGrid.vue: locale "${locale}" missing`);
  }
  return json[locale];
}

function flatten(obj: Record<string, unknown>, prefix = ''): Record<string, string> {
  const out: Record<string, string> = {};
  for (const [k, v] of Object.entries(obj)) {
    const key = prefix ? `${prefix}.${k}` : k;
    if (v && typeof v === 'object' && !Array.isArray(v)) {
      Object.assign(out, flatten(v as Record<string, unknown>, key));
    } else if (typeof v === 'string') {
      out[key] = v;
    }
  }
  return out;
}

describe('RoleCardGrid i18n completeness', () => {
  const en = flatten(extractI18nBlock(gridSfc, 'en'));
  const ru = flatten(extractI18nBlock(gridSfc, 'ru'));

  const allRoles = Object.values(CONCEPT_ROLES).flat();

  it('exposes a label for every canonical role in en', () => {
    for (const role of allRoles) {
      expect(en[`role.${role}.label`], `en role.${role}.label`).toBeTruthy();
    }
  });

  it('exposes a label for every canonical role in ru', () => {
    for (const role of allRoles) {
      expect(ru[`role.${role}.label`], `ru role.${role}.label`).toBeTruthy();
    }
  });

  it('exposes a flavour for every canonical role in en', () => {
    for (const role of allRoles) {
      expect(en[`role.${role}.flavour`], `en role.${role}.flavour`).toBeTruthy();
    }
  });

  it('exposes a flavour for every canonical role in ru', () => {
    for (const role of allRoles) {
      expect(ru[`role.${role}.flavour`], `ru role.${role}.flavour`).toBeTruthy();
    }
  });

  it('every en key has a matching ru key (no orphan translations)', () => {
    const orphans = Object.keys(en).filter((k) => !(k in ru));
    expect(orphans).toEqual([]);
  });

  it('ru role labels carry Cyrillic characters (no English bleed)', () => {
    for (const role of allRoles) {
      const label = ru[`role.${role}.label`];
      expect(label, `ru role.${role}.label`).toBeTruthy();
      expect(/[А-Яа-яЁё]/.test(label!), `ru role.${role}.label "${label!}" must be Cyrillic`).toBe(
        true,
      );
    }
  });

  it('en role labels are ASCII / Latin (no leftover Cyrillic)', () => {
    for (const role of allRoles) {
      const label = en[`role.${role}.label`];
      expect(label, `en role.${role}.label`).toBeTruthy();
      expect(
        /[А-Яа-яЁё]/.test(label!),
        `en role.${role}.label "${label!}" should not be Cyrillic`,
      ).toBe(false);
    }
  });

  it('the canonical Russian display names from ГЛАВА 2 are wired correctly', () => {
    // Sanity-check a sample: if these drift, the rulebook citation is broken.
    expect(ru['role.companion.label']).toBe('Компаньон');
    expect(ru['role.driver.label']).toBe('Водитель');
    expect(ru['role.legionnaire.label']).toBe('Легионер');
    expect(ru['role.network-djinn.label']).toBe('Сетевой джинн');
    expect(ru['role.medicurg.label']).toBe('Медикург');
  });
});
