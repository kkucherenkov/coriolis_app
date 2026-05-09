<script setup lang="ts">
  import { AppDots } from '@app/ui';
  import { computed } from 'vue';
  import type { Attributes } from '@app/api-client-ts';

  // ST3001 ch.2 table 2.2: attribute-point pool per upbringing.
  // Per-attribute creation cap is 2..4 (key-attribute exception 5 lands in Block 2).
  type Upbringing = 'plebeian' | 'stationary' | 'aristocrat';

  const props = defineProps<Props>();

  const emit = defineEmits<{
    'update:attributes': [value: Attributes];
  }>();

  const ATTR_BUDGET: Record<Upbringing, number> = {
    plebeian: 15,
    stationary: 14,
    aristocrat: 13,
  };

  const MIN_VAL = 2;
  const MAX_VAL = 4;

  interface Props {
    attributes: Attributes;
    upbringing: Upbringing | null;
  }

  const totalPoints = computed<number>(() =>
    props.upbringing ? ATTR_BUDGET[props.upbringing] : 13,
  );

  const { t } = useI18n({ useScope: 'local' });

  type AttrKey = keyof Attributes;

  const ATTR_KEYS: AttrKey[] = ['strength', 'agility', 'wits', 'empathy'];

  const spent = computed<number>(() => ATTR_KEYS.reduce((sum, k) => sum + props.attributes[k], 0));

  const remaining = computed<number>(() => totalPoints.value - spent.value);

  const isAllSpent = computed<boolean>(() => remaining.value === 0);

  function attrLabel(key: AttrKey): string {
    return t(`attr.${key}`);
  }

  function attrBadge(key: AttrKey): string {
    return t(`badge.${key}`);
  }

  function canIncrement(key: AttrKey): boolean {
    return props.attributes[key] < MAX_VAL && remaining.value > 0;
  }

  function canDecrement(key: AttrKey): boolean {
    return props.attributes[key] > MIN_VAL;
  }

  function increment(key: AttrKey): void {
    if (!canIncrement(key)) return;
    emit('update:attributes', { ...props.attributes, [key]: props.attributes[key] + 1 });
  }

  function decrement(key: AttrKey): void {
    if (!canDecrement(key)) return;
    emit('update:attributes', { ...props.attributes, [key]: props.attributes[key] - 1 });
  }
</script>

<i18n lang="json">
{
  "en": {
    "pointsRemaining": "Points remaining",
    "allSpent": "All points spent",
    "hint": "Distribute {total} points. Min {min}, max {max} per attribute.",
    "incrementAria": "Increase {attr}",
    "decrementAria": "Decrease {attr}",
    "attr": {
      "strength": "Strength",
      "agility": "Agility",
      "wits": "Wits",
      "empathy": "Empathy"
    },
    "badge": {
      "strength": "STR",
      "agility": "AGI",
      "wits": "WIT",
      "empathy": "EMP"
    }
  },
  "ru": {
    "pointsRemaining": "Осталось очков",
    "allSpent": "Все очки распределены",
    "hint": "Распределите {total} очков. Мин. {min}, макс. {max} на атрибут.",
    "incrementAria": "Увеличить {attr}",
    "decrementAria": "Уменьшить {attr}",
    "attr": {
      "strength": "Сила",
      "agility": "Ловкость",
      "wits": "Разум",
      "empathy": "Эмпатия"
    },
    "badge": {
      "strength": "СИЛ",
      "agility": "ЛОВ",
      "wits": "РАЗ",
      "empathy": "ЭМП"
    }
  },
  "uk": {
    "pointsRemaining": "[uk-todo] Points remaining",
    "allSpent": "[uk-todo] All points spent",
    "hint": "[uk-todo] Distribute {total} points.",
    "incrementAria": "[uk-todo] Increase {attr}",
    "decrementAria": "[uk-todo] Decrease {attr}",
    "attr": {
      "strength": "[uk-todo] Strength",
      "agility": "[uk-todo] Agility",
      "wits": "[uk-todo] Wits",
      "empathy": "[uk-todo] Empathy"
    },
    "badge": {
      "strength": "STR",
      "agility": "AGI",
      "wits": "WIT",
      "empathy": "EMP"
    }
  },
  "el": {
    "pointsRemaining": "[el-todo] Points remaining",
    "allSpent": "[el-todo] All points spent",
    "hint": "[el-todo] Distribute {total} points.",
    "incrementAria": "[el-todo] Increase {attr}",
    "decrementAria": "[el-todo] Decrease {attr}",
    "attr": {
      "strength": "[el-todo] Strength",
      "agility": "[el-todo] Agility",
      "wits": "[el-todo] Wits",
      "empathy": "[el-todo] Empathy"
    },
    "badge": {
      "strength": "STR",
      "agility": "AGI",
      "wits": "WIT",
      "empathy": "EMP"
    }
  }
}
</i18n>

<template>
  <div class="step-attrs">
    <div class="step-attrs__pool" :class="{ 'step-attrs__pool--done': isAllSpent }">
      <span class="step-attrs__pool-label">{{ t('pointsRemaining') }}</span>
      <span class="step-attrs__pool-value">{{ remaining }}</span>
    </div>

    <p class="step-attrs__hint">
      {{ t('hint', { total: totalPoints, min: MIN_VAL, max: MAX_VAL }) }}
    </p>

    <div class="step-attrs__list">
      <div v-for="key in ATTR_KEYS" :key="key" class="step-attrs__row">
        <div class="step-attrs__meta">
          <span class="step-attrs__name">{{ attrLabel(key) }}</span>
          <span class="step-attrs__badge">{{ attrBadge(key) }}</span>
        </div>

        <AppDots
          :value="attributes[key]"
          :max="MAX_VAL"
          tone="brass"
          size="md"
          :label="attrLabel(key)"
          class="step-attrs__dots"
        />

        <span class="step-attrs__numval">{{ attributes[key] }}</span>

        <div class="step-attrs__controls">
          <button
            class="step-attrs__btn"
            type="button"
            :disabled="!canDecrement(key)"
            :aria-label="t('decrementAria', { attr: attrLabel(key) })"
            @click="decrement(key)"
          >
            &minus;
          </button>
          <button
            class="step-attrs__btn"
            type="button"
            :disabled="!canIncrement(key)"
            :aria-label="t('incrementAria', { attr: attrLabel(key) })"
            @click="increment(key)"
          >
            &plus;
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  // Named SCSS layout variables — permitted escape hatch for pixel dimensions.
  $attrs-max-width: 720px;
  $attr-col-name: 180px;
  $attr-col-val: 56px;
  $attr-col-ctrl: 100px;
  $btn-size: 36px;

  .step-attrs {
    max-width: $attrs-max-width;
    margin: 0 auto;

    &__pool {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: var(--space-3) var(--space-4);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-sm);
      margin-bottom: var(--space-4);

      &--done {
        border-color: var(--state-success);
      }

      &--done .step-attrs__pool-value {
        color: var(--state-success);
      }
    }

    &__pool-label {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-brass);
      text-transform: uppercase;
      letter-spacing: 0.14em;
    }

    &__pool-value {
      font-family: var(--font-mono);
      font-size: var(--type-display-sm-font-size);
      font-weight: 700;
      color: var(--brand-brass-light);
    }

    &__hint {
      margin: 0 0 var(--space-6);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__list {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__row {
      display: grid;
      grid-template-columns: $attr-col-name 1fr $attr-col-val $attr-col-ctrl;
      align-items: center;
      gap: var(--space-4);
      padding: var(--space-4) var(--space-5);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
    }

    &__meta {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__name {
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__badge {
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--brand-brass);
      text-transform: uppercase;
      letter-spacing: 0.14em;
    }

    &__dots {
      // filled by AppDots flex
    }

    &__numval {
      font-family: var(--font-mono);
      font-size: var(--type-display-sm-font-size);
      font-weight: 700;
      color: var(--text-primary);
      text-align: center;
    }

    &__controls {
      display: flex;
      gap: var(--space-2);
      justify-content: flex-end;
    }

    &__btn {
      width: $btn-size;
      height: $btn-size;
      display: flex;
      align-items: center;
      justify-content: center;
      background: transparent;
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-sm);
      color: var(--brand-brass);
      font-size: var(--type-body-lg-font-size);
      cursor: pointer;
      transition:
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover:not(:disabled) {
        border-color: var(--brand-brass);
        color: var(--brand-brass-light);
      }

      &:disabled {
        opacity: 0.3;
        cursor: not-allowed;
      }
    }
  }
</style>
