<script setup lang="ts">
  definePageMeta({ layout: 'app' });

  import {
    AppCard,
    AppBadge,
    AppButton,
    AppBanner,
    AppField,
    AppInput,
    AppTextarea,
    AppSavePulse,
    AppModal,
  } from '@app/ui';
  import { ref, computed, onMounted, onBeforeUnmount } from 'vue';
  import { useRoute } from 'vue-router';
  import { useNpcsApi } from '~/composables/useNpcsApi';
  import type { Npc, NpcUpdate } from '~/composables/useNpcsApi';
  import type { Problem, Attributes, Skills } from '@app/api-client-ts';
  import { useAutoSave } from '~/composables/useAutoSave';
  import type { SaveState } from '~/composables/useAutoSave';

  /**
   * NPC sheet — Block 2 of T-2026-05-10-008.
   *
   * Header: inline name + AppSavePulse + Duplicate + Delete (with confirm modal).
   * Body: stat block (attributes, skills, hp, mp, signature, keySkillModifier),
   *        equipment (armor/weapons arrays, tag chips), description textarea.
   * Problems card: surfaces server 422 validation errors with retry affordance.
   * All fields use useAutoSave with 600 ms debounce on blur.
   */

  const { t } = useI18n({ useScope: 'local' });
  const route = useRoute();
  const npcsApi = useNpcsApi();

  const npcId = computed<string>(() => route.params.id as string);

  // ── Load state ───────────────────────────────────────────────────────────────

  type LoadState = 'loading' | 'loaded' | 'error' | 'notfound';

  const state = ref<LoadState>('loading');
  const npc = ref<Npc | null>(null);
  const errorMsg = ref('');

  // ── Server validation problems (422) ─────────────────────────────────────────

  const validationProblems = ref<string[]>([]);

  function recordValidationError(error: unknown): void {
    const problem = error as Problem;
    if (problem.status === 422) {
      const detail = problem.detail ?? t('validationErrorFallback');
      validationProblems.value = [...new Set([...validationProblems.value, detail])];
    }
  }

  function clearValidationProblems(): void {
    validationProblems.value = [];
  }

  // ── Editable local copies ────────────────────────────────────────────────────

  const localName = ref('');
  const localDescription = ref<string | null>(null);

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

  const localHpCurrent = ref(4);
  const localHpMax = ref(4);
  const localMpCurrent = ref(4);
  const localMpMax = ref(4);
  const localSignature = ref(0);
  const localKeySkillModifier = ref(0);

  // Tags are edited as a comma-separated input and split on blur
  const localTagsInput = ref('');
  // Armor/weapons displayed as read-only counts (editing full arrays is out of scope for this block)
  const armorCount = ref(0);
  const weaponsCount = ref(0);

  function syncLocals(n: Npc): void {
    localName.value = n.name;
    localDescription.value = n.description ?? null;
    localAttributes.value = { ...n.attributes };
    localSkills.value = { ...n.skills };
    localHpCurrent.value = n.hp.current;
    localHpMax.value = n.hp.max;
    localMpCurrent.value = n.mp.current;
    localMpMax.value = n.mp.max;
    localSignature.value = n.signature;
    localKeySkillModifier.value = n.keySkillModifier ?? 0;
    localTagsInput.value = n.tags.join(', ');
    armorCount.value = n.armor.length;
    weaponsCount.value = n.weapons.length;
  }

  // ── Auto-save plumbing ───────────────────────────────────────────────────────

  async function persistIdentity(): Promise<void> {
    const trimmed = localName.value.trim();
    if (!trimmed) return;
    const patch: NpcUpdate = { name: trimmed };
    const updated = await npcsApi.update(npcId.value, patch);
    if (npc.value) npc.value = { ...npc.value, ...updated };
    clearValidationProblems();
  }

  async function persistDescription(): Promise<void> {
    const patch: NpcUpdate = { description: localDescription.value };
    const updated = await npcsApi.update(npcId.value, patch);
    if (npc.value) npc.value = { ...npc.value, ...updated };
    clearValidationProblems();
  }

  async function persistStats(): Promise<void> {
    const patch: NpcUpdate = {
      attributes: { ...localAttributes.value },
      skills: { ...localSkills.value },
      hp: { current: localHpCurrent.value, max: localHpMax.value },
      mp: { current: localMpCurrent.value, max: localMpMax.value },
      signature: localSignature.value,
      keySkillModifier: localKeySkillModifier.value,
    };
    const updated = await npcsApi.update(npcId.value, patch);
    if (npc.value) npc.value = { ...npc.value, ...updated };
    clearValidationProblems();
  }

  async function persistTags(): Promise<void> {
    const tags = localTagsInput.value
      .split(',')
      .map((s) => s.trim())
      .filter((s) => s.length > 0);
    const patch: NpcUpdate = { tags };
    const updated = await npcsApi.update(npcId.value, patch);
    if (npc.value) npc.value = { ...npc.value, ...updated };
    clearValidationProblems();
  }

  const identitySave = useAutoSave(
    async () => {
      try {
        await persistIdentity();
      } catch (error) {
        recordValidationError(error);
        throw error;
      }
    },
    { debounceMs: 600 },
  );

  const descriptionSave = useAutoSave(
    async () => {
      try {
        await persistDescription();
      } catch (error) {
        recordValidationError(error);
        throw error;
      }
    },
    { debounceMs: 600 },
  );

  const statsSave = useAutoSave(
    async () => {
      try {
        await persistStats();
      } catch (error) {
        recordValidationError(error);
        throw error;
      }
    },
    { debounceMs: 600 },
  );

  const tagsSave = useAutoSave(
    async () => {
      try {
        await persistTags();
      } catch (error) {
        recordValidationError(error);
        throw error;
      }
    },
    { debounceMs: 600 },
  );

  // Combined save-state for the header indicator
  const headerSaveState = computed<SaveState>(() => {
    const all = new Set([
      identitySave.saveState.value,
      descriptionSave.saveState.value,
      statsSave.saveState.value,
      tagsSave.saveState.value,
    ]);
    if (all.has('saving')) return 'saving';
    if (all.has('error')) return 'error';
    if (all.has('saved')) return 'saved';
    return 'idle';
  });

  // ── Load ─────────────────────────────────────────────────────────────────────

  async function load(): Promise<void> {
    state.value = 'loading';
    errorMsg.value = '';
    validationProblems.value = [];
    try {
      const data = await npcsApi.get(npcId.value);
      npc.value = data;
      syncLocals(data);
      state.value = 'loaded';
    } catch (error) {
      const problem = error as Problem;
      if (problem.status === 404 || problem.status === 403) {
        state.value = 'notfound';
      } else {
        errorMsg.value = problem.detail ?? t('errorLoad');
        state.value = 'error';
      }
    }
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  const duplicating = ref(false);
  const duplicateError = ref('');

  async function onDuplicate(): Promise<void> {
    duplicating.value = true;
    duplicateError.value = '';
    try {
      const copy = await npcsApi.duplicate(npcId.value);
      const sourceName = npc.value?.name ?? '';
      await navigateTo(`/app/npcs/${copy.id}?duplicatedFrom=${encodeURIComponent(sourceName)}`);
    } catch (error) {
      const problem = error as Problem;
      duplicateError.value = problem.detail ?? t('errorDuplicate');
    } finally {
      duplicating.value = false;
    }
  }

  const deleting = ref(false);
  const deleteError = ref('');
  const deleteConfirmOpen = ref(false);

  function openDeleteConfirm(): void {
    deleteConfirmOpen.value = true;
  }

  function closeDeleteConfirm(): void {
    deleteConfirmOpen.value = false;
  }

  async function confirmDelete(): Promise<void> {
    deleting.value = true;
    deleteError.value = '';
    try {
      await npcsApi.delete(npcId.value);
      deleteConfirmOpen.value = false;
      await navigateTo('/app/npcs');
    } catch (error) {
      const problem = error as Problem;
      deleteError.value = problem.detail ?? t('errorDelete');
      deleteConfirmOpen.value = false;
    } finally {
      deleting.value = false;
    }
  }

  // ── Attribute helpers ─────────────────────────────────────────────────────────

  type AttrKey = 'strength' | 'agility' | 'wits' | 'empathy';
  type SkillKey = keyof Skills;

  const ATTR_KEYS: AttrKey[] = ['strength', 'agility', 'wits', 'empathy'];

  const GENERAL_SKILLS: SkillKey[] = [
    'force',
    'meleeCombat',
    'dexterity',
    'infiltration',
    'rangedCombat',
    'observation',
    'survival',
    'manipulation',
  ];

  const ADVANCED_SKILLS: SkillKey[] = [
    'command',
    'culture',
    'dataDjinn',
    'medicurgy',
    'mysticPowers',
    'pilot',
    'science',
    'technology',
  ];

  // ── Tags helpers ──────────────────────────────────────────────────────────────

  const displayTags = computed<string[]>(() => {
    return localTagsInput.value
      .split(',')
      .map((s) => s.trim())
      .filter((s) => s.length > 0);
  });

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  onMounted(() => {
    void load();
  });

  onBeforeUnmount(() => {
    identitySave.cancel();
    descriptionSave.cancel();
    statsSave.cancel();
    tagsSave.cancel();
  });
</script>

<i18n lang="json">
{
  "en": {
    "backToList": "Back to NPCs",
    "errorLoad": "Couldn't load NPC.",
    "errorDuplicate": "Couldn't duplicate NPC.",
    "errorDelete": "Couldn't delete NPC.",
    "retry": "Try again",
    "notfoundTitle": "NPC not found",
    "notfoundBody": "This NPC doesn't exist or you don't have access to it.",
    "duplicate": "Duplicate",
    "delete": "Delete",
    "deleteConfirmTitle": "Delete this NPC?",
    "deleteConfirmBody": "This will permanently delete the NPC. This cannot be undone.",
    "deleteConfirmYes": "Delete",
    "deleteConfirmNo": "Cancel",
    "identityCardTitle": "Identity",
    "fieldName": "Name",
    "statsCardTitle": "Stats",
    "sectionAttributes": "Attributes",
    "sectionSkillsGeneral": "General Skills",
    "sectionSkillsAdvanced": "Advanced Skills",
    "attrStrength": "Strength",
    "attrAgility": "Agility",
    "attrWits": "Wits",
    "attrEmpathy": "Empathy",
    "skillForce": "Force",
    "skillMeleeCombat": "Melee Combat",
    "skillDexterity": "Dexterity",
    "skillInfiltration": "Infiltration",
    "skillRangedCombat": "Ranged Combat",
    "skillObservation": "Observation",
    "skillSurvival": "Survival",
    "skillManipulation": "Manipulation",
    "skillCommand": "Command",
    "skillCulture": "Culture",
    "skillDataDjinn": "Data Djinn",
    "skillMedicurgy": "Medicurgy",
    "skillMysticPowers": "Mystic Powers",
    "skillPilot": "Pilot",
    "skillScience": "Science",
    "skillTechnology": "Technology",
    "statHpCurrent": "HP (current)",
    "statHpMax": "HP (max)",
    "statMpCurrent": "MP (current)",
    "statMpMax": "MP (max)",
    "statSignature": "Signature",
    "statKeySkillMod": "Key Skill Mod",
    "equipmentCardTitle": "Equipment",
    "armorLabel": "Armor items",
    "weaponsLabel": "Weapons",
    "armorNone": "None",
    "weaponsNone": "None",
    "tagsCardTitle": "Tags",
    "tagsLabel": "Tags",
    "tagsHelp": "Comma-separated labels for filtering (e.g. Pirate, Boss).",
    "tagsPlaceholder": "Pirate, Boss, Cyborg…",
    "descriptionCardTitle": "Description",
    "descriptionPlaceholder": "GM notes, behaviour, background…",
    "problemsCardTitle": "Validation issues",
    "problemsIntro": "The following validation errors were returned by the server:",
    "problemsRetry": "Dismiss",
    "validationErrorFallback": "The server rejected the last update (unspecified error)."
  },
  "ru": {
    "backToList": "К списку NPC",
    "errorLoad": "Не удалось загрузить NPC.",
    "errorDuplicate": "Не удалось дублировать NPC.",
    "errorDelete": "Не удалось удалить NPC.",
    "retry": "Попробовать снова",
    "notfoundTitle": "NPC не найден",
    "notfoundBody": "Этот NPC не существует или у вас нет к нему доступа.",
    "duplicate": "Дублировать",
    "delete": "Удалить",
    "deleteConfirmTitle": "Удалить этого NPC?",
    "deleteConfirmBody": "Это безвозвратно удалит NPC. Действие необратимо.",
    "deleteConfirmYes": "Удалить",
    "deleteConfirmNo": "Отмена",
    "identityCardTitle": "Имя",
    "fieldName": "Имя",
    "statsCardTitle": "Характеристики",
    "sectionAttributes": "Атрибуты",
    "sectionSkillsGeneral": "Основные навыки",
    "sectionSkillsAdvanced": "Специальные навыки",
    "attrStrength": "Сила",
    "attrAgility": "Ловкость",
    "attrWits": "Разум",
    "attrEmpathy": "Эмпатия",
    "skillForce": "Применение силы",
    "skillMeleeCombat": "Ближний бой",
    "skillDexterity": "Ловкость рук",
    "skillInfiltration": "Проникновение",
    "skillRangedCombat": "Стрельба",
    "skillObservation": "Наблюдение",
    "skillSurvival": "Выживание",
    "skillManipulation": "Манипуляция",
    "skillCommand": "Командование",
    "skillCulture": "Культура",
    "skillDataDjinn": "Цифровой джинн",
    "skillMedicurgy": "Медицина",
    "skillMysticPowers": "Мистические силы",
    "skillPilot": "Пилотирование",
    "skillScience": "Наука",
    "skillTechnology": "Технологии",
    "statHpCurrent": "ХП (текущие)",
    "statHpMax": "ХП (макс.)",
    "statMpCurrent": "ОМ (текущие)",
    "statMpMax": "ОМ (макс.)",
    "statSignature": "Заметность",
    "statKeySkillMod": "Модификатор навыка",
    "equipmentCardTitle": "Снаряжение",
    "armorLabel": "Броня",
    "weaponsLabel": "Оружие",
    "armorNone": "Нет",
    "weaponsNone": "Нет",
    "tagsCardTitle": "Теги",
    "tagsLabel": "Теги",
    "tagsHelp": "Список через запятую для фильтрации (напр. Пират, Босс).",
    "tagsPlaceholder": "Пират, Босс, Киборг…",
    "descriptionCardTitle": "Описание",
    "descriptionPlaceholder": "Заметки GM, поведение, предыстория…",
    "problemsCardTitle": "Ошибки валидации",
    "problemsIntro": "Сервер вернул следующие ошибки валидации:",
    "problemsRetry": "Закрыть",
    "validationErrorFallback": "Сервер отклонил последнее обновление (неизвестная ошибка)."
  },
  "uk": {
    "backToList": "[uk-todo] Back to NPCs",
    "errorLoad": "[uk-todo] Couldn't load NPC",
    "errorDuplicate": "[uk-todo] Couldn't duplicate NPC",
    "errorDelete": "[uk-todo] Couldn't delete NPC",
    "retry": "[uk-todo] Try again",
    "notfoundTitle": "[uk-todo] NPC not found",
    "notfoundBody": "[uk-todo] This NPC doesn't exist or you don't have access",
    "duplicate": "[uk-todo] Duplicate",
    "delete": "[uk-todo] Delete",
    "deleteConfirmTitle": "[uk-todo] Delete this NPC?",
    "deleteConfirmBody": "[uk-todo] This will permanently delete the NPC. This cannot be undone.",
    "deleteConfirmYes": "[uk-todo] Delete",
    "deleteConfirmNo": "[uk-todo] Cancel",
    "identityCardTitle": "[uk-todo] Identity",
    "fieldName": "[uk-todo] Name",
    "statsCardTitle": "[uk-todo] Stats",
    "sectionAttributes": "[uk-todo] Attributes",
    "sectionSkillsGeneral": "[uk-todo] General Skills",
    "sectionSkillsAdvanced": "[uk-todo] Advanced Skills",
    "attrStrength": "[uk-todo] Strength",
    "attrAgility": "[uk-todo] Agility",
    "attrWits": "[uk-todo] Wits",
    "attrEmpathy": "[uk-todo] Empathy",
    "skillForce": "[uk-todo] Force",
    "skillMeleeCombat": "[uk-todo] Melee Combat",
    "skillDexterity": "[uk-todo] Dexterity",
    "skillInfiltration": "[uk-todo] Infiltration",
    "skillRangedCombat": "[uk-todo] Ranged Combat",
    "skillObservation": "[uk-todo] Observation",
    "skillSurvival": "[uk-todo] Survival",
    "skillManipulation": "[uk-todo] Manipulation",
    "skillCommand": "[uk-todo] Command",
    "skillCulture": "[uk-todo] Culture",
    "skillDataDjinn": "[uk-todo] Data Djinn",
    "skillMedicurgy": "[uk-todo] Medicurgy",
    "skillMysticPowers": "[uk-todo] Mystic Powers",
    "skillPilot": "[uk-todo] Pilot",
    "skillScience": "[uk-todo] Science",
    "skillTechnology": "[uk-todo] Technology",
    "statHpCurrent": "[uk-todo] HP (current)",
    "statHpMax": "[uk-todo] HP (max)",
    "statMpCurrent": "[uk-todo] MP (current)",
    "statMpMax": "[uk-todo] MP (max)",
    "statSignature": "[uk-todo] Signature",
    "statKeySkillMod": "[uk-todo] Key Skill Mod",
    "equipmentCardTitle": "[uk-todo] Equipment",
    "armorLabel": "[uk-todo] Armor items",
    "weaponsLabel": "[uk-todo] Weapons",
    "armorNone": "[uk-todo] None",
    "weaponsNone": "[uk-todo] None",
    "tagsCardTitle": "[uk-todo] Tags",
    "tagsLabel": "[uk-todo] Tags",
    "tagsHelp": "[uk-todo] Comma-separated labels for filtering.",
    "tagsPlaceholder": "[uk-todo] Pirate, Boss…",
    "descriptionCardTitle": "[uk-todo] Description",
    "descriptionPlaceholder": "[uk-todo] GM notes, behaviour, background…",
    "problemsCardTitle": "[uk-todo] Validation issues",
    "problemsIntro": "[uk-todo] The following validation errors were returned by the server:",
    "problemsRetry": "[uk-todo] Dismiss",
    "validationErrorFallback": "[uk-todo] The server rejected the last update."
  },
  "el": {
    "backToList": "[el-todo] Back to NPCs",
    "errorLoad": "[el-todo] Couldn't load NPC",
    "errorDuplicate": "[el-todo] Couldn't duplicate NPC",
    "errorDelete": "[el-todo] Couldn't delete NPC",
    "retry": "[el-todo] Try again",
    "notfoundTitle": "[el-todo] NPC not found",
    "notfoundBody": "[el-todo] This NPC doesn't exist or you don't have access",
    "duplicate": "[el-todo] Duplicate",
    "delete": "[el-todo] Delete",
    "deleteConfirmTitle": "[el-todo] Delete this NPC?",
    "deleteConfirmBody": "[el-todo] This will permanently delete the NPC. This cannot be undone.",
    "deleteConfirmYes": "[el-todo] Delete",
    "deleteConfirmNo": "[el-todo] Cancel",
    "identityCardTitle": "[el-todo] Identity",
    "fieldName": "[el-todo] Name",
    "statsCardTitle": "[el-todo] Stats",
    "sectionAttributes": "[el-todo] Attributes",
    "sectionSkillsGeneral": "[el-todo] General Skills",
    "sectionSkillsAdvanced": "[el-todo] Advanced Skills",
    "attrStrength": "[el-todo] Strength",
    "attrAgility": "[el-todo] Agility",
    "attrWits": "[el-todo] Wits",
    "attrEmpathy": "[el-todo] Empathy",
    "skillForce": "[el-todo] Force",
    "skillMeleeCombat": "[el-todo] Melee Combat",
    "skillDexterity": "[el-todo] Dexterity",
    "skillInfiltration": "[el-todo] Infiltration",
    "skillRangedCombat": "[el-todo] Ranged Combat",
    "skillObservation": "[el-todo] Observation",
    "skillSurvival": "[el-todo] Survival",
    "skillManipulation": "[el-todo] Manipulation",
    "skillCommand": "[el-todo] Command",
    "skillCulture": "[el-todo] Culture",
    "skillDataDjinn": "[el-todo] Data Djinn",
    "skillMedicurgy": "[el-todo] Medicurgy",
    "skillMysticPowers": "[el-todo] Mystic Powers",
    "skillPilot": "[el-todo] Pilot",
    "skillScience": "[el-todo] Science",
    "skillTechnology": "[el-todo] Technology",
    "statHpCurrent": "[el-todo] HP (current)",
    "statHpMax": "[el-todo] HP (max)",
    "statMpCurrent": "[el-todo] MP (current)",
    "statMpMax": "[el-todo] MP (max)",
    "statSignature": "[el-todo] Signature",
    "statKeySkillMod": "[el-todo] Key Skill Mod",
    "equipmentCardTitle": "[el-todo] Equipment",
    "armorLabel": "[el-todo] Armor items",
    "weaponsLabel": "[el-todo] Weapons",
    "armorNone": "[el-todo] None",
    "weaponsNone": "[el-todo] None",
    "tagsCardTitle": "[el-todo] Tags",
    "tagsLabel": "[el-todo] Tags",
    "tagsHelp": "[el-todo] Comma-separated labels for filtering.",
    "tagsPlaceholder": "[el-todo] Pirate, Boss…",
    "descriptionCardTitle": "[el-todo] Description",
    "descriptionPlaceholder": "[el-todo] GM notes, behaviour, background…",
    "problemsCardTitle": "[el-todo] Validation issues",
    "problemsIntro": "[el-todo] The following validation errors were returned by the server:",
    "problemsRetry": "[el-todo] Dismiss",
    "validationErrorFallback": "[el-todo] The server rejected the last update."
  }
}
</i18n>

<template>
  <section class="page-npc" data-testid="page-npc">
    <!-- ── Back nav ──────────────────────────────────────────────────────────── -->
    <AppButton variant="ghost" size="sm" class="page-npc__back" @click="navigateTo('/app/npcs')">
      ← {{ t('backToList') }}
    </AppButton>

    <!-- ── Error banners ──────────────────────────────────────────────────────── -->
    <AppBanner v-if="state === 'error'" tone="danger" role="alert" class="page-npc__banner">
      {{ errorMsg }}
      <AppButton variant="ghost" size="sm" @click="load">
        {{ t('retry') }}
      </AppButton>
    </AppBanner>

    <AppBanner v-if="duplicateError" tone="danger" role="alert" class="page-npc__banner">
      {{ duplicateError }}
    </AppBanner>

    <AppBanner v-if="deleteError" tone="danger" role="alert" class="page-npc__banner">
      {{ deleteError }}
    </AppBanner>

    <!-- ── Loading skeleton ──────────────────────────────────────────────────── -->
    <div v-if="state === 'loading'" class="page-npc__skeleton" aria-busy="true" />

    <!-- ── Not found ─────────────────────────────────────────────────────────── -->
    <AppCard v-else-if="state === 'notfound'" class="page-npc__notfound">
      <h2 class="page-npc__notfound-title">
        {{ t('notfoundTitle') }}
      </h2>
      <p class="page-npc__notfound-body">
        {{ t('notfoundBody') }}
      </p>
    </AppCard>

    <!-- ── Loaded ─────────────────────────────────────────────────────────────── -->
    <template v-else-if="npc && state === 'loaded'">
      <!-- Header -->
      <header class="page-npc__header">
        <div class="page-npc__header-left">
          <h1 class="page-npc__name" data-testid="npc-name">
            {{ npc.name }}
          </h1>
        </div>
        <div class="page-npc__header-actions">
          <AppSavePulse :state="headerSaveState" />
          <AppButton
            variant="ghost"
            size="sm"
            :disabled="duplicating"
            data-testid="btn-duplicate"
            @click="onDuplicate"
          >
            {{ t('duplicate') }}
          </AppButton>
          <AppButton
            variant="ghost"
            size="sm"
            :disabled="deleting"
            data-testid="btn-delete"
            @click="openDeleteConfirm"
          >
            {{ t('delete') }}
          </AppButton>
        </div>
      </header>

      <!-- ── Identity card (name edit) ──────────────────────────────────────── -->
      <AppCard class="page-npc__card">
        <template #header>
          <span class="page-npc__card-title">{{ t('identityCardTitle') }}</span>
        </template>

        <AppField :label="t('fieldName')" required>
          <template #default="attrs">
            <AppInput
              v-bind="attrs"
              v-model="localName"
              type="text"
              :placeholder="t('fieldName')"
              data-testid="input-name"
              @blur="identitySave.schedule()"
            />
          </template>
        </AppField>
      </AppCard>

      <!-- ── Stats card ─────────────────────────────────────────────────────── -->
      <AppCard class="page-npc__card">
        <template #header>
          <span class="page-npc__card-title">{{ t('statsCardTitle') }}</span>
        </template>

        <!-- Attributes sub-section -->
        <p class="page-npc__section-label">
          {{ t('sectionAttributes') }}
        </p>
        <div class="page-npc__attr-grid" data-testid="attr-grid">
          <div v-for="key in ATTR_KEYS" :key="key" class="page-npc__stat">
            <span class="page-npc__stat-label">{{
              t(`attr${key.charAt(0).toUpperCase()}${key.slice(1)}`)
            }}</span>
            <div class="page-npc__stat-stepper">
              <AppButton
                variant="ghost"
                size="sm"
                class="page-npc__stepper-btn"
                :disabled="localAttributes[key] <= 1"
                @click="
                  localAttributes[key] = Math.max(1, localAttributes[key] - 1);
                  statsSave.schedule();
                "
              >
                −
              </AppButton>
              <AppInput
                v-model="localAttributes[key]"
                type="number"
                size="md"
                inputmode="numeric"
                class="page-npc__stat-input"
                @blur="statsSave.schedule()"
              />
              <AppButton
                variant="ghost"
                size="sm"
                class="page-npc__stepper-btn"
                :disabled="localAttributes[key] >= 5"
                @click="
                  localAttributes[key] = Math.min(5, localAttributes[key] + 1);
                  statsSave.schedule();
                "
              >
                +
              </AppButton>
            </div>
          </div>
        </div>

        <!-- HP / MP / Signature / KeySkillMod -->
        <div class="page-npc__pool-grid">
          <!-- HP current — prominent -->
          <div class="page-npc__stat page-npc__stat--prominent">
            <span class="page-npc__stat-label">{{ t('statHpCurrent') }}</span>
            <div class="page-npc__stat-stepper">
              <AppButton
                variant="ghost"
                size="sm"
                class="page-npc__stepper-btn"
                :disabled="localHpCurrent <= 0"
                @click="
                  localHpCurrent = Math.max(0, localHpCurrent - 1);
                  statsSave.schedule();
                "
              >
                −
              </AppButton>
              <AppInput
                v-model="localHpCurrent"
                type="number"
                size="md"
                inputmode="numeric"
                class="page-npc__stat-input page-npc__stat-input--prominent"
                data-testid="input-hp-current"
                @blur="statsSave.schedule()"
              />
              <AppButton
                variant="ghost"
                size="sm"
                class="page-npc__stepper-btn"
                @click="
                  localHpCurrent = localHpCurrent + 1;
                  statsSave.schedule();
                "
              >
                +
              </AppButton>
            </div>
          </div>

          <!-- HP max -->
          <div class="page-npc__stat">
            <span class="page-npc__stat-label">{{ t('statHpMax') }}</span>
            <AppInput
              v-model="localHpMax"
              type="number"
              size="md"
              inputmode="numeric"
              class="page-npc__stat-input"
              @blur="statsSave.schedule()"
            />
          </div>

          <!-- MP current — prominent -->
          <div class="page-npc__stat page-npc__stat--prominent">
            <span class="page-npc__stat-label">{{ t('statMpCurrent') }}</span>
            <div class="page-npc__stat-stepper">
              <AppButton
                variant="ghost"
                size="sm"
                class="page-npc__stepper-btn"
                :disabled="localMpCurrent <= 0"
                @click="
                  localMpCurrent = Math.max(0, localMpCurrent - 1);
                  statsSave.schedule();
                "
              >
                −
              </AppButton>
              <AppInput
                v-model="localMpCurrent"
                type="number"
                size="md"
                inputmode="numeric"
                class="page-npc__stat-input page-npc__stat-input--prominent"
                @blur="statsSave.schedule()"
              />
              <AppButton
                variant="ghost"
                size="sm"
                class="page-npc__stepper-btn"
                @click="
                  localMpCurrent = localMpCurrent + 1;
                  statsSave.schedule();
                "
              >
                +
              </AppButton>
            </div>
          </div>

          <!-- MP max -->
          <div class="page-npc__stat">
            <span class="page-npc__stat-label">{{ t('statMpMax') }}</span>
            <AppInput
              v-model="localMpMax"
              type="number"
              size="md"
              inputmode="numeric"
              class="page-npc__stat-input"
              @blur="statsSave.schedule()"
            />
          </div>

          <!-- Signature -->
          <div class="page-npc__stat">
            <span class="page-npc__stat-label">{{ t('statSignature') }}</span>
            <AppInput
              v-model="localSignature"
              type="number"
              size="md"
              inputmode="numeric"
              class="page-npc__stat-input"
              @blur="statsSave.schedule()"
            />
          </div>

          <!-- Key skill modifier -->
          <div class="page-npc__stat">
            <span class="page-npc__stat-label">{{ t('statKeySkillMod') }}</span>
            <AppInput
              v-model="localKeySkillModifier"
              type="number"
              size="md"
              inputmode="numeric"
              class="page-npc__stat-input"
              @blur="statsSave.schedule()"
            />
          </div>
        </div>

        <!-- General skills sub-section -->
        <p class="page-npc__section-label">
          {{ t('sectionSkillsGeneral') }}
        </p>
        <div class="page-npc__skill-grid">
          <div v-for="key in GENERAL_SKILLS" :key="key" class="page-npc__stat">
            <span class="page-npc__stat-label">{{
              t(`skill${key.charAt(0).toUpperCase()}${key.slice(1)}`)
            }}</span>
            <AppInput
              v-model="localSkills[key]"
              type="number"
              size="md"
              inputmode="numeric"
              class="page-npc__stat-input"
              @blur="statsSave.schedule()"
            />
          </div>
        </div>

        <!-- Advanced skills sub-section -->
        <p class="page-npc__section-label">
          {{ t('sectionSkillsAdvanced') }}
        </p>
        <div class="page-npc__skill-grid">
          <div v-for="key in ADVANCED_SKILLS" :key="key" class="page-npc__stat">
            <span class="page-npc__stat-label">{{
              t(`skill${key.charAt(0).toUpperCase()}${key.slice(1)}`)
            }}</span>
            <AppInput
              v-model="localSkills[key]"
              type="number"
              size="md"
              inputmode="numeric"
              class="page-npc__stat-input"
              @blur="statsSave.schedule()"
            />
          </div>
        </div>
      </AppCard>

      <!-- ── Equipment card (armor/weapons counts — read-only for Block 2) ──── -->
      <AppCard class="page-npc__card">
        <template #header>
          <span class="page-npc__card-title">{{ t('equipmentCardTitle') }}</span>
        </template>

        <div class="page-npc__equipment-row">
          <div class="page-npc__equipment-item">
            <span class="page-npc__stat-label">{{ t('armorLabel') }}</span>
            <AppBadge variant="brass" size="sm">
              {{ armorCount > 0 ? armorCount : t('armorNone') }}
            </AppBadge>
          </div>
          <div class="page-npc__equipment-item">
            <span class="page-npc__stat-label">{{ t('weaponsLabel') }}</span>
            <AppBadge variant="crimson" size="sm">
              {{ weaponsCount > 0 ? weaponsCount : t('weaponsNone') }}
            </AppBadge>
          </div>
        </div>
      </AppCard>

      <!-- ── Tags card ──────────────────────────────────────────────────────── -->
      <AppCard class="page-npc__card">
        <template #header>
          <span class="page-npc__card-title">{{ t('tagsCardTitle') }}</span>
        </template>

        <!-- Chip preview -->
        <div v-if="displayTags.length > 0" class="page-npc__tags-chips" data-testid="tags-chips">
          <AppBadge
            v-for="tag in displayTags"
            :key="tag"
            variant="darkness"
            size="sm"
            class="page-npc__tag-chip"
          >
            {{ tag }}
          </AppBadge>
        </div>

        <AppField :label="t('tagsLabel')" :help-text="t('tagsHelp')">
          <template #default="attrs">
            <AppInput
              v-bind="attrs"
              v-model="localTagsInput"
              type="text"
              :placeholder="t('tagsPlaceholder')"
              data-testid="input-tags"
              @blur="tagsSave.schedule()"
            />
          </template>
        </AppField>
      </AppCard>

      <!-- ── Description card ───────────────────────────────────────────────── -->
      <AppCard class="page-npc__card">
        <template #header>
          <span class="page-npc__card-title">{{ t('descriptionCardTitle') }}</span>
        </template>

        <AppTextarea
          v-model="localDescription"
          :rows="6"
          :maxlength="2000"
          :placeholder="t('descriptionPlaceholder')"
          data-testid="textarea-description"
          @blur="descriptionSave.schedule()"
        />
      </AppCard>

      <!-- ── Problems / Validation card ─────────────────────────────────────── -->
      <AppCard
        v-if="validationProblems.length > 0"
        class="page-npc__card page-npc__card--problems"
        data-testid="problems-card"
      >
        <template #header>
          <span class="page-npc__card-title page-npc__card-title--danger">
            {{ t('problemsCardTitle') }}
          </span>
        </template>

        <p class="page-npc__problems-intro">
          {{ t('problemsIntro') }}
        </p>
        <ul class="page-npc__problems-list" role="list">
          <li
            v-for="(problem, idx) in validationProblems"
            :key="idx"
            class="page-npc__problems-item"
          >
            {{ problem }}
          </li>
        </ul>
        <AppButton
          variant="ghost"
          size="sm"
          class="page-npc__problems-dismiss"
          data-testid="btn-dismiss-problems"
          @click="clearValidationProblems"
        >
          {{ t('problemsRetry') }}
        </AppButton>
      </AppCard>
    </template>

    <!-- ── Delete confirmation modal ─────────────────────────────────────────── -->
    <AppModal
      :open="deleteConfirmOpen"
      :aria-label="t('deleteConfirmTitle')"
      size="sm"
      :close-on-backdrop="false"
      :close-on-esc="!deleting"
      data-testid="delete-modal"
      @update:open="
        (v) => {
          if (!v) closeDeleteConfirm();
        }
      "
    >
      <div class="page-npc__delete-modal">
        <p class="page-npc__delete-modal-heading">
          {{ t('deleteConfirmTitle') }}
        </p>
        <p class="page-npc__delete-modal-body">
          {{ t('deleteConfirmBody') }}
        </p>
        <div class="page-npc__delete-modal-actions">
          <AppButton variant="ghost" size="md" :disabled="deleting" @click="closeDeleteConfirm">
            {{ t('deleteConfirmNo') }}
          </AppButton>
          <AppButton variant="danger" size="md" :loading="deleting" @click="confirmDelete">
            {{ t('deleteConfirmYes') }}
          </AppButton>
        </div>
      </div>
    </AppModal>
  </section>
</template>

<style lang="scss" scoped>
  $skeleton-height: 200px;
  $stat-input-width: 72px;
  $stat-input-prominent-width: 90px;
  $page-max-width: 960px;

  .page-npc {
    display: flex;
    flex-direction: column;
    gap: var(--space-5);
    padding: var(--space-6);
    max-width: $page-max-width;
    margin: 0 auto;

    // ── Back link ──────────────────────────────────────────────────────────────

    &__back {
      align-self: flex-start;
    }

    // ── Error / info banners ───────────────────────────────────────────────────

    &__banner {
      width: 100%;
    }

    // ── Skeleton ───────────────────────────────────────────────────────────────

    &__skeleton {
      height: $skeleton-height;
      border-radius: var(--radius-md);
      background-color: var(--surface-night);
      border: 1px solid var(--brand-brass-shadow);
      opacity: var(--opacity-disabled);
    }

    // ── Not found ──────────────────────────────────────────────────────────────

    &__notfound {
      padding: var(--space-6);
    }

    &__notfound-title {
      margin: 0 0 var(--space-2);
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__notfound-body {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
    }

    // ── Header ─────────────────────────────────────────────────────────────────

    &__header {
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      gap: var(--space-4);
      flex-wrap: wrap;
    }

    &__header-left {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__header-actions {
      display: inline-flex;
      align-items: center;
      gap: var(--space-3);
      flex-wrap: wrap;
    }

    &__name {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-md-font-size);
      letter-spacing: var(--type-display-md-letter-spacing);
      color: var(--brand-brass-light);
    }

    // ── Cards shared ───────────────────────────────────────────────────────────

    &__card {
      width: 100%;

      &--problems {
        border-color: var(--color-danger);
      }
    }

    &__card-title {
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);

      &--danger {
        color: var(--color-danger);
      }
    }

    // ── Section labels (within a card) ─────────────────────────────────────────

    &__section-label {
      margin: var(--space-4) 0 var(--space-2);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      font-weight: 600;
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.06em;

      &:first-child {
        margin-top: 0;
      }
    }

    // ── Attribute grid (4 columns) ─────────────────────────────────────────────

    &__attr-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: var(--space-4);

      @media (max-width: 640px) {
        grid-template-columns: repeat(2, 1fr);
      }
    }

    // ── Pool grid (HP/MP/Signature/KeySkill — 3 columns) ──────────────────────

    &__pool-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: var(--space-4);
      margin-top: var(--space-4);

      @media (max-width: 640px) {
        grid-template-columns: repeat(2, 1fr);
      }
    }

    // ── Skills grid (4 columns) ───────────────────────────────────────────────

    &__skill-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: var(--space-3);

      @media (max-width: 768px) {
        grid-template-columns: repeat(2, 1fr);
      }

      @media (max-width: 480px) {
        grid-template-columns: 1fr;
      }
    }

    // ── Shared stat cell ───────────────────────────────────────────────────────

    &__stat {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);

      &--prominent {
        .page-npc__stat-input {
          width: $stat-input-prominent-width;
          font-size: var(--type-body-lg-font-size);
          font-weight: 600;
        }
      }
    }

    &__stat-label {
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    &__stat-input {
      width: $stat-input-width;
      text-align: center;
    }

    &__stat-stepper {
      display: flex;
      align-items: center;
      gap: var(--space-2);
    }

    &__stepper-btn {
      flex-shrink: 0;
    }

    // ── Equipment card ─────────────────────────────────────────────────────────

    &__equipment-row {
      display: flex;
      gap: var(--space-6);
      flex-wrap: wrap;
    }

    &__equipment-item {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    // ── Tags ───────────────────────────────────────────────────────────────────

    &__tags-chips {
      display: flex;
      flex-wrap: wrap;
      gap: var(--space-2);
      margin-bottom: var(--space-3);
    }

    &__tag-chip {
      flex-shrink: 0;
    }

    // ── Problems card ──────────────────────────────────────────────────────────

    &__problems-intro {
      margin: 0 0 var(--space-3);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    &__problems-list {
      list-style: disc;
      margin: 0 0 var(--space-4);
      padding-inline-start: var(--space-5);
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__problems-item {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--color-danger);
    }

    &__problems-dismiss {
      align-self: flex-start;
    }

    // ── Delete modal ───────────────────────────────────────────────────────────

    &__delete-modal {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
      padding: var(--space-4);
    }

    &__delete-modal-heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-body-lg-font-size);
      color: var(--brand-brass-light);
    }

    &__delete-modal-body {
      margin: 0;
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--text-secondary);
    }

    &__delete-modal-actions {
      display: flex;
      justify-content: flex-end;
      gap: var(--space-3);
    }
  }
</style>
