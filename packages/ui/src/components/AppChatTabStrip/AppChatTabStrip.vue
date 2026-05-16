<script setup lang="ts">
  import { computed, ref } from 'vue';

  import AppChatTab from '../AppChatTab/AppChatTab.vue';
  import AppChatPresenceDot from '../AppChatPresenceDot/AppChatPresenceDot.vue';
  import AppBadge from '../AppBadge/AppBadge.vue';
  import AppPopover from '../AppPopover/AppPopover.vue';

  import type { ChatTabModel } from './types';

  interface Props {
    tabs: ChatTabModel[];
    activeKey: string;
    visibleWhisperLimit?: number;
  }

  const props = withDefaults(defineProps<Props>(), {
    visibleWhisperLimit: 3,
  });

  const emit = defineEmits<{
    (e: 'select' | 'close', key: string): void;
    (e: 'add'): void;
  }>();

  const overflowOpen = ref(false);

  const broadcastTab = computed(() => props.tabs.find((t) => t.kind === 'broadcast') ?? null);

  const whisperTabs = computed(() => props.tabs.filter((t) => t.kind === 'whisper'));

  const visibleWhispers = computed(() => whisperTabs.value.slice(0, props.visibleWhisperLimit));

  const overflowWhispers = computed(() => whisperTabs.value.slice(props.visibleWhisperLimit));

  const overflowCount = computed(() => overflowWhispers.value.length);

  function selectFromOverflow(key: string): void {
    overflowOpen.value = false;
    emit('select', key);
  }
</script>

<template>
  <div
    class="app-chat-tab-strip"
    role="tablist"
  >
    <!-- Pinned broadcast tab -->
    <AppChatTab
      v-if="broadcastTab"
      :label="broadcastTab.label"
      kind="broadcast"
      :unread-count="broadcastTab.unreadCount"
      :active="activeKey === broadcastTab.key"
      @select="emit('select', broadcastTab.key)"
    />

    <!-- Inline whisper tabs (up to visibleWhisperLimit) -->
    <AppChatTab
      v-for="tab in visibleWhispers"
      :key="tab.key"
      :label="tab.label"
      kind="whisper"
      :unread-count="tab.unreadCount"
      :presence="tab.presence"
      :active="activeKey === tab.key"
      @select="emit('select', tab.key)"
      @close="emit('close', tab.key)"
    />

    <!-- Overflow chip -->
    <AppPopover
      v-if="overflowCount > 0"
      v-model:open="overflowOpen"
      placement="bottom"
      aria-label="Overflow whisper tabs"
      class="app-chat-tab-strip__overflow-popover"
    >
      <template #trigger>
        <button
          type="button"
          class="app-chat-tab-strip__overflow-chip"
          :aria-label="`${overflowCount} more whisper tabs`"
        >
          +{{ overflowCount }} more
        </button>
      </template>

      <!-- Overflow list -->
      <ul
        class="app-chat-tab-strip__overflow-list"
        role="list"
      >
        <li
          v-for="tab in overflowWhispers"
          :key="tab.key"
          class="app-chat-tab-strip__overflow-item"
          role="listitem"
        >
          <button
            type="button"
            class="app-chat-tab-strip__overflow-row"
            @click="selectFromOverflow(tab.key)"
          >
            <AppChatPresenceDot
              v-if="tab.presence"
              :presence="tab.presence"
              class="app-chat-tab-strip__overflow-dot"
            />
            <span class="app-chat-tab-strip__overflow-label">{{ tab.label }}</span>
            <AppBadge
              v-if="tab.unreadCount > 0"
              variant="crimson"
              size="sm"
              class="app-chat-tab-strip__overflow-badge"
            >
              {{ tab.unreadCount }}
            </AppBadge>
          </button>
        </li>
      </ul>
    </AppPopover>

    <!-- Add whisper button -->
    <button
      type="button"
      class="app-chat-tab-strip__add"
      aria-label="Open whisper picker"
      @click="emit('add')"
    >
      +
    </button>
  </div>
</template>

<style lang="scss" scoped>
  .app-chat-tab-strip {
    display: flex;
    align-items: stretch;
    gap: 0;
    overflow-x: auto;
    scrollbar-width: thin;
    scrollbar-color: var(--brand-brass-deep) transparent;

    // Prevent layout shift from scrollbar appearance.
    &::-webkit-scrollbar {
      height: 4px;
    }

    &::-webkit-scrollbar-track {
      background: transparent;
    }

    &::-webkit-scrollbar-thumb {
      background: var(--brand-brass-deep);
      border-radius: var(--radius-pill);
    }

    // ── Overflow chip ────────────────────────────────────────────────────────

    &__overflow-popover {
      align-self: center;
    }

    &__overflow-chip {
      display: inline-flex;
      align-items: center;
      background: transparent;
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-sm);
      padding: var(--space-1) var(--space-2);
      margin-inline: var(--space-1);
      color: var(--text-secondary);
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      cursor: pointer;
      white-space: nowrap;
      transition:
        color var(--motion-duration-fast) var(--motion-ease-standard),
        border-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        color: var(--text-primary);
        border-color: var(--brand-brass);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    // ── Overflow list ────────────────────────────────────────────────────────

    &__overflow-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__overflow-item {
      display: contents;
    }

    &__overflow-row {
      display: flex;
      align-items: center;
      gap: var(--space-2);
      width: 100%;
      background: transparent;
      border: none;
      border-radius: var(--radius-sm);
      padding: var(--space-2) var(--space-3);
      color: var(--text-primary);
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      cursor: pointer;
      text-align: left;
      white-space: nowrap;
      transition: background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        background: color-mix(in srgb, var(--brand-brass) 10%, transparent);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    &__overflow-dot {
      flex-shrink: 0;
    }

    &__overflow-label {
      flex: 1;
      min-width: 0;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    &__overflow-badge {
      flex-shrink: 0;
    }

    // ── Add button ───────────────────────────────────────────────────────────

    &__add {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      align-self: center;
      background: transparent;
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-sm);
      width: 24px;
      height: 24px;
      margin-inline: var(--space-1);
      color: var(--text-secondary);
      font-size: var(--type-body-md-font-size);
      cursor: pointer;
      flex-shrink: 0;
      transition:
        color var(--motion-duration-fast) var(--motion-ease-standard),
        border-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        color: var(--text-primary);
        border-color: var(--brand-brass);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .app-chat-tab-strip__overflow-chip,
    .app-chat-tab-strip__add,
    .app-chat-tab-strip__overflow-row {
      transition: none;
    }
  }
</style>
