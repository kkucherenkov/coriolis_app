<script setup lang="ts">
  import { ref } from 'vue';

  interface Props {
    /** The one-shot URL to display + copy. Pass exactly once per reveal. */
    url: string;
    /** Localised "we won't show this again" warning sentence. */
    warning: string;
    /** Localised "Copy" button label. */
    copyLabel: string;
    /** Localised "Copied" toast label. */
    copiedLabel: string;
  }

  const props = defineProps<Props>();
  const justCopied = ref(false);

  async function copy() {
    try {
      await navigator.clipboard.writeText(props.url);
      justCopied.value = true;
      globalThis.setTimeout(() => (justCopied.value = false), 1500);
    } catch {
      // Clipboard API unavailable — the visible URL is still selectable.
    }
  }
</script>

<template>
  <div class="app-session-share-link-card" role="group" :aria-label="copyLabel">
    <code class="app-session-share-link-card__url">{{ url }}</code>
    <button
      type="button"
      class="app-session-share-link-card__copy"
      :aria-live="justCopied ? 'polite' : 'off'"
      @click="copy"
    >
      {{ justCopied ? copiedLabel : copyLabel }}
    </button>
    <p class="app-session-share-link-card__warning">
      {{ warning }}
    </p>
  </div>
</template>

<style scoped lang="scss">
  $btn-min-width: 88px;
  $btn-min-height: 44px;

  .app-session-share-link-card {
    display: grid;
    grid-template-columns: 1fr auto;
    gap: var(--space-3);
    padding: var(--space-4);
    background: var(--surface-night);
    border: 1px solid var(--brand-brass);
    box-shadow: inset 0 0 0 1px var(--brand-brass-shadow);
    border-radius: var(--radius-md);

    &__url {
      grid-column: 1 / 2;
      font-family: var(--font-mono);
      /* --font-size-mono-md not in token set; --type-body-xs-font-size (12px) is the closest monospace size */
      font-size: var(--type-body-xs-font-size);
      color: var(--brand-brass-light);
      word-break: break-all;
      align-self: center;
    }

    &__copy {
      grid-column: 2 / 3;
      font-family: var(--font-body);
      font-weight: 500;
      letter-spacing: 0.06em;
      text-transform: uppercase;
      padding: var(--space-2) var(--space-3);
      background: var(--brand-brass);
      color: var(--surface-void);
      border: none;
      border-radius: var(--radius-sm);
      cursor: pointer;
      min-width: $btn-min-width;
      min-height: $btn-min-height;
    }

    &__warning {
      grid-column: 1 / -1;
      margin: 0;
      font-family: var(--font-body);
      /* --font-size-body-sm not in token set; --type-body-sm-font-size (14px) is the closest */
      font-size: var(--type-body-sm-font-size);
      font-style: italic;
      color: var(--text-secondary);
    }
  }
</style>
