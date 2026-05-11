<script setup lang="ts">
  import { AppProgress, AppButton } from '@app/ui';
  import { computed } from 'vue';

  interface Props {
    step: number;
    totalSteps?: number;
    stepLabel: string;
    title: string;
    blurb?: string;
    isFirstStep?: boolean;
    isLastStep?: boolean;
    canAdvance?: boolean;
    forging?: boolean;
    saveExitLabel: string;
    backLabel: string;
    nextLabel: string;
    forgeLabel: string;
  }

  const props = withDefaults(defineProps<Props>(), {
    totalSteps: 6,
    blurb: undefined,
    isFirstStep: false,
    isLastStep: false,
    canAdvance: true,
    forging: false,
  });

  const emit = defineEmits<{
    back: [];
    next: [];
    forge: [];
    saveExit: [];
  }>();

  const progressLabel = computed(() => `${String(props.step)} / ${String(props.totalSteps)}`);
</script>

<template>
  <div class="wizard-shell">
    <header class="wizard-shell__header">
      <div class="wizard-shell__meta">
        <span class="wizard-shell__brand">{{ stepLabel }}</span>
        <span class="wizard-shell__counter">{{ progressLabel }}</span>
      </div>

      <AppProgress
        :value="step"
        :max="totalSteps"
        :min="0"
        tone="brass"
        size="sm"
        :label="stepLabel"
        class="wizard-shell__progress"
        aria-live="polite"
        :aria-label="stepLabel"
      />
    </header>

    <main class="wizard-shell__body">
      <div class="wizard-shell__title-block">
        <h1 class="wizard-shell__title">
          {{ title }}
        </h1>
        <p v-if="blurb" class="wizard-shell__blurb">
          {{ blurb }}
        </p>
      </div>

      <div class="wizard-shell__content" role="region" :aria-label="title">
        <slot />
      </div>
    </main>

    <footer class="wizard-shell__footer">
      <AppButton variant="ghost" size="md" type="button" @click="emit('saveExit')">
        {{ saveExitLabel }}
      </AppButton>

      <div class="wizard-shell__footer-nav">
        <AppButton
          v-if="!isFirstStep"
          variant="ghost"
          size="md"
          type="button"
          @click="emit('back')"
        >
          {{ backLabel }}
        </AppButton>

        <AppButton
          v-if="!isLastStep"
          variant="primary"
          size="md"
          type="button"
          :disabled="!canAdvance"
          @click="emit('next')"
        >
          {{ nextLabel }}
        </AppButton>

        <AppButton
          v-if="isLastStep"
          variant="primary"
          size="md"
          type="button"
          :disabled="!canAdvance"
          :loading="forging"
          @click="emit('forge')"
        >
          {{ forgeLabel }}
        </AppButton>
      </div>
    </footer>
  </div>
</template>

<style lang="scss" scoped>
  // Named SCSS layout variables — permitted escape hatch for pixel dimensions.
  $wizard-blurb-max-width: 580px;
  $wizard-content-max-width: 1100px;

  .wizard-shell {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    padding: var(--space-8) var(--space-10);
    background-color: var(--surface-void);

    @media (max-width: 768px) {
      padding: var(--space-6) var(--space-4);
    }

    &__header {
      margin-bottom: var(--space-8);
    }

    &__meta {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: var(--space-3);
    }

    &__brand {
      font-family: var(--font-display);
      font-size: var(--type-body-sm-font-size);
      font-weight: var(--type-display-sm-font-weight);
      color: var(--brand-brass);
      text-transform: uppercase;
      letter-spacing: 0.1em;
    }

    &__counter {
      font-family: var(--font-mono);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    &__progress {
      width: 100%;
    }

    &__body {
      flex: 1;
    }

    &__title-block {
      text-align: center;
      margin-bottom: var(--space-9);
    }

    &__title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      line-height: var(--type-display-sm-line-height);
      font-weight: var(--type-display-sm-font-weight);
      letter-spacing: var(--type-display-sm-letter-spacing);
      color: var(--brand-brass-light);
    }

    &__blurb {
      margin: var(--space-4) auto 0;
      max-width: $wizard-blurb-max-width;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
      font-style: italic;
      line-height: 1.6;
    }

    &__content {
      max-width: $wizard-content-max-width;
      margin: 0 auto;
    }

    &__footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: var(--space-9);
      padding-top: var(--space-5);
      border-top: 1px solid var(--brand-brass-deep);
    }

    &__footer-nav {
      display: flex;
      gap: var(--space-3);
      align-items: center;
    }
  }
</style>
