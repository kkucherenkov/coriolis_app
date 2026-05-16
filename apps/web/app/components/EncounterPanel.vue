<script setup lang="ts">
  /**
   * EncounterPanel — session-scoped encounter list with inline create.
   *
   * Props:
   *   sessionId  — the parent game session ID, passed down from the page
   *
   * The panel owns its own data lifecycle: it fetches encounters on mount,
   * after create, and after delete. Combatant counts are fetched per
   * encounter in a second pass and stored in a reactive Map so partial
   * failures don't block the list render.
   *
   * State-machine hint: when an encounter is in `setup` and has zero
   * combatants, a localised advisory is shown below the card — the user
   * must add ≥1 combatant before rolling initiative (enforced server-side
   * with 422 ENCOUNTER_NO_COMBATANTS on the setup→active transition).
   */

  import { ref, computed, onMounted } from 'vue';
  import { AppCard, AppButton, AppInput, AppField, AppBanner, AppBadge } from '@app/ui';
  import { useEncountersApi } from '~/composables/useEncountersApi';
  import CombatTracker from '~/components/CombatTracker.vue';
  import type { Encounter } from '~/composables/useEncountersApi';
  import type { CombatUpdatedPayload } from '~/composables/useSessionRealtime';
  import type { EncounterStatus } from '@app/api-client-ts';

  const props = defineProps<{
    sessionId: string;
    /** IDs of Characters linked through session memberships — forwarded to CombatTracker for the PC picker. */
    sessionCharacterIds?: readonly string[];
    /** True when the current user is the session GM. Forwarded to CombatTracker for GM-only buttons. */
    isGm?: boolean;
    /**
     * Latest combat.updated snapshot from useSessionRealtime. When non-null and
     * matching an open encounter, CombatTracker replaces its local state wholesale.
     */
    combatSnapshot: CombatUpdatedPayload | null;
  }>();

  const { t } = useI18n({ useScope: 'local' });

  const encountersApi = useEncountersApi();

  // ── State ──────────────────────────────────────────────────────────────────
  type PanelState = 'loading' | 'loaded' | 'error';

  const panelState = ref<PanelState>('loading');
  const encounters = ref<Encounter[]>([]);
  const errorMsg = ref('');

  // Combatant counts: encounterId → count (loaded in a second pass)
  const combatantCounts = ref<Map<string, number>>(new Map());

  // ── Create form ────────────────────────────────────────────────────────────
  const showCreateForm = ref(false);
  const createName = ref('');
  const createNotes = ref('');
  const createBusy = ref(false);
  const createError = ref('');

  // ── Delete state ───────────────────────────────────────────────────────────
  const deletingId = ref<string | null>(null);

  // ── Open / expand state (master-detail inline expansion) ──────────────────
  /**
   * encounterId of the currently expanded CombatTracker, or null if none.
   * Clicking "Open" on a card toggles its expansion; clicking on an already-
   * expanded card collapses it.
   */
  const openEncounterId = ref<string | null>(null);

  function toggleEncounter(id: string): void {
    openEncounterId.value = openEncounterId.value === id ? null : id;
  }

  // ── Derived ────────────────────────────────────────────────────────────────
  const encounterCount = computed(() => encounters.value.length);

  function combatantCountFor(encounterId: string): number {
    return combatantCounts.value.get(encounterId) ?? 0;
  }

  function showSetupHint(encounter: Encounter): boolean {
    return encounter.status === 'setup' && combatantCountFor(encounter.id) === 0;
  }

  function stateBadgeVariant(status: Encounter['status']): 'brass' | 'mystic' | 'success' {
    if (status === 'active') return 'success';
    if (status === 'ended') return 'mystic';
    return 'brass';
  }

  function stateLabel(status: Encounter['status']): string {
    if (status === 'setup') return t('stateSetup');
    if (status === 'active') return t('stateActive');
    return t('stateEnded');
  }

  // ── Data loading ────────────────────────────────────────────────────────────
  async function loadEncounters(): Promise<void> {
    panelState.value = 'loading';
    errorMsg.value = '';
    try {
      const result = await encountersApi.list(props.sessionId);
      encounters.value = [...result.items];
      panelState.value = 'loaded';
      // Fire-and-forget combatant counts — partial failures are swallowed
      void loadCombatantCounts(encounters.value);
    } catch (error) {
      const problem = error as { detail?: string };
      errorMsg.value = problem.detail ?? t('errorLoad');
      panelState.value = 'error';
    }
  }

  async function loadCombatantCounts(list: Encounter[]): Promise<void> {
    const newMap = new Map<string, number>(combatantCounts.value);
    await Promise.all(
      list.map(async (enc) => {
        try {
          const result = await encountersApi.listCombatants(enc.id);
          newMap.set(enc.id, result.items.length);
        } catch {
          // Best-effort — leave existing count or 0 if unavailable
          if (!newMap.has(enc.id)) newMap.set(enc.id, 0);
        }
      }),
    );
    combatantCounts.value = newMap;
  }

  onMounted(() => {
    void loadEncounters();
  });

  // ── Create ──────────────────────────────────────────────────────────────────
  function openCreateForm(): void {
    createName.value = '';
    createNotes.value = '';
    createError.value = '';
    showCreateForm.value = true;
  }

  function cancelCreateForm(): void {
    showCreateForm.value = false;
    createError.value = '';
  }

  async function submitCreate(): Promise<void> {
    const name = createName.value.trim();
    if (!name) {
      createError.value = t('errorNameRequired');
      return;
    }
    createBusy.value = true;
    createError.value = '';
    try {
      await encountersApi.create(props.sessionId, {
        name,
        notes: createNotes.value.trim() || undefined,
      });
      showCreateForm.value = false;
      await loadEncounters();
    } catch (error) {
      const problem = error as { detail?: string };
      createError.value = problem.detail ?? t('errorCreate');
    } finally {
      createBusy.value = false;
    }
  }

  // ── Realtime encounter status patch ────────────────────────────────────────
  // Called by CombatTracker's encounterStatusChanged emit when a combat.updated
  // snapshot changes the encounter's status or activeCombatantId. We patch the
  // local encounters list in-place so the status badge and setup hint update
  // without a full panel refetch.
  function onEncounterStatusChanged(
    encounterId: string,
    status: EncounterStatus,
    activeCombatantId: string | null,
  ): void {
    const idx = encounters.value.findIndex((e) => e.id === encounterId);
    if (idx === -1) return;
    const existing = encounters.value[idx];
    if (!existing) return;
    encounters.value[idx] = { ...existing, status, activeCombatantId };
  }

  // ── Delete ──────────────────────────────────────────────────────────────────
  async function removeEncounter(id: string): Promise<void> {
    deletingId.value = id;
    try {
      await encountersApi.remove(id);
      await loadEncounters();
    } catch (error) {
      const problem = error as { detail?: string };
      errorMsg.value = problem.detail ?? t('errorDelete');
    } finally {
      deletingId.value = null;
    }
  }
</script>

<i18n lang="json">
{
  "en": {
    "heading": "Encounters",
    "createButton": "New Encounter",
    "cancelButton": "Cancel",
    "saveButton": "Create",
    "nameLabel": "Name",
    "namePlaceholder": "e.g. Ambush in the Spire",
    "notesLabel": "GM Notes",
    "notesPlaceholder": "Optional notes in Markdown…",
    "stateSetup": "Setup",
    "stateActive": "Active",
    "stateEnded": "Ended",
    "combatantsCount": "{count} combatant | {count} combatants",
    "hintNoCombatants": "Add at least one combatant before rolling initiative.",
    "openButton": "Open",
    "closeButton": "Close",
    "deleteButton": "Delete",
    "emptyHeading": "No encounters yet",
    "emptyBody": "Create the first encounter to start combat tracking.",
    "errorLoad": "Couldn't load encounters.",
    "errorCreate": "Couldn't create encounter.",
    "errorDelete": "Couldn't delete encounter.",
    "errorNameRequired": "Name is required.",
    "retryButton": "Retry"
  },
  "ru": {
    "heading": "Схватки",
    "createButton": "Новая схватка",
    "cancelButton": "Отмена",
    "saveButton": "Создать",
    "nameLabel": "Название",
    "namePlaceholder": "напр. «Засада в Шпиле»",
    "notesLabel": "Заметки ГМ",
    "notesPlaceholder": "Необязательные заметки в Markdown…",
    "stateSetup": "Настройка",
    "stateActive": "Активна",
    "stateEnded": "Завершена",
    "combatantsCount": "{count} участник | {count} участника | {count} участников",
    "hintNoCombatants": "Добавьте хотя бы одного участника перед броском инициативы.",
    "openButton": "Открыть",
    "closeButton": "Закрыть",
    "deleteButton": "Удалить",
    "emptyHeading": "Схваток пока нет",
    "emptyBody": "Создайте первую схватку, чтобы начать отслеживать бой.",
    "errorLoad": "Не удалось загрузить схватки.",
    "errorCreate": "Не удалось создать схватку.",
    "errorDelete": "Не удалось удалить схватку.",
    "errorNameRequired": "Название обязательно.",
    "retryButton": "Повторить"
  },
  "uk": {
    "heading": "[uk-todo] Encounters",
    "createButton": "[uk-todo] New Encounter",
    "cancelButton": "[uk-todo] Cancel",
    "saveButton": "[uk-todo] Create",
    "nameLabel": "[uk-todo] Name",
    "namePlaceholder": "[uk-todo] e.g. Ambush",
    "notesLabel": "[uk-todo] GM Notes",
    "notesPlaceholder": "[uk-todo] Optional notes",
    "stateSetup": "[uk-todo] Setup",
    "stateActive": "[uk-todo] Active",
    "stateEnded": "[uk-todo] Ended",
    "combatantsCount": "[uk-todo] {count} combatant(s)",
    "hintNoCombatants": "[uk-todo] Add at least one combatant before rolling initiative.",
    "openButton": "[uk-todo] Open",
    "closeButton": "[uk-todo] Close",
    "deleteButton": "[uk-todo] Delete",
    "emptyHeading": "[uk-todo] No encounters yet",
    "emptyBody": "[uk-todo] Create the first encounter.",
    "errorLoad": "[uk-todo] Couldn't load encounters.",
    "errorCreate": "[uk-todo] Couldn't create encounter.",
    "errorDelete": "[uk-todo] Couldn't delete encounter.",
    "errorNameRequired": "[uk-todo] Name is required.",
    "retryButton": "[uk-todo] Retry"
  },
  "el": {
    "heading": "[el-todo] Encounters",
    "createButton": "[el-todo] New Encounter",
    "cancelButton": "[el-todo] Cancel",
    "saveButton": "[el-todo] Create",
    "nameLabel": "[el-todo] Name",
    "namePlaceholder": "[el-todo] e.g. Ambush",
    "notesLabel": "[el-todo] GM Notes",
    "notesPlaceholder": "[el-todo] Optional notes",
    "stateSetup": "[el-todo] Setup",
    "stateActive": "[el-todo] Active",
    "stateEnded": "[el-todo] Ended",
    "combatantsCount": "[el-todo] {count} combatant(s)",
    "hintNoCombatants": "[el-todo] Add at least one combatant before rolling initiative.",
    "openButton": "[el-todo] Open",
    "closeButton": "[el-todo] Close",
    "deleteButton": "[el-todo] Delete",
    "emptyHeading": "[el-todo] No encounters yet",
    "emptyBody": "[el-todo] Create the first encounter.",
    "errorLoad": "[el-todo] Couldn't load encounters.",
    "errorCreate": "[el-todo] Couldn't create encounter.",
    "errorDelete": "[el-todo] Couldn't delete encounter.",
    "errorNameRequired": "[el-todo] Name is required.",
    "retryButton": "[el-todo] Retry"
  }
}
</i18n>

<template>
  <AppCard class="encounter-panel" data-testid="encounter-panel">
    <header class="encounter-panel__header">
      <h3 class="encounter-panel__title">
        {{ t('heading') }}
        <span v-if="panelState === 'loaded'" class="encounter-panel__count">
          ({{ encounterCount }})
        </span>
      </h3>
      <AppButton
        v-if="panelState === 'loaded' && !showCreateForm"
        variant="ghost"
        size="sm"
        data-testid="btn-new-encounter"
        @click="openCreateForm"
      >
        {{ t('createButton') }}
      </AppButton>
    </header>

    <!-- Error banner with retry -->
    <AppBanner
      v-if="panelState === 'error' || (panelState === 'loaded' && errorMsg)"
      tone="danger"
      role="alert"
      data-testid="encounter-panel-error"
    >
      {{ errorMsg }}
      <AppButton variant="ghost" size="sm" class="encounter-panel__retry" @click="loadEncounters">
        {{ t('retryButton') }}
      </AppButton>
    </AppBanner>

    <!-- Loading placeholder -->
    <p v-if="panelState === 'loading'" class="encounter-panel__placeholder">&hellip;</p>

    <!-- Inline create form -->
    <form
      v-if="showCreateForm"
      class="encounter-panel__create-form"
      data-testid="encounter-create-form"
      novalidate
      @submit.prevent="submitCreate"
    >
      <AppBanner v-if="createError" tone="danger" role="alert" data-testid="encounter-create-error">
        {{ createError }}
      </AppBanner>

      <AppField :label="t('nameLabel')" required>
        <template #default="slotAttrs">
          <AppInput
            v-bind="slotAttrs"
            v-model="createName"
            type="text"
            maxlength="80"
            :placeholder="t('namePlaceholder')"
            data-testid="encounter-name-input"
          />
        </template>
      </AppField>

      <AppField :label="t('notesLabel')">
        <template #default="slotAttrs">
          <AppInput
            v-bind="slotAttrs"
            v-model="createNotes"
            type="text"
            maxlength="4096"
            :placeholder="t('notesPlaceholder')"
            data-testid="encounter-notes-input"
          />
        </template>
      </AppField>

      <div class="encounter-panel__create-actions">
        <AppButton
          variant="ghost"
          size="sm"
          type="button"
          :disabled="createBusy"
          data-testid="btn-cancel-create"
          @click="cancelCreateForm"
        >
          {{ t('cancelButton') }}
        </AppButton>
        <AppButton
          variant="primary"
          size="sm"
          type="submit"
          :loading="createBusy"
          :disabled="createBusy"
          data-testid="btn-submit-create"
        >
          {{ t('saveButton') }}
        </AppButton>
      </div>
    </form>

    <!-- Empty state -->
    <div
      v-if="panelState === 'loaded' && encounters.length === 0"
      class="encounter-panel__empty"
      data-testid="encounter-panel-empty"
    >
      <p class="encounter-panel__empty-heading">
        {{ t('emptyHeading') }}
      </p>
      <p class="encounter-panel__empty-body">
        {{ t('emptyBody') }}
      </p>
    </div>

    <!-- Encounter list -->
    <ul
      v-if="panelState === 'loaded' && encounters.length > 0"
      class="encounter-panel__list"
      role="list"
    >
      <li
        v-for="encounter in encounters"
        :key="encounter.id"
        class="encounter-panel__card"
        data-testid="encounter-card"
      >
        <div class="encounter-panel__card-top">
          <span class="encounter-panel__card-name">{{ encounter.name }}</span>
          <AppBadge :variant="stateBadgeVariant(encounter.status)" size="sm">
            {{ stateLabel(encounter.status) }}
          </AppBadge>
        </div>

        <p class="encounter-panel__card-meta">
          {{
            t(
              'combatantsCount',
              { count: combatantCountFor(encounter.id) },
              combatantCountFor(encounter.id),
            )
          }}
        </p>

        <!-- State-machine hint: setup with no combatants -->
        <p
          v-if="showSetupHint(encounter)"
          class="encounter-panel__card-hint"
          data-testid="encounter-setup-hint"
        >
          {{ t('hintNoCombatants') }}
        </p>

        <div class="encounter-panel__card-actions">
          <AppButton
            variant="ghost"
            size="sm"
            :aria-expanded="openEncounterId === encounter.id"
            data-testid="btn-open-encounter"
            @click="toggleEncounter(encounter.id)"
          >
            {{ openEncounterId === encounter.id ? t('closeButton') : t('openButton') }}
          </AppButton>
          <AppButton
            variant="ghost"
            size="sm"
            :loading="deletingId === encounter.id"
            :disabled="deletingId === encounter.id"
            data-testid="btn-delete-encounter"
            @click="removeEncounter(encounter.id)"
          >
            {{ t('deleteButton') }}
          </AppButton>
        </div>

        <!-- Inline CombatTracker expansion (Block 5) -->
        <CombatTracker
          v-if="openEncounterId === encounter.id"
          class="encounter-panel__tracker"
          :encounter-id="encounter.id"
          :session-character-ids="[...(sessionCharacterIds ?? [])]"
          :active-combatant-id="encounter.activeCombatantId"
          :encounter-status="encounter.status"
          :is-gm="isGm ?? false"
          :combat-snapshot="combatSnapshot"
          data-testid="inline-combat-tracker"
          @encounter-status-changed="onEncounterStatusChanged"
        />
      </li>
    </ul>
  </AppCard>
</template>

<style lang="scss" scoped>
  .encounter-panel {
    padding: var(--space-4);
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

    &__count {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    &__placeholder {
      margin: 0;
      font-family: var(--font-body);
      color: var(--text-tertiary);
      font-style: italic;
    }

    &__retry {
      margin-left: var(--space-2);
    }

    &__create-form {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
      padding: var(--space-3);
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-sm);
    }

    &__create-actions {
      display: flex;
      gap: var(--space-2);
      justify-content: flex-end;
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

    &__card {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
      padding: var(--space-3);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-sm);
    }

    &__card-top {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: var(--space-2);
    }

    &__card-name {
      font-family: var(--font-display);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
      font-weight: var(--fw-bold);
    }

    &__card-meta {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--text-secondary);
    }

    &__card-hint {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--status-warning, var(--brand-brass));
      font-style: italic;
    }

    &__card-actions {
      display: flex;
      gap: var(--space-2);
      margin-top: var(--space-1);
    }

    &__tracker {
      margin-top: var(--space-2);
      padding-top: var(--space-2);
      border-top: 1px solid var(--brand-brass-shadow);
    }
  }
</style>
