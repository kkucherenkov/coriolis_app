<script setup lang="ts">
  definePageMeta({ layout: 'app', middleware: ['require-gm-role'] });

  import {
    AppCard,
    AppButton,
    AppInput,
    AppField,
    AppBanner,
    AppBadge,
    AppInviteManager,
    AppSessionHeader,
  } from '@app/ui';
  import type { AppSessionHeaderLabels } from '@app/ui';
  import EncounterPanel from '~/components/EncounterPanel.vue';
  import { ref, onMounted, onBeforeUnmount, computed, watch } from 'vue';
  import { useGameSessionsApi } from '~/composables/useGameSessionsApi';
  import { useDpApi } from '~/composables/useDpApi';
  import { useMeApi } from '~/composables/useMeApi';
  import { useCharactersApi } from '~/composables/useCharactersApi';
  import { useInviteApi } from '~/composables/useInviteApi';
  import {
    useSessionRealtime,
    type DpChangedPayload,
    type RollPushedPayload,
    type CombatUpdatedPayload,
  } from '~/composables/useSessionRealtime';
  import type { GameSession } from '~/composables/useGameSessionsApi';
  import type { DpEvent, DpSource } from '~/composables/useDpApi';
  import type { Me } from '~/composables/useMeApi';
  import type { Character, Problem } from '@app/api-client-ts';

  /**
   * Session detail (Phase 4 Feature 7.2 + 7.3). The page resolves the
   * session, the authenticated user, and the user's characters in
   * parallel on mount, then branches the UI on whether the user is the
   * GM owner. Players see a read-only DP counter + assigned-character
   * list. GMs additionally see DP +/- controls, the audit log tail,
   * and a character-assignment widget.
   *
   * The DP write path is a single POST that returns the updated
   * GameSession — we patch `session.value` from the response without
   * needing a follow-up GET. Optimistic update is deliberately avoided
   * because the server may reject the delta (DP_BELOW_ZERO, etc) and
   * we'd then have to roll back the visible counter, which feels worse
   * than a 100-ms blink.
   *
   * Live updates via Centrifugo land in Block 5 — for now the page
   * refetches DP events after every adjust to keep the audit tail in
   * sync.
   */

  const { t, locale } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const sessionsApi = useGameSessionsApi();
  const dpApi = useDpApi();
  const meApi = useMeApi();
  const charactersApi = useCharactersApi();
  const inviteApi = useInviteApi();

  const sessionId = computed<string>(() => route.params.id as string);

  type LoadState = 'loading' | 'loaded' | 'error' | 'notfound';

  const state = ref<LoadState>('loading');
  const session = ref<GameSession | null>(null);
  const me = ref<Me | null>(null);
  const myCharacters = ref<Character[]>([]);
  const dpEvents = ref<DpEvent[]>([]);
  const errorMsg = ref('');

  const isGm = computed(() => Boolean(me.value && me.value.id === session.value?.ownerId));

  const assignedCharacters = computed<readonly Character[]>(() => {
    const ids = new Set(session.value?.characterIds);
    return myCharacters.value.filter((c) => ids.has(c.id));
  });

  const assignableCharacters = computed<readonly Character[]>(() => {
    const ids = new Set(session.value?.characterIds);
    // Drafts can be assigned in principle, but it usually means the GM
    // grabbed the wrong character; let the player publish first.
    return myCharacters.value.filter((c) => !ids.has(c.id) && c.status === 'active');
  });

  // ── Invite manager ────────────────────────────────────────────────────────
  // revealState drives which panel AppInviteManager renders:
  //   'none'          → no active invite; shows Generate CTA
  //   'active'        → invite exists; shows Copy / Rotate / Revoke
  //   'just-generated'→ reveal panel (fresh link after first generate)
  //   'just-rotated'  → reveal panel (fresh link after rotate)
  // revealUrl holds the plaintext URL only in the just-* states; cleared
  // on closeReveal so the URL never persists in component state beyond one
  // interaction (by design — the server never re-serves it).
  //
  // Confirmation for Revoke and Rotate uses window.confirm() as a fallback
  // because the project has no useConfirm / AppConfirm primitive yet.
  // TODO: replace with a proper modal confirm once one is added (follow-up task).
  type InviteState = 'none' | 'active' | 'just-generated' | 'just-rotated';
  const inviteState = ref<InviteState>('none');
  const inviteRotatedAt = ref<string | null>(null);
  const revealUrl = ref<string>('');

  async function loadInviteMetadata(): Promise<void> {
    if (!isGm.value) return;
    try {
      const meta = await inviteApi.getMetadata(sessionId.value);
      inviteState.value = meta.active ? 'active' : 'none';
      inviteRotatedAt.value = meta.rotatedAt ?? null;
    } catch {
      // Non-fatal — invite panel simply stays hidden on error.
    }
  }

  async function onInviteGenerate(): Promise<void> {
    try {
      const rotated = await inviteApi.rotate(sessionId.value);
      inviteRotatedAt.value = rotated.rotatedAt;
      revealUrl.value = rotated.url;
      inviteState.value = 'just-generated';
    } catch (error) {
      const problem = error as { detail?: string };
      // Surface error via the existing AppBanner pattern would require a
      // dedicated ref; for now fall through (generate button re-enables).
      console.error('Invite generate failed:', problem.detail);
    }
  }

  async function onInviteRotate(): Promise<void> {
    // window.confirm fallback — see TODO above.
    const ok = globalThis.confirm(
      t('invite.confirmRotateTitle') + '\n' + t('invite.confirmRotateBody'),
    );
    if (!ok) return;
    try {
      const rotated = await inviteApi.rotate(sessionId.value);
      inviteRotatedAt.value = rotated.rotatedAt;
      revealUrl.value = rotated.url;
      inviteState.value = 'just-rotated';
    } catch (error) {
      const problem = error as { detail?: string };
      console.error('Invite rotate failed:', problem.detail);
    }
  }

  async function onInviteRevoke(): Promise<void> {
    // window.confirm fallback — see TODO above.
    const ok = globalThis.confirm(
      t('invite.confirmRevokeTitle') + '\n' + t('invite.confirmRevokeBody'),
    );
    if (!ok) return;
    try {
      await inviteApi.revoke(sessionId.value);
      inviteState.value = 'none';
      inviteRotatedAt.value = null;
      revealUrl.value = '';
    } catch (error) {
      const problem = error as { detail?: string };
      console.error('Invite revoke failed:', problem.detail);
    }
  }

  function onInviteCopy(): void {
    // The 'copy' event from AppInviteManager fires when the active-state
    // Copy button is clicked. In 'active' state the plaintext URL is no
    // longer available from the server, so we trigger a rotate instead —
    // this surfaces the new URL in the reveal panel, where the user can
    // copy it from AppSessionShareLinkCard.
    void onInviteRotate();
  }

  function onInviteCloseReveal(): void {
    revealUrl.value = '';
    inviteState.value = inviteRotatedAt.value ? 'active' : 'none';
  }

  // ── DP adjustment form ────────────────────────────────────────────────────
  const dpDelta = ref(1);
  const dpReason = ref('');
  const dpSubmitting = ref(false);
  const dpError = ref('');
  const dpDeltaValid = computed(() => dpDelta.value !== 0);

  // ── Character assignment ─────────────────────────────────────────────────
  const assignSelected = ref<string>('');
  const assignBusy = ref(false);
  const assignError = ref('');

  // ── Realtime (Phase 4 Feature 7.4) ────────────────────────────────────────
  // Single subscription per session — torn down on unmount. The handle's
  // refs drive a small "live" indicator on the DP card; we also watch them
  // to push DP / roll-pushed events into the visible state.
  const realtime = useSessionRealtime(sessionId.value);

  // ── AppSessionHeader bindings (Phase 11 Stream B) ─────────────────────────
  const headerStatus = computed<'online' | 'offline'>(() =>
    realtime.connected.value ? 'online' : 'offline',
  );

  const headerLabels = computed<AppSessionHeaderLabels>(() => ({
    statusOnline: t('header.statusOnline'),
    statusOffline: t('header.statusOffline'),
    dpLabel: t('header.dpLabel'),
    leaveLabel: t('header.leaveLabel'),
    backLabel: t('header.backLabel'),
  }));

  const recentRollPushed = ref<RollPushedPayload | null>(null);
  // Last combat.updated snapshot forwarded to EncounterPanel → CombatTracker.
  const lastCombatSnapshot = ref<CombatUpdatedPayload | null>(null);

  watch(
    () => realtime.lastDpChanged.value,
    (payload: DpChangedPayload | null) => {
      if (!payload || !session.value) return;
      // Patch the visible counter even if we just sent the adjust ourselves —
      // the round-trip already returned the new value, so this is mostly a
      // no-op for the GM's own clicks but the right thing for everyone else
      // sharing the session.
      session.value = { ...session.value, dpCount: payload.dpCount };
      if (isGm.value) {
        // Prepend a synthetic audit row so the trail updates without a
        // refetch. The next page reload (or any subsequent adjust) will
        // pull the canonical row from the server, including its real id.
        const synthetic: DpEvent = {
          id: `live-${String(Date.now())}`,
          gameSessionId: payload.gameSessionId,
          delta: payload.delta,
          source: payload.source as DpSource,
          reason: null,
          rollId: null,
          createdAt: payload.at ?? new Date().toISOString(),
        };
        // Skip if our own adjust just ran — the post-adjust refetch will
        // bring the real row in within ~100 ms.
        const top = dpEvents.value[0];
        if (
          top?.delta !== synthetic.delta ||
          Math.abs(new Date(top.createdAt).getTime() - new Date(synthetic.createdAt).getTime()) >
            5000
        ) {
          dpEvents.value = [synthetic, ...dpEvents.value].slice(0, 20);
        }
      }
    },
  );

  watch(
    () => realtime.lastRollPushed.value,
    (payload: RollPushedPayload | null) => {
      if (!payload) return;
      // Surface the most recent push for ~5 s. A toast component would be
      // nicer; deferring to a later UX pass.
      recentRollPushed.value = payload;
      globalThis.setTimeout(() => {
        if (recentRollPushed.value === payload) recentRollPushed.value = null;
      }, 5000);
    },
  );

  watch(
    () => realtime.lastCombatUpdated.value,
    (payload: CombatUpdatedPayload | null) => {
      if (!payload) return;
      // Replace local snapshot reference — EncounterPanel and CombatTracker
      // consume this via the combatSnapshot prop.
      lastCombatSnapshot.value = payload;
    },
  );

  async function loadSession(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const [s, profile, chars] = await Promise.all([
        sessionsApi.getSession(sessionId.value),
        meApi.get(),
        // The list endpoint defaults to active-only, which is what we want
        // here — drafts are wizard-in-progress and shouldn't be assigned.
        charactersApi.list({ limit: 100 }),
      ]);
      session.value = s;
      me.value = profile;
      myCharacters.value = [...chars.items];
      state.value = 'loaded';
    } catch (error) {
      const problem = error as Problem;
      if (problem.status === 404) {
        state.value = 'notfound';
        return;
      }
      errorMsg.value = problem.detail ?? t('errorLoad');
      state.value = 'error';
    }
  }

  async function loadDpEvents(): Promise<void> {
    if (!session.value || !isGm.value) return;
    try {
      const data = await dpApi.listEvents(sessionId.value, { limit: 20 });
      dpEvents.value = [...data.items];
    } catch (error) {
      const problem = error as Problem;
      // Audit log failure shouldn't sink the rest of the page.
      dpError.value = problem.detail ?? t('errorAuditLoad');
    }
  }

  onMounted(async () => {
    await loadSession();
    // Open the websocket only after the session resolved — on error /
    // notfound the channel doesn't exist server-side and the subscription
    // would be rejected on subscribe().
    if (state.value === 'loaded') {
      void realtime.start();
    }
  });

  onBeforeUnmount(() => {
    void realtime.stop();
  });

  // Once the session resolves and we know whether the user is the GM,
  // pull in the audit log and invite metadata.
  watch(isGm, (now, before) => {
    if (now && !before) {
      void loadDpEvents();
      void loadInviteMetadata();
    }
  });

  async function applyDelta(magnitude: number): Promise<void> {
    dpError.value = '';
    if (magnitude === 0) return;
    dpSubmitting.value = true;
    try {
      const updated = await dpApi.adjust(sessionId.value, {
        delta: magnitude,
        reason: dpReason.value.trim() || undefined,
      });
      session.value = updated;
      dpReason.value = '';
      await loadDpEvents();
    } catch (error) {
      const problem = error as Problem;
      dpError.value = problem.detail ?? t('errorDpAdjust');
    } finally {
      dpSubmitting.value = false;
    }
  }

  async function onApplyForm(): Promise<void> {
    if (!dpDeltaValid.value) {
      dpError.value = t('errorDpDeltaInvalid');
      return;
    }
    await applyDelta(dpDelta.value);
  }

  async function onAssign(): Promise<void> {
    if (!assignSelected.value) return;
    assignError.value = '';
    assignBusy.value = true;
    try {
      await sessionsApi.assignCharacter(sessionId.value, assignSelected.value);
      session.value = await sessionsApi.getSession(sessionId.value);
      assignSelected.value = '';
    } catch (error) {
      const problem = error as Problem;
      assignError.value = problem.detail ?? t('errorAssign');
    } finally {
      assignBusy.value = false;
    }
  }

  async function onUnassign(characterId: string): Promise<void> {
    assignError.value = '';
    try {
      await sessionsApi.unassignCharacter(sessionId.value, characterId);
      session.value = await sessionsApi.getSession(sessionId.value);
    } catch (error) {
      const problem = error as Problem;
      assignError.value = problem.detail ?? t('errorUnassign');
    }
  }

  function formatEventTime(iso: string): string {
    return new Date(iso).toLocaleString(locale.value, {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  }

  function sourceLabel(source: DpEvent['source']): string {
    switch (source) {
      case 'gm-manual': {
        return t('source.gmManual');
      }
      case 'roll-push': {
        return t('source.rollPush');
      }
      case 'system': {
        return t('source.system');
      }
      default: {
        return source;
      }
    }
  }
</script>

<i18n lang="json">
{
  "en": {
    "header": {
      "statusOnline": "Online",
      "statusOffline": "Offline",
      "dpLabel": "Darkness Points",
      "leaveLabel": "Leave",
      "backLabel": "← Back"
    },
    "backToList": "← Back to sessions",
    "loading": "Loading session…",
    "errorLoad": "Couldn't load that session.",
    "errorDpAdjust": "Couldn't adjust DP.",
    "errorDpDeltaInvalid": "Delta must be non-zero.",
    "errorAuditLoad": "Couldn't load DP audit log.",
    "errorAssign": "Couldn't assign that character.",
    "errorUnassign": "Couldn't remove that character.",
    "notFoundHeading": "Session not found",
    "notFoundBody": "It may have been deleted, or you don't have permission to view it.",
    "dpLabel": "Darkness Points",
    "dpAdjustHeading": "Adjust DP",
    "dpAdjustHint": "Positive adds, negative removes. Reason is optional but useful in the audit log.",
    "dpDeltaLabel": "Delta",
    "dpReasonLabel": "Reason",
    "dpReasonPlaceholder": "e.g. Faceless Whisper invoked",
    "dpQuickPlus": "+1",
    "dpQuickMinus": "−1",
    "dpApplyButton": "Apply",
    "auditHeading": "Audit log",
    "auditEmpty": "No DP events yet — adjust above to start the trail.",
    "charactersHeading": "Characters",
    "charactersEmpty": "No characters assigned yet.",
    "assignHeading": "Assign character",
    "assignNoneLeft": "All your active characters are already assigned.",
    "assignButton": "Assign",
    "assignSelectPlaceholder": "Pick a character",
    "removeButton": "Remove",
    "gmBadge": "GM owner",
    "playerBadge": "Player view",
    "liveBadge": "Live",
    "liveDisconnected": "Reconnecting…",
    "rollPushedToast": "Roll pushed: character {character} got {hits} hits.",
    "source": {
      "gmManual": "GM",
      "rollPush": "Roll push",
      "system": "System"
    },
    "invite": {
      "title": "Player invite",
      "blurbNone": "Generate a link your players can use to join this session and link their characters.",
      "ctaGenerate": "Generate invite link",
      "labelActiveSince": "Active since",
      "noteActive": "Current link is valid. Rotating invalidates the old link immediately.",
      "ctaCopy": "Copy link",
      "ctaRotate": "Rotate",
      "ctaRevoke": "Revoke",
      "revealTitleNew": "Your new invite link",
      "revealTitleRotated": "Link rotated",
      "revealClose": "I've copied it — close",
      "revealWarning": "This URL appears once. If you lose it, rotate the invite to generate a new one.",
      "revealCopy": "Copy",
      "revealCopied": "Copied",
      "confirmRevokeTitle": "Revoke invite?",
      "confirmRevokeBody": "Players who open the current link after revoking will see an empty state. Continue?",
      "confirmRotateTitle": "Rotate invite?",
      "confirmRotateBody": "The current link will immediately stop working. You'll need to share the new one with every player."
    }
  },
  "ru": {
    "header": {
      "statusOnline": "Онлайн",
      "statusOffline": "Офлайн",
      "dpLabel": "Пункты тьмы",
      "leaveLabel": "Выйти",
      "backLabel": "← Назад"
    },
    "backToList": "← К списку сессий",
    "loading": "Загружаем сессию…",
    "errorLoad": "Не удалось загрузить сессию.",
    "errorDpAdjust": "Не удалось изменить ПТ.",
    "errorDpDeltaInvalid": "Дельта должна быть ненулевой.",
    "errorAuditLoad": "Не удалось загрузить журнал ПТ.",
    "errorAssign": "Не удалось назначить персонажа.",
    "errorUnassign": "Не удалось снять персонажа.",
    "notFoundHeading": "Сессия не найдена",
    "notFoundBody": "Возможно, она была удалена или у вас нет к ней доступа.",
    "dpLabel": "Пункты тьмы",
    "dpAdjustHeading": "Изменить ПТ",
    "dpAdjustHint": "Положительные добавляют, отрицательные снимают. Причина необязательна, но помогает в журнале.",
    "dpDeltaLabel": "Дельта",
    "dpReasonLabel": "Причина",
    "dpReasonPlaceholder": "напр. «Шёпот Безликого»",
    "dpQuickPlus": "+1",
    "dpQuickMinus": "−1",
    "dpApplyButton": "Применить",
    "auditHeading": "Журнал событий",
    "auditEmpty": "Событий ПТ ещё нет — измените значение выше, чтобы начать журнал.",
    "charactersHeading": "Персонажи",
    "charactersEmpty": "Ни одного персонажа ещё не назначено.",
    "assignHeading": "Назначить персонажа",
    "assignNoneLeft": "Все ваши активные персонажи уже в сессии.",
    "assignButton": "Назначить",
    "assignSelectPlaceholder": "Выберите персонажа",
    "removeButton": "Снять",
    "gmBadge": "ГМ-владелец",
    "playerBadge": "Вид игрока",
    "liveBadge": "Live",
    "liveDisconnected": "Переподключение…",
    "rollPushedToast": "Бросок дожат: персонаж {character} получил {hits} успехов.",
    "source": {
      "gmManual": "ГМ",
      "rollPush": "Дожим броска",
      "system": "Система"
    },
    "invite": {
      "title": "Приглашение игроков",
      "blurbNone": "Создайте ссылку, по которой игроки смогут присоединиться к сессии и привязать персонажей.",
      "ctaGenerate": "Создать ссылку",
      "labelActiveSince": "Активна с",
      "noteActive": "Текущая ссылка действительна. При смене старая немедленно перестаёт работать.",
      "ctaCopy": "Скопировать",
      "ctaRotate": "Сменить",
      "ctaRevoke": "Отозвать",
      "revealTitleNew": "Ваша новая ссылка",
      "revealTitleRotated": "Ссылка обновлена",
      "revealClose": "Скопировал(-а) — закрыть",
      "revealWarning": "Эта ссылка показывается один раз. Если потеряете — придётся сменить инвайт.",
      "revealCopy": "Скопировать",
      "revealCopied": "Скопировано",
      "confirmRevokeTitle": "Отозвать приглашение?",
      "confirmRevokeBody": "После отзыва открывшие старую ссылку увидят пустой экран. Продолжить?",
      "confirmRotateTitle": "Сменить приглашение?",
      "confirmRotateBody": "Старая ссылка немедленно перестанет работать. Новую нужно будет разослать всем игрокам."
    }
  },
  "uk": {
    "header": {
      "statusOnline": "[uk-todo] Online",
      "statusOffline": "[uk-todo] Offline",
      "dpLabel": "[uk-todo] Darkness Points",
      "leaveLabel": "[uk-todo] Leave",
      "backLabel": "[uk-todo] ← Back"
    },
    "backToList": "[uk-todo] Back",
    "loading": "[uk-todo] Loading session",
    "errorLoad": "[uk-todo] Couldn't load",
    "errorDpAdjust": "[uk-todo] Couldn't adjust DP",
    "errorDpDeltaInvalid": "[uk-todo] Delta must be non-zero",
    "errorAuditLoad": "[uk-todo] Couldn't load audit",
    "errorAssign": "[uk-todo] Couldn't assign",
    "errorUnassign": "[uk-todo] Couldn't unassign",
    "notFoundHeading": "[uk-todo] Session not found",
    "notFoundBody": "[uk-todo] May have been deleted",
    "dpLabel": "[uk-todo] Darkness Points",
    "dpAdjustHeading": "[uk-todo] Adjust DP",
    "dpAdjustHint": "[uk-todo] Positive adds, negative removes",
    "dpDeltaLabel": "[uk-todo] Delta",
    "dpReasonLabel": "[uk-todo] Reason",
    "dpReasonPlaceholder": "[uk-todo] e.g. invocation",
    "dpQuickPlus": "[uk-todo] +1",
    "dpQuickMinus": "[uk-todo] -1",
    "dpApplyButton": "[uk-todo] Apply",
    "auditHeading": "[uk-todo] Audit log",
    "auditEmpty": "[uk-todo] No events yet",
    "charactersHeading": "[uk-todo] Characters",
    "charactersEmpty": "[uk-todo] None assigned yet",
    "assignHeading": "[uk-todo] Assign character",
    "assignNoneLeft": "[uk-todo] All assigned",
    "assignButton": "[uk-todo] Assign",
    "assignSelectPlaceholder": "[uk-todo] Pick a character",
    "removeButton": "[uk-todo] Remove",
    "gmBadge": "[uk-todo] GM owner",
    "playerBadge": "[uk-todo] Player view",
    "liveBadge": "[uk-todo] Live",
    "liveDisconnected": "[uk-todo] Reconnecting",
    "rollPushedToast": "[uk-todo] Roll pushed: {character} got {hits} hits.",
    "source": {
      "gmManual": "[uk-todo] GM",
      "rollPush": "[uk-todo] Roll push",
      "system": "[uk-todo] System"
    },
    "invite": {
      "title": "Запрошення гравців",
      "blurbNone": "Створіть посилання, за яким гравці зможуть приєднатися до сесії та прив'язати персонажів.",
      "ctaGenerate": "Створити посилання",
      "labelActiveSince": "Активне з",
      "noteActive": "Поточне посилання дійсне. При зміні старе негайно перестає працювати.",
      "ctaCopy": "Скопіювати",
      "ctaRotate": "Змінити",
      "ctaRevoke": "Відкликати",
      "revealTitleNew": "Ваше нове посилання",
      "revealTitleRotated": "Посилання оновлено",
      "revealClose": "Скопіював(-ла) — закрити",
      "revealWarning": "Це посилання показується лише один раз. Якщо втратите — доведеться змінити інвайт.",
      "revealCopy": "Скопіювати",
      "revealCopied": "Скопійовано",
      "confirmRevokeTitle": "Відкликати запрошення?",
      "confirmRevokeBody": "Після відкликання, хто відкриє старе посилання, побачить порожній екран. Продовжити?",
      "confirmRotateTitle": "Змінити запрошення?",
      "confirmRotateBody": "Старе посилання негайно перестане працювати. Нове потрібно буде розіслати всім гравцям."
    }
  },
  "el": {
    "header": {
      "statusOnline": "[el-todo] Online",
      "statusOffline": "[el-todo] Offline",
      "dpLabel": "[el-todo] Darkness Points",
      "leaveLabel": "[el-todo] Leave",
      "backLabel": "[el-todo] ← Back"
    },
    "backToList": "[el-todo] Back",
    "loading": "[el-todo] Loading session",
    "errorLoad": "[el-todo] Couldn't load",
    "errorDpAdjust": "[el-todo] Couldn't adjust DP",
    "errorDpDeltaInvalid": "[el-todo] Delta must be non-zero",
    "errorAuditLoad": "[el-todo] Couldn't load audit",
    "errorAssign": "[el-todo] Couldn't assign",
    "errorUnassign": "[el-todo] Couldn't unassign",
    "notFoundHeading": "[el-todo] Session not found",
    "notFoundBody": "[el-todo] May have been deleted",
    "dpLabel": "[el-todo] Darkness Points",
    "dpAdjustHeading": "[el-todo] Adjust DP",
    "dpAdjustHint": "[el-todo] Positive adds, negative removes",
    "dpDeltaLabel": "[el-todo] Delta",
    "dpReasonLabel": "[el-todo] Reason",
    "dpReasonPlaceholder": "[el-todo] e.g. invocation",
    "dpQuickPlus": "[el-todo] +1",
    "dpQuickMinus": "[el-todo] -1",
    "dpApplyButton": "[el-todo] Apply",
    "auditHeading": "[el-todo] Audit log",
    "auditEmpty": "[el-todo] No events yet",
    "charactersHeading": "[el-todo] Characters",
    "charactersEmpty": "[el-todo] None assigned yet",
    "assignHeading": "[el-todo] Assign character",
    "assignNoneLeft": "[el-todo] All assigned",
    "assignButton": "[el-todo] Assign",
    "assignSelectPlaceholder": "[el-todo] Pick a character",
    "removeButton": "[el-todo] Remove",
    "gmBadge": "[el-todo] GM owner",
    "playerBadge": "[el-todo] Player view",
    "liveBadge": "[el-todo] Live",
    "liveDisconnected": "[el-todo] Reconnecting",
    "rollPushedToast": "[el-todo] Roll pushed: {character} got {hits} hits.",
    "source": {
      "gmManual": "[el-todo] GM",
      "rollPush": "[el-todo] Roll push",
      "system": "[el-todo] System"
    },
    "invite": {
      "title": "Πρόσκληση παικτών",
      "blurbNone": "Δημιουργήστε έναν σύνδεσμο που οι παίκτες μπορούν να χρησιμοποιήσουν για να συνδεθούν στη συνεδρία και να συνδέσουν τους χαρακτήρες τους.",
      "ctaGenerate": "Δημιουργία συνδέσμου πρόσκλησης",
      "labelActiveSince": "Ενεργό από",
      "noteActive": "Ο τρέχων σύνδεσμος είναι έγκυρος. Η αλλαγή ακυρώνει αμέσως τον παλιό σύνδεσμο.",
      "ctaCopy": "Αντιγραφή",
      "ctaRotate": "Αλλαγή",
      "ctaRevoke": "Ανάκληση",
      "revealTitleNew": "Ο νέος σας σύνδεσμος",
      "revealTitleRotated": "Σύνδεσμος ανανεώθηκε",
      "revealClose": "Αντέγραψα — κλείσιμο",
      "revealWarning": "Αυτό το URL εμφανίζεται μία φορά. Αν το χάσετε, αλλάξτε την πρόσκληση για να δημιουργήσετε ένα νέο.",
      "revealCopy": "Αντιγραφή",
      "revealCopied": "Αντιγράφηκε",
      "confirmRevokeTitle": "Ανάκληση πρόσκλησης;",
      "confirmRevokeBody": "Όσοι ανοίξουν τον τρέχοντα σύνδεσμο μετά την ανάκληση θα δουν μια κενή οθόνη. Συνέχεια;",
      "confirmRotateTitle": "Αλλαγή πρόσκλησης;",
      "confirmRotateBody": "Ο τρέχων σύνδεσμος θα σταματήσει να λειτουργεί αμέσως. Θα πρέπει να μοιραστείτε το νέο με κάθε παίκτη."
    }
  }
}
</i18n>

<template>
  <section class="page-session-detail" data-testid="page-session-detail">
    <NuxtLink to="/app/game-sessions" class="page-session-detail__back">
      {{ t('backToList') }}
    </NuxtLink>

    <p v-if="state === 'loading'" class="page-session-detail__placeholder">
      {{ t('loading') }}
    </p>

    <AppBanner v-else-if="state === 'error'" tone="danger" role="alert">
      {{ errorMsg }}
    </AppBanner>

    <div v-else-if="state === 'notfound'" class="page-session-detail__empty">
      <h2 class="page-session-detail__empty-heading">
        {{ t('notFoundHeading') }}
      </h2>
      <p class="page-session-detail__empty-body">
        {{ t('notFoundBody') }}
      </p>
    </div>

    <template v-else-if="session">
      <!-- Session header (Phase 11 Stream B): replaced inline h1 + badge
           with AppSessionHeader. GM mode — no leave button rendered. -->
      <AppSessionHeader
        mode="gm"
        :session-name="session.name"
        :status="headerStatus"
        :dp-count="session.dpCount"
        :labels="headerLabels"
      />

      <Transition name="fade">
        <AppBanner
          v-if="recentRollPushed"
          tone="success"
          role="status"
          class="page-session-detail__toast"
        >
          {{
            t('rollPushedToast', {
              character:
                assignedCharacters.find((c) => c.id === recentRollPushed?.characterId)?.name ?? '#',
              hits: recentRollPushed.hits,
            })
          }}
        </AppBanner>
      </Transition>

      <div class="page-session-detail__top">
        <AppCard class="page-session-detail__dp">
          <span class="page-session-detail__dp-label">
            {{ t('dpLabel') }}
          </span>
          <span class="page-session-detail__dp-value">
            {{ session.dpCount }}
          </span>
          <AppBadge
            :variant="realtime.connected.value ? 'success' : 'brass'"
            size="sm"
            class="page-session-detail__live-badge"
          >
            {{ realtime.connected.value ? t('liveBadge') : t('liveDisconnected') }}
          </AppBadge>
        </AppCard>

        <AppCard v-if="isGm" class="page-session-detail__dp-controls">
          <h3 class="page-session-detail__panel-title">
            {{ t('dpAdjustHeading') }}
          </h3>
          <p class="page-session-detail__panel-hint">
            {{ t('dpAdjustHint') }}
          </p>
          <AppBanner v-if="dpError" tone="danger" role="alert">
            {{ dpError }}
          </AppBanner>
          <div class="page-session-detail__dp-quick">
            <AppButton variant="ghost" size="sm" :disabled="dpSubmitting" @click="applyDelta(-1)">
              {{ t('dpQuickMinus') }}
            </AppButton>
            <AppButton variant="primary" size="sm" :disabled="dpSubmitting" @click="applyDelta(1)">
              {{ t('dpQuickPlus') }}
            </AppButton>
          </div>
          <form class="page-session-detail__dp-form" novalidate @submit.prevent="onApplyForm">
            <AppField :label="t('dpDeltaLabel')" required>
              <template #default="slotAttrs">
                <AppInput
                  v-bind="slotAttrs"
                  v-model.number="dpDelta"
                  type="number"
                  min="-99"
                  max="99"
                />
              </template>
            </AppField>
            <AppField :label="t('dpReasonLabel')">
              <template #default="slotAttrs">
                <AppInput
                  v-bind="slotAttrs"
                  v-model="dpReason"
                  type="text"
                  maxlength="200"
                  :placeholder="t('dpReasonPlaceholder')"
                />
              </template>
            </AppField>
            <AppButton
              type="submit"
              variant="primary"
              size="sm"
              :loading="dpSubmitting"
              :disabled="!dpDeltaValid || dpSubmitting"
            >
              {{ t('dpApplyButton') }}
            </AppButton>
          </form>
        </AppCard>
      </div>

      <AppCard class="page-session-detail__panel">
        <h3 class="page-session-detail__panel-title">
          {{ t('charactersHeading') }}
        </h3>
        <AppBanner v-if="assignError" tone="danger" role="alert">
          {{ assignError }}
        </AppBanner>
        <p v-if="(session.characterIds.length ?? 0) === 0" class="page-session-detail__panel-hint">
          {{ t('charactersEmpty') }}
        </p>
        <ul v-else class="page-session-detail__char-list" role="list">
          <li
            v-for="characterId in session.characterIds"
            :key="characterId"
            class="page-session-detail__char-row"
          >
            <span class="page-session-detail__char-name">
              {{ assignedCharacters.find((c) => c.id === characterId)?.name ?? `#${characterId}` }}
            </span>
            <AppButton v-if="isGm" variant="ghost" size="sm" @click="onUnassign(characterId)">
              {{ t('removeButton') }}
            </AppButton>
          </li>
        </ul>

        <div v-if="isGm" class="page-session-detail__assign">
          <h4 class="page-session-detail__panel-subtitle">
            {{ t('assignHeading') }}
          </h4>
          <p v-if="assignableCharacters.length === 0" class="page-session-detail__panel-hint">
            {{ t('assignNoneLeft') }}
          </p>
          <form
            v-else
            class="page-session-detail__assign-form"
            novalidate
            @submit.prevent="onAssign"
          >
            <select
              v-model="assignSelected"
              class="page-session-detail__assign-select"
              :disabled="assignBusy"
              :aria-label="t('assignHeading')"
            >
              <option value="" disabled>
                {{ t('assignSelectPlaceholder') }}
              </option>
              <option v-for="c in assignableCharacters" :key="c.id" :value="c.id">
                {{ c.name }}
              </option>
            </select>
            <AppButton
              type="submit"
              variant="primary"
              size="sm"
              :loading="assignBusy"
              :disabled="!assignSelected || assignBusy"
            >
              {{ t('assignButton') }}
            </AppButton>
          </form>
        </div>
      </AppCard>

      <AppCard v-if="isGm" class="page-session-detail__panel">
        <h3 class="page-session-detail__panel-title">
          {{ t('auditHeading') }}
        </h3>
        <p v-if="dpEvents.length === 0" class="page-session-detail__panel-hint">
          {{ t('auditEmpty') }}
        </p>
        <ul v-else class="page-session-detail__audit-list" role="list">
          <li v-for="event in dpEvents" :key="event.id" class="page-session-detail__audit-row">
            <span
              class="page-session-detail__audit-delta"
              :class="{
                'page-session-detail__audit-delta--neg': event.delta < 0,
              }"
            >
              {{ event.delta > 0 ? '+' : '' }}{{ event.delta }}
            </span>
            <span class="page-session-detail__audit-source">
              {{ sourceLabel(event.source) }}
            </span>
            <span v-if="event.reason" class="page-session-detail__audit-reason">
              {{ event.reason }}
            </span>
            <span class="page-session-detail__audit-time">
              {{ formatEventTime(event.createdAt) }}
            </span>
          </li>
        </ul>
      </AppCard>

      <!-- Invite manager (Phase 8 Stream A) — GM only. Surfaces generate /
           rotate / revoke controls and a one-time reveal panel for the
           plaintext invite URL. window.confirm() is used for destructive
           confirmations until a proper modal-confirm primitive is added. -->
      <AppCard v-if="isGm" class="page-session-detail__panel" data-testid="invite-manager-section">
        <AppInviteManager
          :state="inviteState"
          :rotated-at="inviteRotatedAt"
          :reveal-url="revealUrl"
          :labels="{
            title: t('invite.title'),
            blurbNone: t('invite.blurbNone'),
            ctaGenerate: t('invite.ctaGenerate'),
            labelActiveSince: t('invite.labelActiveSince'),
            noteActive: t('invite.noteActive'),
            ctaCopy: t('invite.ctaCopy'),
            ctaRotate: t('invite.ctaRotate'),
            ctaRevoke: t('invite.ctaRevoke'),
            revealTitleNew: t('invite.revealTitleNew'),
            revealTitleRotated: t('invite.revealTitleRotated'),
            revealClose: t('invite.revealClose'),
            revealWarning: t('invite.revealWarning'),
            revealCopy: t('invite.revealCopy'),
            revealCopied: t('invite.revealCopied'),
          }"
          @generate="onInviteGenerate"
          @rotate="onInviteRotate"
          @revoke="onInviteRevoke"
          @copy="onInviteCopy"
          @close-reveal="onInviteCloseReveal"
        />
      </AppCard>

      <!-- Encounters (Block 5) — GM only; players see the combat state
           read-only once a player-view encounter display is designed. -->
      <EncounterPanel
        v-if="isGm"
        :session-id="sessionId"
        :session-character-ids="session?.characterIds ?? []"
        :is-gm="isGm"
        :combat-snapshot="lastCombatSnapshot"
        data-testid="encounter-panel-section"
      />
    </template>
  </section>
</template>

<style lang="scss" scoped>
  $page-max-width: 1200px;

  .page-session-detail {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    padding: var(--space-6);
    max-width: $page-max-width;
    margin: 0 auto;

    &__back {
      align-self: flex-start;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-accent);
      text-decoration: none;

      &:hover {
        text-decoration: underline;
      }
    }

    &__header {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__title-row {
      display: flex;
      align-items: center;
      gap: var(--space-3);
      flex-wrap: wrap;
    }

    &__title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-md-font-size);
      letter-spacing: var(--type-display-md-letter-spacing);
      color: var(--brand-brass-light);
    }

    &__description {
      margin: 0;
      font-family: var(--font-body);
      color: var(--text-secondary);
    }

    &__top {
      display: grid;
      grid-template-columns: minmax(180px, 280px) 1fr;
      gap: var(--space-4);

      @media (max-width: 720px) {
        grid-template-columns: 1fr;
      }
    }

    &__dp {
      padding: var(--space-5);
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
      align-items: center;
      justify-content: center;
    }

    &__dp-label {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.06em;
    }

    &__dp-value {
      font-family: var(--font-display);
      font-size: var(--type-display-xl-font-size);
      color: var(--brand-brass-light);
    }

    &__live-badge {
      align-self: center;
    }

    &__toast {
      // Toast-style banner pinned above the DP card. Animated by the
      // <Transition name="fade"> wrapper.
      margin-bottom: 0;
    }

    &__dp-controls {
      padding: var(--space-4);
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__panel-title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass-light);
    }

    &__panel-subtitle {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-brass-light);
    }

    &__panel-hint {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__dp-quick {
      display: flex;
      gap: var(--space-2);
    }

    &__dp-form {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__panel {
      padding: var(--space-4);
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__char-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__char-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: var(--space-3);
      padding: var(--space-2) var(--space-3);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-sm);
    }

    &__char-name {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
    }

    &__assign {
      margin-top: var(--space-3);
      padding-top: var(--space-3);
      border-top: 1px dashed var(--brand-brass-shadow);
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__assign-form {
      display: flex;
      gap: var(--space-2);
      align-items: center;
    }

    &__assign-select {
      flex: 1;
      padding: var(--space-2) var(--space-3);
      background: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      border-radius: var(--radius-sm);
      color: var(--text-primary);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    &__audit-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
      max-height: 24rem;
      overflow-y: auto;
    }

    &__audit-row {
      display: grid;
      grid-template-columns: 3rem 5rem 1fr auto;
      gap: var(--space-2);
      align-items: center;
      padding: var(--space-2) var(--space-3);
      border-radius: var(--radius-sm);
      font-size: var(--type-body-sm-font-size);

      &:nth-child(odd) {
        background: color-mix(in srgb, var(--brand-brass-shadow) 15%, transparent);
      }
    }

    &__audit-delta {
      font-family: var(--font-mono);
      font-weight: var(--fw-bold);
      color: var(--state-success);

      &--neg {
        color: var(--status-danger);
      }
    }

    &__audit-source {
      font-family: var(--font-body);
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.06em;
      font-size: var(--type-body-xs-font-size);
    }

    &__audit-reason {
      font-family: var(--font-body);
      color: var(--text-primary);
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    &__audit-time {
      font-family: var(--font-mono);
      font-size: var(--type-body-xs-font-size);
      color: var(--text-tertiary);
    }

    &__placeholder {
      margin: 0;
      font-family: var(--font-body);
      color: var(--text-tertiary);
      font-style: italic;
    }

    &__empty {
      padding: var(--space-8) var(--space-4);
      text-align: center;
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-md);
    }

    &__empty-heading {
      margin: 0 0 var(--space-2);
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__empty-body {
      margin: 0;
      font-family: var(--font-body);
      color: var(--text-secondary);
    }
  }
</style>
