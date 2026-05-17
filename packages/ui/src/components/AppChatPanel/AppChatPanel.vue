<script setup lang="ts">
  import { computed, nextTick, ref, watch } from 'vue';

  import AppChatTabStrip from '../AppChatTabStrip/AppChatTabStrip.vue';
  import AppChatConnectionPip from '../AppChatConnectionPip/AppChatConnectionPip.vue';
  import AppChatDayDivider from '../AppChatDayDivider/AppChatDayDivider.vue';
  import AppChatMessage from '../AppChatMessage/AppChatMessage.vue';
  import AppChatNewMessagesPill from '../AppChatNewMessagesPill/AppChatNewMessagesPill.vue';
  import AppChatComposer from '../AppChatComposer/AppChatComposer.vue';

  import type {
    AppChatPanelMode,
    AppChatPanelConnectionStatus,
    AppChatPanelRow,
    ChatTabModel,
  } from './types';

  /**
   * AppChatPanel — composition root that owns layout, auto-scroll,
   * the new-messages pill, and the connection-pip slot.
   *
   * Pure presentational composite. All state lives in the consumer
   * (Block 7's Pinia store). Props in, events out.
   *
   * Auto-scroll: the list auto-scrolls to bottom whenever new messages
   * arrive, but only when the user was already near the bottom
   * (within AUTO_SCROLL_THRESHOLD_PX). If the user has scrolled up,
   * auto-scroll is suppressed and the new-messages pill is shown by the
   * consumer (via `newMessagesCount`).
   *
   * Reduced-motion: scroll-behavior on the list switches from "smooth"
   * to "auto" via @media (prefers-reduced-motion: reduce) in CSS.
   */

  interface Props {
    mode: AppChatPanelMode;
    connectionStatus: AppChatPanelConnectionStatus;
    tabs: ChatTabModel[];
    activeKey: string;
    messages: AppChatPanelRow[];
    composerValue: string;
    composerKind: 'broadcast' | 'whisper';
    composerPartnerDisplayName?: string;
    composerDisabled: boolean;
    newMessagesCount: number;
    /**
     * When non-empty the composer enters inline-edit mode: shows a banner
     * with this label + the (optional) original body preview + a Cancel
     * button. Submit semantics stay the same — the parent inspects its
     * own editing state to route to edit() vs send().
     */
    composerEditingLabel?: string;
    composerEditingPreview?: string;
    composerCancelEditLabel?: string;
  }

  // Object-form defineEmits avoids @typescript-eslint/unified-signatures false positives
  // that arise when call-signature overloads share the same parameter type.
  const props = withDefaults(defineProps<Props>(), {
    composerPartnerDisplayName: undefined,
    composerEditingLabel: '',
    composerEditingPreview: '',
    composerCancelEditLabel: 'Cancel',
  });

  defineEmits<{
    'select-tab': [key: string];
    'close-tab': [key: string];
    'add-whisper': [];
    'update:composer-value': [v: string];
    submit: [];
    'edit-message': [id: string];
    'delete-message': [id: string];
    'block-author': [id: string];
    'jump-to-newest': [];
    'cancel-edit': [];
  }>();

  const AUTO_SCROLL_THRESHOLD_PX = 80;

  // ── Auto-scroll state ──────────────────────────────────────────────────────

  const listEl = ref<HTMLElement | null>(null);
  const wasNearBottom = ref<boolean>(true);

  function isNearBottom(el: HTMLElement): boolean {
    return el.scrollHeight - (el.scrollTop + el.clientHeight) <= AUTO_SCROLL_THRESHOLD_PX;
  }

  function onScroll(): void {
    if (!listEl.value) return;
    wasNearBottom.value = isNearBottom(listEl.value);
  }

  watch(
    () => props.messages,
    async () => {
      await nextTick();
      if (!listEl.value) return;
      if (wasNearBottom.value) {
        listEl.value.scrollTop = listEl.value.scrollHeight;
      }
    },
    { flush: 'post' },
  );

  // ── Mode modifier class ─────────────────────────────────────────────────────

  const modeClass = computed(() => `app-chat-panel--mode-${props.mode}`);
</script>

<template>
  <div class="app-chat-panel" :class="modeClass" data-testid="app-chat-panel">
    <header class="app-chat-panel__head">
      <AppChatTabStrip
        :tabs="tabs"
        :active-key="activeKey"
        @select="(k) => $emit('select-tab', k)"
        @close="(k) => $emit('close-tab', k)"
        @add="$emit('add-whisper')"
      />
      <AppChatConnectionPip :status="connectionStatus" />
    </header>

    <main ref="listEl" class="app-chat-panel__list" @scroll="onScroll">
      <template v-for="row in messages" :key="row.id">
        <AppChatDayDivider
          v-if="row.variant === 'day-divider'"
          :label="(row.payload as { label: string }).label"
        />
        <AppChatMessage
          v-else
          v-bind="row.payload"
          @edit="$emit('edit-message', row.id)"
          @delete="$emit('delete-message', row.id)"
          @block="$emit('block-author', row.id)"
        />
      </template>
    </main>

    <AppChatNewMessagesPill
      class="app-chat-panel__pill"
      :count="newMessagesCount"
      @click="$emit('jump-to-newest')"
    />

    <footer class="app-chat-panel__composer">
      <AppChatComposer
        :model-value="composerValue"
        :conversation-kind="composerKind"
        :partner-display-name="composerPartnerDisplayName"
        :disabled="composerDisabled"
        :editing-label="composerEditingLabel"
        :editing-preview="composerEditingPreview"
        :cancel-edit-label="composerCancelEditLabel"
        @update:model-value="(v) => $emit('update:composer-value', v)"
        @submit="$emit('submit')"
        @cancel-edit="$emit('cancel-edit')"
      />
    </footer>
  </div>
</template>

<style lang="scss" scoped>
  $scrollbar-thickness: 4px;
  $docked-panel-width: 340px;

  .app-chat-panel {
    position: relative;
    display: flex;
    flex-direction: column;
    background: var(--surface-night);
    overflow: hidden;

    // ── Head ──────────────────────────────────────────────────────────────────

    &__head {
      display: flex;
      align-items: center;
      gap: var(--space-2);
      padding: var(--space-2) var(--space-3);
      border-bottom: 1px solid var(--brand-brass-deep);
      flex-shrink: 0;
    }

    // ── Message list ──────────────────────────────────────────────────────────

    &__list {
      flex: 1;
      overflow-y: auto;
      padding: var(--space-3);
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
      scroll-behavior: smooth;
      scrollbar-width: thin;
      scrollbar-color: var(--brand-brass-deep) transparent;

      &::-webkit-scrollbar {
        width: $scrollbar-thickness;
      }

      &::-webkit-scrollbar-track {
        background: transparent;
      }

      &::-webkit-scrollbar-thumb {
        background: var(--brand-brass-deep);
        border-radius: var(--radius-pill);
      }
    }

    // ── Pill (new messages) ───────────────────────────────────────────────────

    &__pill {
      position: absolute;
      // Approximate composer height — actual value depends on rows=3 textarea.
      // Using a token-aligned offset that keeps the pill above the composer.
      bottom: calc(var(--chat-composer-height, 7.5rem) + var(--space-2));
      left: 50%;
      transform: translateX(-50%);
      z-index: var(--z-raised);
    }

    // ── Composer ──────────────────────────────────────────────────────────────

    &__composer {
      flex-shrink: 0;
      padding: var(--space-2) var(--space-3);
      border-top: 1px solid var(--brand-brass-deep);
    }

    // ── Mode: primary ─────────────────────────────────────────────────────────

    &--mode-primary {
      width: 100%;
      height: 100%;
    }

    // ── Mode: docked ──────────────────────────────────────────────────────────

    &--mode-docked {
      width: $docked-panel-width;
      height: 100%;
    }
  }

  // Respect reduced-motion — swap smooth scroll for instant.
  @media (prefers-reduced-motion: reduce) {
    .app-chat-panel__list {
      scroll-behavior: auto;
    }
  }
</style>
