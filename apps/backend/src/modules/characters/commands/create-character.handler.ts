import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { UPBRINGING_BUDGETS, sumAttributes, sumSkills } from '../../rules-engine';
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
// (the amplua's key attribute may reach 5 — Block 2 introduces that exception).
const CREATION_ATTR_MIN = 2;
const CREATION_ATTR_MAX = 4;

function validateAttributesAtCreation(attrs: Attributes): void {
  for (const [key, val] of Object.entries(attrs) as [string, number][]) {
    if (val < 1 || val > 5) {
      throw new AttributeOutOfRangeError(key, val);
    }
    if (val < CREATION_ATTR_MIN || val > CREATION_ATTR_MAX) {
      throw new AttributeOutOfCreationRangeError(key, val);
    }
  }
}

function validateSkills(skills: Skills): void {
  for (const [key, val] of Object.entries(skills) as [string, number][]) {
    if (val < 0 || val > 5) {
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

    const attributes = { ...DEFAULT_ATTRIBUTES, ...dto.attributes };
    const skills = { ...DEFAULT_SKILLS, ...dto.skills };
    const conditions: ConditionFlags = { ...DEFAULT_CONDITIONS, ...dto.conditions };

    validateAttributesAtCreation(attributes);
    validateSkills(skills);

    const attributeTotal = sumAttributes(attributes);
    if (attributeTotal > budget.attributes) {
      throw new AttributeBudgetExceededError(attributeTotal, budget.attributes, upbringing);
    }

    const skillTotal = sumSkills(skills);
    if (skillTotal > budget.skills) {
      throw new SkillBudgetExceededError(skillTotal, budget.skills, upbringing);
    }

    const status: CharacterStatus = dto.status ?? 'active';

    const character = await this.repo.create({
      ownerId,
      name: dto.name.trim(),
      concept: dto.concept ?? null,
      iconId: dto.iconId ?? null,
      upbringing,
      origin: dto.origin ?? null,
      reputation: budget.reputation,
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
