import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { CONCEPT_KEYS, UPBRINGING_BUDGETS, sumAttributes, sumSkills } from '../../rules-engine';
import type { AttributeKey, SkillKey } from '../../rules-engine';
import {
  AttributeBudgetExceededError,
  AttributeOutOfCreationRangeError,
  AttributeOutOfRangeError,
  CharacterNameEmptyError,
  CharacterNameTooLongError,
  IconUnknownError,
  SkillBudgetExceededError,
  SkillOutOfRangeError,
} from '../domain/character.errors';
import {
  Attributes,
  CHARACTER_REPO,
  CharacterReadModel,
  Concept,
  ConditionFlags,
  DEFAULT_ATTRIBUTES,
  DEFAULT_CONDITIONS,
  DEFAULT_SKILLS,
  IconId,
  Skills,
  Upbringing,
} from '../domain/character.ports';
import type { CharacterStatus } from '../domain/character.ports';
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
    if (val < 1 || val > 5) {
      throw new AttributeOutOfRangeError(key, val);
    }
    const max = key === keyAttribute ? CREATION_ATTR_KEY_MAX : CREATION_ATTR_NONKEY_MAX;
    if (val < CREATION_ATTR_MIN || val > max) {
      throw new AttributeOutOfCreationRangeError(key, val);
    }
  }
}

function validateSkillsAtCreation(skills: Skills, concept: Concept | null): void {
  const keySet: ReadonlySet<SkillKey> = new Set(concept ? CONCEPT_KEYS[concept].keySkills : []);
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

    const attributes = { ...DEFAULT_ATTRIBUTES, ...dto.attributes };
    const skills = { ...DEFAULT_SKILLS, ...dto.skills };
    const conditions: ConditionFlags = { ...DEFAULT_CONDITIONS, ...dto.conditions };

    validateAttributesAtCreation(attributes, concept);
    validateSkillsAtCreation(skills, concept);

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

    const character = await this.repo.create({
      ownerId,
      name: dto.name.trim(),
      concept,
      iconId: dto.iconId ?? null,
      upbringing,
      origin: dto.origin ?? null,
      reputation,
      startingWealth: budget.startingWealth,
      attributes,
      skills,
      hpCurrent: dto.hp?.current ?? 14,
      mpCurrent: dto.mp?.current ?? 10,
      experience: dto.experience ?? 0,
      conditions,
      notes: dto.notes ?? null,
      status,
    });

    this.eventBus.publish(new CharacterUpdatedEvent(character.id, character.ownerId));

    return character;
  }
}
