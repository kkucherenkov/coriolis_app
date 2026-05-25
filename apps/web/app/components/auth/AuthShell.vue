<script setup lang="ts">
  import { AppWordmark, AppArabesqueCorner } from '@app/ui';

  /**
   * Ceremonial chrome shared by every auth surface (login, signup,
   * forgot-password, reset-password). Renders the brand lockup, a brass
   * "astrolabe" card framed with arabesque corners, and the page heading.
   * The page supplies the form, alerts, and footnote links via the default
   * slot, styled with the shared `auth-content` classes.
   */
  interface Props {
    /** Page heading — names the action (e.g. "Sign in"). Forum display. */
    title: string;
    /** Optional supporting line under the heading. Inter body. */
    subtitle?: string;
  }

  withDefaults(defineProps<Props>(), { subtitle: undefined });
</script>

<template>
  <div class="auth-shell">
    <div class="auth-shell__inner">
      <AppWordmark class="auth-shell__wordmark" :size="44" />

      <section class="auth-shell__card">
        <AppArabesqueCorner
          class="auth-shell__corner auth-shell__corner--tl"
          orientation="tl"
          size="sm"
          color="brass-deep"
        />
        <AppArabesqueCorner
          class="auth-shell__corner auth-shell__corner--tr"
          orientation="tr"
          size="sm"
          color="brass-deep"
        />
        <AppArabesqueCorner
          class="auth-shell__corner auth-shell__corner--bl"
          orientation="bl"
          size="sm"
          color="brass-deep"
        />
        <AppArabesqueCorner
          class="auth-shell__corner auth-shell__corner--br"
          orientation="br"
          size="sm"
          color="brass-deep"
        />

        <div class="auth-shell__body">
          <header class="auth-shell__header">
            <h1 class="auth-shell__title">
              {{ title }}
            </h1>
            <p v-if="subtitle" class="auth-shell__subtitle">
              {{ subtitle }}
            </p>
          </header>

          <slot />
        </div>
      </section>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  .auth-shell {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-7) var(--space-4);

    &__inner {
      width: 100%;
      max-width: 30rem;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-7);
    }

    &__wordmark {
      // The lockup centres itself; nothing to add here beyond the column gap.
      flex-shrink: 0;
    }

    &__card {
      position: relative;
      isolation: isolate;
      width: 100%;
      background: var(--surface-night);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
      box-shadow: var(--shadow-brass-bevel);
      padding: var(--space-10) var(--space-9);

      @media (max-width: 540px) {
        padding: var(--space-9) var(--space-6);
      }
    }

    &__corner {
      position: absolute;
      z-index: var(--z-base);
      opacity: var(--opacity-subtle);
      pointer-events: none;

      &--tl {
        top: var(--space-2);
        left: var(--space-2);
      }

      &--tr {
        top: var(--space-2);
        right: var(--space-2);
      }

      &--bl {
        bottom: var(--space-2);
        left: var(--space-2);
      }

      &--br {
        bottom: var(--space-2);
        right: var(--space-2);
      }
    }

    &__body {
      position: relative;
      z-index: var(--z-raised);
    }

    &__header {
      margin-bottom: var(--space-6);
    }

    &__title {
      margin: 0 0 var(--space-2);
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      line-height: var(--type-display-sm-line-height);
      font-weight: var(--type-display-sm-font-weight);
      letter-spacing: var(--type-display-sm-letter-spacing);
      text-transform: uppercase;
      color: var(--brand-brass-light);
    }

    &__subtitle {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      line-height: var(--type-body-sm-line-height);
      color: var(--text-secondary);
    }
  }
</style>
