<script setup lang="ts">
  export interface AppSessionHeaderLabels {
    statusOnline: string;
    statusOffline: string;
    dpLabel: string;
    leaveLabel: string;
    backLabel: string;
  }

  export interface AppSessionHeaderProps {
    sessionName: string;
    mode: 'gm' | 'player';
    status: 'online' | 'offline';
    dpCount: number;
    labels: AppSessionHeaderLabels;
  }

  defineProps<AppSessionHeaderProps>();
  defineEmits<{ leave: []; back: [] }>();
</script>

<template>
  <header class="app-session-header">
    <div class="app-session-header__main">
      <h1 class="app-session-header__title">
        {{ sessionName }}
      </h1>
      <div class="app-session-header__meta">
        <span class="app-session-header__badge" :class="`app-session-header__badge--${status}`">{{
          status === 'online' ? labels.statusOnline : labels.statusOffline
        }}</span>
        <span class="app-session-header__dp">{{ labels.dpLabel }}: {{ dpCount }}</span>
      </div>
    </div>
    <div class="app-session-header__actions">
      <button
        v-if="mode === 'player'"
        class="app-session-header__leave"
        type="button"
        @click="$emit('leave')"
      >
        {{ labels.leaveLabel }}
      </button>
    </div>
  </header>
</template>

<style lang="scss" scoped>
  // Badge vertical padding — below the space-1 (4px) token by design.
  // SCSS variable is the approved escape hatch for sub-token layout-dimension literals.
  $badge-pad-v: 3px;

  .app-session-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--space-4);
    padding: var(--space-5) var(--space-7);
    background: var(--surface-night);
    border-bottom: 1px solid var(--brand-brass-shadow);

    &__main {
      display: flex;
      align-items: center;
      gap: var(--space-4);
      flex: 1;
      min-width: 0;
    }

    &__title {
      margin: 0;
      font-family: var(--type-display-md-font-family);
      font-size: var(--type-display-sm-font-size);
      font-weight: var(--fw-bold);
      letter-spacing: var(--type-display-sm-letter-spacing);
      color: var(--text-primary);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    &__meta {
      display: flex;
      align-items: center;
      gap: var(--space-3);
      flex-shrink: 0;
    }

    &__badge {
      display: inline-flex;
      align-items: center;
      padding: $badge-pad-v var(--space-3);
      border-radius: var(--radius-pill);
      border: 1px solid;
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-label-sm-font-size);
      font-weight: var(--fw-medium);
      line-height: 1;
      white-space: nowrap;

      // ── Online: mystic-teal — matches AppBadge--mystic convention ───────────
      &--online {
        border-color: var(--state-mystic-teal);
        color: var(--state-mystic-teal);
        background-color: color-mix(in srgb, var(--state-mystic-teal) 12%, transparent);
      }

      // ── Offline: crimson — matches AppBadge--crimson convention ─────────────
      &--offline {
        border-color: var(--state-crimson);
        color: var(--state-crimson-bright);
        background-color: color-mix(in srgb, var(--state-crimson) 12%, transparent);
      }
    }

    &__dp {
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      font-weight: var(--fw-medium);
      color: var(--text-secondary);
      white-space: nowrap;
    }

    &__actions {
      display: inline-flex;
      align-items: center;
      gap: var(--space-3);
      flex-shrink: 0;
    }

    // ── Leave button: ghost style matching AppButton--ghost ──────────────────
    &__leave {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: var(--space-2);
      padding: var(--space-2) var(--space-4);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
      background-color: transparent;
      color: var(--brand-brass-light);
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      font-weight: var(--type-body-md-font-weight);
      line-height: var(--type-body-md-line-height);
      cursor: pointer;
      white-space: nowrap;
      transition:
        background-color var(--motion-duration-fast) var(--motion-ease-standard),
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        background-color: color-mix(in srgb, var(--brand-brass) 8%, transparent);
        border-color: var(--brand-brass);
      }

      &:active {
        background-color: color-mix(in srgb, var(--brand-brass) 14%, transparent);
        border-color: var(--brand-brass);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }
  }
</style>
