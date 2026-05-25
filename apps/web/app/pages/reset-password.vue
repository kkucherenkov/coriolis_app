<script setup lang="ts">
  import { AppInput, AppField, AppButton } from '@app/ui';
  import { ref, computed, onMounted } from 'vue';

  import AuthShell from '../components/auth/AuthShell.vue';

  const { t } = useI18n({ useScope: 'local' });
  const auth = useAuth();
  const route = useRoute();

  const password = ref('');
  const confirmPassword = ref('');
  const loading = ref(false);
  const errorMsg = ref('');
  const successMsg = ref('');
  const token = ref('');

  // BA forwards the reset token as `?token=...` on the redirect that lands
  // here from the email link. Capture it once on mount — the user's
  // browser may strip the query string before submit otherwise.
  onMounted(() => {
    const raw = route.query.token;
    if (typeof raw === 'string' && raw.length > 0) {
      token.value = raw;
    }
  });

  const tokenPresent = computed(() => token.value.length > 0);
  const passwordValid = computed(() => password.value.length >= 8);
  const confirmValid = computed(
    () => confirmPassword.value === password.value && confirmPassword.value.length > 0,
  );
  const formValid = computed(() => tokenPresent.value && passwordValid.value && confirmValid.value);

  async function onSubmit(): Promise<void> {
    errorMsg.value = '';
    if (!tokenPresent.value) {
      errorMsg.value = t('errorTokenMissing');
      return;
    }
    if (!passwordValid.value) {
      errorMsg.value = t('errorPasswordTooShort');
      return;
    }
    if (!confirmValid.value) {
      errorMsg.value = t('errorPasswordMismatch');
      return;
    }
    loading.value = true;
    try {
      const result = await auth.resetPassword({
        newPassword: password.value,
        token: token.value,
      });
      if (result.error) {
        const msg = result.error.message?.toLowerCase() ?? '';
        if (msg.includes('expired') || msg.includes('invalid')) {
          errorMsg.value = t('errorTokenInvalid');
        } else if (msg.includes('password')) {
          errorMsg.value = t('errorPasswordWeak');
        } else {
          errorMsg.value = t('errorGeneric');
        }
        return;
      }
      successMsg.value = t('successBody');
      // Better Auth invalidates the token on successful reset, so the
      // user has to sign in fresh — bounce them after a short pause that
      // lets them read the success message.
      globalThis.setTimeout(() => {
        globalThis.location.href = '/login';
      }, 1500);
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
    "title": "Set new password",
    "subtitle": "Choose a new password to regain access to your account.",
    "passwordLabel": "New password",
    "passwordHint": "At least 8 characters.",
    "confirmLabel": "Confirm new password",
    "confirmHint": "Repeat the password.",
    "submitButton": "Set password",
    "successBody": "Password updated. Redirecting to sign-in…",
    "tokenMissingTitle": "Reset link incomplete",
    "tokenMissingBody": "This page expects a reset token in the URL. Re-open the link from your reset email, or request a new one.",
    "requestNew": "Request a new link",
    "errorTokenMissing": "Reset token is missing from the URL.",
    "errorTokenInvalid": "Reset link is invalid or has expired. Please request a new one.",
    "errorPasswordTooShort": "Password must be at least 8 characters.",
    "errorPasswordMismatch": "Passwords do not match.",
    "errorPasswordWeak": "Password is too weak. Try a longer one.",
    "errorGeneric": "Something went wrong. Please try again."
  },
  "ru": {
    "title": "Новый пароль",
    "subtitle": "Задайте новый пароль, чтобы восстановить доступ к аккаунту.",
    "passwordLabel": "Новый пароль",
    "passwordHint": "Не менее 8 символов.",
    "confirmLabel": "Повторите пароль",
    "confirmHint": "Введите пароль ещё раз.",
    "submitButton": "Сохранить пароль",
    "successBody": "Пароль обновлён. Перенаправляем на страницу входа…",
    "tokenMissingTitle": "Ссылка для сброса неполная",
    "tokenMissingBody": "На этой странице должен быть токен сброса. Откройте ссылку из письма ещё раз или запросите новую.",
    "requestNew": "Запросить новую ссылку",
    "errorTokenMissing": "В ссылке отсутствует токен сброса.",
    "errorTokenInvalid": "Ссылка для сброса недействительна или истекла. Запросите новую.",
    "errorPasswordTooShort": "Пароль должен содержать не менее 8 символов.",
    "errorPasswordMismatch": "Пароли не совпадают.",
    "errorPasswordWeak": "Слишком слабый пароль. Используйте более длинный.",
    "errorGeneric": "Что-то пошло не так. Попробуйте ещё раз."
  }
}
</i18n>

<template>
  <AuthShell data-testid="page-reset" :title="t('title')" :subtitle="t('subtitle')">
    <p v-if="errorMsg" role="alert" class="auth-error">
      {{ errorMsg }}
    </p>

    <p v-if="successMsg" role="status" class="auth-success">
      {{ successMsg }}
    </p>

    <div
      v-if="!tokenPresent"
      class="auth-note auth-note--danger"
      role="alert"
      data-testid="page-reset-token-missing"
    >
      <p class="auth-note__title">
        {{ t('tokenMissingTitle') }}
      </p>
      <p class="auth-note__body">
        {{ t('tokenMissingBody') }}
      </p>
      <NuxtLink to="/forgot-password" class="auth-link">
        {{ t('requestNew') }}
      </NuxtLink>
    </div>

    <form v-else-if="!successMsg" class="auth-form" novalidate @submit.prevent="onSubmit">
      <AppField :label="t('passwordLabel')" :help-text="t('passwordHint')" required>
        <template #default="slotAttrs">
          <AppInput
            v-bind="slotAttrs"
            v-model="password"
            type="password"
            autocomplete="new-password"
          />
        </template>
      </AppField>

      <AppField :label="t('confirmLabel')" :help-text="t('confirmHint')" required>
        <template #default="slotAttrs">
          <AppInput
            v-bind="slotAttrs"
            v-model="confirmPassword"
            type="password"
            autocomplete="new-password"
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
  </AuthShell>
</template>

<style lang="scss" scoped>
  @use '../assets/scss/auth-content';
</style>
