<script setup lang="ts">
  import { AppInput, AppField, AppButton } from '@app/ui';
  import { ref, computed } from 'vue';

  import AuthShell from '../components/auth/AuthShell.vue';

  const { t } = useI18n({ useScope: 'local' });
  const auth = useAuth();
  const route = useRoute();

  const email = ref('');
  const password = ref('');
  const loading = ref(false);
  const errorMsg = ref('');

  const emailValid = computed(() => email.value.includes('@') && email.value.length >= 5);
  const passwordValid = computed(() => password.value.length >= 8);
  const formValid = computed(() => emailValid.value && passwordValid.value);

  async function onSignIn(): Promise<void> {
    errorMsg.value = '';
    if (!emailValid.value) {
      errorMsg.value = t('errorEmailInvalid');
      return;
    }
    if (!passwordValid.value) {
      errorMsg.value = t('errorPasswordTooShort');
      return;
    }
    loading.value = true;
    try {
      const result = await auth.signIn.email({ email: email.value, password: password.value });
      if (result.error) {
        const msg = result.error.message?.toLowerCase() ?? '';
        errorMsg.value =
          msg.includes('invalid') || msg.includes('credential') || msg.includes('password')
            ? t('errorCredentials')
            : t('errorGeneric');
        return;
      }
      // Honour `?redirect=` set by auth-required middleware; fall back to the
      // Bridge dashboard (the authenticated home as of T-2026-05-14-004).
      // Plain `/` would land on the public landing page and look like
      // sign-in failed.
      const raw = route.query.redirect;
      const target = typeof raw === 'string' && raw.startsWith('/') ? raw : '/app/dashboard';
      globalThis.location.href = target;
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
    "title": "Sign in",
    "subtitle": "Enter your email and password to continue.",
    "emailLabel": "Email",
    "emailHint": "Your registered email address.",
    "passwordLabel": "Password",
    "passwordHint": "At least 8 characters.",
    "signInButton": "Sign in",
    "forgotLink": "Forgot password?",
    "noAccount": "Don't have an account?",
    "signUpLink": "Sign up",
    "legalFootnote": "By continuing, you agree to our Terms and Privacy Policy.",
    "errorEmailInvalid": "Please enter a valid email address.",
    "errorPasswordTooShort": "Password must be at least 8 characters.",
    "errorCredentials": "Incorrect email or password. Please try again.",
    "errorGeneric": "Something went wrong. Please try again."
  },
  "ru": {
    "title": "Войти",
    "subtitle": "Введите email и пароль для входа.",
    "emailLabel": "Email",
    "emailHint": "Ваш зарегистрированный email.",
    "passwordLabel": "Пароль",
    "passwordHint": "Не менее 8 символов.",
    "signInButton": "Войти",
    "forgotLink": "Забыли пароль?",
    "noAccount": "Нет аккаунта?",
    "signUpLink": "Зарегистрироваться",
    "legalFootnote": "Продолжая, вы соглашаетесь с условиями и политикой конфиденциальности.",
    "errorEmailInvalid": "Введите корректный email.",
    "errorPasswordTooShort": "Пароль должен содержать не менее 8 символов.",
    "errorCredentials": "Неверный email или пароль. Попробуйте ещё раз.",
    "errorGeneric": "Что-то пошло не так. Попробуйте ещё раз."
  }
}
</i18n>

<template>
  <AuthShell data-testid="page-login" :title="t('title')" :subtitle="t('subtitle')">
    <p v-if="errorMsg" role="alert" class="auth-error">
      {{ errorMsg }}
    </p>

    <form class="auth-form" novalidate @submit.prevent="onSignIn">
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
            autocomplete="current-password"
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
        {{ t('signInButton') }}
      </AppButton>
    </form>

    <p class="auth-links auth-links--tight">
      <NuxtLink to="/forgot-password" class="auth-link">
        {{ t('forgotLink') }}
      </NuxtLink>
    </p>

    <p class="auth-links">
      {{ t('noAccount') }}
      <NuxtLink to="/signup" class="auth-link">
        {{ t('signUpLink') }}
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
