<script setup lang="ts">
  /**
   * "↓ N new messages" pill — reveals only when count > 0.
   * Position is the consumer's responsibility (mount it absolutely above
   * the composer in the chat panel; see AppChatPanel in Block 6).
   *
   * Reduced-motion: the slide-in transition is skipped entirely when
   * prefers-reduced-motion: reduce is active. This is handled in CSS only —
   * no JS matchMedia detection.
   */

  interface Props {
    /** Number of new messages below the current scroll position. */
    count: number;
  }

  defineProps<Props>();

  const emit = defineEmits<{ click: [] }>();

  function onClick(): void {
    emit('click');
  }
</script>

<template>
  <button
    v-if="count > 0"
    type="button"
    class="app-chat-new-messages-pill"
    data-testid="app-chat-new-messages-pill"
    @click="onClick"
  >
    <span class="app-chat-new-messages-pill__arrow" aria-hidden="true">↓</span>
    <span class="app-chat-new-messages-pill__label">{{ count }} new messages</span>
  </button>
</template>

<style lang="scss" scoped>
  // Slide-in distance — a fixed visual offset, not a spacing token.
  $slide-distance: 8px;

  .app-chat-new-messages-pill {
    display: inline-flex;
    align-items: center;
    gap: var(--space-2);
    padding: var(--space-1) var(--space-3);
    border: 1px solid var(--brand-brass-deep);
    border-radius: var(--radius-pill);
    background: var(--surface-night);
    color: var(--brand-brass-light);
    font-family: var(--font-body);
    font-size: var(--type-body-xs-font-size);
    font-weight: var(--fw-medium);
    line-height: 1;
    cursor: pointer;
    user-select: none;
    // Slide-in animation from below.
    animation: pill-slide-in var(--motion-duration) var(--motion-ease-emphasis) both;

    &:hover {
      background: var(--surface-dawn);
      border-color: var(--brand-brass);
      color: var(--brand-brass);
    }

    &:focus-visible {
      outline: 2px solid var(--brand-brass);
      outline-offset: 2px;
    }

    // ── Internal elements ─────────────────────────────────────────────────────

    &__arrow {
      font-size: var(--type-body-xs-font-size);
      line-height: 1;
    }

    &__label {
      line-height: 1;
    }
  }

  @keyframes pill-slide-in {
    from {
      opacity: 0;
      transform: translateY($slide-distance);
    }

    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  // Skip slide-in for users who prefer reduced motion.
  @media (prefers-reduced-motion: reduce) {
    .app-chat-new-messages-pill {
      animation: none;
    }
  }
</style>
