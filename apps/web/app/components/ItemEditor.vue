<script setup lang="ts">
  import {
    AppModal,
    AppConfirm,
    AppSegControl,
    AppInput,
    AppTextarea,
    AppBanner,
    AppButton,
    AppSelect,
  } from '@app/ui';
  import type { AppSelectOption } from '@app/ui';
  import { ref, computed, watch } from 'vue';
  import { useItemsApi } from '~/composables/useItemsApi';
  import type { Item, ItemCreate, ItemUpdate, ItemRangeEnum } from '~/composables/useItemsApi';
  import type { ShipModuleSlot } from '@app/api-client-ts';
  import type { Problem } from '~/composables/useTalentsApi';

  const props = defineProps<Props>();
  const emit = defineEmits<{
    'update:open': [value: boolean];
    saved: [item: Item];
    deleted: [itemId: string];
  }>();
  const { t } = useI18n({ useScope: 'local' });
  const itemsApi = useItemsApi();

  // ── Props & emits ─────────────────────────────────────────────────────────

  interface Props {
    open: boolean;
    item: Item | null; // null = create mode
    characterId: string;
  }

  // ── Item type options (AppSegControl) ─────────────────────────────────────

  type ItemType = 'WEAPON' | 'ARMOR' | 'GEAR' | 'CYBERNETIC' | 'SHIP_MODULE' | 'OTHER';

  const TYPE_OPTIONS = computed(
    () =>
      [
        { value: 'WEAPON', label: t('typeWeapon') },
        { value: 'ARMOR', label: t('typeArmor') },
        { value: 'GEAR', label: t('typeGear') },
        { value: 'CYBERNETIC', label: t('typeCybernetic') },
        { value: 'SHIP_MODULE', label: t('typeShipModule') },
        { value: 'OTHER', label: t('typeOther') },
      ] satisfies { value: string; label: string }[],
  );

  const RANGE_OPTIONS = computed<AppSelectOption[]>(() => [
    { value: 'close', label: t('rangeClose') },
    { value: 'medium', label: t('rangeMedium') },
    { value: 'long', label: t('rangeLong') },
    { value: 'extreme', label: t('rangeExtreme') },
  ]);

  const SLOT_OPTIONS = computed<AppSelectOption[]>(() => [
    { value: 'BRIDGE', label: t('slotBridge') },
    { value: 'REACTOR', label: t('slotReactor') },
    { value: 'DRIVE', label: t('slotDrive') },
    { value: 'HOLD', label: t('slotHold') },
    { value: 'WEAPON', label: t('slotWeapon') },
    { value: 'TORPEDO', label: t('slotTorpedo') },
    { value: 'SENSOR', label: t('slotSensor') },
    { value: 'COMMS', label: t('slotComms') },
    { value: 'HANGAR', label: t('slotHangar') },
    { value: 'QUARTERS', label: t('slotQuarters') },
    { value: 'MEDICAL', label: t('slotMedical') },
    { value: 'WORKSHOP', label: t('slotWorkshop') },
    { value: 'CHAPEL', label: t('slotChapel') },
    { value: 'ESCAPE-PODS', label: t('slotEscapePods') },
    { value: 'OTHER', label: t('slotOther') },
  ]);

  // ── Local form state ──────────────────────────────────────────────────────

  const selectedType = ref<ItemType>('WEAPON');
  const saving = ref(false);
  const deleting = ref(false);
  const errorMsg = ref('');

  // Common fields
  const fieldName = ref('');
  const fieldNotes = ref('');
  const fieldEquipped = ref(false);

  // WEAPON-specific
  const fieldBonus = ref(0);
  const fieldDamage = ref(1);
  const fieldCrit = ref(1);
  const fieldRange = ref<ItemRangeEnum>('close');
  const fieldWeight = ref(1);

  // ARMOR-specific
  const fieldArmorRating = ref(0);
  // (shares fieldWeight, fieldEquipped)

  // GEAR-specific
  const fieldQuantity = ref(1);
  // (shares fieldWeight, fieldNotes)

  // CYBERNETIC-specific
  const fieldXpCost = ref(5);
  const fieldEffect = ref('');

  // SHIP_MODULE-specific
  const fieldSlot = ref<ShipModuleSlot>('OTHER');
  // (shares fieldEffect)

  const isEditMode = computed(() => props.item !== null);

  // ── Sync form when item or open changes ──────────────────────────────────

  function resetToItem(item: Item | null): void {
    errorMsg.value = '';
    if (!item) {
      // Create mode — reset to defaults
      selectedType.value = 'WEAPON';
      fieldName.value = '';
      fieldNotes.value = '';
      fieldEquipped.value = false;
      fieldBonus.value = 0;
      fieldDamage.value = 1;
      fieldCrit.value = 1;
      fieldRange.value = 'close';
      fieldWeight.value = 1;
      fieldArmorRating.value = 0;
      fieldQuantity.value = 1;
      fieldXpCost.value = 5;
      fieldEffect.value = '';
      fieldSlot.value = 'OTHER';
      return;
    }

    selectedType.value = item.type as ItemType;
    fieldName.value = item.name;

    switch (item.type) {
      case 'WEAPON': {
        fieldBonus.value = item.bonus;
        fieldDamage.value = item.damage;
        fieldCrit.value = item.crit;
        fieldRange.value = item.range;
        fieldWeight.value = item.weight;
        fieldEquipped.value = item.equipped;
        fieldNotes.value = '';

        break;
      }
      case 'ARMOR': {
        fieldArmorRating.value = item.armorRating;
        fieldWeight.value = item.weight;
        fieldEquipped.value = item.equipped;
        fieldNotes.value = '';

        break;
      }
      case 'GEAR': {
        fieldWeight.value = item.weight;
        fieldQuantity.value = item.quantity;
        fieldNotes.value = item.notes ?? '';

        break;
      }
      case 'CYBERNETIC': {
        fieldXpCost.value = item.xpCost;
        fieldEffect.value = item.effect;
        fieldNotes.value = '';

        break;
      }
      case 'SHIP_MODULE': {
        fieldSlot.value = item.slot;
        fieldEffect.value = item.effect;
        fieldNotes.value = '';

        break;
      }
      case 'OTHER': {
        fieldWeight.value = item.weight;
        fieldNotes.value = item.notes ?? '';

        break;
      }
      // No default
    }
  }

  watch(
    () => [props.open, props.item] as const,
    ([isOpen, item]) => {
      if (isOpen) resetToItem(item);
    },
    { immediate: true },
  );

  // ── Validation ─────────────────────────────────────────────────────────────

  const nameValid = computed(
    () => fieldName.value.trim().length > 0 && fieldName.value.trim().length <= 80,
  );

  const canSave = computed(() => nameValid.value && !saving.value);

  // ── Build create/update payload ────────────────────────────────────────────

  function buildCreatePayload(): ItemCreate {
    const type = selectedType.value;
    const name = fieldName.value.trim();

    if (type === 'WEAPON') {
      return {
        type,
        name,
        bonus: fieldBonus.value,
        damage: fieldDamage.value,
        crit: fieldCrit.value,
        range: fieldRange.value,
        weight: fieldWeight.value,
        features: [],
        equipped: fieldEquipped.value,
      };
    }
    if (type === 'ARMOR') {
      return {
        type,
        name,
        armorRating: fieldArmorRating.value,
        weight: fieldWeight.value,
        features: [],
        equipped: fieldEquipped.value,
      };
    }
    if (type === 'GEAR') {
      return {
        type,
        name,
        weight: fieldWeight.value,
        quantity: fieldQuantity.value,
        notes: fieldNotes.value || null,
      };
    }
    if (type === 'CYBERNETIC') {
      return {
        type,
        name,
        xpCost: fieldXpCost.value,
        effect: fieldEffect.value,
      };
    }
    if (type === 'SHIP_MODULE') {
      return {
        type,
        name,
        slot: fieldSlot.value,
        effect: fieldEffect.value,
      };
    }
    // OTHER
    return {
      type: 'OTHER',
      name,
      weight: fieldWeight.value,
      notes: fieldNotes.value || null,
    };
  }

  function buildUpdatePayload(): ItemUpdate {
    const type = selectedType.value;
    const name = fieldName.value.trim();

    if (type === 'WEAPON') {
      return {
        type,
        name,
        bonus: fieldBonus.value,
        damage: fieldDamage.value,
        crit: fieldCrit.value,
        range: fieldRange.value,
        weight: fieldWeight.value,
        equipped: fieldEquipped.value,
      };
    }
    if (type === 'ARMOR') {
      return {
        type,
        name,
        armorRating: fieldArmorRating.value,
        weight: fieldWeight.value,
        equipped: fieldEquipped.value,
      };
    }
    if (type === 'GEAR') {
      return {
        type,
        name,
        weight: fieldWeight.value,
        quantity: fieldQuantity.value,
        notes: fieldNotes.value || null,
      };
    }
    if (type === 'CYBERNETIC') {
      return {
        type,
        name,
        xpCost: fieldXpCost.value,
        effect: fieldEffect.value,
      };
    }
    if (type === 'SHIP_MODULE') {
      return {
        type,
        name,
        slot: fieldSlot.value,
        effect: fieldEffect.value,
      };
    }
    return {
      type: 'OTHER',
      name,
      weight: fieldWeight.value,
      notes: fieldNotes.value || null,
    };
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  async function save(): Promise<void> {
    if (!canSave.value) return;
    saving.value = true;
    errorMsg.value = '';
    try {
      const result: Item = await (isEditMode.value && props.item
        ? itemsApi.updateItem(props.item.id, buildUpdatePayload())
        : itemsApi.addItem(props.characterId, buildCreatePayload()));
      emit('saved', result);
      emit('update:open', false);
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorSave');
    } finally {
      saving.value = false;
    }
  }

  // Two-step destructive flow: clicking Delete opens the AppConfirm; the
  // real remove call fires only after the user confirms.
  const deleteConfirmOpen = ref(false);

  function deleteItem(): void {
    if (!props.item) return;
    deleteConfirmOpen.value = true;
  }

  async function onConfirmDelete(): Promise<void> {
    if (!props.item) {
      deleteConfirmOpen.value = false;
      return;
    }
    deleting.value = true;
    errorMsg.value = '';
    try {
      await itemsApi.removeItem(props.item.id);
      emit('deleted', props.item.id);
      emit('update:open', false);
    } catch (error) {
      const problem = error as Problem;
      errorMsg.value = problem.detail ?? t('errorDelete');
    } finally {
      deleting.value = false;
      deleteConfirmOpen.value = false;
    }
  }

  function cancel(): void {
    emit('update:open', false);
  }
</script>

<i18n lang="json">
{
  "en": {
    "titleCreate": "Add item",
    "titleEdit": "Edit item",
    "fieldName": "Name",
    "namePlaceholder": "Item name",
    "fieldNotes": "Notes",
    "notesPlaceholder": "Optional notes…",
    "fieldBonus": "Bonus",
    "fieldDamage": "Damage",
    "fieldCrit": "Critical",
    "fieldRange": "Range",
    "fieldWeight": "Weight (slots)",
    "fieldArmorRating": "Armor rating",
    "fieldQuantity": "Quantity",
    "fieldXpCost": "XP cost",
    "fieldEffect": "Effect / description",
    "fieldSlot": "Ship slot",
    "fieldEquipped": "Equipped",
    "typeWeapon": "Weapon",
    "typeArmor": "Armor",
    "typeGear": "Gear",
    "typeCybernetic": "Cybernetic",
    "typeShipModule": "Ship module",
    "typeOther": "Other",
    "rangeClose": "Close",
    "rangeMedium": "Medium",
    "rangeLong": "Long",
    "rangeExtreme": "Extreme",
    "slotBridge": "Bridge",
    "slotReactor": "Reactor",
    "slotDrive": "Drive",
    "slotHold": "Hold",
    "slotWeapon": "Weapon",
    "slotTorpedo": "Torpedo",
    "slotSensor": "Sensor",
    "slotComms": "Comms",
    "slotHangar": "Hangar",
    "slotQuarters": "Quarters",
    "slotMedical": "Medical",
    "slotWorkshop": "Workshop",
    "slotChapel": "Chapel",
    "slotEscapePods": "Escape pods",
    "slotOther": "Other",
    "save": "Save",
    "cancel": "Cancel",
    "delete": "Remove",
    "deleteItem": "Remove item",
    "deleteConfirmTitle": "Remove this item?",
    "deleteConfirm": "Remove \"{name}\"? This cannot be undone.",
    "errorSave": "Failed to save item.",
    "errorDelete": "Failed to remove item.",
    "typeDisabledHint": "Type cannot be changed after creation."
  },
  "ru": {
    "titleCreate": "Добавить предмет",
    "titleEdit": "Редактировать предмет",
    "fieldName": "Название",
    "namePlaceholder": "Название предмета",
    "fieldNotes": "Заметки",
    "notesPlaceholder": "Дополнительные заметки…",
    "fieldBonus": "Бонус",
    "fieldDamage": "Урон",
    "fieldCrit": "Критический",
    "fieldRange": "Дальность",
    "fieldWeight": "Вес (ячейки)",
    "fieldArmorRating": "Показатель брони",
    "fieldQuantity": "Количество",
    "fieldXpCost": "Стоимость опыта",
    "fieldEffect": "Эффект / описание",
    "fieldSlot": "Слот корабля",
    "fieldEquipped": "Экипировано",
    "typeWeapon": "Оружие",
    "typeArmor": "Броня",
    "typeGear": "Снаряжение",
    "typeCybernetic": "Кибернетика",
    "typeShipModule": "Модуль корабля",
    "typeOther": "Прочее",
    "rangeClose": "Ближняя",
    "rangeMedium": "Средняя",
    "rangeLong": "Дальняя",
    "rangeExtreme": "Предельная",
    "slotBridge": "Мостик",
    "slotReactor": "Реактор",
    "slotDrive": "Двигатель",
    "slotHold": "Трюм",
    "slotWeapon": "Оружейный",
    "slotTorpedo": "Торпедный",
    "slotSensor": "Сенсор",
    "slotComms": "Связь",
    "slotHangar": "Ангар",
    "slotQuarters": "Жилой",
    "slotMedical": "Медотсек",
    "slotWorkshop": "Мастерская",
    "slotChapel": "Часовня",
    "slotEscapePods": "Спасательные капсулы",
    "slotOther": "Другое",
    "save": "Сохранить",
    "cancel": "Отмена",
    "delete": "Удалить",
    "deleteItem": "Удалить предмет",
    "deleteConfirmTitle": "Удалить предмет?",
    "deleteConfirm": "Удалить «{name}»? Это необратимо.",
    "errorSave": "Не удалось сохранить предмет.",
    "errorDelete": "Не удалось удалить предмет.",
    "typeDisabledHint": "Тип нельзя изменить после создания."
  }
}
</i18n>

<template>
  <AppModal
    :open="open"
    :aria-label="isEditMode ? t('titleEdit') : t('titleCreate')"
    size="md"
    @update:open="$emit('update:open', $event)"
  >
    <div class="item-editor">
      <h2 class="item-editor__title">
        {{ isEditMode ? t('titleEdit') : t('titleCreate') }}
      </h2>

      <!-- Error banner -->
      <AppBanner v-if="errorMsg" tone="danger" class="item-editor__error">
        {{ errorMsg }}
      </AppBanner>

      <!-- Type selector — disabled in edit mode -->
      <div class="item-editor__type-selector">
        <AppSegControl
          v-model="selectedType"
          :options="TYPE_OPTIONS"
          size="sm"
          :disabled="isEditMode"
        />
        <p v-if="isEditMode" class="item-editor__type-hint">
          {{ t('typeDisabledHint') }}
        </p>
      </div>

      <!-- Common: name -->
      <div class="item-editor__field">
        <label class="item-editor__label" for="item-name">{{ t('fieldName') }}</label>
        <AppInput
          id="item-name"
          v-model="fieldName"
          size="md"
          :placeholder="t('namePlaceholder')"
          autocomplete="off"
        />
      </div>

      <!-- ── WEAPON fields ─────────────────────────────────────────────────── -->
      <template v-if="selectedType === 'WEAPON'">
        <div class="item-editor__row">
          <div class="item-editor__field">
            <label class="item-editor__label" for="item-bonus">{{ t('fieldBonus') }}</label>
            <AppInput
              id="item-bonus"
              v-model.number="fieldBonus"
              type="number"
              size="md"
              :min="-3"
              :max="3"
            />
          </div>
          <div class="item-editor__field">
            <label class="item-editor__label" for="item-damage">{{ t('fieldDamage') }}</label>
            <AppInput
              id="item-damage"
              v-model.number="fieldDamage"
              type="number"
              size="md"
              :min="0"
              :max="6"
            />
          </div>
          <div class="item-editor__field">
            <label class="item-editor__label" for="item-crit">{{ t('fieldCrit') }}</label>
            <AppInput
              id="item-crit"
              v-model.number="fieldCrit"
              type="number"
              size="md"
              :min="0"
              :max="3"
            />
          </div>
        </div>
        <div class="item-editor__row">
          <div class="item-editor__field">
            <label class="item-editor__label" for="item-range">{{ t('fieldRange') }}</label>
            <AppSelect id="item-range" v-model="fieldRange" :options="RANGE_OPTIONS" size="md" />
          </div>
          <div class="item-editor__field">
            <label class="item-editor__label" for="item-weight">{{ t('fieldWeight') }}</label>
            <AppInput
              id="item-weight"
              v-model.number="fieldWeight"
              type="number"
              size="md"
              :min="0"
              :max="10"
              :step="0.5"
            />
          </div>
        </div>
        <div class="item-editor__field item-editor__field--check">
          <label class="item-editor__label item-editor__label--inline">
            <input v-model="fieldEquipped" type="checkbox" class="item-editor__checkbox" />
            {{ t('fieldEquipped') }}
          </label>
        </div>
      </template>

      <!-- ── ARMOR fields ──────────────────────────────────────────────────── -->
      <template v-else-if="selectedType === 'ARMOR'">
        <div class="item-editor__row">
          <div class="item-editor__field">
            <label class="item-editor__label" for="item-armor">{{ t('fieldArmorRating') }}</label>
            <AppInput
              id="item-armor"
              v-model.number="fieldArmorRating"
              type="number"
              size="md"
              :min="0"
              :max="10"
            />
          </div>
          <div class="item-editor__field">
            <label class="item-editor__label" for="item-weight-armor">{{ t('fieldWeight') }}</label>
            <AppInput
              id="item-weight-armor"
              v-model.number="fieldWeight"
              type="number"
              size="md"
              :min="0"
              :max="10"
              :step="0.5"
            />
          </div>
        </div>
        <div class="item-editor__field item-editor__field--check">
          <label class="item-editor__label item-editor__label--inline">
            <input v-model="fieldEquipped" type="checkbox" class="item-editor__checkbox" />
            {{ t('fieldEquipped') }}
          </label>
        </div>
      </template>

      <!-- ── GEAR fields ───────────────────────────────────────────────────── -->
      <template v-else-if="selectedType === 'GEAR'">
        <div class="item-editor__row">
          <div class="item-editor__field">
            <label class="item-editor__label" for="item-qty">{{ t('fieldQuantity') }}</label>
            <AppInput
              id="item-qty"
              v-model.number="fieldQuantity"
              type="number"
              size="md"
              :min="1"
            />
          </div>
          <div class="item-editor__field">
            <label class="item-editor__label" for="item-weight-gear">{{ t('fieldWeight') }}</label>
            <AppInput
              id="item-weight-gear"
              v-model.number="fieldWeight"
              type="number"
              size="md"
              :min="0"
              :max="10"
              :step="0.5"
            />
          </div>
        </div>
        <div class="item-editor__field">
          <label class="item-editor__label" for="item-notes-gear">{{ t('fieldNotes') }}</label>
          <AppTextarea
            id="item-notes-gear"
            v-model="fieldNotes"
            :placeholder="t('notesPlaceholder')"
            :rows="3"
          />
        </div>
      </template>

      <!-- ── CYBERNETIC fields ─────────────────────────────────────────────── -->
      <template v-else-if="selectedType === 'CYBERNETIC'">
        <div class="item-editor__field">
          <label class="item-editor__label" for="item-xpcost">{{ t('fieldXpCost') }}</label>
          <AppInput
            id="item-xpcost"
            v-model.number="fieldXpCost"
            type="number"
            size="md"
            :min="0"
            :max="15"
          />
        </div>
        <div class="item-editor__field">
          <label class="item-editor__label" for="item-effect-cyber">{{ t('fieldEffect') }}</label>
          <AppTextarea
            id="item-effect-cyber"
            v-model="fieldEffect"
            :placeholder="t('notesPlaceholder')"
            :rows="3"
          />
        </div>
      </template>

      <!-- ── SHIP_MODULE fields ────────────────────────────────────────────── -->
      <template v-else-if="selectedType === 'SHIP_MODULE'">
        <div class="item-editor__field">
          <label class="item-editor__label" for="item-slot">{{ t('fieldSlot') }}</label>
          <AppSelect id="item-slot" v-model="fieldSlot" :options="SLOT_OPTIONS" size="md" />
        </div>
        <div class="item-editor__field">
          <label class="item-editor__label" for="item-effect-ship">{{ t('fieldEffect') }}</label>
          <AppTextarea
            id="item-effect-ship"
            v-model="fieldEffect"
            :placeholder="t('notesPlaceholder')"
            :rows="3"
          />
        </div>
      </template>

      <!-- ── OTHER fields ──────────────────────────────────────────────────── -->
      <template v-else-if="selectedType === 'OTHER'">
        <div class="item-editor__field">
          <label class="item-editor__label" for="item-weight-other">{{ t('fieldWeight') }}</label>
          <AppInput
            id="item-weight-other"
            v-model.number="fieldWeight"
            type="number"
            size="md"
            :min="0"
            :max="10"
            :step="0.5"
          />
        </div>
        <div class="item-editor__field">
          <label class="item-editor__label" for="item-notes-other">{{ t('fieldNotes') }}</label>
          <AppTextarea
            id="item-notes-other"
            v-model="fieldNotes"
            :placeholder="t('notesPlaceholder')"
            :rows="3"
          />
        </div>
      </template>
    </div>

    <!-- Footer slot — save / cancel / delete -->
    <template #footer>
      <button
        v-if="isEditMode"
        type="button"
        class="item-editor__delete-link"
        :disabled="deleting"
        @click="deleteItem"
      >
        {{ t('deleteItem') }}
      </button>
      <div class="item-editor__footer-actions">
        <AppButton variant="ghost" size="md" @click="cancel">
          {{ t('cancel') }}
        </AppButton>
        <AppButton variant="primary" size="md" :loading="saving" :disabled="!canSave" @click="save">
          {{ t('save') }}
        </AppButton>
      </div>
    </template>
  </AppModal>

  <AppConfirm
    v-if="props.item"
    v-model:open="deleteConfirmOpen"
    tone="danger"
    :title="t('deleteConfirmTitle')"
    :body="t('deleteConfirm', { name: props.item.name })"
    :confirm-label="t('delete')"
    :cancel-label="t('cancel')"
    :loading="deleting"
    @confirm="onConfirmDelete"
  />
</template>

<style lang="scss" scoped>
  // Checkbox size — sub-space-scale dimension; SCSS variable is the approved escape hatch.
  $checkbox-size: 16px;

  .item-editor {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);

    &__title {
      font-family: var(--type-display-sm-font-family);
      font-size: var(--type-display-sm-font-size);
      color: var(--brand-brass-light);
      margin: 0;
      letter-spacing: var(--type-display-sm-letter-spacing);
    }

    &__error {
      // No extra margin — gap handles spacing
    }

    &__type-selector {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
      // Wrap on mobile
      overflow-x: auto;
    }

    &__type-hint {
      margin: 0;
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      font-style: italic;
    }

    &__field {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);

      &--check {
        flex-direction: row;
        align-items: center;
      }
    }

    &__label {
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      color: var(--brand-brass);
      font-weight: 500;
      letter-spacing: 0.1em;
      text-transform: uppercase;

      &--inline {
        display: flex;
        align-items: center;
        gap: var(--space-2);
        text-transform: none;
        letter-spacing: normal;
        color: var(--text-primary);
        cursor: pointer;
      }
    }

    &__checkbox {
      width: $checkbox-size;
      height: $checkbox-size;
      accent-color: var(--brand-brass);
      cursor: pointer;
    }

    &__row {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
      gap: var(--space-3);
    }

    &__delete-link {
      flex: 1;
      text-align: left;
      background: none;
      border: none;
      padding: 0;
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      color: var(--state-crimson-bright);
      cursor: pointer;
      text-decoration: underline;
      text-underline-offset: 2px;

      &:hover:not(:disabled) {
        color: var(--state-crimson);
      }

      &:disabled {
        opacity: var(--opacity-disabled);
        cursor: not-allowed;
      }
    }

    &__footer-actions {
      display: flex;
      gap: var(--space-3);
    }
  }
</style>
