<script setup lang="ts">
  import { computed } from 'vue';

  import AppBadge from '../AppBadge/AppBadge.vue';
  import AppChatPresenceDot from '../AppChatPresenceDot/AppChatPresenceDot.vue';

  type Kind = 'broadcast' | 'whisper';
  type Presence = 'online' | 'idle' | 'offline';

  interface Props {
    label: string;
    kind: Kind;
    unreadCount?: number;
    presence?: Presence;
    active: boolean;
  }

  const props = withDefaults(defineProps<Props>(), {
    unreadCount: 0,
    presence: undefined,
  });

  const emit = defineEmits<(e: 'select' | 'close') => void>();

  const rootClasses = computed(() => [
    'app-chat-tab',
    `app-chat-tab--kind-${props.kind}`,
    {
      'app-chat-tab--active': props.active,
    },
  ]);

  const showPresenceDot = computed(() => props.kind === 'whisper' && props.presence !== undefined);

  const showBadge = computed(() => props.unreadCount > 0);

  const showClose = computed(() => props.kind === 'whisper');
</script>

<template>
  <button
    type="button"
    role="tab"
    :class="rootClasses"
    :aria-selected="active"
    :aria-label="label"
    @click="emit('select')"
  >
    <AppChatPresenceDot
      v-if="showPresenceDot && presence"
      :presence="presence"
      class="app-chat-tab__presence"
    />

    <span class="app-chat-tab__label">{{ label }}</span>

    <AppBadge
      v-if="showBadge"
      variant="crimson"
      size="sm"
      class="app-chat-tab__badge"
    >
      {{
        unreadCount
      }}
    </AppBadge>

    <button
      v-if="showClose"
      type="button"
      class="app-chat-tab__close"
      aria-label="Close whisper tab"
      @click.stop="emit('close')"
    >
      ×
    </button>
  </button>
</template>

<style lang="scss" scoped>
  $tab-underline-h: 2px;
  $tab-underline-gap: 3px;

  .app-chat-tab {
    position: relative;
    display: inline-flex;
    align-items: center;
    gap: var(--space-2);
    background: transparent;
    border: none;
    border-radius: 0;
    padding-top: var(--space-2);
    padding-inline: var(--space-3);
    padding-bottom: calc(var(--space-2) + $tab-underline-gap + $tab-underline-h);
    cursor: pointer;
    white-space: nowrap;
    font-family: var(--type-body-md-font-family);
    font-size: var(--type-body-md-font-size);
    font-weight: var(--type-body-md-font-weight);
    line-height: var(--type-body-md-line-height);
    color: var(--text-secondary);
    user-select: none;
    transition: color var(--motion-duration-fast) var(--motion-ease-standard);

    // Underline pseudo-element
    &::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      height: $tab-underline-h;
      border-radius: $tab-underline-h;
      background: transparent;
      transition: background-color var(--motion-duration-fast) var(--motion-ease-standard);
    }

    @media (prefers-reduced-motion: reduce) {
      &::after {
        transition: none;
      }
    }

    &:focus-visible {
      outline: 2px solid var(--brand-brass);
      outline-offset: 2px;
    }

    // ── Kind: broadcast ────────────────────────────────────────────────────────

    &--kind-broadcast {
      &:hover:not(.app-chat-tab--active) {
        color: var(--text-primary);

        &::after {
          background: color-mix(in srgb, var(--brand-brass) 30%, transparent);
        }
      }

      &.app-chat-tab--active {
        color: var(--brand-brass-light);

        &::after {
          background: var(--brand-brass);
        }
      }
    }

    // ── Kind: whisper ──────────────────────────────────────────────────────────

    &--kind-whisper {
      &:hover:not(.app-chat-tab--active) {
        color: var(--text-primary);

        &::after {
          background: color-mix(
            in srgb,
            var(--chat-whisper-accent, var(--state-mystic-teal)) 30%,
            transparent
          );
        }
      }

      &.app-chat-tab--active {
        color: var(--chat-whisper-accent, var(--state-mystic-teal));

        &::after {
          background: var(--chat-whisper-accent, var(--state-mystic-teal));
        }
      }
    }

    // ── Internal elements ──────────────────────────────────────────────────────

    &__presence {
      flex-shrink: 0;
    }

    &__label {
      flex: 1;
      min-width: 0;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    &__badge {
      flex-shrink: 0;
    }

    &__close {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      background: transparent;
      border: none;
      border-radius: var(--radius-sm);
      padding: 0 var(--space-1);
      color: var(--text-secondary);
      cursor: pointer;
      font-size: var(--type-body-md-font-size);
      line-height: 1;
      transition: color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        color: var(--text-primary);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }
  }
</style>
