<script setup lang="ts">
  import { computed, ref, watch } from 'vue';

  import AppModal from '../AppModal/AppModal.vue';
  import AppChatPresenceDot from '../AppChatPresenceDot/AppChatPresenceDot.vue';

  import type { WhisperPickerMember } from './types';

  interface Props {
    open: boolean;
    members: WhisperPickerMember[];
  }

  const props = defineProps<Props>();

  const emit = defineEmits<{
    (e: 'close'): void;
    (e: 'pick', membershipId: string): void;
  }>();

  const focusedIndex = ref(0);

  const visibleMembers = computed(() => props.members.filter((m) => !m.blockedByMe));

  // Reset focus when the modal opens or the member list changes.
  watch(
    () => [props.open, visibleMembers.value.length],
    () => {
      focusedIndex.value = 0;
    },
  );

  function onModalUpdate(value: boolean): void {
    if (!value) emit('close');
  }

  function onKeydown(event: KeyboardEvent): void {
    const count = visibleMembers.value.length;
    if (count === 0) {
      if (event.key === 'Escape') emit('close');
      return;
    }

    switch (event.key) {
      case 'ArrowDown': {
        event.preventDefault();
        focusedIndex.value = (focusedIndex.value + 1) % count;
        break;
      }
      case 'ArrowUp': {
        event.preventDefault();
        focusedIndex.value = (focusedIndex.value - 1 + count) % count;
        break;
      }
      case 'Enter': {
        event.preventDefault();
        const member = visibleMembers.value[focusedIndex.value];
        if (member) emit('pick', member.membershipId);
        break;
      }
      case 'Escape': {
        emit('close');
        break;
      }
      default: {
        break;
      }
    }
  }

  function onRowClick(membershipId: string): void {
    emit('pick', membershipId);
  }
</script>

<template>
  <AppModal
    :open="open"
    size="sm"
    aria-label="Whisper to…"
    close-on-backdrop
    @update:open="onModalUpdate"
  >
    <div class="app-whisper-picker">
      <h2 class="app-whisper-picker__title">
        Whisper to&hellip;
      </h2>

      <p
        v-if="visibleMembers.length === 0"
        class="app-whisper-picker__empty"
      >
        No one available.
      </p>

      <ul
        v-else
        class="app-whisper-picker__list"
        role="listbox"
        tabindex="0"
        @keydown="onKeydown"
      >
        <li
          v-for="(member, i) in visibleMembers"
          :key="member.membershipId"
          role="option"
          tabindex="-1"
          :aria-selected="i === focusedIndex"
          class="app-whisper-picker__item"
          :class="{ 'app-whisper-picker__item--focused': i === focusedIndex }"
          @click="onRowClick(member.membershipId)"
        >
          <AppChatPresenceDot
            :presence="member.presence"
            class="app-whisper-picker__dot"
          />
          <span class="app-whisper-picker__name">{{ member.displayName }}</span>
          <span
            v-if="member.characterName"
            class="app-whisper-picker__character"
          >
            {{ member.characterName }}
          </span>
        </li>
      </ul>
    </div>
  </AppModal>
</template>

<style lang="scss" scoped>
  .app-whisper-picker {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);

    // ── Title ──────────────────────────────────────────────────────────────────

    &__title {
      margin: 0;
      font-family: var(--type-display-sm-font-family);
      font-size: var(--type-display-sm-font-size);
      font-weight: var(--type-display-sm-font-weight);
      color: var(--text-primary);
    }

    // ── Empty state ────────────────────────────────────────────────────────────

    &__empty {
      margin: 0;
      text-align: center;
      color: var(--text-secondary);
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      padding: var(--space-6) 0;
    }

    // ── Member list ────────────────────────────────────────────────────────────

    &__list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
      outline: none;
    }

    // ── Member row ─────────────────────────────────────────────────────────────

    &__item {
      display: flex;
      align-items: center;
      gap: var(--space-3);
      padding: var(--space-3) var(--space-4);
      border-radius: var(--radius-md);
      cursor: pointer;
      color: var(--text-primary);
      transition: background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover,
      &--focused {
        background: color-mix(in srgb, var(--brand-brass) 10%, transparent);
      }
    }

    &__dot {
      flex-shrink: 0;
    }

    &__name {
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      font-weight: 500;
      color: var(--text-primary);
    }

    &__character {
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      margin-left: var(--space-1);
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .app-whisper-picker__item {
      transition: none;
    }
  }
</style>
