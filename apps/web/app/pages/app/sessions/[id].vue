<script setup lang="ts">
  definePageMeta({
    layout: 'app',
    middleware: ['require-session-membership'],
  });

  import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue';
  import { AppSessionHeader, AppBanner, AppChatPanel, AppWhisperPicker } from '@app/ui';
  import type { AppSessionHeaderLabels, AppChatPanelRow, WhisperPickerMember } from '@app/ui';
  import { useGameSessionsApi } from '~/composables/useGameSessionsApi';
  import { useMyMembershipsApi } from '~/composables/useMyMembershipsApi';
  import { useSessionRealtime, type DpChangedPayload } from '~/composables/useSessionRealtime';
  import { useSessionChatRealtime } from '~/composables/useSessionChatRealtime';
  import { useChatStore } from '~/stores/chat';
  import { listMembers } from '@app/api-client-ts';
  import type { GameSession, Problem, GameSessionMembership } from '@app/api-client-ts';

  /**
   * Player session shell (Phase 8 Stream D, Block 8).
   *
   * Wires AppChatPanel (primary mode) to useChatStore + useSessionChatRealtime.
   * myMembershipId resolves from GET /me/memberships (already fetched in load()).
   */

  const { t, locale } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const sessionsApi = useGameSessionsApi();
  const membershipsApi = useMyMembershipsApi();

  const sessionId = computed<string>(() => route.params.id as string);

  type LoadState = 'loading' | 'loaded' | 'error' | 'notfound';

  const state = ref<LoadState>('loading');
  const session = ref<GameSession | null>(null);
  const membershipId = ref<string | null>(null);
  const errorMsg = ref('');
  const leaving = ref(false);
  const leaveError = ref('');

  // Session members (for whisper picker)
  const sessionMembers = ref<GameSessionMembership[]>([]);

  // Chat panel state
  const whisperPickerOpen = ref(false);
  const confirmDeleteOpen = ref(false);
  const confirmDeleteId = ref<string | null>(null);
  const confirmBlockOpen = ref(false);
  const confirmBlockMembershipId = ref<string | null>(null);
  // ── Chat store + realtime ──────────────────────────────────────────────────

  const chatStore = useChatStore();

  // Derived ref for the composable (needs Ref<string>)
  const myMembershipIdRef = computed<string>(() => membershipId.value ?? '');

  const chatRealtime = useSessionChatRealtime({
    gameSessionId: sessionId,
    myMembershipId: myMembershipIdRef,
  });

  // Wire realtime publications → store
  watch(chatRealtime.lastPosted, (m) => {
    if (m) chatStore.applyRealtime({ type: 'chat.message.posted', message: m as never });
  });
  watch(chatRealtime.lastEdited, (m) => {
    if (m) chatStore.applyRealtime({ type: 'chat.message.edited', message: m as never });
  });
  watch(chatRealtime.lastDeleted, (d) => {
    if (d) chatStore.applyRealtime({ type: 'chat.message.deleted', ...d });
  });

  // ── Realtime (encounter / DP) ─────────────────────────────────────────────

  const realtime = useSessionRealtime(sessionId.value);

  watch(
    () => realtime.lastDpChanged.value,
    (payload: DpChangedPayload | null) => {
      if (!payload || !session.value) return;
      session.value = { ...session.value, dpCount: payload.dpCount };
    },
  );

  const headerStatus = computed<'online' | 'offline'>(() =>
    realtime.connected.value ? 'online' : 'offline',
  );

  const headerLabels = computed<AppSessionHeaderLabels>(() => ({
    statusOnline: t('statusOnline'),
    statusOffline: t('statusOffline'),
    dpLabel: t('dpLabel'),
    leaveLabel: t('leaveLabel'),
    backLabel: t('backLabel'),
  }));

  // ── Day-divider interleave ────────────────────────────────────────────────

  /**
   * Interleave day-divider rows between messages whose date differs.
   * System messages map to the 'system' variant; broadcast/whisper messages
   * map based on authorship and kind.
   */
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
        // System messages: resolve the label via i18n using systemKey + systemParams
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
            ownByGm: false,
            canEdit: false,
            canDelete: false,
            canBlock: false,
          },
        });
      } else {
        const isOwnByMe = msg.authorMembershipId === membershipId.value;
        const isWhisper = msg.targetMembershipId !== null;
        const variant = isWhisper ? 'whisper' : isOwnByMe ? 'broadcast-author' : 'broadcast-other';

        rows.push({
          id: msg.id,
          variant,
          payload: {
            variant,
            authorDisplayName: msg.authorDisplayName ?? undefined,
            authorAvatarSrc: null,
            authorPresence: 'offline',
            body: msg.body ?? null,
            createdAtIso: msg.createdAt,
            editedAtIso: msg.editedAt ?? null,
            deletedAtIso: msg.deletedAt ?? null,
            ownByMe: isOwnByMe,
            ownByGm: false,
            canEdit: isOwnByMe && !msg.deletedAt,
            canDelete: isOwnByMe && !msg.deletedAt,
            canBlock: !isOwnByMe && isWhisper && !msg.deletedAt,
          },
        });
      }
    }

    return rows;
  });

  // ── Composer + conversation bindings ─────────────────────────────────────

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
    mode: 'primary' as const,
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

  // ── Pickable members for whisper picker ───────────────────────────────────

  const pickableMembers = computed<WhisperPickerMember[]>(() =>
    sessionMembers.value
      .filter(
        (m) =>
          m.id !== membershipId.value &&
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

  // ── Event handlers ────────────────────────────────────────────────────────

  function onComposerUpdate(v: string): void {
    const conv = chatStore.conversations[chatStore.activeConversationKey];
    if (conv) conv.composerValue = v;
  }

  async function onComposerSubmit(): Promise<void> {
    const body = composerValue.value.trim();
    if (!body) return;
    const key = chatStore.activeConversationKey;
    // Clear composer before send so it feels instant
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
    // Resolve authorMembershipId from the message id
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

  // ── Confirm dialog helpers (block / delete) ────────────────────────────────

  const blockTargetName = computed(() => {
    const m = sessionMembers.value.find((sm) => sm.id === confirmBlockMembershipId.value);
    return m?.displayName ?? confirmBlockMembershipId.value ?? '';
  });

  // ── Load ──────────────────────────────────────────────────────────────────

  async function load(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const [s, memberships] = await Promise.all([
        sessionsApi.getSession(sessionId.value),
        membershipsApi.list(),
      ]);
      session.value = s;
      const m = memberships.find((x) => x.gameSessionId === sessionId.value);
      membershipId.value = m?.membershipId ?? null;
      state.value = 'loaded';

      // Load session members for the whisper picker
      if (membershipId.value) {
        const membersRes = await listMembers({ path: { id: sessionId.value } });
        if (!membersRes.error) {
          sessionMembers.value = membersRes.data as GameSessionMembership[];
        }
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

  async function onLeave(): Promise<void> {
    if (!membershipId.value) return;
    leaveError.value = '';
    leaving.value = true;
    try {
      await membershipsApi.leave(sessionId.value, membershipId.value);
      await navigateTo('/app/sessions');
    } catch (error) {
      const problem = error as Problem;
      leaveError.value = problem.detail ?? t('errorLeave');
    } finally {
      leaving.value = false;
    }
  }

  onMounted(async () => {
    await load();
    if (state.value === 'loaded') {
      void realtime.start();
      if (membershipId.value) {
        await chatStore.hydrate({
          gameSessionId: sessionId.value,
          myMembershipId: membershipId.value,
        });
        await chatRealtime.start();
      }
    }
  });

  onBeforeUnmount(() => {
    void realtime.stop();
    chatRealtime.stop();
  });
</script>

<i18n lang="json">
{
  "en": {
    "loading": "Loading session…",
    "errorLoad": "Couldn't load that session.",
    "errorLeave": "Couldn't leave the session. Please try again.",
    "notFoundHeading": "Session not found",
    "notFoundBody": "It may have been deleted, or you don't have permission to view it.",
    "statusOnline": "Online",
    "statusOffline": "Offline",
    "dpLabel": "Darkness Points",
    "leaveLabel": "Leave session",
    "backLabel": "← Back",
    "encounterPlaceholder": "Encounter view coming soon",
    "chat": {
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
      "new_messages": {
        "pill": "{count, plural, one {# new message} other {# new messages}} ↓"
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
        }
      },
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
    "loading": "Загружаем сессию…",
    "errorLoad": "Не удалось загрузить сессию.",
    "errorLeave": "Не удалось покинуть сессию. Попробуйте ещё раз.",
    "notFoundHeading": "Сессия не найдена",
    "notFoundBody": "Возможно, она была удалена или у вас нет к ней доступа.",
    "statusOnline": "Онлайн",
    "statusOffline": "Офлайн",
    "dpLabel": "Пункты тьмы",
    "leaveLabel": "Покинуть сессию",
    "backLabel": "← Назад",
    "encounterPlaceholder": "Отображение столкновения — скоро",
    "chat": {
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
      "new_messages": {
        "pill": "{count, plural, one {# новое сообщение} few {# новых сообщения} many {# новых сообщений} other {# новых сообщений}} ↓"
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
        }
      },
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
  },
  "uk": {
    "loading": "[uk-todo] Loading session…",
    "errorLoad": "[uk-todo] Couldn't load that session.",
    "errorLeave": "[uk-todo] Couldn't leave the session.",
    "notFoundHeading": "[uk-todo] Session not found",
    "notFoundBody": "[uk-todo] May have been deleted.",
    "statusOnline": "[uk-todo] Online",
    "statusOffline": "[uk-todo] Offline",
    "dpLabel": "[uk-todo] Darkness Points",
    "leaveLabel": "[uk-todo] Leave session",
    "backLabel": "[uk-todo] ← Back",
    "encounterPlaceholder": "[uk-todo] Encounter view coming soon",
    "chat": {
      "connection": {
        "connecting": "[uk-todo] Connecting…",
        "subscribed": "[uk-todo] Live",
        "unrecoverable": "[uk-todo] Reconnecting",
        "disconnected": "[uk-todo] Offline"
      },
      "composer": {
        "placeholder": {
          "broadcast": "[uk-todo] Message everyone…",
          "whisper": "[uk-todo] Whisper to {name}…"
        },
        "counter": "{count} / {max}",
        "editing": "[uk-todo] Editing message",
        "editingCancel": "[uk-todo] Cancel"
      },
      "new_messages": {
        "pill": "[uk-todo] {count} new messages ↓"
      },
      "tabs": {
        "broadcast": "[uk-todo] Everyone",
        "add_whisper": "[uk-todo] Whisper",
        "overflow": "[uk-todo] +{count} more"
      },
      "message": {
        "edited": "[uk-todo] edited",
        "deleted": "[uk-todo] Message deleted",
        "menu": {
          "edit": "[uk-todo] Edit",
          "delete": "[uk-todo] Delete",
          "block": "[uk-todo] Block in this session"
        }
      },
      "block": {
        "confirm": {
          "title": "[uk-todo] Block {name}?",
          "body": "[uk-todo] {name} won't be able to whisper you.",
          "confirm": "[uk-todo] Block"
        }
      },
      "whisper_picker": {
        "title": "[uk-todo] Whisper to…",
        "empty": "[uk-todo] No one available."
      },
      "system": {
        "member_joined": "[uk-todo] {displayName} joined the session.",
        "member_left": "[uk-todo] {displayName} left the session.",
        "member_kicked": "[uk-todo] {displayName} was removed.",
        "roll_pushed": "[uk-todo] {characterName} pushed the roll ({pushedCount} dice, +{dpDelta} DP).",
        "encounter_started": "[uk-todo] Encounter started.",
        "round_advanced": "[uk-todo] Round {round}.",
        "encounter_ended": "[uk-todo] Encounter ended."
      }
    }
  },
  "el": {
    "loading": "[el-todo] Loading session…",
    "errorLoad": "[el-todo] Couldn't load that session.",
    "errorLeave": "[el-todo] Couldn't leave the session.",
    "notFoundHeading": "[el-todo] Session not found",
    "notFoundBody": "[el-todo] May have been deleted.",
    "statusOnline": "[el-todo] Online",
    "statusOffline": "[el-todo] Offline",
    "dpLabel": "[el-todo] Darkness Points",
    "leaveLabel": "[el-todo] Leave session",
    "backLabel": "[el-todo] ← Back",
    "encounterPlaceholder": "[el-todo] Encounter view coming soon",
    "chat": {
      "connection": {
        "connecting": "[el-todo] Connecting…",
        "subscribed": "[el-todo] Live",
        "unrecoverable": "[el-todo] Reconnecting",
        "disconnected": "[el-todo] Offline"
      },
      "composer": {
        "placeholder": {
          "broadcast": "[el-todo] Message everyone…",
          "whisper": "[el-todo] Whisper to {name}…"
        },
        "counter": "{count} / {max}",
        "editing": "[el-todo] Editing message",
        "editingCancel": "[el-todo] Cancel"
      },
      "new_messages": {
        "pill": "[el-todo] {count} new messages ↓"
      },
      "tabs": {
        "broadcast": "[el-todo] Everyone",
        "add_whisper": "[el-todo] Whisper",
        "overflow": "[el-todo] +{count} more"
      },
      "message": {
        "edited": "[el-todo] edited",
        "deleted": "[el-todo] Message deleted",
        "menu": {
          "edit": "[el-todo] Edit",
          "delete": "[el-todo] Delete",
          "block": "[el-todo] Block in this session"
        }
      },
      "block": {
        "confirm": {
          "title": "[el-todo] Block {name}?",
          "body": "[el-todo] {name} won't be able to whisper you.",
          "confirm": "[el-todo] Block"
        }
      },
      "whisper_picker": {
        "title": "[el-todo] Whisper to…",
        "empty": "[el-todo] No one available."
      },
      "system": {
        "member_joined": "[el-todo] {displayName} joined the session.",
        "member_left": "[el-todo] {displayName} left the session.",
        "member_kicked": "[el-todo] {displayName} was removed.",
        "roll_pushed": "[el-todo] {characterName} pushed the roll ({pushedCount} dice, +{dpDelta} DP).",
        "encounter_started": "[el-todo] Encounter started.",
        "round_advanced": "[el-todo] Round {round}.",
        "encounter_ended": "[el-todo] Encounter ended."
      }
    }
  }
}
</i18n>

<template>
  <div class="session-player">
    <p v-if="state === 'loading'" class="session-player__placeholder">
      {{ t('loading') }}
    </p>

    <AppBanner v-else-if="state === 'error'" tone="danger" role="alert">
      {{ errorMsg }}
    </AppBanner>

    <div v-else-if="state === 'notfound'" class="session-player__empty">
      <h2 class="session-player__empty-heading">
        {{ t('notFoundHeading') }}
      </h2>
      <p class="session-player__empty-body">
        {{ t('notFoundBody') }}
      </p>
    </div>

    <template v-else-if="session">
      <AppSessionHeader
        mode="player"
        :session-name="session.name"
        :status="headerStatus"
        :dp-count="session.dpCount"
        :labels="headerLabels"
        @leave="onLeave"
      />

      <AppBanner v-if="leaveError" tone="danger" role="alert" class="session-player__leave-error">
        {{ leaveError }}
      </AppBanner>

      <div class="session-player__body">
        <!-- Chat panel (Stream D) -->
        <AppChatPanel
          v-bind="chatPanelBindings"
          class="session-player__chat"
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

        <div class="session-player__encounter-placeholder">
          {{ t('encounterPlaceholder') }}
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
      <div
        v-if="confirmDeleteOpen"
        class="session-player__confirm-overlay"
        role="dialog"
        :aria-label="t('chat.message.menu.delete')"
      >
        <div class="session-player__confirm-box">
          <p class="session-player__confirm-msg">
            {{ t('chat.message.deleted') }}
          </p>
          <div class="session-player__confirm-actions">
            <AppBanner tone="danger" role="none" class="session-player__confirm-warn">
              {{ t('chat.message.menu.delete') }}?
            </AppBanner>
            <div class="session-player__confirm-btns">
              <button
                class="session-player__confirm-btn session-player__confirm-btn--cancel"
                @click="confirmDeleteOpen = false"
              >
                ✕
              </button>
              <button
                class="session-player__confirm-btn session-player__confirm-btn--danger"
                @click="onConfirmDelete"
              >
                {{ t('chat.message.menu.delete') }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Block confirm -->
      <div
        v-if="confirmBlockOpen"
        class="session-player__confirm-overlay"
        role="dialog"
        :aria-label="t('chat.block.confirm.title', { name: blockTargetName })"
      >
        <div class="session-player__confirm-box">
          <p class="session-player__confirm-title">
            {{ t('chat.block.confirm.title', { name: blockTargetName }) }}
          </p>
          <p class="session-player__confirm-msg">
            {{ t('chat.block.confirm.body', { name: blockTargetName }) }}
          </p>
          <div class="session-player__confirm-btns">
            <button
              class="session-player__confirm-btn session-player__confirm-btn--cancel"
              @click="confirmBlockOpen = false"
            >
              ✕
            </button>
            <button
              class="session-player__confirm-btn session-player__confirm-btn--danger"
              @click="onConfirmBlock"
            >
              {{ t('chat.block.confirm.confirm') }}
            </button>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<style lang="scss" scoped>
  $chat-min-height: 400px;
  $confirm-box-max-width: 420px;

  .session-player {
    display: flex;
    flex-direction: column;
    height: 100%;
    min-height: 0;

    &__placeholder {
      margin: var(--space-6);
      font-family: var(--font-body);
      color: var(--text-tertiary);
      font-style: italic;
    }

    &__empty {
      padding: var(--space-8) var(--space-4);
      text-align: center;
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      margin: var(--space-6);
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

    &__leave-error {
      margin: var(--space-3) var(--space-4);
    }

    &__body {
      flex: 1;
      display: grid;
      grid-template-columns: 1fr;
      gap: var(--space-4);
      padding: var(--space-4);
      min-height: 0;
    }

    &__chat {
      min-height: $chat-min-height;
      border-radius: var(--radius-md);
      border: 1px solid var(--brand-brass-deep);
    }

    &__encounter-placeholder {
      display: flex;
      align-items: center;
      justify-content: center;
      padding: var(--space-6);
      background: var(--surface-night);
      border: 1px dashed var(--brand-brass-shadow);
      border-radius: var(--radius-md);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-tertiary);
      font-style: italic;
    }

    // ── Inline confirm dialogs ─────────────────────────────────────────────

    &__confirm-overlay {
      position: fixed;
      inset: 0;
      background: color-mix(in srgb, var(--surface-void) 80%, transparent);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: var(--z-modal);
    }

    &__confirm-box {
      background: var(--surface-night);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
      padding: var(--space-5);
      max-width: $confirm-box-max-width;
      width: 90%;
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
    }

    &__confirm-title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__confirm-msg {
      margin: 0;
      font-family: var(--font-body);
      color: var(--text-secondary);
    }

    &__confirm-actions {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }

    &__confirm-warn {
      margin: 0;
    }

    &__confirm-btns {
      display: flex;
      justify-content: flex-end;
      gap: var(--space-2);
    }

    &__confirm-btn {
      padding: var(--space-2) var(--space-4);
      border-radius: var(--radius-sm);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      cursor: pointer;
      border: 1px solid var(--brand-brass-shadow);
      background: transparent;
      color: var(--text-primary);

      &:hover {
        background: color-mix(in srgb, var(--brand-brass-shadow) 20%, transparent);
      }

      &--cancel {
        color: var(--text-secondary);
      }

      &--danger {
        background: var(--status-danger);
        border-color: var(--status-danger);
        color: var(--text-primary);

        &:hover {
          background: color-mix(in srgb, var(--status-danger) 80%, var(--surface-void));
        }
      }
    }
  }
</style>
