<script setup lang="ts">
  import { AppInput, AppField, AppButton } from '@app/ui';
  import { ref, computed } from 'vue';

  import AuthShell from '../components/auth/AuthShell.vue';

  const { t } = useI18n({ useScope: 'local' });
  const auth = useAuth();

  const email = ref('');
  const password = ref('');
  const confirmPassword = ref('');
  const loading = ref(false);
  const errorMsg = ref('');

  const emailValid = computed(() => email.value.includes('@') && email.value.length >= 5);
  const passwordValid = computed(() => password.value.length >= 8);
  const confirmValid = computed(
    () => confirmPassword.value === password.value && confirmPassword.value.length > 0,
  );
  const formValid = computed(() => emailValid.value && passwordValid.value && confirmValid.value);

  async function onSignUp(): Promise<void> {
    errorMsg.value = '';
    if (!emailValid.value) {
      errorMsg.value = t('errorEmailInvalid');
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
      // Better Auth requires `name`. Derive from the email local-part as a
      // sensible default; the user can edit their displayName in /app/settings.
      const name = email.value.split('@')[0] ?? email.value;
      const result = await auth.signUp.email({
        email: email.value,
        password: password.value,
        name,
      });
      if (result.error) {
        const msg = result.error.message?.toLowerCase() ?? '';
        if (msg.includes('exist') || msg.includes('already')) {
          errorMsg.value = t('errorEmailTaken');
        } else if (msg.includes('password')) {
          errorMsg.value = t('errorPasswordWeak');
        } else {
          errorMsg.value = t('errorGeneric');
        }
        return;
      }
      // Better Auth `autoSignIn: true` (auth.service.ts) starts a session as
      // part of signUp; jump straight into the Bridge dashboard rather than
      // the public landing.
      globalThis.location.href = '/app/dashboard';
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
    "title": "Create account",
    "subtitle": "Sign up with email and a password.",
    "emailLabel": "Email",
    "emailHint": "We'll send a verification link.",
    "passwordLabel": "Password",
    "passwordHint": "At least 8 characters.",
    "confirmLabel": "Confirm password",
    "confirmHint": "Repeat your password.",
    "signUpButton": "Create account",
    "haveAccount": "Already have an account?",
    "signInLink": "Sign in",
    "legalFootnote": "By continuing, you agree to our Terms and Privacy Policy.",
    "errorEmailInvalid": "Please enter a valid email address.",
    "errorPasswordTooShort": "Password must be at least 8 characters.",
    "errorPasswordMismatch": "Passwords do not match.",
    "errorEmailTaken": "An account with this email already exists.",
    "errorPasswordWeak": "Password is too weak. Try a longer one.",
    "errorGeneric": "Something went wrong. Please try again."
  },
  "ru": {
    "title": "Создать аккаунт",
    "subtitle": "Зарегистрируйтесь по email и паролю.",
    "emailLabel": "Email",
    "emailHint": "Отправим ссылку для подтверждения.",
    "passwordLabel": "Пароль",
    "passwordHint": "Не менее 8 символов.",
    "confirmLabel": "Повторите пароль",
    "confirmHint": "Введите пароль ещё раз.",
    "signUpButton": "Создать аккаунт",
    "haveAccount": "Уже есть аккаунт?",
    "signInLink": "Войти",
    "legalFootnote": "Продолжая, вы соглашаетесь с условиями и политикой конфиденциальности.",
    "errorEmailInvalid": "Введите корректный email.",
    "errorPasswordTooShort": "Пароль должен содержать не менее 8 символов.",
    "errorPasswordMismatch": "Пароли не совпадают.",
    "errorEmailTaken": "Аккаунт с таким email уже существует.",
    "errorPasswordWeak": "Слишком слабый пароль. Используйте более длинный.",
    "errorGeneric": "Что-то пошло не так. Попробуйте ещё раз."
  }
}
</i18n>

<template>
  <AuthShell data-testid="page-signup" :title="t('title')" :subtitle="t('subtitle')">
    <p v-if="errorMsg" role="alert" class="auth-error">
      {{ errorMsg }}
    </p>

    <form class="auth-form" novalidate @submit.prevent="onSignUp">
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
        {{ t('signUpButton') }}
      </AppButton>
    </form>

    <p class="auth-links">
      {{ t('haveAccount') }}
      <NuxtLink to="/login" class="auth-link">
        {{ t('signInLink') }}
      </NuxtLink>
    </p>

    <p class="auth-legal">
      {{ t('legalFootnote') }}
    </p>
  </AuthShell>
</template>

<style lang="scss" scoped>
  @use '../assets/scss/auth-content';
</style>
