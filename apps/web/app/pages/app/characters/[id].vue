<script setup lang="ts">
  import {
    AppCard,
    AppButton,
    AppInput,
    AppStatBlock,
    AppPopover,
    AppDots,
    AppDivider,
  } from '@app/ui';
  import { ref, watch, onBeforeUnmount, computed } from 'vue';
  import { useCharactersApi } from '~/composables/useCharactersApi';
  import type { Character, Problem } from '~/composables/useCharactersApi';
  import type { Attributes, Skills } from '@app/api-client-ts';
  import { useAutoSave } from '~/composables/useAutoSave';

  const { t } = useI18n({ useScope: 'local' });
  const api = useCharactersApi();
  const route = useRoute();

  const characterId = computed<string>(() => route.params.id as string);

  // ── Skill / Attribute constants ──────────────────────────────────────────────

  type AttrKey = 'strength' | 'agility' | 'wits' | 'empathy';
  type AttrBadge = 'STR' | 'AGI' | 'WIT' | 'EMP';
  type GeneralSkillKey =
    | 'force'
    | 'meleeCombat'
    | 'dexterity'
    | 'infiltration'
    | 'rangedCombat'
    | 'observation'
    | 'survival'
    | 'manipulation';
  type AdvancedSkillKey =
    | 'command'
    | 'culture'
    | 'dataDjinn'
    | 'medicurgy'
    | 'mysticPowers'
    | 'pilot'
    | 'science'
    | 'technology';
  type SkillKey = GeneralSkillKey | AdvancedSkillKey;

  const ATTR_KEYS: AttrKey[] = ['strength', 'agility', 'wits', 'empathy'];

  const GENERAL_SKILLS: GeneralSkillKey[] = [
    'force',
    'meleeCombat',
    'dexterity',
    'infiltration',
    'rangedCombat',
    'observation',
    'survival',
    'manipulation',
  ];
  const ADVANCED_SKILLS: AdvancedSkillKey[] = [
    'command',
    'culture',
    'dataDjinn',
    'medicurgy',
    'mysticPowers',
    'pilot',
    'science',
    'technology',
  ];

  const SKILL_GOVERNING_ATTR: Record<SkillKey, AttrBadge> = {
    force: 'STR',
    meleeCombat: 'STR',
    dexterity: 'AGI',
    infiltration: 'AGI',
    rangedCombat: 'AGI',
    pilot: 'AGI',
    observation: 'WIT',
    survival: 'WIT',
    dataDjinn: 'WIT',
    medicurgy: 'WIT',
    science: 'WIT',
    technology: 'WIT',
    manipulation: 'EMP',
    command: 'EMP',
    culture: 'EMP',
    mysticPowers: 'EMP',
  };

  // ── Load state ───────────────────────────────────────────────────────────────

  type LoadState = 'loading' | 'loaded' | 'not-found' | 'error';

  const state = ref<LoadState>('loading');
  const character = ref<Character | null>(null);
  const errorMsg = ref('');

  // ── Editable local copies ────────────────────────────────────────────────────

  const nameValue = ref('');
  const conceptValue = ref('');

  // Local copies of attributes and skills for optimistic updates.
  const localAttributes = ref<Attributes>({
    strength: 2,
    agility: 2,
    wits: 2,
    empathy: 2,
  });
  const localSkills = ref<Skills>({
    dexterity: 0,
    force: 0,
    infiltration: 0,
    manipulation: 0,
    meleeCombat: 0,
    observation: 0,
    rangedCombat: 0,
    survival: 0,
    command: 0,
    culture: 0,
    dataDjinn: 0,
    medicurgy: 0,
    mysticPowers: 0,
    pilot: 0,
    science: 0,
    technology: 0,
  });

  // Local HP current (optimistically updated on +/-; max comes from server).
  const localHpCurrent = ref(0);
  const localMpCurrent = ref(0);

  // Delete confirmation
  const deleteDialogOpen = ref(false);
  const deleteLoading = ref(false);

  // Popover state — at most one open at a time.
  const openPopover = ref<string | null>(null);
  // Stepper pending value — holds the uncommitted in-popover value.
  const stepperValue = ref(0);

  // ── Auto-save: name + concept ────────────────────────────────────────────────

  const {
    saveState,
    saveError,
    schedule: scheduleIdentitySave,
    cancel: cancelIdentitySave,
  } = useAutoSave(
    async () => {
      if (!character.value) return;
      const trimmedName = nameValue.value.trim();
      if (!trimmedName) return;
      const updated = await api.update(characterId.value, {
        name: trimmedName,
        concept: conceptValue.value.trim() || null,
      });
      character.value = updated;
      localHpCurrent.value = updated.hp.current;
      localMpCurrent.value = updated.mp.current;
    },
    { debounceMs: 500 },
  );

  watch(nameValue, () => {
    if (state.value !== 'loaded') return;
    scheduleIdentitySave();
  });
  watch(conceptValue, () => {
    if (state.value !== 'loaded') return;
    scheduleIdentitySave();
  });

  // ── Load ─────────────────────────────────────────────────────────────────────

  async function load(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    try {
      const data = await api.get(characterId.value);
      character.value = data;
      nameValue.value = data.name;
      conceptValue.value = data.concept ?? '';
      localAttributes.value = { ...data.attributes };
      localSkills.value = { ...data.skills };
      localHpCurrent.value = data.hp.current;
      localMpCurrent.value = data.mp.current;
      state.value = 'loaded';
    } catch (error) {
      const problem = error as Problem;
      if (problem.status === 404 || problem.status === 403) {
        state.value = 'not-found';
      } else {
        errorMsg.value = problem.detail ?? t('errorLoad');
        state.value = 'error';
      }
    }
  }

  onMounted(() => {
    void load();
  });

  onBeforeUnmount(() => {
    cancelIdentitySave();
  });

  // ── Helpers ───────────────────────────────────────────────────────────────────

  function initials(name: string): string {
    return name
      .trim()
      .split(/\s+/)
      .slice(0, 2)
      .map((w) => w[0]?.toUpperCase() ?? '')
      .join('');
  }

  // ── Attribute inline edit ─────────────────────────────────────────────────────

  function openAttrPopover(key: AttrKey): void {
    stepperValue.value = localAttributes.value[key];
    openPopover.value = `attr-${key}`;
  }

  function closeAttrPopover(): void {
    openPopover.value = null;
  }

  function attrPopoverOpen(key: AttrKey): boolean {
    return openPopover.value === `attr-${key}`;
  }

  async function commitAttr(key: AttrKey, newValue: number): Promise<void> {
    if (!character.value) return;
    const prev = localAttributes.value[key];
    // Optimistic update
    localAttributes.value = { ...localAttributes.value, [key]: newValue };
    closeAttrPopover();
    try {
      const updated = await api.update(characterId.value, {
        attributes: { ...localAttributes.value },
      });
      character.value = updated;
      localAttributes.value = { ...updated.attributes };
      localHpCurrent.value = updated.hp.current;
      localMpCurrent.value = updated.mp.current;
    } catch {
      // Rollback
      localAttributes.value = { ...localAttributes.value, [key]: prev };
    }
  }

  // ── Skill inline edit ──────────────────────────────────────────────────────────

  function openSkillPopover(key: SkillKey): void {
    stepperValue.value = localSkills.value[key];
    openPopover.value = `skill-${key}`;
  }

  function closeSkillPopover(): void {
    openPopover.value = null;
  }

  function skillPopoverOpen(key: SkillKey): boolean {
    return openPopover.value === `skill-${key}`;
  }

  async function commitSkill(key: SkillKey, newValue: number): Promise<void> {
    if (!character.value) return;
    const prev = localSkills.value[key];
    // Optimistic update
    localSkills.value = { ...localSkills.value, [key]: newValue };
    closeSkillPopover();
    try {
      const updated = await api.update(characterId.value, {
        skills: { ...localSkills.value },
      });
      character.value = updated;
      localSkills.value = { ...updated.skills };
    } catch {
      // Rollback
      localSkills.value = { ...localSkills.value, [key]: prev };
    }
  }

  // ── HP / MP counter ────────────────────────────────────────────────────────────

  async function adjustHp(delta: number): Promise<void> {
    if (!character.value) return;
    const max = character.value.hp.max;
    const prev = localHpCurrent.value;
    const next = Math.max(0, Math.min(max, prev + delta));
    if (next === prev) return;
    localHpCurrent.value = next;
    try {
      const updated = await api.update(characterId.value, {
        hp: { current: next },
      });
      character.value = updated;
      localHpCurrent.value = updated.hp.current;
    } catch {
      localHpCurrent.value = prev;
    }
  }

  async function adjustMp(delta: number): Promise<void> {
    if (!character.value) return;
    const max = character.value.mp.max;
    const prev = localMpCurrent.value;
    const next = Math.max(0, Math.min(max, prev + delta));
    if (next === prev) return;
    localMpCurrent.value = next;
    try {
      const updated = await api.update(characterId.value, {
        mp: { current: next },
      });
      character.value = updated;
      localMpCurrent.value = updated.mp.current;
    } catch {
      localMpCurrent.value = prev;
    }
  }

  // ── Delete ──────────────────────────────────────────────────────────────────────

  function openDeleteDialog(): void {
    deleteDialogOpen.value = true;
  }

  function closeDeleteDialog(): void {
    deleteDialogOpen.value = false;
  }

  async function confirmDelete(): Promise<void> {
    deleteLoading.value = true;
    try {
      await api.delete(characterId.value);
      await navigateTo('/app/characters');
    } catch {
      deleteDialogOpen.value = false;
    } finally {
      deleteLoading.value = false;
    }
  }

  // ── Computed labels for attributes ───────────────────────────────────────────

  function attrLabel(key: AttrKey): string {
    return t(`attr.${key}`);
  }

  function skillLabel(key: SkillKey): string {
    return t(`skill.${key}`);
  }
</script>

<i18n lang="json">
{
  "en": {
    "pageTitle": "Character sheet",
    "namePlaceholder": "Character name",
    "conceptPlaceholder": "Concept — e.g. Veteran fringe pilot",
    "deleteButton": "Delete character",
    "deleteConfirmHeading": "Delete this character?",
    "deleteConfirmBody": "This action is permanent and cannot be undone.",
    "deleteConfirmYes": "Delete",
    "deleteConfirmNo": "Cancel",
    "statusSaving": "Saving…",
    "statusSaved": "Saved",
    "statusError": "Save failed",
    "errorLoad": "Failed to load character.",
    "errorSave": "Auto-save failed. Your changes may not have been saved.",
    "errorDelete": "Failed to delete character. Please try again.",
    "notFoundHeading": "Character not found",
    "notFoundBody": "This character does not exist or you do not have access to it.",
    "notFoundBack": "Back to characters",
    "panelIdentity": "Identity",
    "panelConditions": "Conditions",
    "panelAttributes": "Attributes",
    "panelSkills": "Skills",
    "panelEquipped": "Equipped",
    "panelTalents": "Talents",
    "panelRolls": "Recent Rolls",
    "skillsGeneral": "General",
    "skillsAdvanced": "Advanced",
    "skillsAdvancedNote": "requires training",
    "labelHp": "HP",
    "labelMp": "MP",
    "labelEnc": "ENC",
    "labelDecrease": "Decrease",
    "labelIncrease": "Increase",
    "popoverClose": "Close",
    "comingSoon": "Coming in a future update.",
    "identityConcept": "Concept",
    "attr": {
      "strength": "Strength",
      "agility": "Agility",
      "wits": "Wits",
      "empathy": "Empathy"
    },
    "attrBadge": {
      "strength": "STR",
      "agility": "AGI",
      "wits": "WIT",
      "empathy": "EMP"
    },
    "skill": {
      "force": "Force",
      "meleeCombat": "Melee Combat",
      "dexterity": "Dexterity",
      "infiltration": "Infiltration",
      "rangedCombat": "Ranged Combat",
      "observation": "Observation",
      "survival": "Survival",
      "manipulation": "Manipulation",
      "command": "Command",
      "culture": "Culture",
      "dataDjinn": "Data Djinn",
      "medicurgy": "Medicurgy",
      "mysticPowers": "Mystic Powers",
      "pilot": "Pilot",
      "science": "Science",
      "technology": "Technology"
    }
  },
  "ru": {
    "pageTitle": "Лист персонажа",
    "namePlaceholder": "Имя персонажа",
    "conceptPlaceholder": "Концепция — напр. Ветеран пограничья",
    "deleteButton": "Удалить персонажа",
    "deleteConfirmHeading": "Удалить этого персонажа?",
    "deleteConfirmBody": "Это действие необратимо.",
    "deleteConfirmYes": "Удалить",
    "deleteConfirmNo": "Отмена",
    "statusSaving": "Сохранение…",
    "statusSaved": "Сохранено",
    "statusError": "Ошибка сохранения",
    "errorLoad": "Не удалось загрузить персонажа.",
    "errorSave": "Автосохранение не удалось. Изменения могут быть потеряны.",
    "errorDelete": "Не удалось удалить персонажа. Попробуйте ещё раз.",
    "notFoundHeading": "Персонаж не найден",
    "notFoundBody": "Этот персонаж не существует или у вас нет доступа.",
    "notFoundBack": "К персонажам",
    "panelIdentity": "Личность",
    "panelConditions": "Состояния",
    "panelAttributes": "Атрибуты",
    "panelSkills": "Навыки",
    "panelEquipped": "Снаряжение",
    "panelTalents": "Таланты",
    "panelRolls": "Последние броски",
    "skillsGeneral": "Общие",
    "skillsAdvanced": "Специальные",
    "skillsAdvancedNote": "требует обучения",
    "labelHp": "ОЗ",
    "labelMp": "ОР",
    "labelEnc": "ГР",
    "labelDecrease": "Уменьшить",
    "labelIncrease": "Увеличить",
    "popoverClose": "Закрыть",
    "comingSoon": "Появится в будущем обновлении.",
    "identityConcept": "Концепция",
    "attr": {
      "strength": "Сила",
      "agility": "Ловкость",
      "wits": "Ум",
      "empathy": "Эмпатия"
    },
    "attrBadge": {
      "strength": "СИЛ",
      "agility": "ЛОВ",
      "wits": "УМ",
      "empathy": "ЭМП"
    },
    "skill": {
      "force": "Сила",
      "meleeCombat": "Ближний бой",
      "dexterity": "Ловкость",
      "infiltration": "Скрытность",
      "rangedCombat": "Дальний бой",
      "observation": "Наблюдательность",
      "survival": "Выживание",
      "manipulation": "Манипуляция",
      "command": "Командование",
      "culture": "Культура",
      "dataDjinn": "Дата-джинн",
      "medicurgy": "Медикургия",
      "mysticPowers": "Мистика",
      "pilot": "Пилотаж",
      "science": "Наука",
      "technology": "Технологии"
    }
  },
  "uk": {
    "pageTitle": "[uk-todo] Character sheet",
    "namePlaceholder": "[uk-todo] Character name",
    "conceptPlaceholder": "[uk-todo] Concept",
    "deleteButton": "[uk-todo] Delete character",
    "deleteConfirmHeading": "[uk-todo] Delete this character?",
    "deleteConfirmBody": "[uk-todo] This action is permanent",
    "deleteConfirmYes": "[uk-todo] Delete",
    "deleteConfirmNo": "[uk-todo] Cancel",
    "statusSaving": "[uk-todo] Saving",
    "statusSaved": "[uk-todo] Saved",
    "statusError": "[uk-todo] Save failed",
    "errorLoad": "[uk-todo] Failed to load character",
    "errorSave": "[uk-todo] Auto-save failed",
    "errorDelete": "[uk-todo] Failed to delete character",
    "notFoundHeading": "[uk-todo] Character not found",
    "notFoundBody": "[uk-todo] Does not exist or no access",
    "notFoundBack": "[uk-todo] Back to characters",
    "panelIdentity": "[uk-todo] Identity",
    "panelConditions": "[uk-todo] Conditions",
    "panelAttributes": "[uk-todo] Attributes",
    "panelSkills": "[uk-todo] Skills",
    "panelEquipped": "[uk-todo] Equipped",
    "panelTalents": "[uk-todo] Talents",
    "panelRolls": "[uk-todo] Recent Rolls",
    "skillsGeneral": "[uk-todo] General",
    "skillsAdvanced": "[uk-todo] Advanced",
    "skillsAdvancedNote": "[uk-todo] requires training",
    "labelHp": "HP",
    "labelMp": "MP",
    "labelEnc": "ENC",
    "labelDecrease": "[uk-todo] Decrease",
    "labelIncrease": "[uk-todo] Increase",
    "popoverClose": "[uk-todo] Close",
    "comingSoon": "[uk-todo] Coming in a future update.",
    "identityConcept": "[uk-todo] Concept",
    "attr": {
      "strength": "[uk-todo] Strength",
      "agility": "[uk-todo] Agility",
      "wits": "[uk-todo] Wits",
      "empathy": "[uk-todo] Empathy"
    },
    "attrBadge": {
      "strength": "STR",
      "agility": "AGI",
      "wits": "WIT",
      "empathy": "EMP"
    },
    "skill": {
      "force": "[uk-todo] Force",
      "meleeCombat": "[uk-todo] Melee Combat",
      "dexterity": "[uk-todo] Dexterity",
      "infiltration": "[uk-todo] Infiltration",
      "rangedCombat": "[uk-todo] Ranged Combat",
      "observation": "[uk-todo] Observation",
      "survival": "[uk-todo] Survival",
      "manipulation": "[uk-todo] Manipulation",
      "command": "[uk-todo] Command",
      "culture": "[uk-todo] Culture",
      "dataDjinn": "[uk-todo] Data Djinn",
      "medicurgy": "[uk-todo] Medicurgy",
      "mysticPowers": "[uk-todo] Mystic Powers",
      "pilot": "[uk-todo] Pilot",
      "science": "[uk-todo] Science",
      "technology": "[uk-todo] Technology"
    }
  },
  "el": {
    "pageTitle": "[el-todo] Character sheet",
    "namePlaceholder": "[el-todo] Character name",
    "conceptPlaceholder": "[el-todo] Concept",
    "deleteButton": "[el-todo] Delete character",
    "deleteConfirmHeading": "[el-todo] Delete this character?",
    "deleteConfirmBody": "[el-todo] This action is permanent",
    "deleteConfirmYes": "[el-todo] Delete",
    "deleteConfirmNo": "[el-todo] Cancel",
    "statusSaving": "[el-todo] Saving",
    "statusSaved": "[el-todo] Saved",
    "statusError": "[el-todo] Save failed",
    "errorLoad": "[el-todo] Failed to load character",
    "errorSave": "[el-todo] Auto-save failed",
    "errorDelete": "[el-todo] Failed to delete character",
    "notFoundHeading": "[el-todo] Character not found",
    "notFoundBody": "[el-todo] Does not exist or no access",
    "notFoundBack": "[el-todo] Back to characters",
    "panelIdentity": "[el-todo] Identity",
    "panelConditions": "[el-todo] Conditions",
    "panelAttributes": "[el-todo] Attributes",
    "panelSkills": "[el-todo] Skills",
    "panelEquipped": "[el-todo] Equipped",
    "panelTalents": "[el-todo] Talents",
    "panelRolls": "[el-todo] Recent Rolls",
    "skillsGeneral": "[el-todo] General",
    "skillsAdvanced": "[el-todo] Advanced",
    "skillsAdvancedNote": "[el-todo] requires training",
    "labelHp": "HP",
    "labelMp": "MP",
    "labelEnc": "ENC",
    "labelDecrease": "[el-todo] Decrease",
    "labelIncrease": "[el-todo] Increase",
    "popoverClose": "[el-todo] Close",
    "comingSoon": "[el-todo] Coming in a future update.",
    "identityConcept": "[el-todo] Concept",
    "attr": {
      "strength": "[el-todo] Strength",
      "agility": "[el-todo] Agility",
      "wits": "[el-todo] Wits",
      "empathy": "[el-todo] Empathy"
    },
    "attrBadge": {
      "strength": "STR",
      "agility": "AGI",
      "wits": "WIT",
      "empathy": "EMP"
    },
    "skill": {
      "force": "[el-todo] Force",
      "meleeCombat": "[el-todo] Melee Combat",
      "dexterity": "[el-todo] Dexterity",
      "infiltration": "[el-todo] Infiltration",
      "rangedCombat": "[el-todo] Ranged Combat",
      "observation": "[el-todo] Observation",
      "survival": "[el-todo] Survival",
      "manipulation": "[el-todo] Manipulation",
      "command": "[el-todo] Command",
      "culture": "[el-todo] Culture",
      "dataDjinn": "[el-todo] Data Djinn",
      "medicurgy": "[el-todo] Medicurgy",
      "mysticPowers": "[el-todo] Mystic Powers",
      "pilot": "[el-todo] Pilot",
      "science": "[el-todo] Science",
      "technology": "[el-todo] Technology"
    }
  }
}
</i18n>

<template>
  <section class="page-sheet">
    <!-- ── Loading ───────────────────────────────────────────────────────────── -->
    <div v-if="state === 'loading'" class="page-sheet__loading" aria-busy="true">
      <div class="page-sheet__skeleton-hero" aria-hidden="true" />
      <div class="page-sheet__skeleton-body" aria-hidden="true" />
    </div>

    <!-- ── Not found ─────────────────────────────────────────────────────────── -->
    <div v-else-if="state === 'not-found'" class="page-sheet__not-found">
      <AppCard>
        <div class="page-sheet__not-found-inner">
          <p class="page-sheet__not-found-heading">
            {{ t('notFoundHeading') }}
          </p>
          <p class="page-sheet__not-found-body">
            {{ t('notFoundBody') }}
          </p>
          <AppButton variant="ghost" size="md" @click="navigateTo('/app/characters')">
            {{ t('notFoundBack') }}
          </AppButton>
        </div>
      </AppCard>
    </div>

    <!-- ── Error ─────────────────────────────────────────────────────────────── -->
    <div v-else-if="state === 'error'" class="page-sheet__error" role="alert">
      <p class="page-sheet__error-text">
        {{ errorMsg }}
      </p>
    </div>

    <!-- ── Loaded ─────────────────────────────────────────────────────────────── -->
    <template v-else-if="state === 'loaded' && character">
      <!-- ── Hero plate ──────────────────────────────────────────────────────── -->
      <div class="page-sheet__hero">
        <!-- Portrait avatar -->
        <div class="page-sheet__portrait" aria-hidden="true">
          {{ initials(nameValue || character.name) }}
        </div>

        <!-- Identity (editable name + concept + save status) -->
        <div class="page-sheet__identity">
          <div class="page-sheet__concept-label">
            {{ conceptValue || t('identityConcept') }}
          </div>
          <AppInput
            v-model="nameValue"
            size="lg"
            :placeholder="t('namePlaceholder')"
            :aria-label="t('namePlaceholder')"
            autocomplete="off"
            class="page-sheet__name-input"
          />
          <AppInput
            v-model="conceptValue"
            size="md"
            :placeholder="t('conceptPlaceholder')"
            :aria-label="t('conceptPlaceholder')"
            autocomplete="off"
            class="page-sheet__concept-input"
          />
          <!-- Save indicator -->
          <div class="page-sheet__save-status" aria-live="polite" aria-atomic="true">
            <span
              v-if="saveState === 'saving'"
              class="page-sheet__save-label page-sheet__save-label--saving"
              >{{ t('statusSaving') }}</span
            >
            <span
              v-else-if="saveState === 'saved'"
              class="page-sheet__save-label page-sheet__save-label--saved"
              >{{ t('statusSaved') }}</span
            >
            <span
              v-else-if="saveState === 'error'"
              class="page-sheet__save-label page-sheet__save-label--error"
              role="alert"
              >{{ t('statusError') }}: {{ saveError }}</span
            >
          </div>
        </div>

        <!-- HP / MP / ENC counters -->
        <div class="page-sheet__counters">
          <!-- HP -->
          <div class="page-sheet__counter">
            <span class="page-sheet__counter-label">{{ t('labelHp') }}</span>
            <div class="page-sheet__counter-value">
              {{ localHpCurrent
              }}<span class="page-sheet__counter-max"> / {{ character.hp.max }}</span>
            </div>
            <div class="page-sheet__counter-controls">
              <button
                class="page-sheet__counter-btn"
                :aria-label="t('labelDecrease') + ' ' + t('labelHp')"
                :disabled="localHpCurrent <= 0"
                @click="adjustHp(-1)"
              >
                −
              </button>
              <button
                class="page-sheet__counter-btn"
                :aria-label="t('labelIncrease') + ' ' + t('labelHp')"
                :disabled="localHpCurrent >= character.hp.max"
                @click="adjustHp(1)"
              >
                +
              </button>
            </div>
          </div>

          <!-- MP -->
          <div class="page-sheet__counter page-sheet__counter--mystic">
            <span class="page-sheet__counter-label">{{ t('labelMp') }}</span>
            <div class="page-sheet__counter-value">
              {{ localMpCurrent
              }}<span class="page-sheet__counter-max"> / {{ character.mp.max }}</span>
            </div>
            <div class="page-sheet__counter-controls">
              <button
                class="page-sheet__counter-btn page-sheet__counter-btn--mystic"
                :aria-label="t('labelDecrease') + ' ' + t('labelMp')"
                :disabled="localMpCurrent <= 0"
                @click="adjustMp(-1)"
              >
                −
              </button>
              <button
                class="page-sheet__counter-btn page-sheet__counter-btn--mystic"
                :aria-label="t('labelIncrease') + ' ' + t('labelMp')"
                :disabled="localMpCurrent >= character.mp.max"
                @click="adjustMp(1)"
              >
                +
              </button>
            </div>
          </div>

          <!-- ENC (read-only) -->
          <div class="page-sheet__counter page-sheet__counter--enc">
            <span class="page-sheet__counter-label">{{ t('labelEnc') }}</span>
            <div class="page-sheet__counter-value">
              {{ character.encumbrance.current
              }}<span class="page-sheet__counter-max"> / {{ character.encumbrance.max }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- ── Three-column body ───────────────────────────────────────────────── -->
      <div class="page-sheet__columns">
        <!-- LEFT column: Identity + Conditions placeholder -->
        <div class="page-sheet__col page-sheet__col--left">
          <!-- Identity card -->
          <AppCard class="page-sheet__panel">
            <template #header>
              <span class="page-sheet__panel-title">{{ t('panelIdentity') }}</span>
            </template>
            <div class="page-sheet__identity-rows">
              <div class="page-sheet__identity-row">
                <span class="page-sheet__identity-key">{{ t('identityConcept') }}</span>
                <span class="page-sheet__identity-val">{{ character.concept || '—' }}</span>
              </div>
            </div>
          </AppCard>

          <!-- Conditions placeholder -->
          <AppCard class="page-sheet__panel">
            <template #header>
              <span class="page-sheet__panel-title">{{ t('panelConditions') }}</span>
            </template>
            <p class="page-sheet__placeholder-text">
              {{ t('comingSoon') }}
            </p>
          </AppCard>
        </div>

        <!-- CENTER column: Attributes + Skills -->
        <div class="page-sheet__col page-sheet__col--center">
          <!-- Attributes panel -->
          <AppCard class="page-sheet__panel">
            <template #header>
              <span class="page-sheet__panel-title page-sheet__panel-title--lg">{{
                t('panelAttributes')
              }}</span>
            </template>
            <div class="page-sheet__attrs">
              <AppPopover
                v-for="key in ATTR_KEYS"
                :key="key"
                :open="attrPopoverOpen(key)"
                placement="bottom"
                :aria-label="attrLabel(key)"
                @update:open="
                  (v) => {
                    if (!v) closeAttrPopover();
                  }
                "
              >
                <template #trigger>
                  <AppStatBlock
                    :label="attrLabel(key)"
                    :value="localAttributes[key]"
                    :max="5"
                    size="md"
                    tone="brass"
                    :aria-label="attrLabel(key) + ': ' + String(localAttributes[key])"
                    @select="openAttrPopover(key)"
                  />
                </template>
                <!-- Stepper popover -->
                <div class="page-sheet__stepper">
                  <span class="page-sheet__stepper-label">{{ attrLabel(key) }}</span>
                  <div class="page-sheet__stepper-row">
                    <button
                      class="page-sheet__stepper-btn"
                      :aria-label="t('labelDecrease')"
                      :disabled="stepperValue <= 1"
                      @click="stepperValue = Math.max(1, stepperValue - 1)"
                    >
                      −
                    </button>
                    <span class="page-sheet__stepper-val">{{ stepperValue }}</span>
                    <button
                      class="page-sheet__stepper-btn"
                      :aria-label="t('labelIncrease')"
                      :disabled="stepperValue >= 5"
                      @click="stepperValue = Math.min(5, stepperValue + 1)"
                    >
                      +
                    </button>
                  </div>
                  <AppDots
                    :value="stepperValue"
                    :max="5"
                    size="md"
                    tone="brass"
                    :label="attrLabel(key)"
                  />
                  <div class="page-sheet__stepper-actions">
                    <AppButton variant="ghost" size="sm" @click="closeAttrPopover">
                      {{ t('popoverClose') }}
                    </AppButton>
                    <AppButton variant="primary" size="sm" @click="commitAttr(key, stepperValue)">
                      {{ t('statusSaved') }}
                    </AppButton>
                  </div>
                </div>
              </AppPopover>
            </div>
          </AppCard>

          <!-- Skills panel -->
          <AppCard class="page-sheet__panel">
            <template #header>
              <div class="page-sheet__skills-header">
                <span class="page-sheet__panel-title page-sheet__panel-title--lg">{{
                  t('panelSkills')
                }}</span>
                <div class="page-sheet__skills-legend">
                  <span
                    class="page-sheet__skills-legend-item page-sheet__skills-legend-item--general"
                  >
                    <span class="page-sheet__legend-dot" />{{ t('skillsGeneral') }}
                  </span>
                  <span
                    class="page-sheet__skills-legend-item page-sheet__skills-legend-item--advanced"
                  >
                    <span class="page-sheet__legend-star">✦</span>{{ t('skillsAdvanced') }}
                  </span>
                </div>
              </div>
            </template>
            <div class="page-sheet__skills-grid">
              <!-- General column -->
              <div class="page-sheet__skills-col">
                <div class="page-sheet__skills-col-heading">
                  {{ t('skillsGeneral') }}
                </div>
                <AppDivider tone="brass-deep" />
                <template v-for="sk in GENERAL_SKILLS" :key="sk">
                  <AppPopover
                    :open="skillPopoverOpen(sk)"
                    placement="bottom"
                    :aria-label="skillLabel(sk)"
                    @update:open="
                      (v) => {
                        if (!v) closeSkillPopover();
                      }
                    "
                  >
                    <template #trigger>
                      <button
                        class="page-sheet__skill-row"
                        :aria-label="skillLabel(sk) + ': ' + String(localSkills[sk])"
                        @click="openSkillPopover(sk)"
                      >
                        <span class="page-sheet__skill-name">{{ skillLabel(sk) }}</span>
                        <span class="page-sheet__skill-attr">{{ SKILL_GOVERNING_ATTR[sk] }}</span>
                        <AppDots
                          :value="localSkills[sk]"
                          :max="5"
                          size="sm"
                          tone="brass"
                          :label="skillLabel(sk)"
                        />
                      </button>
                    </template>
                    <!-- Skill stepper -->
                    <div class="page-sheet__stepper">
                      <span class="page-sheet__stepper-label">{{ skillLabel(sk) }}</span>
                      <div class="page-sheet__stepper-row">
                        <button
                          class="page-sheet__stepper-btn"
                          :aria-label="t('labelDecrease')"
                          :disabled="stepperValue <= 0"
                          @click="stepperValue = Math.max(0, stepperValue - 1)"
                        >
                          −
                        </button>
                        <span class="page-sheet__stepper-val">{{ stepperValue }}</span>
                        <button
                          class="page-sheet__stepper-btn"
                          :aria-label="t('labelIncrease')"
                          :disabled="stepperValue >= 5"
                          @click="stepperValue = Math.min(5, stepperValue + 1)"
                        >
                          +
                        </button>
                      </div>
                      <AppDots
                        :value="stepperValue"
                        :max="5"
                        size="md"
                        tone="brass"
                        :label="skillLabel(sk)"
                      />
                      <div class="page-sheet__stepper-actions">
                        <AppButton variant="ghost" size="sm" @click="closeSkillPopover">
                          {{ t('popoverClose') }}
                        </AppButton>
                        <AppButton
                          variant="primary"
                          size="sm"
                          @click="commitSkill(sk, stepperValue)"
                        >
                          {{ t('statusSaved') }}
                        </AppButton>
                      </div>
                    </div>
                  </AppPopover>
                </template>
              </div>

              <!-- Advanced column -->
              <div class="page-sheet__skills-col page-sheet__skills-col--advanced">
                <div
                  class="page-sheet__skills-col-heading page-sheet__skills-col-heading--advanced"
                >
                  <span class="page-sheet__legend-star">✦</span>
                  {{ t('skillsAdvanced') }}
                  <span class="page-sheet__skills-advanced-note">{{
                    t('skillsAdvancedNote')
                  }}</span>
                </div>
                <AppDivider tone="brass" />
                <template v-for="sk in ADVANCED_SKILLS" :key="sk">
                  <AppPopover
                    :open="skillPopoverOpen(sk)"
                    placement="bottom"
                    :aria-label="skillLabel(sk)"
                    @update:open="
                      (v) => {
                        if (!v) closeSkillPopover();
                      }
                    "
                  >
                    <template #trigger>
                      <button
                        class="page-sheet__skill-row page-sheet__skill-row--advanced"
                        :aria-label="skillLabel(sk) + ': ' + String(localSkills[sk])"
                        @click="openSkillPopover(sk)"
                      >
                        <span
                          class="page-sheet__skill-accent-rail"
                          :class="
                            localSkills[sk] > 0 ? 'page-sheet__skill-accent-rail--active' : ''
                          "
                          aria-hidden="true"
                        />
                        <span class="page-sheet__skill-name">{{ skillLabel(sk) }}</span>
                        <span class="page-sheet__skill-attr page-sheet__skill-attr--advanced">{{
                          SKILL_GOVERNING_ATTR[sk]
                        }}</span>
                        <AppDots
                          :value="localSkills[sk]"
                          :max="5"
                          size="sm"
                          tone="mystic"
                          :label="skillLabel(sk)"
                        />
                      </button>
                    </template>
                    <!-- Advanced skill stepper -->
                    <div class="page-sheet__stepper page-sheet__stepper--mystic">
                      <span class="page-sheet__stepper-label page-sheet__stepper-label--mystic">{{
                        skillLabel(sk)
                      }}</span>
                      <div class="page-sheet__stepper-row">
                        <button
                          class="page-sheet__stepper-btn page-sheet__stepper-btn--mystic"
                          :aria-label="t('labelDecrease')"
                          :disabled="stepperValue <= 0"
                          @click="stepperValue = Math.max(0, stepperValue - 1)"
                        >
                          −
                        </button>
                        <span class="page-sheet__stepper-val">{{ stepperValue }}</span>
                        <button
                          class="page-sheet__stepper-btn page-sheet__stepper-btn--mystic"
                          :aria-label="t('labelIncrease')"
                          :disabled="stepperValue >= 5"
                          @click="stepperValue = Math.min(5, stepperValue + 1)"
                        >
                          +
                        </button>
                      </div>
                      <AppDots
                        :value="stepperValue"
                        :max="5"
                        size="md"
                        tone="mystic"
                        :label="skillLabel(sk)"
                      />
                      <div class="page-sheet__stepper-actions">
                        <AppButton variant="ghost" size="sm" @click="closeSkillPopover">
                          {{ t('popoverClose') }}
                        </AppButton>
                        <AppButton
                          variant="primary"
                          size="sm"
                          @click="commitSkill(sk, stepperValue)"
                        >
                          {{ t('statusSaved') }}
                        </AppButton>
                      </div>
                    </div>
                  </AppPopover>
                </template>
              </div>
            </div>
          </AppCard>
        </div>

        <!-- RIGHT column: placeholder cards -->
        <div class="page-sheet__col page-sheet__col--right">
          <AppCard class="page-sheet__panel">
            <template #header>
              <span class="page-sheet__panel-title">{{ t('panelEquipped') }}</span>
            </template>
            <p class="page-sheet__placeholder-text">
              {{ t('comingSoon') }}
            </p>
          </AppCard>

          <AppCard class="page-sheet__panel">
            <template #header>
              <span class="page-sheet__panel-title">{{ t('panelTalents') }}</span>
            </template>
            <p class="page-sheet__placeholder-text">
              {{ t('comingSoon') }}
            </p>
          </AppCard>

          <AppCard class="page-sheet__panel">
            <template #header>
              <span class="page-sheet__panel-title">{{ t('panelRolls') }}</span>
            </template>
            <p class="page-sheet__placeholder-text">
              {{ t('comingSoon') }}
            </p>
          </AppCard>
        </div>
      </div>

      <!-- ── Danger zone ─────────────────────────────────────────────────────── -->
      <div class="page-sheet__danger-zone">
        <AppButton variant="danger" size="sm" @click="openDeleteDialog">
          {{ t('deleteButton') }}
        </AppButton>
      </div>
    </template>

    <!-- ── Delete confirmation dialog ─────────────────────────────────────────── -->
    <dialog
      :open="deleteDialogOpen"
      class="page-sheet__dialog"
      :aria-label="t('deleteConfirmHeading')"
      @close="closeDeleteDialog"
    >
      <div class="page-sheet__dialog-inner">
        <p class="page-sheet__dialog-heading">
          {{ t('deleteConfirmHeading') }}
        </p>
        <p class="page-sheet__dialog-body">
          {{ t('deleteConfirmBody') }}
        </p>
        <div class="page-sheet__dialog-actions">
          <AppButton variant="ghost" size="md" :disabled="deleteLoading" @click="closeDeleteDialog">
            {{ t('deleteConfirmNo') }}
          </AppButton>
          <AppButton variant="danger" size="md" :loading="deleteLoading" @click="confirmDelete">
            {{ t('deleteConfirmYes') }}
          </AppButton>
        </div>
      </div>
    </dialog>
  </section>
</template>

<style lang="scss" scoped>
  // ── Layout constants ──────────────────────────────────────────────────────────
  // Named SCSS variables for pixel layout caps (not design tokens).
  $column-gap: 24px;
  $hero-padding-v: 32px;
  $hero-padding-h: 40px;
  $portrait-size: 80px;
  $portrait-size-mobile: 48px;
  $skeleton-hero-height: 140px;
  $skeleton-body-height: 400px;
  $skeleton-stagger: 200ms;
  $dialog-max-width: 400px;
  $stepper-btn-size: 32px;
  $counter-min-width: 90px;
  $stepper-min-width: 160px;
  $panel-min-width-tablet: 200px;
  $col-left-pct: 28%;
  $col-center-pct: 44%;
  $col-right-pct: 28%;
  // Typography — named vars for sub-token font sizes (eyebrow, legend, micro).
  $font-size-eyebrow: 11px;
  $font-size-legend: 10px;
  $font-size-micro: 9px;
  // Icon/rail sizes — layout constants.
  $legend-dot-size: 8px;
  $accent-rail-offset: 6px;
  // Breakpoints
  $bp-desktop: 1024px;
  $bp-mobile: 768px;

  // ── Root ──────────────────────────────────────────────────────────────────────

  .page-sheet {
    display: flex;
    flex-direction: column;
    gap: var(--space-6);

    // ── Loading skeletons ─────────────────────────────────────────────────────

    &__loading {
      display: flex;
      flex-direction: column;
      gap: var(--space-5);
    }

    &__skeleton-hero {
      height: $skeleton-hero-height;
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      opacity: var(--opacity-disabled);
      animation: sheet-pulse var(--motion-duration-ceremony) ease-in-out infinite alternate;
    }

    &__skeleton-body {
      height: $skeleton-body-height;
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      opacity: var(--opacity-disabled);
      animation: sheet-pulse var(--motion-duration-ceremony) ease-in-out infinite alternate;
      animation-delay: $skeleton-stagger;
    }

    // ── Not found ─────────────────────────────────────────────────────────────

    &__not-found {
      display: flex;
      justify-content: center;
      padding: var(--space-9) 0;
    }

    &__not-found-inner {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-4);
      text-align: center;
    }

    &__not-found-heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      color: var(--brand-brass-light);
    }

    &__not-found-body {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    // ── Error ─────────────────────────────────────────────────────────────────

    &__error {
      padding: var(--space-6) 0;
    }

    &__error-text {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--state-crimson-bright);
    }

    // ── Hero plate ────────────────────────────────────────────────────────────

    &__hero {
      display: grid;
      grid-template-columns: $portrait-size 1fr auto;
      gap: var(--space-6);
      align-items: center;
      padding: $hero-padding-v $hero-padding-h;
      background: linear-gradient(180deg, var(--surface-night) 0%, var(--surface-void) 100%);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);

      @media (max-width: #{$bp-mobile - 1px}) {
        grid-template-columns: $portrait-size-mobile 1fr;
        grid-template-rows: auto auto;
        padding: var(--space-4) var(--space-5);
      }
    }

    &__portrait {
      width: $portrait-size;
      height: $portrait-size;
      border-radius: var(--radius-pill);
      background-color: var(--brand-brass-deep);
      color: var(--text-on-brass);
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      font-weight: 600;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;

      @media (max-width: #{$bp-mobile - 1px}) {
        width: $portrait-size-mobile;
        height: $portrait-size-mobile;
        font-size: var(--type-body-md-font-size);
      }
    }

    &__identity {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
      min-width: 0;
    }

    &__concept-label {
      font-family: var(--font-body);
      font-size: $font-size-eyebrow;
      color: var(--brand-brass);
      letter-spacing: 0.18em;
      text-transform: uppercase;
    }

    &__name-input {
      font-family: var(--font-display);
    }

    &__concept-input {
      font-family: var(--font-body);
    }

    &__save-status {
      min-height: var(--space-5);
    }

    &__save-label {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      letter-spacing: 0.04em;

      &--saving {
        color: var(--text-secondary);
      }

      &--saved {
        color: var(--state-success);
      }

      &--error {
        color: var(--state-crimson-bright);
      }
    }

    // ── HP / MP / ENC counters ─────────────────────────────────────────────────

    &__counters {
      display: flex;
      gap: var(--space-6);
      align-items: center;

      @media (max-width: #{$bp-mobile - 1px}) {
        grid-column: 1 / -1;
        justify-content: flex-start;
        gap: var(--space-4);
        flex-wrap: wrap;
      }
    }

    &__counter {
      display: flex;
      flex-direction: column;
      align-items: center;
      min-width: $counter-min-width;
      gap: var(--space-1);
    }

    &__counter-label {
      font-family: var(--font-body);
      font-size: $font-size-eyebrow;
      letter-spacing: 0.18em;
      text-transform: uppercase;
      color: var(--brand-brass);

      .page-sheet__counter--mystic & {
        color: var(--state-mystic-teal);
      }

      .page-sheet__counter--enc & {
        color: var(--text-secondary);
      }
    }

    &__counter-value {
      font-family: var(--type-mono-stat-md-font-family);
      font-size: var(--type-mono-stat-md-font-size);
      font-weight: 700;
      color: var(--text-primary);
      line-height: 1;
    }

    &__counter-max {
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
      font-weight: 400;
    }

    &__counter-controls {
      display: flex;
      gap: var(--space-2);
    }

    &__counter-btn {
      width: $stepper-btn-size;
      height: $stepper-btn-size;
      border: 1px solid var(--brand-brass-deep);
      background: transparent;
      color: var(--brand-brass);
      border-radius: var(--radius-sm);
      cursor: pointer;
      font-size: var(--type-body-md-font-size);
      line-height: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover:not([disabled]) {
        background-color: color-mix(in srgb, var(--brand-brass) 10%, transparent);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      &[disabled] {
        opacity: var(--opacity-disabled);
        cursor: not-allowed;
      }

      &--mystic {
        border-color: color-mix(in srgb, var(--state-mystic-teal) 50%, transparent);
        color: var(--state-mystic-teal);

        &:hover:not([disabled]) {
          background-color: color-mix(in srgb, var(--state-mystic-teal) 10%, transparent);
        }
      }
    }

    // ── Three-column layout ───────────────────────────────────────────────────

    &__columns {
      display: grid;
      grid-template-columns: $col-left-pct $col-center-pct $col-right-pct;
      gap: $column-gap;

      @media (max-width: #{$bp-desktop - 1px}) {
        grid-template-columns: 1fr 1fr;
      }

      @media (max-width: #{$bp-mobile - 1px}) {
        grid-template-columns: 1fr;
      }
    }

    &__col {
      display: flex;
      flex-direction: column;
      gap: var(--space-5);

      // Mobile: force order — identity → attributes → skills → conditions → right
      @media (max-width: #{$bp-mobile - 1px}) {
        &--left {
          order: 1;
        }

        &--center {
          order: 2;
        }

        &--right {
          order: 3;
        }
      }
    }

    // On tablet (≥768 <1024), right column spans full width below the two.
    // Extracted from &__col nesting to stay within max-nesting-depth: 3.
    @media (max-width: #{$bp-desktop - 1px}) and (min-width: $bp-mobile) {
      &__col--right {
        grid-column: 1 / -1;
        flex-direction: row;
        flex-wrap: wrap;
      }

      &__panel {
        flex: 1;
        min-width: $panel-min-width-tablet;
      }
    }

    // ── Panel titles ──────────────────────────────────────────────────────────

    &__panel-title {
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      color: var(--brand-brass-light);
      letter-spacing: 0.08em;
      text-transform: uppercase;

      &--lg {
        font-size: var(--type-display-sm-font-size);
      }
    }

    // ── Identity rows ─────────────────────────────────────────────────────────

    &__identity-rows {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__identity-row {
      display: flex;
      justify-content: space-between;
      align-items: baseline;
      gap: var(--space-3);
      font-size: var(--type-body-sm-font-size);
    }

    &__identity-key {
      font-family: var(--font-body);
      font-size: $font-size-eyebrow;
      letter-spacing: 0.12em;
      text-transform: uppercase;
      color: var(--brand-brass);
      flex-shrink: 0;
    }

    &__identity-val {
      font-family: var(--font-body);
      color: var(--text-primary);
      text-align: right;
    }

    // ── Placeholder text (coming soon) ────────────────────────────────────────

    &__placeholder-text {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      text-align: center;
      padding: var(--space-6) 0;
    }

    // ── Attributes grid ───────────────────────────────────────────────────────

    &__attrs {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: var(--space-3);

      @media (max-width: #{$bp-mobile - 1px}) {
        gap: var(--space-2);
      }
    }

    // ── Skills ────────────────────────────────────────────────────────────────

    &__skills-header {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      gap: var(--space-4);
      flex-wrap: wrap;
    }

    &__skills-legend {
      display: flex;
      gap: var(--space-4);
      font-family: var(--font-body);
      font-size: $font-size-legend;
      letter-spacing: 0.14em;
      text-transform: uppercase;
    }

    &__skills-legend-item {
      display: inline-flex;
      align-items: center;
      gap: var(--space-1);

      &--general {
        color: var(--text-secondary);
      }

      &--advanced {
        color: var(--state-mystic-teal);
      }
    }

    &__legend-dot {
      display: inline-block;
      width: $legend-dot-size;
      height: $legend-dot-size;
      border-radius: var(--radius-pill);
      background-color: var(--brand-brass);
    }

    &__legend-star {
      font-size: $font-size-legend;
      color: var(--state-mystic-teal);
    }

    &__skills-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: var(--space-6);

      @media (max-width: #{$bp-mobile - 1px}) {
        grid-template-columns: 1fr;
        gap: var(--space-4);
      }
    }

    &__skills-col {
      display: flex;
      flex-direction: column;
      gap: 0;

      &--advanced {
        position: relative;
      }
    }

    &__skills-col-heading {
      font-family: var(--font-display);
      font-size: $font-size-eyebrow;
      letter-spacing: 0.2em;
      text-transform: uppercase;
      color: var(--brand-brass);
      padding-bottom: var(--space-2);
      margin-bottom: var(--space-2);

      &--advanced {
        color: var(--state-mystic-teal);
        display: flex;
        align-items: center;
        gap: var(--space-2);
      }
    }

    &__skills-advanced-note {
      margin-left: auto;
      font-size: $font-size-micro;
      opacity: 0.7;
      letter-spacing: 0.12em;
    }

    // ── Skill row ─────────────────────────────────────────────────────────────

    &__skill-row {
      display: grid;
      grid-template-columns: 1fr auto auto;
      align-items: center;
      gap: var(--space-2);
      padding: var(--space-2) var(--space-1);
      border-bottom: 1px solid color-mix(in srgb, var(--brand-brass-deep) 60%, transparent);
      background: transparent;
      border-left: none;
      border-right: none;
      border-top: none;
      cursor: pointer;
      width: 100%;
      text-align: left;
      transition: background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        background-color: color-mix(in srgb, var(--brand-brass) 5%, transparent);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      &--advanced {
        position: relative;
        padding-left: var(--space-4);
      }
    }

    &__skill-accent-rail {
      position: absolute;
      left: 0;
      top: $accent-rail-offset;
      bottom: $accent-rail-offset;
      width: 2px;
      border-radius: var(--radius-pill);
      background-color: color-mix(in srgb, var(--state-mystic-teal) 30%, transparent);

      &--active {
        background-color: var(--state-mystic-teal);
      }
    }

    &__skill-name {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    &__skill-attr {
      font-family: var(--font-body);
      font-size: $font-size-micro;
      letter-spacing: 0.14em;
      text-transform: uppercase;
      color: var(--brand-brass);
      flex-shrink: 0;

      &--advanced {
        color: var(--state-mystic-teal);
      }
    }

    // ── Stepper popover content ───────────────────────────────────────────────

    &__stepper {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-3);
      min-width: $stepper-min-width;

      &--mystic {
        // teal-tinted popover background hint
        background: color-mix(in srgb, var(--state-mystic-teal) 4%, var(--surface-night));
      }
    }

    &__stepper-label {
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      letter-spacing: 0.08em;
      text-transform: uppercase;
      color: var(--brand-brass-light);

      &--mystic {
        color: var(--state-mystic-teal);
      }
    }

    &__stepper-row {
      display: flex;
      align-items: center;
      gap: var(--space-4);
    }

    &__stepper-val {
      font-family: var(--type-mono-stat-md-font-family);
      font-size: var(--type-mono-stat-md-font-size);
      font-weight: 700;
      color: var(--text-primary);
      min-width: var(--space-6);
      text-align: center;
    }

    &__stepper-btn {
      width: $stepper-btn-size;
      height: $stepper-btn-size;
      border: 1px solid var(--brand-brass-deep);
      background: transparent;
      color: var(--brand-brass);
      border-radius: var(--radius-sm);
      cursor: pointer;
      font-size: var(--type-body-md-font-size);
      line-height: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover:not([disabled]) {
        background-color: color-mix(in srgb, var(--brand-brass) 10%, transparent);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }

      &[disabled] {
        opacity: var(--opacity-disabled);
        cursor: not-allowed;
      }

      &--mystic {
        border-color: color-mix(in srgb, var(--state-mystic-teal) 50%, transparent);
        color: var(--state-mystic-teal);

        &:hover:not([disabled]) {
          background-color: color-mix(in srgb, var(--state-mystic-teal) 10%, transparent);
        }
      }
    }

    &__stepper-actions {
      display: flex;
      gap: var(--space-2);
      width: 100%;
      justify-content: flex-end;
    }

    // ── Danger zone ───────────────────────────────────────────────────────────

    &__danger-zone {
      display: flex;
      justify-content: flex-end;
      padding-top: var(--space-4);
      border-top: 1px solid var(--brand-brass-shadow);
    }

    // ── Delete dialog ─────────────────────────────────────────────────────────

    &__dialog {
      position: fixed;
      inset: 0;
      margin: auto;
      padding: 0;
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      color: var(--text-primary);
      max-width: $dialog-max-width;
      width: calc(100% - var(--space-8));

      &::backdrop {
        background-color: color-mix(in srgb, var(--surface-void) 80%, transparent);
      }

      &:not([open]) {
        display: none;
      }
    }

    &__dialog-inner {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
      padding: var(--space-6);
    }

    &__dialog-heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      line-height: var(--type-display-sm-line-height);
      color: var(--brand-brass-light);
    }

    &__dialog-body {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
    }

    &__dialog-actions {
      display: flex;
      justify-content: flex-end;
      gap: var(--space-3);
    }
  }

  // ── Animations ────────────────────────────────────────────────────────────────

  @keyframes sheet-pulse {
    from {
      opacity: var(--opacity-disabled);
    }

    to {
      opacity: 0.18;
    }
  }

  // ── Reduced motion ─────────────────────────────────────────────────────────────

  @media (prefers-reduced-motion: reduce) {
    .page-sheet__skeleton-hero,
    .page-sheet__skeleton-body {
      animation: none;
    }
  }
</style>
