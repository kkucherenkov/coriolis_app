<script setup lang="ts">
  import { computed } from 'vue';

  import { AppIcon } from '../AppIcon';

  type Tone = 'info' | 'success' | 'warning' | 'danger' | 'parchment';

  interface Props {
    tone?: Tone;
    title?: string;
    dismissible?: boolean;
    icon?: string;
    /** Accessible name for the dismiss control. Localize per consumer locale. */
    dismissLabel?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    tone: 'info',
    title: undefined,
    dismissible: false,
    icon: undefined,
    dismissLabel: 'Dismiss',
  });

  const emit = defineEmits<{
    dismiss: [];
  }>();

  // Default icon per tone. DESIGN §4.2 uses Lucide icon names.
  const DEFAULT_ICONS: Record<Tone, string> = {
    info: 'info',
    success: 'check-circle',
    warning: 'triangle-alert',
    danger: 'octagon-alert',
    parchment: 'eye',
  };

  const resolvedIcon = computed(() => props.icon ?? DEFAULT_ICONS[props.tone]);

  // danger → role="alert" so AT announces immediately; all others → role="status"
  const role = computed(() => (props.tone === 'danger' ? 'alert' : 'status'));

  const classes = computed(() => [
    'app-banner',
    `app-banner--${props.tone}`,
    { 'app-banner--dismissible': props.dismissible },
  ]);
</script>

<template>
  <div :class="classes" :role="role">
    <span class="app-banner__icon" aria-hidden="true">
      <AppIcon :name="resolvedIcon" size="md" />
    </span>

    <div class="app-banner__body">
      <strong v-if="title" class="app-banner__title">{{ title }}</strong>
      <div v-if="$slots['default']" class="app-banner__content">
        <slot />
      </div>
    </div>

    <div v-if="$slots['actions']" class="app-banner__actions">
      <slot name="actions" />
    </div>

    <button
      v-if="dismissible"
      type="button"
      class="app-banner__dismiss"
      :aria-label="dismissLabel"
      @click="emit('dismiss')"
    >
      <AppIcon name="x" size="sm" />
    </button>
  </div>
</template>

<style lang="scss" scoped>
  .app-banner {
    display: flex;
    align-items: flex-start;
    gap: var(--space-3);
    padding: var(--space-4);
    border-radius: var(--radius-md);
    border: 1px solid;

    // ── Tone: info (default) ─────────────────────────────────────────────────

    &--info {
      background-color: var(--surface-night);
      border-color: var(--brand-brass-deep);
      color: var(--text-primary);

      .app-banner__icon {
        color: var(--brand-brass-light);
      }

      .app-banner__title {
        color: var(--brand-brass-light);
      }
    }

    // ── Tone: success ────────────────────────────────────────────────────────

    &--success {
      background-color: var(--surface-night);
      border-color: var(--state-success);
      color: var(--text-primary);

      .app-banner__icon {
        color: var(--state-success);
      }

      .app-banner__title {
        color: var(--state-success);
      }
    }

    // ── Tone: warning ────────────────────────────────────────────────────────

    &--warning {
      background-color: var(--surface-night);
      border-color: var(--brand-brass-deep);
      color: var(--text-primary);

      .app-banner__icon {
        color: var(--brand-brass);
      }

      .app-banner__title {
        color: var(--brand-brass);
      }
    }

    // ── Tone: danger ─────────────────────────────────────────────────────────

    &--danger {
      background-color: var(--surface-night);
      border-color: var(--state-crimson);
      color: var(--text-primary);

      .app-banner__icon {
        color: var(--state-crimson-bright);
      }

      .app-banner__title {
        color: var(--state-crimson-bright);
      }
    }

    // ── Tone: parchment ──────────────────────────────────────────────────────
    // Inverted: light surface on dark background (share-viewer read-only notice).
    // --text-ink (#1A1810) on --surface-parchment (#F2E8D0):
    //   luminance ratio ≈ 12.6:1 — exceeds WCAG AA (4.5:1) and AAA (7:1).

    &--parchment {
      background-color: var(--surface-parchment);
      border-color: var(--brand-brass-deep);
      color: var(--text-ink);

      .app-banner__icon {
        color: var(--brand-brass-shadow);
      }

      .app-banner__title {
        color: var(--text-ink);
      }

      .app-banner__dismiss {
        color: var(--text-ink);

        &:hover {
          background-color: color-mix(in srgb, var(--text-ink) 10%, transparent);
        }
      }
    }

    // ── Elements ─────────────────────────────────────────────────────────────

    &__icon {
      display: inline-flex;
      align-items: center;
      flex-shrink: 0;
      margin-top: 1px; // optical alignment with first text baseline
    }

    &__body {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
      flex: 1;
      min-width: 0;
    }

    &__title {
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      font-weight: 600;
      line-height: var(--type-body-sm-line-height);
    }

    &__content {
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      font-weight: var(--type-body-sm-font-weight);
      line-height: var(--type-body-sm-line-height);
      color: inherit;
    }

    &__actions {
      display: flex;
      align-items: center;
      flex-shrink: 0;
      gap: var(--space-2);
      margin-left: auto;
    }

    &__dismiss {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      background: none;
      border: none;
      cursor: pointer;
      border-radius: var(--radius-sm);
      padding: var(--space-1);
      color: var(--text-secondary);
      transition:
        background-color var(--motion-duration-fast) var(--motion-ease-standard),
        color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        background-color: color-mix(in srgb, var(--text-primary) 10%, transparent);
        color: var(--text-primary);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }
  }
</style>
