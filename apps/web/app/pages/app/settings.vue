<script setup lang="ts">
  import {
    AppAvatar,
    AppButton,
    AppCard,
    AppField,
    AppInput,
    AppLabel,
    AppSelect,
    AppSwitch,
  } from '@app/ui';
  import type { AppSelectOption } from '@app/ui';
  import { ref, watch, computed, onBeforeUnmount, onMounted } from 'vue';
  import { useMeApi } from '~/composables/useMeApi';
  import type { Me, Problem } from '~/composables/useMeApi';
  import { useDebounceFn } from '~/composables/useDebounceFn';

  const { t, setLocale, locale } = useI18n({ useScope: 'local' });
  const api = useMeApi();

  // ── Load state ────────────────────────────────────────────────────────────

  type LoadState = 'loading' | 'loaded' | 'error';
  const loadState = ref<LoadState>('loading');
  const loadError = ref('');
  const me = ref<Me | null>(null);

  // ── Profile editable state ────────────────────────────────────────────────

  const displayNameValue = ref('');

  type SaveState = 'idle' | 'saving' | 'saved' | 'error';
  const saveState = ref<SaveState>('idle');
  const saveError = ref('');

  // ── Locale ────────────────────────────────────────────────────────────────

  const SUPPORTED_LOCALES = ['en', 'ru', 'uk', 'el'] as const;
  type LocaleCode = (typeof SUPPORTED_LOCALES)[number];

  const currentLocale = ref<string>(locale.value);

  const localeOptions = computed<AppSelectOption[]>(() =>
    SUPPORTED_LOCALES.map((code) => ({
      value: code,
      label: t(`locale${code.charAt(0).toUpperCase()}${code.slice(1)}`),
    })),
  );

  function isLocaleCode(value: string): value is LocaleCode {
    return (SUPPORTED_LOCALES as readonly string[]).includes(value);
  }

  // ── Theme ─────────────────────────────────────────────────────────────────

  // v1 persistence: localStorage only.
  // Gap: DESIGN §6.5.d calls for server-side persistence via PATCH /me in a
  // future release. When that lands, mirror the toggle to updateMe({ theme }).
  const THEME_KEY = 'coriolis.theme';
  const HIGH_CONTRAST_VALUE = 'high-contrast';

  const highContrast = ref(false);

  function applyTheme(active: boolean): void {
    if (active) {
      document.documentElement.dataset.theme = HIGH_CONTRAST_VALUE;
    } else {
      delete document.documentElement.dataset.theme;
    }
  }

  function initTheme(): void {
    const stored = localStorage.getItem(THEME_KEY);
    highContrast.value = stored === HIGH_CONTRAST_VALUE;
    applyTheme(highContrast.value);
  }

  function toggleHighContrast(value: boolean): void {
    highContrast.value = value;
    applyTheme(value);
    if (value) {
      localStorage.setItem(THEME_KEY, HIGH_CONTRAST_VALUE);
    } else {
      localStorage.removeItem(THEME_KEY);
    }
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  async function load(): Promise<void> {
    loadState.value = 'loading';
    loadError.value = '';
    try {
      const data = await api.get();
      me.value = data;
      displayNameValue.value = data.displayName ?? '';
      loadState.value = 'loaded';
    } catch (error) {
      const problem = error as Problem;
      loadError.value = problem.detail ?? t('errorLoad');
      loadState.value = 'error';
    }
  }

  onMounted(() => {
    initTheme();
    void load();
  });

  // ── Auto-save display name ────────────────────────────────────────────────

  async function persistDisplayName(): Promise<void> {
    if (!me.value) return;
    const trimmed = displayNameValue.value.trim();
    saveState.value = 'saving';
    saveError.value = '';
    try {
      const updated = await api.update({
        displayName: trimmed || null,
      });
      me.value = updated;
      saveState.value = 'saved';
      setTimeout(() => {
        if (saveState.value === 'saved') saveState.value = 'idle';
      }, 1500);
    } catch (error) {
      const problem = error as Problem;
      saveError.value = problem.detail ?? t('errorSave');
      saveState.value = 'error';
    }
  }

  function persistDisplayNameVoid(): void {
    void persistDisplayName();
  }

  const { debouncedFn: scheduleSave, cancel: cancelSave } = useDebounceFn(
    persistDisplayNameVoid,
    500,
  );

  watch(displayNameValue, () => {
    if (loadState.value !== 'loaded') return;
    saveState.value = 'idle';
    scheduleSave();
  });

  onBeforeUnmount(() => {
    cancelSave();
  });

  // ── Locale switch ─────────────────────────────────────────────────────────

  async function onLocaleChange(value: string | number | null): Promise<void> {
    if (!value || value === locale.value) return;
    const code = String(value);
    if (!isLocaleCode(code)) return;
    currentLocale.value = code;
    await setLocale(code);
  }

  // ── Avatar initials helper ────────────────────────────────────────────────

  const avatarName = computed<string>(() => {
    if (displayNameValue.value.trim()) return displayNameValue.value.trim();
    if (me.value?.email) return me.value.email.split('@')[0] ?? '';
    return '?';
  });

  // ── Formatted date ────────────────────────────────────────────────────────

  const formattedCreatedAt = computed<string>(() => {
    const raw = me.value?.createdAt;
    if (!raw) return '';
    try {
      return new Intl.DateTimeFormat(locale.value, {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
      }).format(new Date(raw));
    } catch {
      return raw;
    }
  });

  // ── Delete account ────────────────────────────────────────────────────────

  const deleteDialogRef = ref<HTMLDialogElement | null>(null);
  const deleteConfirmInput = ref('');
  const deleteInProgress = ref(false);
  const deleteError = ref('');

  const deleteConfirmMatches = computed<boolean>(() => {
    return deleteConfirmInput.value === t('deleteAccountConfirmPhrase');
  });

  function openDeleteDialog(): void {
    deleteConfirmInput.value = '';
    deleteError.value = '';
    deleteDialogRef.value?.showModal();
  }

  function closeDeleteDialog(): void {
    deleteConfirmInput.value = '';
    deleteError.value = '';
    deleteDialogRef.value?.close();
  }

  async function confirmDeleteAccount(): Promise<void> {
    if (!deleteConfirmMatches.value) return;
    deleteInProgress.value = true;
    deleteError.value = '';
    try {
      await api.deleteMe();
      localStorage.removeItem(THEME_KEY);
      await navigateTo('/');
    } catch (error) {
      const problem = error as Problem;
      deleteError.value = problem.detail ?? t('deleteAccountError');
      deleteInProgress.value = false;
    }
  }
</script>

<i18n lang="json">
{
  "en": {
    "sectionProfile": "Profile",
    "displayNameLabel": "Display name",
    "displayNamePlaceholder": "Your name across the Third Horizon",
    "emailLabel": "Email",
    "memberSinceLabel": "Member since",
    "statusSaving": "Saving…",
    "statusSaved": "Saved",
    "statusError": "Save failed",
    "errorLoad": "Failed to load your profile.",
    "errorSave": "Could not save your display name.",
    "sectionLocale": "Language",
    "localeLabel": "Interface language",
    "localeEn": "English",
    "localeRu": "Русский",
    "localeUk": "Українська [uk-todo]",
    "localeEl": "Ελληνικά [el-todo]",
    "sectionTheme": "Appearance",
    "highContrastLabel": "High contrast",
    "highContrastHelp": "Increases contrast for improved readability. Persists to this device only — server-side persistence arrives in a future release (T-6.5.d).",
    "sectionAccount": "Account",
    "deleteAccountButton": "Delete account…",
    "deleteAccountHelp": "Your sessions revoke immediately. Characters, ships, and share links stay accessible for 30 days, then they're cascade-deleted. There's no undo.",
    "deleteAccountTitle": "Delete account",
    "deleteAccountModalTitle": "This is the end of the line",
    "deleteAccountWarning": "Your sessions revoke immediately. Characters, ships, and share links stay accessible for 30 days, then they're cascade-deleted. There's no undo.",
    "deleteAccountConfirmPrompt": "Type DELETE MY ACCOUNT to confirm:",
    "deleteAccountConfirmPhrase": "DELETE MY ACCOUNT",
    "deleteAccountCancel": "Cancel",
    "deleteAccountConfirm": "Delete forever",
    "deleteAccountInProgress": "Deleting…",
    "deleteAccountError": "Could not delete the account. Please try again or contact support.",
    "loading": "Loading your profile…"
  },
  "ru": {
    "sectionProfile": "Профиль",
    "displayNameLabel": "Отображаемое имя",
    "displayNamePlaceholder": "Ваше имя на Третьем Горизонте",
    "emailLabel": "Электронная почта",
    "memberSinceLabel": "Участник с",
    "statusSaving": "Сохранение…",
    "statusSaved": "Сохранено",
    "statusError": "Ошибка сохранения",
    "errorLoad": "Не удалось загрузить профиль.",
    "errorSave": "Не удалось сохранить отображаемое имя.",
    "sectionLocale": "Язык",
    "localeLabel": "Язык интерфейса",
    "localeEn": "English",
    "localeRu": "Русский",
    "localeUk": "Українська [uk-todo]",
    "localeEl": "Ελληνικά [el-todo]",
    "sectionTheme": "Оформление",
    "highContrastLabel": "Высокий контраст",
    "highContrastHelp": "Повышает контрастность для удобства чтения. Сохраняется только на этом устройстве — серверное сохранение появится в будущем релизе (T-6.5.d).",
    "sectionAccount": "Аккаунт",
    "deleteAccountButton": "Удалить аккаунт…",
    "deleteAccountHelp": "Сессии отзываются немедленно. Персонажи, корабли и ссылки на шаринг остаются доступными 30 дней, после чего удаляются каскадно. Это необратимо.",
    "deleteAccountTitle": "Удалить аккаунт",
    "deleteAccountModalTitle": "Конец пути",
    "deleteAccountWarning": "Сессии отзываются немедленно. Персонажи, корабли и ссылки на шаринг остаются доступными 30 дней, после чего удаляются каскадно. Это необратимо.",
    "deleteAccountConfirmPrompt": "Введите УДАЛИТЬ МОЙ АККАУНТ для подтверждения:",
    "deleteAccountConfirmPhrase": "УДАЛИТЬ МОЙ АККАУНТ",
    "deleteAccountCancel": "Отмена",
    "deleteAccountConfirm": "Удалить навсегда",
    "deleteAccountInProgress": "Удаление…",
    "deleteAccountError": "Не удалось удалить аккаунт. Попробуйте ещё раз или обратитесь в поддержку.",
    "loading": "Загрузка профиля…"
  },
  "uk": {
    "sectionProfile": "[uk-todo] Profile",
    "displayNameLabel": "[uk-todo] Display name",
    "displayNamePlaceholder": "[uk-todo] Your name",
    "emailLabel": "[uk-todo] Email",
    "memberSinceLabel": "[uk-todo] Member since",
    "statusSaving": "[uk-todo] Saving",
    "statusSaved": "[uk-todo] Saved",
    "statusError": "[uk-todo] Save failed",
    "errorLoad": "[uk-todo] Failed to load profile",
    "errorSave": "[uk-todo] Could not save display name",
    "sectionLocale": "[uk-todo] Language",
    "localeLabel": "[uk-todo] Interface language",
    "localeEn": "English",
    "localeRu": "Русский",
    "localeUk": "Українська [uk-todo]",
    "localeEl": "Ελληνικά [el-todo]",
    "sectionTheme": "[uk-todo] Appearance",
    "highContrastLabel": "[uk-todo] High contrast",
    "highContrastHelp": "[uk-todo] High contrast help text",
    "sectionAccount": "[uk-todo] Account",
    "deleteAccountButton": "[uk-todo] Delete account…",
    "deleteAccountHelp": "[uk-todo] Sessions revoke immediately. Data kept 30 days.",
    "deleteAccountTitle": "[uk-todo] Delete account",
    "deleteAccountModalTitle": "[uk-todo] This is the end of the line",
    "deleteAccountWarning": "[uk-todo] Sessions revoke immediately. Characters, ships, and share links stay accessible for 30 days, then they're cascade-deleted. There's no undo.",
    "deleteAccountConfirmPrompt": "[uk-todo] Type DELETE MY ACCOUNT to confirm:",
    "deleteAccountConfirmPhrase": "DELETE MY ACCOUNT",
    "deleteAccountCancel": "[uk-todo] Cancel",
    "deleteAccountConfirm": "[uk-todo] Delete forever",
    "deleteAccountInProgress": "[uk-todo] Deleting…",
    "deleteAccountError": "[uk-todo] Could not delete the account.",
    "loading": "[uk-todo] Loading profile"
  },
  "el": {
    "sectionProfile": "[el-todo] Profile",
    "displayNameLabel": "[el-todo] Display name",
    "displayNamePlaceholder": "[el-todo] Your name",
    "emailLabel": "[el-todo] Email",
    "memberSinceLabel": "[el-todo] Member since",
    "statusSaving": "[el-todo] Saving",
    "statusSaved": "[el-todo] Saved",
    "statusError": "[el-todo] Save failed",
    "errorLoad": "[el-todo] Failed to load profile",
    "errorSave": "[el-todo] Could not save display name",
    "sectionLocale": "[el-todo] Language",
    "localeLabel": "[el-todo] Interface language",
    "localeEn": "English",
    "localeRu": "Русский",
    "localeUk": "Українська [uk-todo]",
    "localeEl": "Ελληνικά [el-todo]",
    "sectionTheme": "[el-todo] Appearance",
    "highContrastLabel": "[el-todo] High contrast",
    "highContrastHelp": "[el-todo] High contrast help text",
    "sectionAccount": "[el-todo] Account",
    "deleteAccountButton": "[el-todo] Delete account…",
    "deleteAccountHelp": "[el-todo] Sessions revoke immediately. Data kept 30 days.",
    "deleteAccountTitle": "[el-todo] Delete account",
    "deleteAccountModalTitle": "[el-todo] This is the end of the line",
    "deleteAccountWarning": "[el-todo] Sessions revoke immediately. Characters, ships, and share links stay accessible for 30 days, then they're cascade-deleted. There's no undo.",
    "deleteAccountConfirmPrompt": "[el-todo] Type DELETE MY ACCOUNT to confirm:",
    "deleteAccountConfirmPhrase": "DELETE MY ACCOUNT",
    "deleteAccountCancel": "[el-todo] Cancel",
    "deleteAccountConfirm": "[el-todo] Delete forever",
    "deleteAccountInProgress": "[el-todo] Deleting…",
    "deleteAccountError": "[el-todo] Could not delete the account.",
    "loading": "[el-todo] Loading profile"
  }
}
</i18n>

<template>
  <section class="page-settings">
    <!-- Loading skeleton -->
    <div
      v-if="loadState === 'loading'"
      class="page-settings__loading"
      aria-busy="true"
      :aria-label="t('loading')"
    >
      <div
        class="page-settings__skeleton"
        aria-hidden="true"
      />
      <div
        class="page-settings__skeleton page-settings__skeleton--tall"
        aria-hidden="true"
      />
      <div
        class="page-settings__skeleton"
        aria-hidden="true"
      />
    </div>

    <!-- Error state -->
    <div
      v-else-if="loadState === 'error'"
      class="page-settings__error"
      role="alert"
    >
      <p class="page-settings__error-text">
        {{ loadError }}
      </p>
    </div>

    <!-- Loaded -->
    <template v-else-if="loadState === 'loaded' && me">
      <!-- Section: Profile -->
      <AppCard>
        <template #header>
          <AppLabel
            tone="eyebrow"
            :text="t('sectionProfile')"
          />
        </template>

        <div class="page-settings__profile">
          <!-- Avatar column -->
          <div class="page-settings__profile-avatar">
            <AppAvatar
              :name="avatarName"
              size="lg"
              tone="brass"
            />
          </div>

          <!-- Fields column -->
          <div class="page-settings__profile-fields">
            <!-- Editable: displayName with auto-save indicator -->
            <div class="page-settings__display-name-row">
              <AppField
                :label="t('displayNameLabel')"
                size="md"
              >
                <template #default="slotAttrs">
                  <AppInput
                    v-bind="slotAttrs"
                    v-model="displayNameValue"
                    size="md"
                    :placeholder="t('displayNamePlaceholder')"
                    autocomplete="off"
                  />
                </template>
              </AppField>

              <div
                class="page-settings__save-status"
                aria-live="polite"
                aria-atomic="true"
              >
                <span
                  v-if="saveState === 'saving'"
                  class="page-settings__save-label page-settings__save-label--saving"
                >{{ t('statusSaving') }}</span>
                <span
                  v-else-if="saveState === 'saved'"
                  class="page-settings__save-label page-settings__save-label--saved"
                >{{ t('statusSaved') }}</span>
                <span
                  v-else-if="saveState === 'error'"
                  class="page-settings__save-label page-settings__save-label--error"
                  role="alert"
                >{{ t('statusError') }}</span>
              </div>
            </div>

            <!-- Save error detail -->
            <p
              v-if="saveError && saveState === 'error'"
              class="page-settings__save-error"
              role="alert"
            >
              {{ saveError }}
            </p>

            <!-- Read-only: email -->
            <div class="page-settings__read-row">
              <AppLabel
                tone="default"
                :text="t('emailLabel')"
              />
              <span class="page-settings__read-value">{{ me.email }}</span>
            </div>

            <!-- Read-only: member since -->
            <div class="page-settings__read-row">
              <AppLabel
                tone="default"
                :text="t('memberSinceLabel')"
              />
              <span class="page-settings__read-value">{{ formattedCreatedAt }}</span>
            </div>
          </div>
        </div>
      </AppCard>

      <!-- Section: Locale -->
      <AppCard>
        <template #header>
          <AppLabel
            tone="eyebrow"
            :text="t('sectionLocale')"
          />
        </template>

        <div class="page-settings__locale">
          <AppField
            :label="t('localeLabel')"
            size="md"
          >
            <template #default="slotAttrs">
              <AppSelect
                :select-id="slotAttrs.id"
                :model-value="currentLocale"
                :options="localeOptions"
                size="md"
                @update:model-value="onLocaleChange"
              />
            </template>
          </AppField>
        </div>
      </AppCard>

      <!-- Section: Theme -->
      <AppCard>
        <template #header>
          <AppLabel
            tone="eyebrow"
            :text="t('sectionTheme')"
          />
        </template>

        <div class="page-settings__theme">
          <AppSwitch
            :model-value="highContrast"
            :label="t('highContrastLabel')"
            size="md"
            @update:model-value="toggleHighContrast"
          />
          <p class="page-settings__theme-help">
            {{ t('highContrastHelp') }}
          </p>
        </div>
      </AppCard>

      <!-- Section: Account (danger zone) -->
      <AppCard class="page-settings__account-card">
        <template #header>
          <AppLabel
            tone="eyebrow"
            :text="t('sectionAccount')"
          />
        </template>

        <div class="page-settings__account">
          <AppButton
            variant="danger"
            size="md"
            @click="openDeleteDialog"
          >
            {{ t('deleteAccountButton') }}
          </AppButton>
          <p class="page-settings__account-help">
            {{ t('deleteAccountHelp') }}
          </p>
        </div>
      </AppCard>
    </template>

    <!-- Delete account confirmation dialog -->
    <dialog
      ref="deleteDialogRef"
      class="page-settings__dialog"
      :aria-label="t('deleteAccountModalTitle')"
      @close="closeDeleteDialog"
    >
      <div class="page-settings__dialog-inner">
        <AppLabel
          tone="eyebrow"
          :text="t('deleteAccountTitle')"
        />
        <p class="page-settings__dialog-heading">
          {{ t('deleteAccountModalTitle') }}
        </p>
        <p class="page-settings__dialog-warning">
          {{ t('deleteAccountWarning') }}
        </p>

        <div class="page-settings__dialog-confirm-field">
          <label
            class="page-settings__dialog-confirm-label"
            for="delete-confirm-input"
          >{{
            t('deleteAccountConfirmPrompt')
          }}</label>
          <AppInput
            id="delete-confirm-input"
            v-model="deleteConfirmInput"
            size="md"
            autocomplete="off"
            autocorrect="off"
            autocapitalize="off"
            spellcheck="false"
            autofocus
            :disabled="deleteInProgress"
            :placeholder="t('deleteAccountConfirmPhrase')"
          />
        </div>

        <p
          v-if="deleteError"
          class="page-settings__dialog-error"
          role="alert"
        >
          {{ deleteError }}
        </p>

        <div class="page-settings__dialog-actions">
          <AppButton
            variant="ghost"
            size="md"
            :disabled="deleteInProgress"
            @click="closeDeleteDialog"
          >
            {{ t('deleteAccountCancel') }}
          </AppButton>
          <AppButton
            variant="danger"
            size="md"
            :disabled="!deleteConfirmMatches || deleteInProgress"
            :loading="deleteInProgress"
            @click="confirmDeleteAccount"
          >
            {{ deleteInProgress ? t('deleteAccountInProgress') : t('deleteAccountConfirm') }}
          </AppButton>
        </div>
      </div>
    </dialog>
  </section>
</template>

<style lang="scss" scoped>
  // Page max-width — layout cap, not a spacing token.
  $page-max-width: 720px;
  // Skeleton dimensions — layout constants, not part of the spacing scale.
  $skeleton-height: 120px;
  $skeleton-height-tall: 180px;
  // Stagger delay for skeleton shimmer — intentionally a fixed offset.
  $skeleton-stagger: 150ms;
  $skeleton-stagger-2: 300ms;
  // Dialog max-width — layout cap, not a spacing token.
  $dialog-max-width: 480px;

  .page-settings {
    display: flex;
    flex-direction: column;
    gap: var(--space-6);
    max-width: $page-max-width;

    // ── Loading ────────────────────────────────────────────────────────────────

    &__loading {
      display: flex;
      flex-direction: column;
      gap: var(--space-6);
    }

    &__skeleton {
      height: $skeleton-height;
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      opacity: var(--opacity-disabled);
      animation: settings-pulse var(--motion-duration-ceremony) ease-in-out infinite alternate;

      &--tall {
        height: $skeleton-height-tall;
        animation-delay: $skeleton-stagger;
      }

      &:last-child {
        animation-delay: $skeleton-stagger-2;
      }
    }

    // ── Error ──────────────────────────────────────────────────────────────────

    &__error {
      padding: var(--space-6) 0;
    }

    &__error-text {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--state-crimson-bright);
    }

    // ── Profile section ────────────────────────────────────────────────────────

    &__profile {
      display: flex;
      align-items: flex-start;
      gap: var(--space-6);
    }

    &__profile-avatar {
      flex-shrink: 0;
    }

    &__profile-fields {
      flex: 1;
      min-width: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
    }

    &__display-name-row {
      display: flex;
      align-items: flex-end;
      gap: var(--space-4);
    }

    &__save-status {
      flex-shrink: 0;
      padding-bottom: var(--space-1);
    }

    &__save-label {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      white-space: nowrap;

      &--saving {
        color: var(--text-secondary);
      }

      &--saved {
        color: var(--state-success);
      }

      &--error {
        color: var(--state-crimson-bright);
      }
    }

    &__save-error {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--state-crimson-bright);
    }

    &__read-row {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__read-value {
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
    }

    // ── Locale section ─────────────────────────────────────────────────────────

    &__locale {
      max-width: $page-max-width;
    }

    // ── Theme section ──────────────────────────────────────────────────────────

    &__theme {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__theme-help {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    // ── Account section (danger zone) ──────────────────────────────────────────

    &__account-card {
      border-color: var(--brand-brass-deep);
    }

    &__account {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__account-help {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    // ── Delete account dialog ──────────────────────────────────────────────────

    &__dialog {
      max-width: $dialog-max-width;
      width: 100%;
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-lg);
      background-color: var(--surface-night);
      color: var(--text-primary);
      padding: 0;

      &::backdrop {
        background-color: color-mix(in srgb, var(--surface-void) 80%, transparent);
      }
    }

    &__dialog-inner {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
      padding: var(--space-6);
    }

    &__dialog-heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      color: var(--brand-brass-light);
    }

    &__dialog-warning {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
      line-height: var(--type-body-md-line-height);
    }

    &__dialog-confirm-field {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__dialog-confirm-label {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
    }

    &__dialog-error {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--state-crimson-bright);
    }

    &__dialog-actions {
      display: flex;
      justify-content: flex-end;
      gap: var(--space-3);
      margin-top: var(--space-2);
    }
  }

  @keyframes settings-pulse {
    from {
      opacity: var(--opacity-disabled);
    }

    to {
      opacity: 0.18;
    }
  }
</style>
