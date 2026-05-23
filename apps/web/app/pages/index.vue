<script setup lang="ts">
  import { computed } from 'vue';
  import {
    AppArabesqueCorner,
    AppButton,
    AppDie,
    AppIconCoriolis,
    AppStarOrnament,
    AppWordmark,
  } from '@app/ui';
  // Real product screenshots (docs/screenshots), bundled + hashed by Vite.
  // Desktop drives the showcase; the phone capture swaps in under 720px so
  // small viewports see the mobile layout rather than a shrunk desktop one.
  import sheetDesktop from '~/assets/showcase/character-sheet-desktop.png';
  import sheetMobile from '~/assets/showcase/character-sheet-mobile.png';

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
</script>

<i18n lang="json">
{
  "en": {
    "tagline": "Your character sheet for the Third Horizon.",
    "signIn": "Sign in",
    "createAccount": "Create account",
    "localeSwitcherLabel": "Choose language",
    "showcase": {
      "title": "Your operative, at a glance",
      "blurb": "Attributes, skills, talents, conditions and dice. One screen, read at the speed of play.",
      "alt": "The Coriolis Companion character sheet for Said al-Khatib, an operative: attributes with rank dots, skills, talents, and conditions on a brass-on-indigo layout."
    },
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
    "showcase": {
      "title": "Ваш оперативник как на ладони",
      "blurb": "Характеристики, навыки, таланты, состояния и кубики. Один экран, читается на скорости игры.",
      "alt": "Лист персонажа Coriolis Companion для оперативника Саида аль-Хатиба: характеристики с точками рангов, навыки, таланты и состояния на раскладке брасс-по-индиго."
    },
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
        <!-- The wordmark is a role="img" lockup, so the tagline carries the
             page's h1 (the visible heading text); styling stays on the class. -->
        <h1 id="landing-tagline" class="page-landing__tagline">
          {{ t('tagline') }}
        </h1>

        <div class="page-landing__cta">
          <AppButton variant="primary" size="lg" @click="onSignIn">
            {{ t('signIn') }}
          </AppButton>
          <AppButton variant="ghost" size="lg" @click="onCreateAccount">
            {{ t('createAccount') }}
          </AppButton>
        </div>
      </section>

      <!--
        Proof fold: a real product screenshot, the dominant below-hero moment.
        Heading is left-aligned (continuing the axis break); the framed capture
        runs wider than the hero column for scale. The desktop capture shows
        the three-column sheet; the phone capture swaps in under 720px.
      -->
      <section class="page-landing__showcase" aria-labelledby="showcase-title">
        <div class="page-landing__showcase-intro">
          <h2 id="showcase-title" class="page-landing__showcase-title">
            {{ t('showcase.title') }}
          </h2>
          <p class="page-landing__showcase-blurb">
            {{ t('showcase.blurb') }}
          </p>
        </div>
        <figure class="page-landing__showcase-frame">
          <picture>
            <source media="(max-width: 720px)" :srcset="sheetMobile" />
            <!-- No width/height attrs: the two sources differ in ratio, so the
                 box is reserved via per-breakpoint `aspect-ratio` in CSS to
                 avoid a wrong reservation (CLS) before the swap loads. -->
            <img
              class="page-landing__showcase-img"
              :src="sheetDesktop"
              :alt="t('showcase.alt')"
              loading="lazy"
              decoding="async"
            />
          </picture>
        </figure>
      </section>

      <!--
        Asymmetric feature fold, not a 3-up card grid. "Sheet" leads as the
        framed dominant block; "Share" and "Run" are compact frameless rows.
        Each glyph is a real brand asset (DESIGN §4), decorative beside its
        visible title: the eight-pointed star for the sheet, The Messenger
        Icon for sharing, a glowing success die for play.
      -->
      <section class="page-landing__features" aria-label="Features">
        <article class="page-landing__feature page-landing__feature--lead">
          <span class="page-landing__feature-glyph" aria-hidden="true">
            <AppStarOrnament size="lg" color="brass" />
          </span>
          <h2 class="page-landing__feature-title page-landing__feature-title--lead">
            {{ t('feature.sheet.title') }}
          </h2>
          <p class="page-landing__feature-blurb">
            {{ t('feature.sheet.blurb') }}
          </p>
        </article>

        <ul class="page-landing__feature-list">
          <li class="page-landing__feature page-landing__feature--compact">
            <span
              class="page-landing__feature-glyph page-landing__feature-glyph--sm"
              aria-hidden="true"
            >
              <AppIconCoriolis name="messenger" size="md" color="brass" />
            </span>
            <div class="page-landing__feature-text">
              <h2 class="page-landing__feature-title">
                {{ t('feature.share.title') }}
              </h2>
              <p class="page-landing__feature-blurb">
                {{ t('feature.share.blurb') }}
              </p>
            </div>
          </li>

          <li class="page-landing__feature page-landing__feature--compact">
            <span
              class="page-landing__feature-glyph page-landing__feature-glyph--sm"
              aria-hidden="true"
            >
              <AppDie :value="6" state="hit" size="sm" />
            </span>
            <div class="page-landing__feature-text">
              <h2 class="page-landing__feature-title">
                {{ t('feature.run.title') }}
              </h2>
              <p class="page-landing__feature-blurb">
                {{ t('feature.run.blurb') }}
              </p>
            </div>
          </li>
        </ul>
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
  // Showcase capture runs wider than the hero column but narrower than the
  // feature fold, so scale steps up hero → showcase → features.
  $showcase-max-width: 1000px;
  $showcase-mobile-max-width: 320px;
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
  // WCAG 2.5.5 minimum touch target — applied to the locale toggle on
  // coarse pointers only (no need to inflate it for mouse users).
  $touch-target-min: 44px;

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
      display: inline-flex;
      align-items: center;
      justify-content: center;
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

      // Coarse pointers (touch) get the full 44px tap target; mouse keeps the
      // compact pill.
      @media (pointer: coarse) {
        min-width: $touch-target-min;
        min-height: $touch-target-min;
      }

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

    // CTAs are AppButton (variant primary / ghost, size lg). The page no
    // longer hand-rolls button styling; the shared component owns fills,
    // states, focus ring and the brass-bevel.
    &__cta {
      display: flex;
      gap: var(--space-3);
      flex-wrap: wrap;
      justify-content: center;
      margin-top: var(--space-3);
    }

    // ── Showcase ───────────────────────────────────────────────────────────
    // Real product capture as the proof fold. Left-aligned heading (the axis
    // break continues), framed wide. Depth is the sanctioned brass-bevel inset,
    // not a drop shadow (DESIGN §5.4: shadows smudge on dark surfaces).

    &__showcase {
      width: 100%;
      max-width: $showcase-max-width;
      display: flex;
      flex-direction: column;
      gap: var(--space-6);
    }

    &__showcase-intro {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
      text-align: start;
    }

    &__showcase-title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-md-font-size);
      line-height: var(--type-display-md-line-height);
      letter-spacing: 0.04em;
      color: var(--brand-brass-light);
    }

    &__showcase-blurb {
      margin: 0;
      max-width: 60ch;
      font-family: var(--font-body);
      font-size: var(--type-body-lg-font-size);
      line-height: var(--type-body-lg-line-height);
      color: var(--text-secondary);
    }

    &__showcase-frame {
      margin: 0;
      overflow: hidden;
      background: var(--surface-night);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
      box-shadow: var(--shadow-brass-bevel);

      // The phone capture is portrait; cap its width so it reads as a device,
      // not a wall.
      @media (max-width: 720px) {
        max-width: $showcase-mobile-max-width;
        margin-inline: auto;
      }
    }

    &__showcase-img {
      display: block;
      width: 100%;
      height: auto;
      // Intrinsic capture ratios (not design tokens). Reserves correct height
      // per breakpoint so the <picture> source swap causes no layout shift.
      aspect-ratio: 1280 / 800;

      @media (max-width: 720px) {
        aspect-ratio: 828 / 1792;
      }
    }

    // ── Feature fold ─────────────────────────────────────────────────────────
    // Deliberately asymmetric, not a 3-up card grid. "Sheet" leads as the
    // dominant proof block (left, framed); "Share" and "Run" sit beside it as
    // compact, frameless rows. The hero above is centred and this section is
    // left-aligned, so the composition axis breaks between folds instead of
    // running one dead-centre column.

    &__features {
      width: 100%;
      max-width: $features-max-width;
      display: grid;
      grid-template-columns: minmax(0, 1.15fr) minmax(0, 1fr);
      align-items: stretch;
      gap: var(--space-8);
      text-align: start;

      @media (max-width: 720px) {
        grid-template-columns: 1fr;
        gap: var(--space-6);
      }
    }

    // Lead block — the only framed surface in the fold. Keeping the supporting
    // rows frameless is what stops this reading as three identical boxes.
    &__feature--lead {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
      padding: var(--space-7) var(--space-6);
      background: color-mix(in srgb, var(--surface-night) 60%, transparent);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
      transition: border-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        border-color: var(--brand-brass);
      }
    }

    &__feature-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      justify-content: center;
      gap: var(--space-5);
    }

    // Compact supporting row — glyph leading, text trailing. Consecutive rows
    // are split by a full-width hairline (a top border, never a side stripe).
    &__feature--compact {
      display: flex;
      align-items: flex-start;
      gap: var(--space-4);
      padding-block: var(--space-5);

      & + & {
        border-top: 1px solid var(--brand-brass-shadow);
      }
    }

    &__feature-text {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    // Glyph wrapper now hosts a brand asset (star / Icon / die), so it is
    // layout-only: each component owns its own size and colour.
    &__feature-glyph {
      display: inline-flex;
      line-height: 0;

      &--sm {
        flex-shrink: 0;
        // Optical nudge so the asset sits on the supporting title's cap-height.
        margin-top: var(--space-1);
      }
    }

    &__feature-title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      letter-spacing: 0.06em;
      color: var(--brand-brass-light);
      text-transform: uppercase;

      // Dominant block reads heavier: 28px vs 20px is a 1.4 step.
      &--lead {
        font-size: var(--type-display-md-font-size);
      }
    }

    &__feature-blurb {
      margin: 0;
      max-width: 60ch;
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
