<script setup lang="ts">
  import {
    AppCard,
    AppBadge,
    AppButton,
    AppBanner,
    AppField,
    AppInput,
    AppTextarea,
    AppSavePulse,
  } from '@app/ui';
  import { ref, computed, onMounted, onBeforeUnmount } from 'vue';
  import { useRoute } from 'vue-router';
  import { useShipsApi } from '~/composables/useShipsApi';
  import type { Ship, ShipUpdate } from '~/composables/useShipsApi';
  import type { Problem, ShipModuleSlot, CrewPosition } from '@app/api-client-ts';
  import { useAutoSave } from '~/composables/useAutoSave';
  import type { SaveState } from '~/composables/useAutoSave';

  /**
   * Ship sheet — Block 2 of T-2026-05-10-005.
   *
   * Replaces the Block-1 stub with the real ship sheet:
   *   - Header: name (h1) + class chip + Duplicate / Delete actions + AppSavePulse
   *   - Identity card: editable name / model / registry with auto-save on blur (600 ms)
   *   - Stat block: hull / energy / armor / maneuverability / signature / speed /
   *     cargoCapacity — all inline-editable numbers
   *   - Modules card: read-only grouped by slot (Block 3 wires the editor)
   *   - Crew card: read-only six-position roster (Block 4 wires assignment)
   *   - Notes / History / Problems cards: auto-save on blur
   *
   * Page states: loading | loaded | error | notfound
   * 404 detected via problem.status === 404.
   */

  const { t } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const shipsApi = useShipsApi();

  const shipId = computed<string>(() => route.params.id as string);

  // ── Load state ───────────────────────────────────────────────────────────────

  type LoadState = 'loading' | 'loaded' | 'error' | 'notfound';

  const state = ref<LoadState>('loading');
  const ship = ref<Ship | null>(null);
  const errorMsg = ref('');

  // ── Editable local copies ────────────────────────────────────────────────────

  const localName = ref('');
  const localModel = ref<string | null>(null);
  const localRegistry = ref<string | null>(null);

  const localHullCurrent = ref(0);
  const localHullMax = ref(0);
  const localEnergyCurrent = ref(0);
  const localEnergyMax = ref(0);
  const localArmor = ref(0);
  const localManeuverability = ref(0);
  const localSignature = ref(0);
  const localSpeed = ref(0);
  // cargoCapacity is not part of ShipUpdate — displayed read-only; mutated via module HOLD editor (Block 3)
  const displayCargoCapacity = ref(0);

  const localNotes = ref<string | null>(null);
  const localHistory = ref<string | null>(null);
  const localProblems = ref('');

  // Collapsible card state
  const notesOpen = ref(true);
  const historyOpen = ref(true);

  function syncLocals(s: Ship): void {
    localName.value = s.name;
    localModel.value = s.model ?? null;
    localRegistry.value = s.registry ?? null;
    localHullCurrent.value = s.hull.current;
    localHullMax.value = s.hull.max;
    localEnergyCurrent.value = s.energy.current;
    localEnergyMax.value = s.energy.max;
    localArmor.value = s.armor;
    localManeuverability.value = s.maneuverability;
    localSignature.value = s.signature;
    localSpeed.value = s.speed;
    displayCargoCapacity.value = s.cargoCapacity;
    localNotes.value = s.notes ?? null;
    localHistory.value = s.history ?? null;
    localProblems.value = s.problems.join(', ');
  }

  // ── Auto-save plumbing ───────────────────────────────────────────────────────

  async function persistIdentity(): Promise<void> {
    const patch: ShipUpdate = {
      name: localName.value.trim() || undefined,
      model: localModel.value,
      registry: localRegistry.value,
    };
    const updated = await shipsApi.update(shipId.value, patch);
    if (ship.value) ship.value = { ...ship.value, ...updated };
  }

  async function persistStats(): Promise<void> {
    const patch: ShipUpdate = {
      hull: { current: localHullCurrent.value, max: localHullMax.value },
      energy: { current: localEnergyCurrent.value, max: localEnergyMax.value },
      armor: localArmor.value,
      maneuverability: localManeuverability.value,
      signature: localSignature.value,
      speed: localSpeed.value,
    };
    const updated = await shipsApi.update(shipId.value, patch);
    if (ship.value) ship.value = { ...ship.value, ...updated };
  }

  async function persistNotes(): Promise<void> {
    const updated = await shipsApi.update(shipId.value, { notes: localNotes.value });
    if (ship.value) ship.value = { ...ship.value, ...updated };
  }

  async function persistHistory(): Promise<void> {
    const updated = await shipsApi.update(shipId.value, { history: localHistory.value });
    if (ship.value) ship.value = { ...ship.value, ...updated };
  }

  async function persistProblems(): Promise<void> {
    const problems = localProblems.value
      .split(',')
      .map((s) => s.trim())
      .filter((s) => s.length > 0);
    const updated = await shipsApi.update(shipId.value, { problems });
    if (ship.value) ship.value = { ...ship.value, ...updated };
  }

  const identitySave = useAutoSave(persistIdentity, { debounceMs: 600 });
  const statsSave = useAutoSave(persistStats, { debounceMs: 600 });
  const notesSave = useAutoSave(persistNotes, { debounceMs: 600 });
  const historySave = useAutoSave(persistHistory, { debounceMs: 600 });
  const problemsSave = useAutoSave(persistProblems, { debounceMs: 600 });

  // Combined save-state for the header indicator: show 'saving' if any is saving
  const headerSaveState = computed<SaveState>(() => {
    const all = new Set([
      identitySave.saveState.value,
      statsSave.saveState.value,
      notesSave.saveState.value,
      historySave.saveState.value,
      problemsSave.saveState.value,
    ]);
    if (all.has('saving')) return 'saving';
    if (all.has('error')) return 'error';
    if (all.has('saved')) return 'saved';
    return 'idle';
  });

  // ── Load ─────────────────────────────────────────────────────────────────────

  async function load(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const data = await shipsApi.get(shipId.value);
      ship.value = data;
      syncLocals(data);
      state.value = 'loaded';
    } catch (error) {
      const problem = error as Problem;
      if (problem.status === 404) {
        state.value = 'notfound';
      } else {
        errorMsg.value = problem.detail ?? t('errorLoad');
        state.value = 'error';
      }
    }
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  const duplicating = ref(false);
  const duplicateError = ref('');

  async function onDuplicate(): Promise<void> {
    duplicating.value = true;
    duplicateError.value = '';
    try {
      const copy = await shipsApi.duplicate(shipId.value);
      await navigateTo(`/app/ships/${copy.id}`);
    } catch (error) {
      const problem = error as Problem;
      duplicateError.value = problem.detail ?? t('errorDuplicate');
    } finally {
      duplicating.value = false;
    }
  }

  const deleting = ref(false);
  const deleteError = ref('');

  async function onDelete(): Promise<void> {
    deleting.value = true;
    deleteError.value = '';
    try {
      await shipsApi.delete(shipId.value);
      await navigateTo('/app/ships');
    } catch (error) {
      const problem = error as Problem;
      deleteError.value = problem.detail ?? t('errorDelete');
    } finally {
      deleting.value = false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  function humaniseClass(cls: string): string {
    return cls
      .split('-')
      .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
      .join(' ');
  }

  // Ordered mandatory slots first, then the rest in spec order
  const MANDATORY_SLOTS = new Set<ShipModuleSlot>(['BRIDGE', 'REACTOR', 'DRIVE']);

  const modulesGrouped = computed(() => {
    if (!ship.value) return [];
    const mods = [...ship.value.modules];
    const mandatory = mods.filter((m) => MANDATORY_SLOTS.has(m.slot as ShipModuleSlot));
    const optional = mods.filter((m) => !MANDATORY_SLOTS.has(m.slot as ShipModuleSlot));
    return [...mandatory, ...optional];
  });

  // All six crew positions in rulebook order
  const CREW_POSITIONS: CrewPosition[] = [
    'captain',
    'pilot',
    'sensorOp',
    'gunner',
    'engineer',
    'serviceCrew',
  ];

  const crewRoster = computed(() => {
    const slotMap = new Map(
      (ship.value?.crew ?? []).map((cs) => [cs.position, cs.assignedCharacterId]),
    );
    return CREW_POSITIONS.map((pos) => ({
      position: pos,
      assignedCharacterId: slotMap.get(pos) ?? null,
    }));
  });

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  onMounted(() => {
    void load();
  });

  onBeforeUnmount(() => {
    identitySave.cancel();
    statsSave.cancel();
    notesSave.cancel();
    historySave.cancel();
    problemsSave.cancel();
  });
</script>

<i18n lang="json">
{
  "en": {
    "backToList": "Back to ships",
    "errorLoad": "Couldn't load ship.",
    "errorDuplicate": "Couldn't duplicate ship.",
    "errorDelete": "Couldn't delete ship.",
    "retry": "Try again",
    "notfoundTitle": "Ship not found",
    "notfoundBody": "This ship doesn't exist or you don't have access to it.",
    "classLabel": "Class",
    "duplicate": "Duplicate",
    "delete": "Delete",
    "identityCardTitle": "Identity",
    "fieldName": "Name",
    "fieldModel": "Model",
    "fieldRegistry": "Registry",
    "statsCardTitle": "Stats",
    "statHullCurrent": "Hull (current)",
    "statHullMax": "Hull (max)",
    "statEnergyCurrent": "Energy (current)",
    "statEnergyMax": "Energy (max)",
    "statArmor": "Armor",
    "statManeuverability": "Maneuverability",
    "statSignature": "Signature",
    "statSpeed": "Speed",
    "statCargoCapacity": "Cargo (t)",
    "modulesCardTitle": "Modules",
    "modulesAddDisabled": "Add module — Block 3",
    "modulesEmptySlot": "No modules installed",
    "crewCardTitle": "Crew",
    "crewVacant": "Vacant",
    "crewCaptain": "Captain",
    "crewPilot": "Pilot",
    "crewSensorOp": "Sensor Op",
    "crewGunner": "Gunner",
    "crewEngineer": "Engineer",
    "crewServiceCrew": "Service Crew",
    "notesCardTitle": "Notes",
    "notesPlaceholder": "Operational notes…",
    "historyCardTitle": "History",
    "historyPlaceholder": "Ship history and background…",
    "problemsCardTitle": "Problems",
    "problemsLabel": "Active problems",
    "problemsHelp": "Comma-separated list of active problems.",
    "collapseShow": "Show",
    "collapseHide": "Hide"
  },
  "ru": {
    "backToList": "К списку кораблей",
    "errorLoad": "Не удалось загрузить корабль.",
    "errorDuplicate": "Не удалось дублировать корабль.",
    "errorDelete": "Не удалось удалить корабль.",
    "retry": "Попробовать снова",
    "notfoundTitle": "Корабль не найден",
    "notfoundBody": "Этот корабль не существует или у вас нет к нему доступа.",
    "classLabel": "Класс",
    "duplicate": "Дублировать",
    "delete": "Удалить",
    "identityCardTitle": "Идентификация",
    "fieldName": "Название",
    "fieldModel": "Модель",
    "fieldRegistry": "Реестровый номер",
    "statsCardTitle": "Характеристики",
    "statHullCurrent": "Корпус (текущий)",
    "statHullMax": "Корпус (макс.)",
    "statEnergyCurrent": "Энергия (текущая)",
    "statEnergyMax": "Энергия (макс.)",
    "statArmor": "Броня",
    "statManeuverability": "Манёвренность",
    "statSignature": "Заметность",
    "statSpeed": "Скорость",
    "statCargoCapacity": "Груз (т)",
    "modulesCardTitle": "Модули",
    "modulesAddDisabled": "Добавить модуль — Блок 3",
    "modulesEmptySlot": "Модули не установлены",
    "crewCardTitle": "Экипаж",
    "crewVacant": "Вакантно",
    "crewCaptain": "Капитан",
    "crewPilot": "Пилот",
    "crewSensorOp": "Оператор сенсоров",
    "crewGunner": "Стрелок",
    "crewEngineer": "Инженер",
    "crewServiceCrew": "Техническая команда",
    "notesCardTitle": "Заметки",
    "notesPlaceholder": "Оперативные заметки…",
    "historyCardTitle": "История",
    "historyPlaceholder": "История и предыстория корабля…",
    "problemsCardTitle": "Неисправности",
    "problemsLabel": "Активные неисправности",
    "problemsHelp": "Список через запятую.",
    "collapseShow": "Показать",
    "collapseHide": "Скрыть"
  },
  "uk": {
    "backToList": "[uk-todo] Back to ships",
    "errorLoad": "[uk-todo] Couldn't load ship",
    "errorDuplicate": "[uk-todo] Couldn't duplicate ship",
    "errorDelete": "[uk-todo] Couldn't delete ship",
    "retry": "[uk-todo] Try again",
    "notfoundTitle": "[uk-todo] Ship not found",
    "notfoundBody": "[uk-todo] This ship doesn't exist or you don't have access",
    "classLabel": "[uk-todo] Class",
    "duplicate": "[uk-todo] Duplicate",
    "delete": "[uk-todo] Delete",
    "identityCardTitle": "[uk-todo] Identity",
    "fieldName": "[uk-todo] Name",
    "fieldModel": "[uk-todo] Model",
    "fieldRegistry": "[uk-todo] Registry",
    "statsCardTitle": "[uk-todo] Stats",
    "statHullCurrent": "[uk-todo] Hull (current)",
    "statHullMax": "[uk-todo] Hull (max)",
    "statEnergyCurrent": "[uk-todo] Energy (current)",
    "statEnergyMax": "[uk-todo] Energy (max)",
    "statArmor": "[uk-todo] Armor",
    "statManeuverability": "[uk-todo] Maneuverability",
    "statSignature": "[uk-todo] Signature",
    "statSpeed": "[uk-todo] Speed",
    "statCargoCapacity": "[uk-todo] Cargo (t)",
    "modulesCardTitle": "[uk-todo] Modules",
    "modulesAddDisabled": "[uk-todo] Add module — Block 3",
    "modulesEmptySlot": "[uk-todo] No modules installed",
    "crewCardTitle": "[uk-todo] Crew",
    "crewVacant": "[uk-todo] Vacant",
    "crewCaptain": "[uk-todo] Captain",
    "crewPilot": "[uk-todo] Pilot",
    "crewSensorOp": "[uk-todo] Sensor Op",
    "crewGunner": "[uk-todo] Gunner",
    "crewEngineer": "[uk-todo] Engineer",
    "crewServiceCrew": "[uk-todo] Service Crew",
    "notesCardTitle": "[uk-todo] Notes",
    "notesPlaceholder": "[uk-todo] Operational notes…",
    "historyCardTitle": "[uk-todo] History",
    "historyPlaceholder": "[uk-todo] Ship history…",
    "problemsCardTitle": "[uk-todo] Problems",
    "problemsLabel": "[uk-todo] Active problems",
    "problemsHelp": "[uk-todo] Comma-separated list",
    "collapseShow": "[uk-todo] Show",
    "collapseHide": "[uk-todo] Hide"
  },
  "el": {
    "backToList": "[el-todo] Back to ships",
    "errorLoad": "[el-todo] Couldn't load ship",
    "errorDuplicate": "[el-todo] Couldn't duplicate ship",
    "errorDelete": "[el-todo] Couldn't delete ship",
    "retry": "[el-todo] Try again",
    "notfoundTitle": "[el-todo] Ship not found",
    "notfoundBody": "[el-todo] This ship doesn't exist or you don't have access",
    "classLabel": "[el-todo] Class",
    "duplicate": "[el-todo] Duplicate",
    "delete": "[el-todo] Delete",
    "identityCardTitle": "[el-todo] Identity",
    "fieldName": "[el-todo] Name",
    "fieldModel": "[el-todo] Model",
    "fieldRegistry": "[el-todo] Registry",
    "statsCardTitle": "[el-todo] Stats",
    "statHullCurrent": "[el-todo] Hull (current)",
    "statHullMax": "[el-todo] Hull (max)",
    "statEnergyCurrent": "[el-todo] Energy (current)",
    "statEnergyMax": "[el-todo] Energy (max)",
    "statArmor": "[el-todo] Armor",
    "statManeuverability": "[el-todo] Maneuverability",
    "statSignature": "[el-todo] Signature",
    "statSpeed": "[el-todo] Speed",
    "statCargoCapacity": "[el-todo] Cargo (t)",
    "modulesCardTitle": "[el-todo] Modules",
    "modulesAddDisabled": "[el-todo] Add module — Block 3",
    "modulesEmptySlot": "[el-todo] No modules installed",
    "crewCardTitle": "[el-todo] Crew",
    "crewVacant": "[el-todo] Vacant",
    "crewCaptain": "[el-todo] Captain",
    "crewPilot": "[el-todo] Pilot",
    "crewSensorOp": "[el-todo] Sensor Op",
    "crewGunner": "[el-todo] Gunner",
    "crewEngineer": "[el-todo] Engineer",
    "crewServiceCrew": "[el-todo] Service Crew",
    "notesCardTitle": "[el-todo] Notes",
    "notesPlaceholder": "[el-todo] Operational notes…",
    "historyCardTitle": "[el-todo] History",
    "historyPlaceholder": "[el-todo] Ship history…",
    "problemsCardTitle": "[el-todo] Problems",
    "problemsLabel": "[el-todo] Active problems",
    "problemsHelp": "[el-todo] Comma-separated list",
    "collapseShow": "[el-todo] Show",
    "collapseHide": "[el-todo] Hide"
  }
}
</i18n>

<template>
  <section
    class="page-ship"
    data-testid="page-ship"
  >
    <!-- ── Back nav ──────────────────────────────────────────────────────────── -->
    <AppButton
      variant="ghost"
      size="sm"
      class="page-ship__back"
      @click="navigateTo('/app/ships')"
    >
      ← {{ t('backToList') }}
    </AppButton>

    <!-- ── Error banner ──────────────────────────────────────────────────────── -->
    <AppBanner
      v-if="state === 'error'"
      tone="danger"
      role="alert"
      class="page-ship__banner"
    >
      {{ errorMsg }}
      <AppButton
        variant="ghost"
        size="sm"
        @click="load"
      >
        {{ t('retry') }}
      </AppButton>
    </AppBanner>

    <AppBanner
      v-if="duplicateError"
      tone="danger"
      role="alert"
      class="page-ship__banner"
    >
      {{ duplicateError }}
    </AppBanner>

    <AppBanner
      v-if="deleteError"
      tone="danger"
      role="alert"
      class="page-ship__banner"
    >
      {{ deleteError }}
    </AppBanner>

    <!-- ── Loading skeleton ──────────────────────────────────────────────────── -->
    <div
      v-if="state === 'loading'"
      class="page-ship__skeleton"
      aria-busy="true"
    />

    <!-- ── Not found ─────────────────────────────────────────────────────────── -->
    <AppCard
      v-else-if="state === 'notfound'"
      class="page-ship__notfound"
    >
      <h2 class="page-ship__notfound-title">
        {{ t('notfoundTitle') }}
      </h2>
      <p class="page-ship__notfound-body">
        {{ t('notfoundBody') }}
      </p>
    </AppCard>

    <!-- ── Loaded ─────────────────────────────────────────────────────────────── -->
    <template v-else-if="ship && state === 'loaded'">
      <!-- Header -->
      <header class="page-ship__header">
        <div class="page-ship__header-left">
          <h1 class="page-ship__name">
            {{ ship.name }}
          </h1>
          <AppBadge
            variant="brass"
            size="md"
            class="page-ship__class-chip"
          >
            {{ t('classLabel') }}: {{ humaniseClass(ship.class) }}
          </AppBadge>
        </div>
        <div class="page-ship__header-actions">
          <AppSavePulse :state="headerSaveState" />
          <AppButton
            variant="ghost"
            size="sm"
            :disabled="duplicating"
            @click="onDuplicate"
          >
            {{ t('duplicate') }}
          </AppButton>
          <AppButton
            variant="ghost"
            size="sm"
            :disabled="deleting"
            @click="onDelete"
          >
            {{ t('delete') }}
          </AppButton>
        </div>
      </header>

      <!-- ── Identity card ─────────────────────────────────────────────────── -->
      <AppCard class="page-ship__card">
        <template #header>
          <span class="page-ship__card-title">{{ t('identityCardTitle') }}</span>
        </template>

        <div class="page-ship__identity-grid">
          <AppField
            :label="t('fieldName')"
            required
          >
            <template #default="attrs">
              <AppInput
                v-bind="attrs"
                v-model="localName"
                type="text"
                :placeholder="t('fieldName')"
                @blur="identitySave.schedule()"
              />
            </template>
          </AppField>

          <AppField :label="t('fieldModel')">
            <template #default="attrs">
              <AppInput
                v-bind="attrs"
                :model-value="localModel"
                type="text"
                :placeholder="t('fieldModel')"
                @update:model-value="(v) => { localModel = typeof v === 'string' ? v : null; }"
                @blur="identitySave.schedule()"
              />
            </template>
          </AppField>

          <AppField :label="t('fieldRegistry')">
            <template #default="attrs">
              <AppInput
                v-bind="attrs"
                :model-value="localRegistry"
                type="text"
                :placeholder="t('fieldRegistry')"
                @update:model-value="(v) => { localRegistry = typeof v === 'string' ? v : null; }"
                @blur="identitySave.schedule()"
              />
            </template>
          </AppField>
        </div>
      </AppCard>

      <!-- ── Stat block card ───────────────────────────────────────────────── -->
      <AppCard class="page-ship__card">
        <template #header>
          <span class="page-ship__card-title">{{ t('statsCardTitle') }}</span>
        </template>

        <div class="page-ship__stats-grid">
          <!-- Hull current — prominent -->
          <div class="page-ship__stat page-ship__stat--prominent">
            <span class="page-ship__stat-label">{{ t('statHullCurrent') }}</span>
            <div class="page-ship__stat-stepper">
              <AppButton
                variant="ghost"
                size="sm"
                class="page-ship__stepper-btn"
                :disabled="localHullCurrent <= 0"
                @click="localHullCurrent = Math.max(0, localHullCurrent - 1); statsSave.schedule()"
              >
                −
              </AppButton>
              <AppInput
                v-model="localHullCurrent"
                type="number"
                size="md"
                inputmode="numeric"
                class="page-ship__stat-input page-ship__stat-input--prominent"
                @blur="statsSave.schedule()"
              />
              <AppButton
                variant="ghost"
                size="sm"
                class="page-ship__stepper-btn"
                @click="localHullCurrent = localHullCurrent + 1; statsSave.schedule()"
              >
                +
              </AppButton>
            </div>
          </div>

          <!-- Hull max -->
          <div class="page-ship__stat">
            <span class="page-ship__stat-label">{{ t('statHullMax') }}</span>
            <AppInput
              v-model="localHullMax"
              type="number"
              size="md"
              inputmode="numeric"
              class="page-ship__stat-input"
              @blur="statsSave.schedule()"
            />
          </div>

          <!-- Energy current — prominent -->
          <div class="page-ship__stat page-ship__stat--prominent">
            <span class="page-ship__stat-label">{{ t('statEnergyCurrent') }}</span>
            <div class="page-ship__stat-stepper">
              <AppButton
                variant="ghost"
                size="sm"
                class="page-ship__stepper-btn"
                :disabled="localEnergyCurrent <= 0"
                @click="localEnergyCurrent = Math.max(0, localEnergyCurrent - 1); statsSave.schedule()"
              >
                −
              </AppButton>
              <AppInput
                v-model="localEnergyCurrent"
                type="number"
                size="md"
                inputmode="numeric"
                class="page-ship__stat-input page-ship__stat-input--prominent"
                @blur="statsSave.schedule()"
              />
              <AppButton
                variant="ghost"
                size="sm"
                class="page-ship__stepper-btn"
                @click="localEnergyCurrent = localEnergyCurrent + 1; statsSave.schedule()"
              >
                +
              </AppButton>
            </div>
          </div>

          <!-- Energy max -->
          <div class="page-ship__stat">
            <span class="page-ship__stat-label">{{ t('statEnergyMax') }}</span>
            <AppInput
              v-model="localEnergyMax"
              type="number"
              size="md"
              inputmode="numeric"
              class="page-ship__stat-input"
              @blur="statsSave.schedule()"
            />
          </div>

          <!-- Armor -->
          <div class="page-ship__stat">
            <span class="page-ship__stat-label">{{ t('statArmor') }}</span>
            <AppInput
              v-model="localArmor"
              type="number"
              size="md"
              inputmode="numeric"
              class="page-ship__stat-input"
              @blur="statsSave.schedule()"
            />
          </div>

          <!-- Maneuverability (signed) -->
          <div class="page-ship__stat">
            <span class="page-ship__stat-label">{{ t('statManeuverability') }}</span>
            <AppInput
              v-model="localManeuverability"
              type="number"
              size="md"
              inputmode="numeric"
              class="page-ship__stat-input"
              @blur="statsSave.schedule()"
            />
          </div>

          <!-- Signature (signed) -->
          <div class="page-ship__stat">
            <span class="page-ship__stat-label">{{ t('statSignature') }}</span>
            <AppInput
              v-model="localSignature"
              type="number"
              size="md"
              inputmode="numeric"
              class="page-ship__stat-input"
              @blur="statsSave.schedule()"
            />
          </div>

          <!-- Speed -->
          <div class="page-ship__stat">
            <span class="page-ship__stat-label">{{ t('statSpeed') }}</span>
            <AppInput
              v-model="localSpeed"
              type="number"
              size="md"
              inputmode="numeric"
              class="page-ship__stat-input"
              @blur="statsSave.schedule()"
            />
          </div>

          <!-- Cargo capacity — read-only; mutated via HOLD module editor (Block 3) -->
          <div class="page-ship__stat">
            <span class="page-ship__stat-label">{{ t('statCargoCapacity') }}</span>
            <AppInput
              :model-value="displayCargoCapacity"
              type="number"
              size="md"
              inputmode="numeric"
              class="page-ship__stat-input"
              readonly
            />
          </div>
        </div>
      </AppCard>

      <!-- ── Modules card ───────────────────────────────────────────────────── -->
      <AppCard class="page-ship__card">
        <template #header>
          <div class="page-ship__card-header-row">
            <span class="page-ship__card-title">{{ t('modulesCardTitle') }}</span>
            <AppButton
              variant="ghost"
              size="sm"
              disabled
            >
              {{ t('modulesAddDisabled') }}
            </AppButton>
          </div>
        </template>

        <ul
          v-if="modulesGrouped.length > 0"
          class="page-ship__modules-list"
          aria-label="Modules"
        >
          <li
            v-for="mod in modulesGrouped"
            :key="mod.id"
            class="page-ship__module-row"
          >
            <AppBadge
              variant="darkness"
              size="sm"
              class="page-ship__module-slot"
            >
              {{ mod.slot }}
            </AppBadge>
            <span class="page-ship__module-name">{{ mod.name }}</span>
            <AppBadge
              v-if="mod.energyUse > 0"
              variant="mystic"
              size="sm"
              class="page-ship__module-energy"
            >
              {{ mod.energyUse }}
            </AppBadge>
          </li>
        </ul>

        <p
          v-else
          class="page-ship__modules-empty"
        >
          {{ t('modulesEmptySlot') }}
        </p>
      </AppCard>

      <!-- ── Crew card ──────────────────────────────────────────────────────── -->
      <AppCard class="page-ship__card">
        <template #header>
          <span class="page-ship__card-title">{{ t('crewCardTitle') }}</span>
        </template>

        <ul
          class="page-ship__crew-list"
          aria-label="Crew"
        >
          <li
            v-for="slot in crewRoster"
            :key="slot.position"
            class="page-ship__crew-row"
          >
            <span class="page-ship__crew-position">
              {{ t(`crew${slot.position.charAt(0).toUpperCase()}${slot.position.slice(1)}`) }}
            </span>
            <span
              v-if="slot.assignedCharacterId"
              class="page-ship__crew-name"
            >
              {{ slot.assignedCharacterId }}
            </span>
            <em
              v-else
              class="page-ship__crew-vacant"
            >
              {{ t('crewVacant') }}
            </em>
          </li>
        </ul>
      </AppCard>

      <!-- ── Notes card ─────────────────────────────────────────────────────── -->
      <AppCard class="page-ship__card">
        <template #header>
          <div class="page-ship__card-header-row">
            <span class="page-ship__card-title">{{ t('notesCardTitle') }}</span>
            <AppButton
              variant="ghost"
              size="sm"
              @click="notesOpen = !notesOpen"
            >
              {{ notesOpen ? t('collapseHide') : t('collapseShow') }}
            </AppButton>
          </div>
        </template>

        <div v-if="notesOpen">
          <AppTextarea
            v-model="localNotes"
            :rows="5"
            :maxlength="4096"
            :placeholder="t('notesPlaceholder')"
            @blur="notesSave.schedule()"
          />
        </div>
      </AppCard>

      <!-- ── History card ───────────────────────────────────────────────────── -->
      <AppCard class="page-ship__card">
        <template #header>
          <div class="page-ship__card-header-row">
            <span class="page-ship__card-title">{{ t('historyCardTitle') }}</span>
            <AppButton
              variant="ghost"
              size="sm"
              @click="historyOpen = !historyOpen"
            >
              {{ historyOpen ? t('collapseHide') : t('collapseShow') }}
            </AppButton>
          </div>
        </template>

        <div v-if="historyOpen">
          <AppTextarea
            v-model="localHistory"
            :rows="6"
            :maxlength="4096"
            :placeholder="t('historyPlaceholder')"
            @blur="historySave.schedule()"
          />
        </div>
      </AppCard>

      <!-- ── Problems card ──────────────────────────────────────────────────── -->
      <AppCard class="page-ship__card">
        <template #header>
          <span class="page-ship__card-title">{{ t('problemsCardTitle') }}</span>
        </template>

        <AppField
          :label="t('problemsLabel')"
          :help-text="t('problemsHelp')"
        >
          <template #default="attrs">
            <AppInput
              v-bind="attrs"
              v-model="localProblems"
              type="text"
              @blur="problemsSave.schedule()"
            />
          </template>
        </AppField>
      </AppCard>
    </template>
  </section>
</template>

<style lang="scss" scoped>
  $skeleton-height: 200px;
  $stat-input-width: 80px;
  $stat-input-prominent-width: 96px;

  .page-ship {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    padding: var(--space-6);
    max-width: 960px;
    margin: 0 auto;

    // ── Back link ──────────────────────────────────────────────────────────────

    &__back {
      align-self: flex-start;
    }

    // ── Error / info banners ───────────────────────────────────────────────────

    &__banner {
      width: 100%;
    }

    // ── Skeleton ───────────────────────────────────────────────────────────────

    &__skeleton {
      height: $skeleton-height;
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      opacity: var(--opacity-disabled);
    }

    // ── Not found ──────────────────────────────────────────────────────────────

    &__notfound {
      padding: var(--space-6);
    }

    &__notfound-title {
      margin: 0 0 var(--space-2);
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__notfound-body {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
    }

    // ── Header ─────────────────────────────────────────────────────────────────

    &__header {
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      gap: var(--space-4);
      flex-wrap: wrap;
    }

    &__header-left {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__header-actions {
      display: inline-flex;
      align-items: center;
      gap: var(--space-3);
      flex-wrap: wrap;
    }

    &__name {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-md-font-size);
      letter-spacing: var(--type-display-md-letter-spacing);
      color: var(--brand-brass-light);
    }

    &__class-chip {
      align-self: flex-start;
    }

    // ── Cards shared ───────────────────────────────────────────────────────────

    &__card {
      width: 100%;
    }

    &__card-title {
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__card-header-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: var(--space-3);
    }

    // ── Identity grid ──────────────────────────────────────────────────────────

    &__identity-grid {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      gap: var(--space-4);

      @media (max-width: 640px) {
        grid-template-columns: 1fr;
      }
    }

    // ── Stats grid ─────────────────────────────────────────────────────────────

    &__stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
      gap: var(--space-4);
    }

    &__stat {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__stat-label {
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    &__stat-input {
      width: $stat-input-width;
      text-align: center;
    }

    &__stat-input--prominent {
      width: $stat-input-prominent-width;
      font-size: var(--type-body-lg-font-size);
      font-weight: 600;
    }

    &__stat-stepper {
      display: flex;
      align-items: center;
      gap: var(--space-2);
    }

    &__stepper-btn {
      flex-shrink: 0;
    }

    // ── Modules list ───────────────────────────────────────────────────────────

    &__modules-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__module-row {
      display: flex;
      align-items: center;
      gap: var(--space-3);
    }

    &__module-slot {
      flex-shrink: 0;
      min-width: 80px;
      text-align: center;
    }

    &__module-name {
      flex: 1;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-primary);
    }

    &__module-energy {
      flex-shrink: 0;
    }

    &__modules-empty {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
    }

    // ── Crew list ──────────────────────────────────────────────────────────────

    &__crew-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__crew-row {
      display: flex;
      align-items: center;
      gap: var(--space-4);
    }

    &__crew-position {
      width: 160px;
      flex-shrink: 0;
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    &__crew-name {
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-primary);
    }

    &__crew-vacant {
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }
  }
</style>
