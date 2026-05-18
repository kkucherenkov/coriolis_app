<script setup lang="ts">
  /**
   * ShipModuleEditor — discriminator-aware modal for creating and editing ship
   * modules. Part of T-2026-05-10-005 Block 3.
   *
   * Modes:
   *   create  — no `module` prop. Slot picker visible. Submit calls addModule.
   *   edit    — `module` prop present. Slot is immutable. Submit calls updateModule.
   *   confirm-delete — sub-state within edit mode before calling deleteModule.
   *
   * Mandatory slots (BRIDGE / REACTOR / DRIVE) are excluded from the slot picker
   * in create mode (they are seeded server-side). The Delete button is hidden for
   * those slots in edit mode (server enforces 422 SHIP_MODULE_MANDATORY).
   *
   * Emits:
   *   update:open     — close signal passed back to parent
   *   update:module   — saved ShipModule (add or edit)
   *   delete:module   — deleted moduleId string
   */

  import {
    AppModal,
    AppSegControl,
    AppInput,
    AppTextarea,
    AppBanner,
    AppButton,
    AppField,
    AppSelect,
    AppSwitch,
  } from '@app/ui';
  import type { AppSelectOption } from '@app/ui';
  import { ref, computed, watch } from 'vue';
  import { useShipModulesApi } from '~/composables/useShipModulesApi';
  import type {
    ShipModule,
    ShipModuleCreate,
    ShipModuleUpdate,
    ShipModuleSlot,
    ShipWeaponRange,
  } from '~/composables/useShipModulesApi';
  import type { Problem } from '@app/api-client-ts';

  // ── Props & emits ──────────────────────────────────────────────────────────

  interface Props {
    open: boolean;
    shipId: string;
    module: ShipModule | null; // null = create mode
  }

  const props = defineProps<Props>();

  const emit = defineEmits<{
    'update:open': [value: boolean];
    'update:module': [module: ShipModule];
    'delete:module': [moduleId: string];
  }>();

  const { t } = useI18n({ useScope: 'local' });
  const modulesApi = useShipModulesApi();

  // ── Slot options ──────────────────────────────────────────────────────────
  // BRIDGE / REACTOR / DRIVE are excluded from the picker in create mode
  // (seeded server-side). The user can still select any other slot including
  // COMMS, HANGAR, QUARTERS, MEDICAL, WORKSHOP, CHAPEL, ESCAPE-PODS, CRYO,
  // DOCKING, MINING, REPAIR, CONCEALED-HOLD, PROXY-DECK, OTHER.

  const MANDATORY_SLOTS = new Set<ShipModuleSlot>(['BRIDGE', 'REACTOR', 'DRIVE']);

  const SLOT_OPTIONS = computed<AppSelectOption[]>(() => [
    { value: 'WEAPON', label: t('slotWeapon') },
    { value: 'TORPEDO', label: t('slotTorpedo') },
    { value: 'HOLD', label: t('slotHold') },
    { value: 'SENSOR', label: t('slotSensor') },
    { value: 'COMMS', label: t('slotComms') },
    { value: 'HANGAR', label: t('slotHangar') },
    { value: 'QUARTERS', label: t('slotQuarters') },
    { value: 'MEDICAL', label: t('slotMedical') },
    { value: 'WORKSHOP', label: t('slotWorkshop') },
    { value: 'CHAPEL', label: t('slotChapel') },
    { value: 'ESCAPE-PODS', label: t('slotEscapePods') },
    { value: 'CRYO', label: t('slotCryo') },
    { value: 'DOCKING', label: t('slotDocking') },
    { value: 'MINING', label: t('slotMining') },
    { value: 'REPAIR', label: t('slotRepair') },
    { value: 'CONCEALED-HOLD', label: t('slotConcealedHold') },
    { value: 'PROXY-DECK', label: t('slotProxyDeck') },
    { value: 'OTHER', label: t('slotOther') },
  ]);

  const RANGE_OPTIONS = computed(() => [
    { value: 'zero', label: t('rangeZero') },
    { value: 'close', label: t('rangeClose') },
    { value: 'medium', label: t('rangeMedium') },
    { value: 'long', label: t('rangeLong') },
    { value: 'extreme', label: t('rangeExtreme') },
  ]);

  // ── Form state ─────────────────────────────────────────────────────────────

  const isEditMode = computed(() => props.module !== null);

  // Slot — mutable only in create mode
  const selectedSlot = ref<ShipModuleSlot>('WEAPON');

  // Common fields
  const fieldName = ref('');
  const fieldEnergyUse = ref(0);
  const fieldNotes = ref('');

  // WEAPON-specific
  const fieldWeaponBonus = ref(0);
  const fieldWeaponRange = ref<ShipWeaponRange>('close');
  const fieldWeaponDamage = ref(0);
  const fieldWeaponCritThreshold = ref(1);

  // TORPEDO-specific
  const fieldTorpedoCount = ref(0);
  const fieldMineCount = ref(0);

  // HOLD-specific
  const fieldCargoTons = ref(0);
  const fieldConcealed = ref(false);

  // SENSOR-specific
  const fieldDetectionBonus = ref(1);

  // UI state
  const saving = ref(false);
  const deleting = ref(false);
  const errorMsg = ref('');
  const confirmDelete = ref(false);

  // ── Derived helpers ────────────────────────────────────────────────────────

  const isMandatory = computed(() => MANDATORY_SLOTS.has(selectedSlot.value));

  const effectiveSlot = computed<ShipModuleSlot>(() =>
    isEditMode.value && props.module ? props.module.slot : selectedSlot.value,
  );

  // ── Sync form when modal opens / module changes ────────────────────────────

  function resetForm(module: ShipModule | null): void {
    errorMsg.value = '';
    confirmDelete.value = false;

    if (!module) {
      // Create mode defaults
      selectedSlot.value = 'WEAPON';
      fieldName.value = '';
      fieldEnergyUse.value = 0;
      fieldNotes.value = '';
      fieldWeaponBonus.value = 0;
      fieldWeaponRange.value = 'close';
      fieldWeaponDamage.value = 0;
      fieldWeaponCritThreshold.value = 1;
      fieldTorpedoCount.value = 0;
      fieldMineCount.value = 0;
      fieldCargoTons.value = 0;
      fieldConcealed.value = false;
      fieldDetectionBonus.value = 1;
      return;
    }

    // Edit mode — populate from existing module
    selectedSlot.value = module.slot;
    fieldName.value = module.name;
    fieldEnergyUse.value = module.energyUse;
    fieldNotes.value = module.notes ?? '';

    switch (module.slot) {
      case 'WEAPON': {
        fieldWeaponBonus.value = module.weaponBonus;
        fieldWeaponRange.value = module.weaponRange;
        fieldWeaponDamage.value = module.weaponDamage;
        fieldWeaponCritThreshold.value = module.weaponCritThreshold;

        break;
      }
      case 'TORPEDO': {
        fieldTorpedoCount.value = module.torpedoCount ?? 0;
        fieldMineCount.value = module.mineCount ?? 0;

        break;
      }
      case 'HOLD': {
        fieldCargoTons.value = module.cargoTons ?? 0;
        fieldConcealed.value = module.concealed ?? false;

        break;
      }
      case 'SENSOR': {
        fieldDetectionBonus.value = module.detectionBonus ?? 1;

        break;
      }
      // No default
    }
  }

  watch(
    () => [props.open, props.module] as const,
    ([isOpen, module]) => {
      if (isOpen) resetForm(module);
    },
    { immediate: true },
  );

  // ── Validation ─────────────────────────────────────────────────────────────

  const nameValid = computed(
    () => fieldName.value.trim().length > 0 && fieldName.value.trim().length <= 80,
  );

  const canSave = computed(() => nameValid.value && !saving.value);

  // ── Build payloads ─────────────────────────────────────────────────────────

  function buildCreatePayload(): ShipModuleCreate {
    const slot = selectedSlot.value;
    const name = fieldName.value.trim();
    const energyUse = fieldEnergyUse.value;
    const notes = fieldNotes.value || null;

    if (slot === 'WEAPON') {
      return {
        slot,
        name,
        energyUse,
        weaponBonus: fieldWeaponBonus.value,
        weaponRange: fieldWeaponRange.value,
        weaponDamage: fieldWeaponDamage.value,
        weaponCritThreshold: fieldWeaponCritThreshold.value,
        notes,
      };
    }
    if (slot === 'TORPEDO') {
      return {
        slot,
        name,
        energyUse,
        torpedoCount: fieldTorpedoCount.value,
        mineCount: fieldMineCount.value,
        notes,
      };
    }
    if (slot === 'HOLD') {
      return {
        slot,
        name,
        energyUse,
        cargoTons: fieldCargoTons.value,
        concealed: fieldConcealed.value,
        notes,
      };
    }
    if (slot === 'SENSOR') {
      return { slot, name, energyUse, detectionBonus: fieldDetectionBonus.value, notes };
    }
    // All other slots use the OTHER shape
    return { slot, name, energyUse, notes };
  }

  function buildUpdatePayload(): ShipModuleUpdate {
    if (!props.module) return { slot: 'OTHER' };
    const slot = props.module.slot;
    const name = fieldName.value.trim();
    const energyUse = fieldEnergyUse.value;
    const notes = fieldNotes.value || null;

    if (slot === 'WEAPON') {
      return {
        slot,
        name,
        energyUse,
        weaponBonus: fieldWeaponBonus.value,
        weaponRange: fieldWeaponRange.value,
        weaponDamage: fieldWeaponDamage.value,
        weaponCritThreshold: fieldWeaponCritThreshold.value,
        notes,
      };
    }
    if (slot === 'TORPEDO') {
      return {
        slot,
        name,
        energyUse,
        torpedoCount: fieldTorpedoCount.value,
        mineCount: fieldMineCount.value,
        notes,
      };
    }
    if (slot === 'HOLD') {
      return {
        slot,
        name,
        energyUse,
        cargoTons: fieldCargoTons.value,
        concealed: fieldConcealed.value,
        notes,
      };
    }
    if (slot === 'SENSOR') {
      return { slot, name, energyUse, detectionBonus: fieldDetectionBonus.value, notes };
    }
    return { slot, name, energyUse, notes };
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  async function save(): Promise<void> {
    if (!canSave.value) return;
    saving.value = true;
    errorMsg.value = '';
    try {
      const result: ShipModule = await (isEditMode.value && props.module
        ? modulesApi.updateModule(props.module.id, buildUpdatePayload())
        : modulesApi.addModule(props.shipId, buildCreatePayload()));
      emit('update:module', result);
      emit('update:open', false);
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorSave');
    } finally {
      saving.value = false;
    }
  }

  async function confirmAndDelete(): Promise<void> {
    if (!props.module) return;
    deleting.value = true;
    errorMsg.value = '';
    try {
      await modulesApi.deleteModule(props.module.id);
      emit('delete:module', props.module.id);
      emit('update:open', false);
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorDelete');
      confirmDelete.value = false;
    } finally {
      deleting.value = false;
    }
  }

  function cancel(): void {
    emit('update:open', false);
  }
</script>

<i18n lang="json">
{
  "en": {
    "titleCreate": "Add module",
    "titleEdit": "Edit module",
    "fieldSlot": "Slot type",
    "slotPlaceholder": "Choose slot…",
    "fieldName": "Name",
    "namePlaceholder": "Module name",
    "fieldEnergyUse": "Energy use",
    "fieldNotes": "Notes",
    "notesPlaceholder": "Damage state, conditions…",
    "fieldWeaponBonus": "Attack bonus",
    "fieldWeaponRange": "Range",
    "fieldWeaponDamage": "Damage",
    "fieldWeaponCrit": "Crit threshold",
    "fieldTorpedoCount": "Torpedoes",
    "fieldMineCount": "Mines",
    "fieldCargoTons": "Cargo (tons)",
    "fieldConcealed": "Concealed hold",
    "fieldDetectionBonus": "Detection bonus",
    "rangeZero": "Zero",
    "rangeClose": "Close",
    "rangeMedium": "Medium",
    "rangeLong": "Long",
    "rangeExtreme": "Extreme",
    "slotWeapon": "Weapon",
    "slotTorpedo": "Torpedo",
    "slotHold": "Hold",
    "slotSensor": "Sensor",
    "slotComms": "Comms",
    "slotHangar": "Hangar",
    "slotQuarters": "Quarters",
    "slotMedical": "Medical",
    "slotWorkshop": "Workshop",
    "slotChapel": "Chapel",
    "slotEscapePods": "Escape Pods",
    "slotCryo": "Cryo",
    "slotDocking": "Docking",
    "slotMining": "Mining",
    "slotRepair": "Repair",
    "slotConcealedHold": "Concealed Hold",
    "slotProxyDeck": "Proxy Deck",
    "slotOther": "Other",
    "save": "Save changes",
    "add": "Add module",
    "cancel": "Cancel",
    "delete": "Delete module",
    "deleteConfirmTitle": "Delete this module?",
    "deleteConfirmBody": "This action cannot be undone.",
    "deleteConfirmYes": "Yes, delete",
    "deleteConfirmCancel": "Keep module",
    "errorSave": "Failed to save module.",
    "errorDelete": "Failed to delete module."
  },
  "ru": {
    "titleCreate": "Добавить модуль",
    "titleEdit": "Редактировать модуль",
    "fieldSlot": "Тип слота",
    "slotPlaceholder": "Выберите слот…",
    "fieldName": "Название",
    "namePlaceholder": "Название модуля",
    "fieldEnergyUse": "Расход энергии",
    "fieldNotes": "Заметки",
    "notesPlaceholder": "Состояние повреждений, условия…",
    "fieldWeaponBonus": "Бонус атаки",
    "fieldWeaponRange": "Дальность",
    "fieldWeaponDamage": "Урон",
    "fieldWeaponCrit": "Порог крита",
    "fieldTorpedoCount": "Торпеды",
    "fieldMineCount": "Мины",
    "fieldCargoTons": "Груз (тонн)",
    "fieldConcealed": "Потайной отсек",
    "fieldDetectionBonus": "Бонус обнаружения",
    "rangeZero": "Вплотную",
    "rangeClose": "Близко",
    "rangeMedium": "Средняя",
    "rangeLong": "Далеко",
    "rangeExtreme": "Предельная",
    "slotWeapon": "Оружейный",
    "slotTorpedo": "Торпедный",
    "slotHold": "Грузовой",
    "slotSensor": "Сенсорный",
    "slotComms": "Связь",
    "slotHangar": "Ангар",
    "slotQuarters": "Каюты",
    "slotMedical": "Медблок",
    "slotWorkshop": "Мастерская",
    "slotChapel": "Часовня",
    "slotEscapePods": "Спасательные капсулы",
    "slotCryo": "Криокамеры",
    "slotDocking": "Стыковка",
    "slotMining": "Горнодобывающий",
    "slotRepair": "Ремонтный",
    "slotConcealedHold": "Потайной трюм",
    "slotProxyDeck": "Прокси-палуба",
    "slotOther": "Прочее",
    "save": "Сохранить",
    "add": "Добавить модуль",
    "cancel": "Отмена",
    "delete": "Удалить модуль",
    "deleteConfirmTitle": "Удалить этот модуль?",
    "deleteConfirmBody": "Это действие нельзя отменить.",
    "deleteConfirmYes": "Да, удалить",
    "deleteConfirmCancel": "Оставить модуль",
    "errorSave": "Не удалось сохранить модуль.",
    "errorDelete": "Не удалось удалить модуль."
  }
}
</i18n>

<template>
  <AppModal
    :open="open"
    :aria-label="isEditMode ? t('titleEdit') : t('titleCreate')"
    size="md"
    @update:open="emit('update:open', $event)"
  >
    <div class="ship-module-editor">
      <!-- Header -->
      <h2 id="ship-module-editor-title" class="ship-module-editor__title">
        {{ isEditMode ? t('titleEdit') : t('titleCreate') }}
      </h2>

      <!-- Error banner -->
      <AppBanner v-if="errorMsg" tone="danger" role="alert" class="ship-module-editor__error">
        {{ errorMsg }}
      </AppBanner>

      <!-- ── Confirm-delete sub-panel ───────────────────────────────────────── -->
      <div v-if="confirmDelete" class="ship-module-editor__confirm">
        <p class="ship-module-editor__confirm-title">
          {{ t('deleteConfirmTitle') }}
        </p>
        <p class="ship-module-editor__confirm-body">
          {{ t('deleteConfirmBody') }}
        </p>
        <div class="ship-module-editor__confirm-actions">
          <AppButton variant="danger" size="md" :disabled="deleting" @click="confirmAndDelete">
            {{ t('deleteConfirmYes') }}
          </AppButton>
          <AppButton variant="ghost" size="md" :disabled="deleting" @click="confirmDelete = false">
            {{ t('deleteConfirmCancel') }}
          </AppButton>
        </div>
      </div>

      <!-- ── Main form ──────────────────────────────────────────────────────── -->
      <template v-else>
        <!-- Slot picker — create mode only -->
        <AppField v-if="!isEditMode" :label="t('fieldSlot')" required>
          <template #default="attrs">
            <AppSelect
              v-bind="attrs"
              :model-value="selectedSlot"
              :options="SLOT_OPTIONS"
              :placeholder="t('slotPlaceholder')"
              @update:model-value="selectedSlot = $event as ShipModuleSlot"
            />
          </template>
        </AppField>

        <!-- Name -->
        <AppField :label="t('fieldName')" required>
          <template #default="attrs">
            <AppInput
              v-bind="attrs"
              v-model="fieldName"
              type="text"
              :placeholder="t('namePlaceholder')"
            />
          </template>
        </AppField>

        <!-- Energy use -->
        <AppField :label="t('fieldEnergyUse')">
          <template #default="attrs">
            <div class="ship-module-editor__stepper">
              <AppButton
                variant="ghost"
                size="sm"
                :disabled="fieldEnergyUse <= 0"
                @click="fieldEnergyUse = Math.max(0, fieldEnergyUse - 1)"
              >
                −
              </AppButton>
              <AppInput
                v-bind="attrs"
                v-model="fieldEnergyUse"
                type="number"
                size="md"
                inputmode="numeric"
                class="ship-module-editor__stepper-input"
              />
              <AppButton variant="ghost" size="sm" @click="fieldEnergyUse = fieldEnergyUse + 1">
                +
              </AppButton>
            </div>
          </template>
        </AppField>

        <!-- ── WEAPON discriminator fields ───────────────────────────────── -->
        <template v-if="effectiveSlot === 'WEAPON'">
          <AppField :label="t('fieldWeaponBonus')">
            <template #default="attrs">
              <div class="ship-module-editor__stepper">
                <AppButton
                  variant="ghost"
                  size="sm"
                  :disabled="fieldWeaponBonus <= 0"
                  @click="fieldWeaponBonus = Math.max(0, fieldWeaponBonus - 1)"
                >
                  −
                </AppButton>
                <AppInput
                  v-bind="attrs"
                  v-model="fieldWeaponBonus"
                  type="number"
                  size="md"
                  inputmode="numeric"
                  class="ship-module-editor__stepper-input"
                />
                <AppButton
                  variant="ghost"
                  size="sm"
                  @click="fieldWeaponBonus = fieldWeaponBonus + 1"
                >
                  +
                </AppButton>
              </div>
            </template>
          </AppField>

          <AppField :label="t('fieldWeaponRange')">
            <template #default>
              <AppSegControl
                :model-value="fieldWeaponRange"
                :options="RANGE_OPTIONS"
                size="sm"
                @update:model-value="fieldWeaponRange = $event as ShipWeaponRange"
              />
            </template>
          </AppField>

          <AppField :label="t('fieldWeaponDamage')">
            <template #default="attrs">
              <div class="ship-module-editor__stepper">
                <AppButton
                  variant="ghost"
                  size="sm"
                  :disabled="fieldWeaponDamage <= 0"
                  @click="fieldWeaponDamage = Math.max(0, fieldWeaponDamage - 1)"
                >
                  −
                </AppButton>
                <AppInput
                  v-bind="attrs"
                  v-model="fieldWeaponDamage"
                  type="number"
                  size="md"
                  inputmode="numeric"
                  class="ship-module-editor__stepper-input"
                />
                <AppButton
                  variant="ghost"
                  size="sm"
                  @click="fieldWeaponDamage = fieldWeaponDamage + 1"
                >
                  +
                </AppButton>
              </div>
            </template>
          </AppField>

          <AppField :label="t('fieldWeaponCrit')">
            <template #default="attrs">
              <div class="ship-module-editor__stepper">
                <AppButton
                  variant="ghost"
                  size="sm"
                  :disabled="fieldWeaponCritThreshold <= 1"
                  @click="fieldWeaponCritThreshold = Math.max(1, fieldWeaponCritThreshold - 1)"
                >
                  −
                </AppButton>
                <AppInput
                  v-bind="attrs"
                  v-model="fieldWeaponCritThreshold"
                  type="number"
                  size="md"
                  inputmode="numeric"
                  class="ship-module-editor__stepper-input"
                />
                <AppButton
                  variant="ghost"
                  size="sm"
                  @click="fieldWeaponCritThreshold = fieldWeaponCritThreshold + 1"
                >
                  +
                </AppButton>
              </div>
            </template>
          </AppField>
        </template>

        <!-- ── TORPEDO discriminator fields ──────────────────────────────── -->
        <template v-else-if="effectiveSlot === 'TORPEDO'">
          <AppField :label="t('fieldTorpedoCount')">
            <template #default="attrs">
              <div class="ship-module-editor__stepper">
                <AppButton
                  variant="ghost"
                  size="sm"
                  :disabled="fieldTorpedoCount <= 0"
                  @click="fieldTorpedoCount = Math.max(0, fieldTorpedoCount - 1)"
                >
                  −
                </AppButton>
                <AppInput
                  v-bind="attrs"
                  v-model="fieldTorpedoCount"
                  type="number"
                  size="md"
                  inputmode="numeric"
                  class="ship-module-editor__stepper-input"
                />
                <AppButton
                  variant="ghost"
                  size="sm"
                  @click="fieldTorpedoCount = fieldTorpedoCount + 1"
                >
                  +
                </AppButton>
              </div>
            </template>
          </AppField>

          <AppField :label="t('fieldMineCount')">
            <template #default="attrs">
              <div class="ship-module-editor__stepper">
                <AppButton
                  variant="ghost"
                  size="sm"
                  :disabled="fieldMineCount <= 0"
                  @click="fieldMineCount = Math.max(0, fieldMineCount - 1)"
                >
                  −
                </AppButton>
                <AppInput
                  v-bind="attrs"
                  v-model="fieldMineCount"
                  type="number"
                  size="md"
                  inputmode="numeric"
                  class="ship-module-editor__stepper-input"
                />
                <AppButton variant="ghost" size="sm" @click="fieldMineCount = fieldMineCount + 1">
                  +
                </AppButton>
              </div>
            </template>
          </AppField>
        </template>

        <!-- ── HOLD discriminator fields ──────────────────────────────────── -->
        <template v-else-if="effectiveSlot === 'HOLD'">
          <AppField :label="t('fieldCargoTons')">
            <template #default="attrs">
              <div class="ship-module-editor__stepper">
                <AppButton
                  variant="ghost"
                  size="sm"
                  :disabled="fieldCargoTons <= 0"
                  @click="fieldCargoTons = Math.max(0, fieldCargoTons - 1)"
                >
                  −
                </AppButton>
                <AppInput
                  v-bind="attrs"
                  v-model="fieldCargoTons"
                  type="number"
                  size="md"
                  inputmode="numeric"
                  class="ship-module-editor__stepper-input"
                />
                <AppButton variant="ghost" size="sm" @click="fieldCargoTons = fieldCargoTons + 1">
                  +
                </AppButton>
              </div>
            </template>
          </AppField>

          <AppField :label="t('fieldConcealed')">
            <template #default>
              <AppSwitch v-model="fieldConcealed" :label="t('fieldConcealed')" />
            </template>
          </AppField>
        </template>

        <!-- ── SENSOR discriminator fields ────────────────────────────────── -->
        <template v-else-if="effectiveSlot === 'SENSOR'">
          <AppField :label="t('fieldDetectionBonus')">
            <template #default="attrs">
              <div class="ship-module-editor__stepper">
                <AppButton
                  variant="ghost"
                  size="sm"
                  :disabled="fieldDetectionBonus <= 0"
                  @click="fieldDetectionBonus = Math.max(0, fieldDetectionBonus - 1)"
                >
                  −
                </AppButton>
                <AppInput
                  v-bind="attrs"
                  v-model="fieldDetectionBonus"
                  type="number"
                  size="md"
                  inputmode="numeric"
                  class="ship-module-editor__stepper-input"
                />
                <AppButton
                  variant="ghost"
                  size="sm"
                  @click="fieldDetectionBonus = fieldDetectionBonus + 1"
                >
                  +
                </AppButton>
              </div>
            </template>
          </AppField>
        </template>

        <!-- Notes — always rendered -->
        <AppField :label="t('fieldNotes')">
          <template #default="attrs">
            <AppTextarea
              v-bind="attrs"
              v-model="fieldNotes"
              :rows="3"
              :maxlength="1024"
              :placeholder="t('notesPlaceholder')"
            />
          </template>
        </AppField>

        <!-- Footer actions -->
        <div class="ship-module-editor__footer">
          <div class="ship-module-editor__footer-left">
            <!-- Delete — edit mode only; hidden for mandatory slots -->
            <AppButton
              v-if="isEditMode && !isMandatory"
              variant="danger"
              size="md"
              :disabled="saving || deleting"
              @click="confirmDelete = true"
            >
              {{ t('delete') }}
            </AppButton>
          </div>
          <div class="ship-module-editor__footer-right">
            <AppButton variant="ghost" size="md" :disabled="saving" @click="cancel">
              {{ t('cancel') }}
            </AppButton>
            <AppButton variant="primary" size="md" :disabled="!canSave" @click="save">
              {{ isEditMode ? t('save') : t('add') }}
            </AppButton>
          </div>
        </div>
      </template>
    </div>
  </AppModal>
</template>

<style lang="scss" scoped>
  $stepper-input-width: 72px;

  .ship-module-editor {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
    padding: var(--space-5);

    &__title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__error {
      width: 100%;
    }

    // ── Confirm delete sub-panel ──────────────────────────────────────────────

    &__confirm {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
      padding: var(--space-4);
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      border: 1px solid color-mix(in srgb, var(--state-crimson) 40%, transparent);
    }

    &__confirm-title {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-md-font-size);
      color: var(--state-crimson-bright);
    }

    &__confirm-body {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    &__confirm-actions {
      display: flex;
      gap: var(--space-3);
      flex-wrap: wrap;
    }

    // ── Stepper ───────────────────────────────────────────────────────────────

    &__stepper {
      display: flex;
      align-items: center;
      gap: var(--space-2);
    }

    &__stepper-input {
      width: $stepper-input-width;
      text-align: center;
    }

    // ── Footer ────────────────────────────────────────────────────────────────

    &__footer {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: var(--space-3);
      flex-wrap: wrap;
      padding-top: var(--space-2);
      border-top: 1px solid var(--brand-brass-shadow);
    }

    &__footer-left {
      display: flex;
      gap: var(--space-3);
    }

    &__footer-right {
      display: flex;
      gap: var(--space-3);
      margin-left: auto;
    }
  }
</style>
