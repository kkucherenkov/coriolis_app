<script setup lang="ts">
  import { computed } from 'vue';

  type SaveState = 'idle' | 'saving' | 'saved' | 'error';

  interface Props {
    state: SaveState;
  }

  const props = defineProps<Props>();

  const classes = computed(() => ['app-save-pulse', `app-save-pulse--${props.state}`]);
</script>

<template>
  <!--
    AppSavePulse — visual auto-save indicator.
    Decision log: uses a single dot that pulses (scale + opacity) in 'saving'
    state; transitions to solid/dim/crimson for the other states.
    UModal wrapping (AppModal primitive) was intentionally deferred to a later
    batch so this primitive ships without extra scope.
  -->
  <span
    :class="classes"
    aria-hidden="true"
    role="presentation"
  >
    <span class="app-save-pulse__dot" />
  </span>
</template>

<style lang="scss" scoped>
  // Dot size — below Stylelint raw-px floor, approved as layout constant.
  $dot-size: 8px;
  $dot-size-saving: 10px;

  .app-save-pulse {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: $dot-size-saving;
    height: $dot-size-saving;
    flex-shrink: 0;

    // ── Dot ───────────────────────────────────────────────────────────────────

    &__dot {
      display: block;
      width: $dot-size;
      height: $dot-size;
      border-radius: var(--radius-pill);
      background-color: var(--brand-brass-deep);
      transition:
        background-color var(--motion-duration-standard) var(--motion-ease-standard),
        opacity var(--motion-duration-standard) var(--motion-ease-standard),
        transform var(--motion-duration-standard) var(--motion-ease-standard);
    }

    // ── Idle — dim brass dot ──────────────────────────────────────────────────

    &--idle &__dot {
      background-color: var(--brand-brass-deep);
      opacity: var(--opacity-disabled);
      transform: scale(1);
    }

    // ── Saving — pulsing brass dot ────────────────────────────────────────────

    &--saving &__dot {
      background-color: var(--brand-brass);
      opacity: 1;
      transform: scale(1);
      animation: app-save-pulse-anim var(--motion-duration-ceremony) ease-in-out infinite alternate;
    }

    // ── Saved — solid bright brass dot ───────────────────────────────────────

    &--saved &__dot {
      background-color: var(--brand-brass-light);
      opacity: 1;
      transform: scale(1);
    }

    // ── Error — crimson, no pulse ─────────────────────────────────────────────

    &--error &__dot {
      background-color: var(--state-crimson-bright);
      opacity: 1;
      transform: scale(1);
    }
  }

  // ── Pulse animation ───────────────────────────────────────────────────────────

  @keyframes app-save-pulse-anim {
    from {
      transform: scale(0.75);
      opacity: 0.5;
    }

    to {
      transform: scale(1.25);
      opacity: 1;
    }
  }

  // ── Reduced motion — fade-only, no scale ─────────────────────────────────────

  @media (prefers-reduced-motion: reduce) {
    .app-save-pulse--saving .app-save-pulse__dot {
      animation: app-save-pulse-fade var(--motion-duration-ceremony) ease-in-out infinite alternate;
    }

    @keyframes app-save-pulse-fade {
      from {
        opacity: 0.4;
      }

      to {
        opacity: 1;
      }
    }
  }
</style>
