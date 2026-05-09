/**
 * Coriolis ST3001 ch.4 Достоинства — talent catalog.
 *
 * Single source of truth for the three talent kinds available at character
 * creation (icon gifts, crew talents, personal talents) plus pasynok
 * stigmas. Both `apps/web` (renderer) and `apps/backend` (iconGift hydration
 * on character forge) consume this module via the `@app/specs` workspace
 * barrel.
 *
 * Locale codes match `@nuxtjs/i18n` locales — `en`/`ru` are sourced from the
 * Russian rulebook plus the Free League English edition, `uk`/`el` carry
 * `[uk-todo]/[el-todo]` placeholder copy until a translation lands.
 *
 * Talent IDs are kebab-case and stable across DB rows, i18n keys, and the
 * `ICON_GIFT_TALENT_IDS` mapping (icon → gift-talent ID).
 */
import type { components } from './openapi-types.js';

export type CatalogLocale = 'en' | 'ru' | 'uk' | 'el';
export type LocalizedString = Readonly<Record<CatalogLocale, string>>;

type IconId = components['schemas']['IconId'];
type CrewConcept = components['schemas']['CrewConcept'];
type TalentKind = components['schemas']['TalentKind'];

export interface CatalogTalentBase {
  readonly id: string;
  readonly kind: TalentKind;
  readonly name: LocalizedString;
  readonly description: LocalizedString;
  /** Maximum rank (1..3) per ST3001 ch.4 — most talents are rank 1. */
  readonly rankCap: 1 | 2 | 3;
}

export interface IconGiftCatalogEntry extends CatalogTalentBase {
  readonly kind: 'iconGift';
  readonly iconId: IconId;
}

export interface CrewTalentCatalogEntry extends CatalogTalentBase {
  readonly kind: 'crew';
  readonly crewConcept: CrewConcept;
}

export interface PersonalTalentCatalogEntry extends CatalogTalentBase {
  readonly kind: 'personal';
}

export interface StigmaTalentCatalogEntry extends CatalogTalentBase {
  readonly kind: 'stigma';
}

export type CatalogTalent =
  | IconGiftCatalogEntry
  | CrewTalentCatalogEntry
  | PersonalTalentCatalogEntry
  | StigmaTalentCatalogEntry;

const UK_TODO = '[uk-todo]';
const EL_TODO = '[el-todo]';

// ---------------------------------------------------------------------------
// Icon gifts (9) — ST3001 ch.4 §Дары Ликов. One per icon, immutable.
// ---------------------------------------------------------------------------

export const ICON_GIFTS: readonly IconGiftCatalogEntry[] = Object.freeze([
  {
    id: 'gift-lady-of-tears',
    kind: 'iconGift',
    iconId: 'lady-of-tears',
    rankCap: 1,
    name: {
      en: 'Gift of the Lady of Tears',
      ru: 'Дар Владычицы Слёз',
      uk: `${UK_TODO} Gift of the Lady of Tears`,
      el: `${EL_TODO} Gift of the Lady of Tears`,
    },
    description: {
      en: 'Once per session, when broken, immediately recover 1 HP or MP, or ignore the effect of a Critical Injury you just suffered. The GM gains 1 Darkness Point.',
      ru: 'Раз за игровую встречу: утратив боеспособность или дееспособность, ты можешь немедленно прийти в себя, восстановив 1 пункт здоровья или рассудка, либо проигнорировать эффект только что полученной травмы. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'gift-dancer',
    kind: 'iconGift',
    iconId: 'dancer',
    rankCap: 1,
    name: {
      en: 'Gift of the Dancer',
      ru: 'Дар Танцора',
      uk: `${UK_TODO} Gift of the Dancer`,
      el: `${EL_TODO} Gift of the Dancer`,
    },
    description: {
      en: 'Once per session, dodge any incoming attack and take zero damage. Apply after a successful enemy attack roll but before armor or cover is checked. The GM gains 1 Darkness Point.',
      ru: 'Раз за игровую встречу: ты уклоняешься от любой атаки, не получив ни пункта урона. Применяй после удачной проверки атаки противника, но до проверки укрытия и брони. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'gift-gambler',
    kind: 'iconGift',
    iconId: 'gambler',
    rankCap: 1,
    name: {
      en: 'Gift of the Gambler',
      ru: 'Дар Игрока',
      uk: `${UK_TODO} Gift of the Gambler`,
      el: `${EL_TODO} Gift of the Gambler`,
    },
    description: {
      en: 'Once per session, automatically succeed on a single skill check as if you had rolled three sixes. For special skills the gift only triggers if your skill is above zero. The GM gains 1 Darkness Point.',
      ru: 'Раз за игровую встречу: ты добиваешься безусловного успеха при проверке любого навыка, словно выбросил три шестёрки. Для специальных навыков работает только если значение навыка выше нуля. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'gift-merchant',
    kind: 'iconGift',
    iconId: 'merchant',
    rankCap: 1,
    name: {
      en: 'Gift of the Merchant',
      ru: 'Дар Купца',
      uk: `${UK_TODO} Gift of the Merchant`,
      el: `${EL_TODO} Gift of the Merchant`,
    },
    description: {
      en: 'Once per session, when short on funds for gear or ship modules, you can secure a favourable loan from a willing creditor. The debt must be repaid by the agreed date. The GM gains 1 Darkness Point.',
      ru: 'Раз за игровую встречу: если у тебя не хватает денег на покупку снаряжения или оборудования для корабля, ты получаешь выгодный заём. Долг придётся выплатить в заранее оговорённый срок. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'gift-deckhand',
    kind: 'iconGift',
    iconId: 'deckhand',
    rankCap: 1,
    name: {
      en: 'Gift of the Deckhand',
      ru: 'Дар Юнги',
      uk: `${UK_TODO} Gift of the Deckhand`,
      el: `${EL_TODO} Gift of the Deckhand`,
    },
    description: {
      en: 'Once per session, when your ship hits zero hull or zero energy, instantly restore 1d6 points to either pool. Restoration is not an action — the Icons grant it freely. The GM gains 1 Darkness Point.',
      ru: 'Раз за игровую встречу: если запас прочности или энергии твоего корабля опускается до нуля, ты мгновенно восстанавливаешь d6 пунктов того или другого. Это не считается действием — корабль получает благодать Ликов. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'gift-traveler',
    kind: 'iconGift',
    iconId: 'traveler',
    rankCap: 1,
    name: {
      en: 'Gift of the Traveler',
      ru: 'Дар Странника',
      uk: `${UK_TODO} Gift of the Traveler`,
      el: `${EL_TODO} Gift of the Traveler`,
    },
    description: {
      en: 'Once per session, when faced with a binary choice, ask the GM which option is better for your character. The GM must answer honestly, though "better" is subjective and the answer may be ambiguous. The GM gains 1 Darkness Point.',
      ru: 'Раз за игровую встречу: если персонажу нужно выбрать один из двух вариантов, ты можешь спросить у ведущего, какой выгоднее, и ведущий обязан ответить честно (помни, что «выгодность» условна). Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'gift-messenger',
    kind: 'iconGift',
    iconId: 'messenger',
    rankCap: 1,
    name: {
      en: 'Gift of the Messenger',
      ru: 'Дар Вестника',
      uk: `${UK_TODO} Gift of the Messenger`,
      el: `${EL_TODO} Gift of the Messenger`,
    },
    description: {
      en: 'Once per session, convince any PC or NPC to do something you ask without rolling Manipulation. The request must be reasonable and may not push the target to act against their own interests. The GM gains 1 Darkness Point.',
      ru: 'Раз за игровую встречу: ты убеждаешь любого персонажа поступить так, как тебе нужно, без проверки влияния. Просьба должна быть разумной — нельзя заставить персонажа действовать вопреки его интересам. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'gift-judge',
    kind: 'iconGift',
    iconId: 'judge',
    rankCap: 1,
    name: {
      en: 'Gift of the Judge',
      ru: 'Дар Судьи',
      uk: `${UK_TODO} Gift of the Judge`,
      el: `${EL_TODO} Gift of the Judge`,
    },
    description: {
      en: 'Once per session, when one of your attacks hits, the target also suffers a Critical Injury — even if armor or cover absorbed all the damage. The GM gains 1 Darkness Point.',
      ru: 'Раз за игровую встречу: если твоя атака попадает в цель, жертва получает травму, даже если броня или укрытие защитили её от урона. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'gift-faceless-one',
    kind: 'iconGift',
    iconId: 'faceless-one',
    rankCap: 1,
    name: {
      en: 'Gift of the Faceless One',
      ru: 'Дар Незримого',
      uk: `${UK_TODO} Gift of the Faceless One`,
      el: `${EL_TODO} Gift of the Faceless One`,
    },
    description: {
      en: 'Once per session, slightly bend the scene to your favour: a knife happens to be at hand, a window happens to be unlocked. Effects must be cosmetic and indirect; the GM has the final word. The GM gains 1 Darkness Point.',
      ru: 'Раз за игровую встречу: ты слегка изменяешь обстоятельства сцены в свою пользу — нож подвернётся под руку, окно окажется незапертым. Изменения косметические и опосредованные; последнее слово за ведущим. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
]);

// ---------------------------------------------------------------------------
// Crew talents (15) — ST3001 ch.4 §Достоинства команды (5 amplua × 3 each).
// ---------------------------------------------------------------------------

export const CREW_TALENTS: readonly CrewTalentCatalogEntry[] = Object.freeze([
  // Free Traders
  {
    id: 'crew-nose-for-birrs',
    kind: 'crew',
    crewConcept: 'free-trader',
    rankCap: 1,
    name: {
      en: 'Nose for Birrs',
      ru: 'Нюх на бирры',
      uk: `${UK_TODO} Nose for Birrs`,
      el: `${EL_TODO} Nose for Birrs`,
    },
    description: {
      en: '+2 to Manipulation when haggling. Once per session for the whole crew, not per character.',
      ru: 'Торгуясь, вы получаете +2 при проверках влияния. Использовать можно один раз за игровую встречу — на всю команду, а не по разу на каждого героя.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'crew-you-scratch-mine',
    kind: 'crew',
    crewConcept: 'free-trader',
    rankCap: 1,
    name: {
      en: 'You Scratch My Back',
      ru: 'Ты — мне, я — тебе',
      uk: `${UK_TODO} You Scratch My Back`,
      el: `${EL_TODO} You Scratch My Back`,
    },
    description: {
      en: 'You have a knack for finding the most corrupt officials and customs agents. +2 to Manipulation when bribing.',
      ru: 'У вас талант находить самых коррумпированных чиновников и таможенников — вы получаете +2 при проверках влияния, когда подкупаете кого-нибудь.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'crew-shortest-path',
    kind: 'crew',
    crewConcept: 'free-trader',
    rankCap: 1,
    name: {
      en: 'Shortest Path',
      ru: 'Кратчайший путь',
      uk: `${UK_TODO} Shortest Path`,
      el: `${EL_TODO} Shortest Path`,
    },
    description: {
      en: 'Cut travel time in half OR avoid one unwanted random encounter en route. Once per voyage. The GM gains 1 Darkness Point.',
      ru: 'Вы либо сокращаете время путешествия вдвое, либо избегаете одной нежелательной случайной встречи в пути. Один раз за путешествие. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  // Mercenaries
  {
    id: 'crew-open-fire',
    kind: 'crew',
    crewConcept: 'mercenary',
    rankCap: 1,
    name: {
      en: 'Open Fire!',
      ru: 'Огонь!',
      uk: `${UK_TODO} Open Fire`,
      el: `${EL_TODO} Open Fire`,
    },
    description: {
      en: '+2 to Ranged Combat checks, but only when every hero on the team attacks the same target this round.',
      ru: 'Вы получаете +2 при проверках стрельбы, но только если все герои в этом раунде атакуют одну и ту же цель.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'crew-charge',
    kind: 'crew',
    crewConcept: 'mercenary',
    rankCap: 1,
    name: {
      en: 'Charge!',
      ru: 'В атаку!',
      uk: `${UK_TODO} Charge`,
      el: `${EL_TODO} Charge`,
    },
    description: {
      en: '+2 to Melee Combat, but only if every hero spends a fast action moving this round. Effect lasts one round.',
      ru: 'Вы получаете +2 при проверках ближнего боя, но только если все герои в этом раунде потратят хотя бы одно быстрое действие на перемещение. Эффект — один раунд.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'crew-eyes-open',
    kind: 'crew',
    crewConcept: 'mercenary',
    rankCap: 1,
    name: {
      en: 'Eyes Open',
      ru: 'Не зевать!',
      uk: `${UK_TODO} Eyes Open`,
      el: `${EL_TODO} Eyes Open`,
    },
    description: {
      en: 'Always alert. +2 to Observation checks made to spot enemy ambushes.',
      ru: 'Вы всегда зорко следите за обстановкой и получаете +2 при проверках наблюдательности, когда выясняете, заметили вы вражескую засаду или нет.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  // Agents
  {
    id: 'crew-hundred-friends',
    kind: 'crew',
    crewConcept: 'agents',
    rankCap: 1,
    name: {
      en: 'A Hundred Friends',
      ru: 'Сто друзей',
      uk: `${UK_TODO} A Hundred Friends`,
      el: `${EL_TODO} A Hundred Friends`,
    },
    description: {
      en: 'Wherever you arrive, you instantly make useful contacts who can shelter you, lend gear, or vouch for you. Once per session for the whole crew. The GM gains 1 Darkness Point.',
      ru: 'Оказавшись в новом месте, вы мигом обзаводитесь полезными знакомствами — они дадут убежище, одолжат снаряжение или поручатся за вас. Один раз за игровую встречу на всю команду. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'crew-assassins-guild',
    kind: 'crew',
    crewConcept: 'agents',
    rankCap: 1,
    name: {
      en: "Assassins' Guild",
      ru: 'Гильдия убийц',
      uk: `${UK_TODO} Assassins Guild`,
      el: `${EL_TODO} Assassins Guild`,
    },
    description: {
      en: 'When attacking a target unaware of your presence, use Infiltration instead of Melee Combat.',
      ru: 'Атакуя противника, который не знает о вашем присутствии, вы можете использовать скрытность вместо ближнего боя.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'crew-alama-dancers',
    kind: 'crew',
    crewConcept: 'agents',
    rankCap: 1,
    name: {
      en: 'Dancers of Alama',
      ru: 'Танцоры Алама',
      uk: `${UK_TODO} Dancers of Alama`,
      el: `${EL_TODO} Dancers of Alama`,
    },
    description: {
      en: 'When making a positive impression, use Dexterity instead of Manipulation.',
      ru: 'Пытаясь произвести хорошее впечатление, вы можете использовать проворство вместо влияния.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  // Explorers
  {
    id: 'crew-seasoned-travelers',
    kind: 'crew',
    crewConcept: 'explorer',
    rankCap: 1,
    name: {
      en: 'Seasoned Travelers',
      ru: 'Бывалые путешественники',
      uk: `${UK_TODO} Seasoned Travelers`,
      el: `${EL_TODO} Seasoned Travelers`,
    },
    description: {
      en: 'When trying to understand a society or group, use Manipulation instead of Culture.',
      ru: 'Пытаясь понять обычаи общества или группы людей, вы можете использовать влияние вместо мудрости.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'crew-survivors',
    kind: 'crew',
    crewConcept: 'explorer',
    rankCap: 1,
    name: {
      en: 'Survivors',
      ru: 'Остаться в живых',
      uk: `${UK_TODO} Survivors`,
      el: `${EL_TODO} Survivors`,
    },
    description: {
      en: 'The whole crew escapes any natural hazard — wildfire, sandstorm, cave-in, explosive decompression. Once per session for the whole crew. The GM gains 1 Darkness Point.',
      ru: 'Вся ваша команда может спастись от любой опасности «природного» происхождения — пожара, бури, обвала, декомпрессии. Один раз за игровую встречу на всю команду. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'crew-truth-seekers',
    kind: 'crew',
    crewConcept: 'explorer',
    rankCap: 1,
    name: {
      en: 'Truth Seekers',
      ru: 'Искатели истины',
      uk: `${UK_TODO} Truth Seekers`,
      el: `${EL_TODO} Truth Seekers`,
    },
    description: {
      en: 'Without rolling, gain a piece of information or evidence valuable enough to bypass a small obstacle in the adventure. Once per session for the whole crew. The GM gains 1 Darkness Point.',
      ru: 'Без проверки получаете от ведущего информацию или улику, достаточно ценную, чтобы обойти небольшое препятствие сценария. Один раз за игровую встречу на всю команду. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  // Pilgrims
  {
    id: 'crew-jesters',
    kind: 'crew',
    crewConcept: 'pilgrim',
    rankCap: 1,
    name: {
      en: 'Jesters',
      ru: 'Шутники',
      uk: `${UK_TODO} Jesters`,
      el: `${EL_TODO} Jesters`,
    },
    description: {
      en: 'Talk your way out of trouble by turning the situation into a joke. Once per session for the whole crew. The GM gains 1 Darkness Point.',
      ru: 'Вы выпутываетесь из неприятностей, развеселив публику и обратив всё в шутку. Один раз за игровую встречу на всю команду. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'crew-mercy-of-icons',
    kind: 'crew',
    crewConcept: 'pilgrim',
    rankCap: 1,
    name: {
      en: 'Mercy of the Icons',
      ru: 'Милость Ликов',
      uk: `${UK_TODO} Mercy of the Icons`,
      el: `${EL_TODO} Mercy of the Icons`,
    },
    description: {
      en: 'Cancel the effect of a misfortune the GM just invoked with Darkness Points. Once per session for the whole crew.',
      ru: 'Вы можете отменить эффект неприятности, которую ведущий только что призвал на ваши головы при помощи пунктов тьмы. Один раз за игровую встречу на всю команду.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'crew-no-birrs-to-spare',
    kind: 'crew',
    crewConcept: 'pilgrim',
    rankCap: 1,
    name: {
      en: 'No Birrs to Spare',
      ru: 'Без бирра за душой',
      uk: `${UK_TODO} No Birrs to Spare`,
      el: `${EL_TODO} No Birrs to Spare`,
    },
    description: {
      en: 'Earn your keep by performance. Win an opposed Dexterity vs Manipulation check against a local official or patron and you secure spartan lodging and spares for free.',
      ru: 'Прибыв на место, вы зарабатываете на жизнь ремеслом или представлениями. Выиграйте встречную проверку проворства против влияния местного представителя власти — и обеспечите себе спартанское проживание и запчасти.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
]);

// ---------------------------------------------------------------------------
// Personal talents (26) — ST3001 ch.4 §Личные достоинства. Flat pool.
// ---------------------------------------------------------------------------

export const PERSONAL_TALENTS: readonly PersonalTalentCatalogEntry[] = Object.freeze([
  {
    id: 'personal-runner',
    kind: 'personal',
    rankCap: 3,
    name: {
      en: 'Runner',
      ru: 'Бегун',
      uk: `${UK_TODO} Runner`,
      el: `${EL_TODO} Runner`,
    },
    description: {
      en: 'Movement speed increases from 10 to 12 metres. May be taken three times: at rank 2 speed becomes 14m, at rank 3 it becomes 16m. Stacks with the Speed bionic, but not with the Reinforced Muscles cybernetic.',
      ru: 'Скорость персонажа увеличивается с 10 до 12 метров. Достоинство можно приобрести трижды: после второго раза скорость 14 м, после третьего — 16 м. Сочетается с бионической модификацией скорости, но не с имплантатом усиленных мышц.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-blesser',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Blesser',
      ru: 'Благословитель',
      uk: `${UK_TODO} Blesser`,
      el: `${EL_TODO} Blesser`,
    },
    description: {
      en: 'Once per session, bless another PC at short range, granting them +3 to a single skill check. In combat the blessing is a Stretch action. The GM gains 1 Darkness Point.',
      ru: 'Раз за игровую встречу ты благословляешь персонажа другого игрока в рамках ближней дистанции, обеспечивая ему +3 к одной любой проверке. В бою — продолжительное действие. Ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-wealthy-family',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Wealthy Family',
      ru: 'Богатая семья',
      uk: `${UK_TODO} Wealthy Family`,
      el: `${EL_TODO} Wealthy Family`,
    },
    description: {
      en: 'Trading on rumours of family wealth, gain +2 to Manipulation when the GM finds the angle plausible. Truth of the rumours is irrelevant. Requires aristocrat upbringing.',
      ru: 'Сыграв на слухах о богатствах семьи, ты получаешь +2 при проверке влияния, если ведущий сочтёт это уместным. Правдивы слухи или нет — неважно. Только при аристократическом воспитании.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-fast-reload',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Fast Reload',
      ru: 'Быстрая перезарядка',
      uk: `${UK_TODO} Fast Reload`,
      el: `${EL_TODO} Fast Reload`,
    },
    description: {
      en: 'Reload a weapon as a fast action instead of a slow action.',
      ru: 'Ты перезаряжаешь оружие быстрым действием, а не стандартным.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-point-blank',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Point-Blank Shot',
      ru: 'Выстрел в упор',
      uk: `${UK_TODO} Point-Blank Shot`,
      el: `${EL_TODO} Point-Blank Shot`,
    },
    description: {
      en: 'When you hit a target at short range, count one extra six on the Ranged Combat roll.',
      ru: 'Если ты попадаешь в противника в рамках ближней дистанции, считай, что при проверке стрельбы у тебя выпало на одну шестёрку больше.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-menacing',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Menacing',
      ru: 'Грозный вид',
      uk: `${UK_TODO} Menacing`,
      el: `${EL_TODO} Menacing`,
    },
    description: {
      en: 'When intimidating, use Force instead of Manipulation. On a conditional success you may demand the target accept your original offer or escalate to violence.',
      ru: 'Запугивая оппонента, ты можешь использовать силу вместо влияния. При условном успехе можешь настоять на первоначальном предложении — оппоненту останется либо согласиться, либо перейти к насилию.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-nine-lives',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Nine Lives',
      ru: 'Девять жизней',
      uk: `${UK_TODO} Nine Lives`,
      el: `${EL_TODO} Nine Lives`,
    },
    description: {
      en: 'When the GM rolls d66 to determine your Critical Injury, you may swap the tens and ones digits. Cancelled if the attacker has Executioner.',
      ru: 'Когда ведущий проходит проверку d66 на травму, ты можешь поменять местами выпавшие десятки и единицы. Если у противника есть достоинство «Палач», эффекты взаимоисключаются.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-hardened',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Hardened',
      ru: 'Закалка',
      uk: `${UK_TODO} Hardened`,
      el: `${EL_TODO} Hardened`,
    },
    description: {
      en: 'Provides Armor Rating 3 against environmental damage (cold, heat, sandstorms, decompression).',
      ru: 'Этот талант обеспечивает «броню» с классом защиты 3 против «природного» ситуативного урона.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-defensive-stance',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Defensive Stance',
      ru: 'Защитная стойка',
      uk: `${UK_TODO} Defensive Stance`,
      el: `${EL_TODO} Defensive Stance`,
    },
    description: {
      en: '+2 to Melee Combat checks made to defend against incoming attacks.',
      ru: 'Защищаясь, ты получаешь +2 при проверках ближнего боя.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-tough',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Tough',
      ru: 'Здоровяк',
      uk: `${UK_TODO} Tough`,
      el: `${EL_TODO} Tough`,
    },
    description: {
      en: 'Maximum HP increases by 2.',
      ru: 'Запас здоровья увеличивается на 2 пункта.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-sinister',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Sinister',
      ru: 'Зловещий',
      uk: `${UK_TODO} Sinister`,
      el: `${EL_TODO} Sinister`,
    },
    description: {
      en: 'When inflicting Stress with a successful Manipulation check, deal 1 extra Stress.',
      ru: 'Причиняя стресс удачной проверкой влияния, ты наносишь на 1 пункт стресса больше обычного.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-truth-spotter',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Truth Spotter',
      ru: 'Изобличитель',
      uk: `${UK_TODO} Truth Spotter`,
      el: `${EL_TODO} Truth Spotter`,
    },
    description: {
      en: 'After at least one minute of conversation, tell whether your interlocutor is lying without a Manipulation check. You will not know what the lie was. Half-truths register as lies. Each use grants the GM 1 Darkness Point.',
      ru: 'Поговорив с человеком хотя бы минуту, ты определяешь ложь без проверок влияния. В чём именно ложь — неизвестно (полуправду тоже распознаёшь как ложь). Каждый раз ведущий получает 1 пункт тьмы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-inventor',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Inventor',
      ru: 'Изобретатель',
      uk: `${UK_TODO} Inventor`,
      el: `${EL_TODO} Inventor`,
    },
    description: {
      en: 'On a successful Technology check, repair any broken gear without spare parts (it breaks again after the next use). With proper spares, build a one-shot improvised gadget at gear bonus equal to the sixes rolled.',
      ru: 'При успешной проверке технологики ты без запчастей чинишь сломанный предмет (он снова сломается после первого применения). Если есть подходящие запчасти, собираешь одноразовый самопал, модификатор которого равен количеству выпавших шестёрок.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-assassin-strike',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Assassin Strike',
      ru: 'Коварный удар',
      uk: `${UK_TODO} Assassin Strike`,
      el: `${EL_TODO} Assassin Strike`,
    },
    description: {
      en: '+2 to Melee Combat when striking from surprise with a light weapon.',
      ru: 'Нанося удар исподтишка лёгким оружием, ты получаешь +2 при проверке ближнего боя.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-licensee',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Licensee',
      ru: 'Лицензиат',
      uk: `${UK_TODO} Licensee`,
      el: `${EL_TODO} Licensee`,
    },
    description: {
      en: 'You hold the paperwork to legally purchase licensed weapons and gear. Local law may still restrict carrying them in public.',
      ru: 'У тебя есть документы и разрешения на покупку лицензированного оружия и снаряжения. Местные законы могут запрещать его публичное ношение.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-seducer',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Seducer',
      ru: 'Обольститель',
      uk: `${UK_TODO} Seducer`,
      el: `${EL_TODO} Seducer`,
    },
    description: {
      en: '+2 to Manipulation when winning someone over through seduction.',
      ru: 'Ты получаешь +2 при проверках влияния, когда добиваешься чего-либо обольщением.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-veteran-warrior',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Veteran Warrior',
      ru: 'Опытный воин',
      uk: `${UK_TODO} Veteran Warrior`,
      el: `${EL_TODO} Veteran Warrior`,
    },
    description: {
      en: 'Roll two dice for initiative and keep the higher. With Accelerated Reflexes cybernetic, roll three dice instead.',
      ru: 'При проверке инициативы ты бросаешь два кубика и выбираешь лучший. С имплантатом ускоренной реакции бросаешь три кубика.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-consecrator',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Consecrator',
      ru: 'Освятитель',
      uk: `${UK_TODO} Consecrator`,
      el: `${EL_TODO} Consecrator`,
    },
    description: {
      en: 'Over 1d6 hours at a chapel or altar, craft a talisman that grants +1 to a single skill check before losing its blessing.',
      ru: 'Ты можешь создать и освятить талисман: за d6 часов при наличии часовни или алтаря. Талисман даёт +1 к одной проверке навыка, после чего теряет силу.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-executioner',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Executioner',
      ru: 'Палач',
      uk: `${UK_TODO} Executioner`,
      el: `${EL_TODO} Executioner`,
    },
    description: {
      en: 'When the GM rolls d66 for the Critical Injury you inflict, you may swap the tens and ones digits. Cancelled if the target has Nine Lives.',
      ru: 'Когда ведущий проходит проверку d66 на травму твоего противника, ты можешь поменять местами выпавшие десятки и единицы. Если у противника есть «Девять жизней», эффекты взаимоисключаются.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-field-medic',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Field Medic',
      ru: 'Полевой медикург',
      uk: `${UK_TODO} Field Medic`,
      el: `${EL_TODO} Field Medic`,
    },
    description: {
      en: '+2 to Medicurgy checks when stabilising and healing critical injuries.',
      ru: 'Оказывая неотложную помощь, ты получаешь +2 при проверках медикургии.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-zero-g-adept',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Zero-G Adept',
      ru: 'Привычка к невесомости',
      uk: `${UK_TODO} Zero-G Adept`,
      el: `${EL_TODO} Zero-G Adept`,
    },
    description: {
      en: '+2 to Dexterity checks while in zero gravity.',
      ru: 'Ты получаешь +2 при проверках проворства в условиях невесомости.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-gunner',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Gunner',
      ru: 'Пулемётчик',
      uk: `${UK_TODO} Gunner`,
      el: `${EL_TODO} Gunner`,
    },
    description: {
      en: 'When firing fully automatic, ignore the first 1 rolled on the extra dice. With a high-capacity magazine, ignore the first two.',
      ru: 'При ведении автоматического огня ты игнорируешь первую выпавшую на дополнительном кубике единицу. Если у оружия есть свойство «вместительный магазин» — две.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-comforter',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Comforter',
      ru: 'Утешитель',
      uk: `${UK_TODO} Comforter`,
      el: `${EL_TODO} Comforter`,
    },
    description: {
      en: '+2 to Medicurgy when rallying a Broken character with comforting words.',
      ru: 'Ты получаешь +2 при проверках медикургии, когда воодушевляешь недееспособного персонажа.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-faction-member',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Faction Member',
      ru: 'Член фракции',
      uk: `${UK_TODO} Faction Member`,
      el: `${EL_TODO} Faction Member`,
    },
    description: {
      en: 'You belong to one of the Council factions or another powerful organization. +2 to Manipulation when invoking your affiliation to intimidate (when locally relevant).',
      ru: 'Ты принадлежишь к одной из фракций Совета или иной могущественной организации. Используя этот факт для запугивания, получаешь +2 при проверке влияния (если фракция имеет вес в этом месте).',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-sixth-sense',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Sixth Sense',
      ru: 'Шестое чувство',
      uk: `${UK_TODO} Sixth Sense`,
      el: `${EL_TODO} Sixth Sense`,
    },
    description: {
      en: 'Once per session, negate the effect of a surprise attack against you. You also enjoy +2 to Observation when actively scanning for ambushes or sneak attacks.',
      ru: 'Раз за игровую встречу ты нейтрализуешь эффект внезапной атаки. Дополнительно получаешь +2 при проверке наблюдательности, когда обнаруживаешь засаду или подкрадывающегося противника.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'personal-exo-technician',
    kind: 'personal',
    rankCap: 1,
    name: {
      en: 'Exo-Technician',
      ru: 'Экзотехник',
      uk: `${UK_TODO} Exo-Technician`,
      el: `${EL_TODO} Exo-Technician`,
    },
    description: {
      en: 'Inside any exo, from a basic exo-suit to a combat exo-armor, gain +2 to Dexterity and Force checks.',
      ru: 'Находясь внутри любого экзоустройства, от экзоскафандра до боевого экзодоспеха, ты получаешь +2 при проверках проворства и силы.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
]);

// ---------------------------------------------------------------------------
// Stigmas (3) — ST3001 ch.4 §Стигмы пасынков. Mutant-only, picked in Block 5.
// ---------------------------------------------------------------------------

export const STIGMA_TALENTS: readonly StigmaTalentCatalogEntry[] = Object.freeze([
  {
    id: 'stigma-aquatic-breath',
    kind: 'stigma',
    rankCap: 1,
    name: {
      en: 'Aquatic Breathing',
      ru: 'Подводное дыхание',
      uk: `${UK_TODO} Aquatic Breathing`,
      el: `${EL_TODO} Aquatic Breathing`,
    },
    description: {
      en: 'You can breathe freely underwater.',
      ru: 'Ты можешь свободно дышать под водой.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'stigma-resilience',
    kind: 'stigma',
    rankCap: 1,
    name: {
      en: 'Resilience',
      ru: 'Стойкость',
      uk: `${UK_TODO} Resilience`,
      el: `${EL_TODO} Resilience`,
    },
    description: {
      en: 'Provides Armor Rating 6 against environmental damage. Stacks with Hardened to AR 9.',
      ru: 'Этот талант обеспечивает класс защиты 6 против «природного» ситуативного урона. В сочетании с «Закалкой» — 9.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
  {
    id: 'stigma-pheromones',
    kind: 'stigma',
    rankCap: 1,
    name: {
      en: 'Pheromones',
      ru: 'Феромоны',
      uk: `${UK_TODO} Pheromones`,
      el: `${EL_TODO} Pheromones`,
    },
    description: {
      en: 'Modified glands let you broadcast and absorb airborne pheromones. Once per session, gain +2 to Manipulation. Suppressed by vacuum, gas masks, exo-suits.',
      ru: 'Видоизменённые железы позволяют испускать и поглощать летучие феромоны. Раз за игровую встречу получаешь +2 при проверке влияния. Не работает в вакууме и против носителей противогазов и экзоскафандров.',
      uk: UK_TODO,
      el: EL_TODO,
    },
  },
]);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

export const TALENT_CATALOG: readonly CatalogTalent[] = Object.freeze([
  ...ICON_GIFTS,
  ...CREW_TALENTS,
  ...PERSONAL_TALENTS,
  ...STIGMA_TALENTS,
]);

const CATALOG_BY_ID: ReadonlyMap<string, CatalogTalent> = new Map(
  TALENT_CATALOG.map((t) => [t.id, t]),
);

const ICON_GIFT_BY_ICON: ReadonlyMap<IconId, IconGiftCatalogEntry> = new Map(
  ICON_GIFTS.map((g) => [g.iconId, g]),
);

/** Returns the catalog entry for a stable talent ID, or `undefined` for custom names. */
export function findCatalogTalentById(id: string): CatalogTalent | undefined {
  return CATALOG_BY_ID.get(id);
}

/** Returns the canonical iconGift entry for a given Icon. */
export function getIconGiftByIconId(iconId: IconId): IconGiftCatalogEntry {
  const gift = ICON_GIFT_BY_ICON.get(iconId);
  if (!gift) {
    // The IconId enum is checked at the OpenAPI layer; this is defence-in-depth.
    throw new Error(`No iconGift catalog entry for icon "${iconId}"`);
  }
  return gift;
}

/** Returns the three crew talents that belong to the given crew amplua. */
export function getCrewTalentsByConcept(
  crewConcept: CrewConcept,
): readonly CrewTalentCatalogEntry[] {
  return CREW_TALENTS.filter((t) => t.crewConcept === crewConcept);
}
