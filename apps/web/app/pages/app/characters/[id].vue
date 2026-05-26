<script setup lang="ts">
  definePageMeta({ layout: 'app' });

  import {
    AppCard,
    AppButton,
    AppInput,
    AppTextarea,
    AppStatBlock,
    AppDotInput,
    AppModal,
    AppConfirm,
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
  import type {
    Attributes,
    Skills,
    ConditionFlags,
    CriticalInjury,
    Role,
  } from '@app/api-client-ts';
  import { useTalentLocalization } from '~/composables/useTalentLocalization';
  import { useAutoSave } from '~/composables/useAutoSave';
  import type { SaveState } from '~/composables/useAutoSave';
  import { useDebounceFn } from '~/composables/useDebounceFn';
  import SheetDiceRoller from '~/components/sheet/SheetDiceRoller.vue';
  import SheetRollHistory from '~/components/sheet/SheetRollHistory.vue';
  import type { Roll } from '~/composables/useRollsApi';
  import RoleUnmigratedBanner from '~/components/RoleUnmigratedBanner.vue';

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

  // Surfaces a rollback after a failed attribute / skill / HP / MP save so the
  // value never snaps back silently (critique P0). Cleared on the next attempt
  // and on any successful mutation.
  const statError = ref('');

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

  // Roving-tabindex arrow-key navigation across the enabled tabs, per the
  // WAI-ARIA tabs pattern. Disabled tabs ([disabled]) are skipped. No per-tab
  // refs needed: we query the live tablist DOM and move focus + activation.
  function onTabKeydown(event: KeyboardEvent): void {
    const navKeys = ['ArrowRight', 'ArrowLeft', 'Home', 'End'];
    if (!navKeys.includes(event.key)) return;
    const container = event.currentTarget as HTMLElement;
    const tabs = [...container.querySelectorAll<HTMLButtonElement>('[role="tab"]:not([disabled])')];
    if (tabs.length === 0) return;
    const current = tabs.indexOf(document.activeElement as HTMLButtonElement);
    let nextIndex = current;
    switch (event.key) {
      case 'ArrowRight': {
        nextIndex = (current + 1) % tabs.length;
        break;
      }
      case 'ArrowLeft': {
        nextIndex = (current - 1 + tabs.length) % tabs.length;
        break;
      }
      case 'Home': {
        nextIndex = 0;
        break;
      }
      case 'End': {
        {
          nextIndex = tabs.length - 1;
          // No default
        }
        break;
      }
    }
    event.preventDefault();
    const nextTab = tabs[nextIndex];
    nextTab?.focus();
    nextTab?.click();
  }

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
    if (item.type === 'CYBERNETIC') return `${String(item.xpCost)} XP`;
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

  // ── Auto-save: name + concept ────────────────────────────────────────────────

  const {
    saveState: _saveState,
    saveError,
    schedule: scheduleIdentitySave,
    flush: flushIdentitySave,
  } = useAutoSave(
    async () => {
      if (!character.value) return;
      const trimmedName = nameValue.value.trim();
      // Nothing to persist if the name is empty or unchanged. The unchanged
      // guard keeps the unmount flush() cheap (no redundant PATCH).
      if (!trimmedName || trimmedName === character.value.name) return;
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
    // Flush (not cancel) so a rename typed right before navigating away is
    // committed instead of discarded (critique minor). The persist callback
    // no-ops when the name is unchanged, so this is cheap when nothing is
    // pending.
    void flushIdentitySave();
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

  // ── Attribute inline edit (click-the-dot via AppDotInput) ─────────────────────

  // Each change updates the local copy immediately (optimistic) and schedules a
  // debounced PATCH, so holding an arrow key or rapid dot clicks coalesce into
  // one request carrying the final value. On failure the local copy rolls back
  // to the last known server truth and the statError banner surfaces it.
  const { debouncedFn: scheduleAttrSave } = useDebounceFn(() => {
    void persistAttributes();
  }, 350);

  async function persistAttributes(): Promise<void> {
    if (!character.value) return;
    statError.value = '';
    try {
      const updated = await api.update(characterId.value, {
        attributes: { ...localAttributes.value },
      });
      character.value = updated;
      localAttributes.value = { ...updated.attributes };
      localHpCurrent.value = updated.hp.current;
      localMpCurrent.value = updated.mp.current;
    } catch (error) {
      // Roll back to the last known server truth (guaranteed non-null by the
      // early return above) and surface the failure.
      localAttributes.value = { ...character.value.attributes };
      statError.value =
        (error as Problem).detail ?? t('errorStatSave', { label: t('panelAttributes') });
    }
  }

  function setAttr(key: AttrKey, value: number): void {
    localAttributes.value = { ...localAttributes.value, [key]: value };
    scheduleAttrSave();
  }

  // ── Skill inline edit (click-the-dot via AppDotInput) ──────────────────────────

  const { debouncedFn: scheduleSkillSave } = useDebounceFn(() => {
    void persistSkills();
  }, 350);

  async function persistSkills(): Promise<void> {
    if (!character.value) return;
    statError.value = '';
    try {
      const updated = await api.update(characterId.value, {
        skills: { ...localSkills.value },
      });
      character.value = updated;
      localSkills.value = { ...updated.skills };
    } catch (error) {
      localSkills.value = { ...character.value.skills };
      statError.value =
        (error as Problem).detail ?? t('errorStatSave', { label: t('panelSkills') });
    }
  }

  function setSkill(key: SkillKey, value: number): void {
    localSkills.value = { ...localSkills.value, [key]: value };
    scheduleSkillSave();
  }

  // ── HP / MP counter ────────────────────────────────────────────────────────────

  async function adjustHp(delta: number): Promise<void> {
    if (!character.value) return;
    const max = character.value.hp.max;
    const prev = localHpCurrent.value;
    const next = Math.max(0, Math.min(max, prev + delta));
    if (next === prev) return;
    localHpCurrent.value = next;
    statError.value = '';
    try {
      const updated = await api.update(characterId.value, {
        hp: { current: next },
      });
      character.value = updated;
      localHpCurrent.value = updated.hp.current;
    } catch (error) {
      localHpCurrent.value = prev;
      statError.value = (error as Problem).detail ?? t('errorStatSave', { label: t('labelHp') });
    }
  }

  async function adjustMp(delta: number): Promise<void> {
    if (!character.value) return;
    const max = character.value.mp.max;
    const prev = localMpCurrent.value;
    const next = Math.max(0, Math.min(max, prev + delta));
    if (next === prev) return;
    localMpCurrent.value = next;
    statError.value = '';
    try {
      const updated = await api.update(characterId.value, {
        mp: { current: next },
      });
      character.value = updated;
      localMpCurrent.value = updated.mp.current;
    } catch (error) {
      localMpCurrent.value = prev;
      statError.value = (error as Problem).detail ?? t('errorStatSave', { label: t('labelMp') });
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
    // Guard against a double-submit (Enter held / button spammed) spawning
    // multiple optimistic temp entries before the first response lands.
    if (addInjurySaving.value) return;
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

  // Critical-injury removal is guarded by a confirm (parity with talent delete)
  // so a stray click on the small × can't silently drop tracked game state.
  const injuryDeleteConfirmOpen = ref(false);
  const injuryDeletePending = ref<CriticalInjury | null>(null);
  const injuryDeleting = ref(false);
  const injuryDeleteName = computed(() => injuryDeletePending.value?.name ?? '');

  function removeInjuryConfirm(injury: CriticalInjury): void {
    injuryDeletePending.value = injury;
    injuryDeleteConfirmOpen.value = true;
  }

  async function onConfirmRemoveInjury(): Promise<void> {
    const injury = injuryDeletePending.value;
    if (!injury) {
      injuryDeleteConfirmOpen.value = false;
      return;
    }
    injuryDeleting.value = true;
    try {
      await removeInjury(injury.id);
    } finally {
      injuryDeleting.value = false;
      injuryDeleteConfirmOpen.value = false;
      injuryDeletePending.value = null;
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

  // Two-step talent delete. The "Remove" button in the talent editor opens
  // the AppConfirm; the real removeTalent call fires from onConfirmDeleteTalent.
  const talentDeleteConfirmOpen = ref(false);
  const talentDeletePending = ref<Talent | null>(null);
  const talentDeleting = ref(false);

  const talentDeleteName = computed(() =>
    talentDeletePending.value ? displayTalentName(talentDeletePending.value) : '',
  );

  function deleteTalentConfirm(talent: Talent): void {
    talentDeletePending.value = talent;
    talentDeleteConfirmOpen.value = true;
  }

  async function onConfirmDeleteTalent(): Promise<void> {
    const talent = talentDeletePending.value;
    if (!talent) {
      talentDeleteConfirmOpen.value = false;
      return;
    }
    talentDeleting.value = true;
    talentEditorError.value = '';
    try {
      await talentsApi.removeTalent(talent.id);
      localTalents.value = localTalents.value.filter((tt) => tt.id !== talent.id);
      closeTalentEditor();
    } catch (error) {
      const problem = error as Problem;
      talentEditorError.value = problem.detail ?? t('errorTalentDelete');
    } finally {
      talentDeleting.value = false;
      talentDeleteConfirmOpen.value = false;
      talentDeletePending.value = null;
    }
  }

  // ── Delete ──────────────────────────────────────────────────────────────────────

  function openDeleteDialog(): void {
    deleteDialogOpen.value = true;
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

  // ── Role migration banner ──────────────────────────────────────────────────

  function onRoleConfirmed(role: Role): void {
    if (!character.value) return;
    character.value = { ...character.value, role, roleUnmigrated: false };
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
    "errorStatSave": "Couldn't save {label}. Your change was reverted.",
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
    "hpHelp": "Hit Points",
    "mpHelp": "Mind Points",
    "encHelp": "Encumbrance",
    "labelDecrease": "Decrease",
    "labelIncrease": "Increase",
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
    "injuryRemoveConfirmTitle": "Remove this injury?",
    "injuryRemoveConfirm": "Remove \"{name}\"? This can't be undone.",
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
    "talentDeleteConfirmTitle": "Remove this talent?",
    "talentDeleteConfirm": "Remove talent \"{name}\"? This cannot be undone.",
    "noTalents": "No talents yet. Add one to track your character's edges.",
    "errorTalentSave": "Failed to save talent.",
    "errorTalentDelete": "Failed to remove talent.",
    "tabStats": "Stats",
    "tabGear": "Gear",
    "tabTalents": "Talents",
    "tabNotes": "Notes",
    "tabShare": "Share",
    "tabSoon": "soon",
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
    "errorStatSave": "Не удалось сохранить «{label}». Изменение отменено.",
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
    "hpHelp": "Очки здоровья",
    "mpHelp": "Очки разума",
    "encHelp": "Грузоподъёмность",
    "labelDecrease": "Уменьшить",
    "labelIncrease": "Увеличить",
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
    "injuryRemoveConfirmTitle": "Удалить ранение?",
    "injuryRemoveConfirm": "Удалить «{name}»? Это необратимо.",
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
    "talentDeleteConfirmTitle": "Удалить талант?",
    "talentDeleteConfirm": "Удалить талант «{name}»? Это необратимо.",
    "noTalents": "Нет талантов. Добавьте, чтобы фиксировать сильные стороны персонажа.",
    "errorTalentSave": "Не удалось сохранить талант.",
    "errorTalentDelete": "Не удалось удалить талант.",
    "tabStats": "Статы",
    "tabGear": "Снаряжение",
    "tabTalents": "Таланты",
    "tabNotes": "Заметки",
    "tabShare": "Поделиться",
    "tabSoon": "скоро",
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
          <div class="page-sheet__save-status" aria-live="polite" aria-atomic="true">
            <AppSavePulse :state="saveState" />
            <!-- sr-only accessible label for screen readers -->
            <span class="sr-only">
              <template v-if="saveState === 'saving'">{{ t('statusSaving') }}</template>
              <template v-else-if="saveState === 'saved'">{{ t('statusSaved') }}</template>
              <template v-else-if="saveState === 'error'"
                >{{ t('statusError') }}: {{ saveError }}</template
              >
            </span>
          </div>
        </div>

        <!-- HP / MP / ENC counters -->
        <div class="page-sheet__counters">
          <!-- HP -->
          <div class="page-sheet__counter">
            <span class="page-sheet__counter-label" :title="t('hpHelp')">{{ t('labelHp') }}</span>
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
            <span class="page-sheet__counter-label" :title="t('mpHelp')">{{ t('labelMp') }}</span>
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
            <span class="page-sheet__counter-label" :title="t('encHelp')">{{ t('labelEnc') }}</span>
            <div class="page-sheet__counter-value">
              {{ character.encumbrance.current
              }}<span class="page-sheet__counter-max"> / {{ character.encumbrance.max }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- ── Stat save-failure banner (critique P0) ─────────────────────────── -->
      <AppBanner v-if="statError" tone="danger" class="page-sheet__stat-error" role="alert">
        {{ statError }}
      </AppBanner>

      <!-- ── Role migration banner ──────────────────────────────────────────── -->
      <RoleUnmigratedBanner
        :character-id="characterId"
        :concept="character.concept ?? null"
        :role="character.role ?? null"
        :role-unmigrated="character.roleUnmigrated ?? false"
        @role-confirmed="onRoleConfirmed"
      />

      <!-- ── Encumbrance warning banner ─────────────────────────────────────── -->
      <AppBanner v-if="isEncumbered" tone="danger" class="page-sheet__enc-warning" role="status">
        {{ t('encWarning') }}
      </AppBanner>

      <!-- ── Tab bar ──────────────────────────────────────────────────────────── -->
      <div class="page-sheet__tabs" role="tablist" @keydown="onTabKeydown">
        <AppTab
          id="sheet-tab-stats"
          :active="activeTab === 'stats'"
          size="md"
          tone="brass"
          aria-controls="sheet-panel-stats"
          @click="activeTab = 'stats'"
        >
          {{ t('tabStats') }}
        </AppTab>
        <AppTab
          id="sheet-tab-gear"
          :active="activeTab === 'gear'"
          size="md"
          tone="brass"
          aria-controls="sheet-panel-gear"
          @click="activeTab = 'gear'"
        >
          {{ t('tabGear') }}
        </AppTab>
        <!-- Talents / Notes / Share are roadmap surfaces — disabled with a "soon"
             marker so they don't read as live destinations (critique P1). -->
        <AppTab disabled size="md" tone="brass">
          {{ t('tabTalents') }}
          <span class="page-sheet__tab-soon">{{ t('tabSoon') }}</span>
        </AppTab>
        <AppTab disabled size="md" tone="brass">
          {{ t('tabNotes') }}
          <span class="page-sheet__tab-soon">{{ t('tabSoon') }}</span>
        </AppTab>
        <AppTab disabled size="md" tone="brass">
          {{ t('tabShare') }}
          <span class="page-sheet__tab-soon">{{ t('tabSoon') }}</span>
        </AppTab>
      </div>

      <!-- ── Three-column body (Stats tab) ─────────────────────────────────────── -->
      <div
        v-show="activeTab === 'stats'"
        id="sheet-panel-stats"
        class="page-sheet__columns"
        role="tabpanel"
        aria-labelledby="sheet-tab-stats"
        tabindex="0"
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
            <AppBanner v-if="conditionsError" tone="danger" class="page-sheet__conditions-error">
              {{ conditionsError }}
            </AppBanner>

            <!-- Critical injuries sub-section -->
            <AppDivider tone="brass-deep" class="page-sheet__injuries-divider" />
            <div class="page-sheet__injuries-header">
              <span class="page-sheet__injuries-title">{{ t('panelCriticalInjuries') }}</span>
            </div>

            <AppBanner v-if="injuriesError" tone="danger" class="page-sheet__conditions-error">
              {{ injuriesError }}
            </AppBanner>

            <!-- Injuries list -->
            <ul v-if="localInjuries.length > 0" class="page-sheet__injuries-list">
              <li v-for="injury in localInjuries" :key="injury.id" class="page-sheet__injury-row">
                <span class="page-sheet__injury-name">{{ injury.name }}</span>
                <button
                  class="page-sheet__injury-remove"
                  :aria-label="t('injuryRemoveLabel')"
                  @click="removeInjuryConfirm(injury)"
                >
                  ×
                </button>
              </li>
            </ul>
            <p v-else class="page-sheet__injuries-empty">
              {{ t('noInjuries') }}
            </p>

            <!-- Inline add injury -->
            <div v-if="addInjuryActive" class="page-sheet__injury-add-form">
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
                <AppButton variant="ghost" size="sm" @click="cancelAddInjury">
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
              <!-- Click-the-dot editing: AppStatBlock editable renders an
                   interactive AppDotInput (min 1 for attributes). -->
              <AppStatBlock
                v-for="key in ATTR_KEYS"
                :key="key"
                editable
                :label="attrLabel(key)"
                :value="localAttributes[key]"
                :min="1"
                :max="5"
                size="md"
                tone="brass"
                @update:value="setAttr(key, $event)"
              />
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
                <div v-for="sk in GENERAL_SKILLS" :key="sk" class="page-sheet__skill-row">
                  <span class="page-sheet__skill-name">{{ skillLabel(sk) }}</span>
                  <span class="page-sheet__skill-attr">{{ SKILL_GOVERNING_ATTR[sk] }}</span>
                  <AppDotInput
                    :model-value="localSkills[sk]"
                    :min="0"
                    :max="5"
                    size="sm"
                    tone="brass"
                    :label="skillLabel(sk)"
                    @update:model-value="setSkill(sk, $event)"
                  />
                </div>
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
                <div
                  v-for="sk in ADVANCED_SKILLS"
                  :key="sk"
                  class="page-sheet__skill-row page-sheet__skill-row--advanced"
                >
                  <span
                    class="page-sheet__skill-accent-rail"
                    :class="localSkills[sk] > 0 ? 'page-sheet__skill-accent-rail--active' : ''"
                    aria-hidden="true"
                  />
                  <span class="page-sheet__skill-name">{{ skillLabel(sk) }}</span>
                  <span class="page-sheet__skill-attr page-sheet__skill-attr--advanced">{{
                    SKILL_GOVERNING_ATTR[sk]
                  }}</span>
                  <AppDotInput
                    :model-value="localSkills[sk]"
                    :min="0"
                    :max="5"
                    size="sm"
                    tone="mystic"
                    :label="skillLabel(sk)"
                    @update:model-value="setSkill(sk, $event)"
                  />
                </div>
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
            <ul v-if="equippedItems.length > 0" class="page-sheet__equipped-list">
              <li v-for="item in equippedItems" :key="item.id" class="page-sheet__equipped-row">
                <span class="page-sheet__equipped-name">{{ item.name }}</span>
                <span class="page-sheet__equipped-summary">{{ itemSummary(item) }}</span>
              </li>
            </ul>
            <p v-else class="page-sheet__placeholder-text">
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
            <ul v-if="localTalents.length > 0" class="page-sheet__talents-list">
              <li v-for="talent in localTalents" :key="talent.id" class="page-sheet__talent-row">
                <button class="page-sheet__talent-btn" @click="openEditTalent(talent)">
                  <span class="page-sheet__talent-name">{{ displayTalentName(talent) }}</span>
                  <span class="page-sheet__talent-chevron" aria-hidden="true">›</span>
                </button>
              </li>
            </ul>
            <p v-else class="page-sheet__placeholder-text">
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
            <SheetRollHistory ref="rollHistoryRef" :character-id="characterId" />
          </AppCard>
        </div>
      </div>

      <!-- ── Gear tab ────────────────────────────────────────────────────────── -->
      <div
        v-show="activeTab === 'gear'"
        id="sheet-panel-gear"
        class="page-sheet__gear-tab"
        role="tabpanel"
        aria-labelledby="sheet-tab-gear"
        tabindex="0"
      >
        <!-- Top action row -->
        <div class="page-sheet__gear-header">
          <AppButton variant="primary" size="sm" @click="openCreateItem">
            + {{ t('gearAddButton') }}
          </AppButton>
          <!-- Encumbrance summary -->
          <div class="page-sheet__gear-enc" :class="{ 'page-sheet__gear-enc--warn': isEncumbered }">
            <span class="page-sheet__gear-enc-label">{{ t('labelEnc') }}</span>
            <span class="page-sheet__gear-enc-value">
              {{ character.encumbrance.current }} / {{ character.encumbrance.max }}
            </span>
            <AppBadge v-if="isEncumbered" variant="crimson" size="sm">
              {{ t('encWarning') }}
            </AppBadge>
          </div>
        </div>

        <!-- Inventory table -->
        <div v-if="localInventory.length > 0" class="page-sheet__gear-table-wrap">
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
              <tr v-for="item in localInventory" :key="item.id" class="page-sheet__gear-row">
                <td class="page-sheet__gear-td">
                  <AppBadge :variant="itemTypeBadgeVariant(item.type)" size="sm">
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
                  <AppButton variant="ghost" size="sm" @click="openEditItem(item)">
                    {{ t('itemEditBtn') }}
                  </AppButton>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Empty state -->
        <AppCard v-else class="page-sheet__gear-empty">
          <p class="page-sheet__gear-empty-text">
            {{ t('gearEmpty') }}
          </p>
          <AppButton variant="primary" size="sm" @click="openCreateItem">
            + {{ t('gearAddButton') }}
          </AppButton>
        </AppCard>
      </div>

      <!-- ── Danger zone ─────────────────────────────────────────────────────── -->
      <div class="page-sheet__danger-zone">
        <AppButton variant="danger" size="sm" @click="openDeleteDialog">
          {{ t('deleteButton') }}
        </AppButton>
      </div>
    </template>

    <!-- ── Delete confirmation (focus-trapping AppModal via AppConfirm) ────────── -->
    <AppConfirm
      v-model:open="deleteDialogOpen"
      tone="danger"
      :title="t('deleteConfirmHeading')"
      :body="t('deleteConfirmBody')"
      :confirm-label="t('deleteConfirmYes')"
      :cancel-label="t('deleteConfirmNo')"
      :loading="deleteLoading"
      @confirm="confirmDelete"
    />

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

        <AppBanner v-if="talentEditorError" tone="danger" class="page-sheet__talent-editor-error">
          {{ talentEditorError }}
        </AppBanner>

        <div class="page-sheet__talent-fields">
          <div class="page-sheet__talent-field">
            <label class="page-sheet__talent-label" :for="'talent-name'">
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
            <label class="page-sheet__talent-label" :for="'talent-desc'">
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
          <AppButton variant="ghost" size="md" @click="closeTalentEditor">
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

    <!-- ── Talent delete confirm (used by the talent editor footer) ───────── -->
    <AppConfirm
      v-model:open="talentDeleteConfirmOpen"
      tone="danger"
      :title="t('talentDeleteConfirmTitle')"
      :body="t('talentDeleteConfirm', { name: talentDeleteName })"
      :confirm-label="t('talentDelete')"
      :cancel-label="t('talentCancel')"
      :loading="talentDeleting"
      @confirm="onConfirmDeleteTalent"
    />

    <!-- ── Critical-injury removal confirm (critique P2) ────────────────────── -->
    <AppConfirm
      v-model:open="injuryDeleteConfirmOpen"
      tone="danger"
      :title="t('injuryRemoveConfirmTitle')"
      :body="t('injuryRemoveConfirm', { name: injuryDeleteName })"
      :confirm-label="t('injuryRemoveLabel')"
      :cancel-label="t('injuryAddCancel')"
      :loading="injuryDeleting"
      @confirm="onConfirmRemoveInjury"
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
  $stepper-btn-size: 32px;
  $counter-min-width: 90px;
  // Fractional units (not %): percentages summing to 100% + 24px gaps overflowed
  // the grid container by 48px on desktop. fr distributes after gap accounting.
  $col-left-fr: 28fr;
  $col-center-fr: 44fr;
  $col-right-fr: 28fr;
  $font-size-eyebrow: 11px;
  $font-size-legend: 10px;
  $font-size-micro: 9px;
  $legend-dot-size: 8px;
  $accent-rail-offset: 6px;
  $bp-desktop: 1024px;
  $bp-mobile: 768px;
  $injury-remove-size: 32px;

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
      // minmax(0, 1fr) on identity column lets long names ellipsis instead of
      // forcing the hero wider than the page-sheet track.
      grid-template-columns: $portrait-size minmax(0, 1fr) auto;
      gap: var(--space-6);
      align-items: center;
      padding: $hero-padding-v $hero-padding-h;
      background: linear-gradient(180deg, var(--surface-night) 0%, var(--surface-void) 100%);
      border: 1px solid var(--brand-brass-deep);
      border-radius: var(--radius-md);
      min-width: 0;

      @media (max-width: #{$bp-mobile - 1px}) {
        grid-template-columns: $portrait-size-mobile minmax(0, 1fr);
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
      // minmax(0, …) lets tracks shrink below their content's intrinsic
      // min-width, preventing a long token / non-wrapping row inside any
      // panel from forcing horizontal page overflow on narrow viewports.
      grid-template-columns:
        minmax(0, $col-left-fr) minmax(0, $col-center-fr)
        minmax(0, $col-right-fr);
      gap: $column-gap;
      min-width: 0;

      @media (max-width: #{$bp-desktop - 1px}) {
        grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
      }

      @media (max-width: #{$bp-mobile - 1px}) {
        grid-template-columns: minmax(0, 1fr);
      }
    }

    &__col {
      display: flex;
      flex-direction: column;
      gap: var(--space-5);
      // Allow column to shrink below its content's intrinsic width so a wide
      // panel never forces the parent grid track to overflow the viewport.
      min-width: 0;

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
        // min() prevents overflow when the track is narrower than 200px
        min-width: min(200px, 100%);
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
      grid-template-columns: repeat(4, minmax(0, 1fr));
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
      grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
      gap: var(--space-6);

      @media (max-width: #{$bp-mobile - 1px}) {
        grid-template-columns: minmax(0, 1fr);
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
      font-size: $font-size-legend;
      opacity: 0.85;
      letter-spacing: 0.12em;
    }

    // ── Skill row ─────────────────────────────────────────────────────────────

    // The row is a static container now; the AppDotInput it holds owns focus
    // and interaction. No row-level cursor/hover/focus.
    &__skill-row {
      display: grid;
      grid-template-columns: 1fr auto auto;
      align-items: center;
      gap: var(--space-2);
      padding: var(--space-1) var(--space-1);
      border-bottom: 1px solid color-mix(in srgb, var(--brand-brass-deep) 60%, transparent);

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

    // "soon" marker on roadmap (disabled) tabs.
    &__tab-soon {
      margin-left: var(--space-1);
      font-size: $font-size-micro;
      letter-spacing: 0.12em;
      text-transform: lowercase;
      color: var(--brand-brass);
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

    // ── TalentEditor (AppModal variant) ──────────────────────────────────────

    &__talent-editor {
      display: flex;
      flex-direction: column;
      gap: var(--space-4);
    }

    // ── Dialogs ───────────────────────────────────────────────────────────────

    // Heading shared by the talent editor (AppModal). The delete + injury-remove
    // confirms now use AppConfirm, which renders its own chrome.
    &__dialog-heading {
      margin: 0;
      font-family: var(--font-display);
      font-size: var(--type-display-sm-font-size);
      line-height: var(--type-display-sm-line-height);
      color: var(--brand-brass-light);
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
