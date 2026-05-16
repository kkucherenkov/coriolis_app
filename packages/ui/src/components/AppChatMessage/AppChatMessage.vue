<script setup lang="ts">
  import { computed, ref } from 'vue';

  import AppButton from '../AppButton/AppButton.vue';
  import AppChatAvatar from '../AppChatAvatar/AppChatAvatar.vue';
  import AppPopover from '../AppPopover/AppPopover.vue';

  /**
   * Chat message bubble — supports broadcast-author, broadcast-other,
   * whisper, and system variants. Composes AppChatAvatar + AppPopover
   * for kebab menu actions (edit, delete, block).
   *
   * Single root <article> with conditional internals so that
   * wrapper.classes() / wrapper.attributes() are always available in tests.
   *
   * Variant alignment:
   *   broadcast-author + whisper (ownByMe) → right-aligned (--alignment-right)
   *   broadcast-other + whisper (!ownByMe) → left-aligned (--alignment-left)
   *   system → centred, no bubble, no kebab
   */

  type Variant = 'broadcast-author' | 'broadcast-other' | 'whisper' | 'system';
  type Presence = 'online' | 'idle' | 'offline';

  interface Props {
    variant: Variant;
    authorDisplayName?: string;
    authorAvatarSrc?: string | null;
    authorPresence?: Presence;
    body?: string | null;
    systemLabel?: string;
    createdAtIso: string;
    editedAtIso?: string | null;
    deletedAtIso?: string | null;
    ownByMe: boolean;
    ownByGm: boolean;
    canEdit: boolean;
    canDelete: boolean;
    canBlock: boolean;
  }

  const props = withDefaults(defineProps<Props>(), {
    authorDisplayName: undefined,
    authorAvatarSrc: undefined,
    authorPresence: undefined,
    body: undefined,
    systemLabel: undefined,
    editedAtIso: undefined,
    deletedAtIso: undefined,
  });

  const emit = defineEmits<(e: 'edit' | 'delete' | 'block') => void>();

  const kebabOpen = ref(false);

  const isSystem = computed(() => props.variant === 'system');
  const isDeleted = computed(() => Boolean(props.deletedAtIso));
  const isEdited = computed(() => Boolean(props.editedAtIso));

  /**
   * Right-aligned: broadcast-author always, whisper when ownByMe.
   * Left-aligned: broadcast-other always, whisper when !ownByMe.
   * System: centred — alignment modifiers not applied.
   */
  const alignRight = computed(() => {
    if (props.variant === 'broadcast-author') return true;
    if (props.variant === 'whisper') return props.ownByMe;
    return false;
  });

  const rootClasses = computed(() => {
    const classes: (string | Record<string, boolean>)[] = [
      'app-chat-message',
      `app-chat-message--variant-${props.variant}`,
    ];
    if (!isSystem.value) {
      classes.push(
        alignRight.value ? 'app-chat-message--alignment-right' : 'app-chat-message--alignment-left',
      );
    }
    classes.push(
      { 'app-chat-message--own-by-me': props.ownByMe },
      { 'app-chat-message--deleted': isDeleted.value },
      { 'app-chat-message--edited': isEdited.value },
    );
    return classes;
  });

  /** Accessible name for the article element. */
  const accessibleLabel = computed(() => {
    if (isSystem.value) return props.systemLabel ?? '';
    const author = props.authorDisplayName ?? 'Unknown';
    const time = new Date(props.createdAtIso).toLocaleTimeString([], {
      hour: '2-digit',
      minute: '2-digit',
    });
    return `${author} at ${time}`;
  });

  /** Local time string rendered in the timestamp element. */
  const localTime = computed(() =>
    new Date(props.createdAtIso).toLocaleTimeString([], {
      hour: '2-digit',
      minute: '2-digit',
    }),
  );

  /** Whether the kebab menu trigger + popover should render. */
  const showKebab = computed(() => !isSystem.value && !isDeleted.value);

  /** Which menu items are visible. */
  const showEdit = computed(() => props.canEdit && props.ownByMe);
  const showDelete = computed(() => props.canDelete && (props.ownByMe || props.ownByGm));
  const showBlock = computed(() => props.canBlock && !props.ownByMe);

  function onEdit(): void {
    kebabOpen.value = false;
    emit('edit');
  }

  function onDelete(): void {
    kebabOpen.value = false;
    emit('delete');
  }

  function onBlock(): void {
    kebabOpen.value = false;
    emit('block');
  }
</script>

<template>
  <article
    :class="rootClasses"
    role="article"
    :aria-label="accessibleLabel"
    data-testid="app-chat-message"
  >
    <!-- ── System variant — centred paragraph, no bubble ── -->
    <template v-if="isSystem">
      <p class="app-chat-message__system">
        {{ systemLabel }}
      </p>
    </template>

    <!-- ── All other variants ── -->
    <template v-else>
      <!-- Left-aligned header: avatar + author name -->
      <div v-if="!alignRight" class="app-chat-message__header">
        <AppChatAvatar :initials="authorDisplayName" :presence="authorPresence" size="sm" />
        <span class="app-chat-message__author">
          <!-- Lock icon shown in left-aligned header for whisper -->
          <span v-if="variant === 'whisper'" class="app-chat-message__lock-wrap">
            <svg
              class="app-chat-message__lock"
              width="12"
              height="12"
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
              aria-hidden="true"
            >
              <rect
                x="3"
                y="11"
                width="18"
                height="11"
                rx="2"
                ry="2"
                stroke="currentColor"
                stroke-width="2"
                fill="none"
              />
              <path
                d="M7 11V7a5 5 0 0 1 10 0v4"
                stroke="currentColor"
                stroke-width="2"
                fill="none"
              />
            </svg>
          </span>
          {{ authorDisplayName }}
        </span>
      </div>

      <!-- Bubble wrap (right-aligned: optional lock before bubble) -->
      <div class="app-chat-message__bubble-wrap">
        <!-- Lock icon shown outside bubble for right-aligned whisper -->
        <span v-if="alignRight && variant === 'whisper'" class="app-chat-message__lock-wrap">
          <svg
            class="app-chat-message__lock"
            width="12"
            height="12"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            aria-hidden="true"
          >
            <rect
              x="3"
              y="11"
              width="18"
              height="11"
              rx="2"
              ry="2"
              stroke="currentColor"
              stroke-width="2"
              fill="none"
            />
            <path d="M7 11V7a5 5 0 0 1 10 0v4" stroke="currentColor" stroke-width="2" fill="none" />
          </svg>
        </span>

        <div class="app-chat-message__bubble">
          <!-- Kebab popover -->
          <AppPopover
            v-if="showKebab"
            v-model:open="kebabOpen"
            placement="bottom"
            aria-label="Message actions"
            class="app-chat-message__kebab-popover"
          >
            <template #trigger>
              <AppButton
                variant="ghost"
                size="sm"
                class="app-chat-message__kebab-btn"
                aria-label="Message options"
              >
                <template #icon-leading>
                  <svg
                    width="16"
                    height="16"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    xmlns="http://www.w3.org/2000/svg"
                    aria-hidden="true"
                  >
                    <circle cx="12" cy="5" r="1.5" />
                    <circle cx="12" cy="12" r="1.5" />
                    <circle cx="12" cy="19" r="1.5" />
                  </svg>
                </template>
              </AppButton>
            </template>

            <div class="app-chat-message__menu">
              <button
                v-if="showEdit"
                class="app-chat-message__menu-item"
                type="button"
                data-testid="menu-edit"
                @click="onEdit"
              >
                Edit
              </button>
              <button
                v-if="showDelete"
                class="app-chat-message__menu-item app-chat-message__menu-item--danger"
                type="button"
                data-testid="menu-delete"
                @click="onDelete"
              >
                Delete
              </button>
              <button
                v-if="showBlock"
                class="app-chat-message__menu-item app-chat-message__menu-item--danger"
                type="button"
                data-testid="menu-block"
                @click="onBlock"
              >
                Block in this session
              </button>
            </div>
          </AppPopover>

          <!-- Body or deleted placeholder -->
          <p v-if="isDeleted" class="app-chat-message__body">
            <em class="app-chat-message__deleted">Message deleted</em>
          </p>
          <p v-else class="app-chat-message__body">
            {{ body }}
          </p>

          <!-- Footer: timestamp + edited mark -->
          <footer class="app-chat-message__footer">
            <time :datetime="createdAtIso" class="app-chat-message__time">{{ localTime }}</time>
            <span v-if="isEdited" class="app-chat-message__edited">edited</span>
          </footer>
        </div>
      </div>
    </template>
  </article>
</template>

<style lang="scss" scoped>
  // Fade-in duration constant — referenced by both the animation and the
  // reduced-motion guard below.
  $bubble-appear-duration: var(--motion-duration);

  .app-chat-message {
    display: flex;
    flex-direction: column;
    gap: var(--space-1);
    padding: var(--space-1) 0;

    // ── System variant ────────────────────────────────────────────────────────

    &--variant-system {
      align-items: center;
    }

    &__system {
      font-style: italic;
      color: var(--chat-system-fg);
      text-align: center;
      font-size: var(--type-body-sm-font-size);
      margin: 0;
    }

    // ── Alignment ─────────────────────────────────────────────────────────────

    &--alignment-left {
      align-items: flex-start;
    }

    &--alignment-right {
      align-items: flex-end;
    }

    // ── Header row (avatar + author name, left-aligned only) ─────────────────

    &__header {
      display: flex;
      align-items: center;
      gap: var(--space-2);
    }

    &__author {
      display: inline-flex;
      align-items: center;
      gap: var(--space-1);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-weight: var(--fw-medium);
    }

    // ── Lock icon ─────────────────────────────────────────────────────────────

    &__lock-wrap {
      display: inline-flex;
      align-items: center;
    }

    &__lock {
      color: var(--chat-whisper-accent);
    }

    // ── Bubble wrap ───────────────────────────────────────────────────────────

    &__bubble-wrap {
      display: flex;
      align-items: flex-start;
      gap: var(--space-1);
    }

    // ── Bubble ────────────────────────────────────────────────────────────────

    &__bubble {
      position: relative;
      padding: var(--space-2) var(--space-3);
      border-radius: var(--radius-md);
      max-width: 36rem;
      overflow-wrap: break-word;
      animation: app-chat-message-appear $bubble-appear-duration var(--motion-ease-standard) both;
    }

    &--variant-broadcast-author &__bubble {
      background: var(--chat-bubble-author-bg);
    }

    &--variant-broadcast-other &__bubble {
      background: var(--chat-bubble-other-bg);
    }

    &--variant-whisper &__bubble {
      border: 1px solid var(--chat-whisper-accent);
      background: var(--chat-bubble-other-bg);
    }

    // own-by-me whisper uses author-bubble background
    &--variant-whisper#{&}--own-by-me &__bubble {
      background: var(--chat-bubble-author-bg);
    }

    // ── Kebab ─────────────────────────────────────────────────────────────────

    &__kebab-popover {
      position: absolute;
      top: var(--space-1);
      right: var(--space-1);
      z-index: var(--z-dropdown);
    }

    &__kebab-btn {
      padding: var(--space-1);
      min-width: unset;
    }

    // ── Body ──────────────────────────────────────────────────────────────────

    &__body {
      margin: 0;
      padding-right: var(--space-6);
      color: var(--text-primary);
      font-size: var(--type-body-md-font-size);
      line-height: var(--type-body-md-line-height);
    }

    &__deleted {
      color: var(--text-secondary);
      font-style: italic;
    }

    // ── Footer ────────────────────────────────────────────────────────────────

    &__footer {
      display: flex;
      align-items: center;
      gap: var(--space-1);
      margin-top: var(--space-1);
    }

    &__time {
      font-size: var(--type-body-xs-font-size, 0.75rem);
      color: var(--text-secondary);
    }

    &__edited {
      font-size: var(--type-body-xs-font-size, 0.75rem);
      color: var(--text-secondary);
      font-style: italic;
    }

    // ── Menu ──────────────────────────────────────────────────────────────────

    &__menu {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__menu-item {
      display: block;
      width: 100%;
      padding: var(--space-1) var(--space-2);
      text-align: left;
      background: transparent;
      border: none;
      border-radius: var(--radius-sm);
      color: var(--text-primary);
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-sm-font-size);
      cursor: pointer;

      &:hover {
        background: color-mix(in srgb, var(--brand-brass) 10%, transparent);
      }

      &--danger {
        color: var(--state-crimson);

        &:hover {
          background: color-mix(in srgb, var(--state-crimson) 10%, transparent);
        }
      }
    }
  }

  // ── Entrance keyframe ─────────────────────────────────────────────────────

  @keyframes app-chat-message-appear {
    from {
      opacity: 0;
      translate: 0 4px;
    }

    to {
      opacity: 1;
      translate: 0 0;
    }
  }

  // Respect reduced-motion — kill the bubble appear animation.
  @media (prefers-reduced-motion: reduce) {
    .app-chat-message__bubble {
      animation: none;
    }
  }
</style>
