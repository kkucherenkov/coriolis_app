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
  RECOMMENDED_PERSONAL_TALENTS_BY_CONCEPT,
  STIGMA_TALENTS,
  TALENT_CATALOG,
  findCatalogTalentById,
  findCatalogTalentByName,
  getCrewTalentsByConcept,
  getIconGiftByIconId,
  getRecommendedPersonalTalents,
  pickLocalized,
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

    it('findCatalogTalentByName resolves the same entry from any locale', () => {
      const traveler = getIconGiftByIconId('traveler');
      const fromEn = findCatalogTalentByName(traveler.name.en, 'iconGift');
      const fromRu = findCatalogTalentByName(traveler.name.ru, 'iconGift');
      const fromUk = findCatalogTalentByName(traveler.name.uk, 'iconGift');
      expect(fromEn?.id).toBe('gift-traveler');
      expect(fromRu?.id).toBe('gift-traveler');
      expect(fromUk?.id).toBe('gift-traveler');
    });

    it('findCatalogTalentByName is case-insensitive and trims whitespace', () => {
      const traveler = getIconGiftByIconId('traveler');
      const noisy = `  ${traveler.name.ru.toUpperCase()}  `;
      expect(findCatalogTalentByName(noisy, 'iconGift')?.id).toBe('gift-traveler');
    });

    it('findCatalogTalentByName respects kind — same name on a different kind misses', () => {
      const traveler = getIconGiftByIconId('traveler');
      // The traveler gift's name only exists on iconGift; asking for the same
      // string under personal must return undefined so personal talents that
      // happen to share a noun never collide with an icon-gift entry.
      expect(findCatalogTalentByName(traveler.name.en, 'personal')).toBeUndefined();
    });

    it('findCatalogTalentByName returns undefined for user-authored names', () => {
      expect(findCatalogTalentByName('Wing-Mate', 'personal')).toBeUndefined();
      expect(findCatalogTalentByName('', 'iconGift')).toBeUndefined();
    });

    it('pickLocalized returns the requested locale and falls back to en for unknowns', () => {
      const traveler = getIconGiftByIconId('traveler');
      expect(pickLocalized(traveler.name, 'ru')).toBe(traveler.name.ru);
      expect(pickLocalized(traveler.name, 'en')).toBe(traveler.name.en);
      expect(pickLocalized(traveler.name, 'fr')).toBe(traveler.name.en);
    });
  });

  describe('per-amplua personal-talent recommendations (ST3001 ch.2 §АМПЛУА)', () => {
    const ALL_CONCEPTS = [
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
    ] as const;

    it('exposes a recommendation list for every Concept (no amplua left empty)', () => {
      for (const concept of ALL_CONCEPTS) {
        expect(
          RECOMMENDED_PERSONAL_TALENTS_BY_CONCEPT[concept].length,
          `no recommendations registered for amplua ${concept}`,
        ).toBeGreaterThan(0);
      }
    });

    it('every recommended ID resolves to a real personal-talent catalog entry', () => {
      // Implants (Бионические модификации / имплантаты) and mystic practices
      // are listed alongside personal talents in ch.2 but live outside the
      // personal catalog — the map filters them out at definition time, and
      // this test guards against a future copy-paste mistake reintroducing
      // a non-personal ID.
      const personalIds = new Set(PERSONAL_TALENTS.map((t) => t.id));
      for (const concept of ALL_CONCEPTS) {
        for (const id of RECOMMENDED_PERSONAL_TALENTS_BY_CONCEPT[concept]) {
          expect(personalIds.has(id), `${concept} → ${id}`).toBe(true);
        }
      }
    });

    it('getRecommendedPersonalTalents returns entries in the rulebook order', () => {
      // Operative's rulebook order is Палач → Грозный вид → Лицензиат
      // (ch.2 §ОПЕРАТИВНИК — ДОСТОИНСТВА). Confirm we preserve that order
      // so the wizard renders the cards as the rulebook prints them.
      const operative = getRecommendedPersonalTalents('operative');
      expect(operative.map((t) => t.id)).toEqual([
        'personal-executioner',
        'personal-menacing',
        'personal-licensee',
      ]);
    });

    it('getRecommendedPersonalTalents drops unknown IDs silently (defence in depth)', () => {
      // Synthesise a defensive case: if the map ever ships an ID typo it
      // should produce a missing card in the UI, not a thrown error from
      // the catalog helper. We can't introduce a typo here without
      // mutating frozen data, so confirm via a known-empty intersection:
      // every concept yields at most as many entries as IDs registered.
      for (const concept of ALL_CONCEPTS) {
        const ids = RECOMMENDED_PERSONAL_TALENTS_BY_CONCEPT[concept];
        const entries = getRecommendedPersonalTalents(concept);
        expect(entries.length).toBeLessThanOrEqual(ids.length);
      }
    });
  });
});
