<script setup lang="ts">
  import { computed } from 'vue';

  import AppBadge from '../AppBadge/AppBadge.vue';
  import AppDie from '../AppDie/AppDie.vue';

  type DieValue = 1 | 2 | 3 | 4 | 5 | 6;
  type DieSize = 'sm' | 'md' | 'lg';
  type DieTone = 'brass' | 'mystic';

  /**
   * Coriolis dice rules (ST3001 ГЛАВА 5):
   *   - A roll of 6 is a success ("hit").
   *   - A roll of 1 is a bane.
   *   - When you push (reroll), the non-6 dice from the first roll are rerolled.
   *   - The kept 6s from the first roll count toward total successes.
   *   - Rerolled dice that also show 6 add successes; their state is "pushed"
   *     (distinct from the kept 6s). We track hit count as:
   *       count of values[i] === 6 regardless of whether the die was pushed.
   *   - A die is `pushed` if its index appears in pushedIndices.
   *   - A die is `failed` if its value === 1 and it is NOT pushed
   *     (pushed failures are less significant — the push already paid the cost).
   *   - A die is `hit` if its value === 6 and it is NOT pushed
   *     (pushed hits are shown with state `pushed` to distinguish them visually
   *     and match the dice-roller.jsx mockup which dims non-6 originals).
   */

  interface Props {
    values: DieValue[];
    pushedIndices?: number[];
    size?: DieSize;
    tone?: DieTone;
    showHitCount?: boolean;
  }

  const props = withDefaults(defineProps<Props>(), {
    pushedIndices: () => [],
    size: 'md',
    tone: 'brass',
    showHitCount: true,
  });

  const pushedSet = computed(() => new Set(props.pushedIndices));

  /**
   * Total successes: all dice showing 6 (both kept and pushed).
   * In Coriolis the push mechanic keeps the 6s and rerolls the rest;
   * all 6s in the final pool count as successes.
   */
  const hitCount = computed(() => props.values.filter((v) => v === 6).length);

  /** Determine display state per die index. */
  function dieState(index: number, value: DieValue): 'normal' | 'hit' | 'pushed' | 'failed' {
    const isPushed = pushedSet.value.has(index);
    if (isPushed) return 'pushed';
    if (value === 6) return 'hit';
    if (value === 1) return 'failed';
    return 'normal';
  }

  const poolClasses = computed(() => [
    'app-die-pool',
    `app-die-pool--${props.size}`,
    `app-die-pool--${props.tone}`,
  ]);
</script>

<template>
  <div :class="poolClasses">
    <ul role="list" class="app-die-pool__list">
      <li
        v-for="(value, index) in values"
        :key="index"
        :class="['app-die-pool__item', { 'app-die-pool__item--pushed': pushedSet.has(index) }]"
      >
        <AppDie :value="value" :state="dieState(index, value)" :size="size" />
      </li>
    </ul>

    <div v-if="showHitCount" class="app-die-pool__count" aria-live="polite">
      <AppBadge variant="success" size="sm">
        {{ hitCount }} {{ hitCount === 1 ? 'hit' : 'hits' }}
      </AppBadge>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  // Push offset — a small visual cue that a die was rerolled per dice-roller.jsx.
  // Not a token value (sub-4px micro-detail); SCSS var is the approved escape hatch.
  $pushed-offset: 3px;

  .app-die-pool {
    display: inline-flex;
    flex-direction: column;
    gap: var(--space-2);

    // ── Die list ──────────────────────────────────────────────────────────────

    &__list {
      display: flex;
      flex-wrap: wrap;
      gap: var(--space-2);
      list-style: none;
      margin: 0;
      padding: 0;
    }

    // ── Individual die slot ───────────────────────────────────────────────────

    &__item {
      display: inline-flex;
      align-items: center;
      justify-content: center;
    }

    // Pushed dice translated slightly downward and dimmed per the dice-roller.jsx mockup.
    &__item--pushed {
      transform: translateY($pushed-offset);
      opacity: var(--opacity-elevated); // 0.85
    }

    // ── Hit count badge ───────────────────────────────────────────────────────

    &__count {
      display: flex;
      align-items: center;
    }

    // ── Size modifiers ────────────────────────────────────────────────────────

    &--sm {
      gap: var(--space-1);

      .app-die-pool__list {
        gap: var(--space-1);
      }
    }

    &--md {
      gap: var(--space-2);
    }

    &--lg {
      gap: var(--space-3);

      .app-die-pool__list {
        gap: var(--space-3);
      }
    }

    // ── Tone modifiers (reserved for future theming) ──────────────────────────

    &--brass {
      // No overrides yet; placeholder for "Mystic powers" variant.
    }

    &--mystic {
      // Future: teal tint on the pool background.
    }
  }
</style>
