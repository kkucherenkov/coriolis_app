<script setup lang="ts">
  import { computed } from 'vue';
  import type { Concept, Role, Skills } from '@app/api-client-ts';
  import { keySkillsForRole } from '~/utils/roleCatalogue';

  // ST3001 ch.2 table 2.4 — single skill-point pool sized by upbringing.
  // Per-skill caps at creation depend on the chosen role: the role's
  // four key skills cap at 3, every other skill caps at 1. Falls back
  // to the concept-union (5 skills) when role is null (legacy drafts
  // without a role-pick — Block 4 will surface a roleUnmigrated banner
  // for those). The General / Advanced split in the layout below is
  // purely visual — it groups skills by the ch.3 action-economy rule
  // (advanced skills require ≥1 rank to roll), not by an artificial
  // pool partition.
  type Upbringing = 'plebeian' | 'stationary' | 'aristocrat';

  const props = defineProps<Props>();

  const emit = defineEmits<{
    'update:skills': [value: Skills];
  }>();

  const SKILL_BUDGET: Record<Upbringing, number> = {
    plebeian: 8,
    stationary: 10,
    aristocrat: 12,
  };

  const CONCEPT_KEY_SKILLS: Record<Concept, readonly (keyof Skills)[]> = {
    artist: ['manipulation', 'culture', 'dexterity', 'observation', 'infiltration'],
    networker: ['dataDjinn', 'culture', 'manipulation', 'observation', 'infiltration'],
    fugitive: ['meleeCombat', 'infiltration', 'culture', 'mysticPowers', 'manipulation'],
    negotiator: ['manipulation', 'culture', 'observation', 'command', 'infiltration'],
    operative: ['meleeCombat', 'rangedCombat', 'infiltration', 'observation', 'manipulation'],
    pilot: ['pilot', 'rangedCombat', 'technology', 'observation', 'dataDjinn'],
    pioneer: ['survival', 'observation', 'technology', 'infiltration', 'science'],
    preacher: ['culture', 'mysticPowers', 'manipulation', 'command', 'observation'],
    scientist: ['science', 'culture', 'technology', 'medicurgy', 'dataDjinn'],
    sailor: ['meleeCombat', 'force', 'technology', 'observation', 'pilot'],
    soldier: ['rangedCombat', 'meleeCombat', 'force', 'command', 'observation'],
  };

  const KEY_SKILL_MAX = 3;
  const NONKEY_SKILL_MAX = 1;
  /** Total dots rendered for every skill row — enough to cover key skills (3 ranks). */
  const DOT_COUNT = 3;

  interface Props {
    skills: Skills;
    upbringing: Upbringing | null;
    concept: Concept | null;
    role: Role | null;
  }

  const keySkillSet = computed<ReadonlySet<keyof Skills>>(() => {
    // Role wins when present — the four canonical key skills per
    // ST3001 ГЛАВА 2 «АМПЛУА И РОЛИ» / «КЛЮЧЕВЫЕ НАВЫКИ».
    if (props.role) return new Set(keySkillsForRole(props.role));
    // Legacy fallback: concept-union (5 skills) when no role is picked
    // yet. The wizard's role step (Step 5) lands the role for new
    // drafts; legacy drafts get the union until the user re-confirms
    // via the roleUnmigrated banner (Block 4).
    if (props.concept) return new Set(CONCEPT_KEY_SKILLS[props.concept]);
    return new Set();
  });

  function maxRank(key: keyof Skills): number {
    return keySkillSet.value.has(key) ? KEY_SKILL_MAX : NONKEY_SKILL_MAX;
  }

  const pool = computed<number>(() =>
    props.upbringing ? SKILL_BUDGET[props.upbringing] : SKILL_BUDGET.stationary,
  );

  const { t } = useI18n({ useScope: 'local' });

  /** Localised, comma-separated list of the role's 4 key skill labels.
   *  Empty when no role is picked yet. */
  const keySkillsLabel = computed<string>(() => {
    if (!props.role) return '';
    return keySkillsForRole(props.role)
      .map((key) => t(`skill.${key}`))
      .join(', ');
  });

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

  const GENERAL_KEYS: GeneralSkillKey[] = [
    'force',
    'meleeCombat',
    'dexterity',
    'infiltration',
    'rangedCombat',
    'observation',
    'survival',
    'manipulation',
  ];

  const ADVANCED_KEYS: AdvancedSkillKey[] = [
    'command',
    'culture',
    'dataDjinn',
    'medicurgy',
    'mysticPowers',
    'pilot',
    'science',
    'technology',
  ];

  const SKILL_ATTR: Record<keyof Skills, string> = {
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

  const spent = computed<number>(() =>
    [...GENERAL_KEYS, ...ADVANCED_KEYS].reduce((s, k) => s + props.skills[k], 0),
  );

  const remaining = computed<number>(() => pool.value - spent.value);

  function canIncrement(key: keyof Skills): boolean {
    return props.skills[key] < maxRank(key) && remaining.value > 0;
  }

  function canDecrement(key: keyof Skills): boolean {
    return props.skills[key] > 0;
  }

  function setSkill(key: keyof Skills, delta: 1 | -1): void {
    if (delta === 1 && !canIncrement(key)) return;
    if (delta === -1 && !canDecrement(key)) return;
    emit('update:skills', { ...props.skills, [key]: props.skills[key] + delta });
  }

  function onDotClick(key: keyof Skills, dotIdx: number): void {
    // dotIdx is 0-based; clicking a filled dot clears to that level, clicking empty sets to dotIdx+1
    const newVal = dotIdx + 1 === props.skills[key] ? dotIdx : dotIdx + 1;
    const delta = newVal - props.skills[key];
    if (delta > 0 && (newVal > maxRank(key) || delta > remaining.value)) return;
    emit('update:skills', { ...props.skills, [key]: newVal });
  }
</script>

<i18n lang="json">
{
  "en": {
    "generalTitle": "General Skills",
    "advancedTitle": "Advanced Skills",
    "pointsLeft": "Points left",
    "hint": "{pool} skill points · Key skills up to {max}, others up to {nonKeyMax}.",
    "keySkillsForRole": "Key skills for your role: {skills} (max {max} each).",
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
      "science": "Science!",
      "technology": "Technology"
    },
    "decrementAria": "Decrease {skill}",
    "incrementAria": "Increase {skill}"
  },
  "ru": {
    "generalTitle": "Общие навыки",
    "advancedTitle": "Продвинутые навыки",
    "pointsLeft": "Осталось",
    "hint": "Очков навыков: {pool} · Ключевые до {max}, остальные до {nonKeyMax}.",
    "keySkillsForRole": "Ключевые навыки роли: {skills} (по {max} макс.).",
    "skill": {
      "force": "Сила",
      "meleeCombat": "Рукопашный бой",
      "dexterity": "Ловкость",
      "infiltration": "Инфильтрация",
      "rangedCombat": "Дальний бой",
      "observation": "Наблюдение",
      "survival": "Выживание",
      "manipulation": "Манипуляция",
      "command": "Командование",
      "culture": "Культура",
      "dataDjinn": "Дата-джинн",
      "medicurgy": "Медицинские технологии",
      "mysticPowers": "Мистические силы",
      "pilot": "Пилот",
      "science": "Наука!",
      "technology": "Технология"
    },
    "decrementAria": "Уменьшить {skill}",
    "incrementAria": "Увеличить {skill}"
  }
}
</i18n>

<template>
  <div class="step-6-skills">
    <p class="step-6-skills__hint">
      {{
        t('hint', {
          pool: pool,
          max: KEY_SKILL_MAX,
          nonKeyMax: NONKEY_SKILL_MAX,
        })
      }}
    </p>
    <p v-if="role" class="step-6-skills__role-hint">
      {{ t('keySkillsForRole', { skills: keySkillsLabel, max: KEY_SKILL_MAX }) }}
    </p>

    <div class="step-6-skills__cols">
      <!-- General skills -->
      <div class="step-6-skills__panel">
        <div class="step-6-skills__panel-header">
          <span class="step-6-skills__panel-title">{{ t('generalTitle') }}</span>
          <span
            class="step-6-skills__pool"
            :class="{ 'step-6-skills__pool--done': remaining === 0 }"
          >
            {{ t('pointsLeft') }}: {{ remaining }}
          </span>
        </div>

        <div v-for="key in GENERAL_KEYS" :key="key" class="step-6-skills__row">
          <span class="step-6-skills__name">{{ t(`skill.${key}`) }}</span>
          <span class="step-6-skills__attr">{{ SKILL_ATTR[key] }}</span>
          <div class="step-6-skills__dots" role="group" :aria-label="t(`skill.${key}`)">
            <span
              v-for="i in DOT_COUNT"
              :key="i"
              class="step-6-skills__dot"
              :class="{ 'step-6-skills__dot--filled': i - 1 < skills[key] }"
              role="button"
              tabindex="0"
              :aria-pressed="i - 1 < skills[key]"
              @click="onDotClick(key, i - 1)"
              @keydown.enter.space.prevent="onDotClick(key, i - 1)"
            />
          </div>
          <span class="step-6-skills__val">{{ skills[key] }}</span>
          <div class="step-6-skills__btns">
            <button
              class="step-6-skills__btn"
              type="button"
              :disabled="!canDecrement(key)"
              :aria-label="t('decrementAria', { skill: t(`skill.${key}`) })"
              @click="setSkill(key, -1)"
            >
              &minus;
            </button>
            <button
              class="step-6-skills__btn"
              type="button"
              :disabled="!canIncrement(key)"
              :aria-label="t('incrementAria', { skill: t(`skill.${key}`) })"
              @click="setSkill(key, 1)"
            >
              &plus;
            </button>
          </div>
        </div>
      </div>

      <!-- Advanced skills -->
      <div class="step-6-skills__panel">
        <div class="step-6-skills__panel-header">
          <span class="step-6-skills__panel-title">{{ t('advancedTitle') }}</span>
          <span
            class="step-6-skills__pool"
            :class="{ 'step-6-skills__pool--done': remaining === 0 }"
          >
            {{ t('pointsLeft') }}: {{ remaining }}
          </span>
        </div>

        <div v-for="key in ADVANCED_KEYS" :key="key" class="step-6-skills__row">
          <span class="step-6-skills__name">{{ t(`skill.${key}`) }}</span>
          <span class="step-6-skills__attr">{{ SKILL_ATTR[key] }}</span>
          <div class="step-6-skills__dots" role="group" :aria-label="t(`skill.${key}`)">
            <span
              v-for="i in DOT_COUNT"
              :key="i"
              class="step-6-skills__dot"
              :class="{ 'step-6-skills__dot--filled': i - 1 < skills[key] }"
              role="button"
              tabindex="0"
              :aria-pressed="i - 1 < skills[key]"
              @click="onDotClick(key, i - 1)"
              @keydown.enter.space.prevent="onDotClick(key, i - 1)"
            />
          </div>
          <span class="step-6-skills__val">{{ skills[key] }}</span>
          <div class="step-6-skills__btns">
            <button
              class="step-6-skills__btn"
              type="button"
              :disabled="!canDecrement(key)"
              :aria-label="t('decrementAria', { skill: t(`skill.${key}`) })"
              @click="setSkill(key, -1)"
            >
              &minus;
            </button>
            <button
              class="step-6-skills__btn"
              type="button"
              :disabled="!canIncrement(key)"
              :aria-label="t('incrementAria', { skill: t(`skill.${key}`) })"
              @click="setSkill(key, 1)"
            >
              &plus;
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  // Named SCSS layout variables — permitted escape hatch for pixel dimensions.
  $dot-size: 12px;
  $skills-max-width: 1080px;
  $skill-col-attr: 36px;
  $skill-col-val: 28px;
  $skill-col-ctrl: 72px;
  $btn-size: 28px;

  .step-6-skills {
    &__hint {
      margin: 0 0 var(--space-3);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
      text-align: center;
    }

    &__role-hint {
      margin: 0 0 var(--space-6);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-brass);
      text-align: center;
    }

    &__cols {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: var(--space-5);
      max-width: $skills-max-width;
      margin: 0 auto;

      @media (max-width: 768px) {
        grid-template-columns: 1fr;
      }
    }

    &__panel {
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      padding: var(--space-5);
    }

    &__panel-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: var(--space-4);
      padding-bottom: var(--space-3);
      border-bottom: 1px solid var(--brand-brass-shadow);
    }

    &__panel-title {
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      font-weight: var(--type-display-sm-font-weight);
      color: var(--brand-brass-light);
      text-transform: uppercase;
      letter-spacing: 0.1em;
    }

    &__pool {
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--brand-brass);
      text-transform: uppercase;
      letter-spacing: 0.12em;

      &--done {
        color: var(--state-success);
      }
    }

    &__row {
      display: grid;
      grid-template-columns: 1fr $skill-col-attr auto $skill-col-val $skill-col-ctrl;
      align-items: center;
      gap: var(--space-2);
      padding: var(--space-2) 0;
      border-bottom: 1px solid color-mix(in srgb, var(--brand-brass) 20%, transparent);

      &:last-child {
        border-bottom: none;
      }
    }

    &__name {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
    }

    &__attr {
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--brand-brass);
      text-transform: uppercase;
      letter-spacing: 0.12em;
      text-align: center;
    }

    &__dots {
      display: flex;
      gap: var(--space-1);
      align-items: center;
    }

    &__dot {
      width: $dot-size;
      height: $dot-size;
      border-radius: var(--radius-pill);
      border: 1px solid var(--brand-brass-shadow);
      background-color: transparent;
      cursor: pointer;
      flex-shrink: 0;
      transition: background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &--filled {
        background-color: var(--brand-brass);
        border-color: var(--brand-brass);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    &__val {
      font-family: var(--font-mono);
      font-size: var(--type-body-md-font-size);
      color: var(--text-primary);
      text-align: center;
    }

    &__btns {
      display: flex;
      gap: var(--space-1);
      justify-content: flex-end;
    }

    &__btn {
      width: $btn-size;
      height: $btn-size;
      display: flex;
      align-items: center;
      justify-content: center;
      background: transparent;
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-sm);
      color: var(--brand-brass);
      font-size: var(--type-body-md-font-size);
      cursor: pointer;
      transition:
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover:not(:disabled) {
        border-color: var(--brand-brass);
        color: var(--brand-brass-light);
      }

      &:disabled {
        opacity: 0.3;
        cursor: not-allowed;
      }
    }
  }
</style>
