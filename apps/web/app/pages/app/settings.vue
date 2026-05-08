<script setup lang="ts">
  import { AppAvatar, AppButton, AppCard, AppField, AppInput, AppLabel, AppSelect, AppSwitch } from '@app/ui';
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

  const currentLocale = ref<string>(locale.value);

  const localeOptions = computed<AppSelectOption[]>(() => [
    { value: 'en', label: t('localeEn') },
    { value: 'ru', label: t('localeRu') },
    { value: 'uk', label: t('localeUk') },
    { value: 'el', label: t('localeEl') },
  ]);

  // ── Theme ─────────────────────────────────────────────────────────────────

  // v1 persistence: localStorage only.
  // Gap: DESIGN §6.5.d calls for server-side persistence via PATCH /me in a
  // future release. When that lands, mirror the toggle to updateMe({ theme }).
  const THEME_KEY = 'coriolis.theme';
  const HIGH_CONTRAST_VALUE = 'high-contrast';

  const highContrast = ref(false);

  function applyTheme(active: boolean): void {
    if (active) {
      document.documentElement.setAttribute('data-theme', HIGH_CONTRAST_VALUE);
    } else {
      document.documentElement.removeAttribute('data-theme');
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
    } catch (err) {
      const problem = err as Problem;
      loadError.value = problem?.detail ?? t('errorLoad');
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
    } catch (err) {
      const problem = err as Problem;
      saveError.value = problem?.detail ?? t('errorSave');
      saveState.value = 'error';
    }
  }

  const { debouncedFn: scheduleSave, cancel: cancelSave } = useDebounceFn(
    persistDisplayName,
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
    currentLocale.value = String(value);
    await setLocale(String(value));
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
    "deleteAccountButton": "Delete account",
    "deleteAccountHelp": "Account deletion lands in a future release (T-4.2.1). Your data remains safe until that feature ships.",
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
    "deleteAccountButton": "Удалить аккаунт",
    "deleteAccountHelp": "Удаление аккаунта появится в будущем релизе (T-4.2.1). Ваши данные в безопасности до выхода этой функции.",
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
    "deleteAccountButton": "[uk-todo] Delete account",
    "deleteAccountHelp": "[uk-todo] Account deletion future release",
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
    "deleteAccountButton": "[el-todo] Delete account",
    "deleteAccountHelp": "[el-todo] Account deletion future release",
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
      <div class="page-settings__skeleton" aria-hidden="true" />
      <div class="page-settings__skeleton page-settings__skeleton--tall" aria-hidden="true" />
      <div class="page-settings__skeleton" aria-hidden="true" />
    </div>

    <!-- Error state -->
    <div
      v-else-if="loadState === 'error'"
      class="page-settings__error"
      role="alert"
    >
      <p class="page-settings__error-text">{{ loadError }}</p>
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

              <div class="page-settings__save-status" aria-live="polite" aria-atomic="true">
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
          <p class="page-settings__theme-help">{{ t('highContrastHelp') }}</p>
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
            :disabled="true"
          >
            {{ t('deleteAccountButton') }}
          </AppButton>
          <p class="page-settings__account-help">{{ t('deleteAccountHelp') }}</p>
        </div>
      </AppCard>

    </template>
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
