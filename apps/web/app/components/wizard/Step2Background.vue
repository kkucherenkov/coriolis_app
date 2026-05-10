<script setup lang="ts">
  import { AppSegControl, AppField, AppInput } from '@app/ui';
  import { computed } from 'vue';

  // ST3001 ch.2, table 2.2 — three canonical upbringings.
  type Upbringing = 'plebeian' | 'stationary' | 'aristocrat';
  // ST3001 ch.2 §АМПЛУА КОМАНДЫ — five canonical crew amplua.
  type CrewConcept = 'free-trader' | 'mercenary' | 'explorer' | 'agents' | 'pilgrim';

  const props = defineProps<Props>();

  const emit = defineEmits<{
    'update:origin': [value: string | null];
    'update:upbringing': [value: Upbringing];
    'update:crewConcept': [value: CrewConcept | null];
    'update:age': [value: number | null];
  }>();

  const CREW_CONCEPTS: readonly CrewConcept[] = [
    'free-trader',
    'mercenary',
    'explorer',
    'agents',
    'pilgrim',
  ];

  interface UpbringingBudget {
    attributes: number;
    skills: number;
    reputation: number;
    wealth: number;
  }

  const UPBRINGING_BUDGETS: Record<Upbringing, UpbringingBudget> = {
    plebeian: { attributes: 15, skills: 8, reputation: 2, wealth: 500 },
    stationary: { attributes: 14, skills: 10, reputation: 4, wealth: 1000 },
    aristocrat: { attributes: 13, skills: 12, reputation: 6, wealth: 5000 },
  };

  interface Props {
    origin: string | null;
    upbringing: Upbringing | null;
    crewConcept: CrewConcept | null;
    age: number | null;
  }

  const { t } = useI18n({ useScope: 'local' });

  const upbringingOptions = computed(() => [
    { value: 'plebeian', label: t('upbringing.plebeian') },
    { value: 'stationary', label: t('upbringing.stationary') },
    { value: 'aristocrat', label: t('upbringing.aristocrat') },
  ]);

  const selectedBudget = computed<UpbringingBudget | null>(() =>
    props.upbringing ? UPBRINGING_BUDGETS[props.upbringing] : null,
  );

  const ageStr = computed<string>(() => (props.age !== null ? String(props.age) : ''));

  function onOriginInput(val: string | number | null): void {
    const s = val !== null && val !== '' ? String(val) : null;
    emit('update:origin', s);
  }

  function onUpbringingChange(val: string | number | null): void {
    if (val === 'plebeian' || val === 'stationary' || val === 'aristocrat') {
      emit('update:upbringing', val);
    }
  }

  function onCrewToggle(value: CrewConcept): void {
    emit('update:crewConcept', props.crewConcept === value ? null : value);
  }

  function isCrewSelected(value: CrewConcept): boolean {
    return props.crewConcept === value;
  }

  function onAgeInput(val: string | number | null): void {
    const raw = typeof val === 'number' ? val : Number.parseInt(val ?? '', 10);
    emit('update:age', Number.isFinite(raw) ? raw : null);
  }
</script>

<i18n lang="json">
{
  "en": {
    "originLabel": "Origin",
    "originPlaceholder": "Where do you come from?",
    "originHelp": "Free text — home station, planet, or region of the Third Horizon. Has no mechanical effect.",
    "upbringingLabel": "Upbringing",
    "upbringingHelp": "Determines your starting attribute and skill points, your reputation, and your starting wealth.",
    "upbringing": {
      "plebeian": "Plebeian",
      "stationary": "Stationary",
      "aristocrat": "Aristocrat"
    },
    "upbringingDesc": {
      "plebeian": "Workers, colonists, nomads — the Horizon's lower stratum.",
      "stationary": "Asteroid-dwellers and inhabitants of the great stations.",
      "aristocrat": "Bureaucrats, factionists, hereditary elites and the wealthiest merchants."
    },
    "budget": {
      "title": "Starting budget",
      "attributes": "Attribute points",
      "skills": "Skill points",
      "reputation": "Reputation",
      "wealth": "Birrs",
      "selectPrompt": "Select an upbringing to see your starting budget."
    },
    "crewLabel": "Crew",
    "crewHelp": "What sort of crew are you part of? The whole team shares one — pick whichever you'd like.",
    "crew": {
      "free-trader": "Free Traders",
      "mercenary": "Mercenaries",
      "explorer": "Explorers",
      "agents": "Agents",
      "pilgrim": "Pilgrims"
    },
    "crewDesc": {
      "free-trader": "Merchants and smugglers running cargo across the Horizon.",
      "mercenary": "Soldiers of fortune, pirates, and revolutionaries who fight for pay or cause.",
      "explorer": "Truth-seekers, prospectors, colonists, journalists chasing the unknown.",
      "agents": "Faction operatives — enforcers, spies, assassins working in the shadows.",
      "pilgrim": "Believers and travellers walking the holy routes of the Horizon."
    },
    "ageLabel": "Age",
    "agePlaceholder": "e.g. 28",
    "ageHelp": "Optional. Any positive integer."
  },
  "ru": {
    "originLabel": "Происхождение",
    "originPlaceholder": "Откуда вы родом?",
    "originHelp": "Свободный текст — станция, планета или регион Третьего горизонта. Без механического эффекта.",
    "upbringingLabel": "Воспитание",
    "upbringingHelp": "Определяет стартовые очки характеристик и навыков, репутацию и начальное богатство.",
    "upbringing": {
      "plebeian": "Плебей",
      "stationary": "Орбитал",
      "aristocrat": "Аристократ"
    },
    "upbringingDesc": {
      "plebeian": "Рабочие, колонисты, кочевники — низший социальный пласт Горизонта.",
      "stationary": "Астероидяне и обитатели больших космических станций.",
      "aristocrat": "Бюрократы, фабриканты, чистокровная элита и богатейшие купцы."
    },
    "budget": {
      "title": "Стартовый бюджет",
      "attributes": "Очки характеристик",
      "skills": "Очки навыков",
      "reputation": "Репутация",
      "wealth": "Бирры",
      "selectPrompt": "Выберите воспитание, чтобы увидеть стартовый бюджет."
    },
    "crewLabel": "Команда",
    "crewHelp": "К какой команде вы относитесь? Все игроки делят одну — выберите подходящую.",
    "crew": {
      "free-trader": "Вольные торговцы",
      "mercenary": "Наёмники",
      "explorer": "Исследователи",
      "agents": "Агенты",
      "pilgrim": "Пилигримы"
    },
    "crewDesc": {
      "free-trader": "Купцы и контрабандисты, перевозящие грузы по Горизонту.",
      "mercenary": "Солдаты удачи, пираты и повстанцы — за деньги или идею.",
      "explorer": "Искатели истины, старатели, колонисты, журналисты.",
      "agents": "Оперативники фракций — каратели, шпионы, ассасины в тени.",
      "pilgrim": "Верующие и странники, идущие по святым путям Горизонта."
    },
    "ageLabel": "Возраст",
    "agePlaceholder": "напр. 28",
    "ageHelp": "Необязательно. Любое положительное число."
  },
  "uk": {
    "originLabel": "[uk-todo] Origin",
    "originPlaceholder": "[uk-todo] Where do you come from?",
    "originHelp": "[uk-todo] Home station or planet.",
    "upbringingLabel": "[uk-todo] Upbringing",
    "upbringingHelp": "[uk-todo] Drives starting points and wealth.",
    "upbringing": {
      "plebeian": "[uk-todo] Plebeian",
      "stationary": "[uk-todo] Stationary",
      "aristocrat": "[uk-todo] Aristocrat"
    },
    "upbringingDesc": {
      "plebeian": "[uk-todo] Workers and colonists.",
      "stationary": "[uk-todo] Station dwellers.",
      "aristocrat": "[uk-todo] Hereditary elites."
    },
    "budget": {
      "title": "[uk-todo] Starting budget",
      "attributes": "[uk-todo] Attribute pts",
      "skills": "[uk-todo] Skill pts",
      "reputation": "[uk-todo] Reputation",
      "wealth": "[uk-todo] Birrs",
      "selectPrompt": "[uk-todo] Select an upbringing."
    },
    "crewLabel": "[uk-todo] Crew",
    "crewHelp": "[uk-todo] Pick the team's crew amplua.",
    "crew": {
      "free-trader": "[uk-todo] Free Traders",
      "mercenary": "[uk-todo] Mercenaries",
      "explorer": "[uk-todo] Explorers",
      "agents": "[uk-todo] Agents",
      "pilgrim": "[uk-todo] Pilgrims"
    },
    "crewDesc": {
      "free-trader": "[uk-todo] Merchants and smugglers.",
      "mercenary": "[uk-todo] Soldiers of fortune.",
      "explorer": "[uk-todo] Truth-seekers and prospectors.",
      "agents": "[uk-todo] Faction operatives.",
      "pilgrim": "[uk-todo] Believers and travellers."
    },
    "ageLabel": "[uk-todo] Age",
    "agePlaceholder": "[uk-todo] e.g. 28",
    "ageHelp": "[uk-todo] Optional."
  },
  "el": {
    "originLabel": "[el-todo] Origin",
    "originPlaceholder": "[el-todo] Where do you come from?",
    "originHelp": "[el-todo] Home station or planet.",
    "upbringingLabel": "[el-todo] Upbringing",
    "upbringingHelp": "[el-todo] Drives starting points and wealth.",
    "upbringing": {
      "plebeian": "[el-todo] Plebeian",
      "stationary": "[el-todo] Stationary",
      "aristocrat": "[el-todo] Aristocrat"
    },
    "upbringingDesc": {
      "plebeian": "[el-todo] Workers and colonists.",
      "stationary": "[el-todo] Station dwellers.",
      "aristocrat": "[el-todo] Hereditary elites."
    },
    "budget": {
      "title": "[el-todo] Starting budget",
      "attributes": "[el-todo] Attribute pts",
      "skills": "[el-todo] Skill pts",
      "reputation": "[el-todo] Reputation",
      "wealth": "[el-todo] Birrs",
      "selectPrompt": "[el-todo] Select an upbringing."
    },
    "crewLabel": "[el-todo] Crew",
    "crewHelp": "[el-todo] Pick the team's crew amplua.",
    "crew": {
      "free-trader": "[el-todo] Free Traders",
      "mercenary": "[el-todo] Mercenaries",
      "explorer": "[el-todo] Explorers",
      "agents": "[el-todo] Agents",
      "pilgrim": "[el-todo] Pilgrims"
    },
    "crewDesc": {
      "free-trader": "[el-todo] Merchants and smugglers.",
      "mercenary": "[el-todo] Soldiers of fortune.",
      "explorer": "[el-todo] Truth-seekers and prospectors.",
      "agents": "[el-todo] Faction operatives.",
      "pilgrim": "[el-todo] Believers and travellers."
    },
    "ageLabel": "[el-todo] Age",
    "agePlaceholder": "[el-todo] e.g. 28",
    "ageHelp": "[el-todo] Optional."
  }
}
</i18n>

<template>
  <div class="step-background">
    <AppField :label="t('originLabel')" :help-text="t('originHelp')">
      <template #default="slotAttrs">
        <AppInput
          v-bind="slotAttrs"
          :model-value="origin ?? ''"
          :placeholder="t('originPlaceholder')"
          autocomplete="off"
          size="md"
          @update:model-value="onOriginInput($event)"
        />
      </template>
    </AppField>

    <AppField :label="t('upbringingLabel')" :help-text="t('upbringingHelp')">
      <AppSegControl
        :model-value="upbringing ?? null"
        :options="upbringingOptions"
        size="md"
        @update:model-value="onUpbringingChange($event)"
      />
    </AppField>

    <p v-if="upbringing" class="step-background__desc">
      {{ t(`upbringingDesc.${upbringing}`) }}
    </p>

    <div v-if="selectedBudget" class="step-background__budget" :aria-label="t('budget.title')">
      <span class="step-background__budget-title">{{ t('budget.title') }}</span>
      <dl class="step-background__budget-grid">
        <div class="step-background__budget-row">
          <dt>{{ t('budget.attributes') }}</dt>
          <dd>{{ selectedBudget.attributes }}</dd>
        </div>
        <div class="step-background__budget-row">
          <dt>{{ t('budget.skills') }}</dt>
          <dd>{{ selectedBudget.skills }}</dd>
        </div>
        <div class="step-background__budget-row">
          <dt>{{ t('budget.reputation') }}</dt>
          <dd>{{ selectedBudget.reputation }}</dd>
        </div>
        <div class="step-background__budget-row">
          <dt>{{ t('budget.wealth') }}</dt>
          <dd>{{ selectedBudget.wealth }}</dd>
        </div>
      </dl>
    </div>
    <p v-else class="step-background__budget-prompt">
      {{ t('budget.selectPrompt') }}
    </p>

    <AppField :label="t('crewLabel')" :help-text="t('crewHelp')">
      <div class="step-background__crew-grid">
        <button
          v-for="crew in CREW_CONCEPTS"
          :key="crew"
          type="button"
          class="step-background__crew-chip"
          :class="{
            'step-background__crew-chip--selected': isCrewSelected(crew),
          }"
          :aria-pressed="isCrewSelected(crew)"
          @click="onCrewToggle(crew)"
        >
          <span class="step-background__crew-name">{{ t(`crew.${crew}`) }}</span>
          <span class="step-background__crew-desc">{{ t(`crewDesc.${crew}`) }}</span>
        </button>
      </div>
    </AppField>

    <AppField :label="t('ageLabel')" :help-text="t('ageHelp')">
      <template #default="slotAttrs">
        <AppInput
          v-bind="slotAttrs"
          :model-value="ageStr"
          :placeholder="t('agePlaceholder')"
          type="number"
          inputmode="numeric"
          min="1"
          max="999"
          autocomplete="off"
          size="md"
          @update:model-value="onAgeInput($event)"
        />
      </template>
    </AppField>
  </div>
</template>

<style lang="scss" scoped>
  $step-form-max-width: 560px;

  .step-background {
    display: flex;
    flex-direction: column;
    gap: var(--space-6);
    max-width: $step-form-max-width;
    margin: 0 auto;

    &__desc {
      margin: calc(var(--space-2) * -1) 0 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__budget {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
      padding: var(--space-4);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
    }

    &__budget-title {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-brass);
      text-transform: uppercase;
      letter-spacing: 0.14em;
    }

    &__budget-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: var(--space-2) var(--space-4);
      margin: 0;
    }

    &__budget-row {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      gap: var(--space-3);

      dt {
        font-family: var(--font-body);
        font-size: var(--type-body-sm-font-size);
        color: var(--text-secondary);
      }

      dd {
        margin: 0;
        font-family: var(--font-mono);
        font-size: var(--type-body-md-font-size);
        font-weight: 700;
        color: var(--brand-brass-light);
      }
    }

    &__budget-prompt {
      margin: 0;
      padding: var(--space-3) var(--space-4);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      font-style: italic;
      color: var(--text-secondary);
      background-color: var(--surface-night);
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-md);
    }

    &__crew-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: var(--space-2);
    }

    &__crew-chip {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
      padding: var(--space-3) var(--space-4);
      text-align: left;
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      cursor: pointer;
      transition:
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        border-color: var(--brand-brass-deep);
        background-color: var(--surface-dawn);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      &--selected {
        border-color: var(--brand-brass);
        background-color: var(--surface-dawn);
      }
    }

    &__crew-name {
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__crew-desc {
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--text-secondary);
      line-height: 1.45;
    }
  }
</style>
