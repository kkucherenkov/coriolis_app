<script setup lang="ts">
  /**
   * CombatTracker — inline combat encounter widget (T-2026-05-10-008 Block 4).
   *
   * Props:
   *   encounterId         — the encounter being tracked
   *   sessionCharacterIds — IDs of Characters assigned to the parent session.
   *                         The component fetches all of the current user's
   *                         characters and filters by this list for the PC picker.
   *
   * Block 4 scope: list, add (PC/NPC), remove, status-flag chips, drag handle.
   * NO Roll Initiative / Advance Turn / reorder-dispatch — Block 5 adds those.
   * Drag reorder reorders local state only (no backend PATCH in this block).
   */

  import { ref, computed, onMounted } from 'vue';
  import { AppButton, AppBadge, AppChip, AppInput, AppBanner } from '@app/ui';
  import { useCombatantsApi } from '~/composables/useCombatantsApi';
  import { useNpcsApi } from '~/composables/useNpcsApi';
  import { useCharactersApi } from '~/composables/useCharactersApi';
  import type { Combatant } from '~/composables/useEncountersApi';
  import type { Npc } from '~/composables/useNpcsApi';
  import type { Character } from '@app/api-client-ts';

  const props = defineProps<{
    encounterId: string;
    sessionCharacterIds: string[];
    /** Id of the currently active combatant (from encounter.activeCombatantId) */
    activeCombatantId: string | null;
  }>();

  const { t } = useI18n({ useScope: 'local' });

  const combatantsApi = useCombatantsApi();
  const npcsApi = useNpcsApi();
  const charactersApi = useCharactersApi();

  // ── Combatant list ────────────────────────────────────────────────────────────
  type LoadState = 'loading' | 'loaded' | 'error';

  const listState = ref<LoadState>('loading');
  const combatants = ref<Combatant[]>([]);
  const listError = ref('');

  /** Sorted by turnOrder (nulls last), then by displayName as stable tiebreak. */
  const sortedCombatants = computed<Combatant[]>(() => {
    return [...combatants.value].sort((a, b) => {
      if (a.turnOrder === null && b.turnOrder === null) {
        return a.displayName.localeCompare(b.displayName);
      }
      if (a.turnOrder === null) return 1;
      if (b.turnOrder === null) return -1;
      return a.turnOrder - b.turnOrder;
    });
  });

  async function loadCombatants(): Promise<void> {
    listState.value = 'loading';
    listError.value = '';
    try {
      const result = await combatantsApi.list(props.encounterId);
      combatants.value = [...result.items];
      listState.value = 'loaded';
    } catch (err) {
      const problem = err as { detail?: string };
      listError.value = problem.detail ?? t('errorLoad');
      listState.value = 'error';
    }
  }

  onMounted(() => {
    void loadCombatants();
  });

  // ── Drag reorder (local-only in Block 4) ─────────────────────────────────────
  const dragFromIndex = ref<number | null>(null);

  function onDragStart(index: number): void {
    dragFromIndex.value = index;
  }

  function onDragOver(event: DragEvent, index: number): void {
    event.preventDefault();
    const from = dragFromIndex.value;
    if (from === null || from === index) return;
    const copy = [...combatants.value];
    const [item] = copy.splice(from, 1);
    if (!item) return;
    copy.splice(index, 0, item);
    combatants.value = copy;
    dragFromIndex.value = index;
  }

  function onDragEnd(): void {
    dragFromIndex.value = null;
    // Block 5 will dispatch reorder to backend here
  }

  // ── Remove ────────────────────────────────────────────────────────────────────
  const removingId = ref<string | null>(null);
  const removeError = ref('');

  async function removeCombatant(id: string): Promise<void> {
    removingId.value = id;
    removeError.value = '';
    try {
      await combatantsApi.remove(id);
      combatants.value = combatants.value.filter((c) => c.id !== id);
    } catch (err) {
      const problem = err as { detail?: string };
      removeError.value = problem.detail ?? t('errorRemove');
    } finally {
      removingId.value = null;
    }
  }

  // ── Status-flag chips ─────────────────────────────────────────────────────────
  type CanonicalFlag = 'incapacitated' | 'prone' | 'covered';
  const CANONICAL_FLAGS: CanonicalFlag[] = ['incapacitated', 'prone', 'covered'];

  function isCanonical(flag: string): flag is CanonicalFlag {
    return (CANONICAL_FLAGS as string[]).includes(flag);
  }

  /** Icon name (heroicons) for canonical flags. */
  function canonicalFlagIcon(flag: CanonicalFlag): string {
    if (flag === 'incapacitated') return 'i-heroicons-x-circle';
    if (flag === 'prone') return 'i-heroicons-arrow-down-circle';
    return 'i-heroicons-shield-exclamation'; // covered
  }

  function canonicalFlagVariant(flag: CanonicalFlag): 'crimson' | 'brass' | 'mystic' {
    if (flag === 'incapacitated') return 'crimson';
    if (flag === 'prone') return 'brass';
    return 'mystic'; // covered
  }

  const updatingFlagFor = ref<string | null>(null);

  async function toggleFlag(combatant: Combatant, flag: string): Promise<void> {
    updatingFlagFor.value = combatant.id;
    const hasFlag = combatant.statusFlags.includes(flag);
    const next = hasFlag
      ? combatant.statusFlags.filter((f) => f !== flag)
      : [...combatant.statusFlags, flag];
    try {
      const updated = await combatantsApi.update(combatant.id, { statusFlags: next });
      const idx = combatants.value.findIndex((c) => c.id === combatant.id);
      if (idx !== -1) combatants.value[idx] = updated;
    } catch {
      // Swallow — flag reverts to server state on next load
    } finally {
      updatingFlagFor.value = null;
    }
  }

  async function removeFlag(combatant: Combatant, flag: string): Promise<void> {
    updatingFlagFor.value = combatant.id;
    const next = combatant.statusFlags.filter((f) => f !== flag);
    try {
      const updated = await combatantsApi.update(combatant.id, { statusFlags: next });
      const idx = combatants.value.findIndex((c) => c.id === combatant.id);
      if (idx !== -1) combatants.value[idx] = updated;
    } catch {
      // Swallow
    } finally {
      updatingFlagFor.value = null;
    }
  }

  // Add-chip input per combatant: keyed by combatant id
  const addFlagInput = ref<Record<string, string>>({});

  async function submitAddFlag(combatant: Combatant): Promise<void> {
    const tag = (addFlagInput.value[combatant.id] ?? '').trim();
    if (!tag || combatant.statusFlags.includes(tag)) {
      addFlagInput.value[combatant.id] = '';
      return;
    }
    updatingFlagFor.value = combatant.id;
    const next = [...combatant.statusFlags, tag];
    try {
      const updated = await combatantsApi.update(combatant.id, { statusFlags: next });
      const idx = combatants.value.findIndex((c) => c.id === combatant.id);
      if (idx !== -1) combatants.value[idx] = updated;
      addFlagInput.value[combatant.id] = '';
    } catch {
      // Swallow
    } finally {
      updatingFlagFor.value = null;
    }
  }

  // ── Add Combatant picker ──────────────────────────────────────────────────────
  const showPicker = ref(false);
  type PickerTab = 'pc' | 'npc';
  const pickerTab = ref<PickerTab>('pc');

  // PC picker
  const pcPickerState = ref<LoadState>('loading');
  const allCharacters = ref<Character[]>([]);
  const pcPickerError = ref('');

  const sessionCharacters = computed<Character[]>(() => {
    const ids = new Set(props.sessionCharacterIds);
    return allCharacters.value.filter((c) => ids.has(c.id));
  });

  const existingSourceIds = computed<Set<string>>(() => {
    return new Set(combatants.value.map((c) => c.sourceId));
  });

  const availablePcs = computed<Character[]>(() =>
    sessionCharacters.value.filter((c) => !existingSourceIds.value.has(c.id)),
  );

  const availableNpcs = computed<Npc[]>(() =>
    npcList.value.filter((n) => !existingSourceIds.value.has(n.id)),
  );

  // NPC picker
  const npcPickerState = ref<LoadState>('loading');
  const npcList = ref<Npc[]>([]);
  const npcPickerError = ref('');

  async function loadPicker(): Promise<void> {
    // Load PCs
    pcPickerState.value = 'loading';
    pcPickerError.value = '';
    try {
      const result = await charactersApi.list({ limit: 200 });
      allCharacters.value = [...result.items];
      pcPickerState.value = 'loaded';
    } catch (err) {
      const problem = err as { detail?: string };
      pcPickerError.value = problem.detail ?? t('errorLoadPcs');
      pcPickerState.value = 'error';
    }

    // Load NPCs
    npcPickerState.value = 'loading';
    npcPickerError.value = '';
    try {
      const result = await npcsApi.list({ limit: 200 });
      npcList.value = [...result.items];
      npcPickerState.value = 'loaded';
    } catch (err) {
      const problem = err as { detail?: string };
      npcPickerError.value = problem.detail ?? t('errorLoadNpcs');
      npcPickerState.value = 'error';
    }
  }

  function openPicker(): void {
    showPicker.value = true;
    void loadPicker();
  }

  function closePicker(): void {
    showPicker.value = false;
  }

  const addingId = ref<string | null>(null);

  async function addPc(character: Character): Promise<void> {
    addingId.value = character.id;
    try {
      const added = await combatantsApi.add(props.encounterId, {
        kind: 'pc',
        id: character.id,
      });
      combatants.value = [...combatants.value, added];
    } catch (err) {
      const problem = err as { detail?: string };
      listError.value = problem.detail ?? t('errorAdd');
    } finally {
      addingId.value = null;
    }
  }

  async function addNpc(npc: Npc): Promise<void> {
    addingId.value = npc.id;
    try {
      const added = await combatantsApi.add(props.encounterId, {
        kind: 'npc',
        id: npc.id,
      });
      combatants.value = [...combatants.value, added];
    } catch (err) {
      const problem = err as { detail?: string };
      listError.value = problem.detail ?? t('errorAdd');
    } finally {
      addingId.value = null;
    }
  }
</script>

<i18n lang="json">
{
  "en": {
    "heading": "Combatants",
    "addButton": "Add Combatant",
    "closePickerButton": "Close",
    "tabPc": "PC",
    "tabNpc": "NPC",
    "pcEmpty": "No session characters available.",
    "npcEmpty": "No NPCs in your library.",
    "addPcButton": "Add",
    "addNpcButton": "Add",
    "removeButton": "Remove",
    "emptyHeading": "No combatants yet",
    "emptyBody": "Add at least one combatant to begin.",
    "activeLabel": "Active turn",
    "flagIncapacitated": "Incapacitated",
    "flagProne": "Prone",
    "flagCovered": "Covered",
    "flagRemoveLabel": "Remove flag {flag}",
    "addFlagPlaceholder": "Add tag…",
    "addFlagButton": "Add tag",
    "hpLabel": "HP",
    "initiativeLabel": "Init",
    "orderLabel": "Order",
    "dragHandle": "Drag to reorder",
    "retryButton": "Retry",
    "errorLoad": "Couldn't load combatants.",
    "errorAdd": "Couldn't add combatant.",
    "errorRemove": "Couldn't remove combatant.",
    "errorLoadPcs": "Couldn't load characters.",
    "errorLoadNpcs": "Couldn't load NPCs."
  },
  "ru": {
    "heading": "Участники",
    "addButton": "Добавить участника",
    "closePickerButton": "Закрыть",
    "tabPc": "Персонаж",
    "tabNpc": "НПС",
    "pcEmpty": "Нет доступных персонажей сессии.",
    "npcEmpty": "Нет НПС в библиотеке.",
    "addPcButton": "Добавить",
    "addNpcButton": "Добавить",
    "removeButton": "Удалить",
    "emptyHeading": "Участников пока нет",
    "emptyBody": "Добавьте хотя бы одного участника.",
    "activeLabel": "Активный ход",
    "flagIncapacitated": "Небоеспособен",
    "flagProne": "Повержен",
    "flagCovered": "В укрытии",
    "flagRemoveLabel": "Убрать метку {flag}",
    "addFlagPlaceholder": "Добавить метку…",
    "addFlagButton": "Добавить",
    "hpLabel": "ОЗ",
    "initiativeLabel": "Иниц",
    "orderLabel": "Порядок",
    "dragHandle": "Перетащить для сортировки",
    "retryButton": "Повторить",
    "errorLoad": "Не удалось загрузить участников.",
    "errorAdd": "Не удалось добавить участника.",
    "errorRemove": "Не удалось удалить участника.",
    "errorLoadPcs": "Не удалось загрузить персонажей.",
    "errorLoadNpcs": "Не удалось загрузить НПС."
  },
  "uk": {
    "heading": "[uk-todo] Combatants",
    "addButton": "[uk-todo] Add Combatant",
    "closePickerButton": "[uk-todo] Close",
    "tabPc": "[uk-todo] PC",
    "tabNpc": "[uk-todo] NPC",
    "pcEmpty": "[uk-todo] No session characters available.",
    "npcEmpty": "[uk-todo] No NPCs in your library.",
    "addPcButton": "[uk-todo] Add",
    "addNpcButton": "[uk-todo] Add",
    "removeButton": "[uk-todo] Remove",
    "emptyHeading": "[uk-todo] No combatants yet",
    "emptyBody": "[uk-todo] Add at least one combatant to begin.",
    "activeLabel": "[uk-todo] Active turn",
    "flagIncapacitated": "[uk-todo] Incapacitated",
    "flagProne": "[uk-todo] Prone",
    "flagCovered": "[uk-todo] Covered",
    "flagRemoveLabel": "[uk-todo] Remove flag {flag}",
    "addFlagPlaceholder": "[uk-todo] Add tag…",
    "addFlagButton": "[uk-todo] Add tag",
    "hpLabel": "[uk-todo] HP",
    "initiativeLabel": "[uk-todo] Init",
    "orderLabel": "[uk-todo] Order",
    "dragHandle": "[uk-todo] Drag to reorder",
    "retryButton": "[uk-todo] Retry",
    "errorLoad": "[uk-todo] Couldn't load combatants.",
    "errorAdd": "[uk-todo] Couldn't add combatant.",
    "errorRemove": "[uk-todo] Couldn't remove combatant.",
    "errorLoadPcs": "[uk-todo] Couldn't load characters.",
    "errorLoadNpcs": "[uk-todo] Couldn't load NPCs."
  },
  "el": {
    "heading": "[el-todo] Combatants",
    "addButton": "[el-todo] Add Combatant",
    "closePickerButton": "[el-todo] Close",
    "tabPc": "[el-todo] PC",
    "tabNpc": "[el-todo] NPC",
    "pcEmpty": "[el-todo] No session characters available.",
    "npcEmpty": "[el-todo] No NPCs in your library.",
    "addPcButton": "[el-todo] Add",
    "addNpcButton": "[el-todo] Add",
    "removeButton": "[el-todo] Remove",
    "emptyHeading": "[el-todo] No combatants yet",
    "emptyBody": "[el-todo] Add at least one combatant to begin.",
    "activeLabel": "[el-todo] Active turn",
    "flagIncapacitated": "[el-todo] Incapacitated",
    "flagProne": "[el-todo] Prone",
    "flagCovered": "[el-todo] Covered",
    "flagRemoveLabel": "[el-todo] Remove flag {flag}",
    "addFlagPlaceholder": "[el-todo] Add tag…",
    "addFlagButton": "[el-todo] Add tag",
    "hpLabel": "[el-todo] HP",
    "initiativeLabel": "[el-todo] Init",
    "orderLabel": "[el-todo] Order",
    "dragHandle": "[el-todo] Drag to reorder",
    "retryButton": "[el-todo] Retry",
    "errorLoad": "[el-todo] Couldn't load combatants.",
    "errorAdd": "[el-todo] Couldn't add combatant.",
    "errorRemove": "[el-todo] Couldn't remove combatant.",
    "errorLoadPcs": "[el-todo] Couldn't load characters.",
    "errorLoadNpcs": "[el-todo] Couldn't load NPCs."
  }
}
</i18n>

<template>
  <div class="combat-tracker" data-testid="combat-tracker">
    <!-- Header (Block 5 will add Roll Initiative / Advance Turn here) -->
    <header class="combat-tracker__header">
      <h4 class="combat-tracker__title">{{ t('heading') }}</h4>
      <!-- Placeholder for Block 5 initiative action buttons -->
      <div class="combat-tracker__header-actions">
        <AppButton
          variant="ghost"
          size="sm"
          data-testid="btn-add-combatant"
          @click="openPicker"
        >
          {{ t('addButton') }}
        </AppButton>
      </div>
    </header>

    <!-- Error banner -->
    <div
      v-if="listError"
      class="combat-tracker__banner"
      role="alert"
      data-testid="combat-tracker-error"
    >
      <AppBanner tone="danger">
        {{ listError }}
        <AppButton
          variant="ghost"
          size="sm"
          class="combat-tracker__retry"
          @click="loadCombatants"
        >
          {{ t('retryButton') }}
        </AppButton>
      </AppBanner>
    </div>

    <!-- Loading -->
    <p v-if="listState === 'loading'" class="combat-tracker__placeholder">&hellip;</p>

    <!-- Empty state -->
    <div
      v-if="listState === 'loaded' && combatants.length === 0"
      class="combat-tracker__empty"
      data-testid="combat-tracker-empty"
    >
      <p class="combat-tracker__empty-heading">{{ t('emptyHeading') }}</p>
      <p class="combat-tracker__empty-body">{{ t('emptyBody') }}</p>
    </div>

    <!-- Combatant list -->
    <ul
      v-if="listState === 'loaded' && combatants.length > 0"
      class="combat-tracker__list"
      role="list"
      data-testid="combatant-list"
    >
      <li
        v-for="(combatant, index) in sortedCombatants"
        :key="combatant.id"
        class="combat-tracker__row"
        :class="{
          'combat-tracker__row--active': combatant.id === activeCombatantId,
          'combat-tracker__row--dragging': dragFromIndex === index,
        }"
        :data-testid="`combatant-row-${combatant.id}`"
        draggable="true"
        @dragstart="onDragStart(index)"
        @dragover="onDragOver($event, index)"
        @dragend="onDragEnd"
      >
        <!-- Drag handle -->
        <span
          class="combat-tracker__drag-handle"
          :aria-label="t('dragHandle')"
          role="img"
          aria-hidden="true"
        >
          &#8942;
        </span>

        <!-- Active indicator -->
        <span
          v-if="combatant.id === activeCombatantId"
          class="combat-tracker__active-indicator"
          :aria-label="t('activeLabel')"
          role="img"
        >
          &#9658;
        </span>

        <!-- Combatant info -->
        <div class="combat-tracker__row-body">
          <div class="combat-tracker__row-top">
            <span class="combat-tracker__name">{{ combatant.displayName }}</span>
            <AppBadge variant="brass" size="sm">
              {{ combatant.combatantType === 'pc' ? t('tabPc') : t('tabNpc') }}
            </AppBadge>
            <span class="combat-tracker__hp">
              {{ t('hpLabel') }}: {{ combatant.hpCurrent }}/{{ combatant.hpMax }}
            </span>
            <span v-if="combatant.initiative !== null" class="combat-tracker__initiative">
              {{ t('initiativeLabel') }}: {{ combatant.initiative }}
            </span>
          </div>

          <!-- Status-flag chips -->
          <div class="combat-tracker__flags" data-testid="status-flags">
            <!-- Canonical flags: toggleable with icon -->
            <template v-for="flag in CANONICAL_FLAGS" :key="flag">
              <AppChip
                :model-value="combatant.statusFlags.includes(flag)"
                :variant="canonicalFlagVariant(flag)"
                size="sm"
                :disabled="updatingFlagFor === combatant.id"
                :aria-label="t(`flag${flag.charAt(0).toUpperCase() + flag.slice(1)}`)"
                :data-testid="`chip-canonical-${flag}`"
                @update:model-value="toggleFlag(combatant, flag)"
              >
                <UIcon :name="canonicalFlagIcon(flag)" class="combat-tracker__flag-icon" />
                {{ t(`flag${flag.charAt(0).toUpperCase() + flag.slice(1)}`) }}
              </AppChip>
            </template>

            <!-- Free-form flags: removable chips -->
            <template
              v-for="flag in combatant.statusFlags.filter((f) => !isCanonical(f))"
              :key="flag"
            >
              <AppChip
                :model-value="true"
                variant="brass"
                size="sm"
                removable
                :disabled="updatingFlagFor === combatant.id"
                :data-testid="`chip-freeform-${flag}`"
                @remove="removeFlag(combatant, flag)"
              >
                {{ flag }}
              </AppChip>
            </template>

            <!-- Add-chip input -->
            <form
              class="combat-tracker__add-flag"
              @submit.prevent="submitAddFlag(combatant)"
            >
              <AppInput
                :model-value="addFlagInput[combatant.id] ?? ''"
                type="text"
                size="sm"
                maxlength="40"
                :placeholder="t('addFlagPlaceholder')"
                :disabled="updatingFlagFor === combatant.id"
                :aria-label="t('addFlagButton')"
                :data-testid="`add-flag-input-${combatant.id}`"
                @update:model-value="(v: string | number | null) => { addFlagInput[combatant.id] = String(v ?? '') }"
              />
            </form>
          </div>
        </div>

        <!-- Per-row remove -->
        <AppButton
          variant="ghost"
          size="sm"
          :loading="removingId === combatant.id"
          :disabled="removingId === combatant.id"
          class="combat-tracker__remove"
          :data-testid="`btn-remove-combatant-${combatant.id}`"
          @click="removeCombatant(combatant.id)"
        >
          {{ t('removeButton') }}
        </AppButton>
      </li>
    </ul>

    <!-- Add Combatant picker -->
    <div v-if="showPicker" class="combat-tracker__picker" data-testid="combatant-picker">
      <div class="combat-tracker__picker-header">
        <!-- Tab bar -->
        <div class="combat-tracker__picker-tabs" role="tablist">
          <button
            type="button"
            role="tab"
            class="combat-tracker__picker-tab"
            :class="{ 'combat-tracker__picker-tab--active': pickerTab === 'pc' }"
            :aria-selected="pickerTab === 'pc'"
            data-testid="picker-tab-pc"
            @click="pickerTab = 'pc'"
          >
            {{ t('tabPc') }}
          </button>
          <button
            type="button"
            role="tab"
            class="combat-tracker__picker-tab"
            :class="{ 'combat-tracker__picker-tab--active': pickerTab === 'npc' }"
            :aria-selected="pickerTab === 'npc'"
            data-testid="picker-tab-npc"
            @click="pickerTab = 'npc'"
          >
            {{ t('tabNpc') }}
          </button>
        </div>
        <AppButton variant="ghost" size="sm" data-testid="btn-close-picker" @click="closePicker">
          {{ t('closePickerButton') }}
        </AppButton>
      </div>

      <!-- PC tab -->
      <div v-if="pickerTab === 'pc'" role="tabpanel" data-testid="picker-panel-pc">
        <p v-if="pcPickerState === 'loading'" class="combat-tracker__placeholder">&hellip;</p>
        <p v-if="pcPickerError" class="combat-tracker__picker-error" role="alert">
          {{ pcPickerError }}
        </p>
        <p
          v-if="pcPickerState === 'loaded' && availablePcs.length === 0"
          class="combat-tracker__picker-empty"
          data-testid="pc-picker-empty"
        >
          {{ t('pcEmpty') }}
        </p>
        <ul v-if="pcPickerState === 'loaded' && availablePcs.length > 0" class="combat-tracker__picker-list" role="list">
          <li
            v-for="character in availablePcs"
            :key="character.id"
            class="combat-tracker__picker-item"
            :data-testid="`pc-picker-item-${character.id}`"
          >
            <span class="combat-tracker__picker-name">{{ character.name }}</span>
            <AppButton
              variant="ghost"
              size="sm"
              :loading="addingId === character.id"
              :disabled="addingId !== null"
              :data-testid="`btn-add-pc-${character.id}`"
              @click="addPc(character)"
            >
              {{ t('addPcButton') }}
            </AppButton>
          </li>
        </ul>
      </div>

      <!-- NPC tab -->
      <div v-if="pickerTab === 'npc'" role="tabpanel" data-testid="picker-panel-npc">
        <p v-if="npcPickerState === 'loading'" class="combat-tracker__placeholder">&hellip;</p>
        <p v-if="npcPickerError" class="combat-tracker__picker-error" role="alert">
          {{ npcPickerError }}
        </p>
        <p
          v-if="npcPickerState === 'loaded' && availableNpcs.length === 0"
          class="combat-tracker__picker-empty"
          data-testid="npc-picker-empty"
        >
          {{ t('npcEmpty') }}
        </p>
        <ul v-if="npcPickerState === 'loaded' && availableNpcs.length > 0" class="combat-tracker__picker-list" role="list">
          <li
            v-for="npc in availableNpcs"
            :key="npc.id"
            class="combat-tracker__picker-item"
            :data-testid="`npc-picker-item-${npc.id}`"
          >
            <span class="combat-tracker__picker-name">{{ npc.name }}</span>
            <AppButton
              variant="ghost"
              size="sm"
              :loading="addingId === npc.id"
              :disabled="addingId !== null"
              :data-testid="`btn-add-npc-${npc.id}`"
              @click="addNpc(npc)"
            >
              {{ t('addNpcButton') }}
            </AppButton>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  .combat-tracker {
    display: flex;
    flex-direction: column;
    gap: var(--space-3);

    &__header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: var(--space-2);
    }

    &__title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__header-actions {
      display: flex;
      gap: var(--space-2);
      align-items: center;
    }

    &__placeholder {
      margin: 0;
      font-family: var(--font-body);
      color: var(--text-tertiary);
      font-style: italic;
    }

    &__banner {
      display: contents;
    }

    &__retry {
      margin-left: var(--space-2);
    }

    &__empty {
      padding: var(--space-6) var(--space-4);
      text-align: center;
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-md);
    }

    &__empty-heading {
      margin: 0 0 var(--space-1);
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__empty-body {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    &__list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__row {
      display: flex;
      align-items: flex-start;
      gap: var(--space-2);
      padding: var(--space-2) var(--space-3);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-sm);
      transition: background-color 0.15s;

      &--active {
        border-color: var(--brand-brass);
        background-color: color-mix(in srgb, var(--brand-brass) 8%, transparent);
      }

      &--dragging {
        opacity: 0.6;
      }
    }

    &__drag-handle {
      flex-shrink: 0;
      cursor: grab;
      color: var(--text-tertiary);
      font-size: var(--type-body-lg-font-size);
      user-select: none;
      padding-top: var(--space-1);

      &:active {
        cursor: grabbing;
      }
    }

    &__active-indicator {
      flex-shrink: 0;
      color: var(--brand-brass);
      font-size: var(--type-body-sm-font-size);
      padding-top: var(--space-1);
    }

    &__row-body {
      flex: 1;
      min-width: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__row-top {
      display: flex;
      align-items: center;
      gap: var(--space-2);
      flex-wrap: wrap;
    }

    &__name {
      font-family: var(--font-display);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
      font-weight: var(--fw-bold);
    }

    &__hp {
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--text-secondary);
    }

    &__initiative {
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--brand-brass-light);
    }

    &__flags {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: var(--space-1);
    }

    &__flag-icon {
      width: 0.875rem;
      height: 0.875rem;
      vertical-align: middle;
    }

    &__add-flag {
      display: contents;
    }

    &__remove {
      flex-shrink: 0;
      align-self: flex-start;
    }

    // ── Picker ──────────────────────────────────────────────────────────────────

    &__picker {
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-sm);
      padding: var(--space-3);
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__picker-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: var(--space-2);
    }

    &__picker-tabs {
      display: flex;
      gap: var(--space-1);
    }

    &__picker-tab {
      padding: var(--space-1) var(--space-3);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-sm);
      background: transparent;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      cursor: pointer;
      transition: color 0.15s, border-color 0.15s;

      &--active {
        color: var(--brand-brass-light);
        border-color: var(--brand-brass);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    &__picker-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
      max-height: 16rem;
      overflow-y: auto;
    }

    &__picker-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: var(--space-2);
      padding: var(--space-1) var(--space-2);
      border-radius: var(--radius-sm);

      &:hover {
        background-color: color-mix(in srgb, var(--brand-brass) 6%, transparent);
      }
    }

    &__picker-name {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
    }

    &__picker-empty {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-tertiary);
      font-style: italic;
      padding: var(--space-2) 0;
    }

    &__picker-error {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--status-danger, var(--brand-crimson));
    }
  }
</style>
