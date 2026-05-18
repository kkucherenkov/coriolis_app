<script setup lang="ts">
  import { computed, nextTick, ref, watch } from 'vue';

  import AppPopover from '../AppPopover/AppPopover.vue';

  export interface Locale {
    /** ISO code matching nuxt.config.ts i18n.locales[].code (en, ru, uk, el). */
    code: string;
    /** Human-readable native name (English / Русский / Українська / Ελληνικά). */
    name: string;
  }

  export interface MenuLabels {
    triggerAriaLabel: string;
    languageLabel: string;
    settingsLabel: string;
    signOutLabel: string;
  }

  export interface Props {
    /** Display name shown next to the avatar. */
    displayName: string;
    /** Optional avatar URL. When absent, render initials from displayName. */
    avatarUrl?: string | null;
    /** Available locales — usually pulled from useI18n().locales. */
    locales: readonly Locale[];
    /** Currently selected locale code. */
    currentLocale: string;
    /** Translated labels. */
    labels: MenuLabels;
    /** Whether the menu is open (v-model:open compatible). */
    open?: boolean;
  }

  const props = withDefaults(defineProps<Props>(), {
    avatarUrl: null,
    open: false,
  });

  const emit = defineEmits<{
    'update:open': [value: boolean];
    'language-change': [code: string];
    'settings-click': [];
    'sign-out-click': [];
  }>();

  // Stable ID for aria-controls relationship.
  const menuId = `app-user-menu-panel-${Math.random().toString(36).slice(2, 8)}`;

  const imageError = ref(false);

  const showImage = computed(() => Boolean(props.avatarUrl) && !imageError.value);

  /**
   * Compute initials from displayName:
   * - Take the first grapheme cluster of each whitespace-separated word, up to 2 chars.
   * - Uppercase. Fallback to '?' when name is empty / whitespace-only.
   * Uses Intl.Segmenter so that multi-codepoint characters (emoji, complex scripts) are
   * treated as a single unit rather than being split at a code-unit boundary.
   */
  const initials = computed(() => {
    const trimmed = props.displayName.trim();
    if (!trimmed) return '?';
    const segmenter = new Intl.Segmenter(undefined, { granularity: 'grapheme' });
    const words = trimmed.split(/\s+/);
    return words
      .slice(0, 2)
      .map((w) => {
        const [first] = segmenter.segment(w);
        return first?.segment ?? '';
      })
      .join('')
      .toUpperCase();
  });

  function handleImageError(): void {
    imageError.value = true;
  }

  function onTriggerClick(): void {
    emit('update:open', !props.open);
  }

  function close(): void {
    emit('update:open', false);
  }

  function onLocaleClick(code: string): void {
    // Spec choice: clicking the current locale still closes the menu,
    // but does NOT emit language-change (no-op locale switch).
    if (code !== props.currentLocale) {
      emit('language-change', code);
    }
    close();
  }

  function onSettingsClick(): void {
    emit('settings-click');
    close();
  }

  function onSignOutClick(): void {
    emit('sign-out-click');
    close();
  }

  // ── Keyboard navigation inside the menu panel ───────────────────────────────

  const menuRef = ref<HTMLElement | null>(null);

  function getMenuItems(): HTMLElement[] {
    if (!menuRef.value) return [];
    return [
      ...menuRef.value.querySelectorAll<HTMLElement>('[role="menuitem"], [role="menuitemradio"]'),
    ];
  }

  function onMenuKeydown(event: KeyboardEvent): void {
    const items = getMenuItems();
    if (items.length === 0) return;

    const current = document.activeElement as HTMLElement | null;
    const idx = current ? items.indexOf(current) : -1;

    switch (event.key) {
      case 'ArrowDown': {
        event.preventDefault();
        const next = idx < items.length - 1 ? idx + 1 : 0;
        items[next]?.focus();
        break;
      }
      case 'ArrowUp': {
        event.preventDefault();
        const prev = idx > 0 ? idx - 1 : items.length - 1;
        items[prev]?.focus();
        break;
      }
      case 'Home': {
        event.preventDefault();
        items[0]?.focus();
        break;
      }
      case 'End': {
        event.preventDefault();
        items.at(-1)?.focus();
        break;
      }
      default: {
        break;
      }
    }
  }

  // Move focus to the first menuitem when the panel opens.
  watch(
    () => props.open,
    async (isOpen) => {
      if (isOpen) {
        await nextTick();
        const items = getMenuItems();
        items[0]?.focus();
      }
    },
  );
</script>

<template>
  <div class="app-user-menu">
    <!--
      AppPopover renders the panel as role="dialog" aria-modal="true" — axe's
      `aria-dialog-name` rule requires that dialog to have an accessible name,
      so reuse the trigger label (it already describes the popover surface).
    -->
    <AppPopover
      :open="open"
      placement="bottom"
      :aria-label="labels.triggerAriaLabel"
      @update:open="emit('update:open', $event)"
    >
      <!-- Trigger: avatar + name button -->
      <template #trigger>
        <button
          type="button"
          class="app-user-menu__trigger"
          :aria-label="labels.triggerAriaLabel"
          aria-haspopup="menu"
          :aria-expanded="open"
          :aria-controls="menuId"
          @click="onTriggerClick"
        >
          <!-- Avatar or initials -->
          <span class="app-user-menu__avatar" aria-hidden="true">
            <img
              v-if="showImage"
              class="app-user-menu__avatar-img"
              :src="avatarUrl!"
              :alt="displayName"
              loading="lazy"
              decoding="async"
              @error="handleImageError"
            />
            <span v-else class="app-user-menu__avatar-initials">{{ initials }}</span>
          </span>

          <!-- Display name -->
          <span class="app-user-menu__name">{{ displayName }}</span>

          <!-- Chevron indicator -->
          <span class="app-user-menu__chevron" aria-hidden="true">&#8964;</span>
        </button>
      </template>

      <!-- Menu panel -->
      <div
        :id="menuId"
        ref="menuRef"
        role="menu"
        aria-orientation="vertical"
        class="app-user-menu__panel"
        @keydown="onMenuKeydown"
      >
        <!-- Language section -->
        <div role="group" :aria-label="labels.languageLabel" class="app-user-menu__section">
          <div class="app-user-menu__section-label" aria-hidden="true">
            {{ labels.languageLabel }}
          </div>

          <button
            v-for="locale in locales"
            :key="locale.code"
            type="button"
            role="menuitemradio"
            :aria-checked="locale.code === currentLocale"
            class="app-user-menu__item app-user-menu__item--radio"
            :class="{ 'app-user-menu__item--checked': locale.code === currentLocale }"
            @click="onLocaleClick(locale.code)"
          >
            <span class="app-user-menu__radio-indicator" aria-hidden="true">
              {{ locale.code === currentLocale ? '●' : '○' }}
            </span>
            {{ locale.name }}
          </button>
        </div>

        <!-- Divider -->
        <div role="separator" class="app-user-menu__divider" />

        <!-- Settings -->
        <button type="button" role="menuitem" class="app-user-menu__item" @click="onSettingsClick">
          {{ labels.settingsLabel }}
        </button>

        <!-- Sign out — destructive action -->
        <button
          type="button"
          role="menuitem"
          class="app-user-menu__item app-user-menu__item--danger"
          @click="onSignOutClick"
        >
          {{ labels.signOutLabel }}
        </button>
      </div>
    </AppPopover>
  </div>
</template>

<style lang="scss" scoped>
  // Avatar diameter in the trigger
  $trigger-avatar-size: 32px;
  $trigger-avatar-initials-ratio: 0.38;

  // Menu panel min width — sized for the longest locale name + radio indicator.
  $panel-min-width: 200px;

  // Section label — caption typography below body-sm (no token for 10px).
  $section-label-font-size: 10px;

  .app-user-menu {
    display: inline-flex;
    position: relative;

    // ── Trigger button ──────────────────────────────────────────────────────

    &__trigger {
      display: inline-flex;
      align-items: center;
      gap: var(--space-2);
      max-width: 100%;
      min-width: 0;
      padding: var(--space-1) var(--space-2);
      background: transparent;
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
      color: var(--text-primary);
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      cursor: pointer;
      transition:
        background-color var(--motion-duration-fast) var(--motion-ease-standard),
        border-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        background-color: color-mix(in srgb, var(--brand-brass) 8%, transparent);
        border-color: var(--brand-brass);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    // ── Avatar ──────────────────────────────────────────────────────────────

    &__avatar {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      width: $trigger-avatar-size;
      height: $trigger-avatar-size;
      border-radius: 50%;
      overflow: hidden;
      background: var(--brand-brass-shadow);
      border: 1px solid var(--brand-brass-deep);
    }

    &__avatar-img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }

    &__avatar-initials {
      font-family: var(--type-display-md-font-family);
      font-size: calc(#{$trigger-avatar-size} * #{$trigger-avatar-initials-ratio});
      color: var(--brand-brass-light);
      line-height: 1;
      user-select: none;
    }

    // ── Name label ──────────────────────────────────────────────────────────

    &__name {
      flex: 0 1 auto;
      min-width: 0;
      max-width: 14rem;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;

      // On phones the email / display-name is the worst overflow offender —
      // clamp it so the trigger never widens past about a third of the
      // viewport.
      @media (max-width: 768px) {
        max-width: 8rem;
      }

      @media (max-width: 420px) {
        max-width: 5rem;
      }
    }

    // ── Chevron indicator ───────────────────────────────────────────────────

    &__chevron {
      font-size: 1.1em;
      color: var(--brand-brass-light);
      line-height: 1;
    }

    // ── Menu panel ──────────────────────────────────────────────────────────

    &__panel {
      display: flex;
      flex-direction: column;
      min-width: $panel-min-width;
      padding: var(--space-2) 0;
    }

    // ── Section ─────────────────────────────────────────────────────────────

    &__section {
      display: flex;
      flex-direction: column;
    }

    &__section-label {
      padding: var(--space-1) var(--space-3);
      font-family: var(--type-display-sm-font-family);
      font-size: $section-label-font-size;
      font-weight: var(--type-label-sm-font-weight, 600);
      letter-spacing: 0.1em;
      text-transform: uppercase;
      color: var(--brand-brass-light);
      user-select: none;
    }

    // ── Divider ─────────────────────────────────────────────────────────────

    &__divider {
      height: 1px;
      margin: var(--space-1) var(--space-3);
      background: var(--brand-brass-deep);
    }

    // ── Menu items ───────────────────────────────────────────────────────────

    &__item {
      display: flex;
      align-items: center;
      gap: var(--space-2);
      width: 100%;
      padding: var(--space-2) var(--space-3);
      background: transparent;
      border: none;
      color: var(--text-primary);
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      text-align: left;
      cursor: pointer;
      transition:
        background-color var(--motion-duration-fast) var(--motion-ease-standard),
        color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover,
      &:focus-visible {
        background-color: color-mix(in srgb, var(--brand-brass) 10%, transparent);
        color: var(--brand-brass-light);
        outline: none;
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: -2px;
      }

      // Checked state for radio items
      &--checked {
        color: var(--brand-brass-light);
      }

      // Destructive / sign-out styling
      &--danger {
        color: var(--state-crimson-bright);

        &:hover,
        &:focus-visible {
          background-color: color-mix(in srgb, var(--state-crimson) 12%, transparent);
          color: var(--state-crimson-bright);
        }
      }
    }

    // ── Radio indicator dot ──────────────────────────────────────────────────

    &__radio-indicator {
      display: inline-flex;
      width: 1em;
      flex-shrink: 0;
      font-size: 0.65em;
      color: var(--brand-brass);
    }
  }
</style>
