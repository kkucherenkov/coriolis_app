<script setup lang="ts">
  import { computed } from 'vue';

  import AppButton from '../AppButton/AppButton.vue';
  import AppModal from '../AppModal/AppModal.vue';

  type Tone = 'neutral' | 'danger';

  interface Props {
    /** Controlled open state; v-model:open binding (same shape as AppModal). */
    open?: boolean;
    /** Title shown at the top of the modal. */
    title: string;
    /** Body copy under the title; explains the consequence. */
    body?: string;
    /** Label for the confirm CTA. */
    confirmLabel: string;
    /** Label for the cancel button. Defaults to "Cancel" in caller's locale. */
    cancelLabel: string;
    /**
     * Tone of the confirm CTA. `danger` paints the button red to flag
     * destructive ops (kick, revoke, delete). `neutral` is for benign
     * branches (publish, archive).
     */
    tone?: Tone;
    /** Shows a spinner on the confirm CTA + disables both buttons. */
    loading?: boolean;
  }

  const props = withDefaults(defineProps<Props>(), {
    open: false,
    body: '',
    tone: 'neutral',
    loading: false,
  });

  const emit = defineEmits<{
    'update:open': [value: boolean];
    confirm: [];
    cancel: [];
  }>();

  function onCancel(): void {
    if (props.loading) return;
    emit('cancel');
    emit('update:open', false);
  }

  function onConfirm(): void {
    if (props.loading) return;
    emit('confirm');
  }

  const confirmVariant = computed<'primary' | 'danger'>(() =>
    props.tone === 'danger' ? 'danger' : 'primary',
  );

  // Wire the modal's update:open back through so v-model:open works on the
  // parent (e.g. Esc closing the modal cancels the confirm).
  function onModalUpdateOpen(value: boolean): void {
    if (!value) emit('cancel');
    emit('update:open', value);
  }
</script>

<template>
  <AppModal
    :open="open"
    :aria-label="title"
    size="sm"
    :close-on-backdrop="false"
    :close-on-esc="!loading"
    @update:open="onModalUpdateOpen"
  >
    <div class="app-confirm">
      <h3 class="app-confirm__title">{{ title }}</h3>
      <p v-if="body" class="app-confirm__body">{{ body }}</p>
    </div>

    <template #footer>
      <AppButton variant="ghost" size="sm" :disabled="loading" @click="onCancel">
        {{ cancelLabel }}
      </AppButton>
      <AppButton :variant="confirmVariant" size="sm" :loading="loading" @click="onConfirm">
        {{ confirmLabel }}
      </AppButton>
    </template>
  </AppModal>
</template>

<style lang="scss" scoped>
  .app-confirm {
    display: flex;
    flex-direction: column;
    gap: var(--space-3);

    &__title {
      margin: 0;
      font-family: var(--type-body-lg-font-family);
      font-size: var(--type-body-lg-font-size);
      line-height: var(--type-body-lg-line-height);
      font-weight: var(--fw-semibold);
      color: var(--text-primary);
      letter-spacing: 0.01em;
    }

    &__body {
      margin: 0;
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      line-height: var(--type-body-md-line-height);
      color: var(--text-secondary);
    }
  }
</style>
