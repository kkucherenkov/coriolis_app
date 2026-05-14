<script setup lang="ts">
  import { computed } from 'vue';

  import AppDots from '../AppDots/AppDots.vue';

  /**
   * Dense skill row — `name + attr eyebrow + dot row + monospace rank`. Used
   * inside the character-sheet Skills card (desktop + mobile) and wizard
   * step 6 (Skills).
   *
   * Handoff reference: `primitives.jsx:L165-L181` + `COMPONENTS.md:L96-L103`.
   *
   * The `name` slot lets callers inject in-line decorations (e.g. the `key`
   * chip on a key-skill row in the advanced skills column); the default
   * fallback renders the `name` prop as plain body text.
   *
   * Surface decorations that depend on parent context — for instance the
   * teal accent rail on the Advanced skill column — stay with the consumer
   * so this atom remains composable across desktop, mobile, and wizard.
   */
  type Tone = 'brass' | 'mystic';

  interface Props {
    /** Skill name, e.g. `"Pilot"`. Overridable via the `name` slot. */
    name: string;
    /** Attribute eyebrow, e.g. `"Agility"`. Rendered uppercase. */
    attr: string;
    /** Rank — number of filled dots (`0`…`rankMax`). */
    rank: number;
    /** Total dots in the meter. Defaults to the rulebook cap of `5`. */
    rankMax?: number;
    /**
     * Visual tone for the attribute eyebrow + dot fill. `brass` for general
     * skills, `mystic` for advanced skills (mirrors the sheet's column tone).
     */
    tone?: Tone;
  }

  const props = withDefaults(defineProps<Props>(), {
    rankMax: 5,
    tone: 'brass',
  });

  const clampedRank = computed(() => Math.max(0, Math.min(props.rankMax, props.rank)));

  const accessibleLabel = computed(
    () => `${props.name}, ${props.attr}, ${String(clampedRank.value)} of ${String(props.rankMax)}`,
  );

  const rootClasses = computed(() => ['app-skill-row', `app-skill-row--${props.tone}`]);
</script>

<template>
  <div :class="rootClasses" role="group" :aria-label="accessibleLabel" data-testid="app-skill-row">
    <span class="app-skill-row__name">
      <slot name="name">{{ name }}</slot>
    </span>
    <span class="app-skill-row__attr" aria-hidden="true">{{ attr }}</span>
    <AppDots
      class="app-skill-row__dots"
      :value="clampedRank"
      :max="rankMax"
      :tone="tone"
      size="sm"
      :label="`${name} rank`"
    />
    <span class="app-skill-row__rank" aria-hidden="true">{{ clampedRank }}</span>
  </div>
</template>

<style lang="scss" scoped>
  // Page-scoped layout dimensions — per-component constants from the handoff,
  // not design-token values. Named SCSS variables for Stylelint's exemption.
  $attr-font-size: 10px;
  $rank-font-size: 14px;
  $rank-min-width: 14px;

  .app-skill-row {
    display: grid;
    grid-template-columns: 1fr auto auto auto;
    align-items: center;
    gap: var(--space-3);
    padding: var(--space-2) var(--space-1);
    // Handoff: 1px solid rgba(166,124,40,0.25) — brass-deep at 25% alpha.
    border-bottom: 1px solid color-mix(in srgb, var(--brand-brass-deep) 25%, transparent);

    // ── Name (body) ─────────────────────────────────────────────────────────

    &__name {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      font-weight: var(--fw-regular);
      line-height: 1;
      color: var(--text-primary);
    }

    // ── Attribute eyebrow (uppercase) ───────────────────────────────────────

    &__attr {
      font-family: var(--font-body);
      font-size: $attr-font-size;
      font-weight: var(--fw-medium);
      letter-spacing: 0.1em;
      line-height: 1;
      text-transform: uppercase;
    }

    // ── Monospace rank ──────────────────────────────────────────────────────

    &__rank {
      font-family: var(--font-mono);
      font-size: $rank-font-size;
      font-weight: var(--fw-medium);
      line-height: 1;
      min-width: $rank-min-width;
      text-align: right;
      color: var(--text-primary);
    }

    // ── Tones ───────────────────────────────────────────────────────────────

    &--brass {
      .app-skill-row__attr {
        color: var(--brand-brass);
      }
    }

    &--mystic {
      .app-skill-row__attr {
        color: var(--state-mystic-teal);
      }

      // Advanced rows trail with a mystic-tinted divider so the column reads
      // as a sibling block to general skills in the Skills card.
      border-bottom-color: color-mix(in srgb, var(--state-mystic-teal) 25%, transparent);
    }
  }

  // Honour reduced-motion preference defensively. No motion ships in this
  // atom today; the rule stays so any future hover transition is guarded.
  @media (prefers-reduced-motion: reduce) {
    .app-skill-row {
      transition: none;
    }
  }
</style>
