<script setup lang="ts">
  import { ref, useId } from 'vue';

  import AppMobileDrawer from '../AppMobileDrawer/AppMobileDrawer.vue';
  import type { DrawerLabels } from '../AppMobileDrawer/AppMobileDrawer.vue';

  export interface NavItem {
    /**
     * Stable key used for active-link comparison. Matches the page-side
     * `useRoute().path` prefix that should highlight this link.
     */
    key: string;
    /** Where the link points (e.g. '/app/characters'). */
    href: string;
    /** Translated label shown in the header. */
    label: string;
    /** Optional Iconify slug. When absent, label-only. */
    icon?: string;
  }

  export interface BrandLabels {
    /** Rendered brand name text (e.g. "Coriolis · Companion"). */
    brandName: string;
    /** Aria-label for the brand link (e.g. "Go to dashboard"). */
    brandHomeAriaLabel: string;
    /** Hidden visually, surfaced to screen readers as the nav landmark name. */
    navAriaLabel: string;
  }

  export interface Props {
    /** Translated brand strings. */
    brand: BrandLabels;
    /** Nav items in display order. */
    navItems: readonly NavItem[];
    /** Currently active nav key — matches one of navItems[i].key. */
    activeKey?: string;
    /** Brand link target — usually '/app'. */
    brandHref?: string;
    /**
     * When provided, renders a hamburger button at the mobile breakpoint and
     * mounts an AppMobileDrawer with these translated labels. The drawer's
     * content is filled via the `mobile-drawer-content` slot.
     */
    mobileDrawerLabels?: DrawerLabels;
  }

  withDefaults(defineProps<Props>(), {
    activeKey: undefined,
    brandHref: '/app',
    mobileDrawerLabels: undefined,
  });

  /**
   * Slots:
   * - `user-menu`            — Right-side user account widget (e.g. <UserMenu>).
   * - `mobile-drawer-content` — Content rendered inside the mobile drawer
   *                             (nav links, user menu copy, etc.). Only active
   *                             when `mobileDrawerLabels` is provided.
   */

  // Links the hamburger button to the drawer via aria-controls.
  // useId() is Vue 3.5+: SSR-safe + stable across hydration (Math.random would mismatch).
  const drawerId = `app-header-drawer-${useId()}`;

  const drawerOpen = ref(false);
</script>

<template>
  <header class="app-header">
    <!-- Hamburger — mobile only, rendered only when mobileDrawerLabels is given -->
    <button
      v-if="mobileDrawerLabels"
      class="app-header__hamburger"
      type="button"
      :aria-label="mobileDrawerLabels.ariaLabel"
      :aria-controls="drawerId"
      :aria-expanded="drawerOpen"
      @click="drawerOpen = true"
    >
      <!-- Hamburger SVG icon -->
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="22"
        height="22"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        aria-hidden="true"
      >
        <line x1="3" y1="6" x2="21" y2="6" />
        <line x1="3" y1="12" x2="21" y2="12" />
        <line x1="3" y1="18" x2="21" y2="18" />
      </svg>
    </button>

    <!-- Brand / logo -->
    <a class="app-header__brand" :href="brandHref" :aria-label="brand.brandHomeAriaLabel">
      <span class="app-header__brand-name">{{ brand.brandName }}</span>
    </a>

    <!-- Centre navigation — desktop only (hidden on mobile via CSS) -->
    <nav class="app-header__nav" :aria-label="brand.navAriaLabel">
      <a
        v-for="item in navItems"
        :key="item.key"
        class="app-header__nav-link"
        :class="{ 'app-header__nav-link--active': item.key === activeKey }"
        :href="item.href"
        :aria-current="item.key === activeKey ? 'page' : undefined"
      >
        <span v-if="item.icon" class="app-header__nav-icon" aria-hidden="true">{{
          item.icon
        }}</span>
        {{ item.label }}
      </a>
    </nav>

    <!-- Right side: user-menu slot -->
    <div class="app-header__actions">
      <slot name="user-menu" />
    </div>
  </header>

  <!-- Mobile drawer — mounted outside the header flow via Teleport (inside AppMobileDrawer) -->
  <AppMobileDrawer
    v-if="mobileDrawerLabels"
    v-model:open="drawerOpen"
    :labels="mobileDrawerLabels"
    :panel-id="drawerId"
  >
    <slot name="mobile-drawer-content" />
  </AppMobileDrawer>
</template>

<style lang="scss" scoped>
  .app-header {
    position: sticky;
    top: 0;
    z-index: var(--z-sticky);
    display: flex;
    align-items: center;
    gap: var(--space-4);
    width: 100%;
    max-width: 100%;
    padding: var(--space-5) var(--space-7);
    background: var(--surface-night);
    border-bottom: 1px solid var(--brand-brass-shadow);

    // On phones the header has 1) hamburger 2) brand wordmark 3) user menu
    // with a potentially long email — the desktop gap+padding pushes the
    // user menu off-screen. Shrink both, and let the nav slot collapse.
    @media (max-width: 768px) {
      gap: var(--space-2);
      padding: var(--space-3) var(--space-3);
    }

    // ── Hamburger ────────────────────────────────────────────────────────────

    &__hamburger {
      display: none; // visible only at the mobile breakpoint

      @media (max-width: 768px) {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: var(--space-8);
        height: var(--space-8);
        padding: var(--space-1);
        flex-shrink: 0;
        background: transparent;
        border: 1px solid var(--brand-brass-deep);
        border-radius: var(--radius-md);
        color: var(--text-secondary);
        cursor: pointer;
        transition:
          color var(--motion-duration-fast) var(--motion-ease-standard),
          background-color var(--motion-duration-fast) var(--motion-ease-standard);

        &:hover {
          color: var(--brand-brass-light);
          background-color: color-mix(in srgb, var(--brand-brass) 8%, transparent);
        }

        &:focus-visible {
          outline: 2px solid var(--brand-brass);
          outline-offset: 2px;
        }
      }
    }

    // ── Brand link ──────────────────────────────────────────────────────────

    &__brand {
      display: inline-flex;
      align-items: center;
      gap: var(--space-2);
      flex-shrink: 0;
      text-decoration: none;
      color: var(--brand-brass-light);
      font-family: var(--type-display-md-font-family);
      font-size: var(--type-display-sm-font-size);
      font-weight: var(--fw-regular);
      letter-spacing: 0.03em;
      transition: opacity var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        opacity: 0.85;
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 3px;
        border-radius: var(--radius-sm);
      }
    }

    &__brand-name {
      white-space: nowrap;

      // On phones the brand wordmark is the largest fixed-width text in the
      // header — let it ellipsize so the user menu always has room.
      @media (max-width: 768px) {
        max-width: 11rem;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      @media (max-width: 420px) {
        max-width: 8rem;
      }
    }

    // ── Centre navigation ───────────────────────────────────────────────────

    &__nav {
      display: flex;
      align-items: center;
      gap: var(--space-2);
      flex: 1;
      justify-content: center;

      // Hide below mobile breakpoint — mobile nav lives inside the drawer
      @media (max-width: 768px) {
        display: none;
      }
    }

    &__nav-link {
      display: inline-flex;
      align-items: center;
      gap: var(--space-1);
      padding: var(--space-2) var(--space-3);
      text-decoration: none;
      color: var(--text-secondary);
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      border-radius: var(--radius-md);
      border-bottom: 2px solid transparent;
      transition:
        color var(--motion-duration-fast) var(--motion-ease-standard),
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        color: var(--brand-brass-light);
        background-color: color-mix(in srgb, var(--brand-brass) 8%, transparent);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      // Active link: brass text + brass bottom border accent
      &--active {
        color: var(--brand-brass-light);
        border-bottom-color: var(--brand-brass);
        background-color: color-mix(in srgb, var(--brand-brass) 6%, transparent);
      }
    }

    &__nav-icon {
      font-size: 1em;
      line-height: 1;
    }

    // ── Right-side actions ──────────────────────────────────────────────────

    &__actions {
      display: inline-flex;
      align-items: center;
      gap: var(--space-3);
      flex-shrink: 1;
      min-width: 0;
      margin-left: auto;

      @media (max-width: 768px) {
        gap: var(--space-2);
      }
    }
  }
</style>
