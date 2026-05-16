<script setup lang="ts">
  import { computed } from 'vue';

  import AppPortrait from '../AppPortrait/AppPortrait.vue';

  /**
   * Chat avatar — wraps AppPortrait with a presence pip overlay.
   * Used in chat bubble headers, tab strips, and member lists.
   *
   * The pip is an absolutely positioned <span> overlaid on the bottom-right
   * corner of the portrait disc. Colour routing:
   *   online  → var(--brand-brass)
   *   idle    → var(--text-muted) fallback var(--text-secondary)
   *   offline → transparent fill, visible border only
   */

  type Size = 'sm' | 'md';
  type Presence = 'online' | 'idle' | 'offline';

  interface Props {
    src?: string | null;
    initials?: string;
    size?: Size;
    presence?: Presence;
  }

  const props = withDefaults(defineProps<Props>(), {
    src: undefined,
    initials: undefined,
    size: 'md',
    presence: undefined,
  });

  /** Portrait pixel sizes matching the sm/md tokens used in chat bubbles. */
  const PORTRAIT_SIZE: Record<Size, number> = { sm: 32, md: 40 };

  const portraitSize = computed(() => PORTRAIT_SIZE[props.size]);

  const rootClasses = computed(() => [
    'app-chat-avatar',
    `app-chat-avatar--size-${props.size}`,
    props.presence ? `app-chat-avatar--presence-${props.presence}` : '',
  ]);
</script>

<template>
  <span :class="rootClasses" data-testid="app-chat-avatar">
    <AppPortrait :initials="initials" :size="portraitSize" />
    <span v-if="presence" class="app-chat-avatar__pip" :aria-label="presence" role="img" />
  </span>
</template>

<style lang="scss" scoped>
  // Pip diameter — intentionally not a token (sub-pixel component detail).
  $pip-size: 10px;
  $pip-border: 2px;
  // Avatar disc sizes matching the sm/md chat bubble handoff values.
  $avatar-size-sm: 32px;
  $avatar-size-md: 40px;

  .app-chat-avatar {
    position: relative;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;

    // ── Size modifiers ────────────────────────────────────────────────────────

    &--size-sm {
      width: $avatar-size-sm;
      height: $avatar-size-sm;
    }

    &--size-md {
      width: $avatar-size-md;
      height: $avatar-size-md;
    }

    // ── Presence pip ──────────────────────────────────────────────────────────

    &__pip {
      position: absolute;
      bottom: 0;
      right: 0;
      width: $pip-size;
      height: $pip-size;
      border-radius: 50%;
      // Default border — drawn on all presences so the pip has consistent size.
      border: $pip-border solid var(--surface-void);
    }

    // online — brass accent, strong presence signal.
    &--presence-online &__pip {
      background: var(--brand-brass);
    }

    // idle — muted; --text-secondary is the closest existing token.
    // NOTE: --text-muted is not present in tokens.generated.css;
    //       falling back to --text-secondary (approved fallback per Block 3 report).
    &--presence-idle &__pip {
      background: var(--text-secondary);
    }

    // offline — transparent fill, border-only style signals absence.
    &--presence-offline &__pip {
      background: transparent;
      border-color: var(--text-secondary);
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .app-chat-avatar {
      transition: none;
    }
  }
</style>
