<script setup lang="ts">
  import { computed } from 'vue';

  /**
   * Connection status pip — 6px circle that reflects the Centrifugo
   * subscription state for the current chat channel.
   *
   * Colour token mapping (verified against tokens.generated.css):
   *   subscribed     → var(--state-success)     (green — connection live)
   *   connecting     → var(--brand-brass)        (amber — in-flight)
   *   unrecoverable  → var(--state-crimson)      (red — permanent error)
   *   disconnected   → var(--text-secondary)     (muted — offline / idle)
   *
   * NOTE: --ok, --warn, --error are not present in tokens.generated.css.
   *   Falling back to --state-success / --brand-brass / --state-crimson
   *   respectively. --text-muted is also absent; using --text-secondary.
   *   These fallbacks are reported in Block 3 notes and must be resolved
   *   when the missing semantic tokens are added in a future token pass.
   *
   * NOTE: Tooltip text uses English placeholder strings. t() integration
   *   is deferred to Block 8 when i18n keys are added for chat UI strings.
   *   Replace the hardcoded `title` values with t('chat.connection.<status>')
   *   at that point.
   */

  type Status = 'connecting' | 'subscribed' | 'unrecoverable' | 'disconnected';

  interface Props {
    status: Status;
  }

  const props = defineProps<Props>();

  const STATUS_LABEL: Record<Status, string> = {
    connecting: 'Connecting…', // Block 8: t('chat.connection.connecting')
    subscribed: 'Live', // Block 8: t('chat.connection.subscribed')
    unrecoverable: 'Reconnecting', // Block 8: t('chat.connection.unrecoverable')
    disconnected: 'Offline', // Block 8: t('chat.connection.disconnected')
  };

  const rootClasses = computed(() => [
    'app-chat-connection-pip',
    `app-chat-connection-pip--${props.status}`,
  ]);

  const label = computed(() => STATUS_LABEL[props.status]);
</script>

<template>
  <span
    :class="rootClasses"
    role="status"
    aria-live="polite"
    :title="label"
    :aria-label="label"
    data-testid="app-chat-connection-pip"
  />
</template>

<style lang="scss" scoped>
  // Pip diameter — intentionally sub-token, a visual accent not a spacing unit.
  $pip-size: 6px;

  .app-chat-connection-pip {
    display: inline-block;
    width: $pip-size;
    height: $pip-size;
    border-radius: 50%;
    flex-shrink: 0;

    // ── Status colour routing ─────────────────────────────────────────────────
    // Tokens used are the closest approved matches to the semantic --ok /
    // --warn / --error / --text-muted tokens requested in the spec;
    // see the NOTE in <script> for the fallback rationale.

    &--subscribed {
      background: var(--state-success);
    }

    &--connecting {
      background: var(--brand-brass);
    }

    &--unrecoverable {
      background: var(--state-crimson);
    }

    &--disconnected {
      background: var(--text-secondary);
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .app-chat-connection-pip {
      animation: none;
    }
  }
</style>
