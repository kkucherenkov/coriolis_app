<script setup lang="ts">
  import { computed, ref } from 'vue';
  import { AppBanner, AppHeader, UserMenu } from '@app/ui';
  import { useAuth } from '~/composables/useAuth';
  import { useMeApi } from '~/composables/useMeApi';
  import { useOnline } from '~/composables/useOnline';
  import { useOfflineQueue } from '~/composables/useOfflineQueue';

  const { online } = useOnline();
  const { pending: queuePending, status: queueStatus } = useOfflineQueue();

  // Banner visibility:
  //   offline AND/OR a drain pass is in flight / just finished / errored.
  //   When fully online + idle + queue empty, the banner is gone.
  const offlineBannerVisible = computed(() => !online.value || queueStatus.value !== 'idle');

  const offlineBannerTone = computed(() => {
    if (!online.value) return 'warning';
    if (queueStatus.value === 'error') return 'danger';
    if (queueStatus.value === 'synced') return 'success';
    return 'info';
  });

  const offlineBannerTitle = computed(() => {
    if (!online.value) return t('offlineBanner.title');
    if (queueStatus.value === 'syncing') return t('offlineBanner.syncingTitle');
    if (queueStatus.value === 'synced') return t('offlineBanner.syncedTitle');
    if (queueStatus.value === 'error') return t('offlineBanner.errorTitle');
    return '';
  });

  const offlineBannerBody = computed(() => {
    if (!online.value) {
      return queuePending.value > 0
        ? t('offlineBanner.bodyWithPending', { n: queuePending.value })
        : t('offlineBanner.body');
    }
    if (queueStatus.value === 'syncing') {
      return t('offlineBanner.syncingBody', { n: queuePending.value });
    }
    if (queueStatus.value === 'error') {
      return t('offlineBanner.errorBody');
    }
    return ''; // 'synced' → title-only pulse, 'idle' → banner hidden
  });

  const { t, locale, locales, setLocale } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const auth = useAuth();
  const meApi = useMeApi();

  // ── User identity ─────────────────────────────────────────────────────────────
  // useMeApi returns an imperative client (get/update/deleteMe); we load on mount
  // and store the result in a reactive ref. The header renders skeleton-style
  // with '…' until the request resolves.

  interface MeSnapshot {
    name?: string | null;
    displayName?: string | null;
    email?: string | null;
  }

  const meSnapshot = ref<MeSnapshot | null>(null);

  const displayName = computed<string>(() => {
    const m = meSnapshot.value;
    if (!m) return '…';
    return m.displayName ?? m.name ?? m.email ?? '…';
  });

  // Avatar URL is not in the user model yet — null for now.
  const avatarUrl = computed<string | null>(() => null);

  onMounted(async () => {
    try {
      const data = await meApi.get();
      meSnapshot.value = data as MeSnapshot;
    } catch {
      // Non-fatal: the header will keep showing '…' or initials from email.
    }
  });

  // ── Active nav section ────────────────────────────────────────────────────────
  const NAV_SECTIONS = [
    { key: 'characters', prefix: '/app/characters' },
    { key: 'ships', prefix: '/app/ships' },
    { key: 'npcs', prefix: '/app/npcs' },
    { key: 'sessions', prefix: '/app/game-sessions' },
  ] as const;

  const activeKey = computed<string | undefined>(
    () => NAV_SECTIONS.find((s) => route.path.startsWith(s.prefix))?.key,
  );

  // ── Nav items ─────────────────────────────────────────────────────────────────
  const navItems = computed(() => [
    { key: 'characters', href: '/app/characters', label: t('nav.characters') },
    { key: 'ships', href: '/app/ships', label: t('nav.ships') },
    { key: 'npcs', href: '/app/npcs', label: t('nav.npcs') },
    { key: 'sessions', href: '/app/game-sessions', label: t('nav.sessions') },
  ]);

  // ── User menu ─────────────────────────────────────────────────────────────────
  const userMenuOpen = ref(false);

  const localesForMenu = computed(() =>
    locales.value.map((l) => ({ code: l.code, name: (l as { name?: string }).name ?? l.code })),
  );

  function onLanguageChange(code: string): void {
    void setLocale(code as never);
  }

  function onSettingsClick(): void {
    void navigateTo('/app/settings');
  }

  async function onSignOutClick(): Promise<void> {
    await auth.signOut();
    void navigateTo('/login');
  }
</script>

<i18n lang="json">
{
  "en": {
    "skipToContent": "Skip to main content",
    "offlineBanner": {
      "title": "You're offline",
      "body": "Reads come from the local cache. Changes won't save until your connection returns.",
      "bodyWithPending": "Reads come from the local cache. {n} change(s) will save when you reconnect.",
      "syncingTitle": "Reconnecting…",
      "syncingBody": "Syncing {n} pending change(s).",
      "syncedTitle": "All changes saved",
      "errorTitle": "Some changes couldn't sync",
      "errorBody": "We'll retry automatically when the network is steady. Refresh if you want to force it."
    },
    "brand": {
      "name": "Coriolis · Companion",
      "homeAriaLabel": "Go to dashboard",
      "navAriaLabel": "Main navigation"
    },
    "drawer": {
      "ariaLabel": "Navigation menu",
      "closeAriaLabel": "Close menu"
    },
    "userMenu": {
      "triggerAriaLabel": "Open user menu",
      "languageLabel": "Language",
      "settingsLabel": "Settings",
      "signOutLabel": "Sign out"
    },
    "nav": {
      "characters": "Characters",
      "ships": "Ships",
      "npcs": "NPCs",
      "sessions": "Sessions"
    }
  },
  "ru": {
    "skipToContent": "Перейти к основному содержанию",
    "offlineBanner": {
      "title": "Вы офлайн",
      "body": "Чтение идёт из локального кэша. Изменения не сохранятся до возврата сети.",
      "bodyWithPending": "Чтение идёт из локального кэша. {n} изменение(й) сохранится при восстановлении сети.",
      "syncingTitle": "Восстанавливаем связь…",
      "syncingBody": "Синхронизирую {n} ожидающее(их) изменение(й).",
      "syncedTitle": "Все изменения сохранены",
      "errorTitle": "Часть изменений не синхронизировалась",
      "errorBody": "Попробуем ещё раз при стабильной сети. Обнови страницу, чтобы повторить сейчас."
    },
    "brand": {
      "name": "Coriolis · Companion",
      "homeAriaLabel": "Перейти к панели",
      "navAriaLabel": "Основная навигация"
    },
    "drawer": {
      "ariaLabel": "Меню навигации",
      "closeAriaLabel": "Закрыть меню"
    },
    "userMenu": {
      "triggerAriaLabel": "Открыть меню пользователя",
      "languageLabel": "Язык",
      "settingsLabel": "Настройки",
      "signOutLabel": "Выйти"
    },
    "nav": {
      "characters": "Персонажи",
      "ships": "Корабли",
      "npcs": "NPC",
      "sessions": "Сессии"
    }
  },
  "uk": {
    "skipToContent": "[uk-todo] Skip to main content",
    "offlineBanner": {
      "title": "[uk-todo] You're offline",
      "body": "[uk-todo] Reads come from the local cache. Changes won't save until your connection returns.",
      "bodyWithPending": "[uk-todo] Reads come from the local cache. {n} change(s) will save when you reconnect.",
      "syncingTitle": "[uk-todo] Reconnecting…",
      "syncingBody": "[uk-todo] Syncing {n} pending change(s).",
      "syncedTitle": "[uk-todo] All changes saved",
      "errorTitle": "[uk-todo] Some changes couldn't sync",
      "errorBody": "[uk-todo] We'll retry automatically when the network is steady. Refresh if you want to force it."
    },
    "brand": {
      "name": "Coriolis · Companion",
      "homeAriaLabel": "[uk-todo] Go to dashboard",
      "navAriaLabel": "[uk-todo] Main navigation"
    },
    "drawer": {
      "ariaLabel": "[uk-todo] Navigation menu",
      "closeAriaLabel": "[uk-todo] Close menu"
    },
    "userMenu": {
      "triggerAriaLabel": "[uk-todo] Open user menu",
      "languageLabel": "[uk-todo] Language",
      "settingsLabel": "[uk-todo] Settings",
      "signOutLabel": "[uk-todo] Sign out"
    },
    "nav": {
      "characters": "[uk-todo] Characters",
      "ships": "[uk-todo] Ships",
      "npcs": "[uk-todo] NPCs",
      "sessions": "[uk-todo] Sessions"
    }
  },
  "el": {
    "skipToContent": "[el-todo] Skip to main content",
    "offlineBanner": {
      "title": "[el-todo] You're offline",
      "body": "[el-todo] Reads come from the local cache. Changes won't save until your connection returns.",
      "bodyWithPending": "[el-todo] Reads come from the local cache. {n} change(s) will save when you reconnect.",
      "syncingTitle": "[el-todo] Reconnecting…",
      "syncingBody": "[el-todo] Syncing {n} pending change(s).",
      "syncedTitle": "[el-todo] All changes saved",
      "errorTitle": "[el-todo] Some changes couldn't sync",
      "errorBody": "[el-todo] We'll retry automatically when the network is steady. Refresh if you want to force it."
    },
    "brand": {
      "name": "Coriolis · Companion",
      "homeAriaLabel": "[el-todo] Go to dashboard",
      "navAriaLabel": "[el-todo] Main navigation"
    },
    "drawer": {
      "ariaLabel": "[el-todo] Navigation menu",
      "closeAriaLabel": "[el-todo] Close menu"
    },
    "userMenu": {
      "triggerAriaLabel": "[el-todo] Open user menu",
      "languageLabel": "[el-todo] Language",
      "settingsLabel": "[el-todo] Settings",
      "signOutLabel": "[el-todo] Sign out"
    },
    "nav": {
      "characters": "[el-todo] Characters",
      "ships": "[el-todo] Ships",
      "npcs": "[el-todo] NPCs",
      "sessions": "[el-todo] Sessions"
    }
  }
}
</i18n>

<template>
  <div class="layout-app">
    <!-- Skip-link: visible only when focused. -->
    <a class="layout-app__skip-link" href="#main-content">{{ t('skipToContent') }}</a>

    <!--
      Offline / sync banner. Shows when:
        - navigator.onLine === false (with pending-count line if queue > 0), OR
        - the queue is draining / has just drained / errored.
      Tone + copy track the queue status so a player gets feedback on
      reconnect (syncing → success pulse → fade).
    -->
    <AppBanner
      v-if="offlineBannerVisible"
      :tone="offlineBannerTone"
      role="status"
      :title="offlineBannerTitle"
      class="layout-app__offline-banner"
    >
      {{ offlineBannerBody }}
    </AppBanner>

    <AppHeader
      :brand="{
        brandName: t('brand.name'),
        brandHomeAriaLabel: t('brand.homeAriaLabel'),
        navAriaLabel: t('brand.navAriaLabel'),
      }"
      :nav-items="navItems"
      :active-key="activeKey"
      brand-href="/app"
      :mobile-drawer-labels="{
        ariaLabel: t('drawer.ariaLabel'),
        closeAriaLabel: t('drawer.closeAriaLabel'),
      }"
    >
      <template #user-menu>
        <UserMenu
          v-model:open="userMenuOpen"
          :display-name="displayName"
          :avatar-url="avatarUrl"
          :locales="localesForMenu"
          :current-locale="String(locale)"
          :labels="{
            triggerAriaLabel: t('userMenu.triggerAriaLabel'),
            languageLabel: t('userMenu.languageLabel'),
            settingsLabel: t('userMenu.settingsLabel'),
            signOutLabel: t('userMenu.signOutLabel'),
          }"
          @language-change="onLanguageChange"
          @settings-click="onSettingsClick"
          @sign-out-click="onSignOutClick"
        />
      </template>

      <template #mobile-drawer-content>
        <nav :aria-label="t('brand.navAriaLabel')" class="layout-app__mobile-nav">
          <NuxtLink
            v-for="item in navItems"
            :key="item.key"
            :to="item.href"
            class="layout-app__mobile-link"
            :class="{ 'layout-app__mobile-link--active': activeKey === item.key }"
            :aria-current="activeKey === item.key ? 'page' : undefined"
          >
            {{ item.label }}
          </NuxtLink>
        </nav>

        <div class="layout-app__mobile-user">
          <UserMenu
            v-model:open="userMenuOpen"
            :display-name="displayName"
            :avatar-url="avatarUrl"
            :locales="localesForMenu"
            :current-locale="String(locale)"
            :labels="{
              triggerAriaLabel: t('userMenu.triggerAriaLabel'),
              languageLabel: t('userMenu.languageLabel'),
              settingsLabel: t('userMenu.settingsLabel'),
              signOutLabel: t('userMenu.signOutLabel'),
            }"
            @language-change="onLanguageChange"
            @settings-click="onSettingsClick"
            @sign-out-click="onSignOutClick"
          />
        </div>
      </template>
    </AppHeader>

    <main id="main-content" class="layout-app__main">
      <slot />
    </main>
  </div>
</template>

<style lang="scss" scoped>
  .layout-app {
    display: flex;
    flex-direction: column;
    min-height: 100dvh;
    background: var(--surface-void);
    color: var(--text-primary);
    font-family: var(--font-body);
    font-size: var(--type-body-md-font-size);
    line-height: var(--type-body-md-line-height);

    &__skip-link {
      position: absolute;
      left: var(--space-3);
      // Hidden off-screen by default — slides into view on focus.
      top: calc(-1 * var(--space-8));
      background: var(--brand-brass);
      color: var(--surface-void);
      padding: var(--space-2) var(--space-4);
      border-radius: var(--radius-sm);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      z-index: var(--z-max);
      transition: top var(--motion-duration) var(--motion-ease-standard);
      text-decoration: none;

      &:focus {
        top: var(--space-3);
      }
    }

    &__main {
      flex: 1;
      display: flex;
      flex-direction: column;
      padding: var(--space-7) var(--space-8);

      @media (max-width: 768px) {
        padding: var(--space-5) var(--space-4);
      }
    }

    &__mobile-nav {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
      padding: var(--space-5) var(--space-4);
    }

    &__mobile-link {
      display: block;
      padding: var(--space-3) var(--space-4);
      border-radius: var(--radius-sm);
      color: var(--text-secondary);
      text-decoration: none;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      transition:
        background-color var(--motion-duration-fast) var(--motion-ease-standard),
        color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        background: var(--surface-night);
        color: var(--text-primary);
      }

      &--active {
        background: var(--surface-night);
        color: var(--brand-brass-light);
        border-left: 2px solid var(--brand-brass);
        padding-left: calc(var(--space-4) - 2px);
      }
    }

    &__mobile-user {
      padding: var(--space-4);
      border-top: 1px solid var(--brand-brass-shadow);
    }
  }
</style>
