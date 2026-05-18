<script setup lang="ts">
  import { computed } from 'vue';
  import { AppArabesqueCorner, AppWordmark } from '@app/ui';

  const { t, locale, locales, setLocale } = useI18n({ useScope: 'local' });
  const auth = useAuth();

  // Already-authenticated visitors should never see the public landing —
  // bounce them straight to the Bridge dashboard. The app is SPA-only
  // (nuxt.config.ts ssr: false), so this only runs in the browser.
  try {
    const result = await auth.getSession();
    const data = result.data as { user?: { id?: string } } | null;
    if (data?.user?.id) {
      await navigateTo('/app/dashboard', { replace: true });
    }
  } catch {
    // Network/session failure — leave the visitor on the landing.
  }

  function onSignIn(): void {
    void navigateTo('/login');
  }

  function onCreateAccount(): void {
    void navigateTo('/signup');
  }

  // Locale switcher — three-dot brass row of `code` chips. The list is
  // sourced from the global Nuxt i18n config so adding a locale there
  // propagates here automatically.
  const localeOptions = computed(() =>
    (locales.value as { code: string; name?: string }[]).map((l) => ({
      code: l.code,
      label: l.name ?? l.code.toUpperCase(),
    })),
  );

  async function onLocaleChange(code: string): Promise<void> {
    await setLocale(code as 'en' | 'ru');
  }

  // Three-feature grid keys. Order matches the handoff: Sheet → Share → Run.
  const FEATURES = [
    { id: 'sheet', icon: '✦' },
    { id: 'share', icon: '☍' },
    { id: 'run', icon: '⚂' },
  ] as const;
</script>

<i18n lang="json">
{
  "en": {
    "tagline": "Your character sheet for the Third Horizon.",
    "signIn": "Sign in",
    "createAccount": "Create account",
    "localeSwitcherLabel": "Choose language",
    "feature": {
      "sheet": {
        "title": "Sheet",
        "blurb": "Create a character with rules-faithful step-by-step guidance — concept, role, attributes, skills, talents, the Nine Icons."
      },
      "share": {
        "title": "Share",
        "blurb": "Publish a read-only sheet to the table over a single short link. Revoke any time; rotation keeps stale screenshots stale."
      },
      "run": {
        "title": "Run",
        "blurb": "Roll dice, push the roll, track combat, manage Darkness Points — the wheel of the Horizon stays at your fingertips."
      }
    },
    "footer": {
      "fan": "An unofficial fan project for Coriolis: The Third Horizon. Not affiliated with Free League Publishing.",
      "ip": "Coriolis and all related marks belong to Fria Ligan / Free League Publishing."
    }
  },
  "ru": {
    "tagline": "Ваш лист персонажа для Третьего Горизонта.",
    "signIn": "Войти",
    "createAccount": "Создать аккаунт",
    "localeSwitcherLabel": "Выбор языка",
    "feature": {
      "sheet": {
        "title": "Лист",
        "blurb": "Создавайте персонажа по канону — амплуа, роль, характеристики, навыки, достоинства, Девять Икон."
      },
      "share": {
        "title": "Поделиться",
        "blurb": "Откройте лист для стола одной короткой ссылкой. Можно отозвать или повернуть — устаревшие скриншоты остаются устаревшими."
      },
      "run": {
        "title": "Игра",
        "blurb": "Бросайте кубики, пушьте бросок, ведите бой, считайте Очки Тьмы — Колесо Горизонта всегда под рукой."
      }
    },
    "footer": {
      "fan": "Неофициальный фан-проект по Coriolis: Третий Горизонт. Не аффилирован с Free League Publishing.",
      "ip": "Coriolis и связанные знаки принадлежат Fria Ligan / Free League Publishing."
    }
  }
}
</i18n>

<template>
  <div class="page-landing">
    <div class="page-landing__starfield" aria-hidden="true" />

    <AppArabesqueCorner
      orientation="tl"
      size="lg"
      color="brass-deep"
      class="page-landing__corner page-landing__corner--tl"
    />
    <AppArabesqueCorner
      orientation="tr"
      size="lg"
      color="brass-deep"
      class="page-landing__corner page-landing__corner--tr"
    />
    <AppArabesqueCorner
      orientation="bl"
      size="lg"
      color="brass-deep"
      class="page-landing__corner page-landing__corner--bl"
    />
    <AppArabesqueCorner
      orientation="br"
      size="lg"
      color="brass-deep"
      class="page-landing__corner page-landing__corner--br"
    />

    <header class="page-landing__topnav">
      <nav class="page-landing__locales" :aria-label="t('localeSwitcherLabel')">
        <button
          v-for="opt in localeOptions"
          :key="opt.code"
          type="button"
          class="page-landing__locale"
          :class="{ 'page-landing__locale--active': locale === opt.code }"
          :aria-current="locale === opt.code ? 'true' : undefined"
          @click="onLocaleChange(opt.code)"
        >
          {{ opt.code.toUpperCase() }}
        </button>
      </nav>
    </header>

    <main class="page-landing__main">
      <section class="page-landing__hero" aria-labelledby="landing-tagline">
        <AppWordmark :size="88" />
        <p id="landing-tagline" class="page-landing__tagline">
          {{ t('tagline') }}
        </p>

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
      </section>

      <section class="page-landing__features" aria-label="Features">
        <article v-for="f in FEATURES" :key="f.id" class="page-landing__feature">
          <span class="page-landing__feature-glyph" aria-hidden="true">{{ f.icon }}</span>
          <h2 class="page-landing__feature-title">
            {{ t(`feature.${f.id}.title`) }}
          </h2>
          <p class="page-landing__feature-blurb">
            {{ t(`feature.${f.id}.blurb`) }}
          </p>
        </article>
      </section>
    </main>

    <footer class="page-landing__footer">
      <p class="page-landing__footer-line">
        {{ t('footer.fan') }}
      </p>
      <p class="page-landing__footer-line page-landing__footer-line--muted">
        {{ t('footer.ip') }}
      </p>
    </footer>
  </div>
</template>

<style lang="scss" scoped>
  // Layout caps for the landing surface. Page-scoped, not part of the
  // shared spacing scale — Stylelint allows named SCSS variables for
  // layout caps (see stylelint.config.mjs declaration-property-value rule).
  $hero-max-width: 640px;
  $features-max-width: 1080px;
  $corner-inset: 16px;
  // Phone-shrunken corner ornament — lg (96px) is too dominant under 540px.
  $corner-mobile-size: 56px;
  // Mobile-scaled wordmark elements (CSS clamp() needs literal bounds).
  $wordmark-brand-mobile-clamp: clamp(40px, 12vw, 72px);
  $wordmark-eyebrow-mobile-clamp: clamp(10px, 2.4vw, 14px);
  $wordmark-swash-mobile-clamp: clamp(96px, 28vw, 180px);
  // Starfield density + cycle vars — tuned for ambience without distraction.
  $starfield-density: 240px;
  $starfield-twinkle: 8s;

  .page-landing {
    position: relative;
    flex: 1;
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    overflow: hidden;
    background-color: var(--surface-void);

    // ── Starfield ──────────────────────────────────────────────────────────────

    &__starfield {
      position: absolute;
      inset: 0;
      pointer-events: none;
      // Two-layer radial-gradient stipple — low-density bright pinpricks
      // over a denser dim layer. SCSS percentages stay literal because
      // they encode the star positions, not design tokens.
      background-image:
        radial-gradient(
          1.5px 1.5px at 20% 30%,
          color-mix(in srgb, var(--brand-brass-light) 80%, transparent),
          transparent 60%
        ),
        radial-gradient(
          1px 1px at 70% 60%,
          color-mix(in srgb, var(--brand-brass-light) 60%, transparent),
          transparent 60%
        ),
        radial-gradient(
          1px 1px at 40% 80%,
          color-mix(in srgb, var(--text-secondary) 50%, transparent),
          transparent 60%
        ),
        radial-gradient(
          0.5px 0.5px at 85% 25%,
          color-mix(in srgb, var(--text-secondary) 40%, transparent),
          transparent 60%
        );
      background-size: $starfield-density $starfield-density;
      animation: landing-twinkle $starfield-twinkle ease-in-out infinite alternate;

      @media (prefers-reduced-motion: reduce) {
        animation: none;
      }
    }

    // ── Arabesque corners ──────────────────────────────────────────────────────

    &__corner {
      position: absolute;
      pointer-events: none;
      z-index: var(--z-raised);

      &--tl {
        top: $corner-inset;
        left: $corner-inset;
      }

      &--tr {
        top: $corner-inset;
        right: $corner-inset;
      }

      &--bl {
        bottom: $corner-inset;
        left: $corner-inset;
      }

      &--br {
        bottom: $corner-inset;
        right: $corner-inset;
      }

      // Scale the lg (96px) ornament down on phones so the corners stay
      // decorative instead of devouring half of each side.
      @media (max-width: 540px) {
        :deep(.app-arabesque-corner) {
          width: $corner-mobile-size;
          height: $corner-mobile-size;
        }

        :deep(.app-arabesque-corner__svg) {
          width: $corner-mobile-size;
          height: $corner-mobile-size;
        }
      }
    }

    // ── Top nav ────────────────────────────────────────────────────────────────

    &__topnav {
      position: relative;
      z-index: var(--z-raised);
      display: flex;
      justify-content: flex-end;
      padding: var(--space-5) var(--space-7) 0;

      @media (max-width: 540px) {
        // Centre the locale pill on phones; right-justified it collides
        // with the top-right arabesque corner.
        justify-content: center;
        padding: var(--space-4) var(--space-3) 0;
      }
    }

    &__locales {
      display: inline-flex;
      gap: var(--space-1);
      padding: var(--space-1) var(--space-2);
      background: color-mix(in srgb, var(--surface-night) 70%, transparent);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-pill);
    }

    &__locale {
      cursor: pointer;
      padding: var(--space-1) var(--space-3);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      font-weight: 600;
      letter-spacing: 0.08em;
      color: var(--text-secondary);
      background: transparent;
      border: none;
      border-radius: var(--radius-pill);
      transition:
        color var(--motion-duration-fast) var(--motion-ease-standard),
        background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        color: var(--brand-brass-light);
        background: color-mix(in srgb, var(--brand-brass) 8%, transparent);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      &--active {
        color: var(--brand-brass-light);
        background: color-mix(in srgb, var(--brand-brass) 12%, transparent);
      }
    }

    // ── Main column ────────────────────────────────────────────────────────────

    &__main {
      position: relative;
      z-index: var(--z-raised);
      flex: 1;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: var(--space-10);
      padding: var(--space-9) var(--space-7);

      @media (max-width: 768px) {
        gap: var(--space-7);
        padding: var(--space-7) var(--space-4);
      }

      @media (max-width: 420px) {
        gap: var(--space-6);
        padding: var(--space-6) var(--space-3);
      }
    }

    &__hero {
      width: 100%;
      max-width: $hero-max-width;
      text-align: center;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-6);
    }

    // AppWordmark renders at a fixed pixel size (88 for landing hero).
    // On narrow viewports the canonical "CORIOLIS" wordmark + 0.1em tracking
    // overflows the screen — scale the inner brand text down via :deep()
    // overrides so the lockup always fits without touching the shared
    // component contract.
    @media (max-width: 540px) {
      :deep(.app-wordmark__brand) {
        font-size: $wordmark-brand-mobile-clamp;
      }

      :deep(.app-wordmark__eyebrow) {
        font-size: $wordmark-eyebrow-mobile-clamp;
      }

      :deep(.app-wordmark__swash) svg {
        width: $wordmark-swash-mobile-clamp;
        height: auto;
      }
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

    // ── Three-feature grid ─────────────────────────────────────────────────────

    &__features {
      width: 100%;
      max-width: $features-max-width;
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: var(--space-6);

      @media (max-width: 720px) {
        grid-template-columns: 1fr;
      }
    }

    &__feature {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
      padding: var(--space-6) var(--space-5);
      background: color-mix(in srgb, var(--surface-night) 60%, transparent);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-lg);
      transition: border-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        border-color: var(--brand-brass-deep);
      }
    }

    &__feature-glyph {
      font-family: var(--font-display);
      font-size: var(--type-display-md-font-size);
      color: var(--brand-brass);
      line-height: 1;
    }

    &__feature-title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      letter-spacing: 0.06em;
      color: var(--brand-brass-light);
      text-transform: uppercase;
    }

    &__feature-blurb {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      line-height: var(--type-body-md-line-height);
      color: var(--text-secondary);
    }

    // ── Footer ─────────────────────────────────────────────────────────────────

    &__footer {
      position: relative;
      z-index: var(--z-raised);
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-1);
      padding: var(--space-6) var(--space-7);
      text-align: center;
    }

    &__footer-line {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);

      &--muted {
        color: color-mix(in srgb, var(--text-secondary) 60%, transparent);
      }
    }
  }

  // Starfield twinkle — slow opacity drift, suppressed under reduced motion
  // (handled inline on `&__starfield`).
  @keyframes landing-twinkle {
    from {
      opacity: 0.55;
    }

    to {
      opacity: 1;
    }
  }
</style>
