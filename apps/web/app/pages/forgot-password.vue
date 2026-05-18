<script setup lang="ts">
  import { AppInput, AppField, AppButton } from '@app/ui';
  import { ref, computed } from 'vue';

  const { t } = useI18n({ useScope: 'local' });
  const auth = useAuth();

  const email = ref('');
  const loading = ref(false);
  const submitted = ref(false);
  const errorMsg = ref('');

  const emailValid = computed(() => email.value.includes('@') && email.value.length >= 5);
  const formValid = computed(() => emailValid.value);

  async function onSubmit(): Promise<void> {
    errorMsg.value = '';
    if (!emailValid.value) {
      errorMsg.value = t('errorEmailInvalid');
      return;
    }
    loading.value = true;
    try {
      // Better Auth's email link bounces through the backend reset endpoint
      // before redirecting the browser back to this `redirectTo` URL with the
      // token still in the query string. The SPA picks it up on the
      // /reset-password page and finishes the flow with `auth.resetPassword`.
      const redirectTo = `${globalThis.location.origin}/reset-password`;
      const result = await auth.requestPasswordReset({ email: email.value, redirectTo });
      if (result.error) {
        // Don't leak whether the email is registered — Better Auth returns
        // 200 for unknown emails by design, so any error here is a server
        // problem rather than a "no such account" signal.
        errorMsg.value = t('errorGeneric');
        return;
      }
      submitted.value = true;
    } catch {
      errorMsg.value = t('errorGeneric');
    } finally {
      loading.value = false;
    }
  }
</script>

<i18n lang="json">
{
  "en": {
    "wordmark": "Coriolis Companion",
    "title": "Reset password",
    "subtitle": "Enter your email and we'll send a reset link.",
    "emailLabel": "Email",
    "emailHint": "Where to send the reset link.",
    "submitButton": "Send reset link",
    "successTitle": "Check your inbox",
    "successBody": "If an account exists for that email, a reset link is on its way. The link expires in 1 hour.",
    "backToSignIn": "Back to sign in",
    "errorEmailInvalid": "Please enter a valid email address.",
    "errorGeneric": "Something went wrong. Please try again."
  },
  "ru": {
    "wordmark": "Coriolis Companion",
    "title": "Восстановление пароля",
    "subtitle": "Введите email — мы отправим ссылку для сброса пароля.",
    "emailLabel": "Email",
    "emailHint": "Куда отправить ссылку для сброса.",
    "submitButton": "Отправить ссылку",
    "successTitle": "Проверьте почту",
    "successBody": "Если аккаунт с таким email существует, ссылка для сброса уже в пути. Срок действия ссылки — 1 час.",
    "backToSignIn": "Вернуться ко входу",
    "errorEmailInvalid": "Введите корректный email.",
    "errorGeneric": "Что-то пошло не так. Попробуйте ещё раз."
  }
}
</i18n>

<template>
  <div class="page-forgot" data-testid="page-forgot">
    <div class="page-forgot__shell">
      <h1 class="page-forgot__wordmark">
        {{ t('wordmark') }}
      </h1>

      <div class="page-forgot__card">
        <div class="page-forgot__header">
          <h2 class="page-forgot__title">
            {{ t('title') }}
          </h2>
          <p class="page-forgot__subtitle">
            {{ t('subtitle') }}
          </p>
        </div>

        <p v-if="errorMsg" role="alert" class="page-forgot__error">
          {{ errorMsg }}
        </p>

        <div
          v-if="submitted"
          class="page-forgot__success"
          role="status"
          data-testid="page-forgot-success"
        >
          <p class="page-forgot__success-title">
            {{ t('successTitle') }}
          </p>
          <p class="page-forgot__success-body">
            {{ t('successBody') }}
          </p>
        </div>

        <form v-else class="page-forgot__form" novalidate @submit.prevent="onSubmit">
          <AppField :label="t('emailLabel')" :help="t('emailHint')" required>
            <template #default="slotAttrs">
              <AppInput
                v-bind="slotAttrs"
                v-model="email"
                type="email"
                autocomplete="email"
                inputmode="email"
                placeholder="user@example.com"
              />
            </template>
          </AppField>

          <AppButton
            type="submit"
            variant="primary"
            class="page-forgot__submit"
            :loading="loading"
            :disabled="loading || !formValid"
          >
            {{ t('submitButton') }}
          </AppButton>
        </form>

        <p class="page-forgot__footnote-link">
          <NuxtLink to="/login" class="page-forgot__link">
            {{ t('backToSignIn') }}
          </NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  // Page-scoped layout cap. Mirrors `login.vue` so the auth surfaces share
  // the same proportions — see done.md note on T-2026-05-09-004.
  $card-max-width: 480px;

  .page-forgot {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-9) var(--space-6);
    background: var(--surface-bg);

    @media (max-width: 540px) {
      padding: var(--space-5) 0;
    }

    &__shell {
      width: 100%;
      max-width: $card-max-width;
      display: flex;
      flex-direction: column;
      align-items: stretch;
      gap: var(--space-6);
    }

    &__wordmark {
      margin: 0;
      text-align: center;
      font-family: var(--font-display);
      font-size: var(--type-display-md-font-size);
      line-height: var(--type-display-md-line-height);
      font-weight: var(--type-display-md-font-weight);
      letter-spacing: var(--type-display-md-letter-spacing);
      text-transform: uppercase;
      color: var(--brand-brass-light);
    }

    &__card {
      background: var(--surface-surface);
      border: 1px solid var(--border-default);
      border-radius: var(--radius-xl);
      padding: var(--space-10) var(--space-9);
      box-shadow: var(--shadow-md);

      @media (max-width: 540px) {
        padding: var(--space-7) var(--space-5);
      }
    }

    &__header {
      margin-bottom: var(--space-6);
    }

    &__title {
      margin: 0 0 var(--space-2);
      font-size: var(--text-2xl);
      font-weight: var(--fw-bold);
      letter-spacing: var(--tracking-tight);
      color: var(--text-fg);
    }

    &__subtitle {
      margin: 0;
      font-size: var(--text-sm);
      color: var(--text-fg-muted);
    }

    &__error {
      margin: 0 0 var(--space-4);
      padding: var(--space-3) var(--space-4);
      border-radius: var(--radius-md);
      background: var(--status-danger-soft);
      color: var(--status-danger);
      font-size: var(--text-sm);
    }

    &__success {
      padding: var(--space-4);
      border-radius: var(--radius-md);
      background: var(--status-success-soft);
      color: var(--status-success);
    }

    &__success-title {
      margin: 0 0 var(--space-2);
      font-size: var(--text-base);
      font-weight: var(--fw-bold);
    }

    &__success-body {
      margin: 0;
      font-size: var(--text-sm);
    }

    &__form {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
    }

    &__submit {
      width: 100%;
    }

    &__footnote-link {
      margin: var(--space-5) 0 0;
      font-size: var(--text-sm);
      color: var(--text-fg-muted);
      text-align: center;
    }

    &__link {
      color: var(--brand-accent);
      text-decoration: none;

      &:hover {
        text-decoration: underline;
      }
    }
  }
</style>
