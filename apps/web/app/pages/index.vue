<script setup lang="ts">
  const { t } = useI18n({ useScope: 'local' });

  function onSignIn(): void {
    void navigateTo('/login');
  }

  function onCreateAccount(): void {
    void navigateTo('/login?mode=register');
  }
</script>

<i18n lang="json">
{
  "en": {
    "wordmark": "Coriolis Companion",
    "tagline": "Your character sheet for the Third Horizon.",
    "signIn": "Sign in",
    "createAccount": "Create account"
  },
  "ru": {
    "wordmark": "Coriolis Companion",
    "tagline": "Ваш лист персонажа для Третьего Горизонта.",
    "signIn": "Войти",
    "createAccount": "Создать аккаунт"
  },
  "uk": {
    "wordmark": "Coriolis Companion",
    "tagline": "[uk-todo] tagline for landing hero",
    "signIn": "[uk-todo] sign in",
    "createAccount": "[uk-todo] create account"
  },
  "el": {
    "wordmark": "Coriolis Companion",
    "tagline": "[el-todo] tagline for landing hero",
    "signIn": "[el-todo] sign in",
    "createAccount": "[el-todo] create account"
  }
}
</i18n>

<template>
  <section class="page-landing">
    <div class="page-landing__hero">
      <h1 class="page-landing__wordmark">{{ t('wordmark') }}</h1>
      <p class="page-landing__tagline">{{ t('tagline') }}</p>

      <div class="page-landing__cta">
        <button
          type="button"
          class="page-landing__button page-landing__button--primary"
          @click="onSignIn"
        >
          {{ t('signIn') }}
        </button>
        <button
          type="button"
          class="page-landing__button page-landing__button--ghost"
          @click="onCreateAccount"
        >
          {{ t('createAccount') }}
        </button>
      </div>
    </div>
  </section>
</template>

<style lang="scss" scoped>
  // Layout dimensions for the landing hero. Page-scoped, not part of the
  // shared spacing scale — Stylelint allows named SCSS variables for
  // layout caps (see stylelint.config.mjs declaration-property-value rule).
  $hero-max-width: 640px;

  .page-landing {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-9) var(--space-7);

    &__hero {
      max-width: $hero-max-width;
      text-align: center;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-6);
    }

    &__wordmark {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-xl-font-size);
      line-height: var(--type-display-xl-line-height);
      font-weight: var(--type-display-xl-font-weight);
      letter-spacing: var(--type-display-xl-letter-spacing);
      color: var(--brand-brass-light);
    }

    &__tagline {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-lg-font-size);
      line-height: var(--type-body-lg-line-height);
      font-style: italic;
      letter-spacing: 0.04em;
      color: var(--text-secondary);
    }

    &__cta {
      display: flex;
      gap: var(--space-3);
      flex-wrap: wrap;
      justify-content: center;
      margin-top: var(--space-3);
    }

    &__button {
      cursor: pointer;
      padding: var(--space-3) var(--space-6);
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      letter-spacing: 0.06em;
      border-radius: var(--radius-md);
      transition:
        background-color var(--motion-duration-fast) var(--motion-ease-standard),
        border-color var(--motion-duration-fast) var(--motion-ease-standard),
        color var(--motion-duration-fast) var(--motion-ease-standard);

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      &--primary {
        background: var(--brand-brass);
        border: 1px solid var(--brand-brass);
        color: var(--text-on-brass);

        &:hover {
          background: var(--brand-brass-light);
          border-color: var(--brand-brass-light);
        }
      }

      &--ghost {
        background: transparent;
        border: 1px solid var(--brand-brass-deep);
        color: var(--brand-brass-light);

        &:hover {
          border-color: var(--brand-brass);
          background: color-mix(in srgb, var(--brand-brass) 8%, transparent);
        }
      }
    }
  }
</style>
