<script setup lang="ts">
  import { AppInput, AppField, AppButton } from '@app/ui';
  import { ref, computed } from 'vue';

  import AuthShell from '../components/auth/AuthShell.vue';

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
  <AuthShell data-testid="page-forgot" :title="t('title')" :subtitle="t('subtitle')">
    <p v-if="errorMsg" role="alert" class="auth-error">
      {{ errorMsg }}
    </p>

    <div
      v-if="submitted"
      class="auth-note auth-note--success"
      role="status"
      data-testid="page-forgot-success"
    >
      <p class="auth-note__title">
        {{ t('successTitle') }}
      </p>
      <p class="auth-note__body">
        {{ t('successBody') }}
      </p>
    </div>

    <form v-else class="auth-form" novalidate @submit.prevent="onSubmit">
      <AppField :label="t('emailLabel')" :help-text="t('emailHint')" required>
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
        class="auth-submit"
        :loading="loading"
        :disabled="loading || !formValid"
      >
        {{ t('submitButton') }}
      </AppButton>
    </form>

    <p class="auth-links">
      <NuxtLink to="/login" class="auth-link">
        {{ t('backToSignIn') }}
      </NuxtLink>
    </p>
  </AuthShell>
</template>

<style lang="scss" scoped>
  @use '../assets/scss/auth-content';
</style>
