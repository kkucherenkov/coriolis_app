<script setup lang="ts">
  import {
    AppCard,
    AppStatBlock,
    AppDots,
    AppDivider,
    AppConditionPill,
    AppBanner,
    AppBadge,
  } from '@app/ui';
  import type { Character, Item } from '@app/api-client-ts';
  import { useTalentLocalization } from '~/composables/useTalentLocalization';

  interface Props {
    character: Character;
  }

  const props = defineProps<Props>();

  const { t } = useI18n({ useScope: 'local' });
  // Both the editable sheet and this read-only viewer render rows from the
  // same Talent table, so the locale-switch logic lives in one composable
  // (see `useTalentLocalization` for the catalog-match rationale).
  const { displayTalentName, displayTalentDescription } = useTalentLocalization();

  // ── Skill / Attribute constants ─────────────────────────────────────────────

  type AttrKey = 'strength' | 'agility' | 'wits' | 'empathy';
  type GeneralSkillKey =
    | 'force'
    | 'meleeCombat'
    | 'dexterity'
    | 'infiltration'
    | 'rangedCombat'
    | 'observation'
    | 'survival'
    | 'manipulation';
  type AdvancedSkillKey =
    | 'command'
    | 'culture'
    | 'dataDjinn'
    | 'medicurgy'
    | 'mysticPowers'
    | 'pilot'
    | 'science'
    | 'technology';
  type SkillKey = GeneralSkillKey | AdvancedSkillKey;
  type ConditionKey = 'exhausted' | 'sleepless' | 'thirsty' | 'hungry';
  type AttrBadge = 'STR' | 'AGI' | 'WIT' | 'EMP';

  const ATTR_KEYS: AttrKey[] = ['strength', 'agility', 'wits', 'empathy'];

  const GENERAL_SKILLS: GeneralSkillKey[] = [
    'force',
    'meleeCombat',
    'dexterity',
    'infiltration',
    'rangedCombat',
    'observation',
    'survival',
    'manipulation',
  ];
  const ADVANCED_SKILLS: AdvancedSkillKey[] = [
    'command',
    'culture',
    'dataDjinn',
    'medicurgy',
    'mysticPowers',
    'pilot',
    'science',
    'technology',
  ];

  const CONDITION_KEYS: ConditionKey[] = ['exhausted', 'sleepless', 'thirsty', 'hungry'];

  const SKILL_GOVERNING_ATTR: Record<SkillKey, AttrBadge> = {
    force: 'STR',
    meleeCombat: 'STR',
    dexterity: 'AGI',
    infiltration: 'AGI',
    rangedCombat: 'AGI',
    pilot: 'AGI',
    observation: 'WIT',
    survival: 'WIT',
    dataDjinn: 'WIT',
    medicurgy: 'WIT',
    science: 'WIT',
    technology: 'WIT',
    manipulation: 'EMP',
    command: 'EMP',
    culture: 'EMP',
    mysticPowers: 'EMP',
  };

  // ── Helpers ──────────────────────────────────────────────────────────────────

  function initials(name: string): string {
    return name
      .trim()
      .split(/\s+/)
      .slice(0, 2)
      .map((w) => w[0]?.toUpperCase() ?? '')
      .join('');
  }

  function attrLabel(key: AttrKey): string {
    return t(`attr.${key}`);
  }

  function skillLabel(key: SkillKey): string {
    return t(`skill.${key}`);
  }

  function conditionLabel(key: ConditionKey): string {
    return t(`condition.${key}`);
  }

  function itemTypeBadgeVariant(
    type: string,
  ): 'brass' | 'mystic' | 'crimson' | 'success' | 'darkness' {
    switch (type) {
      case 'WEAPON': {
        return 'crimson';
      }
      case 'ARMOR': {
        return 'brass';
      }
      case 'GEAR': {
        return 'success';
      }
      case 'CYBERNETIC': {
        return 'mystic';
      }
      case 'SHIP_MODULE': {
        return 'darkness';
      }
      default: {
        return 'brass';
      }
    }
  }

  function itemTypeBadgeLabel(type: string): string {
    return t(`itemType.${type}`);
  }

  function itemSummary(item: Item): string {
    if (item.type === 'WEAPON') return `+${String(item.bonus)} / ${String(item.damage)}d`;
    if (item.type === 'ARMOR') return `AR ${String(item.armorRating)}`;
    if (item.type === 'GEAR') return `×${String(item.quantity)}`;
    if (item.type === 'CYBERNETIC') return `${String(item.bodyPoints)} BP`;
    if (item.type === 'SHIP_MODULE') return item.slot;
    return `${String(item.weight)} enc`;
  }

  const isEncumbered = computed<boolean>(
    () => props.character.encumbrance.current > props.character.encumbrance.max,
  );
</script>

<template>
  <section class="share-viewer">
    <!-- ── Parchment disclaimer banner ────────────────────────────────────────── -->
    <AppBanner
      tone="parchment"
      class="share-viewer__banner"
    >
      <template #default>
        <span class="share-viewer__banner-text">
          {{ t('disclaimerReadOnly') }}
        </span>
      </template>
    </AppBanner>

    <!-- ── Hero header ────────────────────────────────────────────────────────── -->
    <div class="share-viewer__hero">
      <div
        class="share-viewer__portrait"
        aria-hidden="true"
      >
        {{ initials(character.name) }}
      </div>

      <div class="share-viewer__identity">
        <div class="share-viewer__concept">
          {{ character.concept || '—' }}
        </div>
        <h1 class="share-viewer__name">
          {{ character.name }}
        </h1>
      </div>

      <!-- HP / MP counters (read-only) -->
      <div class="share-viewer__counters">
        <div class="share-viewer__counter">
          <span class="share-viewer__counter-label">{{ t('labelHp') }}</span>
          <div class="share-viewer__counter-value">
            {{ character.hp.current
            }}<span class="share-viewer__counter-max"> / {{ character.hp.max }}</span>
          </div>
        </div>

        <div class="share-viewer__counter share-viewer__counter--mystic">
          <span class="share-viewer__counter-label">{{ t('labelMp') }}</span>
          <div class="share-viewer__counter-value">
            {{ character.mp.current
            }}<span class="share-viewer__counter-max"> / {{ character.mp.max }}</span>
          </div>
        </div>

        <div
          class="share-viewer__counter share-viewer__counter--enc"
          :class="{ 'share-viewer__counter--enc-warn': isEncumbered }"
        >
          <span class="share-viewer__counter-label">{{ t('labelEnc') }}</span>
          <div class="share-viewer__counter-value">
            {{ character.encumbrance.current
            }}<span class="share-viewer__counter-max"> / {{ character.encumbrance.max }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- ── Encumbrance warning ──────────────────────────────────────────────── -->
    <AppBanner
      v-if="isEncumbered"
      tone="danger"
      class="share-viewer__enc-warning"
      role="status"
    >
      {{ t('encWarning') }}
    </AppBanner>

    <!-- ── Three-column body ───────────────────────────────────────────────── -->
    <div class="share-viewer__columns">
      <!-- LEFT column: Identity + Conditions + Injuries -->
      <div class="share-viewer__col share-viewer__col--left">
        <!-- Identity -->
        <AppCard class="share-viewer__panel">
          <template #header>
            <span class="share-viewer__panel-title">{{ t('panelIdentity') }}</span>
          </template>
          <div class="share-viewer__identity-rows">
            <div class="share-viewer__identity-row">
              <span class="share-viewer__identity-key">{{ t('identityConcept') }}</span>
              <span class="share-viewer__identity-val">{{ character.concept || '—' }}</span>
            </div>
          </div>
        </AppCard>

        <!-- Conditions -->
        <AppCard class="share-viewer__panel">
          <template #header>
            <span class="share-viewer__panel-title">{{ t('panelConditions') }}</span>
          </template>

          <div class="share-viewer__conditions">
            <AppConditionPill
              v-for="key in CONDITION_KEYS"
              :key="key"
              :condition="key"
              :model-value="character.conditions[key]"
              disabled
              size="md"
            >
              {{ conditionLabel(key) }}
            </AppConditionPill>
          </div>

          <!-- Critical injuries -->
          <AppDivider
            tone="brass-deep"
            class="share-viewer__injuries-divider"
          />
          <div class="share-viewer__injuries-header">
            <span class="share-viewer__injuries-title">{{ t('panelCriticalInjuries') }}</span>
          </div>

          <ul
            v-if="character.criticalInjuries.length > 0"
            class="share-viewer__injuries-list"
          >
            <li
              v-for="injury in character.criticalInjuries"
              :key="injury.id"
              class="share-viewer__injury-row"
            >
              <span class="share-viewer__injury-name">{{ injury.name }}</span>
            </li>
          </ul>
          <p
            v-else
            class="share-viewer__placeholder-text"
          >
            {{ t('noInjuries') }}
          </p>
        </AppCard>
      </div>

      <!-- CENTER column: Attributes + Skills -->
      <div class="share-viewer__col share-viewer__col--center">
        <!-- Attributes panel -->
        <AppCard class="share-viewer__panel">
          <template #header>
            <span class="share-viewer__panel-title share-viewer__panel-title--lg">{{
              t('panelAttributes')
            }}</span>
          </template>
          <div class="share-viewer__attrs">
            <AppStatBlock
              v-for="key in ATTR_KEYS"
              :key="key"
              :label="attrLabel(key)"
              :value="character.attributes[key]"
              :max="5"
              size="md"
              tone="brass"
              disabled
              :aria-label="attrLabel(key) + ': ' + String(character.attributes[key])"
            />
          </div>
        </AppCard>

        <!-- Skills panel -->
        <AppCard class="share-viewer__panel">
          <template #header>
            <div class="share-viewer__skills-header">
              <span class="share-viewer__panel-title share-viewer__panel-title--lg">{{
                t('panelSkills')
              }}</span>
              <div class="share-viewer__skills-legend">
                <span
                  class="share-viewer__skills-legend-item share-viewer__skills-legend-item--general"
                >
                  <span class="share-viewer__legend-dot" />{{ t('skillsGeneral') }}
                </span>
                <span
                  class="share-viewer__skills-legend-item share-viewer__skills-legend-item--advanced"
                >
                  <span class="share-viewer__legend-star">✦</span>{{ t('skillsAdvanced') }}
                </span>
              </div>
            </div>
          </template>
          <div class="share-viewer__skills-grid">
            <!-- General column -->
            <div class="share-viewer__skills-col">
              <div class="share-viewer__skills-col-heading">
                {{ t('skillsGeneral') }}
              </div>
              <AppDivider tone="brass-deep" />
              <div
                v-for="sk in GENERAL_SKILLS"
                :key="sk"
                class="share-viewer__skill-row"
                :aria-label="skillLabel(sk) + ': ' + String(character.skills[sk])"
              >
                <span class="share-viewer__skill-name">{{ skillLabel(sk) }}</span>
                <span class="share-viewer__skill-attr">{{ SKILL_GOVERNING_ATTR[sk] }}</span>
                <AppDots
                  :value="character.skills[sk]"
                  :max="5"
                  size="sm"
                  tone="brass"
                  :label="skillLabel(sk)"
                />
              </div>
            </div>

            <!-- Advanced column -->
            <div class="share-viewer__skills-col share-viewer__skills-col--advanced">
              <div
                class="share-viewer__skills-col-heading share-viewer__skills-col-heading--advanced"
              >
                <span class="share-viewer__legend-star">✦</span>
                {{ t('skillsAdvanced') }}
                <span class="share-viewer__skills-advanced-note">{{
                  t('skillsAdvancedNote')
                }}</span>
              </div>
              <AppDivider tone="brass" />
              <div
                v-for="sk in ADVANCED_SKILLS"
                :key="sk"
                class="share-viewer__skill-row share-viewer__skill-row--advanced"
                :aria-label="skillLabel(sk) + ': ' + String(character.skills[sk])"
              >
                <span
                  class="share-viewer__skill-accent-rail"
                  :class="character.skills[sk] > 0 ? 'share-viewer__skill-accent-rail--active' : ''"
                  aria-hidden="true"
                />
                <span class="share-viewer__skill-name">{{ skillLabel(sk) }}</span>
                <span class="share-viewer__skill-attr share-viewer__skill-attr--advanced">{{
                  SKILL_GOVERNING_ATTR[sk]
                }}</span>
                <AppDots
                  :value="character.skills[sk]"
                  :max="5"
                  size="sm"
                  tone="mystic"
                  :label="skillLabel(sk)"
                />
              </div>
            </div>
          </div>
        </AppCard>
      </div>

      <!-- RIGHT column: Talents + Inventory -->
      <div class="share-viewer__col share-viewer__col--right">
        <!-- Talents -->
        <AppCard class="share-viewer__panel">
          <template #header>
            <span class="share-viewer__panel-title">{{ t('panelTalents') }}</span>
          </template>

          <ul
            v-if="character.talents.length > 0"
            class="share-viewer__talents-list"
          >
            <li
              v-for="talent in character.talents"
              :key="talent.id"
              class="share-viewer__talent-row"
            >
              <span class="share-viewer__talent-name">{{ displayTalentName(talent) }}</span>
              <span
                v-if="talent.description"
                class="share-viewer__talent-desc"
              >{{
                displayTalentDescription(talent)
              }}</span>
            </li>
          </ul>
          <p
            v-else
            class="share-viewer__placeholder-text"
          >
            {{ t('noTalents') }}
          </p>
        </AppCard>

        <!-- Inventory -->
        <AppCard class="share-viewer__panel">
          <template #header>
            <span class="share-viewer__panel-title">{{ t('panelInventory') }}</span>
          </template>

          <div
            v-if="character.inventory.length > 0"
            class="share-viewer__inventory-list"
          >
            <div
              v-for="item in character.inventory"
              :key="item.id"
              class="share-viewer__inventory-row"
            >
              <AppBadge
                :variant="itemTypeBadgeVariant(item.type)"
                size="sm"
              >
                {{ itemTypeBadgeLabel(item.type) }}
              </AppBadge>
              <span class="share-viewer__inventory-name">{{ item.name }}</span>
              <span class="share-viewer__inventory-summary">{{ itemSummary(item) }}</span>
            </div>
          </div>
          <p
            v-else
            class="share-viewer__placeholder-text"
          >
            {{ t('inventoryEmpty') }}
          </p>
        </AppCard>
      </div>
    </div>

    <!-- ── Footer ─────────────────────────────────────────────────────────────── -->
    <footer class="share-viewer__footer">
      <p class="share-viewer__footer-credit">
        {{ t('footerCredit') }}
        <a
          href="/"
          class="share-viewer__footer-link"
          data-nav-link="true"
        >Coriolis Companion</a>
      </p>
    </footer>
  </section>
</template>

<i18n lang="json">
{
  "en": {
    "disclaimerReadOnly": "Read-only view — shared by the character's owner. Sign in to create your own character sheet.",
    "labelHp": "HP",
    "labelMp": "MP",
    "labelEnc": "ENC",
    "encWarning": "Encumbered (−1 die to physical actions)",
    "panelIdentity": "Identity",
    "identityConcept": "Concept",
    "panelConditions": "Conditions",
    "panelCriticalInjuries": "Critical Injuries",
    "panelAttributes": "Attributes",
    "panelSkills": "Skills",
    "panelTalents": "Talents",
    "panelInventory": "Inventory",
    "skillsGeneral": "General",
    "skillsAdvanced": "Advanced",
    "skillsAdvancedNote": "requires training",
    "noInjuries": "No critical injuries.",
    "noTalents": "No talents.",
    "inventoryEmpty": "No items.",
    "footerCredit": "Generated by",
    "condition": {
      "exhausted": "Exhausted",
      "sleepless": "Sleepless",
      "thirsty": "Thirsty",
      "hungry": "Hungry"
    },
    "itemType": {
      "WEAPON": "Weapon",
      "ARMOR": "Armor",
      "GEAR": "Gear",
      "CYBERNETIC": "Cyber",
      "SHIP_MODULE": "Module",
      "OTHER": "Other"
    },
    "attr": {
      "strength": "Strength",
      "agility": "Agility",
      "wits": "Wits",
      "empathy": "Empathy"
    },
    "skill": {
      "force": "Force",
      "meleeCombat": "Melee Combat",
      "dexterity": "Dexterity",
      "infiltration": "Infiltration",
      "rangedCombat": "Ranged Combat",
      "observation": "Observation",
      "survival": "Survival",
      "manipulation": "Manipulation",
      "command": "Command",
      "culture": "Culture",
      "dataDjinn": "Data Djinn",
      "medicurgy": "Medicurgy",
      "mysticPowers": "Mystic Powers",
      "pilot": "Pilot",
      "science": "Science",
      "technology": "Technology"
    }
  },
  "ru": {
    "disclaimerReadOnly": "Только чтение — персонаж предоставлен его владельцем. Войдите, чтобы создать свой лист персонажа.",
    "labelHp": "ОЗ",
    "labelMp": "ОР",
    "labelEnc": "ГР",
    "encWarning": "Перегружен (−1 кубик на физические действия)",
    "panelIdentity": "Личность",
    "identityConcept": "Концепция",
    "panelConditions": "Состояния",
    "panelCriticalInjuries": "Критические ранения",
    "panelAttributes": "Атрибуты",
    "panelSkills": "Навыки",
    "panelTalents": "Таланты",
    "panelInventory": "Снаряжение",
    "skillsGeneral": "Общие",
    "skillsAdvanced": "Специальные",
    "skillsAdvancedNote": "требует обучения",
    "noInjuries": "Нет критических ранений.",
    "noTalents": "Нет талантов.",
    "inventoryEmpty": "Нет предметов.",
    "footerCredit": "Создано с помощью",
    "condition": {
      "exhausted": "Истощение",
      "sleepless": "Бессонница",
      "thirsty": "Жажда",
      "hungry": "Голод"
    },
    "itemType": {
      "WEAPON": "Оружие",
      "ARMOR": "Броня",
      "GEAR": "Снар.",
      "CYBERNETIC": "Кибер",
      "SHIP_MODULE": "Модуль",
      "OTHER": "Прочее"
    },
    "attr": {
      "strength": "Сила",
      "agility": "Ловкость",
      "wits": "Ум",
      "empathy": "Эмпатия"
    },
    "skill": {
      "force": "Сила",
      "meleeCombat": "Ближний бой",
      "dexterity": "Ловкость",
      "infiltration": "Скрытность",
      "rangedCombat": "Дальний бой",
      "observation": "Наблюдательность",
      "survival": "Выживание",
      "manipulation": "Манипуляция",
      "command": "Командование",
      "culture": "Культура",
      "dataDjinn": "Дата-джинн",
      "medicurgy": "Медикургия",
      "mysticPowers": "Мистика",
      "pilot": "Пилотаж",
      "science": "Наука",
      "technology": "Технологии"
    }
  },
  "uk": {
    "disclaimerReadOnly": "[uk-todo] Read-only view — shared by the character's owner.",
    "labelHp": "HP",
    "labelMp": "MP",
    "labelEnc": "ENC",
    "encWarning": "[uk-todo] Encumbered (−1 die to physical actions)",
    "panelIdentity": "[uk-todo] Identity",
    "identityConcept": "[uk-todo] Concept",
    "panelConditions": "[uk-todo] Conditions",
    "panelCriticalInjuries": "[uk-todo] Critical Injuries",
    "panelAttributes": "[uk-todo] Attributes",
    "panelSkills": "[uk-todo] Skills",
    "panelTalents": "[uk-todo] Talents",
    "panelInventory": "[uk-todo] Inventory",
    "skillsGeneral": "[uk-todo] General",
    "skillsAdvanced": "[uk-todo] Advanced",
    "skillsAdvancedNote": "[uk-todo] requires training",
    "noInjuries": "[uk-todo] No critical injuries.",
    "noTalents": "[uk-todo] No talents.",
    "inventoryEmpty": "[uk-todo] No items.",
    "footerCredit": "[uk-todo] Generated by",
    "condition": {
      "exhausted": "[uk-todo] Exhausted",
      "sleepless": "[uk-todo] Sleepless",
      "thirsty": "[uk-todo] Thirsty",
      "hungry": "[uk-todo] Hungry"
    },
    "itemType": {
      "WEAPON": "[uk-todo] Weapon",
      "ARMOR": "[uk-todo] Armor",
      "GEAR": "[uk-todo] Gear",
      "CYBERNETIC": "[uk-todo] Cyber",
      "SHIP_MODULE": "[uk-todo] Module",
      "OTHER": "[uk-todo] Other"
    },
    "attr": {
      "strength": "[uk-todo] Strength",
      "agility": "[uk-todo] Agility",
      "wits": "[uk-todo] Wits",
      "empathy": "[uk-todo] Empathy"
    },
    "skill": {
      "force": "[uk-todo] Force",
      "meleeCombat": "[uk-todo] Melee Combat",
      "dexterity": "[uk-todo] Dexterity",
      "infiltration": "[uk-todo] Infiltration",
      "rangedCombat": "[uk-todo] Ranged Combat",
      "observation": "[uk-todo] Observation",
      "survival": "[uk-todo] Survival",
      "manipulation": "[uk-todo] Manipulation",
      "command": "[uk-todo] Command",
      "culture": "[uk-todo] Culture",
      "dataDjinn": "[uk-todo] Data Djinn",
      "medicurgy": "[uk-todo] Medicurgy",
      "mysticPowers": "[uk-todo] Mystic Powers",
      "pilot": "[uk-todo] Pilot",
      "science": "[uk-todo] Science",
      "technology": "[uk-todo] Technology"
    }
  },
  "el": {
    "disclaimerReadOnly": "[el-todo] Read-only view — shared by the character's owner.",
    "labelHp": "HP",
    "labelMp": "MP",
    "labelEnc": "ENC",
    "encWarning": "[el-todo] Encumbered (−1 die to physical actions)",
    "panelIdentity": "[el-todo] Identity",
    "identityConcept": "[el-todo] Concept",
    "panelConditions": "[el-todo] Conditions",
    "panelCriticalInjuries": "[el-todo] Critical Injuries",
    "panelAttributes": "[el-todo] Attributes",
    "panelSkills": "[el-todo] Skills",
    "panelTalents": "[el-todo] Talents",
    "panelInventory": "[el-todo] Inventory",
    "skillsGeneral": "[el-todo] General",
    "skillsAdvanced": "[el-todo] Advanced",
    "skillsAdvancedNote": "[el-todo] requires training",
    "noInjuries": "[el-todo] No critical injuries.",
    "noTalents": "[el-todo] No talents.",
    "inventoryEmpty": "[el-todo] No items.",
    "footerCredit": "[el-todo] Generated by",
    "condition": {
      "exhausted": "[el-todo] Exhausted",
      "sleepless": "[el-todo] Sleepless",
      "thirsty": "[el-todo] Thirsty",
      "hungry": "[el-todo] Hungry"
    },
    "itemType": {
      "WEAPON": "[el-todo] Weapon",
      "ARMOR": "[el-todo] Armor",
      "GEAR": "[el-todo] Gear",
      "CYBERNETIC": "[el-todo] Cyber",
      "SHIP_MODULE": "[el-todo] Module",
      "OTHER": "[el-todo] Other"
    },
    "attr": {
      "strength": "[el-todo] Strength",
      "agility": "[el-todo] Agility",
      "wits": "[el-todo] Wits",
      "empathy": "[el-todo] Empathy"
    },
    "skill": {
      "force": "[el-todo] Force",
      "meleeCombat": "[el-todo] Melee Combat",
      "dexterity": "[el-todo] Dexterity",
      "infiltration": "[el-todo] Infiltration",
      "rangedCombat": "[el-todo] Ranged Combat",
      "observation": "[el-todo] Observation",
      "survival": "[el-todo] Survival",
      "manipulation": "[el-todo] Manipulation",
      "command": "[el-todo] Command",
      "culture": "[el-todo] Culture",
      "dataDjinn": "[el-todo] Data Djinn",
      "medicurgy": "[el-todo] Medicurgy",
      "mysticPowers": "[el-todo] Mystic Powers",
      "pilot": "[el-todo] Pilot",
      "science": "[el-todo] Science",
      "technology": "[el-todo] Technology"
    }
  }
}
</i18n>

<style lang="scss" scoped>
  $column-gap: 24px;
  $hero-padding-v: 32px;
  $hero-padding-h: 40px;
  $portrait-size: 80px;
  $portrait-size-mobile: 48px;
  $counter-min-width: 90px;
  $col-left-pct: 28%;
  $col-center-pct: 44%;
  $col-right-pct: 28%;
  $font-size-eyebrow: 11px;
  $font-size-legend: 10px;
  $legend-dot-size: 8px;
  $bp-desktop: 1024px;
  $bp-mobile: 768px;
  // Font size SCSS vars (raw px forbidden inline by stylelint token rules)
  $font-size-portrait: 24px;
  $font-size-portrait-mobile: 16px;
  $font-size-name: 28px;
  $font-size-counter-value: 28px;
  $font-size-counter-max: 16px;
  $font-size-panel-title: 13px;
  $font-size-panel-title-lg: 15px;
  // Accent rail dimensions (px values must live in SCSS vars)
  $accent-rail-width: 3px;
  $accent-rail-height: 16px;

  .share-viewer {
    display: flex;
    flex-direction: column;
    gap: var(--space-6);

    // ── Parchment banner ────────────────────────────────────────────────────────

    &__banner {
      margin-bottom: var(--space-2);
    }

    &__banner-text {
      font-style: italic;
    }

    // ── Hero ─────────────────────────────────────────────────────────────────────

    &__hero {
      display: flex;
      align-items: center;
      gap: var(--space-6);
      padding: $hero-padding-v $hero-padding-h;
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-lg);

      @media (max-width: $bp-mobile) {
        flex-direction: column;
        align-items: flex-start;
        padding: var(--space-4);
        gap: var(--space-4);
      }
    }

    &__portrait {
      width: $portrait-size;
      height: $portrait-size;
      border-radius: 50%;
      background-color: var(--brand-brass-deep);
      color: var(--brand-brass-light);
      display: flex;
      align-items: center;
      justify-content: center;
      font-family: var(--type-display-font-family);
      font-size: $font-size-portrait;
      font-weight: 700;
      letter-spacing: 0.05em;
      flex-shrink: 0;

      @media (max-width: $bp-mobile) {
        width: $portrait-size-mobile;
        height: $portrait-size-mobile;
        font-size: $font-size-portrait-mobile;
      }
    }

    &__identity {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
      flex: 1;
      min-width: 0;
    }

    &__concept {
      font-size: $font-size-eyebrow;
      text-transform: uppercase;
      letter-spacing: 0.18em;
      color: var(--brand-brass);
      font-family: var(--type-body-sm-font-family);
    }

    &__name {
      font-family: var(--type-display-font-family);
      font-size: $font-size-name;
      font-weight: 400;
      color: var(--brand-brass-light);
      margin: 0;
      line-height: 1.2;
    }

    // ── Counters ─────────────────────────────────────────────────────────────────

    &__counters {
      display: flex;
      gap: var(--space-6);
      flex-shrink: 0;

      @media (max-width: $bp-mobile) {
        gap: var(--space-4);
      }
    }

    &__counter {
      display: flex;
      flex-direction: column;
      align-items: center;
      min-width: $counter-min-width;

      &--mystic {
        .share-viewer__counter-label {
          color: var(--state-mystic-teal);
        }

        .share-viewer__counter-value {
          color: var(--state-mystic-teal);
        }
      }

      &--enc-warn {
        .share-viewer__counter-value {
          color: var(--state-crimson-bright);
        }
      }
    }

    &__counter-label {
      font-size: $font-size-eyebrow;
      text-transform: uppercase;
      letter-spacing: 0.18em;
      color: var(--brand-brass);
      font-family: var(--type-body-sm-font-family);
    }

    &__counter-value {
      font-family: var(--type-mono-font-family, monospace);
      font-size: $font-size-counter-value;
      font-weight: 700;
      color: var(--text-primary);
      line-height: 1.1;
    }

    &__counter-max {
      font-size: $font-size-counter-max;
      font-weight: 400;
      color: var(--text-secondary);
    }

    // ── Encumbrance warning ─────────────────────────────────────────────────────

    &__enc-warning {
      margin-top: calc(-1 * var(--space-3));
    }

    // ── Three-column layout ──────────────────────────────────────────────────────

    &__columns {
      display: flex;
      gap: $column-gap;
      align-items: flex-start;

      @media (max-width: $bp-desktop) {
        flex-direction: column;
      }
    }

    &__col {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);

      &--left {
        width: $col-left-pct;
        flex-shrink: 0;

        @media (max-width: $bp-desktop) {
          width: 100%;
        }
      }

      &--center {
        width: $col-center-pct;
        flex-shrink: 0;

        @media (max-width: $bp-desktop) {
          width: 100%;
        }
      }

      &--right {
        flex: 1;
        min-width: 0;

        @media (max-width: $bp-desktop) {
          width: 100%;
        }
      }
    }

    // ── Panels ────────────────────────────────────────────────────────────────────

    &__panel {
      width: 100%;
    }

    &__panel-title {
      font-family: var(--type-display-font-family);
      font-size: $font-size-panel-title;
      text-transform: uppercase;
      letter-spacing: 0.14em;
      color: var(--brand-brass);

      &--lg {
        font-size: $font-size-panel-title-lg;
      }
    }

    // ── Identity ──────────────────────────────────────────────────────────────────

    &__identity-rows {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__identity-row {
      display: flex;
      justify-content: space-between;
      gap: var(--space-2);
    }

    &__identity-key {
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    &__identity-val {
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
      text-align: right;
    }

    // ── Conditions ────────────────────────────────────────────────────────────────

    &__conditions {
      display: flex;
      flex-wrap: wrap;
      gap: var(--space-2);
      margin-bottom: var(--space-3);
    }

    &__injuries-divider {
      margin: var(--space-3) 0;
    }

    &__injuries-header {
      margin-bottom: var(--space-2);
    }

    &__injuries-title {
      font-size: $font-size-eyebrow;
      text-transform: uppercase;
      letter-spacing: 0.12em;
      color: var(--text-secondary);
      font-family: var(--type-body-sm-font-family);
    }

    &__injuries-list {
      list-style: none;
      padding: 0;
      margin: 0 0 var(--space-2);
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__injury-row {
      display: flex;
      align-items: center;
      gap: var(--space-2);
      padding: var(--space-1) 0;
      border-bottom: 1px solid var(--brand-brass-deep);

      &:last-child {
        border-bottom: none;
      }
    }

    &__injury-name {
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
    }

    // ── Attributes ────────────────────────────────────────────────────────────────

    &__attrs {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: var(--space-3);

      @media (min-width: $bp-desktop) {
        grid-template-columns: repeat(4, 1fr);
      }
    }

    // ── Skills ────────────────────────────────────────────────────────────────────

    &__skills-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: var(--space-2);
    }

    &__skills-legend {
      display: flex;
      gap: var(--space-3);
    }

    &__skills-legend-item {
      display: flex;
      align-items: center;
      gap: var(--space-1);
      font-size: $font-size-legend;
      color: var(--text-secondary);
    }

    &__legend-dot {
      width: $legend-dot-size;
      height: $legend-dot-size;
      border-radius: 50%;
      background-color: var(--brand-brass);
      display: inline-block;
    }

    &__legend-star {
      color: var(--state-mystic-teal);
      font-size: $font-size-legend;
    }

    &__skills-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: var(--space-4);

      @media (max-width: $bp-mobile) {
        grid-template-columns: 1fr;
      }
    }

    &__skills-col {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__skills-col-heading {
      font-size: $font-size-eyebrow;
      text-transform: uppercase;
      letter-spacing: 0.12em;
      color: var(--text-secondary);
      font-family: var(--type-body-sm-font-family);
      padding-bottom: var(--space-1);
      display: flex;
      align-items: center;
      gap: var(--space-1);

      &--advanced {
        color: var(--state-mystic-teal);
      }
    }

    &__skills-advanced-note {
      font-style: italic;
      font-size: $font-size-legend;
      text-transform: none;
      letter-spacing: 0;
      color: var(--text-secondary);
    }

    &__skill-row {
      display: flex;
      align-items: center;
      gap: var(--space-2);
      padding: var(--space-1) 0;
      border-bottom: 1px solid color-mix(in srgb, var(--brand-brass-deep) 40%, transparent);

      &:last-child {
        border-bottom: none;
      }

      &--advanced {
        position: relative;
      }
    }

    &__skill-accent-rail {
      width: $accent-rail-width;
      height: $accent-rail-height;
      border-radius: 2px;
      background-color: var(--brand-brass-deep);
      flex-shrink: 0;

      &--active {
        background-color: var(--state-mystic-teal);
      }
    }

    &__skill-name {
      flex: 1;
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
      min-width: 0;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    &__skill-attr {
      font-size: $font-size-legend;
      text-transform: uppercase;
      letter-spacing: 0.12em;
      color: var(--brand-brass);
      font-family: var(--type-body-sm-font-family);
      flex-shrink: 0;

      &--advanced {
        color: var(--state-mystic-teal);
      }
    }

    // ── Talents ───────────────────────────────────────────────────────────────────

    &__talents-list {
      list-style: none;
      padding: 0;
      margin: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__talent-row {
      padding: var(--space-2) 0;
      border-bottom: 1px solid var(--brand-brass-deep);
      display: flex;
      flex-direction: column;
      gap: var(--space-1);

      &:last-child {
        border-bottom: none;
      }
    }

    &__talent-name {
      font-size: var(--type-body-sm-font-size);
      font-weight: 600;
      color: var(--text-primary);
    }

    &__talent-desc {
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      line-height: 1.4;
    }

    // ── Inventory ─────────────────────────────────────────────────────────────────

    &__inventory-list {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__inventory-row {
      display: flex;
      align-items: center;
      gap: var(--space-2);
      padding: var(--space-1) 0;
      border-bottom: 1px solid color-mix(in srgb, var(--brand-brass-deep) 40%, transparent);

      &:last-child {
        border-bottom: none;
      }
    }

    &__inventory-name {
      flex: 1;
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
      min-width: 0;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    &__inventory-summary {
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      flex-shrink: 0;
    }

    // ── Placeholder text ─────────────────────────────────────────────────────────

    &__placeholder-text {
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
      margin: 0;
    }

    // ── Footer ────────────────────────────────────────────────────────────────────

    &__footer {
      text-align: center;
      padding: var(--space-4) 0 var(--space-8);
    }

    &__footer-credit {
      font-size: $font-size-legend;
      color: var(--text-secondary);
      font-style: italic;
      margin: 0;
    }

    &__footer-link {
      color: var(--brand-brass);
      text-decoration: none;

      &:hover {
        text-decoration: underline;
        color: var(--brand-brass-light);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
        border-radius: var(--radius-sm);
      }
    }
  }
</style>
