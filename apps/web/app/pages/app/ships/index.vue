<script setup lang="ts">
  import { AppCard, AppButton, AppInput, AppField, AppBadge, AppBanner, AppModal } from '@app/ui';
  import { ref, computed, onMounted, onUnmounted } from 'vue';
  import { useRoute, useRouter } from 'vue-router';
  import { useShipsApi } from '~/composables/useShipsApi';
  import type { Ship, ShipClass } from '~/composables/useShipsApi';
  import type { Problem } from '@app/api-client-ts';

  /**
   * Ships index — ships owned by the authenticated user. Phase 5
   * T-2026-05-10-005 Block 1.
   *
   * The OpenAPI list endpoint is cursor-paginated; for v1 we just take
   * the first page (limit=20) — a "Load more" affordance lands in a
   * follow-up when the corpus grows past that.
   * TODO: expose "Load more" using `nextCursor` when needed.
   */

  const { t } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const router = useRouter();
  const shipsApi = useShipsApi();

  type LoadState = 'loading' | 'loaded' | 'error';

  const state = ref<LoadState>('loading');
  const ships = ref<Ship[]>([]);
  const errorMsg = ref('');

  // ── All 20 ShipClass values from ST3001 ГЛАВА 7 Table 7.4 ──────────────────
  const ALL_SHIP_CLASSES: ShipClass[] = [
    'fighter',
    'shuttle',
    'torpedo-boat',
    'light-freighter',
    'light-passenger',
    'courier-yacht',
    'clipper',
    'patrol-boat',
    'gunboat',
    'assault-ship',
    'blockade-runner',
    'pleasure-yacht',
    'flying-circus',
    'prospector',
    'rescue-ship',
    'passenger-liner',
    'heavy-freighter',
    'cruiser',
    'destroyer',
    'heavy-cruiser',
  ];

  /** Title-cases a kebab-case class string for display: "light-freighter" → "Light Freighter" */
  function humaniseClass(cls: ShipClass): string {
    return cls
      .split('-')
      .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
      .join(' ');
  }

  // ── New-ship form ────────────────────────────────────────────────────────────
  const formOpen = ref(false);
  const newName = ref('');
  const newClass = ref<ShipClass>('light-freighter');
  const newModel = ref('');
  const newRegistry = ref('');
  const creating = ref(false);
  const formError = ref('');

  const newNameTrimmed = computed(() => newName.value.trim());
  const formValid = computed(
    () => newNameTrimmed.value.length > 0 && newNameTrimmed.value.length <= 80,
  );

  async function load(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const data = await shipsApi.list({ limit: 20 });
      ships.value = [...data.items];
      state.value = 'loaded';
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorLoad');
      state.value = 'error';
    }
  }

  function openForm(): void {
    formOpen.value = true;
    newName.value = '';
    newClass.value = 'light-freighter';
    newModel.value = '';
    newRegistry.value = '';
    formError.value = '';
  }

  function closeForm(): void {
    formOpen.value = false;
  }

  async function onCreate(): Promise<void> {
    formError.value = '';
    if (!formValid.value) {
      formError.value = t('errorNameRequired');
      return;
    }
    creating.value = true;
    try {
      const ship = await shipsApi.create({
        name: newNameTrimmed.value,
        class: newClass.value,
        model: newModel.value.trim() || null,
        registry: newRegistry.value.trim() || null,
      });
      // Navigate straight to the detail page so the player can start
      // kit-bashing modules (Block 2 fills in the real sheet).
      await navigateTo(`/app/ships/${ship.id}`);
    } catch (error) {
      const problem = error as Problem;
      formError.value = problem.detail ?? t('errorCreate');
    } finally {
      creating.value = false;
    }
  }

  async function onDuplicate(ship: Ship): Promise<void> {
    try {
      const copy = await shipsApi.duplicate(ship.id);
      await navigateTo(`/app/ships/${copy.id}?duplicatedFrom=${encodeURIComponent(ship.name)}`);
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorDuplicate');
    }
  }

  // ── Delete confirm ─────────────────────────────────────────────────────────

  const deleteConfirmOpen = ref(false);
  const deletingShip = ref<Ship | null>(null);
  const deleting = ref(false);

  function openDeleteConfirm(ship: Ship): void {
    deletingShip.value = ship;
    deleteConfirmOpen.value = true;
  }

  function closeDeleteConfirm(): void {
    deleteConfirmOpen.value = false;
    deletingShip.value = null;
  }

  async function confirmDelete(): Promise<void> {
    if (!deletingShip.value) return;
    deleting.value = true;
    try {
      await shipsApi.delete(deletingShip.value.id);
      deleteConfirmOpen.value = false;
      deletingShip.value = null;
      await load();
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorDelete');
      deleteConfirmOpen.value = false;
      deletingShip.value = null;
    } finally {
      deleting.value = false;
    }
  }

  // ── Duplicate toast — "recently created" banner from redirect ─────────────

  const duplicatedFromName = ref('');
  const showDuplicatedToast = ref(false);
  let toastTimer: ReturnType<typeof setTimeout> | null = null;

  onMounted(() => {
    void load();
    const fromQuery = route.query.duplicatedFrom;
    if (typeof fromQuery === 'string' && fromQuery.length > 0) {
      duplicatedFromName.value = fromQuery;
      showDuplicatedToast.value = true;
      // Clear the query param so a refresh doesn't re-trigger.
      void router.replace({ query: {} });
      toastTimer = setTimeout(() => {
        showDuplicatedToast.value = false;
        duplicatedFromName.value = '';
      }, 4000);
    }
  });

  onUnmounted(() => {
    if (toastTimer !== null) clearTimeout(toastTimer);
  });

  function moduleCount(ship: Ship): number {
    // Subtract the three mandatory modules (BRIDGE, REACTOR, DRIVE) to show
    // only optional installed modules in the badge.
    return Math.max(0, ship.modules.length - 3);
  }

  function crewCount(ship: Ship): number {
    return ship.crew.filter((slot) => slot.assignedCharacterId != null).length;
  }
</script>

<i18n lang="json">
{
  "en": {
    "pageTitle": "Ships",
    "newShip": "New ship",
    "emptyHeading": "Build your fleet",
    "emptyBody": "Spin up your first ship to start tracking modules, crew, and combat stats. Pick a class from the form above to get going.",
    "errorLoad": "Couldn't load ships.",
    "errorCreate": "Couldn't create that ship.",
    "errorDelete": "Couldn't delete that ship.",
    "errorDuplicate": "Couldn't duplicate that ship.",
    "deleteConfirmTitle": "Delete this ship?",
    "deleteConfirmBody": "This will permanently delete the ship, its modules, and clear the crew roster. This cannot be undone.",
    "deleteConfirmYes": "Delete",
    "deleteConfirmNo": "Cancel",
    "duplicatedToast": "Duplicated \"{name}\" to a new ship.",
    "errorNameRequired": "A ship name is required (1–80 characters).",
    "formNameLabel": "Ship name",
    "formNameHint": "Short label, 1–80 characters.",
    "formNamePlaceholder": "e.g. Scarab of Kua",
    "formClassLabel": "Class",
    "formClassHint": "Hull class from ST3001 Chapter 7.",
    "formModelLabel": "Model",
    "formModelHint": "Optional — shipyard model name.",
    "formModelPlaceholder": "e.g. Helebian Class III",
    "formRegistryLabel": "Registry",
    "formRegistryHint": "Optional — transponder code.",
    "formRegistryPlaceholder": "e.g. KUA-7741-M",
    "formCreateButton": "Create ship",
    "formCancelButton": "Cancel",
    "open": "Open",
    "duplicate": "Duplicate",
    "delete": "Delete",
    "hullLabel": "Hull",
    "energyLabel": "Energy",
    "modulesCount": "{n} module | {n} modules",
    "crewCount": "{n} crew",
    "retry": "Try again"
  },
  "ru": {
    "pageTitle": "Корабли",
    "newShip": "Новый корабль",
    "emptyHeading": "Соберите свой флот",
    "emptyBody": "Создайте первый корабль и начните отслеживать модули, экипаж и боевые характеристики. Выберите класс в форме выше, чтобы начать.",
    "errorLoad": "Не удалось загрузить корабли.",
    "errorCreate": "Не удалось создать корабль.",
    "errorDelete": "Не удалось удалить корабль.",
    "errorDuplicate": "Не удалось продублировать корабль.",
    "deleteConfirmTitle": "Удалить этот корабль?",
    "deleteConfirmBody": "Это безвозвратно удалит корабль, его модули и очистит список экипажа. Действие необратимо.",
    "deleteConfirmYes": "Удалить",
    "deleteConfirmNo": "Отмена",
    "duplicatedToast": "«{name}» скопирован в новый корабль.",
    "errorNameRequired": "Название корабля обязательно (1–80 символов).",
    "formNameLabel": "Название",
    "formNameHint": "Короткое имя, 1–80 символов.",
    "formNamePlaceholder": "напр. «Скараб Куа»",
    "formClassLabel": "Класс",
    "formClassHint": "Класс корпуса по ST3001 Глава 7.",
    "formModelLabel": "Модель",
    "formModelHint": "По желанию — название модели верфи.",
    "formModelPlaceholder": "напр. Хелебиан Класс III",
    "formRegistryLabel": "Реестровый номер",
    "formRegistryHint": "По желанию — код транспондера.",
    "formRegistryPlaceholder": "напр. KUA-7741-M",
    "formCreateButton": "Создать",
    "formCancelButton": "Отмена",
    "open": "Открыть",
    "duplicate": "Дублировать",
    "delete": "Удалить",
    "hullLabel": "Корпус",
    "energyLabel": "Энергия",
    "modulesCount": "{n} модуль | {n} модуля | {n} модулей",
    "crewCount": "{n} чел. экипажа",
    "retry": "Попробовать снова"
  },
  "uk": {
    "pageTitle": "[uk-todo] Ships",
    "newShip": "[uk-todo] New ship",
    "emptyHeading": "[uk-todo] Build your fleet",
    "emptyBody": "[uk-todo] Spin up your first ship to start tracking modules, crew, and combat stats.",
    "errorLoad": "[uk-todo] Couldn't load ships",
    "errorCreate": "[uk-todo] Couldn't create that ship",
    "errorDelete": "[uk-todo] Couldn't delete that ship",
    "errorDuplicate": "[uk-todo] Couldn't duplicate that ship",
    "deleteConfirmTitle": "[uk-todo] Delete this ship?",
    "deleteConfirmBody": "[uk-todo] This will permanently delete the ship, its modules, and clear the crew roster. This cannot be undone.",
    "deleteConfirmYes": "[uk-todo] Delete",
    "deleteConfirmNo": "[uk-todo] Cancel",
    "duplicatedToast": "[uk-todo] Duplicated \"{name}\" to a new ship.",
    "errorNameRequired": "[uk-todo] Name required",
    "formNameLabel": "[uk-todo] Ship name",
    "formNameHint": "[uk-todo] 1-80 characters",
    "formNamePlaceholder": "[uk-todo] e.g. Scarab of Kua",
    "formClassLabel": "[uk-todo] Class",
    "formClassHint": "[uk-todo] Hull class",
    "formModelLabel": "[uk-todo] Model",
    "formModelHint": "[uk-todo] Optional model name",
    "formModelPlaceholder": "[uk-todo] e.g. Helebian Class III",
    "formRegistryLabel": "[uk-todo] Registry",
    "formRegistryHint": "[uk-todo] Optional transponder code",
    "formRegistryPlaceholder": "[uk-todo] e.g. KUA-7741-M",
    "formCreateButton": "[uk-todo] Create ship",
    "formCancelButton": "[uk-todo] Cancel",
    "open": "[uk-todo] Open",
    "duplicate": "[uk-todo] Duplicate",
    "delete": "[uk-todo] Delete",
    "hullLabel": "[uk-todo] Hull",
    "energyLabel": "[uk-todo] Energy",
    "modulesCount": "[uk-todo] {n} modules",
    "crewCount": "[uk-todo] {n} crew",
    "retry": "[uk-todo] Try again"
  },
  "el": {
    "pageTitle": "[el-todo] Ships",
    "newShip": "[el-todo] New ship",
    "emptyHeading": "[el-todo] Build your fleet",
    "emptyBody": "[el-todo] Spin up your first ship to start tracking modules, crew, and combat stats.",
    "errorLoad": "[el-todo] Couldn't load ships",
    "errorCreate": "[el-todo] Couldn't create that ship",
    "errorDelete": "[el-todo] Couldn't delete that ship",
    "errorDuplicate": "[el-todo] Couldn't duplicate that ship",
    "deleteConfirmTitle": "[el-todo] Delete this ship?",
    "deleteConfirmBody": "[el-todo] This will permanently delete the ship, its modules, and clear the crew roster. This cannot be undone.",
    "deleteConfirmYes": "[el-todo] Delete",
    "deleteConfirmNo": "[el-todo] Cancel",
    "duplicatedToast": "[el-todo] Duplicated \"{name}\" to a new ship.",
    "errorNameRequired": "[el-todo] Name required",
    "formNameLabel": "[el-todo] Ship name",
    "formNameHint": "[el-todo] 1-80 characters",
    "formNamePlaceholder": "[el-todo] e.g. Scarab of Kua",
    "formClassLabel": "[el-todo] Class",
    "formClassHint": "[el-todo] Hull class",
    "formModelLabel": "[el-todo] Model",
    "formModelHint": "[el-todo] Optional model name",
    "formModelPlaceholder": "[el-todo] e.g. Helebian Class III",
    "formRegistryLabel": "[el-todo] Registry",
    "formRegistryHint": "[el-todo] Optional transponder code",
    "formRegistryPlaceholder": "[el-todo] e.g. KUA-7741-M",
    "formCreateButton": "[el-todo] Create ship",
    "formCancelButton": "[el-todo] Cancel",
    "open": "[el-todo] Open",
    "duplicate": "[el-todo] Duplicate",
    "delete": "[el-todo] Delete",
    "hullLabel": "[el-todo] Hull",
    "energyLabel": "[el-todo] Energy",
    "modulesCount": "[el-todo] {n} modules",
    "crewCount": "[el-todo] {n} crew",
    "retry": "[el-todo] Try again"
  }
}
</i18n>

<template>
  <section
    class="page-ships"
    data-testid="page-ships"
  >
    <header class="page-ships__header">
      <h1 class="page-ships__title">
        {{ t('pageTitle') }}
      </h1>
      <AppButton
        v-if="!formOpen"
        variant="primary"
        size="md"
        @click="openForm"
      >
        + {{ t('newShip') }}
      </AppButton>
    </header>

    <!-- Create form card -->
    <AppCard
      v-if="formOpen"
      class="page-ships__form-card"
    >
      <form
        novalidate
        class="page-ships__form"
        @submit.prevent="onCreate"
      >
        <AppBanner
          v-if="formError"
          tone="danger"
          role="alert"
        >
          {{ formError }}
        </AppBanner>

        <AppField
          :label="t('formNameLabel')"
          :help="t('formNameHint')"
          required
        >
          <template #default="slotAttrs">
            <AppInput
              v-bind="slotAttrs"
              v-model="newName"
              type="text"
              maxlength="80"
              :placeholder="t('formNamePlaceholder')"
            />
          </template>
        </AppField>

        <AppField
          :label="t('formClassLabel')"
          :help="t('formClassHint')"
          required
        >
          <template #default="slotAttrs">
            <select
              v-bind="slotAttrs"
              v-model="newClass"
              class="page-ships__select"
            >
              <option
                v-for="cls in ALL_SHIP_CLASSES"
                :key="cls"
                :value="cls"
              >
                {{ humaniseClass(cls) }}
              </option>
            </select>
          </template>
        </AppField>

        <AppField
          :label="t('formModelLabel')"
          :help="t('formModelHint')"
        >
          <template #default="slotAttrs">
            <AppInput
              v-bind="slotAttrs"
              v-model="newModel"
              type="text"
              maxlength="120"
              :placeholder="t('formModelPlaceholder')"
            />
          </template>
        </AppField>

        <AppField
          :label="t('formRegistryLabel')"
          :help="t('formRegistryHint')"
        >
          <template #default="slotAttrs">
            <AppInput
              v-bind="slotAttrs"
              v-model="newRegistry"
              type="text"
              maxlength="60"
              :placeholder="t('formRegistryPlaceholder')"
            />
          </template>
        </AppField>

        <div class="page-ships__form-actions">
          <AppButton
            type="button"
            variant="ghost"
            size="sm"
            :disabled="creating"
            @click="closeForm"
          >
            {{ t('formCancelButton') }}
          </AppButton>
          <AppButton
            type="submit"
            variant="primary"
            size="sm"
            :loading="creating"
            :disabled="!formValid || creating"
          >
            {{ t('formCreateButton') }}
          </AppButton>
        </div>
      </form>
    </AppCard>

    <!-- Error banner -->
    <AppBanner
      v-if="errorMsg && state === 'error'"
      tone="danger"
      role="alert"
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

    <!-- Loading skeleton -->
    <div
      v-else-if="state === 'loading'"
      class="page-ships__grid"
      aria-busy="true"
    >
      <div
        v-for="n in 4"
        :key="n"
        class="page-ships__skeleton"
        aria-hidden="true"
      />
    </div>

    <!-- Empty state -->
    <div
      v-else-if="ships.length === 0"
      class="page-ships__empty"
    >
      <h2 class="page-ships__empty-heading">
        {{ t('emptyHeading') }}
      </h2>
      <p class="page-ships__empty-body">
        {{ t('emptyBody') }}
      </p>
    </div>

    <!-- Ships grid -->
    <ul
      v-else
      class="page-ships__grid"
      role="list"
    >
      <li
        v-for="ship in ships"
        :key="ship.id"
      >
        <AppCard class="page-ships__card">
          <div class="page-ships__card-head">
            <h3 class="page-ships__card-title">
              {{ ship.name }}
            </h3>
            <AppBadge
              variant="brass"
              size="sm"
            >
              {{ humaniseClass(ship.class) }}
            </AppBadge>
          </div>

          <div class="page-ships__card-stats">
            <span class="page-ships__stat">
              <span class="page-ships__stat-label">{{ t('hullLabel') }}</span>
              <span class="page-ships__stat-value">{{ ship.hull.current }}/{{ ship.hull.max }}</span>
            </span>
            <span class="page-ships__stat">
              <span class="page-ships__stat-label">{{ t('energyLabel') }}</span>
              <span class="page-ships__stat-value">{{ ship.energy.current }}/{{ ship.energy.max }}</span>
            </span>
          </div>

          <div class="page-ships__card-badges">
            <AppBadge
              variant="darkness"
              size="sm"
            >
              {{ t('modulesCount', { n: moduleCount(ship) }) }}
            </AppBadge>
            <AppBadge
              v-if="crewCount(ship) > 0"
              variant="brass"
              size="sm"
            >
              {{ t('crewCount', { n: crewCount(ship) }) }}
            </AppBadge>
          </div>

          <div class="page-ships__card-actions">
            <AppButton
              variant="primary"
              size="sm"
              @click="navigateTo(`/app/ships/${ship.id}`)"
            >
              {{ t('open') }}
            </AppButton>
            <AppButton
              variant="ghost"
              size="sm"
              @click="onDuplicate(ship)"
            >
              {{ t('duplicate') }}
            </AppButton>
            <AppButton
              variant="ghost"
              size="sm"
              @click="openDeleteConfirm(ship)"
            >
              {{ t('delete') }}
            </AppButton>
          </div>
        </AppCard>
      </li>
    </ul>

    <!-- ── Duplicate toast ─────────────────────────────────────────────────── -->
    <AppBanner
      v-if="showDuplicatedToast"
      tone="success"
      role="status"
      class="page-ships__toast"
      data-testid="duplicate-toast"
    >
      {{ t('duplicatedToast', { name: duplicatedFromName }) }}
    </AppBanner>

    <!-- ── Delete confirmation modal ─────────────────────────────────────── -->
    <AppModal
      :open="deleteConfirmOpen"
      :aria-label="t('deleteConfirmTitle')"
      size="sm"
      :close-on-backdrop="!deleting"
      :close-on-esc="!deleting"
      @update:open="(v) => { if (!v) closeDeleteConfirm(); }"
    >
      <div class="page-ships__delete-modal">
        <p class="page-ships__delete-modal-heading">
          {{ t('deleteConfirmTitle') }}
        </p>
        <p class="page-ships__delete-modal-body">
          {{ t('deleteConfirmBody') }}
        </p>
        <div class="page-ships__delete-modal-actions">
          <AppButton
            variant="ghost"
            size="md"
            :disabled="deleting"
            @click="closeDeleteConfirm"
          >
            {{ t('deleteConfirmNo') }}
          </AppButton>
          <AppButton
            variant="danger"
            size="md"
            :loading="deleting"
            @click="confirmDelete"
          >
            {{ t('deleteConfirmYes') }}
          </AppButton>
        </div>
      </div>
    </AppModal>
  </section>
</template>

<style lang="scss" scoped>
  $card-min-width: 300px;
  $skeleton-min-height: 160px;

  .page-ships {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    padding: var(--space-6);
    max-width: 1200px;
    margin: 0 auto;

    &__header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: var(--space-3);
      flex-wrap: wrap;
    }

    &__title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-md-font-size);
      letter-spacing: var(--type-display-md-letter-spacing);
      color: var(--brand-brass-light);
    }

    &__form-card {
      padding: var(--space-4);
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__select {
      width: 100%;
      padding: var(--space-2) var(--space-3);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-sm);
      color: var(--text-primary);
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      cursor: pointer;

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    &__form-actions {
      display: flex;
      justify-content: flex-end;
      gap: var(--space-2);
    }

    // ── Skeleton ───────────────────────────────────────────────────────────────

    &__skeleton {
      min-height: $skeleton-min-height;
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      opacity: var(--opacity-disabled);
      animation: ships-pulse var(--motion-duration-ceremony) ease-in-out infinite alternate;
    }

    // ── Empty state ────────────────────────────────────────────────────────────

    &__empty {
      padding: var(--space-8) var(--space-4);
      text-align: center;
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      background: color-mix(in srgb, var(--brand-brass-shadow) 15%, transparent);
    }

    &__empty-heading {
      margin: 0 0 var(--space-2);
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__empty-body {
      margin: 0;
      font-family: var(--font-body);
      color: var(--text-secondary);
      max-width: 480px;
      margin-inline: auto;
    }

    // ── Grid ──────────────────────────────────────────────────────────────────

    &__grid {
      list-style: none;
      margin: 0;
      padding: 0;
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax($card-min-width, 1fr));
      gap: var(--space-4);
    }

    // ── Card ──────────────────────────────────────────────────────────────────

    &__card {
      padding: var(--space-4);
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__card-head {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: var(--space-2);
      flex-wrap: wrap;
    }

    &__card-title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__card-stats {
      display: flex;
      gap: var(--space-4);
    }

    &__stat {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__stat-label {
      font-family: var(--font-mono);
      font-size: var(--type-body-xs-font-size);
      color: var(--text-tertiary);
      text-transform: uppercase;
      letter-spacing: 0.08em;
    }

    &__stat-value {
      font-family: var(--font-mono);
      font-size: var(--type-body-md-font-size);
      color: var(--text-primary);
    }

    &__card-badges {
      display: inline-flex;
      gap: var(--space-1);
      flex-wrap: wrap;
    }

    &__card-actions {
      margin-top: var(--space-1);
      display: flex;
      gap: var(--space-2);
    }

    // ── Duplicate toast ────────────────────────────────────────────────────────

    $toast-min-width: 320px;
    $toast-max-width: 560px;

    &__toast {
      position: fixed;
      bottom: var(--space-6);
      left: 50%;
      transform: translateX(-50%);
      z-index: var(--z-toast);
      min-width: $toast-min-width;
      max-width: $toast-max-width;
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

  @keyframes ships-pulse {
    from {
      opacity: var(--opacity-disabled);
    }

    to {
      opacity: 0.18;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .page-ships__skeleton {
      animation: none;
    }
  }
</style>
