<script setup lang="ts">
  import { AppInput, AppField, AppButton } from '@app/ui';
  import { ref, computed } from 'vue';

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
      // part of signUp; jump straight into the authenticated home rather than
      // the public landing.
      globalThis.location.href = '/app/characters';
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
    "wordmark": "Coriolis Companion",
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
  },
  "uk": {
    "wordmark": "Coriolis Companion",
    "title": "[uk-todo] Create account",
    "subtitle": "[uk-todo] Sign up with email and password",
    "emailLabel": "[uk-todo] Email",
    "emailHint": "[uk-todo] Email hint",
    "passwordLabel": "[uk-todo] Password",
    "passwordHint": "[uk-todo] Password hint",
    "confirmLabel": "[uk-todo] Confirm password",
    "confirmHint": "[uk-todo] Confirm hint",
    "signUpButton": "[uk-todo] Create account",
    "haveAccount": "[uk-todo] Have account",
    "signInLink": "[uk-todo] Sign in",
    "legalFootnote": "[uk-todo] Legal",
    "errorEmailInvalid": "[uk-todo] Invalid email",
    "errorPasswordTooShort": "[uk-todo] Password too short",
    "errorPasswordMismatch": "[uk-todo] Passwords mismatch",
    "errorEmailTaken": "[uk-todo] Email taken",
    "errorPasswordWeak": "[uk-todo] Password weak",
    "errorGeneric": "[uk-todo] Generic error"
  },
  "el": {
    "wordmark": "Coriolis Companion",
    "title": "[el-todo] Create account",
    "subtitle": "[el-todo] Sign up with email and password",
    "emailLabel": "[el-todo] Email",
    "emailHint": "[el-todo] Email hint",
    "passwordLabel": "[el-todo] Password",
    "passwordHint": "[el-todo] Password hint",
    "confirmLabel": "[el-todo] Confirm password",
    "confirmHint": "[el-todo] Confirm hint",
    "signUpButton": "[el-todo] Create account",
    "haveAccount": "[el-todo] Have account",
    "signInLink": "[el-todo] Sign in",
    "legalFootnote": "[el-todo] Legal",
    "errorEmailInvalid": "[el-todo] Invalid email",
    "errorPasswordTooShort": "[el-todo] Password too short",
    "errorPasswordMismatch": "[el-todo] Passwords mismatch",
    "errorEmailTaken": "[el-todo] Email taken",
    "errorPasswordWeak": "[el-todo] Password weak",
    "errorGeneric": "[el-todo] Generic error"
  }
}
</i18n>

<template>
  <div
    class="page-signup"
    data-testid="page-signup"
  >
    <div class="page-signup__shell">
      <h1 class="page-signup__wordmark">
        {{ t('wordmark') }}
      </h1>

      <div class="page-signup__card">
        <div class="page-signup__header">
          <h2 class="page-signup__title">
            {{ t('title') }}
          </h2>
          <p class="page-signup__subtitle">
            {{ t('subtitle') }}
          </p>
        </div>

        <p
          v-if="errorMsg"
          role="alert"
          class="page-signup__error"
        >
          {{ errorMsg }}
        </p>

        <form
          class="page-signup__form"
          novalidate
          @submit.prevent="onSignUp"
        >
          <AppField
            :label="t('emailLabel')"
            :help="t('emailHint')"
            required
          >
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
            class="page-signup__submit"
            :loading="loading"
            :disabled="loading || !formValid"
          >
            {{ t('signUpButton') }}
          </AppButton>
        </form>

        <p class="page-signup__footnote-link">
          {{ t('haveAccount') }}
          <NuxtLink
            to="/login"
            class="page-signup__link"
          >
            {{ t('signInLink') }}
          </NuxtLink>
        </p>

        <p class="page-signup__legal">
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

  .page-signup {
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
