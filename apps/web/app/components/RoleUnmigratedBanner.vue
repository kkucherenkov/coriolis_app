<script setup lang="ts">
  import { ref, useId } from 'vue';
  import { AppBanner, AppButton, AppModal } from '@app/ui';
  import RoleCardGrid from '~/components/RoleCardGrid.vue';
  import { useCharactersApi } from '~/composables/useCharactersApi';
  import type { Problem } from '~/composables/useCharactersApi';
  import type { Concept, Role } from '@app/api-client-ts';

  interface Props {
    characterId: string;
    concept: Concept | null;
    /** The server's stored role. May be non-null even for `roleUnmigrated` rows —
     *  the Block E backfill sets the default role per concept so the card grid
     *  can pre-select it for the user to confirm (or override). */
    role: Role | null;
    roleUnmigrated: boolean;
  }

  const props = defineProps<Props>();

  const emit = defineEmits<{
    /** Emitted on successful PATCH. Parent should update character.role and
     *  character.roleUnmigrated = false (or re-fetch). */
    'role-confirmed': [role: Role];
  }>();

  const { t } = useI18n({ useScope: 'local' });
  const api = useCharactersApi();

  const headingId = useId();
  const descId = useId();

  // ── Dialog state ────────────────────────────────────────────────────────────

  const dialogOpen = ref(false);
  const pendingRole = ref<Role | null>(props.role);
  const saving = ref(false);
  const errorMsg = ref('');

  function openDialog(): void {
    pendingRole.value = props.role;
    errorMsg.value = '';
    dialogOpen.value = true;
  }

  function closeDialog(): void {
    dialogOpen.value = false;
    // AppModal returns focus to the trigger element automatically via its
    // focus-trap implementation. The CTA is our trigger so focus lands correctly.
  }

  async function confirmRole(): Promise<void> {
    if (!pendingRole.value) return;
    saving.value = true;
    errorMsg.value = '';
    try {
      await api.update(props.characterId, { role: pendingRole.value });
      const confirmed = pendingRole.value;
      closeDialog();
      emit('role-confirmed', confirmed);
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorPatchFailed');
    } finally {
      saving.value = false;
    }
  }
</script>

<i18n lang="json">
{
  "en": {
    "bannerText": "This character pre-dates role-tracking. Confirm your role to keep your skill-cap math canon-aligned.",
    "cta": "Confirm role",
    "dialogHeading": "Confirm your role",
    "dialogDescription": "Choose one of the three canonical roles for your concept. Your key skills and skill caps will update to match.",
    "confirmLabel": "Confirm",
    "cancelLabel": "Cancel",
    "errorPatchFailed": "Failed to save role. Please try again."
  },
  "ru": {
    "bannerText": "Этот персонаж создан до появления ролей. Подтвердите вашу роль, чтобы каппы навыков считались по канону.",
    "cta": "Подтвердить роль",
    "dialogHeading": "Подтвердите роль",
    "dialogDescription": "Выберите одну из трёх канонических ролей для вашего амплуа. Ключевые навыки и ограничения обновятся автоматически.",
    "confirmLabel": "Подтвердить",
    "cancelLabel": "Отмена",
    "errorPatchFailed": "Не удалось сохранить роль. Попробуйте ещё раз."
  },
  "uk": {
    "bannerText": "[uk-todo] This character pre-dates role-tracking. Confirm your role to keep your skill-cap math canon-aligned.",
    "cta": "[uk-todo] Confirm role",
    "dialogHeading": "[uk-todo] Confirm your role",
    "dialogDescription": "[uk-todo] Choose one of the three canonical roles for your concept.",
    "confirmLabel": "[uk-todo] Confirm",
    "cancelLabel": "[uk-todo] Cancel",
    "errorPatchFailed": "[uk-todo] Failed to save role. Please try again."
  },
  "el": {
    "bannerText": "[el-todo] This character pre-dates role-tracking. Confirm your role to keep your skill-cap math canon-aligned.",
    "cta": "[el-todo] Confirm role",
    "dialogHeading": "[el-todo] Confirm your role",
    "dialogDescription": "[el-todo] Choose one of the three canonical roles for your concept.",
    "confirmLabel": "[el-todo] Confirm",
    "cancelLabel": "[el-todo] Cancel",
    "errorPatchFailed": "[el-todo] Failed to save role. Please try again."
  }
}
</i18n>

<template>
  <!-- Render nothing when the banner is not needed -->
  <template v-if="roleUnmigrated && concept !== null">
    <!-- ── Banner ──────────────────────────────────────────────────────────── -->
    <AppBanner tone="warning" class="role-unmigrated-banner" aria-live="polite">
      {{ t('bannerText') }}
      <template #actions>
        <AppButton variant="primary" size="sm" @click="openDialog">
          {{ t('cta') }}
        </AppButton>
      </template>
    </AppBanner>

    <!-- ── Role-picker dialog ──────────────────────────────────────────────── -->
    <AppModal
      :open="dialogOpen"
      :aria-labelledby="headingId"
      close-on-backdrop
      close-on-esc
      size="md"
      @update:open="dialogOpen = $event"
    >
      <div
        class="role-unmigrated-banner__dialog"
        role="dialog"
        :aria-labelledby="headingId"
        :aria-describedby="descId"
      >
        <h2 :id="headingId" class="role-unmigrated-banner__dialog-heading">
          {{ t('dialogHeading') }}
        </h2>
        <p :id="descId" class="role-unmigrated-banner__dialog-desc">
          {{ t('dialogDescription') }}
        </p>

        <!-- Error message (inline, dialog stays open) -->
        <AppBanner v-if="errorMsg" tone="danger" class="role-unmigrated-banner__dialog-error">
          {{ errorMsg }}
        </AppBanner>

        <!-- Role card grid scoped to this character's concept -->
        <RoleCardGrid
          :concept="concept"
          :role="pendingRole"
          class="role-unmigrated-banner__grid"
          @update:role="pendingRole = $event"
        />

        <!-- Dialog footer -->
        <div class="role-unmigrated-banner__dialog-footer">
          <AppButton variant="ghost" size="md" :disabled="saving" @click="closeDialog">
            {{ t('cancelLabel') }}
          </AppButton>
          <AppButton
            variant="primary"
            size="md"
            :disabled="!pendingRole || saving"
            :loading="saving"
            @click="confirmRole"
          >
            {{ t('confirmLabel') }}
          </AppButton>
        </div>
      </div>
    </AppModal>
  </template>
</template>

<style lang="scss" scoped>
  .role-unmigrated-banner {
    &__dialog {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
      padding: var(--space-5);
    }

    &__dialog-heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      font-weight: var(--type-display-sm-font-weight);
      color: var(--brand-brass-light);
    }

    &__dialog-desc {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      line-height: 1.5;
    }

    &__dialog-error {
      // inherits AppBanner danger tone styles
    }

    &__grid {
      // role-card-grid inherits its own styles; no overrides needed
    }

    &__dialog-footer {
      display: flex;
      justify-content: flex-end;
      gap: var(--space-3);
      padding-top: var(--space-2);
      border-top: 1px solid var(--brand-brass-shadow);
    }
  }
</style>
