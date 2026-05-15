/**
 * Coriolis ST3001 — starter-kit catalogue (per amplua + role).
 *
 * Single source of truth for the wizard Step 8 (Gear) picker. Both
 * `apps/web` and `apps/mobile` consume this module via the `@app/specs`
 * workspace barrel and drive the per-amplua picker locally — the
 * backend stays unaware of the catalogue and only sees individual
 * `POST /api/v1/characters/{id}/items` requests for each chosen item.
 *
 * ## Architectural decision (T-WIZARD-GEAR-BACKEND-DERIVE)
 *
 * We chose **option (b)** from the open question in
 * `specs/design/CHARACTER_WIZARD.md` §3.8: the client renders the
 * per-amplua picker reading this static catalogue. The alternative —
 * server-computed starter packs on activation — was rejected for v1
 * because:
 *
 *   1. Coriolis starter kits are tied to the printed rulebook (ST3001).
 *      They change at the cadence of game printings, not deploys.
 *   2. Server-side derivation would need a seeded `starter_kit` table,
 *      a migration to populate it, and an admin tool to keep it in sync
 *      with the rulebook. That's a lot of plumbing for static content.
 *   3. The wizard flow is per-character: a single player POSTing 5-8
 *      items at activation is well within the existing items API. No
 *      new endpoint is needed.
 *   4. Client-side rendering keeps the catalogue free to evolve (item
 *      copy tweaks, localisations) without backend release cycles.
 *
 * Trade-offs accepted:
 *
 *   - **No server-side validation** that the player picked "canonical"
 *     items — the wizard UX is the gate. A future hardening pass can
 *     add an optional `Character.starterKitFingerprint` field that the
 *     server stores for audit + reproducibility.
 *   - **Three client embeddings** (web TS, mobile Dart, dart codegen
 *     for the SDK) all need the same source. Mobile reads the catalogue
 *     via a generated Dart constants file produced from this TS module
 *     in a follow-up bundler step.
 *
 * ## Data sourcing
 *
 * Catalogue populated from ST3001 ГЛАВА 2 «Персонажи игроков»
 * (Russian translation, canonical source — see memory pointer
 * `coriolis-rulebook-ru`). Each amplua's СНАРЯЖЕНИЕ table is verbatim:
 * 5 rows, 2 alternatives each, player picks one per row. All three
 * roles within an amplua share the same gear table — roles only
 * differentiate skills/talents/narrative, not starting equipment.
 *
 * ## Catalogue shape
 *
 * Each (concept, role) pair maps to a `StarterKit` with:
 *
 *   - `fixed[]` — items every character of that kit receives
 *     unconditionally. Empty for every Coriolis amplua: ST3001 has no
 *     unconditional starting items; everything is a choice.
 *   - `choices[]` — choice groups in canonical rulebook order. Each
 *     group has 1+ `options[]`; the player picks exactly one.
 *
 * `StarterKitItem.itemTemplate` is a partial `ItemCreate` body that
 * the wizard wraps in the appropriate `ItemCreate` discriminator
 * (weapon / armor / gear / cybernetic / other) before POSTing.
 */
import type { components } from './openapi-types.js';

import type { CatalogLocale, LocalizedString } from './talents.js';
export type { CatalogLocale, LocalizedString } from './talents.js';

type Concept = components['schemas']['Concept'];
type Role = components['schemas']['Role'];

/** Discriminator value for the wire-form `ItemCreate` one-of branch. */
export type StarterKitItemKind = 'WEAPON' | 'ARMOR' | 'GEAR' | 'CYBERNETIC' | 'OTHER';

/**
 * Shape-shape: a partial `ItemCreate` body the wizard POSTs per pick.
 *
 * The wizard hydrates the missing fields (per discriminator) at
 * activation time. We deliberately keep this type loose — strongly
 * typing per-discriminator at the catalogue layer would tie us to the
 * one-of generator output and trip on every spec regen.
 */
export interface StarterKitItemTemplate {
  readonly kind: StarterKitItemKind;
  /**
   * Display + persistence name. The wizard does NOT localise on the
   * wire — `Item.name` is the source of truth across locales — so the
   * picker shows `name[locale]` but POSTs the user's UI locale value
   * as-is.
   */
  readonly name: LocalizedString;
  /**
   * Optional partial of the per-discriminator fields. The wizard knows
   * the full schema (via the SDK) and fills the rest with safe
   * defaults (e.g. `equipped: false`, `quantity: 1`).
   */
  readonly fields?: Readonly<Record<string, unknown>>;
}

export interface StarterKitItem {
  /** Stable kebab-case id; used for test selectors + i18n + telemetry. */
  readonly id: string;
  readonly template: StarterKitItemTemplate;
}

export interface StarterKitChoice {
  /** Stable kebab-case id within the kit (e.g. `sidearm`, `outfit`). */
  readonly id: string;
  readonly label: LocalizedString;
  readonly options: readonly StarterKitItem[];
  /**
   * Optional: number of items the player picks from this group. Defaults
   * to 1. Some ST3001 rows allow multi-pick (e.g. "choose two utility
   * items").
   */
  readonly pickCount?: number;
}

export interface StarterKit {
  readonly concept: Concept;
  readonly role: Role;
  /** Items every character of this kit receives (no choice). */
  readonly fixed: readonly StarterKitItem[];
  /** Choice groups in rulebook order; the player picks per group. */
  readonly choices: readonly StarterKitChoice[];
}

// ── Internal builders ────────────────────────────────────────────────────────

/** Templated kit shared by all three roles of an amplua. */
interface AmpluaKitTemplate {
  readonly fixed: readonly StarterKitItem[];
  readonly choices: readonly StarterKitChoice[];
}

function rowLabel(n: number): LocalizedString {
  const s = String(n);
  return {
    en: `Row ${s}`,
    ru: `Ряд ${s}`,
    uk: `[uk-todo] Row ${s}`,
    el: `[el-todo] Row ${s}`,
  };
}

function withTodo(en: string, ru: string): LocalizedString {
  return {
    en,
    ru,
    uk: `[uk-todo] ${en}`,
    el: `[el-todo] ${en}`,
  };
}

function item(id: string, kind: StarterKitItemKind, en: string, ru: string): StarterKitItem {
  return { id, template: { kind, name: withTodo(en, ru) } };
}

function row(n: number, options: readonly StarterKitItem[]): StarterKitChoice {
  return {
    id: `row-${String(n)}`,
    label: rowLabel(n),
    options,
  };
}

// ── ST3001 ГЛАВА 2 amplua kits ───────────────────────────────────────────────
//
// Source-of-truth: `/Users/kkucherenkov/Documents/vaults/obsidian/70.01
// Areas/TRPG/Coriolis/ST3001/ГЛАВА 2 Персонажи игроков.md` (per-amplua
// «СНАРЯЖЕНИЕ» tables). Each amplua has a 5-row table; the table is
// shared by all three of the amplua's roles.

const KIT_ARTIST: AmpluaKitTemplate = {
  fixed: [],
  choices: [
    row(1, [
      item('alam-fan', 'OTHER', 'Hand fan of Alam', 'Веер Алама'),
      item('tabula', 'GEAR', 'Tabula', 'Табула'),
    ]),
    row(2, [
      item('opor', 'OTHER', 'Opor', 'Опор'),
      item('sensor-analyzer', 'GEAR', 'Sensor analyzer', 'Сенсорный анализатор'),
    ]),
    row(3, [
      item('luxury-outfit', 'GEAR', 'Luxury outfit', 'Роскошный наряд'),
      item('musical-instrument', 'GEAR', 'Musical instrument', 'Музыкальный инструмент'),
    ]),
    row(4, [
      item(
        'beautiful-appearance-biomod',
        'CYBERNETIC',
        'Beautiful appearance (biomod)',
        'Прекрасная внешность (мод.)',
      ),
      item('rare-poetry-collection', 'OTHER', 'Collection of rare poetry', 'Сборник редких стихов'),
    ]),
    row(5, [
      item('memoirs-meizelmann', 'OTHER', '“Memoirs” by Meizelmann', '«Мемуары» Мейзельмана'),
      item(
        'alkamaar-restaurant-card',
        'OTHER',
        'Regular customer card at Alkamaar restaurant',
        'Карта постоянного клиента ресторана «Алькамаар»',
      ),
    ]),
  ],
};

const KIT_NETWORKER: AmpluaKitTemplate = {
  fixed: [],
  choices: [
    row(1, [
      item('comlink-iv', 'GEAR', 'Comlink (IV)', 'Коммуникатор (IV)'),
      item('holograph-i', 'GEAR', 'Holograph (I)', 'Голограф (I)'),
    ]),
    row(2, [
      item('broadband-sensor', 'GEAR', 'Broadband sensor', 'Широкополосный сенсор'),
      item('computer-s', 'GEAR', 'Computer (S)', 'Компьютер (С)'),
    ]),
    row(3, [
      item('pocket-vulcan-pistol', 'WEAPON', 'Pocket Vulcan pistol', 'Карманный вулкан-пистолет'),
      item('neuroshock-stun', 'WEAPON', 'Neuroshocker', 'Нейрошокер'),
    ]),
    row(4, [
      item('tabula', 'GEAR', 'Tabula', 'Табула'),
      item(
        'transactor-1000-birr',
        'GEAR',
        'Transactor with 1000 birr',
        'Транзактор с 1000 бирров на счету',
      ),
    ]),
    row(5, [item('opor', 'OTHER', 'Opor', 'Опор'), item('arrash', 'OTHER', 'Arrash', 'Арраш')]),
  ],
};

const KIT_FUGITIVE: AmpluaKitTemplate = {
  fixed: [],
  choices: [
    row(1, [
      item('anonymous-clothing', 'GEAR', 'Anonymous clothing', 'Обезличивающая одежда'),
      item('birr-chip-500', 'GEAR', 'Birr-chip with 500 birr', 'Бирка с 500 бирров'),
    ]),
    row(2, [
      item('comlink-ii', 'GEAR', 'Comlink (II)', 'Коммуникатор (II)'),
      item('protective-clothing', 'ARMOR', 'Protective clothing', 'Защитная одежда'),
    ]),
    row(3, [
      item('vulcan-carbine', 'WEAPON', 'Vulcan carbine', 'Вулкан-карабин'),
      item('vibro-sword', 'WEAPON', 'Vibro sword', 'Вибромеч'),
    ]),
    row(4, [
      item('thermal-suit', 'ARMOR', 'Thermal suit', 'Термостатический комбинезон'),
      item('vacsuit', 'ARMOR', 'Vacsuit', 'Экзоскафандр'),
    ]),
    row(5, [
      item(
        'transactor-fake-id',
        'GEAR',
        'Transactor with forged ID',
        'Транзактор с фальшивым удостоверением личности',
      ),
      item('mask', 'GEAR', 'Mask', 'Маска'),
    ]),
  ],
};

const KIT_NEGOTIATOR: AmpluaKitTemplate = {
  fixed: [],
  choices: [
    row(1, [
      item('tabula', 'GEAR', 'Tabula', 'Табула'),
      item('interpreter-implant', 'CYBERNETIC', 'Interpreter (implant)', 'Интерпретатор (имп.)'),
    ]),
    row(2, [
      item('comlink-v', 'GEAR', 'Comlink (V)', 'Коммуникатор (V)'),
      item('megaphone', 'GEAR', 'Megaphone', 'Громкоговоритель'),
    ]),
    row(3, [
      item('luxury-outfit', 'GEAR', 'Luxury outfit', 'Роскошный наряд'),
      item('kamra-d6-doses', 'OTHER', 'Kamra (d6 doses)', 'Камбра (d6 доз)'),
    ]),
    row(4, [
      item('lie-detector-implant', 'CYBERNETIC', 'Lie detector (implant)', 'Детектор лжи (имп.)'),
      item('auto-translator', 'GEAR', 'Auto-translator', 'Автоматический переводчик'),
    ]),
    row(5, [
      item('pocket-vulcan-pistol', 'WEAPON', 'Pocket Vulcan pistol', 'Карманный вулкан-пистолет'),
      item('mercury-knife', 'WEAPON', 'Mercury knife', 'Ртутный нож'),
    ]),
  ],
};

const KIT_OPERATIVE: AmpluaKitTemplate = {
  fixed: [],
  choices: [
    row(1, [
      item('pocket-vulcan-pistol', 'WEAPON', 'Pocket Vulcan pistol', 'Карманный вулкан-пистолет'),
      item(
        'advanced-melee-weapon',
        'WEAPON',
        'Advanced melee weapon',
        'Передовое оружие ближнего боя',
      ),
    ]),
    row(2, [
      item('broadband-sensor', 'GEAR', 'Broadband sensor', 'Широкополосный сенсор'),
      item('computer-s', 'GEAR', 'Computer (S)', 'Компьютер (С)'),
    ]),
    row(3, [
      item('modulating-mask', 'GEAR', 'Modulating mask', 'Модулирующая маска'),
      item('mechanical-lockpick', 'GEAR', 'Mechanical lockpick', 'Механическая отмычка'),
    ]),
    row(4, [
      item('recon-probe', 'GEAR', 'Recon probe', 'Разведзонд'),
      item('fake-id-set', 'GEAR', 'Set of forged IDs', 'Набор фальшивых удостоверений личности'),
    ]),
    row(5, [
      item('electronic-lockpick', 'GEAR', 'Electronic lockpick', 'Электронная отмычка'),
      item('poison-5-doses', 'OTHER', 'Poison (5 doses)', 'Яд (5 доз)'),
    ]),
  ],
};

const KIT_PILOT: AmpluaKitTemplate = {
  fixed: [],
  choices: [
    row(1, [
      item('tool-kit-s', 'GEAR', 'Tool kit (S)', 'Набор инструментов (С)'),
      item('piloting-talisman', 'OTHER', 'Piloting talisman', 'Талисман пилотирования'),
    ]),
    row(2, [
      item('vacsuit', 'ARMOR', 'Vacsuit', 'Экзоскафандр'),
      item(
        'manual-maneuvering-unit',
        'GEAR',
        'Manual maneuvering unit',
        'Ручной маневровый двигатель',
      ),
    ]),
    row(3, [
      item(
        'targeting-reticle-implant',
        'CYBERNETIC',
        'Targeting reticle (implant)',
        'Целеуказатель (имп.)',
      ),
      item('comlink-iv', 'GEAR', 'Comlink (IV)', 'Коммуникатор (IV)'),
    ]),
    row(4, [
      item('rail-pistol', 'WEAPON', 'Rail pistol', 'Рельсовый пистолет'),
      item('neuroshock-stun', 'WEAPON', 'Neuroshocker', 'Нейрошокер'),
    ]),
    row(5, [
      item('flight-suit', 'ARMOR', 'Flight suit', 'Лётный комбинезон'),
      item('luxury-outfit', 'GEAR', 'Luxury outfit', 'Роскошный наряд'),
    ]),
  ],
};

const KIT_PREACHER: AmpluaKitTemplate = {
  fixed: [],
  choices: [
    row(1, [
      item('holy-scriptures', 'OTHER', 'Holy scriptures', 'Священные писания'),
      item('censer', 'OTHER', 'Censer', 'Кадило'),
    ]),
    row(2, [
      item('talisman-any', 'OTHER', 'Talisman (any)', 'Талисман (любой)'),
      item('ritual-robes', 'GEAR', 'Ritual robes', 'Ритуальное облачение'),
    ]),
    row(3, [
      item('reliquary', 'OTHER', 'Reliquary', 'Реликварий'),
      item('prophecy-scrolls', 'OTHER', 'Prophecy scrolls', 'Рукописи с пророчествами'),
    ]),
    row(4, [
      item('m-stims-5', 'GEAR', '5 Medi-stims', '5 м-стимов'),
      item(
        'blessed-herbs-10',
        'OTHER',
        '10 doses of blessed healing herbs',
        '10 порций освящённых целебных трав',
      ),
    ]),
    row(5, [
      item('tabula', 'GEAR', 'Tabula', 'Табула'),
      item('writing-kit', 'GEAR', 'Writing kit', 'Писчие принадлежности'),
    ]),
  ],
};

const KIT_SCIENTIST: AmpluaKitTemplate = {
  fixed: [],
  choices: [
    row(1, [
      item('comlink-iii', 'GEAR', 'Comlink (III)', 'Коммуникатор (III)'),
      item('broadband-sensor', 'GEAR', 'Broadband sensor', 'Широкополосный сенсор'),
    ]),
    row(2, [
      item('portable-lab', 'GEAR', 'Portable lab', 'Портативная лаборатория'),
      item('computer-s', 'GEAR', 'Computer (S)', 'Компьютер (С)'),
    ]),
    row(3, [
      item('vacsuit', 'ARMOR', 'Vacsuit', 'Экзоскафандр'),
      item('data-library', 'GEAR', 'Data library', 'Электронная библиотека'),
    ]),
    row(4, [
      item('pressure-tent', 'GEAR', 'Pressure tent', 'Герметичный шатёр'),
      item('med-kit', 'GEAR', 'Med-kit', 'М-комплект'),
    ]),
    row(5, [
      item('tool-kit-p', 'GEAR', 'Tool kit (P)', 'Набор инструментов (П)'),
      item('compass', 'GEAR', 'Compass', 'Компас'),
    ]),
  ],
};

const KIT_SAILOR: AmpluaKitTemplate = {
  fixed: [],
  choices: [
    row(1, [
      item('tool-kit-s', 'GEAR', 'Tool kit (S)', 'Набор инструментов (С)'),
      item('sealant', 'GEAR', 'Sealant', 'Герметик'),
    ]),
    row(2, [
      item('power-knuckles', 'WEAPON', 'Power knuckles', 'Силовой кастет'),
      item('sensor-analyzer', 'GEAR', 'Sensor analyzer', 'Сенсорный анализатор'),
    ]),
    row(3, [
      item('arrash', 'OTHER', 'Arrash', 'Арраш'),
      item('tobacco', 'OTHER', 'Tobacco', 'Табак'),
    ]),
    row(4, [
      item('exo-loader', 'GEAR', 'Exo-loader', 'Экзопогрузчик'),
      item('vacsuit', 'ARMOR', 'Vacsuit', 'Экзоскафандр'),
    ]),
    row(5, [
      item('hyper-cable', 'GEAR', 'Hyper-cable', 'Гипертрос'),
      item('vibro-knife', 'WEAPON', 'Vibro knife', 'Вибронож'),
    ]),
  ],
};

const KIT_SOLDIER: AmpluaKitTemplate = {
  fixed: [],
  choices: [
    row(1, [
      item('heavy-armor', 'ARMOR', 'Heavy armor', 'Тяжёлая броня'),
      item('mercury-sword', 'WEAPON', 'Mercury sword', 'Ртутный меч'),
    ]),
    row(2, [
      item(
        'rail-pistol-sensor-sight-s',
        'WEAPON',
        'Rail pistol with sensor sight (S)',
        'Рельсовый пистолет с сенсорным прицелом (С)',
      ),
      item('vulcan-carbine', 'WEAPON', 'Vulcan carbine', 'Вулкан-карабин'),
    ]),
    row(3, [
      item('frag-grenade', 'WEAPON', 'Frag grenade', 'Осколочная граната'),
      item(
        'reinforced-muscles-implant',
        'CYBERNETIC',
        'Reinforced muscles (implant)',
        'Усиленные мышцы (имп.)',
      ),
    ]),
    row(4, [
      item('officer-pad', 'GEAR', 'Officer pad', 'Командирский планшет'),
      item('sensor-sight-p', 'GEAR', 'Sensor sight (P)', 'Сенсорный прицел (П)'),
    ]),
    row(5, [
      item('comlink-ii', 'GEAR', 'Comlink (II)', 'Коммуникатор (II)'),
      item('med-kit', 'GEAR', 'Med-kit', 'М-комплект'),
    ]),
  ],
};

const KIT_PIONEER: AmpluaKitTemplate = {
  fixed: [],
  choices: [
    row(1, [
      item('drone-uav', 'GEAR', 'UAV drone', 'БПЛА'),
      item('comlink-v', 'GEAR', 'Comlink (V)', 'Коммуникатор (V)'),
    ]),
    row(2, [
      item('vibro-axe', 'WEAPON', 'Vibro axe', 'Вибросекира'),
      item('vulcan-carbine', 'WEAPON', 'Vulcan carbine', 'Вулкан-карабин'),
    ]),
    row(3, [
      item('m-stims-5', 'GEAR', '5 Medi-stims', '5 м-стимов'),
      item('data-library', 'GEAR', 'Data library', 'Электронная библиотека'),
    ]),
    row(4, [
      item(
        'optimized-metabolism-implant',
        'CYBERNETIC',
        'Optimized metabolism (implant)',
        'Оптимизированный метаболизм (имп.)',
      ),
      item('vacsuit', 'ARMOR', 'Vacsuit', 'Экзоскафандр'),
    ]),
    row(5, [
      item('sensor-analyzer', 'GEAR', 'Sensor analyzer', 'Сенсорный анализатор'),
      item('compass', 'GEAR', 'Compass', 'Компас'),
    ]),
  ],
};

// ── (concept, roles) → 33 kits expansion ─────────────────────────────────────
//
// Roles within an amplua share the same gear table (per ST3001 ch.2);
// we expand once per role for direct `(concept, role)` lookup.

const AMPLUA_KITS: readonly {
  readonly concept: Concept;
  readonly roles: readonly Role[];
  readonly template: AmpluaKitTemplate;
}[] = [
  { concept: 'artist', roles: ['companion', 'musician', 'poet'], template: KIT_ARTIST },
  {
    concept: 'networker',
    roles: ['analyst', 'correspondent', 'network-djinn'],
    template: KIT_NETWORKER,
  },
  { concept: 'fugitive', roles: ['criminal', 'mystic', 'revolutionary'], template: KIT_FUGITIVE },
  { concept: 'negotiator', roles: ['agitator', 'diplomat', 'dealer'], template: KIT_NEGOTIATOR },
  { concept: 'operative', roles: ['assassin', 'guard', 'spy'], template: KIT_OPERATIVE },
  { concept: 'pilot', roles: ['ace', 'driver', 'trucker'], template: KIT_PILOT },
  { concept: 'pioneer', roles: ['colonist', 'prospector', 'scout'], template: KIT_PIONEER },
  { concept: 'preacher', roles: ['ascetic', 'missionary', 'prophet'], template: KIT_PREACHER },
  {
    concept: 'scientist',
    roles: ['archaeologist', 'medicurg', 'technologist'],
    template: KIT_SCIENTIST,
  },
  { concept: 'sailor', roles: ['ship-engineer', 'labourer', 'loader'], template: KIT_SAILOR },
  { concept: 'soldier', roles: ['legionnaire', 'mercenary', 'officer'], template: KIT_SOLDIER },
];

function expandKits(): readonly StarterKit[] {
  const out: StarterKit[] = [];
  for (const { concept, roles, template } of AMPLUA_KITS) {
    for (const role of roles) {
      out.push({
        concept,
        role,
        fixed: template.fixed,
        choices: template.choices,
      });
    }
  }
  return Object.freeze(out);
}

export const STARTER_KIT_CATALOG: readonly StarterKit[] = expandKits();

/**
 * Returns the starter kit for [concept, role], or `null` if no entry
 * exists yet.
 */
export function findStarterKit(concept: Concept, role: Role): StarterKit | null {
  return STARTER_KIT_CATALOG.find((k) => k.concept === concept && k.role === role) ?? null;
}

/**
 * Resolves the user-visible label of a starter kit item for [locale],
 * falling back through the `[locale]-todo` placeholders if a real
 * translation hasn't landed yet. Mirrors the helper in `talents.ts`.
 */
export function pickStarterKitItemName(item: StarterKitItem, locale: CatalogLocale): string {
  const raw = item.template.name[locale];
  if (!raw) return item.template.name.en;
  return raw;
}
