<script setup lang="ts">
  import {
    AppCard,
    AppButton,
    AppInput,
    AppTextarea,
    AppStatBlock,
    AppPopover,
    AppModal,
    AppDots,
    AppDivider,
    AppConditionPill,
    AppBanner,
    AppSavePulse,
    AppBadge,
    AppTab,
  } from '@app/ui';
  import { ref, watch, onBeforeUnmount, computed } from 'vue';
  import { useCharactersApi } from '~/composables/useCharactersApi';
  import type { Character, Problem } from '~/composables/useCharactersApi';
  import { useTalentsApi } from '~/composables/useTalentsApi';
  import type { Talent } from '~/composables/useTalentsApi';
  import type { Item } from '~/composables/useItemsApi';
  import type { Attributes, Skills, ConditionFlags, CriticalInjury } from '@app/api-client-ts';
  import { useTalentLocalization } from '~/composables/useTalentLocalization';
  import { useAutoSave } from '~/composables/useAutoSave';
  import type { SaveState } from '~/composables/useAutoSave';
  import SheetDiceRoller from '~/components/sheet/SheetDiceRoller.vue';
  import SheetRollHistory from '~/components/sheet/SheetRollHistory.vue';
  import type { Roll } from '~/composables/useRollsApi';

  const { t } = useI18n({ useScope: 'local' });
  const { displayTalentName } = useTalentLocalization();
  const api = useCharactersApi();
  const talentsApi = useTalentsApi();
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
  type ConditionKey = 'exhausted' | 'sleepless' | 'thirsty' | 'hungry';

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

  const CONDITION_KEYS: ConditionKey[] = ['exhausted', 'sleepless', 'thirsty', 'hungry'];

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

  const localHpCurrent = ref(0);
  const localMpCurrent = ref(0);

  // ── Conditions (Feature 5.3) ─────────────────────────────────────────────────

  const localConditions = ref<ConditionFlags>({
    exhausted: false,
    sleepless: false,
    thirsty: false,
    hungry: false,
  });
  const conditionsError = ref('');

  // ── Critical injuries (Feature 5.3) ──────────────────────────────────────────

  const localInjuries = ref<CriticalInjury[]>([]);
  const injuriesError = ref('');
  // Inline add-injury state
  const addInjuryActive = ref(false);
  const newInjuryName = ref('');
  const addInjurySaving = ref(false);

  // ── Tab navigation ────────────────────────────────────────────────────────────

  type SheetTab = 'stats' | 'gear' | 'talents' | 'notes' | 'share';
  const activeTab = ref<SheetTab>('stats');

  // ── Inventory (Feature 5.4) ───────────────────────────────────────────────────

  const localInventory = ref<Item[]>([]);
  const itemEditorOpen = ref(false);
  const itemEditorItem = ref<Item | null>(null); // null = create mode

  function openCreateItem(): void {
    itemEditorItem.value = null;
    itemEditorOpen.value = true;
  }

  function openEditItem(item: Item): void {
    itemEditorItem.value = item;
    itemEditorOpen.value = true;
  }

  function onItemSaved(item: Item): void {
    const idx = localInventory.value.findIndex((i) => i.id === item.id);
    localInventory.value =
      idx !== -1
        ? // Update in-place
          localInventory.value.map((i) => (i.id === item.id ? item : i))
        : // Prepend new item
          [item, ...localInventory.value];
  }

  function onItemDeleted(itemId: string): void {
    localInventory.value = localInventory.value.filter((i) => i.id !== itemId);
  }

  // ── Computed: encumbrance ─────────────────────────────────────────────────────

  const isEncumbered = computed<boolean>(() => {
    if (!character.value) return false;
    return character.value.encumbrance.current > character.value.encumbrance.max;
  });

  // ── Computed: equipped items (for right-column quick view) ────────────────────

  const equippedItems = computed<Item[]>(() =>
    localInventory.value.filter(
      (item) =>
        (item.type === 'WEAPON' || item.type === 'ARMOR' || item.type === 'GEAR') &&
        'equipped' in item &&
        item.equipped,
    ),
  );

  // ── Helpers: item type badge variant ─────────────────────────────────────────

  function itemTypeBadgeVariant(
    type: string,
  ): 'brass' | 'mystic' | 'crimson' | 'success' | 'darkness' {
    switch (type) {
      case 'WEAPON': {
        return 'crimson';
      }
      case 'ARMOR': {
        return 'brass';
      }
      case 'GEAR': {
        return 'success';
      }
      case 'CYBERNETIC': {
        return 'mystic';
      }
      case 'SHIP_MODULE': {
        return 'darkness';
      }
      default: {
        return 'brass';
      }
    }
  }

  function itemTypeBadgeLabel(type: string): string {
    return t(`itemType.${type}`);
  }

  function itemSummary(item: Item): string {
    if (item.type === 'WEAPON') return `+${String(item.bonus)} / ${String(item.damage)}d`;
    if (item.type === 'ARMOR') return `AR ${String(item.armorRating)}`;
    if (item.type === 'GEAR') return `×${String(item.quantity)}`;
    if (item.type === 'CYBERNETIC') return `${String(item.bodyPoints)} BP`;
    if (item.type === 'SHIP_MODULE') return item.slot;
    // OTHER — always has weight field
    return `${String(item.weight)} enc`;
  }

  // ── Rolls (Phase 4 Feature 7.1) ────────────────────────────────────────────────
  // SheetDiceRoller emits rollCreated / rollPushed; we forward both to the
  // sibling SheetRollHistory via its exposed `prependRoll` / `updateRoll`
  // methods so a fresh roll lands at the top of the list immediately
  // without a refetch (which would race against the still-being-persisted
  // INSERT on the server).
  interface RollHistoryHandle {
    prependRoll: (roll: Roll) => void;
    updateRoll: (roll: Roll) => void;
  }
  const rollHistoryRef = ref<RollHistoryHandle | null>(null);

  function onRollCreated(roll: Roll): void {
    rollHistoryRef.value?.prependRoll(roll);
  }

  function onRollPushed(roll: Roll): void {
    rollHistoryRef.value?.updateRoll(roll);
  }

  // ── Talents (Feature 5.2) ────────────────────────────────────────────────────

  const localTalents = ref<Talent[]>([]);

  // TalentEditor modal state — migrated to AppModal (Feature 5.4).
  const talentEditorOpen = ref(false);
  const talentEditorTalent = ref<Talent | null>(null); // null = create mode
  const talentEditorName = ref('');
  const talentEditorDescription = ref('');
  const talentEditorSaving = ref(false);
  const talentEditorError = ref('');

  // ── Delete confirmation ───────────────────────────────────────────────────────

  const deleteDialogOpen = ref(false);
  const deleteLoading = ref(false);

  // ── Popover state ─────────────────────────────────────────────────────────────

  const openPopover = ref<string | null>(null);
  const stepperValue = ref(0);

  // ── Auto-save: name + concept ────────────────────────────────────────────────

  const {
    saveState: _saveState,
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
      });
      character.value = updated;
      localHpCurrent.value = updated.hp.current;
      localMpCurrent.value = updated.mp.current;
    },
    { debounceMs: 500 },
  );

  // Explicitly typed to avoid Ref<SaveState | undefined> unwrapping ambiguity
  // in the template (TypeScript infers ReturnType<typeof ref<SaveState>> as
  // Ref<SaveState | undefined> when the generic argument is a union).
  const saveState = computed<SaveState>(() => _saveState.value ?? 'idle');

  watch(nameValue, () => {
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
      localConditions.value = { ...data.conditions };
      localInjuries.value = [...data.criticalInjuries];
      localTalents.value = [...data.talents];
      localInventory.value = [...data.inventory];
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
    localSkills.value = { ...localSkills.value, [key]: newValue };
    closeSkillPopover();
    try {
      const updated = await api.update(characterId.value, {
        skills: { ...localSkills.value },
      });
      character.value = updated;
      localSkills.value = { ...updated.skills };
    } catch {
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

  // ── Conditions (Feature 5.3) ──────────────────────────────────────────────────

  async function toggleCondition(key: ConditionKey): Promise<void> {
    if (!character.value) return;
    const prev = { ...localConditions.value };
    const next: ConditionFlags = { ...localConditions.value, [key]: !localConditions.value[key] };
    // Optimistic update
    localConditions.value = next;
    conditionsError.value = '';
    try {
      const updated = await api.update(characterId.value, { conditions: next });
      character.value = updated;
      localConditions.value = { ...updated.conditions };
    } catch (error) {
      // Rollback
      localConditions.value = prev;
      const problem = error as Problem;
      conditionsError.value = problem.detail ?? t('errorConditionToggle');
    }
  }

  // ── Critical injuries (Feature 5.3) ──────────────────────────────────────────

  function openAddInjury(): void {
    newInjuryName.value = '';
    addInjuryActive.value = true;
  }

  function cancelAddInjury(): void {
    addInjuryActive.value = false;
    newInjuryName.value = '';
  }

  async function confirmAddInjury(): Promise<void> {
    const name = newInjuryName.value.trim();
    if (!name || !character.value) return;
    addInjurySaving.value = true;
    injuriesError.value = '';
    // Optimistic — append a client-side entry; replace on server response.
    const tempInjury: CriticalInjury = {
      id: `__temp_${String(Date.now())}`,
      name,
      severity: 'light',
      effect: '',
      acquiredAt: new Date().toISOString(),
    };
    const prevInjuries = [...localInjuries.value];
    localInjuries.value = [...localInjuries.value, tempInjury];
    addInjuryActive.value = false;
    newInjuryName.value = '';
    try {
      const updated = await api.update(characterId.value, {
        criticalInjuries: localInjuries.value.map((inj) => ({
          ...inj,
          // strip temp id so server generates a real one
          ...(inj.id.startsWith('__temp_') ? { id: undefined as unknown as string } : {}),
        })),
      });
      character.value = updated;
      localInjuries.value = [...updated.criticalInjuries];
    } catch (error) {
      localInjuries.value = prevInjuries;
      const problem = error as Problem;
      injuriesError.value = problem.detail ?? t('errorInjuryAdd');
    } finally {
      addInjurySaving.value = false;
    }
  }

  async function removeInjury(injuryId: string): Promise<void> {
    if (!character.value) return;
    injuriesError.value = '';
    const prevInjuries = [...localInjuries.value];
    // Optimistic removal
    localInjuries.value = localInjuries.value.filter((inj) => inj.id !== injuryId);
    try {
      const updated = await api.update(characterId.value, {
        criticalInjuries: localInjuries.value,
      });
      character.value = updated;
      localInjuries.value = [...updated.criticalInjuries];
    } catch (error) {
      localInjuries.value = prevInjuries;
      const problem = error as Problem;
      injuriesError.value = problem.detail ?? t('errorInjuryRemove');
    }
  }

  // ── Talents — TalentEditor (Feature 5.2) ──────────────────────────────────────

  function openCreateTalent(): void {
    talentEditorTalent.value = null;
    talentEditorName.value = '';
    talentEditorDescription.value = '';
    talentEditorError.value = '';
    talentEditorOpen.value = true;
  }

  function openEditTalent(talent: Talent): void {
    talentEditorTalent.value = talent;
    talentEditorName.value = talent.name;
    talentEditorDescription.value = talent.description;
    talentEditorError.value = '';
    talentEditorOpen.value = true;
  }

  function closeTalentEditor(): void {
    talentEditorOpen.value = false;
  }

  async function saveTalent(): Promise<void> {
    const name = talentEditorName.value.trim();
    const description = talentEditorDescription.value.trim();
    if (!name || !character.value) return;

    talentEditorSaving.value = true;
    talentEditorError.value = '';

    try {
      if (talentEditorTalent.value) {
        // Update existing
        const updated = await talentsApi.updateTalent(talentEditorTalent.value.id, {
          name,
          description,
        });
        localTalents.value = localTalents.value.map((t) => (t.id === updated.id ? updated : t));
      } else {
        // Create new — prepend to list
        const created = await talentsApi.addTalent(characterId.value, {
          name,
          description,
        });
        localTalents.value = [created, ...localTalents.value];
      }
      closeTalentEditor();
    } catch (error) {
      const problem = error as Problem;
      talentEditorError.value = problem.detail ?? t('errorTalentSave');
    } finally {
      talentEditorSaving.value = false;
    }
  }

  async function deleteTalentConfirm(talent: Talent): Promise<void> {
    // v1: native confirm() — AppModal primitive is a separate batch
    if (!confirm(t('talentDeleteConfirm', { name: displayTalentName(talent) }))) return;
    talentEditorError.value = '';
    try {
      await talentsApi.removeTalent(talent.id);
      localTalents.value = localTalents.value.filter((t) => t.id !== talent.id);
      closeTalentEditor();
    } catch (error) {
      const problem = error as Problem;
      talentEditorError.value = problem.detail ?? t('errorTalentDelete');
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

  // ── Computed labels ───────────────────────────────────────────────────────────

  function attrLabel(key: AttrKey): string {
    return t(`attr.${key}`);
  }

  function skillLabel(key: SkillKey): string {
    return t(`skill.${key}`);
  }

  function conditionLabel(key: ConditionKey): string {
    return t(`condition.${key}`);
  }

  const talentEditorIsEdit = computed(() => talentEditorTalent.value !== null);
  const talentNameValid = computed(() => {
    const v = talentEditorName.value.trim();
    return v.length > 0 && v.length <= 80;
  });
  const talentDescriptionValid = computed(() => {
    const v = talentEditorDescription.value.trim();
    return v.length === 0 || v.length <= 600;
  });
  const talentEditorCanSave = computed(() => talentNameValid.value && talentDescriptionValid.value);
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
    "panelCriticalInjuries": "Critical Injuries",
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
    "concept": {
      "artist": "Artist",
      "networker": "Networker",
      "fugitive": "Fugitive",
      "negotiator": "Negotiator",
      "operative": "Operative",
      "pilot": "Pilot",
      "pioneer": "Pioneer",
      "preacher": "Preacher",
      "scientist": "Scientist",
      "sailor": "Sailor",
      "soldier": "Soldier"
    },
    "condition": {
      "exhausted": "Exhausted",
      "sleepless": "Sleepless",
      "thirsty": "Thirsty",
      "hungry": "Hungry"
    },
    "errorConditionToggle": "Failed to update condition.",
    "injuryAddPlaceholder": "Broken arm, etc.",
    "injuryAddButton": "Add injury",
    "injuryAddCancel": "Cancel",
    "injuryAddSave": "Save",
    "injuryRemoveLabel": "Remove injury",
    "noInjuries": "No critical injuries.",
    "errorInjuryAdd": "Failed to add injury.",
    "errorInjuryRemove": "Failed to remove injury.",
    "talentAddButton": "Add talent",
    "talentEditTitle": "Edit talent",
    "talentCreateTitle": "New talent",
    "talentNameLabel": "Name",
    "talentNamePlaceholder": "e.g. Wing-Mate",
    "talentDescriptionLabel": "Description",
    "talentDescriptionPlaceholder": "Rules text or flavour…",
    "talentSave": "Save",
    "talentCancel": "Cancel",
    "talentDelete": "Remove talent",
    "talentDeleteConfirm": "Remove talent \"{name}\"? This cannot be undone.",
    "noTalents": "No talents yet.",
    "errorTalentSave": "Failed to save talent.",
    "errorTalentDelete": "Failed to remove talent.",
    "tabStats": "Stats",
    "tabGear": "Gear",
    "tabTalents": "Talents",
    "tabNotes": "Notes",
    "tabShare": "Share",
    "tabComingSoon": "Coming in a future update.",
    "gearAddButton": "Add item",
    "gearEmpty": "No items yet. Add your first item to get started.",
    "encWarning": "Encumbered (−1 die to physical actions)",
    "itemColType": "Type",
    "itemColName": "Name",
    "itemColEquipped": "Equipped",
    "itemColSummary": "Details",
    "itemColActions": "Actions",
    "itemEditBtn": "Edit",
    "itemDeleteBtn": "Delete",
    "equippedNone": "Nothing equipped.",
    "itemType": {
      "WEAPON": "Weapon",
      "ARMOR": "Armor",
      "GEAR": "Gear",
      "CYBERNETIC": "Cyber",
      "SHIP_MODULE": "Module",
      "OTHER": "Other"
    },
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
    "panelCriticalInjuries": "Критические ранения",
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
    "identityConcept": "Амплуа",
    "concept": {
      "artist": "Артист",
      "networker": "Сетевой паук",
      "fugitive": "Беглец",
      "negotiator": "Негоциант",
      "operative": "Оперативник",
      "pilot": "Пилот",
      "pioneer": "Первопроходец",
      "preacher": "Проповедник",
      "scientist": "Учёный",
      "sailor": "Матрос",
      "soldier": "Солдат"
    },
    "condition": {
      "exhausted": "Истощение",
      "sleepless": "Бессонница",
      "thirsty": "Жажда",
      "hungry": "Голод"
    },
    "errorConditionToggle": "Не удалось обновить состояние.",
    "injuryAddPlaceholder": "Сломанная рука и т.п.",
    "injuryAddButton": "Добавить ранение",
    "injuryAddCancel": "Отмена",
    "injuryAddSave": "Сохранить",
    "injuryRemoveLabel": "Удалить ранение",
    "noInjuries": "Нет критических ранений.",
    "errorInjuryAdd": "Не удалось добавить ранение.",
    "errorInjuryRemove": "Не удалось удалить ранение.",
    "talentAddButton": "Добавить талант",
    "talentEditTitle": "Редактировать талант",
    "talentCreateTitle": "Новый талант",
    "talentNameLabel": "Название",
    "talentNamePlaceholder": "напр. Напарник по крылу",
    "talentDescriptionLabel": "Описание",
    "talentDescriptionPlaceholder": "Текст правила или описание…",
    "talentSave": "Сохранить",
    "talentCancel": "Отмена",
    "talentDelete": "Удалить талант",
    "talentDeleteConfirm": "Удалить талант «{name}»? Это необратимо.",
    "noTalents": "Нет талантов.",
    "errorTalentSave": "Не удалось сохранить талант.",
    "errorTalentDelete": "Не удалось удалить талант.",
    "tabStats": "Статы",
    "tabGear": "Снаряжение",
    "tabTalents": "Таланты",
    "tabNotes": "Заметки",
    "tabShare": "Поделиться",
    "tabComingSoon": "Появится в будущем обновлении.",
    "gearAddButton": "Добавить предмет",
    "gearEmpty": "Нет предметов. Добавьте первый предмет.",
    "encWarning": "Перегружен (−1 кубик на физические действия)",
    "itemColType": "Тип",
    "itemColName": "Название",
    "itemColEquipped": "Экипировано",
    "itemColSummary": "Детали",
    "itemColActions": "Действия",
    "itemEditBtn": "Изменить",
    "itemDeleteBtn": "Удалить",
    "equippedNone": "Ничего не экипировано.",
    "itemType": {
      "WEAPON": "Оружие",
      "ARMOR": "Броня",
      "GEAR": "Снар.",
      "CYBERNETIC": "Кибер",
      "SHIP_MODULE": "Модуль",
      "OTHER": "Прочее"
    },
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
    "panelCriticalInjuries": "[uk-todo] Critical Injuries",
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
    "concept": {
      "artist": "[uk-todo] Artist",
      "networker": "[uk-todo] Networker",
      "fugitive": "[uk-todo] Fugitive",
      "negotiator": "[uk-todo] Negotiator",
      "operative": "[uk-todo] Operative",
      "pilot": "[uk-todo] Pilot",
      "pioneer": "[uk-todo] Pioneer",
      "preacher": "[uk-todo] Preacher",
      "scientist": "[uk-todo] Scientist",
      "sailor": "[uk-todo] Sailor",
      "soldier": "[uk-todo] Soldier"
    },
    "condition": {
      "exhausted": "[uk-todo] Exhausted",
      "sleepless": "[uk-todo] Sleepless",
      "thirsty": "[uk-todo] Thirsty",
      "hungry": "[uk-todo] Hungry"
    },
    "errorConditionToggle": "[uk-todo] Failed to update condition.",
    "injuryAddPlaceholder": "[uk-todo] Broken arm, etc.",
    "injuryAddButton": "[uk-todo] Add injury",
    "injuryAddCancel": "[uk-todo] Cancel",
    "injuryAddSave": "[uk-todo] Save",
    "injuryRemoveLabel": "[uk-todo] Remove injury",
    "noInjuries": "[uk-todo] No critical injuries.",
    "errorInjuryAdd": "[uk-todo] Failed to add injury.",
    "errorInjuryRemove": "[uk-todo] Failed to remove injury.",
    "talentAddButton": "[uk-todo] Add talent",
    "talentEditTitle": "[uk-todo] Edit talent",
    "talentCreateTitle": "[uk-todo] New talent",
    "talentNameLabel": "[uk-todo] Name",
    "talentNamePlaceholder": "[uk-todo] e.g. Wing-Mate",
    "talentDescriptionLabel": "[uk-todo] Description",
    "talentDescriptionPlaceholder": "[uk-todo] Rules text or flavour…",
    "talentSave": "[uk-todo] Save",
    "talentCancel": "[uk-todo] Cancel",
    "talentDelete": "[uk-todo] Remove talent",
    "talentDeleteConfirm": "[uk-todo] Remove talent \"{name}\"?",
    "noTalents": "[uk-todo] No talents yet.",
    "errorTalentSave": "[uk-todo] Failed to save talent.",
    "errorTalentDelete": "[uk-todo] Failed to remove talent.",
    "tabStats": "[uk-todo] Stats",
    "tabGear": "[uk-todo] Gear",
    "tabTalents": "[uk-todo] Talents",
    "tabNotes": "[uk-todo] Notes",
    "tabShare": "[uk-todo] Share",
    "tabComingSoon": "[uk-todo] Coming in a future update.",
    "gearAddButton": "[uk-todo] Add item",
    "gearEmpty": "[uk-todo] No items yet.",
    "encWarning": "[uk-todo] Encumbered (−1 die to physical actions)",
    "itemColType": "[uk-todo] Type",
    "itemColName": "[uk-todo] Name",
    "itemColEquipped": "[uk-todo] Equipped",
    "itemColSummary": "[uk-todo] Details",
    "itemColActions": "[uk-todo] Actions",
    "itemEditBtn": "[uk-todo] Edit",
    "itemDeleteBtn": "[uk-todo] Delete",
    "equippedNone": "[uk-todo] Nothing equipped.",
    "itemType": {
      "WEAPON": "[uk-todo] Weapon",
      "ARMOR": "[uk-todo] Armor",
      "GEAR": "[uk-todo] Gear",
      "CYBERNETIC": "[uk-todo] Cyber",
      "SHIP_MODULE": "[uk-todo] Module",
      "OTHER": "[uk-todo] Other"
    },
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
    "panelCriticalInjuries": "[el-todo] Critical Injuries",
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
    "concept": {
      "artist": "[el-todo] Artist",
      "networker": "[el-todo] Networker",
      "fugitive": "[el-todo] Fugitive",
      "negotiator": "[el-todo] Negotiator",
      "operative": "[el-todo] Operative",
      "pilot": "[el-todo] Pilot",
      "pioneer": "[el-todo] Pioneer",
      "preacher": "[el-todo] Preacher",
      "scientist": "[el-todo] Scientist",
      "sailor": "[el-todo] Sailor",
      "soldier": "[el-todo] Soldier"
    },
    "condition": {
      "exhausted": "[el-todo] Exhausted",
      "sleepless": "[el-todo] Sleepless",
      "thirsty": "[el-todo] Thirsty",
      "hungry": "[el-todo] Hungry"
    },
    "errorConditionToggle": "[el-todo] Failed to update condition.",
    "injuryAddPlaceholder": "[el-todo] Broken arm, etc.",
    "injuryAddButton": "[el-todo] Add injury",
    "injuryAddCancel": "[el-todo] Cancel",
    "injuryAddSave": "[el-todo] Save",
    "injuryRemoveLabel": "[el-todo] Remove injury",
    "noInjuries": "[el-todo] No critical injuries.",
    "errorInjuryAdd": "[el-todo] Failed to add injury.",
    "errorInjuryRemove": "[el-todo] Failed to remove injury.",
    "talentAddButton": "[el-todo] Add talent",
    "talentEditTitle": "[el-todo] Edit talent",
    "talentCreateTitle": "[el-todo] New talent",
    "talentNameLabel": "[el-todo] Name",
    "talentNamePlaceholder": "[el-todo] e.g. Wing-Mate",
    "talentDescriptionLabel": "[el-todo] Description",
    "talentDescriptionPlaceholder": "[el-todo] Rules text or flavour…",
    "talentSave": "[el-todo] Save",
    "talentCancel": "[el-todo] Cancel",
    "talentDelete": "[el-todo] Remove talent",
    "talentDeleteConfirm": "[el-todo] Remove talent \"{name}\"?",
    "noTalents": "[el-todo] No talents yet.",
    "errorTalentSave": "[el-todo] Failed to save talent.",
    "errorTalentDelete": "[el-todo] Failed to remove talent.",
    "tabStats": "[el-todo] Stats",
    "tabGear": "[el-todo] Gear",
    "tabTalents": "[el-todo] Talents",
    "tabNotes": "[el-todo] Notes",
    "tabShare": "[el-todo] Share",
    "tabComingSoon": "[el-todo] Coming in a future update.",
    "gearAddButton": "[el-todo] Add item",
    "gearEmpty": "[el-todo] No items yet.",
    "encWarning": "[el-todo] Encumbered (−1 die to physical actions)",
    "itemColType": "[el-todo] Type",
    "itemColName": "[el-todo] Name",
    "itemColEquipped": "[el-todo] Equipped",
    "itemColSummary": "[el-todo] Details",
    "itemColActions": "[el-todo] Actions",
    "itemEditBtn": "[el-todo] Edit",
    "itemDeleteBtn": "[el-todo] Delete",
    "equippedNone": "[el-todo] Nothing equipped.",
    "itemType": {
      "WEAPON": "[el-todo] Weapon",
      "ARMOR": "[el-todo] Armor",
      "GEAR": "[el-todo] Gear",
      "CYBERNETIC": "[el-todo] Cyber",
      "SHIP_MODULE": "[el-todo] Module",
      "OTHER": "[el-todo] Other"
    },
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
    <div
      v-if="state === 'loading'"
      class="page-sheet__loading"
      aria-busy="true"
    >
      <div
        class="page-sheet__skeleton-hero"
        aria-hidden="true"
      />
      <div
        class="page-sheet__skeleton-body"
        aria-hidden="true"
      />
    </div>

    <!-- ── Not found ─────────────────────────────────────────────────────────── -->
    <div
      v-else-if="state === 'not-found'"
      class="page-sheet__not-found"
    >
      <AppCard>
        <div class="page-sheet__not-found-inner">
          <p class="page-sheet__not-found-heading">
            {{ t('notFoundHeading') }}
          </p>
          <p class="page-sheet__not-found-body">
            {{ t('notFoundBody') }}
          </p>
          <AppButton
            variant="ghost"
            size="md"
            @click="navigateTo('/app/characters')"
          >
            {{ t('notFoundBack') }}
          </AppButton>
        </div>
      </AppCard>
    </div>

    <!-- ── Error ─────────────────────────────────────────────────────────────── -->
    <div
      v-else-if="state === 'error'"
      class="page-sheet__error"
      role="alert"
    >
      <p class="page-sheet__error-text">
        {{ errorMsg }}
      </p>
    </div>

    <!-- ── Loaded ─────────────────────────────────────────────────────────────── -->
    <template v-else-if="state === 'loaded' && character">
      <!-- ── Hero plate ──────────────────────────────────────────────────────── -->
      <div class="page-sheet__hero">
        <!-- Portrait avatar -->
        <div
          class="page-sheet__portrait"
          aria-hidden="true"
        >
          {{ initials(nameValue || character.name) }}
        </div>

        <!-- Identity (editable name + read-only concept + save status) -->
        <div class="page-sheet__identity">
          <div class="page-sheet__concept-label">
            {{ conceptValue ? t(`concept.${conceptValue}`) : t('identityConcept') }}
          </div>
          <AppInput
            v-model="nameValue"
            size="lg"
            :placeholder="t('namePlaceholder')"
            :aria-label="t('namePlaceholder')"
            autocomplete="off"
            class="page-sheet__name-input"
          />
          <!-- Feature 5.5 — AppSavePulse indicator -->
          <div
            class="page-sheet__save-status"
            aria-live="polite"
            aria-atomic="true"
          >
            <AppSavePulse :state="saveState" />
            <!-- sr-only accessible label for screen readers -->
            <span class="sr-only">
              <template v-if="saveState === 'saving'">{{ t('statusSaving') }}</template>
              <template v-else-if="saveState === 'saved'">{{ t('statusSaved') }}</template>
              <template v-else-if="saveState === 'error'">{{ t('statusError') }}: {{ saveError }}</template>
            </span>
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

          <!-- ENC (read-only, crimson when encumbered) -->
          <div
            class="page-sheet__counter page-sheet__counter--enc"
            :class="{ 'page-sheet__counter--enc-warn': isEncumbered }"
          >
            <span class="page-sheet__counter-label">{{ t('labelEnc') }}</span>
            <div class="page-sheet__counter-value">
              {{ character.encumbrance.current
              }}<span class="page-sheet__counter-max"> / {{ character.encumbrance.max }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- ── Encumbrance warning banner ─────────────────────────────────────── -->
      <AppBanner
        v-if="isEncumbered"
        tone="danger"
        class="page-sheet__enc-warning"
        role="status"
      >
        {{ t('encWarning') }}
      </AppBanner>

      <!-- ── Tab bar ──────────────────────────────────────────────────────────── -->
      <div
        class="page-sheet__tabs"
        role="tablist"
      >
        <AppTab
          :active="activeTab === 'stats'"
          size="md"
          tone="brass"
          @click="activeTab = 'stats'"
        >
          {{ t('tabStats') }}
        </AppTab>
        <AppTab
          :active="activeTab === 'gear'"
          size="md"
          tone="brass"
          @click="activeTab = 'gear'"
        >
          {{ t('tabGear') }}
        </AppTab>
        <AppTab
          :active="activeTab === 'talents'"
          size="md"
          tone="brass"
          @click="activeTab = 'talents'"
        >
          {{ t('tabTalents') }}
        </AppTab>
        <AppTab
          :active="activeTab === 'notes'"
          size="md"
          tone="brass"
          @click="activeTab = 'notes'"
        >
          {{ t('tabNotes') }}
        </AppTab>
        <AppTab
          :active="activeTab === 'share'"
          size="md"
          tone="brass"
          @click="activeTab = 'share'"
        >
          {{ t('tabShare') }}
        </AppTab>
      </div>

      <!-- ── Three-column body (Stats tab) ─────────────────────────────────────── -->
      <div
        v-show="activeTab === 'stats'"
        class="page-sheet__columns"
      >
        <!-- LEFT column: Identity + Conditions + Critical Injuries -->
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

          <!-- Feature 5.3 — Conditions panel -->
          <AppCard class="page-sheet__panel">
            <template #header>
              <span class="page-sheet__panel-title">{{ t('panelConditions') }}</span>
            </template>

            <!-- Condition pills -->
            <div class="page-sheet__conditions">
              <AppConditionPill
                v-for="key in CONDITION_KEYS"
                :key="key"
                :condition="key"
                :model-value="localConditions[key]"
                size="md"
                @update:model-value="toggleCondition(key)"
              >
                {{ conditionLabel(key) }}
              </AppConditionPill>
            </div>

            <!-- Conditions error banner -->
            <AppBanner
              v-if="conditionsError"
              tone="danger"
              class="page-sheet__conditions-error"
            >
              {{ conditionsError }}
            </AppBanner>

            <!-- Critical injuries sub-section -->
            <AppDivider
              tone="brass-deep"
              class="page-sheet__injuries-divider"
            />
            <div class="page-sheet__injuries-header">
              <span class="page-sheet__injuries-title">{{ t('panelCriticalInjuries') }}</span>
            </div>

            <AppBanner
              v-if="injuriesError"
              tone="danger"
              class="page-sheet__conditions-error"
            >
              {{ injuriesError }}
            </AppBanner>

            <!-- Injuries list -->
            <ul
              v-if="localInjuries.length > 0"
              class="page-sheet__injuries-list"
            >
              <li
                v-for="injury in localInjuries"
                :key="injury.id"
                class="page-sheet__injury-row"
              >
                <span class="page-sheet__injury-name">{{ injury.name }}</span>
                <button
                  class="page-sheet__injury-remove"
                  :aria-label="t('injuryRemoveLabel')"
                  @click="removeInjury(injury.id)"
                >
                  ×
                </button>
              </li>
            </ul>
            <p
              v-else
              class="page-sheet__injuries-empty"
            >
              {{ t('noInjuries') }}
            </p>

            <!-- Inline add injury -->
            <div
              v-if="addInjuryActive"
              class="page-sheet__injury-add-form"
            >
              <AppInput
                v-model="newInjuryName"
                size="sm"
                :placeholder="t('injuryAddPlaceholder')"
                :aria-label="t('injuryAddPlaceholder')"
                autocomplete="off"
                @keydown.enter.prevent="confirmAddInjury"
                @keydown.esc.prevent="cancelAddInjury"
              />
              <div class="page-sheet__injury-add-actions">
                <AppButton
                  variant="ghost"
                  size="sm"
                  @click="cancelAddInjury"
                >
                  {{ t('injuryAddCancel') }}
                </AppButton>
                <AppButton
                  variant="primary"
                  size="sm"
                  :loading="addInjurySaving"
                  :disabled="!newInjuryName.trim()"
                  @click="confirmAddInjury"
                >
                  {{ t('injuryAddSave') }}
                </AppButton>
              </div>
            </div>
            <AppButton
              v-else
              variant="ghost"
              size="sm"
              class="page-sheet__injury-add-btn"
              @click="openAddInjury"
            >
              + {{ t('injuryAddButton') }}
            </AppButton>
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
                    <AppButton
                      variant="ghost"
                      size="sm"
                      @click="closeAttrPopover"
                    >
                      {{ t('popoverClose') }}
                    </AppButton>
                    <AppButton
                      variant="primary"
                      size="sm"
                      @click="commitAttr(key, stepperValue)"
                    >
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
                <template
                  v-for="sk in GENERAL_SKILLS"
                  :key="sk"
                >
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
                        <AppButton
                          variant="ghost"
                          size="sm"
                          @click="closeSkillPopover"
                        >
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
                <template
                  v-for="sk in ADVANCED_SKILLS"
                  :key="sk"
                >
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
                        <AppButton
                          variant="ghost"
                          size="sm"
                          @click="closeSkillPopover"
                        >
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

        <!-- RIGHT column: Equipped quick view + Talents + Recent Rolls -->
        <div class="page-sheet__col page-sheet__col--right">
          <!-- ── Feature 5.4: Equipped quick view ────────────────────────────── -->
          <AppCard class="page-sheet__panel">
            <template #header>
              <span class="page-sheet__panel-title">{{ t('panelEquipped') }}</span>
            </template>
            <ul
              v-if="equippedItems.length > 0"
              class="page-sheet__equipped-list"
            >
              <li
                v-for="item in equippedItems"
                :key="item.id"
                class="page-sheet__equipped-row"
              >
                <span class="page-sheet__equipped-name">{{ item.name }}</span>
                <span class="page-sheet__equipped-summary">{{ itemSummary(item) }}</span>
              </li>
            </ul>
            <p
              v-else
              class="page-sheet__placeholder-text"
            >
              {{ t('equippedNone') }}
            </p>
          </AppCard>

          <!-- Feature 5.2 — Talents panel -->
          <AppCard class="page-sheet__panel">
            <template #header>
              <span class="page-sheet__panel-title">{{ t('panelTalents') }}</span>
            </template>

            <!-- Error banner -->
            <AppBanner
              v-if="talentEditorError && !talentEditorOpen"
              tone="danger"
              class="page-sheet__talent-error"
            >
              {{ talentEditorError }}
            </AppBanner>

            <!-- Talent list -->
            <ul
              v-if="localTalents.length > 0"
              class="page-sheet__talents-list"
            >
              <li
                v-for="talent in localTalents"
                :key="talent.id"
                class="page-sheet__talent-row"
              >
                <button
                  class="page-sheet__talent-btn"
                  @click="openEditTalent(talent)"
                >
                  <span class="page-sheet__talent-name">{{ displayTalentName(talent) }}</span>
                  <span
                    class="page-sheet__talent-chevron"
                    aria-hidden="true"
                  >›</span>
                </button>
              </li>
            </ul>
            <p
              v-else
              class="page-sheet__placeholder-text"
            >
              {{ t('noTalents') }}
            </p>

            <AppButton
              variant="ghost"
              size="sm"
              class="page-sheet__talent-add-btn"
              @click="openCreateTalent"
            >
              + {{ t('talentAddButton') }}
            </AppButton>
          </AppCard>

          <AppCard class="page-sheet__panel">
            <template #header>
              <span class="page-sheet__panel-title">{{ t('panelRolls') }}</span>
            </template>
            <SheetDiceRoller
              :character-id="characterId"
              :exhausted="localConditions.exhausted"
              @roll-created="onRollCreated"
              @roll-pushed="onRollPushed"
            />
            <SheetRollHistory
              ref="rollHistoryRef"
              :character-id="characterId"
            />
          </AppCard>
        </div>
      </div>

      <!-- ── Gear tab ────────────────────────────────────────────────────────── -->
      <div
        v-show="activeTab === 'gear'"
        class="page-sheet__gear-tab"
      >
        <!-- Top action row -->
        <div class="page-sheet__gear-header">
          <AppButton
            variant="primary"
            size="sm"
            @click="openCreateItem"
          >
            + {{ t('gearAddButton') }}
          </AppButton>
          <!-- Encumbrance summary -->
          <div
            class="page-sheet__gear-enc"
            :class="{ 'page-sheet__gear-enc--warn': isEncumbered }"
          >
            <span class="page-sheet__gear-enc-label">{{ t('labelEnc') }}</span>
            <span class="page-sheet__gear-enc-value">
              {{ character.encumbrance.current }} / {{ character.encumbrance.max }}
            </span>
            <AppBadge
              v-if="isEncumbered"
              variant="crimson"
              size="sm"
            >
              {{ t('encWarning') }}
            </AppBadge>
          </div>
        </div>

        <!-- Inventory table -->
        <div
          v-if="localInventory.length > 0"
          class="page-sheet__gear-table-wrap"
        >
          <table class="page-sheet__gear-table">
            <thead>
              <tr>
                <th class="page-sheet__gear-th">
                  {{ t('itemColType') }}
                </th>
                <th class="page-sheet__gear-th page-sheet__gear-th--name">
                  {{ t('itemColName') }}
                </th>
                <th class="page-sheet__gear-th">
                  {{ t('itemColSummary') }}
                </th>
                <th class="page-sheet__gear-th">
                  {{ t('itemColActions') }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="item in localInventory"
                :key="item.id"
                class="page-sheet__gear-row"
              >
                <td class="page-sheet__gear-td">
                  <AppBadge
                    :variant="itemTypeBadgeVariant(item.type)"
                    size="sm"
                  >
                    {{ itemTypeBadgeLabel(item.type) }}
                  </AppBadge>
                </td>
                <td class="page-sheet__gear-td page-sheet__gear-td--name">
                  {{ item.name }}
                </td>
                <td class="page-sheet__gear-td page-sheet__gear-td--summary">
                  {{ itemSummary(item) }}
                </td>
                <td class="page-sheet__gear-td page-sheet__gear-td--actions">
                  <AppButton
                    variant="ghost"
                    size="sm"
                    @click="openEditItem(item)"
                  >
                    {{ t('itemEditBtn') }}
                  </AppButton>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Empty state -->
        <AppCard
          v-else
          class="page-sheet__gear-empty"
        >
          <p class="page-sheet__gear-empty-text">
            {{ t('gearEmpty') }}
          </p>
          <AppButton
            variant="primary"
            size="sm"
            @click="openCreateItem"
          >
            + {{ t('gearAddButton') }}
          </AppButton>
        </AppCard>
      </div>

      <!-- ── Other placeholder tabs ──────────────────────────────────────────── -->
      <div
        v-show="activeTab === 'talents'"
        class="page-sheet__tab-placeholder"
      >
        <p class="page-sheet__placeholder-text">
          {{ t('tabComingSoon') }}
        </p>
      </div>
      <div
        v-show="activeTab === 'notes'"
        class="page-sheet__tab-placeholder"
      >
        <p class="page-sheet__placeholder-text">
          {{ t('tabComingSoon') }}
        </p>
      </div>
      <div
        v-show="activeTab === 'share'"
        class="page-sheet__tab-placeholder"
      >
        <p class="page-sheet__placeholder-text">
          {{ t('tabComingSoon') }}
        </p>
      </div>

      <!-- ── Danger zone ─────────────────────────────────────────────────────── -->
      <div class="page-sheet__danger-zone">
        <AppButton
          variant="danger"
          size="sm"
          @click="openDeleteDialog"
        >
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
          <AppButton
            variant="ghost"
            size="md"
            :disabled="deleteLoading"
            @click="closeDeleteDialog"
          >
            {{ t('deleteConfirmNo') }}
          </AppButton>
          <AppButton
            variant="danger"
            size="md"
            :loading="deleteLoading"
            @click="confirmDelete"
          >
            {{ t('deleteConfirmYes') }}
          </AppButton>
        </div>
      </div>
    </dialog>

    <!-- ── Feature 5.2 — TalentEditor (migrated to AppModal in Feature 5.4) ──── -->
    <AppModal
      :open="talentEditorOpen"
      :aria-label="talentEditorIsEdit ? t('talentEditTitle') : t('talentCreateTitle')"
      size="md"
      @update:open="
        (v) => {
          if (!v) closeTalentEditor();
        }
      "
    >
      <div class="page-sheet__talent-editor">
        <p class="page-sheet__dialog-heading">
          {{ talentEditorIsEdit ? t('talentEditTitle') : t('talentCreateTitle') }}
        </p>

        <AppBanner
          v-if="talentEditorError"
          tone="danger"
          class="page-sheet__talent-editor-error"
        >
          {{ talentEditorError }}
        </AppBanner>

        <div class="page-sheet__talent-fields">
          <div class="page-sheet__talent-field">
            <label
              class="page-sheet__talent-label"
              :for="'talent-name'"
            >
              {{ t('talentNameLabel') }}
            </label>
            <AppInput
              id="talent-name"
              v-model="talentEditorName"
              size="md"
              :placeholder="t('talentNamePlaceholder')"
              autocomplete="off"
              @keydown.enter.prevent="talentEditorCanSave && saveTalent()"
            />
          </div>
          <div class="page-sheet__talent-field">
            <label
              class="page-sheet__talent-label"
              :for="'talent-desc'"
            >
              {{ t('talentDescriptionLabel') }}
            </label>
            <AppTextarea
              id="talent-desc"
              v-model="talentEditorDescription"
              :placeholder="t('talentDescriptionPlaceholder')"
              :rows="4"
            />
          </div>
        </div>
      </div>

      <template #footer>
        <!-- Remove talent (edit mode only) -->
        <button
          v-if="talentEditorIsEdit && talentEditorTalent"
          class="page-sheet__talent-delete-link"
          @click="deleteTalentConfirm(talentEditorTalent)"
        >
          {{ t('talentDelete') }}
        </button>
        <div class="page-sheet__dialog-actions-right">
          <AppButton
            variant="ghost"
            size="md"
            @click="closeTalentEditor"
          >
            {{ t('talentCancel') }}
          </AppButton>
          <AppButton
            variant="primary"
            size="md"
            :loading="talentEditorSaving"
            :disabled="!talentEditorCanSave"
            @click="saveTalent"
          >
            {{ t('talentSave') }}
          </AppButton>
        </div>
      </template>
    </AppModal>

    <!-- ── Feature 5.4 — ItemEditor modal ──────────────────────────────────────── -->
    <ItemEditor
      :open="itemEditorOpen"
      :item="itemEditorItem"
      :character-id="characterId"
      @update:open="itemEditorOpen = $event"
      @saved="onItemSaved"
      @deleted="onItemDeleted"
    />
  </section>
</template>

<style lang="scss" scoped>
  // ── Layout constants ──────────────────────────────────────────────────────────
  $column-gap: 24px;
  $hero-padding-v: 32px;
  $hero-padding-h: 40px;
  $portrait-size: 80px;
  $portrait-size-mobile: 48px;
  $skeleton-hero-height: 140px;
  $skeleton-body-height: 400px;
  $skeleton-stagger: 200ms;
  $dialog-max-width: 400px;
  $dialog-talent-max-width: 520px;
  $stepper-btn-size: 32px;
  $counter-min-width: 90px;
  $stepper-min-width: 160px;
  $panel-min-width-tablet: 200px;
  $col-left-pct: 28%;
  $col-center-pct: 44%;
  $col-right-pct: 28%;
  $font-size-eyebrow: 11px;
  $font-size-legend: 10px;
  $font-size-micro: 9px;
  $legend-dot-size: 8px;
  $accent-rail-offset: 6px;
  $bp-desktop: 1024px;
  $bp-mobile: 768px;
  $injury-remove-size: 20px;

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

    // Feature 5.5 — save status now uses AppSavePulse + sr-only text
    &__save-status {
      min-height: var(--space-5);
      display: flex;
      align-items: center;
      gap: var(--space-2);
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

    // ── Feature 5.3 — Conditions ──────────────────────────────────────────────

    &__conditions {
      display: flex;
      flex-wrap: wrap;
      gap: var(--space-2);
      padding-bottom: var(--space-3);
    }

    &__conditions-error {
      margin-top: var(--space-2);
    }

    &__injuries-divider {
      margin: var(--space-3) 0;
    }

    &__injuries-header {
      margin-bottom: var(--space-2);
    }

    &__injuries-title {
      font-family: var(--font-body);
      font-size: $font-size-eyebrow;
      letter-spacing: 0.14em;
      text-transform: uppercase;
      color: var(--state-crimson-bright);
    }

    &__injuries-list {
      list-style: none;
      margin: 0 0 var(--space-3);
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__injury-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: var(--space-1) var(--space-2);
      background-color: color-mix(in srgb, var(--state-crimson) 8%, transparent);
      border: 1px solid color-mix(in srgb, var(--state-crimson) 30%, transparent);
      border-radius: var(--radius-sm);
    }

    &__injury-name {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
      min-width: 0;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      flex: 1;
    }

    &__injury-remove {
      width: $injury-remove-size;
      height: $injury-remove-size;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      border: none;
      background: transparent;
      color: var(--state-crimson-bright);
      cursor: pointer;
      border-radius: var(--radius-sm);
      font-size: var(--type-body-md-font-size);
      line-height: 1;
      transition: background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        background-color: color-mix(in srgb, var(--state-crimson) 15%, transparent);
      }

      &:focus-visible {
        outline: 2px solid var(--state-crimson-bright);
        outline-offset: 2px;
      }
    }

    &__injuries-empty {
      margin: 0 0 var(--space-3);
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
    }

    &__injury-add-form {
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__injury-add-actions {
      display: flex;
      gap: var(--space-2);
      justify-content: flex-end;
    }

    &__injury-add-btn {
      align-self: flex-start;
    }

    // ── Feature 5.2 — Talents ─────────────────────────────────────────────────

    &__talent-error {
      margin-bottom: var(--space-3);
    }

    &__talents-list {
      list-style: none;
      margin: 0 0 var(--space-3);
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: 0;
    }

    &__talent-row {
      border-bottom: 1px solid color-mix(in srgb, var(--brand-brass-deep) 60%, transparent);

      &:last-child {
        border-bottom: none;
      }
    }

    &__talent-btn {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: var(--space-2);
      width: 100%;
      padding: var(--space-2) var(--space-1);
      background: transparent;
      border: none;
      cursor: pointer;
      text-align: left;
      transition: background-color var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        background-color: color-mix(in srgb, var(--brand-brass) 5%, transparent);
      }

      &:focus-visible {
        outline: 2px solid var(--brand-brass);
        outline-offset: 2px;
      }
    }

    &__talent-name {
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-primary);
      min-width: 0;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      flex: 1;
    }

    &__talent-chevron {
      font-size: var(--type-body-md-font-size);
      color: var(--brand-brass);
      flex-shrink: 0;
    }

    &__talent-add-btn {
      align-self: flex-start;
      margin-top: var(--space-1);
    }

    // ── Talent editor dialog overrides ────────────────────────────────────────

    &__talent-editor-error {
      margin-bottom: var(--space-3);
    }

    &__talent-fields {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
    }

    &__talent-field {
      display: flex;
      flex-direction: column;
      gap: var(--space-1);
    }

    &__talent-label {
      font-family: var(--font-body);
      font-size: $font-size-eyebrow;
      letter-spacing: 0.12em;
      text-transform: uppercase;
      color: var(--brand-brass);
    }

    &__talent-delete-link {
      background: transparent;
      border: none;
      padding: 0;
      cursor: pointer;
      font-family: var(--font-body);
      font-size: var(--type-body-sm-font-size);
      color: var(--state-crimson-bright);
      text-decoration: underline;
      transition: opacity var(--motion-duration-fast) var(--motion-ease-standard);

      &:hover {
        opacity: 0.7;
      }

      &:focus-visible {
        outline: 2px solid var(--state-crimson-bright);
        outline-offset: 2px;
      }
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

    // ── Tabs ─────────────────────────────────────────────────────────────────────

    &__tabs {
      display: flex;
      gap: 0;
      border-bottom: 1px solid var(--brand-brass-deep);
      padding-inline: var(--space-4);
      overflow-x: auto;
    }

    // ── Encumbrance warning banner ────────────────────────────────────────────

    &__enc-warning {
      // margin handled by gap in the page flex column
    }

    &__counter--enc-warn {
      .page-sheet__counter-label,
      .page-sheet__counter-value {
        color: var(--state-crimson-bright);
      }
    }

    // ── Equipped quick view ───────────────────────────────────────────────────

    &__equipped-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: var(--space-2);
    }

    &__equipped-row {
      display: flex;
      justify-content: space-between;
      align-items: baseline;
      gap: var(--space-2);
      padding-bottom: var(--space-2);
      border-bottom: 1px solid color-mix(in srgb, var(--brand-brass-deep) 60%, transparent);

      &:last-child {
        border-bottom: none;
        padding-bottom: 0;
      }
    }

    &__equipped-name {
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
      color: var(--text-primary);
    }

    &__equipped-summary {
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);
      white-space: nowrap;
    }

    // ── Gear tab ─────────────────────────────────────────────────────────────

    &__gear-tab {
      display: flex;
      flex-direction: column;
      gap: var(--space-5);
    }

    &__gear-header {
      display: flex;
      align-items: center;
      gap: var(--space-4);
      flex-wrap: wrap;
    }

    &__gear-enc {
      display: flex;
      align-items: center;
      gap: var(--space-2);
      font-family: var(--type-body-sm-font-family);
      font-size: var(--type-body-sm-font-size);
      color: var(--text-secondary);

      &--warn {
        color: var(--state-crimson-bright);
      }
    }

    &__gear-enc-label {
      text-transform: uppercase;
      letter-spacing: 0.12em;
      font-size: $font-size-eyebrow;
      color: inherit;
    }

    &__gear-enc-value {
      font-family: var(--type-mono-stat-md-font-family);
      font-size: var(--type-mono-stat-md-font-size);
    }

    &__gear-table-wrap {
      overflow-x: auto;
    }

    &__gear-table {
      width: 100%;
      border-collapse: collapse;
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
    }

    &__gear-th {
      text-align: left;
      padding: var(--space-2) var(--space-3);
      font-size: $font-size-eyebrow;
      font-weight: 500;
      letter-spacing: 0.14em;
      text-transform: uppercase;
      color: var(--brand-brass);
      border-bottom: 1px solid var(--brand-brass-deep);
      white-space: nowrap;

      &--name {
        width: 100%;
      }
    }

    &__gear-row {
      border-bottom: 1px solid color-mix(in srgb, var(--brand-brass-deep) 50%, transparent);

      &:last-child {
        border-bottom: none;
      }

      &:hover {
        background-color: color-mix(in srgb, var(--brand-brass) 4%, transparent);
      }
    }

    &__gear-td {
      padding: var(--space-2) var(--space-3);
      color: var(--text-primary);
      vertical-align: middle;

      &--name {
        font-weight: 500;
      }

      &--summary {
        color: var(--text-secondary);
        white-space: nowrap;
        font-size: var(--type-body-sm-font-size);
      }

      &--actions {
        white-space: nowrap;
      }
    }

    &__gear-empty {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-4);
      padding: var(--space-8);
      text-align: center;
    }

    &__gear-empty-text {
      margin: 0;
      color: var(--text-secondary);
      font-family: var(--type-body-md-font-family);
      font-size: var(--type-body-md-font-size);
    }

    // ── Other placeholder tabs ────────────────────────────────────────────────

    &__tab-placeholder {
      padding: var(--space-8);
      text-align: center;
    }

    // ── TalentEditor (AppModal variant) ──────────────────────────────────────

    &__talent-editor {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
    }

    // ── Dialogs ───────────────────────────────────────────────────────────────

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

      &--talent {
        max-width: $dialog-talent-max-width;
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

      &--talent {
        justify-content: space-between;
        align-items: center;
      }
    }

    &__dialog-actions-right {
      display: flex;
      gap: var(--space-3);
    }
  }

  // ── Utility ───────────────────────────────────────────────────────────────────

  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip-path: inset(50%);
    white-space: nowrap;
    border-width: 0;
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
