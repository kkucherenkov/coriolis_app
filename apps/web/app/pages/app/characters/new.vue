<script setup lang="ts">
  definePageMeta({ layout: 'app' });

  import { ref, computed, onMounted, onBeforeUnmount } from 'vue';
  import { useCharactersApi } from '~/composables/useCharactersApi';
  import { useAutoSave } from '~/composables/useAutoSave';
  import type { Character, CharacterUpdate } from '~/composables/useCharactersApi';
  import {
    findCatalogTalentById,
    type CrewTalentCatalogEntry,
    type PersonalTalentCatalogEntry,
    type StigmaTalentCatalogEntry,
  } from '@app/specs';
  import type {
    Attributes,
    Skills,
    IconId,
    Concept,
    Role,
    CrewConcept,
    MutantLineage,
    Upbringing,
  } from '@app/api-client-ts';
  import { rolesForConcept } from '~/utils/roleCatalogue';
  import WizardShell from '~/components/wizard/WizardShell.vue';
  import Step1Concept from '~/components/wizard/Step1Concept.vue';
  import Step2Background from '~/components/wizard/Step2Background.vue';
  import Step3Icon from '~/components/wizard/Step3Icon.vue';
  import Step4Attributes from '~/components/wizard/Step4Attributes.vue';
  import Step5Role from '~/components/wizard/Step5Role.vue';
  import Step6Skills from '~/components/wizard/Step6Skills.vue';
  import Step7Talents from '~/components/wizard/Step7Talents.vue';

  // TODO(wizard-step-7-relationships): Relationships step deferred to v1.1+.

  const { t } = useI18n({ useScope: 'local' });

  const api = useCharactersApi();
  const route = useRoute();
  const router = useRouter();

  // ── Constants ────────────────────────────────────────────────────────────────

  const TOTAL_STEPS = 7;

  const DEFAULT_ATTRS: Attributes = {
    strength: 2,
    agility: 2,
    wits: 2,
    empathy: 2,
  };

  const DEFAULT_SKILLS: Skills = {
    force: 0,
    meleeCombat: 0,
    dexterity: 0,
    infiltration: 0,
    rangedCombat: 0,
    observation: 0,
    survival: 0,
    manipulation: 0,
    command: 0,
    culture: 0,
    dataDjinn: 0,
    medicurgy: 0,
    mysticPowers: 0,
    pilot: 0,
    science: 0,
    technology: 0,
  };

  // ── State ────────────────────────────────────────────────────────────────────

  const step = ref<number>(1);
  const loading = ref<boolean>(true);
  const forging = ref<boolean>(false);
  const errorMsg = ref<string>('');

  // Draft character fields mirrored locally. Upbringing defaults to
  // 'stationary' (the balanced middle path per ST3001 ch.2 table 2.2 —
  // 14 attribute pts, 10 skill pts, 4 reputation, 1000 birrs); the user
  // can change it on Step 2 before forging.
  const DEFAULT_UPBRINGING: Upbringing = 'stationary';
  const draftId = ref<string>('');
  const draftName = ref<string>('Untitled');
  const draftConcept = ref<Concept | null>(null);
  const draftRole = ref<Role | null>(null);
  const draftOrigin = ref<string | null>(null);
  const draftUpbringing = ref<Upbringing>(DEFAULT_UPBRINGING);
  const draftCrewConcept = ref<CrewConcept | null>(null);
  const draftMutant = ref<boolean>(false);
  const draftMutantLineage = ref<MutantLineage | null>(null);
  const draftAge = ref<number | null>(null);
  const draftIconId = ref<IconId | null>(null);
  const draftAttributes = ref<Attributes>({ ...DEFAULT_ATTRS });
  const draftSkills = ref<Skills>({ ...DEFAULT_SKILLS });
  const draftPersonalTalentId = ref<string | null>(null);
  const draftCrewTalentId = ref<string | null>(null);
  const draftStigmaTalentId = ref<string | null>(null);

  // ── AutoSave ─────────────────────────────────────────────────────────────────

  async function persistDraft(): Promise<void> {
    if (!draftId.value) return;
    const body: CharacterUpdate = {
      name: draftName.value.trim() || 'Untitled',
      concept: draftConcept.value,
      role: draftRole.value,
      iconId: draftIconId.value,
      upbringing: draftUpbringing.value,
      origin: draftOrigin.value,
      crewConcept: draftCrewConcept.value,
      mutant: draftMutant.value,
      mutantLineage: draftMutantLineage.value,
      attributes: draftAttributes.value,
      skills: draftSkills.value,
    };
    await api.update(draftId.value, body);
  }

  const {
    schedule: scheduleSave,
    flush: flushSave,
    cancel: cancelSave,
  } = useAutoSave(persistDraft, { debounceMs: 600 });

  // ── Mount — resume or create draft ───────────────────────────────────────────

  onMounted(async () => {
    loading.value = true;
    errorMsg.value = '';

    try {
      const qId = route.query.id as string | undefined;

      if (qId) {
        // Resume existing draft
        const char = await api.get(qId);
        if (char.status !== 'draft') {
          // Draft was already forged — land on the sheet
          await navigateTo(`/app/characters/${qId}`);
          return;
        }
        hydrateDraft(char);
      } else {
        // Create a fresh draft. Upbringing is required server-side; we seed
        // with the wizard's DEFAULT_UPBRINGING and let the user pick on Step 2.
        const char = await api.create({
          name: 'Untitled',
          upbringing: DEFAULT_UPBRINGING,
          status: 'draft',
        });
        hydrateDraft(char);
        // Replace URL so refresh resumes without re-creating
        await router.replace({ query: { id: char.id } });
      }
    } catch {
      errorMsg.value = t('errorLoad');
    } finally {
      loading.value = false;
    }
  });

  onBeforeUnmount(() => {
    cancelSave();
  });

  function hydrateDraft(char: Character): void {
    draftId.value = char.id;
    draftName.value = char.name;
    draftConcept.value = char.concept ?? null;
    draftRole.value = char.role ?? null;
    draftIconId.value = char.iconId ?? null;
    draftUpbringing.value = char.upbringing;
    draftOrigin.value = char.origin ?? null;
    draftCrewConcept.value = char.crewConcept ?? null;
    draftMutant.value = char.mutant;
    draftMutantLineage.value = char.mutantLineage ?? null;
    draftAttributes.value = { ...char.attributes };
    draftSkills.value = { ...char.skills };
  }

  // ── Validation guards ─────────────────────────────────────────────────────────

  const step1Valid = computed<boolean>(() => {
    const n = draftName.value.trim();
    return n.length > 0 && n.length <= 80;
  });

  const canAdvance = computed<boolean>(() => {
    if (step.value === 1) return step1Valid.value;
    return true; // Steps 2–6 are fully optional at the data level
  });

  // ── Navigation ────────────────────────────────────────────────────────────────

  async function goNext(): Promise<void> {
    if (!canAdvance.value) return;
    await flushSave();
    if (step.value < TOTAL_STEPS) step.value++;
  }

  async function goBack(): Promise<void> {
    await flushSave();
    if (step.value > 1) step.value--;
  }

  async function saveAndExit(): Promise<void> {
    await flushSave();
    await navigateTo('/app/characters');
  }

  async function forge(): Promise<void> {
    if (forging.value) return;
    forging.value = true;
    errorMsg.value = '';
    try {
      cancelSave();
      // Final data sync + status transition in one PATCH. Upbringing is
      // immutable, so we don't include it here; it was set at draft create.
      await api.update(draftId.value, {
        name: draftName.value.trim() || 'Untitled',
        concept: draftConcept.value,
        role: draftRole.value,
        iconId: draftIconId.value,
        origin: draftOrigin.value,
        crewConcept: draftCrewConcept.value,
        mutant: draftMutant.value,
        mutantLineage: draftMutantLineage.value,
        attributes: draftAttributes.value,
        skills: draftSkills.value,
        status: 'active',
      });

      // Persist the player's picks (the iconGift is auto-seeded server-side).
      // We post one talent per pick, hydrating its name/description from the
      // shared catalog so backend rows carry the canonical EN fallback while
      // renderers resolve the locale via the catalog ID stored in `name`.
      await postPickedTalent(draftPersonalTalentId.value, 'personal');
      await postPickedTalent(draftCrewTalentId.value, 'crew');
      if (draftMutant.value) {
        await postPickedTalent(draftStigmaTalentId.value, 'stigma');
      }

      await navigateTo(`/app/characters/${draftId.value}`);
    } catch {
      errorMsg.value = t('errorForge');
      forging.value = false;
    }
  }

  async function postPickedTalent(
    id: string | null,
    kind: 'personal' | 'crew' | 'stigma',
  ): Promise<void> {
    if (!id) return;
    const entry = findCatalogTalentById(id);
    if (entry?.kind !== kind) return;
    const typed = entry as
      | PersonalTalentCatalogEntry
      | CrewTalentCatalogEntry
      | StigmaTalentCatalogEntry;
    await api.addTalent(draftId.value, {
      kind,
      name: typed.id,
      description: typed.description.en,
      rank: 1,
    });
  }

  // ── Field mutations — schedule auto-save on every change ─────────────────────

  function onNameUpdate(val: string): void {
    draftName.value = val;
    scheduleSave();
  }

  function onConceptUpdate(val: Concept | null): void {
    if (val !== draftConcept.value && draftRole.value !== null) {
      const allowed = rolesForConcept(val);
      if (!allowed.includes(draftRole.value)) draftRole.value = null;
    }
    draftConcept.value = val;
    scheduleSave();
  }

  function onRoleUpdate(val: Role | null): void {
    draftRole.value = val;
    scheduleSave();
  }

  function onOriginUpdate(val: string | null): void {
    draftOrigin.value = val;
    scheduleSave();
  }

  function onUpbringingUpdate(val: Upbringing): void {
    draftUpbringing.value = val;
    scheduleSave();
  }

  function onCrewConceptUpdate(val: CrewConcept | null): void {
    draftCrewConcept.value = val;
    scheduleSave();
  }

  function onAgeUpdate(val: number | null): void {
    draftAge.value = val;
    // Age is not in CharacterUpdate yet — stored locally only for v1.
  }

  function onIconUpdate(val: IconId | null): void {
    draftIconId.value = val;
    scheduleSave();
  }

  function onAttributesUpdate(val: Attributes): void {
    draftAttributes.value = val;
    scheduleSave();
  }

  function onSkillsUpdate(val: Skills): void {
    draftSkills.value = val;
    scheduleSave();
  }

  function onPersonalTalentUpdate(val: string | null): void {
    draftPersonalTalentId.value = val;
    // Picks are persisted at forge() time, not on every change.
  }

  function onCrewTalentUpdate(val: string | null): void {
    draftCrewTalentId.value = val;
    // Picks are persisted at forge() time, not on every change.
  }

  function onMutantUpdate(val: boolean): void {
    draftMutant.value = val;
    // Clearing the flag in Step1 must also clear any stigma the player
    // already picked — backend rejects stigma-on-non-mutant via
    // `STIGMA_REQUIRES_MUTANT`, and we don't want to retain a dangling
    // selection across toggles.
    if (!val) draftStigmaTalentId.value = null;
    scheduleSave();
  }

  function onMutantLineageUpdate(val: MutantLineage | null): void {
    draftMutantLineage.value = val;
    scheduleSave();
  }

  function onStigmaTalentUpdate(val: string | null): void {
    draftStigmaTalentId.value = val;
    // Picks are persisted at forge() time.
  }

  // ── Step metadata ─────────────────────────────────────────────────────────────

  const stepTitle = computed<string>(() => t(`step.${String(step.value)}.title`));
  const stepBlurb = computed<string>(() => t(`step.${String(step.value)}.blurb`));
  const stepLabel = computed<string>(() => t('wizardLabel'));
</script>

<i18n lang="json">
{
  "en": {
    "wizardLabel": "New Character",
    "saveExit": "Save & exit",
    "back": "Back",
    "next": "Next",
    "forge": "Forge character",
    "errorLoad": "Could not load the draft. Please try again.",
    "errorForge": "Could not forge the character. Please try again.",
    "step": {
      "1": {
        "title": "Your concept",
        "blurb": "Give your character a name and a short phrase that captures who they are at the table."
      },
      "2": {
        "title": "People & Background",
        "blurb": "Where did you come from? How were you raised among the stars?"
      },
      "3": {
        "title": "Choose your Icon",
        "blurb": "The Icons watch from beyond the dark water. One walks beside you. Choose, and they will hear your prayers."
      },
      "4": {
        "title": "Distribute your attributes",
        "blurb": "Spend the attribute points your upbringing grants. Each attribute is between 2 and 4."
      },
      "5": {
        "title": "Choose your role",
        "blurb": "Your role shapes who you are within your concept. It sets four key skills that define your specialty."
      },
      "6": {
        "title": "Train your skills",
        "blurb": "General skills you may use untrained. Advanced skills require at least one rank to attempt."
      },
      "7": {
        "title": "Choose your talents",
        "blurb": "Talents are habits forged in the dark between worlds. Pick up to three starting talents."
      }
    }
  },
  "ru": {
    "wizardLabel": "Новый персонаж",
    "saveExit": "Сохранить и выйти",
    "back": "Назад",
    "next": "Далее",
    "forge": "Создать персонажа",
    "errorLoad": "Не удалось загрузить черновик. Попробуйте ещё раз.",
    "errorForge": "Не удалось создать персонажа. Попробуйте ещё раз.",
    "step": {
      "1": {
        "title": "Концепт персонажа",
        "blurb": "Дайте персонажу имя и короткую фразу, отражающую его роль за столом."
      },
      "2": {
        "title": "Люди и происхождение",
        "blurb": "Откуда вы? Как вы выросли среди звёзд Третьего горизонта?"
      },
      "3": {
        "title": "Выберите свою Икону",
        "blurb": "Иконы наблюдают из-за тёмных вод. Одна идёт рядом с вами. Выберите — и она услышит ваши молитвы."
      },
      "4": {
        "title": "Распределите атрибуты",
        "blurb": "Потратьте очки атрибутов, которые даёт ваше воспитание. Значение каждого — от 2 до 4."
      },
      "5": {
        "title": "Выберите роль",
        "blurb": "Роль определяет ваше место внутри амплуа и задаёт четыре ключевых навыка специализации."
      },
      "6": {
        "title": "Развейте навыки",
        "blurb": "Общие навыки можно использовать без тренировки. Для продвинутых нужен хотя бы один ранг."
      },
      "7": {
        "title": "Выберите таланты",
        "blurb": "Таланты — привычки, выкованные в тёмном пространстве между мирами. Возьмите до трёх начальных талантов."
      }
    }
  },
  "uk": {
    "wizardLabel": "[uk-todo] New Character",
    "saveExit": "[uk-todo] Save & exit",
    "back": "[uk-todo] Back",
    "next": "[uk-todo] Next",
    "forge": "[uk-todo] Forge character",
    "errorLoad": "[uk-todo] Could not load the draft.",
    "errorForge": "[uk-todo] Could not forge the character.",
    "step": {
      "1": { "title": "[uk-todo] Your concept", "blurb": "[uk-todo] Name your character." },
      "2": { "title": "[uk-todo] People & Background", "blurb": "[uk-todo] Where are you from?" },
      "3": { "title": "[uk-todo] Choose your Icon", "blurb": "[uk-todo] Pick an Icon." },
      "4": { "title": "[uk-todo] Distribute attributes", "blurb": "[uk-todo] 13 points." },
      "5": {
        "title": "[uk-todo] Choose your role",
        "blurb": "[uk-todo] Pick a role for your concept."
      },
      "6": { "title": "[uk-todo] Train your skills", "blurb": "[uk-todo] Spend skill points." },
      "7": { "title": "[uk-todo] Choose talents", "blurb": "[uk-todo] Pick up to 3 talents." }
    }
  },
  "el": {
    "wizardLabel": "[el-todo] New Character",
    "saveExit": "[el-todo] Save & exit",
    "back": "[el-todo] Back",
    "next": "[el-todo] Next",
    "forge": "[el-todo] Forge character",
    "errorLoad": "[el-todo] Could not load the draft.",
    "errorForge": "[el-todo] Could not forge the character.",
    "step": {
      "1": { "title": "[el-todo] Your concept", "blurb": "[el-todo] Name your character." },
      "2": { "title": "[el-todo] People & Background", "blurb": "[el-todo] Where are you from?" },
      "3": { "title": "[el-todo] Choose your Icon", "blurb": "[el-todo] Pick an Icon." },
      "4": { "title": "[el-todo] Distribute attributes", "blurb": "[el-todo] 13 points." },
      "5": {
        "title": "[el-todo] Choose your role",
        "blurb": "[el-todo] Pick a role for your concept."
      },
      "6": { "title": "[el-todo] Train your skills", "blurb": "[el-todo] Spend skill points." },
      "7": { "title": "[el-todo] Choose talents", "blurb": "[el-todo] Pick up to 3 talents." }
    }
  }
}
</i18n>

<template>
  <div class="page-wizard">
    <div v-if="loading" class="page-wizard__loader" role="status" aria-live="polite" />

    <div v-else-if="errorMsg" class="page-wizard__error" role="alert">
      {{ errorMsg }}
    </div>

    <WizardShell
      v-else
      :step="step"
      :total-steps="TOTAL_STEPS"
      :step-label="stepLabel"
      :title="stepTitle"
      :blurb="stepBlurb"
      :is-first-step="step === 1"
      :is-last-step="step === TOTAL_STEPS"
      :can-advance="canAdvance"
      :forging="forging"
      :save-exit-label="t('saveExit')"
      :back-label="t('back')"
      :next-label="t('next')"
      :forge-label="t('forge')"
      @back="goBack"
      @next="goNext"
      @forge="forge"
      @save-exit="saveAndExit"
    >
      <Step1Concept
        v-if="step === 1"
        :name="draftName"
        :concept="draftConcept"
        :mutant="draftMutant"
        :mutant-lineage="draftMutantLineage"
        @update:name="onNameUpdate"
        @update:concept="onConceptUpdate"
        @update:mutant="onMutantUpdate"
        @update:mutant-lineage="onMutantLineageUpdate"
      />

      <Step2Background
        v-if="step === 2"
        :origin="draftOrigin"
        :upbringing="draftUpbringing"
        :crew-concept="draftCrewConcept"
        :age="draftAge"
        @update:origin="onOriginUpdate"
        @update:upbringing="onUpbringingUpdate"
        @update:crew-concept="onCrewConceptUpdate"
        @update:age="onAgeUpdate"
      />

      <Step3Icon v-if="step === 3" :icon-id="draftIconId" @update:icon-id="onIconUpdate" />

      <Step4Attributes
        v-if="step === 4"
        :attributes="draftAttributes"
        :upbringing="draftUpbringing"
        :concept="draftConcept"
        @update:attributes="onAttributesUpdate"
      />

      <Step5Role
        v-if="step === 5"
        :concept="draftConcept"
        :role="draftRole"
        @update:role="onRoleUpdate"
      />

      <Step6Skills
        v-if="step === 6"
        :skills="draftSkills"
        :upbringing="draftUpbringing"
        :concept="draftConcept"
        :role="draftRole"
        @update:skills="onSkillsUpdate"
      />

      <Step7Talents
        v-if="step === 7"
        :personal-talent-id="draftPersonalTalentId"
        :crew-talent-id="draftCrewTalentId"
        :stigma-talent-id="draftStigmaTalentId"
        :icon-id="draftIconId"
        :concept="draftConcept"
        :crew-concept="draftCrewConcept"
        :mutant="draftMutant"
        @update:personal-talent-id="onPersonalTalentUpdate"
        @update:crew-talent-id="onCrewTalentUpdate"
        @update:stigma-talent-id="onStigmaTalentUpdate"
      />
    </WizardShell>
  </div>
</template>

<style lang="scss" scoped>
  // Named SCSS variables for pixel dimensions and durations — permitted escape hatch.
  $spinner-size: 40px;
  $spinner-spin-duration: 800ms;
  $spinner-slow-duration: 2000ms;

  .page-wizard {
    min-height: 100vh;

    &__loader {
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      // Spinner via CSS-only ring — no inline style, token-derived.
      &::after {
        content: '';
        display: block;
        width: $spinner-size;
        height: $spinner-size;
        border-radius: var(--radius-pill);
        border: 3px solid var(--brand-brass-deep);
        border-top-color: var(--brand-brass);
        animation: wizard-spin $spinner-spin-duration linear infinite;

        @media (prefers-reduced-motion: reduce) {
          animation-duration: $spinner-slow-duration;
        }
      }
    }

    &__error {
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      padding: var(--space-8);
      font-family: var(--font-body);
      font-size: var(--type-body-md-font-size);
      color: var(--state-crimson);
      text-align: center;
    }
  }

  @keyframes wizard-spin {
    to {
      transform: rotate(360deg);
    }
  }
</style>
