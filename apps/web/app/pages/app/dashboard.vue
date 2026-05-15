<script setup lang="ts">
  definePageMeta({ layout: 'app' });

  import { computed, onMounted, onBeforeUnmount, ref } from 'vue';
  import { AppArabesqueCorner, AppPanelTitle, AppSegControl, AppWordmark } from '@app/ui';
  import { useCharactersApi } from '~/composables/useCharactersApi';
  import { useGameSessionsApi } from '~/composables/useGameSessionsApi';
  import {
    APHORISM_KEYS,
    formatCycleClock,
    formatCycleDate,
    formatSyncLabel,
    pickAphorism,
  } from '~/utils/bridge';

  const { t, locale } = useI18n({ useScope: 'local' });
  const auth = useAuth();
  const charactersApi = useCharactersApi();
  const sessionsApi = useGameSessionsApi();

  // ── Greeting / username ─────────────────────────────────────────────────────

  const userName = ref<string>('');

  // ── Cycle stat ──────────────────────────────────────────────────────────────

  // The Bridge "Cycle" card surfaces a steady time-of-day rhythm so the
  // dashboard never feels frozen between data refreshes. The stat ticks
  // every minute; we keep the source UTC and let `Intl.DateTimeFormat`
  // localise per `useI18n().locale`.
  const now = ref<Date>(new Date());
  let nowTimerId: ReturnType<typeof setInterval> | null = null;

  // ── Sync indicator ──────────────────────────────────────────────────────────

  // Last successful interaction with the backend. Updated on every list
  // fetch below; rendered as a relative time on the Sync card.
  const lastSyncAt = ref<Date | null>(null);
  const online = ref<boolean>(typeof navigator === 'undefined' ? true : navigator.onLine);

  function onOnline(): void {
    online.value = true;
  }
  function onOffline(): void {
    online.value = false;
  }

  // ── Characters card ─────────────────────────────────────────────────────────

  interface CharSummary {
    activeCount: number;
  }
  const charSummary = ref<CharSummary>({ activeCount: 0 });

  type LoadState = 'loading' | 'loaded' | 'error';
  const charState = ref<LoadState>('loading');

  async function loadCharacters(): Promise<void> {
    charState.value = 'loading';
    try {
      // Default `list` already filters out drafts (handler enforces
      // `includeDrafts=false`), so the count maps to the player's active
      // roster size.
      const data = await charactersApi.list({ limit: 50 });
      charSummary.value = { activeCount: data.items.length };
      lastSyncAt.value = new Date();
      charState.value = 'loaded';
    } catch {
      charState.value = 'error';
    }
  }

  // ── Sessions card + segmented control ──────────────────────────────────────

  // Two segments: Running (sessions owned by this GM) and Playing In
  // (sessions the user is a member of). Playing-in count is fixed to 0
  // in Stream A — the /me/memberships endpoint ships in Stream B.
  type SessionSegment = 'running' | 'playing';
  const sessionSegment = ref<SessionSegment>('running');
  const runningCount = ref<number>(0);
  // playing count is intentionally 0 until Stream B wires /me/memberships.
  const playingCount = 0;

  const sessionSegOptions = computed(() => [
    { value: 'running', label: t('card.sessions.running', { n: runningCount.value }) },
    { value: 'playing', label: t('card.sessions.playing', { n: playingCount }) },
  ]);

  async function loadSessionCount(): Promise<void> {
    try {
      // Until the API exposes a `total` field, fetch up to 100 and count.
      // TODO: replace with a dedicated count endpoint or `total` in response.
      const result = await sessionsApi.listSessions({ status: 'active', limit: 100 });
      runningCount.value = result.items.length;
    } catch {
      // Non-fatal — count stays 0, sessions card still renders.
    }
  }

  // ── Aphorism (footer) ───────────────────────────────────────────────────────

  // The Bridge always closes with a Coriolis aphorism. Keys + the
  // deterministic day-of-year picker live in `~/utils/bridge.ts` so
  // the rule is unit-testable without mounting Nuxt.
  const aphorismKey = computed(() => pickAphorism(now.value, APHORISM_KEYS));

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  onMounted(async () => {
    nowTimerId = setInterval(() => {
      now.value = new Date();
    }, 60_000);
    if (typeof globalThis.addEventListener === 'function') {
      globalThis.addEventListener('online', onOnline);
      globalThis.addEventListener('offline', onOffline);
    }

    try {
      const result = await auth.getSession();
      const data = result.data as { user?: { name?: string; email?: string } } | null;
      userName.value = data?.user?.name ?? data?.user?.email ?? '';
    } catch {
      // No session — middleware will redirect; we render gracefully.
    }

    await loadCharacters();
    void loadSessionCount();
  });

  onBeforeUnmount(() => {
    if (nowTimerId) clearInterval(nowTimerId);
    if (typeof globalThis.removeEventListener === 'function') {
      globalThis.removeEventListener('online', onOnline);
      globalThis.removeEventListener('offline', onOffline);
    }
  });

  // ── Display formatters ──────────────────────────────────────────────────────

  // All formatters delegate to pure helpers in `~/utils/bridge.ts` —
  // see that file for contract docs and the Vitest spec that locks
  // their behaviour.

  const cycleClock = computed<string>(() => formatCycleClock(now.value, locale.value));

  const cycleDate = computed<string>(() => formatCycleDate(now.value, locale.value));

  const syncLabel = computed<string>(() =>
    formatSyncLabel({
      online: online.value,
      now: now.value,
      lastSyncAt: lastSyncAt.value,
      locale: locale.value,
      t,
    }),
  );
</script>

<i18n lang="json">
{
  "en": {
    "wizardLabel": "Bridge",
    "greeting": {
      "withName": "Welcome back, {name}.",
      "anonymous": "Welcome back."
    },
    "card": {
      "cycle": {
        "title": "Cycle",
        "kicker": "Local clock"
      },
      "sync": {
        "title": "Sync",
        "kicker": "State of the line",
        "online": "Online",
        "offline": "Offline"
      },
      "characters": {
        "title": "Roster",
        "kicker": "Active characters",
        "empty": "No characters yet — start one to see them on your roster.",
        "createCta": "Create character",
        "browseCta": "Open roster",
        "errorLoad": "Could not load your roster."
      },
      "sessions": {
        "title": "Sessions",
        "running": "Running ({n})",
        "playing": "Playing in ({n})",
        "runningEmpty": "No sessions running. Create one to get started.",
        "playingEmpty": "You haven't joined any sessions yet. Ask your GM for an invite link."
      }
    },
    "sync": {
      "online": "Online",
      "offline": "Offline — changes will sync when the line returns.",
      "pending": "Awaiting first sync…"
    },
    "aphorism": {
      "wheel": "The Wheel turns. The Horizon listens. The Icons walk beside you.",
      "icons": "Nine Icons watch from beyond the dark water; one walks at your shoulder.",
      "dark": "Push only what you must. The Dark counts the rest."
    }
  },
  "ru": {
    "wizardLabel": "Мостик",
    "greeting": {
      "withName": "С возвращением, {name}.",
      "anonymous": "С возвращением."
    },
    "card": {
      "cycle": {
        "title": "Цикл",
        "kicker": "Локальное время"
      },
      "sync": {
        "title": "Связь",
        "kicker": "Состояние линии",
        "online": "В сети",
        "offline": "Нет сети"
      },
      "characters": {
        "title": "Команда",
        "kicker": "Активные персонажи",
        "empty": "Персонажей пока нет — создайте, и они появятся в команде.",
        "createCta": "Создать персонажа",
        "browseCta": "Открыть команду",
        "errorLoad": "Не удалось загрузить команду."
      },
      "sessions": {
        "title": "Сессии",
        "running": "Активные ({n})",
        "playing": "Я игрок в ({n})",
        "runningEmpty": "Нет запущенных сессий. Создайте одну, чтобы начать.",
        "playingEmpty": "Вы ещё не присоединились ни к одной сессии. Попросите ведущего прислать ссылку-инвайт."
      }
    },
    "sync": {
      "online": "В сети",
      "offline": "Нет сети — изменения синхронизируются, когда линия вернётся.",
      "pending": "Ждём первой синхронизации…"
    },
    "aphorism": {
      "wheel": "Колесо Горизонта вращается. Иконы идут рядом.",
      "icons": "Девять Икон смотрят из-за тёмных вод; одна стоит рядом с тобой.",
      "dark": "Пушь лишь то, что должен. Тьма считает остальное."
    }
  },
  "uk": {
    "wizardLabel": "[uk-todo] Bridge",
    "greeting": {
      "withName": "[uk-todo] Welcome back, {name}.",
      "anonymous": "[uk-todo] Welcome back."
    },
    "card": {
      "cycle": {
        "title": "[uk-todo] Cycle",
        "kicker": "[uk-todo] Local clock"
      },
      "sync": {
        "title": "[uk-todo] Sync",
        "kicker": "[uk-todo] State of the line",
        "online": "[uk-todo] Online",
        "offline": "[uk-todo] Offline"
      },
      "characters": {
        "title": "[uk-todo] Roster",
        "kicker": "[uk-todo] Active characters",
        "empty": "[uk-todo] No characters yet.",
        "createCta": "[uk-todo] Create character",
        "browseCta": "[uk-todo] Open roster",
        "errorLoad": "[uk-todo] Could not load your roster."
      },
      "sessions": {
        "title": "Сесії",
        "running": "Активні ({n})",
        "playing": "Я гравець у ({n})",
        "runningEmpty": "Немає активних сесій. Створіть одну, щоб почати.",
        "playingEmpty": "Ви ще не приєдналися до жодної сесії. Попросіть ведучого надіслати посилання-інвайт."
      }
    },
    "sync": {
      "online": "[uk-todo] Online",
      "offline": "[uk-todo] Offline — changes will sync when the line returns.",
      "pending": "[uk-todo] Awaiting first sync…"
    },
    "aphorism": {
      "wheel": "[uk-todo] The Wheel turns.",
      "icons": "[uk-todo] Nine Icons watch from beyond the dark water.",
      "dark": "[uk-todo] Push only what you must."
    }
  },
  "el": {
    "wizardLabel": "[el-todo] Bridge",
    "greeting": {
      "withName": "[el-todo] Welcome back, {name}.",
      "anonymous": "[el-todo] Welcome back."
    },
    "card": {
      "cycle": {
        "title": "[el-todo] Cycle",
        "kicker": "[el-todo] Local clock"
      },
      "sync": {
        "title": "[el-todo] Sync",
        "kicker": "[el-todo] State of the line",
        "online": "[el-todo] Online",
        "offline": "[el-todo] Offline"
      },
      "characters": {
        "title": "[el-todo] Roster",
        "kicker": "[el-todo] Active characters",
        "empty": "[el-todo] No characters yet.",
        "createCta": "[el-todo] Create character",
        "browseCta": "[el-todo] Open roster",
        "errorLoad": "[el-todo] Could not load your roster."
      },
      "sessions": {
        "title": "Συνεδρίες",
        "running": "Σε εξέλιξη ({n})",
        "playing": "Παίζω σε ({n})",
        "runningEmpty": "Δεν υπάρχουν συνεδρίες σε εξέλιξη. Δημιουργήστε μία για να ξεκινήσετε.",
        "playingEmpty": "Δεν έχετε ακόμα συμμετάσχει σε καμία συνεδρία. Ζητήστε από τον GM σας έναν σύνδεσμο πρόσκλησης."
      }
    },
    "sync": {
      "online": "[el-todo] Online",
      "offline": "[el-todo] Offline — changes will sync when the line returns.",
      "pending": "[el-todo] Awaiting first sync…"
    },
    "aphorism": {
      "wheel": "[el-todo] The Wheel turns.",
      "icons": "[el-todo] Nine Icons watch from beyond the dark water.",
      "dark": "[el-todo] Push only what you must."
    }
  }
}
</i18n>

<template>
  <section
    class="bridge"
    :aria-label="t('wizardLabel')"
  >
    <AppArabesqueCorner
      orientation="tl"
      size="md"
      color="brass-deep"
      class="bridge__corner bridge__corner--tl"
    />
    <AppArabesqueCorner
      orientation="tr"
      size="md"
      color="brass-deep"
      class="bridge__corner bridge__corner--tr"
    />

    <header class="bridge__hero">
      <AppWordmark
        :size="48"
        :eyebrow="t('wizardLabel')"
      />
      <p class="bridge__greeting">
        {{ userName ? t('greeting.withName', { name: userName }) : t('greeting.anonymous') }}
      </p>
    </header>

    <div class="bridge__grid">
      <article
        class="bridge__card"
        aria-labelledby="bridge-cycle-title"
      >
        <AppPanelTitle
          id="bridge-cycle-title"
          :kicker="t('card.cycle.kicker')"
          :title="t('card.cycle.title')"
          size="sm"
        />
        <p
          class="bridge__stat"
          aria-live="polite"
        >
          {{ cycleClock }}
        </p>
        <p class="bridge__caption">
          {{ cycleDate }}
        </p>
      </article>

      <article
        class="bridge__card"
        aria-labelledby="bridge-sync-title"
      >
        <AppPanelTitle
          id="bridge-sync-title"
          :kicker="t('card.sync.kicker')"
          :title="t('card.sync.title')"
          size="sm"
        />
        <p class="bridge__stat">
          <span
            class="bridge__sync-dot"
            :class="online ? 'bridge__sync-dot--online' : 'bridge__sync-dot--offline'"
            aria-hidden="true"
          />
          {{ online ? t('card.sync.online') : t('card.sync.offline') }}
        </p>
        <p class="bridge__caption">
          {{ syncLabel }}
        </p>
      </article>

      <article
        class="bridge__card"
        aria-labelledby="bridge-roster-title"
      >
        <AppPanelTitle
          id="bridge-roster-title"
          :kicker="t('card.characters.kicker')"
          :title="t('card.characters.title')"
          size="sm"
        />
        <p
          v-if="charState === 'loading'"
          class="bridge__stat"
          aria-live="polite"
        >
          …
        </p>
        <p
          v-else-if="charState === 'error'"
          class="bridge__caption bridge__caption--error"
        >
          {{ t('card.characters.errorLoad') }}
        </p>
        <template v-else>
          <p class="bridge__stat">
            {{ charSummary.activeCount }}
          </p>
          <p class="bridge__caption">
            <span v-if="charSummary.activeCount === 0">{{ t('card.characters.empty') }}</span>
            <button
              v-if="charSummary.activeCount === 0"
              type="button"
              class="bridge__cta"
              @click="navigateTo('/app/characters/new')"
            >
              {{ t('card.characters.createCta') }}
            </button>
            <button
              v-else
              type="button"
              class="bridge__cta"
              @click="navigateTo('/app/characters')"
            >
              {{ t('card.characters.browseCta') }}
            </button>
          </p>
        </template>
      </article>
    </div>

    <!-- Sessions panel (Phase 8 Stream A).
         Running count comes from listSessions; Playing-in count is fixed
         to 0 until Stream B wires /me/memberships. -->
    <section
      class="bridge__sessions"
      aria-labelledby="bridge-sessions-title"
    >
      <div class="bridge__sessions-header">
        <AppPanelTitle
          id="bridge-sessions-title"
          :title="t('card.sessions.title')"
          size="sm"
        />
        <AppSegControl
          v-model="sessionSegment"
          :options="sessionSegOptions"
          size="sm"
          class="bridge__sessions-seg"
        />
      </div>
      <p
        v-if="sessionSegment === 'playing'"
        class="bridge__sessions-empty"
      >
        {{ t('card.sessions.playingEmpty') }}
      </p>
      <p
        v-else-if="sessionSegment === 'running' && runningCount === 0"
        class="bridge__sessions-empty"
      >
        {{ t('card.sessions.runningEmpty') }}
      </p>
      <div
        v-else-if="sessionSegment === 'running' && runningCount > 0"
        class="bridge__sessions-cta-row"
      >
        <button
          type="button"
          class="bridge__cta"
          @click="navigateTo('/app/game-sessions')"
        >
          {{ t('card.sessions.running', { n: runningCount }) }} →
        </button>
      </div>
    </section>

    <footer
      class="bridge__aphorism"
      aria-label="aphorism"
    >
      <p>{{ t(aphorismKey) }}</p>
    </footer>
  </section>
</template>

<style lang="scss" scoped>
  $grid-max-width: 1080px;
  $sync-dot: 10px;

  .bridge {
    position: relative;
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: var(--space-8);
    padding: var(--space-9) var(--space-7);
    max-width: $grid-max-width;
    margin: 0 auto;
    width: 100%;

    &__corner {
      position: absolute;
      pointer-events: none;
      z-index: var(--z-raised);

      &--tl {
        top: var(--space-3);
        left: var(--space-3);
      }

      &--tr {
        top: var(--space-3);
        right: var(--space-3);
      }
    }

    &__hero {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-3);
      text-align: center;
    }

    &__greeting {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: var(--space-5);

      @media (max-width: 720px) {
        grid-template-columns: 1fr;
      }
    }

    &__card {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
      padding: var(--space-6) var(--space-5);
      background: color-mix(in srgb, var(--surface-night) 70%, transparent);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-lg);
      transition: border-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        border-color: var(--brand-brass-deep);
      }
    }

    &__stat {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-md-font-size);
      line-height: 1;
      color: var(--brand-brass-light);
      letter-spacing: 0.04em;
      display: flex;
      align-items: center;
      gap: var(--space-3);
    }

    &__caption {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      display: flex;
      flex-direction: column;
      gap: var(--space-2);

      &--error {
        color: var(--state-crimson-bright);
      }
    }

    &__cta {
      align-self: flex-start;
      cursor: pointer;
      padding: var(--space-2) var(--space-4);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-brass-light);
      background: transparent;
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
      transition: border-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        border-color: var(--brand-brass);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    &__sync-dot {
      width: $sync-dot;
      height: $sync-dot;
      border-radius: var(--radius-pill);
      flex-shrink: 0;

      &--online {
        background: var(--state-mystic-teal);
        box-shadow: 0 0 0 4px color-mix(in srgb, var(--state-mystic-teal) 25%, transparent);
      }

      &--offline {
        background: var(--state-crimson);
      }
    }

    &__sessions {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
      padding: var(--space-5);
      background: color-mix(in srgb, var(--surface-night) 70%, transparent);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-lg);
    }

    &__sessions-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: var(--space-4);
      flex-wrap: wrap;
    }

    &__sessions-seg {
      flex-shrink: 0;
    }

    &__sessions-empty {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__sessions-cta-row {
      display: flex;
    }

    &__aphorism {
      text-align: center;
      padding: var(--space-6) var(--space-5) 0;

      p {
        margin: 0;
        font-family: var(--font-display);
        font-size: var(--type-body-lg-font-size);
        line-height: var(--type-body-lg-line-height);
        font-style: italic;
        letter-spacing: 0.04em;
        color: var(--brand-brass-light);
      }
    }
  }
</style>
