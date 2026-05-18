<script setup lang="ts">
  definePageMeta({ layout: 'app', middleware: ['require-gm-role'] });

  import {
    AppCard,
    AppButton,
    AppConfirm,
    AppInput,
    AppField,
    AppBanner,
    AppBadge,
    AppInviteManager,
    AppSessionHeader,
    AppChatPanel,
    AppWhisperPicker,
  } from '@app/ui';
  import type { AppSessionHeaderLabels, AppChatPanelRow, WhisperPickerMember } from '@app/ui';
  import EncounterPanel from '~/components/EncounterPanel.vue';
  import { ref, onMounted, onBeforeUnmount, computed, watch } from 'vue';
  import { useGameSessionsApi } from '~/composables/useGameSessionsApi';
  import { useDpApi } from '~/composables/useDpApi';
  import { useMeApi } from '~/composables/useMeApi';
  import { useInviteApi } from '~/composables/useInviteApi';
  import {
    useSessionRealtime,
    type DpChangedPayload,
    type RollPushedPayload,
    type CombatUpdatedPayload,
  } from '~/composables/useSessionRealtime';
  import { useSessionChatRealtime } from '~/composables/useSessionChatRealtime';
  import { useChatStore } from '~/stores/chat';
  import { listMembers, removeMembership } from '@app/api-client-ts';
  import type { GameSession } from '~/composables/useGameSessionsApi';
  import type { DpEvent, DpSource } from '~/composables/useDpApi';
  import type { Me } from '~/composables/useMeApi';
  import type { Problem, GameSessionMembership } from '@app/api-client-ts';

  /**
   * Session detail (Phase 8 Stream D, Block 8).
   *
   * Adds AppChatPanel (docked mode) in a collapsible right-rail.
   * myMembershipId resolves from listMembers by matching userId === me.value.id.
   * chatDockedCollapsed is persisted via PATCH /api/v1/me (synced across
   * devices since OpenAPI 1.10.0); the localStorage placeholder shipped in
   * Stream D was replaced when the Me schema gained the canonical field.
   */

  const { t, locale } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const sessionsApi = useGameSessionsApi();
  const dpApi = useDpApi();
  const meApi = useMeApi();
  const inviteApi = useInviteApi();

  const sessionId = computed<string>(() => route.params.id as string);

  type LoadState = 'loading' | 'loaded' | 'error' | 'notfound';

  const state = ref<LoadState>('loading');
  const session = ref<GameSession | null>(null);
  const me = ref<Me | null>(null);
  const dpEvents = ref<DpEvent[]>([]);
  const errorMsg = ref('');

  // GM's own membershipId (resolved after session + me load)
  const gmMembershipId = ref<string | null>(null);
  // All session members (for whisper picker + Crew panel)
  const sessionMembers = ref<GameSessionMembership[]>([]);

  const isGm = computed(() => Boolean(me.value && me.value.id === session.value?.ownerId));

  // Character ids linked through memberships — drives the encounter "import linked PCs" picker.
  const linkedCharacterIds = computed<readonly string[]>(
    () =>
      session.value?.memberships
        .map((m) => m.characterId)
        .filter((id): id is string => typeof id === 'string' && id.length > 0) ?? [],
  );

  // ── Chat dock collapsed state (synced via PATCH /me) ──────────────────────
  //
  // Initial value seeds from `me.chatDockedCollapsed` once /me has loaded.
  // Toggle optimistically flips the local ref + PATCH /me; on PATCH error
  // we roll back so the UI never drifts from the server.

  const chatDockCollapsed = ref<boolean>(false);

  async function toggleChatDock(): Promise<void> {
    const previous = chatDockCollapsed.value;
    const next = !previous;
    chatDockCollapsed.value = next;
    try {
      const updated = await meApi.update({ chatDockedCollapsed: next });
      me.value = updated;
    } catch {
      // Server rejected the toggle — restore the previous local state so the
      // header chevron and the panel stay in sync.
      chatDockCollapsed.value = previous;
    }
  }

  // ── Chat panel state ──────────────────────────────────────────────────────

  const whisperPickerOpen = ref(false);
  const confirmDeleteOpen = ref(false);
  const confirmDeleteId = ref<string | null>(null);
  const confirmBlockOpen = ref(false);
  const confirmBlockMembershipId = ref<string | null>(null);

  // ── Chat store + realtime ─────────────────────────────────────────────────

  const chatStore = useChatStore();

  const gmMembershipIdRef = computed<string>(() => gmMembershipId.value ?? '');

  const chatRealtime = useSessionChatRealtime({
    gameSessionId: sessionId,
    myMembershipId: gmMembershipIdRef,
  });

  watch(chatRealtime.lastPosted, (m) => {
    if (m) chatStore.applyRealtime({ type: 'chat.message.posted', message: m as never });
  });
  watch(chatRealtime.lastEdited, (m) => {
    if (m) chatStore.applyRealtime({ type: 'chat.message.edited', message: m as never });
  });
  watch(chatRealtime.lastDeleted, (d) => {
    if (d) chatStore.applyRealtime({ type: 'chat.message.deleted', ...d });
  });

  // ── Day-divider interleave ────────────────────────────────────────────────

  const chatPanelMessages = computed<AppChatPanelRow[]>(() => {
    const msgs = chatStore.activeMessages;
    if (msgs.length === 0) return [];

    const rows: AppChatPanelRow[] = [];
    let lastDateStr = '';

    for (const msg of msgs) {
      const dateStr = new Date(msg.createdAt).toLocaleDateString(locale.value);

      if (dateStr !== lastDateStr) {
        lastDateStr = dateStr;
        rows.push({
          id: `day-${dateStr}`,
          variant: 'day-divider',
          payload: { label: dateStr },
        });
      }

      if (msg.kind === 'system') {
        const systemKey = (msg as unknown as { systemKey?: string }).systemKey ?? '';
        const systemParams =
          (msg as unknown as { systemParams?: Record<string, unknown> }).systemParams ?? {};
        rows.push({
          id: msg.id,
          variant: 'system',
          payload: {
            variant: 'system',
            systemLabel: systemKey
              ? t(systemKey, systemParams as Record<string, string | number>)
              : '',
            createdAtIso: msg.createdAt,
            editedAtIso: null,
            deletedAtIso: null,
            ownByMe: false,
            ownByGm: true,
            canEdit: false,
            canDelete: false,
            canBlock: false,
          },
        });
      } else {
        const isOwnByMe = msg.authorMembershipId === gmMembershipId.value;
        const isWhisper = msg.targetMembershipId !== null;
        const variant = isWhisper ? 'whisper' : isOwnByMe ? 'broadcast-author' : 'broadcast-other';

        rows.push({
          id: msg.id,
          variant,
          payload: {
            variant,
            authorDisplayName: msg.authorDisplayName ?? undefined,
            authorAvatarSrc: null,
            authorPresence: 'offline' as const,
            body: msg.body ?? null,
            createdAtIso: msg.createdAt,
            editedAtIso: msg.editedAt ?? null,
            deletedAtIso: msg.deletedAt ?? null,
            ownByMe: isOwnByMe,
            ownByGm: true,
            canEdit: isOwnByMe && !msg.deletedAt,
            canDelete: !msg.deletedAt, // GM can delete any message
            canBlock: !isOwnByMe && isWhisper && !msg.deletedAt,
          },
        });
      }
    }

    return rows;
  });

  // ── Composer bindings ─────────────────────────────────────────────────────

  const activeConv = computed(() => chatStore.conversations[chatStore.activeConversationKey]);
  const composerValue = computed(() => activeConv.value?.composerValue ?? '');
  const composerKind = computed<'broadcast' | 'whisper'>(() =>
    chatStore.activeConversationKey === 'broadcast' ? 'broadcast' : 'whisper',
  );
  const composerPartnerDisplayName = computed<string | undefined>(() => {
    if (chatStore.activeConversationKey === 'broadcast') return;
    const summary = chatStore.conversationsList.find(
      (c) => c.conversationKey === chatStore.activeConversationKey,
    );
    return summary?.partnerDisplayName ?? summary?.partnerCharacterName ?? undefined;
  });

  const chatPanelBindings = computed(() => ({
    mode: 'docked' as const,
    connectionStatus: chatRealtime.status.value,
    tabs: chatStore.panelTabs,
    activeKey: chatStore.activeConversationKey,
    messages: chatPanelMessages.value,
    composerValue: composerValue.value,
    composerKind: composerKind.value,
    composerPartnerDisplayName: composerPartnerDisplayName.value,
    composerDisabled: chatRealtime.status.value === 'unrecoverable',
    newMessagesCount: chatStore.activeNewMessagesCount,
    composerEditingLabel: editingMessageId.value ? t('chat.composer.editing') : '',
    composerEditingPreview: editingPreview.value,
    composerCancelEditLabel: t('chat.composer.editingCancel'),
  }));

  // ── Pickable members ──────────────────────────────────────────────────────

  const pickableMembers = computed<WhisperPickerMember[]>(() =>
    sessionMembers.value
      .filter(
        (m) =>
          m.id !== gmMembershipId.value &&
          !chatStore.openWhisperKeys.includes(m.id) &&
          !chatStore.blockedByMe.has(m.id),
      )
      .map((m) => ({
        membershipId: m.id,
        displayName: m.displayName ?? m.id,
        characterName: m.characterName ?? null,
        presence: 'offline' as const,
        blockedByMe: false,
      })),
  );

  // ── Chat event handlers ───────────────────────────────────────────────────

  function onComposerUpdate(v: string): void {
    const conv = chatStore.conversations[chatStore.activeConversationKey];
    if (conv) conv.composerValue = v;
  }

  async function onComposerSubmit(): Promise<void> {
    const body = composerValue.value.trim();
    if (!body) return;
    const key = chatStore.activeConversationKey;
    const conv = chatStore.conversations[key];
    if (conv) conv.composerValue = '';

    // If editing, route to the edit verb; the realtime echo will patch
    // the existing row's body + editedAt. Otherwise send a new message.
    if (editingMessageId.value) {
      const idToEdit = editingMessageId.value;
      editingMessageId.value = null;
      editingPreview.value = '';
      await chatStore.edit(idToEdit, body);
      return;
    }

    await chatStore.send(key, body);
  }

  // ── Inline edit affordance ──────────────────────────────────────────────
  //
  // editingMessageId tracks which message the composer is editing. While
  // non-null:
  //   - AppChatPanel shows the edit-banner above the composer
  //   - onComposerSubmit routes to chatStore.edit() instead of send()
  //   - switching tabs cancels the edit (parent watches activeKey)
  const editingMessageId = ref<string | null>(null);
  const editingPreview = ref<string>('');

  function onEditMessage(id: string): void {
    const msg = chatStore.activeMessages.find((m) => m.id === id);
    if (!msg?.body) return;
    const conv = chatStore.conversations[chatStore.activeConversationKey];
    if (!conv) return;
    editingMessageId.value = id;
    editingPreview.value = msg.body;
    conv.composerValue = msg.body;
  }

  function onCancelEdit(): void {
    const conv = chatStore.conversations[chatStore.activeConversationKey];
    if (conv) conv.composerValue = '';
    editingMessageId.value = null;
    editingPreview.value = '';
  }

  // Cancel an in-flight edit if the user switches conversations — the
  // editing-banner would otherwise lie about which thread it belongs to.
  watch(
    () => chatStore.activeConversationKey,
    () => {
      if (editingMessageId.value !== null) {
        onCancelEdit();
      }
    },
  );

  function onDeleteMessage(id: string): void {
    confirmDeleteId.value = id;
    confirmDeleteOpen.value = true;
  }

  async function onConfirmDelete(): Promise<void> {
    if (!confirmDeleteId.value) return;
    await chatStore.delete(confirmDeleteId.value);
    confirmDeleteOpen.value = false;
    confirmDeleteId.value = null;
  }

  function onBlockAuthor(messageId: string): void {
    const msg = chatStore.activeMessages.find((m) => m.id === messageId);
    if (!msg?.authorMembershipId) return;
    confirmBlockMembershipId.value = msg.authorMembershipId;
    confirmBlockOpen.value = true;
  }

  async function onConfirmBlock(): Promise<void> {
    if (!confirmBlockMembershipId.value) return;
    await chatStore.block(confirmBlockMembershipId.value);
    confirmBlockOpen.value = false;
    confirmBlockMembershipId.value = null;
  }

  function onJumpToNewest(): void {
    chatStore.markAsAtBottom(chatStore.activeConversationKey);
  }

  async function onPickWhisper(mId: string): Promise<void> {
    whisperPickerOpen.value = false;
    await chatStore.openWhisper(mId);
  }

  const blockTargetName = computed(() => {
    const m = sessionMembers.value.find((sm) => sm.id === confirmBlockMembershipId.value);
    return m?.displayName ?? confirmBlockMembershipId.value ?? '';
  });

  // ── Invite manager ────────────────────────────────────────────────────────

  type InviteState = 'none' | 'active' | 'just-generated' | 'just-rotated';
  const inviteState = ref<InviteState>('none');
  const inviteRotatedAt = ref<string | null>(null);
  const revealUrl = ref<string>('');
  const inviteRotateConfirmOpen = ref(false);
  const inviteRotateBusy = ref(false);
  const inviteRevokeConfirmOpen = ref(false);
  const inviteRevokeBusy = ref(false);

  // ── Kick member confirm ───────────────────────────────────────────────────
  const kickConfirmOpen = ref(false);
  const kickBusy = ref(false);
  const kickTarget = ref<{ membershipId: string; displayName: string } | null>(null);
  const kickError = ref('');

  function onKickRequest(membershipId: string, displayName: string): void {
    kickTarget.value = { membershipId, displayName };
    kickError.value = '';
    kickConfirmOpen.value = true;
  }

  async function onConfirmKick(): Promise<void> {
    const target = kickTarget.value;
    if (!target) return;
    kickBusy.value = true;
    kickError.value = '';
    try {
      const res = await removeMembership({
        path: { id: sessionId.value, membershipId: target.membershipId },
      });
      if (res.error) {
        const problem = res.error as { detail?: string };
        kickError.value = problem.detail ?? t('crewKickError');
        return;
      }
      // Soft-delete on the server side; refresh local member list.
      sessionMembers.value = sessionMembers.value.filter((m) => m.id !== target.membershipId);
      kickConfirmOpen.value = false;
      kickTarget.value = null;
    } finally {
      kickBusy.value = false;
    }
  }

  async function loadInviteMetadata(): Promise<void> {
    if (!isGm.value) return;
    try {
      const meta = await inviteApi.getMetadata(sessionId.value);
      inviteState.value = meta.active ? 'active' : 'none';
      inviteRotatedAt.value = meta.rotatedAt ?? null;
    } catch {
      // Non-fatal
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
      console.error('Invite generate failed:', problem.detail);
    }
  }

  function onInviteRotate(): void {
    inviteRotateConfirmOpen.value = true;
  }

  async function onConfirmInviteRotate(): Promise<void> {
    inviteRotateBusy.value = true;
    try {
      const rotated = await inviteApi.rotate(sessionId.value);
      inviteRotatedAt.value = rotated.rotatedAt;
      revealUrl.value = rotated.url;
      inviteState.value = 'just-rotated';
      inviteRotateConfirmOpen.value = false;
    } catch (error) {
      const problem = error as { detail?: string };
      console.error('Invite rotate failed:', problem.detail);
    } finally {
      inviteRotateBusy.value = false;
    }
  }

  function onInviteRevoke(): void {
    inviteRevokeConfirmOpen.value = true;
  }

  async function onConfirmInviteRevoke(): Promise<void> {
    inviteRevokeBusy.value = true;
    try {
      await inviteApi.revoke(sessionId.value);
      inviteState.value = 'none';
      inviteRotatedAt.value = null;
      revealUrl.value = '';
      inviteRevokeConfirmOpen.value = false;
    } catch (error) {
      const problem = error as { detail?: string };
      console.error('Invite revoke failed:', problem.detail);
    } finally {
      inviteRevokeBusy.value = false;
    }
  }

  function onInviteCopy(): void {
    onInviteRotate();
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

  // ── Realtime (Phase 4 Feature 7.4) ───────────────────────────────────────
  const realtime = useSessionRealtime(sessionId.value);

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
  const lastCombatSnapshot = ref<CombatUpdatedPayload | null>(null);

  watch(
    () => realtime.lastDpChanged.value,
    (payload: DpChangedPayload | null) => {
      if (!payload || !session.value) return;
      session.value = { ...session.value, dpCount: payload.dpCount };
      if (isGm.value) {
        const synthetic: DpEvent = {
          id: `live-${String(Date.now())}`,
          gameSessionId: payload.gameSessionId,
          delta: payload.delta,
          source: payload.source as DpSource,
          reason: null,
          rollId: null,
          createdAt: payload.at ?? new Date().toISOString(),
        };
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
      lastCombatSnapshot.value = payload;
    },
  );

  // ── Data loading ──────────────────────────────────────────────────────────

  async function loadSession(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const [s, profile] = await Promise.all([
        sessionsApi.getSession(sessionId.value),
        meApi.get(),
      ]);
      session.value = s;
      me.value = profile;
      state.value = 'loaded';

      // Load session members to resolve GM's membershipId and populate whisper picker + Crew panel.
      const membersRes = await listMembers({ path: { id: sessionId.value } });
      if (!membersRes.error) {
        const members = membersRes.data as GameSessionMembership[];
        sessionMembers.value = members;
        // GM's membershipId is the row where userId === me.id
        const gmRow = members.find((m) => m.userId === profile.id);
        gmMembershipId.value = gmRow?.id ?? null;
      }
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
      dpError.value = problem.detail ?? t('errorAuditLoad');
    }
  }

  onMounted(async () => {
    await loadSession();
    if (me.value) {
      chatDockCollapsed.value = me.value.chatDockedCollapsed ?? false;
    }
    if (state.value === 'loaded') {
      void realtime.start();
      if (gmMembershipId.value) {
        await chatStore.hydrate({
          gameSessionId: sessionId.value,
          myMembershipId: gmMembershipId.value,
        });
        await chatRealtime.start();
      }
    }
  });

  onBeforeUnmount(() => {
    void realtime.stop();
    chatRealtime.stop();
  });

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
    "crewHeading": "Crew",
    "crewEmpty": "Share your invite link to bring players to the table.",
    "crewRoleGm": "(GM)",
    "crewKickButton": "Kick",
    "crewKickConfirmTitle": "Remove {name} from the session?",
    "crewKickConfirmBody": "They lose realtime access on their next token refresh (within 5 minutes). Their chat history stays. They can rejoin if you share a fresh invite link.",
    "crewKickError": "Couldn't remove that member.",
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
      "confirmRotateBody": "The current link will immediately stop working. You'll need to share the new one with every player.",
      "confirmCancel": "Cancel"
    },
    "chat": {
      "dock": {
        "expand": "▶",
        "collapse": "◀"
      },
      "connection": {
        "connecting": "Connecting…",
        "subscribed": "Live",
        "unrecoverable": "Reconnecting",
        "disconnected": "Offline"
      },
      "composer": {
        "placeholder": {
          "broadcast": "Message everyone…",
          "whisper": "Whisper to {name}…"
        },
        "counter": "{count} / {max}",
        "editing": "Editing message",
        "editingCancel": "Cancel"
      },
      "tabs": {
        "broadcast": "Everyone",
        "add_whisper": "Whisper",
        "overflow": "+{count} more"
      },
      "message": {
        "edited": "edited",
        "deleted": "Message deleted",
        "menu": {
          "edit": "Edit",
          "delete": "Delete",
          "block": "Block in this session"
        },
        "delete_confirm": {
          "title": "Delete this message?",
          "body": "Everyone in the conversation will see 'Message deleted' instead. This can't be undone."
        }
      },
      "confirm_cancel": "Cancel",
      "block": {
        "confirm": {
          "title": "Block {name}?",
          "body": "{name} won't be able to whisper you in this session. Existing history stays.",
          "confirm": "Block"
        }
      },
      "whisper_picker": {
        "title": "Whisper to…",
        "empty": "No one available."
      },
      "system": {
        "member_joined": "{displayName} joined the session.",
        "member_left": "{displayName} left the session.",
        "member_kicked": "{displayName} was removed.",
        "roll_pushed": "{characterName} pushed the roll ({pushedCount} dice, +{dpDelta} DP).",
        "encounter_started": "Encounter started.",
        "round_advanced": "Round {round}.",
        "encounter_ended": "Encounter ended."
      }
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
    "crewHeading": "Экипаж",
    "crewEmpty": "Поделитесь ссылкой-приглашением, чтобы пригласить игроков за стол.",
    "crewRoleGm": "(ГМ)",
    "crewKickButton": "Удалить",
    "crewKickConfirmTitle": "Удалить {name} из сессии?",
    "crewKickConfirmBody": "Доступ к реалтайму пропадёт у игрока на следующем обновлении токена (в течение 5 минут). История чата остаётся. Игрок сможет вернуться, если вы пришлёте новую ссылку-приглашение.",
    "crewKickError": "Не удалось удалить участника.",
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
      "confirmRotateBody": "Старая ссылка немедленно перестанет работать. Новую нужно будет разослать всем игрокам.",
      "confirmCancel": "Отмена"
    },
    "chat": {
      "dock": {
        "expand": "▶",
        "collapse": "◀"
      },
      "connection": {
        "connecting": "Подключение…",
        "subscribed": "Онлайн",
        "unrecoverable": "Переподключение",
        "disconnected": "Не в сети"
      },
      "composer": {
        "placeholder": {
          "broadcast": "Написать всем…",
          "whisper": "Шёпотом к {name}…"
        },
        "counter": "{count} / {max}",
        "editing": "Редактирование сообщения",
        "editingCancel": "Отмена"
      },
      "tabs": {
        "broadcast": "Все",
        "add_whisper": "Шёпот",
        "overflow": "+{count} ещё"
      },
      "message": {
        "edited": "изм.",
        "deleted": "Сообщение удалено",
        "menu": {
          "edit": "Изменить",
          "delete": "Удалить",
          "block": "Заблокировать в этой сессии"
        },
        "delete_confirm": {
          "title": "Удалить сообщение?",
          "body": "Все участники беседы увидят вместо него «Сообщение удалено». Действие необратимо."
        }
      },
      "confirm_cancel": "Отмена",
      "block": {
        "confirm": {
          "title": "Заблокировать {name}?",
          "body": "{name} не сможет писать вам шёпотом в этой сессии. Существующая история останется видимой.",
          "confirm": "Заблокировать"
        }
      },
      "whisper_picker": {
        "title": "Кому шепнуть",
        "empty": "Нет доступных участников."
      },
      "system": {
        "member_joined": "{displayName} вошёл в сессию.",
        "member_left": "{displayName} вышел из сессии.",
        "member_kicked": "{displayName} удалён из сессии.",
        "roll_pushed": "{characterName} перебросил ({pushedCount} кубов, +{dpDelta} DP).",
        "encounter_started": "Столкновение началось.",
        "round_advanced": "Раунд {round}.",
        "encounter_ended": "Столкновение завершено."
      }
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
                sessionMembers.find((m) => m.characterId === recentRollPushed?.characterId)
                  ?.characterName ?? '#',
              hits: recentRollPushed.hits,
            })
          }}
        </AppBanner>
      </Transition>

      <!-- Main content + right-rail chat dock -->
      <div class="page-session-detail__layout">
        <!-- Left: existing content column -->
        <div class="page-session-detail__content">
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
                <AppButton
                  variant="ghost"
                  size="sm"
                  :disabled="dpSubmitting"
                  @click="applyDelta(-1)"
                >
                  {{ t('dpQuickMinus') }}
                </AppButton>
                <AppButton
                  variant="primary"
                  size="sm"
                  :disabled="dpSubmitting"
                  @click="applyDelta(1)"
                >
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

          <AppCard class="page-session-detail__panel" data-testid="crew-panel">
            <h3 class="page-session-detail__panel-title">
              {{ t('crewHeading') }}
            </h3>
            <p
              v-if="sessionMembers.filter((m) => m.role !== 'gm').length === 0"
              class="page-session-detail__panel-hint"
            >
              {{ t('crewEmpty') }}
            </p>
            <ul v-else class="page-session-detail__char-list" role="list">
              <li
                v-for="member in sessionMembers"
                :key="member.id"
                class="page-session-detail__char-row"
              >
                <span class="page-session-detail__char-name">
                  {{ member.displayName ?? member.userId }}
                  <span v-if="member.role === 'gm'" class="page-session-detail__crew-role">
                    {{ t('crewRoleGm') }}
                  </span>
                  <span v-if="member.characterName" class="page-session-detail__crew-character">
                    — {{ member.characterName }}
                  </span>
                </span>
                <AppButton
                  v-if="isGm && member.role !== 'gm'"
                  variant="ghost"
                  size="sm"
                  :data-testid="`crew-kick-${member.id}`"
                  @click="onKickRequest(member.id, member.displayName ?? member.userId)"
                >
                  {{ t('crewKickButton') }}
                </AppButton>
              </li>
            </ul>
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

          <AppCard
            v-if="isGm"
            class="page-session-detail__panel"
            data-testid="invite-manager-section"
          >
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

          <EncounterPanel
            v-if="isGm"
            :session-id="sessionId"
            :session-character-ids="linkedCharacterIds"
            :is-gm="isGm"
            :combat-snapshot="lastCombatSnapshot"
            data-testid="encounter-panel-section"
          />
        </div>

        <!-- Right: collapsible chat dock (Overview right-rail) -->
        <div
          class="page-session-detail__chat-rail"
          :class="{ 'page-session-detail__chat-rail--collapsed': chatDockCollapsed }"
        >
          <button
            class="page-session-detail__chat-dock-toggle"
            :aria-label="chatDockCollapsed ? t('chat.dock.expand') : t('chat.dock.collapse')"
            :aria-expanded="!chatDockCollapsed"
            @click="toggleChatDock"
          >
            {{ chatDockCollapsed ? t('chat.dock.expand') : t('chat.dock.collapse') }}
          </button>

          <AppChatPanel
            v-show="!chatDockCollapsed"
            class="page-session-detail__chat-panel"
            v-bind="chatPanelBindings"
            @select-tab="(k) => chatStore.setActiveConversationKey(k)"
            @close-tab="(k) => chatStore.closeWhisper(k)"
            @add-whisper="whisperPickerOpen = true"
            @update:composer-value="onComposerUpdate"
            @submit="onComposerSubmit"
            @edit-message="onEditMessage"
            @cancel-edit="onCancelEdit"
            @delete-message="onDeleteMessage"
            @block-author="onBlockAuthor"
            @jump-to-newest="onJumpToNewest"
          />
        </div>
      </div>

      <!-- Whisper picker modal -->
      <AppWhisperPicker
        :open="whisperPickerOpen"
        :members="pickableMembers"
        @close="whisperPickerOpen = false"
        @pick="onPickWhisper"
      />

      <!-- Delete confirm -->
      <AppConfirm
        v-model:open="confirmDeleteOpen"
        tone="danger"
        :title="t('chat.message.delete_confirm.title')"
        :body="t('chat.message.delete_confirm.body')"
        :confirm-label="t('chat.message.menu.delete')"
        :cancel-label="t('chat.confirm_cancel')"
        @confirm="onConfirmDelete"
      />

      <!-- Block confirm -->
      <AppConfirm
        v-model:open="confirmBlockOpen"
        tone="danger"
        :title="t('chat.block.confirm.title', { name: blockTargetName })"
        :body="t('chat.block.confirm.body', { name: blockTargetName })"
        :confirm-label="t('chat.block.confirm.confirm')"
        :cancel-label="t('chat.confirm_cancel')"
        @confirm="onConfirmBlock"
      />

      <!-- Invite rotate confirm -->
      <AppConfirm
        v-model:open="inviteRotateConfirmOpen"
        tone="danger"
        :title="t('invite.confirmRotateTitle')"
        :body="t('invite.confirmRotateBody')"
        :confirm-label="t('invite.ctaRotate')"
        :cancel-label="t('invite.confirmCancel')"
        :loading="inviteRotateBusy"
        @confirm="onConfirmInviteRotate"
      />

      <!-- Invite revoke confirm -->
      <AppConfirm
        v-model:open="inviteRevokeConfirmOpen"
        tone="danger"
        :title="t('invite.confirmRevokeTitle')"
        :body="t('invite.confirmRevokeBody')"
        :confirm-label="t('invite.ctaRevoke')"
        :cancel-label="t('invite.confirmCancel')"
        :loading="inviteRevokeBusy"
        @confirm="onConfirmInviteRevoke"
      />

      <!-- Kick member confirm -->
      <AppConfirm
        v-model:open="kickConfirmOpen"
        tone="danger"
        :title="t('crewKickConfirmTitle', { name: kickTarget?.displayName ?? '' })"
        :body="t('crewKickConfirmBody')"
        :confirm-label="t('crewKickButton')"
        :cancel-label="t('invite.confirmCancel')"
        :loading="kickBusy"
        data-testid="crew-kick-confirm"
        @confirm="onConfirmKick"
      />
      <AppBanner v-if="kickError" tone="danger" role="alert">
        {{ kickError }}
      </AppBanner>
    </template>
  </section>
</template>

<style lang="scss" scoped>
  $page-max-width: 1200px;
  $chat-rail-width: 340px;
  $chat-rail-collapsed-width: 28px;

  .page-session-detail {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    padding: var(--space-6);
    width: 100%;
    max-width: $page-max-width;
    margin: 0 auto;
    min-width: 0;

    @media (max-width: 768px) {
      padding: var(--space-4) var(--space-3);
    }

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

    // ── Main content + right-rail layout ────────────────────────────────────

    &__layout {
      display: flex;
      gap: var(--space-4);
      align-items: flex-start;
      min-height: 0;
    }

    &__content {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: var(--space-5);
      min-width: 0;
    }

    // ── Chat right-rail ──────────────────────────────────────────────────────

    &__chat-rail {
      flex-shrink: 0;
      width: $chat-rail-width;
      display: flex;
      flex-direction: row;
      align-items: flex-start;
      gap: 0;
      transition: width var(--motion-duration) var(--motion-ease-standard);
      height: 80vh;

      &--collapsed {
        width: $chat-rail-collapsed-width;
      }
    }

    &__chat-dock-toggle {
      width: $chat-rail-collapsed-width;
      flex-shrink: 0;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      background: var(--surface-night);
      border: none;
      border-left: 2px solid var(--brand-brass-deep);
      color: var(--brand-brass);
      font-size: var(--type-body-xs-font-size);
      cursor: pointer;
      padding: 0;
      writing-mode: vertical-rl;
      letter-spacing: 0.08em;

      &:hover {
        background: color-mix(in srgb, var(--brand-brass-deep) 20%, var(--surface-night));
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: -2px;
      }
    }

    &__chat-panel {
      flex: 1;
      height: 100%;
      border-left: 2px solid var(--brand-brass-deep);
      background: var(--surface-night);
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

    // Inline confirm-dialog styles removed — AppConfirm primitive owns this now.
  }
</style>
