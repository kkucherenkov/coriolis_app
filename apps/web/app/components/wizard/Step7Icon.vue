<script setup lang="ts">
  import { AppButton, AppIconCoriolis } from '@app/ui';
  import type { IconCoriolisName } from '@app/ui';
  import type { IconId } from '@app/api-client-ts';
  import { NINE_ICONS, rollIconD66 } from '~/utils/iconRoll';

  interface Props {
    iconId: IconId | null;
  }

  const { iconId } = defineProps<Props>();

  const emit = defineEmits<{
    'update:iconId': [value: IconId | null];
  }>();

  const { t } = useI18n({ useScope: 'local' });

  function select(icon: IconId): void {
    emit('update:iconId', icon);
  }

  // ST3001 ch.2 step 15 — «Случайным образом определи Лика-покровителя».
  // Backed by the deterministic d66 → IconId table in `~/utils/iconRoll.ts`
  // (each Icon gets 4 of 36 outcomes). Players keep manual selection as
  // the default surface; this is the "let the rulebook pick for me" CTA.
  function rollAndSelect(): void {
    select(rollIconD66());
  }

  function onKeydown(event: KeyboardEvent, icon: IconId): void {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      select(icon);
    }
  }
</script>

<i18n lang="json">
{
  "en": {
    "choosePrompt": "Select the Icon who walks beside you.",
    "rollLabel": "Roll d66 for me",
    "rollHint": "Let the rulebook decide — equivalent to ST3001 step 15.",
    "iconName": {
      "lady-of-tears": "Lady of Tears",
      "traveler": "The Traveler",
      "messenger": "The Messenger",
      "merchant": "The Merchant",
      "dancer": "The Dancer",
      "gambler": "The Gambler",
      "judge": "The Judge",
      "faceless-one": "The Faceless One",
      "deckhand": "The Deckhand"
    },
    "iconDomain": {
      "lady-of-tears": "Sorrow · healing · memory",
      "traveler": "Journey · exploration · fate",
      "messenger": "Words · secrets · speed",
      "merchant": "Trade · wealth · contracts",
      "dancer": "Art · passion · beauty",
      "gambler": "Luck · risk · opportunity",
      "judge": "Law · order · justice",
      "faceless-one": "Mystery · hidden truths · the void",
      "deckhand": "Labour · endurance · solidarity"
    },
    "selected": "Chosen",
    "ariaGrid": "Nine Icons grid"
  },
  "ru": {
    "choosePrompt": "Выберите Икону, что идёт рядом с вами.",
    "rollLabel": "Кинуть d66",
    "rollHint": "Доверьте выбор правилам — соответствует шагу 15 ST3001.",
    "iconName": {
      "lady-of-tears": "Дама слёз",
      "traveler": "Странник",
      "messenger": "Вестник",
      "merchant": "Торговец",
      "dancer": "Танцовщица",
      "gambler": "Игрок",
      "judge": "Судья",
      "faceless-one": "Безликий",
      "deckhand": "Матрос"
    },
    "iconDomain": {
      "lady-of-tears": "Скорбь · исцеление · память",
      "traveler": "Путь · исследование · судьба",
      "messenger": "Слова · тайны · скорость",
      "merchant": "Торговля · богатство · контракты",
      "dancer": "Искусство · страсть · красота",
      "gambler": "Удача · риск · шанс",
      "judge": "Закон · порядок · справедливость",
      "faceless-one": "Тайна · скрытые истины · пустота",
      "deckhand": "Труд · стойкость · солидарность"
    },
    "selected": "Выбрано",
    "ariaGrid": "Сетка Девяти Икон"
  }
}
</i18n>

<template>
  <div class="step-icon">
    <p class="step-icon__prompt">
      {{ t('choosePrompt') }}
    </p>

    <div class="step-icon__roll">
      <AppButton
        type="button"
        variant="mystic"
        size="md"
        :aria-describedby="`step-icon-roll-hint`"
        @click="rollAndSelect"
      >
        {{ t('rollLabel') }}
      </AppButton>
      <p id="step-icon-roll-hint" class="step-icon__roll-hint">
        {{ t('rollHint') }}
      </p>
    </div>

    <div class="step-icon__grid" role="radiogroup" :aria-label="t('ariaGrid')">
      <div
        v-for="icon in NINE_ICONS"
        :key="icon"
        class="step-icon__cell"
        :class="{ 'step-icon__cell--selected': iconId === icon }"
        role="radio"
        :aria-checked="iconId === icon"
        tabindex="0"
        @click="select(icon)"
        @keydown="onKeydown($event, icon)"
      >
        <div class="step-icon__aura" aria-hidden="true" />

        <AppIconCoriolis
          :name="icon as IconCoriolisName"
          size="lg"
          :color="iconId === icon ? 'mystic' : 'brass'"
          v-bind="{ ariaLabel: t(`iconName.${icon}`) }"
          class="step-icon__glyph"
        />

        <span class="step-icon__name">{{ t(`iconName.${icon}`) }}</span>
        <span class="step-icon__domain">{{ t(`iconDomain.${icon}`) }}</span>

        <span v-if="iconId === icon" class="step-icon__badge" aria-hidden="true">
          {{ t('selected') }}
        </span>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  // Named SCSS layout variables — permitted escape hatch for pixel dimensions.
  $icon-grid-max-width: 880px;
  // Pulse keyframe duration — SCSS var avoids literal ms in animation shorthand.
  $aura-pulse-duration: 1200ms;
  // Box-shadow spread for pulse — SCSS var avoids literal px in box-shadow.
  $aura-spread: 12px;
  // Stacking context: content sits above the ::before aura overlay.
  $z-icon-content: var(--z-raised);

  // Pulse keyframe — defined at block level so the @media override is clean.
  @keyframes aura-pulse {
    0% {
      box-shadow: 0 0 0 0 var(--state-mystic-teal);
      opacity: 0.8;
    }
    70% {
      box-shadow: 0 0 0 $aura-spread var(--state-mystic-teal);
      opacity: 0;
    }
    100% {
      box-shadow: 0 0 0 0 var(--state-mystic-teal);
      opacity: 0;
    }
  }

  .step-icon {
    &__prompt {
      text-align: center;
      margin: 0 0 var(--space-4);
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__roll {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-2);
      margin: 0 0 var(--space-8);
    }

    &__roll-hint {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: var(--space-4);
      max-width: $icon-grid-max-width;
      margin: 0 auto;
    }

    &__cell {
      position: relative;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-2);
      padding: var(--space-5) var(--space-4);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      cursor: pointer;
      outline: none;
      transition:
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover:not(.step-icon__cell--selected) {
        border-color: var(--brand-brass-deep);
        background-color: var(--surface-dawn);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      // ── Selected state ────────────────────────────────────────────────────

      &--selected {
        border-color: var(--state-mystic-teal);
        background-color: var(--surface-night);
        box-shadow: 0 0 0 4px color-mix(in srgb, var(--state-mystic-teal) 25%, transparent);
      }

      &--selected .step-icon__aura {
        animation: aura-pulse $aura-pulse-duration ease-out infinite;
      }

      @media (prefers-reduced-motion: reduce) {
        &--selected .step-icon__aura {
          animation: none;
          box-shadow: 0 0 0 4px var(--state-mystic-teal);
          opacity: 0.4;
        }
      }
    }

    // Pseudo-overlay for the pulsing aura — sits behind content
    &__aura {
      position: absolute;
      inset: 0;
      border-radius: var(--radius-md);
      pointer-events: none;
    }

    &__glyph {
      position: relative;
      z-index: $z-icon-content;
    }

    &__name {
      position: relative;
      z-index: $z-icon-content;
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      font-weight: var(--type-display-sm-font-weight);
      color: var(--brand-brass-light);
      text-align: center;
    }

    &__domain {
      position: relative;
      z-index: $z-icon-content;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      text-align: center;
      line-height: 1.4;
    }

    &__badge {
      position: relative;
      z-index: $z-icon-content;
      display: inline-block;
      padding: var(--space-1) var(--space-2);
      background-color: color-mix(in srgb, var(--state-mystic-teal) 15%, transparent);
      border: 1px solid var(--state-mystic-teal);
      border-radius: var(--radius-sm);
      font-family: var(--font-body);
      font-size: var(--type-body-xs-font-size);
      color: var(--state-mystic-teal);
      text-transform: uppercase;
      letter-spacing: 0.1em;
      margin-top: var(--space-1);
    }
  }
</style>
