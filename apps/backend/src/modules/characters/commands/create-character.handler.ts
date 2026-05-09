import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import {
  AttributeOutOfRangeError,
  CharacterNameEmptyError,
  CharacterNameTooLongError,
  IconUnknownError,
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

function validateAttributes(attrs: Attributes): void {
  for (const [key, val] of Object.entries(attrs) as [string, number][]) {
    if (val < 1 || val > 5) {
      throw new AttributeOutOfRangeError(key, val);
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
export class CreateCharacterHandler
  implements ICommandHandler<CreateCharacterCommand, CharacterReadModel>
{
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

    const attributes = { ...DEFAULT_ATTRIBUTES, ...dto.attributes };
    const skills = { ...DEFAULT_SKILLS, ...dto.skills };
    const conditions: ConditionFlags = { ...DEFAULT_CONDITIONS, ...dto.conditions };

    validateAttributes(attributes);
    validateSkills(skills);

    const status: CharacterStatus = dto.status ?? 'active';

    const character = await this.repo.create({
      ownerId,
      name: dto.name.trim(),
      concept: dto.concept ?? null,
      iconId: dto.iconId ?? null,
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
