<script setup lang="ts">
  import { AppInput, AppField, AppButton } from '@app/ui';
  import { ref, computed } from 'vue';

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
    "wordmark": "Coriolis Companion",
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
    "wordmark": "Coriolis Companion",
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
  },
  "uk": {
    "wordmark": "Coriolis Companion",
    "title": "[uk-todo] Sign in",
    "subtitle": "[uk-todo] Enter email and password",
    "emailLabel": "[uk-todo] Email",
    "emailHint": "[uk-todo] Email hint",
    "passwordLabel": "[uk-todo] Password",
    "passwordHint": "[uk-todo] Password hint",
    "signInButton": "[uk-todo] Sign in",
    "forgotLink": "[uk-todo] Forgot password",
    "noAccount": "[uk-todo] No account",
    "signUpLink": "[uk-todo] Sign up",
    "legalFootnote": "[uk-todo] Legal",
    "errorEmailInvalid": "[uk-todo] Invalid email",
    "errorPasswordTooShort": "[uk-todo] Password too short",
    "errorCredentials": "[uk-todo] Bad credentials",
    "errorGeneric": "[uk-todo] Generic error"
  },
  "el": {
    "wordmark": "Coriolis Companion",
    "title": "[el-todo] Sign in",
    "subtitle": "[el-todo] Enter email and password",
    "emailLabel": "[el-todo] Email",
    "emailHint": "[el-todo] Email hint",
    "passwordLabel": "[el-todo] Password",
    "passwordHint": "[el-todo] Password hint",
    "signInButton": "[el-todo] Sign in",
    "forgotLink": "[el-todo] Forgot password",
    "noAccount": "[el-todo] No account",
    "signUpLink": "[el-todo] Sign up",
    "legalFootnote": "[el-todo] Legal",
    "errorEmailInvalid": "[el-todo] Invalid email",
    "errorPasswordTooShort": "[el-todo] Password too short",
    "errorCredentials": "[el-todo] Bad credentials",
    "errorGeneric": "[el-todo] Generic error"
  }
}
</i18n>

<template>
  <div class="page-login" data-testid="page-login">
    <div class="page-login__shell">
      <h1 class="page-login__wordmark">
        {{ t('wordmark') }}
      </h1>

      <div class="page-login__card">
        <div class="page-login__header">
          <h2 class="page-login__title">
            {{ t('title') }}
          </h2>
          <p class="page-login__subtitle">
            {{ t('subtitle') }}
          </p>
        </div>

        <p v-if="errorMsg" role="alert" class="page-login__error">
          {{ errorMsg }}
        </p>

        <form class="page-login__form" novalidate @submit.prevent="onSignIn">
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

          <AppField :label="t('passwordLabel')" :help="t('passwordHint')" required>
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
            class="page-login__submit"
            :loading="loading"
            :disabled="loading || !formValid"
          >
            {{ t('signInButton') }}
          </AppButton>
        </form>

        <p class="page-login__footnote-link page-login__footnote-link--forgot">
          <NuxtLink to="/forgot-password" class="page-login__link">
            {{ t('forgotLink') }}
          </NuxtLink>
        </p>

        <p class="page-login__footnote-link">
          {{ t('noAccount') }}
          <NuxtLink to="/signup" class="page-login__link">
            {{ t('signUpLink') }}
          </NuxtLink>
        </p>

        <p class="page-login__legal">
          {{ t('legalFootnote') }}
        </p>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
  // Page-scoped layout cap. Boilerplate left-over — proper restyling against
  // Coriolis tokens lands in Phase 1 Epic 4 auth-vertical extensions.
  $card-max-width: 480px;

  .page-login {
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

      // Place the standalone "Forgot password?" link tight under the
      // submit button, then leave the wider gap before "Don't have an
      // account?". Two stacked links read as one block instead of two.
      &--forgot {
        margin-top: var(--space-3);
      }
    }

    &__link {
      color: var(--brand-accent);
      text-decoration: none;

      &:hover {
        text-decoration: underline;
      }
    }

    &__legal {
      margin: var(--space-3) 0 0;
      font-size: var(--text-xs);
      color: var(--text-fg-subtle);
      text-align: center;
    }
  }
</style>
