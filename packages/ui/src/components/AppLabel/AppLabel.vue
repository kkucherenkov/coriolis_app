<script setup lang="ts">
  import { computed } from 'vue';

  type Tone = 'default' | 'eyebrow' | 'stat-block';

  interface Props {
    /** When present, renders as `<label for="<id>">`. Absent → renders as `<span>`. */
    for?: string;
    /** Visual tone — controls typography style. */
    tone?: Tone;
    /** Appends a brass `*` after the label content; marked with aria-label="required". */
    required?: boolean;
    /** Optional secondary line rendered below the main label in muted color. */
    helpText?: string;
    /**
     * Convenience prop: plain-text label content for consumers that cannot use slots
     * (e.g. AppField render-function usage). When the default slot is also provided,
     * the slot takes precedence.
     */
    text?: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    for: undefined,
    tone: 'default',
    required: false,
    helpText: undefined,
    text: undefined,
  });

  const tag = computed(() => (props.for !== undefined ? 'label' : 'span'));

  const classes = computed(() => [
    'app-label',
    `app-label--${props.tone}`,
    { 'app-label--with-help': !!props.helpText },
  ]);
</script>

<template>
  <component :is="tag" :for="tag === 'label' ? $props.for : undefined" :class="classes">
    <span class="app-label__text">
      <slot>{{ text }}</slot>
    </span>
    <span v-if="required" class="app-label__required" aria-label="required" aria-hidden="false">*</span>
    <span v-if="helpText" class="app-label__help">{{ helpText }}</span>
  </component>
</template>

<style lang="scss" scoped>
  .app-label {
    display: inline-flex;
    flex-direction: column;
    gap: var(--space-1);

    // ── Tone: default ────────────────────────────────────────────────────────

    &--default {
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      line-height: var(--type-body-sm-line-height);
      font-weight: var(--type-body-sm-font-weight);
      color: var(--text-primary);

      .app-label__text {
        display: inline-flex;
        align-items: baseline;
        gap: var(--space-1);
      }
    }

    // ── Tone: eyebrow ────────────────────────────────────────────────────────
    // "STRENGTH" / "AGILITY" style — Forum, uppercase, brass tracking.
    // Maps to --type-display-sm: 20/28, Forum 400, 0.08em uppercase.

    &--eyebrow {
      font-family: var(--type-display-sm-font-family);
      font-size: var(--type-display-sm-font-size);
      line-height: var(--type-display-sm-line-height);
      font-weight: var(--type-display-sm-font-weight);
      letter-spacing: var(--type-display-sm-letter-spacing);
      text-transform: uppercase;
      color: var(--brand-brass-light);

      .app-label__text {
        display: inline-flex;
        align-items: baseline;
        gap: var(--space-1);
      }
    }

    // ── Tone: stat-block ─────────────────────────────────────────────────────
    // Labels above big numeric stats — uppercase, brass, slightly larger than body-sm.
    // Uses body-sm scale with explicit uppercase and brass color.

    &--stat-block {
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      line-height: var(--type-body-sm-line-height);
      font-weight: var(--type-body-sm-font-weight);
      letter-spacing: 0.1em;
      text-transform: uppercase;
      color: var(--brand-brass);

      .app-label__text {
        display: inline-flex;
        align-items: baseline;
        gap: var(--space-1);
      }
    }

    // ── Required marker ──────────────────────────────────────────────────────

    &__required {
      color: var(--brand-brass);
      font-weight: 600;
      line-height: inherit;
    }

    // ── Help text ────────────────────────────────────────────────────────────

    &__help {
      display: block;
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      line-height: var(--type-body-sm-line-height);
      font-weight: var(--type-body-sm-font-weight);
      color: var(--text-secondary);
    }

    // ── With-help modifier ───────────────────────────────────────────────────

    &--with-help {
      gap: var(--space-1);
    }
  }
</style>
