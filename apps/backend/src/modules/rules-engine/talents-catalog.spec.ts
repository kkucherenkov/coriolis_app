/**
 * Catalog shape assertions for the talent data exported from `@app/specs`.
 * Backend hosts the spec because `apps/backend` already wires Vitest and
 * imports the catalog directly via the `@app/specs` workspace alias.
 */
import { describe, expect, it } from 'vitest';
import {
  CREW_TALENTS,
  ICON_GIFTS,
  PERSONAL_TALENTS,
  STIGMA_TALENTS,
  TALENT_CATALOG,
  findCatalogTalentById,
  getCrewTalentsByConcept,
  getIconGiftByIconId,
} from '@app/specs';

const ICON_IDS = [
  'lady-of-tears',
  'traveler',
  'messenger',
  'merchant',
  'dancer',
  'gambler',
  'judge',
  'faceless-one',
  'deckhand',
] as const;

const CREW_CONCEPTS = ['free-trader', 'mercenary', 'explorer', 'agents', 'pilgrim'] as const;

describe('talent catalog (@app/specs)', () => {
  it('exports exactly nine icon gifts (ST3001 ch.4 §Дары Ликов)', () => {
    expect(ICON_GIFTS.length).toBe(9);
  });

  it('icon gifts cover every IconId exactly once', () => {
    const iconIds = ICON_GIFTS.map((g) => g.iconId).toSorted();
    expect(iconIds).toEqual([...ICON_IDS].toSorted());
  });

  it('every icon-gift entry uses the canonical kebab-case `gift-{iconId}` ID', () => {
    for (const gift of ICON_GIFTS) {
      expect(gift.id).toBe(`gift-${gift.iconId}`);
      expect(gift.kind).toBe('iconGift');
    }
  });

  it('exports exactly fifteen crew talents (5 amplua × 3, ST3001 ch.4 §Достоинства команды)', () => {
    expect(CREW_TALENTS.length).toBe(15);
  });

  it('every crew amplua receives exactly three talents', () => {
    for (const amplua of CREW_CONCEPTS) {
      const talents = getCrewTalentsByConcept(amplua);
      expect(talents.length, `amplua=${amplua}`).toBe(3);
      expect(talents.every((t) => t.crewConcept === amplua)).toBe(true);
    }
  });

  it('exports the personal-talent pool (ST3001 ch.4 §Личные достоинства)', () => {
    expect(PERSONAL_TALENTS.length).toBeGreaterThanOrEqual(26);
    expect(PERSONAL_TALENTS.every((t) => t.kind === 'personal')).toBe(true);
  });

  it('exports the three pasynok stigmas (ST3001 ch.4 §Стигмы пасынков)', () => {
    expect(STIGMA_TALENTS.length).toBe(3);
    expect(STIGMA_TALENTS.every((t) => t.kind === 'stigma')).toBe(true);
  });

  it('every catalog ID is unique', () => {
    const ids = TALENT_CATALOG.map((t) => t.id);
    expect(new Set(ids).size).toBe(ids.length);
  });

  it('every entry carries non-empty en + ru localisations', () => {
    for (const entry of TALENT_CATALOG) {
      expect(entry.name.en.length, `name.en for ${entry.id}`).toBeGreaterThan(0);
      expect(entry.name.ru.length, `name.ru for ${entry.id}`).toBeGreaterThan(0);
      expect(entry.description.en.length, `description.en for ${entry.id}`).toBeGreaterThan(0);
      expect(entry.description.ru.length, `description.ru for ${entry.id}`).toBeGreaterThan(0);
    }
  });

  it('uk + el locales carry the agreed [uk-todo]/[el-todo] placeholder marker', () => {
    for (const entry of TALENT_CATALOG) {
      expect(entry.name.uk, `name.uk for ${entry.id}`).toContain('[uk-todo]');
      expect(entry.name.el, `name.el for ${entry.id}`).toContain('[el-todo]');
      expect(entry.description.uk, `description.uk for ${entry.id}`).toContain('[uk-todo]');
      expect(entry.description.el, `description.el for ${entry.id}`).toContain('[el-todo]');
    }
  });

  it('every rankCap is between 1 and 3 inclusive', () => {
    for (const entry of TALENT_CATALOG) {
      expect(entry.rankCap, `rankCap for ${entry.id}`).toBeGreaterThanOrEqual(1);
      expect(entry.rankCap, `rankCap for ${entry.id}`).toBeLessThanOrEqual(3);
    }
  });

  describe('helpers', () => {
    it('findCatalogTalentById returns the entry when present', () => {
      const entry = findCatalogTalentById('gift-traveler');
      expect(entry?.kind).toBe('iconGift');
      expect(entry?.id).toBe('gift-traveler');
    });

    it('findCatalogTalentById returns undefined for unknown IDs (custom user talents)', () => {
      expect(findCatalogTalentById('totally-custom-talent')).toBeUndefined();
    });

    it('getIconGiftByIconId resolves every IconId to a gift entry', () => {
      for (const iconId of ICON_IDS) {
        const gift = getIconGiftByIconId(iconId);
        expect(gift.iconId).toBe(iconId);
      }
    });
  });
});
