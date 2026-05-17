<script setup lang="ts">
  /**
   * Chat day divider — horizontal separator with a brass hairline on both
   * sides and an uppercase tracked label (e.g. "TODAY", "YESTERDAY", "MAY 16").
   *
   * Token note: --brand-brass-deep is confirmed present in tokens.generated.css.
   * The spec referred to it as "brand-brass-deep" — that exact token exists.
   */

  interface Props {
    /** Label rendered between the two hairlines (e.g. "TODAY", "MAY 16"). */
    label: string;
  }

  defineProps<Props>();
</script>

<template>
  <div class="app-chat-day-divider" role="separator" data-testid="app-chat-day-divider">
    <span class="app-chat-day-divider__line" aria-hidden="true" />
    <span class="app-chat-day-divider__label">{{ label }}</span>
    <span class="app-chat-day-divider__line" aria-hidden="true" />
  </div>
</template>

<style lang="scss" scoped>
  .app-chat-day-divider {
    display: flex;
    align-items: center;
    gap: var(--space-3);
    padding-inline: var(--space-4);

    // ── Hairline ──────────────────────────────────────────────────────────────

    &__line {
      flex: 1;
      height: 0;
      border-top: 1px solid var(--brand-brass-deep);
    }

    // ── Label ─────────────────────────────────────────────────────────────────

    &__label {
      flex-shrink: 0;
      font-family: var(--font-display); // Forum, serif — per spec
      font-size: var(--type-body-xs-font-size);
      font-weight: var(--fw-regular);
      line-height: 1;
      letter-spacing: 0.16em;
      text-transform: uppercase;
      color: var(--brand-brass-deep);
      user-select: none;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .app-chat-day-divider {
      transition: none;
    }
  }
</style>
