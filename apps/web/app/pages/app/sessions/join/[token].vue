<script setup lang="ts">
  definePageMeta({ layout: 'app' });

  import { ref, computed, onMounted } from 'vue';
  import { AppSessionJoinCard } from '@app/ui';
  import type { AppSessionJoinCardLabels } from '@app/ui';
  import { useInvitePublicApi } from '~/composables/useInvitePublicApi';
  import { useMyMembershipsApi } from '~/composables/useMyMembershipsApi';
  import type { InvitePreview } from '~/composables/useInvitePublicApi';

  /**
   * Public invite-join page (Phase 11 Stream B).
   *
   * Reachable without authentication — auth-required.global.ts exempts
   * /app/sessions/join/* paths. The page reads the token from the URL,
   * fetches a public preview, resolves the join state, and delegates
   * rendering to AppSessionJoinCard.
   *
   * States:
   *   valid          — invite active, caller not yet a member → show join CTA
   *   revoked        — 404/410 from preview endpoint → explain, no CTA
   *   already-member — alreadyJoined flag true → link to existing session
   *   not-signed-in  — unauthenticated caller, invite looks valid → sign-in CTA
   */

  // Local alias mirrors AppSessionJoinCard's JoinState — avoids importing the
  // type from @app/ui which the Vue SFC parser cannot resolve for ref<T>.
  type JoinState = 'valid' | 'revoked' | 'already-member' | 'not-signed-in';
  type PageLoadState = 'loading' | 'ready' | 'error';

  const { t } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const inviteApi = useInvitePublicApi();
  const membershipsApi = useMyMembershipsApi();
  const authClient = useAuth();

  const token = computed<string>(() => route.params.token as string);

  const loadState = ref<PageLoadState>('loading');
  const joinState = ref<JoinState>('valid');
  const preview = ref<InvitePreview | null>(null);
  const joining = ref(false);
  const joinError = ref('');
  // gameSessionId resolved from /me/memberships when alreadyJoined is true.
  const alreadyJoinedSessionId = ref<string | null>(null);

  /**
   * Type predicate: returns true when Better Auth's opaque session envelope
   * contains a user object with a non-empty id. Avoids unsafe-member-access
   * by narrowing through typeof guards rather than casts.
   */
  function hasUserId(data: unknown): boolean {
    if (typeof data !== 'object' || data === null) return false;
    const d = data as { user?: unknown };
    if (typeof d.user !== 'object' || d.user === null) return false;
    const u = d.user as { id?: unknown };
    return typeof u.id === 'string' && u.id.length > 0;
  }

  async function load(): Promise<void> {
    loadState.value = 'loading';
    joinError.value = '';
    try {
      const data = await inviteApi.getPreview(token.value);
      preview.value = data;

      // Determine auth state using getSession (same pattern as dashboard.vue).
      const sessionResult = await authClient.getSession();
      // getSession() returns { data: unknown } — Better Auth does not expose a
      // narrow type. hasUserId() narrows without unsafe member access.
      const isAuthenticated = hasUserId(sessionResult.data);

      if (!isAuthenticated) {
        joinState.value = 'not-signed-in';
      } else if (data.alreadyJoined) {
        joinState.value = 'already-member';
        // Resolve the game session id via /me/memberships since preview
        // does not carry sessionId directly.
        try {
          const memberships = await membershipsApi.list();
          // If multiple sessions share the same name, pick the newest by joinedAt.
          const sorted = memberships
            .filter((ms) => ms.sessionName === data.sessionName)
            .toSorted((a, b) => new Date(b.joinedAt).getTime() - new Date(a.joinedAt).getTime());
          alreadyJoinedSessionId.value = sorted[0]?.gameSessionId ?? null;
        } catch {
          // Non-fatal — goToSession handler falls back to /app/sessions list.
        }
      } else {
        joinState.value = 'valid';
      }

      loadState.value = 'ready';
    } catch (error) {
      // WHY: we always throw the RFC 9457 Problem object from useInvitePublicApi;
      // the cast is intentional and mirrors the pattern in every other composable.

      const problem: { status?: number } = error as { status?: number };
      // 404 and 410 both mean the invite is no longer valid.
      if (problem.status === 404 || problem.status === 410) {
        joinState.value = 'revoked';
        loadState.value = 'ready';
      } else {
        loadState.value = 'error';
      }
    }
  }

  async function onJoin(): Promise<void> {
    joining.value = true;
    joinError.value = '';
    try {
      const result = await inviteApi.accept(token.value);
      await navigateTo(`/app/sessions/${result.membership.gameSessionId}`);
    } catch (error) {
      const problem: { detail?: string } = error as { detail?: string };
      joinError.value = problem.detail ?? t('errorJoin');
    } finally {
      joining.value = false;
    }
  }

  function onSignIn(): void {
    void navigateTo(`/login?redirect=${encodeURIComponent(route.fullPath)}`);
  }

  function onGoToSession(): void {
    if (alreadyJoinedSessionId.value) {
      void navigateTo(`/app/sessions/${alreadyJoinedSessionId.value}`);
    } else {
      void navigateTo('/app/sessions');
    }
  }

  const labels = computed<AppSessionJoinCardLabels>(() => ({
    titleValid: t('titleValid'),
    titleRevoked: t('titleRevoked'),
    titleAlreadyMember: t('titleAlreadyMember'),
    titleNotSignedIn: t('titleNotSignedIn'),
    sessionLabel: t('sessionLabel'),
    gmLabel: t('gmLabel'),
    ctaJoin: joining.value ? t('ctaJoining') : t('ctaJoin'),
    ctaSignIn: t('ctaSignIn'),
    ctaGoToSession: t('ctaGoToSession'),
    revokedMessage: t('revokedMessage'),
    alreadyMemberMessage: t('alreadyMemberMessage'),
  }));

  onMounted(() => {
    void load();
  });
</script>

<i18n lang="json">
{
  "en": {
    "titleValid": "You're invited",
    "titleRevoked": "Invite no longer valid",
    "titleAlreadyMember": "Already in this session",
    "titleNotSignedIn": "Sign in to join",
    "sessionLabel": "Session",
    "gmLabel": "GM",
    "ctaJoin": "Join session",
    "ctaJoining": "Joining…",
    "ctaSignIn": "Sign in",
    "ctaGoToSession": "Go to session",
    "revokedMessage": "This invite link has expired or been revoked. Ask your GM for a new one.",
    "alreadyMemberMessage": "You are already a member of this session.",
    "errorJoin": "Couldn't join the session. Please try again.",
    "loading": "Loading invite…",
    "errorLoad": "Something went wrong loading this invite. Please try again."
  },
  "ru": {
    "titleValid": "Вас пригласили",
    "titleRevoked": "Приглашение недействительно",
    "titleAlreadyMember": "Вы уже в сессии",
    "titleNotSignedIn": "Войдите, чтобы присоединиться",
    "sessionLabel": "Сессия",
    "gmLabel": "ГМ",
    "ctaJoin": "Войти в сессию",
    "ctaJoining": "Входим…",
    "ctaSignIn": "Войти",
    "ctaGoToSession": "Перейти к сессии",
    "revokedMessage": "Ссылка-приглашение истекла или была отозвана. Попросите ГМ сгенерировать новую.",
    "alreadyMemberMessage": "Вы уже являетесь участником этой сессии.",
    "errorJoin": "Не удалось присоединиться к сессии. Попробуйте ещё раз.",
    "loading": "Загружаем приглашение…",
    "errorLoad": "Что-то пошло не так. Попробуйте ещё раз."
  }
}
</i18n>

<template>
  <div class="page-join">
    <p v-if="loadState === 'loading'" class="page-join__loading">
      {{ t('loading') }}
    </p>

    <p v-else-if="loadState === 'error'" class="page-join__error" role="alert">
      {{ t('errorLoad') }}
    </p>

    <template v-else>
      <p v-if="joinError" class="page-join__join-error" role="alert">
        {{ joinError }}
      </p>

      <AppSessionJoinCard
        :state="joinState"
        :preview="preview"
        :labels="labels"
        @join="onJoin"
        @sign-in="onSignIn"
        @go-to-session="onGoToSession"
      />
    </template>
  </div>
</template>

<style lang="scss" scoped>
  .page-join {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 60vh;
    padding: var(--space-6);
    gap: var(--space-4);

    &__loading {
      margin: 0;
      font-family: var(--font-body);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__error {
      margin: 0;
      font-family: var(--font-body);
      color: var(--state-crimson-bright);
    }

    &__join-error {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--state-crimson-bright);
    }
  }
</style>
