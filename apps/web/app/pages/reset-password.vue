<script setup lang="ts">
  import { AppInput, AppField, AppButton } from '@app/ui';
  import { ref, computed, onMounted } from 'vue';

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
    "wordmark": "Coriolis Companion",
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
    "wordmark": "Coriolis Companion",
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
  },
  "uk": {
    "wordmark": "Coriolis Companion",
    "title": "[uk-todo] Set new password",
    "subtitle": "[uk-todo] Choose a new password",
    "passwordLabel": "[uk-todo] New password",
    "passwordHint": "[uk-todo] At least 8 characters",
    "confirmLabel": "[uk-todo] Confirm new password",
    "confirmHint": "[uk-todo] Repeat the password",
    "submitButton": "[uk-todo] Set password",
    "successBody": "[uk-todo] Password updated, redirecting…",
    "tokenMissingTitle": "[uk-todo] Reset link incomplete",
    "tokenMissingBody": "[uk-todo] Re-open from email or request new",
    "requestNew": "[uk-todo] Request a new link",
    "errorTokenMissing": "[uk-todo] Token missing",
    "errorTokenInvalid": "[uk-todo] Token invalid or expired",
    "errorPasswordTooShort": "[uk-todo] Password too short",
    "errorPasswordMismatch": "[uk-todo] Passwords do not match",
    "errorPasswordWeak": "[uk-todo] Password too weak",
    "errorGeneric": "[uk-todo] Generic error"
  },
  "el": {
    "wordmark": "Coriolis Companion",
    "title": "[el-todo] Set new password",
    "subtitle": "[el-todo] Choose a new password",
    "passwordLabel": "[el-todo] New password",
    "passwordHint": "[el-todo] At least 8 characters",
    "confirmLabel": "[el-todo] Confirm new password",
    "confirmHint": "[el-todo] Repeat the password",
    "submitButton": "[el-todo] Set password",
    "successBody": "[el-todo] Password updated, redirecting…",
    "tokenMissingTitle": "[el-todo] Reset link incomplete",
    "tokenMissingBody": "[el-todo] Re-open from email or request new",
    "requestNew": "[el-todo] Request a new link",
    "errorTokenMissing": "[el-todo] Token missing",
    "errorTokenInvalid": "[el-todo] Token invalid or expired",
    "errorPasswordTooShort": "[el-todo] Password too short",
    "errorPasswordMismatch": "[el-todo] Passwords do not match",
    "errorPasswordWeak": "[el-todo] Password too weak",
    "errorGeneric": "[el-todo] Generic error"
  }
}
</i18n>

<template>
  <div
    class="page-reset"
    data-testid="page-reset"
  >
    <div class="page-reset__shell">
      <h1 class="page-reset__wordmark">
        {{ t('wordmark') }}
      </h1>

      <div class="page-reset__card">
        <div class="page-reset__header">
          <h2 class="page-reset__title">
            {{ t('title') }}
          </h2>
          <p class="page-reset__subtitle">
            {{ t('subtitle') }}
          </p>
        </div>

        <p
          v-if="errorMsg"
          role="alert"
          class="page-reset__error"
        >
          {{ errorMsg }}
        </p>

        <p
          v-if="successMsg"
          role="status"
          class="page-reset__success"
        >
          {{ successMsg }}
        </p>

        <div
          v-if="!tokenPresent"
          class="page-reset__token-missing"
          role="alert"
          data-testid="page-reset-token-missing"
        >
          <p class="page-reset__token-missing-title">
            {{ t('tokenMissingTitle') }}
          </p>
          <p class="page-reset__token-missing-body">
            {{ t('tokenMissingBody') }}
          </p>
          <NuxtLink
            to="/forgot-password"
            class="page-reset__link"
          >
            {{ t('requestNew') }}
          </NuxtLink>
        </div>

        <form
          v-else-if="!successMsg"
          class="page-reset__form"
          novalidate
          @submit.prevent="onSubmit"
        >
          <AppField
            :label="t('passwordLabel')"
            :help="t('passwordHint')"
            required
          >
            <template #default="slotAttrs">
              <AppInput
                v-bind="slotAttrs"
                v-model="password"
                type="password"
                autocomplete="new-password"
              />
            </template>
          </AppField>

          <AppField
            :label="t('confirmLabel')"
            :help="t('confirmHint')"
            required
          >
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
            class="page-reset__submit"
            :loading="loading"
            :disabled="loading || !formValid"
          >
            {{ t('submitButton') }}
          </AppButton>
        </form>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  // Page-scoped layout cap. Mirrors `login.vue` and `forgot-password.vue`
  // — see done.md note on T-2026-05-09-004 for the auth-surface proportions.
  $card-max-width: 480px;

  .page-reset {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-9) var(--space-6);
    background: var(--surface-bg);

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
      margin: 0 0 var(--space-4);
      padding: var(--space-3) var(--space-4);
      border-radius: var(--radius-md);
      background: var(--status-success-soft);
      color: var(--status-success);
      font-size: var(--text-sm);
    }

    &__token-missing {
      padding: var(--space-4);
      border-radius: var(--radius-md);
      background: var(--status-warning-soft);
      color: var(--status-warning);
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__token-missing-title {
      margin: 0;
      font-size: var(--text-base);
      font-weight: var(--fw-bold);
    }

    &__token-missing-body {
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

    &__link {
      color: var(--brand-accent);
      text-decoration: none;

      &:hover {
        text-decoration: underline;
      }
    }
  }
</style>
