<script setup lang="ts">
  definePageMeta({ layout: 'app' });

  import {
    AppCard,
    AppBadge,
    AppButton,
    AppBanner,
    AppField,
    AppInput,
    AppTextarea,
    AppSavePulse,
    AppModal,
    AppStatPair,
  } from '@app/ui';
  import { ref, computed, onMounted, onBeforeUnmount } from 'vue';
  import { useRoute } from 'vue-router';
  import { useRuntimeConfig } from '#imports';
  import { useShipsApi } from '~/composables/useShipsApi';
  import type { Ship, ShipUpdate } from '~/composables/useShipsApi';
  import type { Problem, ShipModuleSlot, CrewPosition } from '@app/api-client-ts';
  import { useAutoSave } from '~/composables/useAutoSave';
  import type { SaveState } from '~/composables/useAutoSave';
  import ShipModuleEditor from '~/components/sheet/ShipModuleEditor.vue';
  import type { ShipModule } from '~/composables/useShipModulesApi';
  import { useShipCrewApi } from '~/composables/useShipCrewApi';
  import { useCharactersApi } from '~/composables/useCharactersApi';
  import type { Character } from '~/composables/useCharactersApi';

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
  const runtimeConfig = useRuntimeConfig();
  const shipsApi = useShipsApi();
  const crewApi = useShipCrewApi();
  const charactersApi = useCharactersApi();

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

  // Collapsible card state — default collapsed when the field is empty on load.
  // Opens automatically once the user has content, stays open until toggled.
  const notesOpen = ref(false);
  const historyOpen = ref(false);

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
    // Expand collapsed sections only when there is pre-existing content.
    notesOpen.value = Boolean(s.notes && s.notes.trim().length > 0);
    historyOpen.value = Boolean(s.history && s.history.trim().length > 0);
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
      // Pass the source ship name so the index page can surface a "duplicated" toast.
      const sourceName = ship.value?.name ?? '';
      await navigateTo(`/app/ships/${copy.id}?duplicatedFrom=${encodeURIComponent(sourceName)}`);
    } catch (error) {
      const problem = error as Problem;
      duplicateError.value = problem.detail ?? t('errorDuplicate');
    } finally {
      duplicating.value = false;
    }
  }

  const deleting = ref(false);
  const deleteError = ref('');
  const deleteConfirmOpen = ref(false);

  function openDeleteConfirm(): void {
    deleteConfirmOpen.value = true;
  }

  function closeDeleteConfirm(): void {
    deleteConfirmOpen.value = false;
  }

  async function confirmDelete(): Promise<void> {
    deleting.value = true;
    deleteError.value = '';
    try {
      await shipsApi.delete(shipId.value);
      deleteConfirmOpen.value = false;
      await navigateTo('/app/ships');
    } catch (error) {
      const problem = error as Problem;
      deleteError.value = problem.detail ?? t('errorDelete');
      deleteConfirmOpen.value = false;
    } finally {
      deleting.value = false;
    }
  }

  /** URL for the export endpoint — opens in a new tab. Backend returns 501 until it ships. */
  const exportUrl = computed<string>(
    () => `${runtimeConfig.public.apiBaseUrl}/ships/${shipId.value}/export`,
  );

  // ── Module editor state ──────────────────────────────────────────────────────

  const moduleEditorOpen = ref(false);
  const editingModule = ref<ShipModule | null>(null);

  function openModuleCreate(): void {
    editingModule.value = null;
    moduleEditorOpen.value = true;
  }

  function openModuleEdit(mod: ShipModule): void {
    editingModule.value = mod;
    moduleEditorOpen.value = true;
  }

  function onModuleUpdated(updated: ShipModule): void {
    if (!ship.value) return;
    const idx = ship.value.modules.findIndex((m) => m.id === updated.id);
    if (idx !== -1) {
      // Replace existing module in place
      const mods = [...ship.value.modules];
      mods[idx] = updated;
      ship.value = { ...ship.value, modules: mods };
    } else {
      // New module added
      ship.value = { ...ship.value, modules: [...ship.value.modules, updated] };
    }
  }

  function onModuleDeleted(moduleId: string): void {
    if (!ship.value) return;
    ship.value = {
      ...ship.value,
      modules: ship.value.modules.filter((m) => m.id !== moduleId),
    };
  }

  // ── Crew state ────────────────────────────────────────────────────────────────

  const allCharacters = ref<Character[]>([]);
  const crewError = ref('');
  // Per-position state for the inline pickers
  const pickerOpen = ref<Partial<Record<CrewPosition, boolean>>>({});
  const pickerSelected = ref<Partial<Record<CrewPosition, string>>>({});
  const crewBusy = ref<Partial<Record<CrewPosition, boolean>>>({});

  function togglePicker(pos: CrewPosition): void {
    pickerOpen.value = { ...pickerOpen.value, [pos]: !pickerOpen.value[pos] };
    pickerSelected.value = { ...pickerSelected.value, [pos]: '' };
  }

  function closePicker(pos: CrewPosition): void {
    pickerOpen.value = { ...pickerOpen.value, [pos]: false };
    pickerSelected.value = { ...pickerSelected.value, [pos]: '' };
  }

  /** Characters already serving on this ship (any position). */
  const charactersOnShip = computed<Set<string>>(() => {
    return new Set(
      (ship.value?.crew ?? []).map((cs) => cs.assignedCharacterId).filter(Boolean) as string[],
    );
  });

  /**
   * For a given vacant position, return the characters available to pick.
   * Split into two groups: those NOT yet on the ship (primary), and those
   * already serving at another position (they trigger move semantics).
   */
  function pickableFor(pos: CrewPosition): { free: Character[]; onShip: Character[] } {
    const currentHolder = ship.value?.crew.find((cs) => cs.position === pos)?.assignedCharacterId;
    const free: Character[] = [];
    const onShip: Character[] = [];
    for (const ch of allCharacters.value) {
      if (ch.id === currentHolder) continue; // already in this slot
      if (charactersOnShip.value.has(ch.id)) {
        onShip.push(ch);
      } else {
        free.push(ch);
      }
    }
    return { free, onShip };
  }

  async function refetchShip(): Promise<void> {
    const refreshed = await shipsApi.get(shipId.value);
    ship.value = refreshed;
    syncLocals(refreshed);
  }

  async function onAssign(pos: CrewPosition): Promise<void> {
    const characterId = pickerSelected.value[pos];
    if (!characterId) return;
    crewError.value = '';
    crewBusy.value = { ...crewBusy.value, [pos]: true };
    try {
      await crewApi.assign(shipId.value, { position: pos, characterId });
      await refetchShip();
      closePicker(pos);
    } catch (error) {
      const problem = error as { status?: number; detail?: string };
      crewError.value = problem.detail ?? t('crewErrorAssign');
    } finally {
      crewBusy.value = { ...crewBusy.value, [pos]: false };
    }
  }

  async function onUnassign(pos: CrewPosition, characterId: string): Promise<void> {
    crewError.value = '';
    crewBusy.value = { ...crewBusy.value, [pos]: true };
    try {
      await crewApi.unassign(shipId.value, characterId);
      await refetchShip();
    } catch (error) {
      const problem = error as { status?: number; detail?: string };
      crewError.value = problem.detail ?? t('crewErrorUnassign');
    } finally {
      crewBusy.value = { ...crewBusy.value, [pos]: false };
    }
  }

  function characterName(id: string): string {
    const ch = allCharacters.value.find((c) => c.id === id);
    return ch?.name ?? `#${id}`;
  }

  // Human-readable position label key map
  const POSITION_KEY: Record<CrewPosition, string> = {
    captain: 'crewCaptain',
    pilot: 'crewPilot',
    sensorOp: 'crewSensorOp',
    gunner: 'crewGunner',
    engineer: 'crewEngineer',
    serviceCrew: 'crewServiceCrew',
  };

  function positionLabel(pos: CrewPosition): string {
    return t(POSITION_KEY[pos]);
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
    void charactersApi.list({ limit: 100 }).then((res) => {
      allCharacters.value = res.items;
    });
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
    "export": "Export",
    "exportExperimental": "experimental",
    "deleteConfirmTitle": "Delete this ship?",
    "deleteConfirmBody": "This will permanently delete the ship, its modules, and clear the crew roster. This cannot be undone.",
    "deleteConfirmYes": "Delete",
    "deleteConfirmNo": "Cancel",
    "identityCardTitle": "Identity",
    "fieldName": "Name",
    "fieldModel": "Model",
    "fieldRegistry": "Registry",
    "statsCardTitle": "Stats",
    "statHull": "Hull",
    "statEnergy": "Energy",
    "statArmor": "Armor",
    "statManeuverability": "Maneuv.",
    "statSignature": "Signature",
    "statSpeed": "Speed",
    "statCargoCapacity": "Cargo (t)",
    "modulesCardTitle": "Modules",
    "modulesAdd": "+ Add module",
    "modulesEmptySlot": "No modules installed",
    "crewCardTitle": "Crew",
    "crewVacant": "Vacant",
    "crewCaptain": "Captain",
    "crewPilot": "Pilot",
    "crewSensorOp": "Sensor Op",
    "crewGunner": "Gunner",
    "crewEngineer": "Engineer",
    "crewServiceCrew": "Service Crew",
    "crewAssign": "Assign…",
    "crewRemove": "Remove",
    "crewPickerCancel": "Cancel",
    "crewPickerLabel": "Select character",
    "crewPickerPlaceholder": "— pick a character —",
    "crewPickerGroupFree": "Available",
    "crewPickerGroupOnShip": "Already on this ship (will move)",
    "crewPickerConfirm": "Assign",
    "crewErrorAssign": "Couldn't assign crew member.",
    "crewErrorUnassign": "Couldn't remove crew member.",
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
    "export": "Экспорт",
    "exportExperimental": "эксперим.",
    "deleteConfirmTitle": "Удалить этот корабль?",
    "deleteConfirmBody": "Это безвозвратно удалит корабль, его модули и очистит список экипажа. Действие необратимо.",
    "deleteConfirmYes": "Удалить",
    "deleteConfirmNo": "Отмена",
    "identityCardTitle": "Идентификация",
    "fieldName": "Название",
    "fieldModel": "Модель",
    "fieldRegistry": "Реестровый номер",
    "statsCardTitle": "Характеристики",
    "statHull": "Корпус",
    "statEnergy": "Энергия",
    "statArmor": "Броня",
    "statManeuverability": "Манёвр.",
    "statSignature": "Заметность",
    "statSpeed": "Скорость",
    "statCargoCapacity": "Груз (т)",
    "modulesCardTitle": "Модули",
    "modulesAdd": "+ Добавить модуль",
    "modulesEmptySlot": "Модули не установлены",
    "crewCardTitle": "Экипаж",
    "crewVacant": "Вакантно",
    "crewCaptain": "Капитан",
    "crewPilot": "Пилот",
    "crewSensorOp": "Штурман-оператор",
    "crewGunner": "Стрелок",
    "crewEngineer": "Инженер",
    "crewServiceCrew": "Команда",
    "crewAssign": "Назначить…",
    "crewRemove": "Убрать",
    "crewPickerCancel": "Отмена",
    "crewPickerLabel": "Выберите персонажа",
    "crewPickerPlaceholder": "— выберите персонажа —",
    "crewPickerGroupFree": "Доступны",
    "crewPickerGroupOnShip": "Уже на борту (переведут позицию)",
    "crewPickerConfirm": "Назначить",
    "crewErrorAssign": "Не удалось назначить члена экипажа.",
    "crewErrorUnassign": "Не удалось убрать члена экипажа.",
    "notesCardTitle": "Заметки",
    "notesPlaceholder": "Оперативные заметки…",
    "historyCardTitle": "История",
    "historyPlaceholder": "История и предыстория корабля…",
    "problemsCardTitle": "Неисправности",
    "problemsLabel": "Активные неисправности",
    "problemsHelp": "Список через запятую.",
    "collapseShow": "Показать",
    "collapseHide": "Скрыть"
  }
}
</i18n>

<template>
  <section class="page-ship" data-testid="page-ship">
    <!-- ── Back nav ──────────────────────────────────────────────────────────── -->
    <AppButton variant="ghost" size="sm" class="page-ship__back" @click="navigateTo('/app/ships')">
      ← {{ t('backToList') }}
    </AppButton>

    <!-- ── Error banner ──────────────────────────────────────────────────────── -->
    <AppBanner v-if="state === 'error'" tone="danger" role="alert" class="page-ship__banner">
      {{ errorMsg }}
      <AppButton variant="ghost" size="sm" @click="load">
        {{ t('retry') }}
      </AppButton>
    </AppBanner>

    <AppBanner v-if="duplicateError" tone="danger" role="alert" class="page-ship__banner">
      {{ duplicateError }}
    </AppBanner>

    <AppBanner v-if="deleteError" tone="danger" role="alert" class="page-ship__banner">
      {{ deleteError }}
    </AppBanner>

    <!-- ── Loading skeleton ──────────────────────────────────────────────────── -->
    <div v-if="state === 'loading'" class="page-ship__skeleton" aria-busy="true" />

    <!-- ── Not found ─────────────────────────────────────────────────────────── -->
    <AppCard v-else-if="state === 'notfound'" class="page-ship__notfound">
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
          <AppBadge variant="brass" size="md" class="page-ship__class-chip">
            {{ t('classLabel') }}: {{ humaniseClass(ship.class) }}
          </AppBadge>
        </div>
        <div class="page-ship__header-actions">
          <AppSavePulse :state="headerSaveState" />
          <a
            :href="exportUrl"
            target="_blank"
            rel="noopener noreferrer"
            class="page-ship__export-link"
            data-testid="export-link"
          >
            {{ t('export') }}
            <span class="page-ship__export-chip">{{ t('exportExperimental') }}</span>
          </a>
          <AppButton variant="ghost" size="sm" :disabled="duplicating" @click="onDuplicate">
            {{ t('duplicate') }}
          </AppButton>
          <AppButton variant="ghost" size="sm" :disabled="deleting" @click="openDeleteConfirm">
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
          <AppField :label="t('fieldName')" required>
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
                @update:model-value="
                  (v) => {
                    localModel = typeof v === 'string' ? v : null;
                  }
                "
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
                @update:model-value="
                  (v) => {
                    localRegistry = typeof v === 'string' ? v : null;
                  }
                "
                @blur="identitySave.schedule()"
              />
            </template>
          </AppField>
        </div>
      </AppCard>

      <!-- ── Two-column operational layout ─────────────────────────────────── -->
      <!-- Primary (left): stats + modules  |  Secondary (right): crew + log   -->
      <div class="page-ship__columns">
        <!-- ── PRIMARY column ─────────────────────────────────────────────── -->
        <div class="page-ship__col page-ship__col--primary">
          <!-- Stats card — current/max pairs via AppStatPair + scalar stats -->
          <AppCard class="page-ship__card">
            <template #header>
              <span class="page-ship__card-title">{{ t('statsCardTitle') }}</span>
            </template>

            <!-- Hull + Energy as large current/max counters -->
            <div class="page-ship__pair-row">
              <AppStatPair
                :label="t('statHull')"
                :current="localHullCurrent"
                :max="localHullMax"
                tone="brass"
                @update:current="
                  localHullCurrent = $event;
                  statsSave.schedule();
                "
                @blur="statsSave.schedule()"
              />
              <AppStatPair
                :label="t('statEnergy')"
                :current="localEnergyCurrent"
                :max="localEnergyMax"
                tone="brass"
                @update:current="
                  localEnergyCurrent = $event;
                  statsSave.schedule();
                "
                @blur="statsSave.schedule()"
              />
            </div>

            <!-- Scalar stats: armor / maneuverability / signature / speed / cargo -->
            <div class="page-ship__scalars-grid">
              <!-- Armor -->
              <div class="page-ship__scalar">
                <span class="page-ship__scalar-label">{{ t('statArmor') }}</span>
                <AppInput
                  v-model="localArmor"
                  type="number"
                  size="md"
                  inputmode="numeric"
                  class="page-ship__scalar-input"
                  @blur="statsSave.schedule()"
                />
              </div>

              <!-- Maneuverability -->
              <div class="page-ship__scalar">
                <span class="page-ship__scalar-label">{{ t('statManeuverability') }}</span>
                <AppInput
                  v-model="localManeuverability"
                  type="number"
                  size="md"
                  inputmode="numeric"
                  class="page-ship__scalar-input"
                  @blur="statsSave.schedule()"
                />
              </div>

              <!-- Signature -->
              <div class="page-ship__scalar">
                <span class="page-ship__scalar-label">{{ t('statSignature') }}</span>
                <AppInput
                  v-model="localSignature"
                  type="number"
                  size="md"
                  inputmode="numeric"
                  class="page-ship__scalar-input"
                  @blur="statsSave.schedule()"
                />
              </div>

              <!-- Speed -->
              <div class="page-ship__scalar">
                <span class="page-ship__scalar-label">{{ t('statSpeed') }}</span>
                <AppInput
                  v-model="localSpeed"
                  type="number"
                  size="md"
                  inputmode="numeric"
                  class="page-ship__scalar-input"
                  @blur="statsSave.schedule()"
                />
              </div>

              <!-- Cargo capacity — read-only -->
              <div class="page-ship__scalar">
                <span class="page-ship__scalar-label">{{ t('statCargoCapacity') }}</span>
                <AppInput
                  :model-value="displayCargoCapacity"
                  type="number"
                  size="md"
                  inputmode="numeric"
                  class="page-ship__scalar-input"
                  readonly
                />
              </div>
            </div>
          </AppCard>

          <!-- Modules card -->
          <AppCard class="page-ship__card">
            <template #header>
              <div class="page-ship__card-header-row">
                <span class="page-ship__card-title">{{ t('modulesCardTitle') }}</span>
                <AppButton variant="ghost" size="sm" @click="openModuleCreate">
                  {{ t('modulesAdd') }}
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
                tabindex="0"
                role="button"
                @click="openModuleEdit(mod as ShipModule)"
                @keydown.enter.prevent="openModuleEdit(mod as ShipModule)"
                @keydown.space.prevent="openModuleEdit(mod as ShipModule)"
              >
                <AppBadge variant="darkness" size="sm" class="page-ship__module-slot">
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

            <p v-else class="page-ship__modules-empty">
              {{ t('modulesEmptySlot') }}
            </p>
          </AppCard>
        </div>

        <!-- ── SECONDARY column ───────────────────────────────────────────── -->
        <div class="page-ship__col page-ship__col--secondary">
          <!-- Crew card -->
          <AppCard class="page-ship__card">
            <template #header>
              <span class="page-ship__card-title">{{ t('crewCardTitle') }}</span>
            </template>

            <AppBanner v-if="crewError" tone="danger" role="alert" class="page-ship__crew-error">
              {{ crewError }}
            </AppBanner>

            <ul class="page-ship__crew-list" aria-label="Crew">
              <li v-for="slot in crewRoster" :key="slot.position" class="page-ship__crew-row">
                <span class="page-ship__crew-position">
                  {{ positionLabel(slot.position) }}
                </span>

                <template v-if="slot.assignedCharacterId">
                  <span class="page-ship__crew-name">
                    {{ characterName(slot.assignedCharacterId) }}
                  </span>
                  <AppButton
                    variant="ghost"
                    size="sm"
                    class="page-ship__crew-remove"
                    :disabled="crewBusy[slot.position]"
                    @click="onUnassign(slot.position, slot.assignedCharacterId)"
                  >
                    {{ t('crewRemove') }}
                  </AppButton>
                </template>

                <template v-else>
                  <em class="page-ship__crew-vacant">{{ t('crewVacant') }}</em>
                  <AppButton
                    variant="ghost"
                    size="sm"
                    class="page-ship__crew-assign-btn"
                    :disabled="crewBusy[slot.position]"
                    @click="togglePicker(slot.position)"
                  >
                    {{ pickerOpen[slot.position] ? t('crewPickerCancel') : t('crewAssign') }}
                  </AppButton>

                  <div v-if="pickerOpen[slot.position]" class="page-ship__crew-picker">
                    <AppField :label="t('crewPickerLabel')">
                      <template #default="attrs">
                        <select
                          v-bind="attrs"
                          :value="pickerSelected[slot.position] ?? ''"
                          class="page-ship__crew-select"
                          @change="
                            (e) => {
                              pickerSelected[slot.position] = (e.target as HTMLSelectElement).value;
                            }
                          "
                        >
                          <option value="" disabled>
                            {{ t('crewPickerPlaceholder') }}
                          </option>
                          <optgroup
                            v-if="pickableFor(slot.position).free.length > 0"
                            :label="t('crewPickerGroupFree')"
                          >
                            <option
                              v-for="ch in pickableFor(slot.position).free"
                              :key="ch.id"
                              :value="ch.id"
                            >
                              {{ ch.name }}
                            </option>
                          </optgroup>
                          <optgroup
                            v-if="pickableFor(slot.position).onShip.length > 0"
                            :label="t('crewPickerGroupOnShip')"
                          >
                            <option
                              v-for="ch in pickableFor(slot.position).onShip"
                              :key="ch.id"
                              :value="ch.id"
                            >
                              {{ ch.name }}
                            </option>
                          </optgroup>
                        </select>
                      </template>
                    </AppField>
                    <AppButton
                      variant="primary"
                      size="sm"
                      class="page-ship__crew-confirm"
                      :disabled="!pickerSelected[slot.position] || crewBusy[slot.position]"
                      @click="onAssign(slot.position)"
                    >
                      {{ t('crewPickerConfirm') }}
                    </AppButton>
                  </div>
                </template>
              </li>
            </ul>
          </AppCard>

          <!-- Notes card — collapsed by default when empty -->
          <AppCard class="page-ship__card">
            <template #header>
              <div class="page-ship__card-header-row">
                <span class="page-ship__card-title">{{ t('notesCardTitle') }}</span>
                <AppButton variant="ghost" size="sm" @click="notesOpen = !notesOpen">
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

          <!-- History card — collapsed by default when empty -->
          <AppCard class="page-ship__card">
            <template #header>
              <div class="page-ship__card-header-row">
                <span class="page-ship__card-title">{{ t('historyCardTitle') }}</span>
                <AppButton variant="ghost" size="sm" @click="historyOpen = !historyOpen">
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

          <!-- Problems card -->
          <AppCard class="page-ship__card">
            <template #header>
              <span class="page-ship__card-title">{{ t('problemsCardTitle') }}</span>
            </template>

            <AppField :label="t('problemsLabel')" :help-text="t('problemsHelp')">
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
        </div>
      </div>

      <!-- ── Module editor modal ───────────────────────────────────────────── -->
      <ShipModuleEditor
        :open="moduleEditorOpen"
        :ship-id="shipId"
        :module="editingModule"
        @update:open="moduleEditorOpen = $event"
        @update:module="onModuleUpdated"
        @delete:module="onModuleDeleted"
      />
    </template>

    <!-- ── Delete confirmation modal ─────────────────────────────────────────── -->
    <AppModal
      :open="deleteConfirmOpen"
      :aria-label="t('deleteConfirmTitle')"
      size="sm"
      :close-on-backdrop="false"
      :close-on-esc="!deleting"
      @update:open="
        (v) => {
          if (!v) closeDeleteConfirm();
        }
      "
    >
      <div class="page-ship__delete-modal">
        <p class="page-ship__delete-modal-heading">
          {{ t('deleteConfirmTitle') }}
        </p>
        <p class="page-ship__delete-modal-body">
          {{ t('deleteConfirmBody') }}
        </p>
        <div class="page-ship__delete-modal-actions">
          <AppButton variant="ghost" size="md" :disabled="deleting" @click="closeDeleteConfirm">
            {{ t('deleteConfirmNo') }}
          </AppButton>
          <AppButton variant="danger" size="md" :loading="deleting" @click="confirmDelete">
            {{ t('deleteConfirmYes') }}
          </AppButton>
        </div>
      </div>
    </AppModal>
  </section>
</template>

<style lang="scss" scoped>
  $skeleton-height: 200px;
  $scalar-input-width: 72px;
  $scalar-label-font-size: 11px;
  $page-max-width: 1200px;
  // Two-column layout breakpoint
  $bp-two-col: 768px;
  $crew-position-width: 140px;

  .page-ship {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    padding: var(--space-6);
    width: 100%;
    max-width: $page-max-width;
    margin: 0 auto;
    min-width: 0;

    @media (max-width: #{$bp-two-col}) {
      padding: var(--space-4) var(--space-3);
    }

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

    // ── Two-column operational layout ──────────────────────────────────────────
    // Primary (≈60%): stats + modules  |  Secondary (≈40%): crew + log/notes

    &__columns {
      display: grid;
      grid-template-columns: 3fr 2fr;
      gap: var(--space-5);
      align-items: start;

      @media (max-width: #{$bp-two-col}) {
        grid-template-columns: 1fr;
      }
    }

    &__col {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
      min-width: 0;
    }

    // ── Stat pair row (Hull + Energy as large counters) ────────────────────────

    &__pair-row {
      display: flex;
      gap: var(--space-8);
      margin-bottom: var(--space-5);
      flex-wrap: wrap;
    }

    // ── Scalar stats grid (armor / maneuv / sig / speed / cargo) ──────────────
    // Five stats in a wrapping row

    &__scalars-grid {
      display: flex;
      flex-wrap: wrap;
      gap: var(--space-4) var(--space-5);
    }

    &__scalar {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__scalar-label {
      font-family: var(--type-display-sm-font-family);
      font-size: $scalar-label-font-size;
      letter-spacing: 0.1em;
      text-transform: uppercase;
      color: var(--brand-brass-light);
      line-height: 1;
    }

    &__scalar-input {
      width: $scalar-input-width;
      text-align: center;
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
      cursor: pointer;
      padding: var(--space-2) var(--space-3);
      border-radius: var(--radius-sm);
      transition: background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        background-color: var(--surface-night);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass-light);
        outline-offset: 2px;
      }
    }

    &__module-slot {
      flex-shrink: 0;
      min-width: var(--space-12);
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
      gap: var(--space-3);
      flex-wrap: wrap;
    }

    &__crew-position {
      width: $crew-position-width;
      flex-shrink: 0;
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    &__crew-name {
      flex: 1;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-primary);
    }

    &__crew-vacant {
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
      font-style: italic;
      flex: 1;
    }

    &__crew-remove {
      flex-shrink: 0;
    }

    &__crew-assign-btn {
      flex-shrink: 0;
    }

    &__crew-error {
      margin-bottom: var(--space-3);
    }

    &__crew-picker {
      display: flex;
      align-items: flex-end;
      gap: var(--space-3);
      flex-wrap: wrap;
      width: 100%;
      padding: var(--space-3);
      background-color: var(--surface-night);
      border-radius: var(--radius-sm);
    }

    &__crew-select {
      width: 100%;
      padding: var(--space-2) var(--space-3);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-sm);
      color: var(--text-primary);
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);

      &:focus {
        outline: 2px solid var(--brand-brass-light);
        outline-offset: 2px;
      }
    }

    &__crew-confirm {
      flex-shrink: 0;
    }

    // ── Export affordance ──────────────────────────────────────────────────────

    &__export-link {
      display: inline-flex;
      align-items: center;
      gap: var(--space-1);
      padding: var(--space-1) var(--space-2);
      border-radius: var(--radius-sm);
      border: 1px solid transparent;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      text-decoration: none;
      cursor: pointer;
      transition:
        color var(--motion-duration-fast) var(--motion-ease-standard),
        background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        color: var(--text-primary);
        background-color: var(--surface-night);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    &__export-chip {
      display: inline-block;
      margin-left: var(--space-1);
      padding: 0 var(--space-1);
      border-radius: var(--radius-xs, 2px);
      background-color: color-mix(in srgb, var(--brand-brass-shadow) 30%, transparent);
      font-family: var(--font-mono);
      font-size: var(--type-body-xs-font-size);
      color: var(--text-secondary);
      vertical-align: middle;
    }

    // ── Delete confirmation modal ──────────────────────────────────────────────

    &__delete-modal {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
      padding: var(--space-5);
    }

    &__delete-modal-heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__delete-modal-body {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
    }

    &__delete-modal-actions {
      display: flex;
      justify-content: flex-end;
      gap: var(--space-3);
    }
  }
</style>
