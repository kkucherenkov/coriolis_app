import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';
import { getIconGiftByIconId } from '@app/specs';

import {
  CONCEPT_BY_ROLE,
  CONCEPT_KEYS,
  UPBRINGING_BUDGETS,
  getRoleKeySkills,
  sumAttributes,
  sumSkills,
} from '../../rules-engine';
import type { AttributeKey, Role, SkillKey } from '../../rules-engine';
import {
  AttributeBudgetExceededError,
  AttributeOutOfCreationRangeError,
  AttributeOutOfRangeError,
  CharacterNameEmptyError,
  CharacterNameTooLongError,
  IconUnknownError,
  MutantLineageForbiddenError,
  MutantLineageRequiredError,
  RoleConceptMismatchError,
  SkillBudgetExceededError,
  SkillOutOfRangeError,
} from '../domain/character.errors';
import {
  Attributes,
  CHARACTER_REPO,
  CharacterReadModel,
  Concept,
  ConditionFlags,
  CrewConcept,
  DEFAULT_ATTRIBUTES,
  DEFAULT_CONDITIONS,
  DEFAULT_SKILLS,
  IconId,
  MutantLineage,
  Skills,
  Upbringing,
} from '../domain/character.ports';
import type { CharacterStatus, TalentKind } from '../domain/character.ports';
import { CharacterUpdatedEvent } from '../events/character-updated.event';

import { CreateCharacterCommand } from './create-character.command';

import type { ICharacterRepo } from '../domain/character.ports';

const VALID_ICONS = new Set<IconId>([
  'lady-of-tears',
  'traveler',
  'messenger',
  'merchant',
  'dancer',
  'gambler',
  'judge',
  'faceless-one',
  'deckhand',
]);

const VALID_UPBRINGINGS = new Set<Upbringing>(['plebeian', 'stationary', 'aristocrat']);

const VALID_CREW_CONCEPTS = new Set<CrewConcept>([
  'free-trader',
  'mercenary',
  'explorer',
  'agents',
  'pilgrim',
]);

const VALID_MUTANT_LINEAGES = new Set<MutantLineage>(['zirba', 'shingura', 'nerida']);

// Per Coriolis core book ch.2: at creation each attribute is between 2 and 4
// (the amplua's key attribute may reach 5 — concept-aware exception).
const CREATION_ATTR_MIN = 2;
const CREATION_ATTR_NONKEY_MAX = 4;
const CREATION_ATTR_KEY_MAX = 5;
const CREATION_SKILL_NONKEY_MAX = 1;
const CREATION_SKILL_KEY_MAX = 3;

function validateAttributesAtCreation(attrs: Attributes, concept: Concept | null): void {
  const keyAttribute = concept ? CONCEPT_KEYS[concept].keyAttribute : null;
  for (const [key, val] of Object.entries(attrs) as [AttributeKey, number][]) {
    if (val < 2 || val > 5) {
      throw new AttributeOutOfRangeError(key, val);
    }
    const max = key === keyAttribute ? CREATION_ATTR_KEY_MAX : CREATION_ATTR_NONKEY_MAX;
    if (val < CREATION_ATTR_MIN || val > max) {
      throw new AttributeOutOfCreationRangeError(key, val);
    }
  }
}

function validateSkillsAtCreation(
  skills: Skills,
  concept: Concept | null,
  role: Role | null,
): void {
  // When a role is provided, use the exact 4 key skills for that role.
  // When only a concept is provided (no role yet), use the union of all
  // three roles' key skills from CONCEPT_KEYS (preserves legacy behaviour).
  const keySet: ReadonlySet<SkillKey> = role
    ? new Set(getRoleKeySkills(role))
    : new Set(concept ? CONCEPT_KEYS[concept].keySkills : []);

  for (const [key, val] of Object.entries(skills) as [SkillKey, number][]) {
    if (val < 0 || val > 5) {
      throw new SkillOutOfRangeError(key, val);
    }
    const max = keySet.has(key) ? CREATION_SKILL_KEY_MAX : CREATION_SKILL_NONKEY_MAX;
    if (val > max) {
      throw new SkillOutOfRangeError(key, val);
    }
  }
}

@CommandHandler(CreateCharacterCommand)
export class CreateCharacterHandler implements ICommandHandler<
  CreateCharacterCommand,
  CharacterReadModel
> {
  constructor(
    @Inject(CHARACTER_REPO) private readonly repo: ICharacterRepo,
    private readonly eventBus: EventBus,
  ) {}

  async execute(command: CreateCharacterCommand): Promise<CharacterReadModel> {
    const { ownerId, dto } = command;

    // Defence-in-depth — DTO already validated by the ValidationPipe
    if (!dto.name || dto.name.trim() === '') throw new CharacterNameEmptyError();
    if (dto.name.length > 80) throw new CharacterNameTooLongError();

    if (dto.iconId && !VALID_ICONS.has(dto.iconId)) {
      throw new IconUnknownError(dto.iconId);
    }

    if (!VALID_UPBRINGINGS.has(dto.upbringing)) {
      // ValidationPipe should reject this; defence-in-depth.
      throw new AttributeOutOfRangeError('upbringing', 0);
    }
    const upbringing = dto.upbringing;
    const budget = UPBRINGING_BUDGETS[upbringing];
    const concept = dto.concept ?? null;
    const conceptKeys = concept ? CONCEPT_KEYS[concept] : null;

    // Role validation: if a role is provided, ensure it belongs to the concept.
    // dto.role is an arbitrary string from the wire; cast defensively and guard
    // against unknown values that aren't in CONCEPT_BY_ROLE at runtime.
    const role: Role | null = (dto.role ?? null) as Role | null;
    if (role !== null) {
      const roleConcept = (CONCEPT_BY_ROLE as Record<string, string | undefined>)[role];
      if (!roleConcept || roleConcept !== concept) {
        throw new RoleConceptMismatchError(role, concept ?? '(none)');
      }
    }

    const crewConcept = dto.crewConcept ?? null;
    if (crewConcept && !VALID_CREW_CONCEPTS.has(crewConcept)) {
      // ValidationPipe should reject this; defence-in-depth.
      throw new AttributeOutOfRangeError('crewConcept', 0);
    }

    const mutant = dto.mutant ?? false;
    const mutantLineage = dto.mutantLineage ?? null;
    if (mutantLineage && !VALID_MUTANT_LINEAGES.has(mutantLineage)) {
      // ValidationPipe should reject this; defence-in-depth.
      throw new AttributeOutOfRangeError('mutantLineage', 0);
    }
    if (mutant && !mutantLineage) {
      throw new MutantLineageRequiredError();
    }
    if (!mutant && mutantLineage) {
      throw new MutantLineageForbiddenError();
    }

    const attributes = { ...DEFAULT_ATTRIBUTES, ...dto.attributes };
    const skills = { ...DEFAULT_SKILLS, ...dto.skills };
    const conditions: ConditionFlags = { ...DEFAULT_CONDITIONS, ...dto.conditions };

    validateAttributesAtCreation(attributes, concept);
    validateSkillsAtCreation(skills, concept, role);

    const attributeTotal = sumAttributes(attributes);
    if (attributeTotal > budget.attributes) {
      throw new AttributeBudgetExceededError(attributeTotal, budget.attributes, upbringing);
    }

    const skillTotal = sumSkills(skills);
    if (skillTotal > budget.skills) {
      throw new SkillBudgetExceededError(skillTotal, budget.skills, upbringing);
    }

    const status: CharacterStatus = dto.status ?? 'active';
    // Reputation = upbringing baseline + concept modifier, clamped at 0 so
    // a -2 modifier on a 2-rep plebeian doesn't go negative.
    const reputation = Math.max(0, budget.reputation + (conceptKeys?.reputationModifier ?? 0));

    // iconGift talent is auto-derived from the chosen icon (one gift per icon
    // per Coriolis ch.4). The talent record stores the catalog ID in `name`
    // (renderers resolve it to the localized name + description via the
    // `@app/specs` catalog) and falls back to the canonical English description
    // for non-catalog consumers.
    const seedTalents: { kind: TalentKind; name: string; description: string; rank?: number }[] =
      [];
    if (dto.iconId) {
      const gift = getIconGiftByIconId(dto.iconId);
      seedTalents.push({
        kind: 'iconGift',
        name: gift.id,
        description: gift.description.en,
        rank: 1,
      });
    }

    const character = await this.repo.create({
      ownerId,
      name: dto.name.trim(),
      concept,
      role,
      roleUnmigrated: false,
      iconId: dto.iconId ?? null,
      upbringing,
      origin: dto.origin ?? null,
      reputation,
      startingWealth: budget.startingWealth,
      // Wallet starts in lockstep with the historical record. While the
      // character is a draft, every upbringing change re-derives both
      // `startingWealth` and `birr` (see UpdateCharacterHandler) so the
      // wallet is never stale; on the draft → active forge transition,
      // birr stays at this seeded value and becomes mutable.
      birr: budget.startingWealth,
      crewConcept,
      mutant,
      mutantLineage,
      attributes,
      skills,
      hpCurrent: dto.hp?.current ?? 14,
      mpCurrent: dto.mp?.current ?? 10,
      experience: dto.experience ?? 0,
      conditions,
      notes: dto.notes ?? null,
      talents: seedTalents,
      status,
    });

    this.eventBus.publish(new CharacterUpdatedEvent(character.id, character.ownerId));

    return character;
  }
}
