<script setup lang="ts">
  import { computed } from 'vue';

  /**
   * Presence dot — a small standalone presence indicator.
   * Extracted from AppChatAvatar so the tab strip can render presence
   * without pulling in the full AppPortrait atom.
   *
   * Colour routing matches AppChatAvatar's pip:
   *   online  → var(--brand-brass)
   *   idle    → var(--text-secondary)  (--text-muted absent, fallback reported)
   *   offline → transparent fill, border-only
   */

  type Presence = 'online' | 'idle' | 'offline';

  interface Props {
    presence: Presence;
  }

  const props = defineProps<Props>();

  const rootClasses = computed(() => [
    'app-chat-presence-dot',
    `app-chat-presence-dot--${props.presence}`,
  ]);
</script>

<template>
  <span
    :class="rootClasses"
    role="img"
    :aria-label="presence"
    data-testid="app-chat-presence-dot"
  />
</template>

<style lang="scss" scoped>
  // Dot diameter — matches AppChatAvatar pip size for visual consistency.
  $dot-size: 8px;
  $dot-border: 2px;

  .app-chat-presence-dot {
    display: inline-block;
    width: $dot-size;
    height: $dot-size;
    border-radius: 50%;
    flex-shrink: 0;
    // Border present on all states so the element keeps a consistent hit-box.
    border: $dot-border solid transparent;

    // online — brass accent.
    &--online {
      background: var(--brand-brass);
      border-color: transparent;
    }

    // idle — muted; --text-muted absent, using --text-secondary (Block 3 fallback).
    &--idle {
      background: var(--text-secondary);
      border-color: transparent;
    }

    // offline — border-only, transparent fill.
    &--offline {
      background: transparent;
      border-color: var(--text-secondary);
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .app-chat-presence-dot {
      animation: none;
    }
  }
</style>
