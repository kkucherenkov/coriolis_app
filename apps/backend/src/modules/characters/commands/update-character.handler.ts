import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import {
  AttributeOutOfRangeError,
  CharacterNameEmptyError,
  CharacterNameTooLongError,
  CharacterNotFoundError,
  CharacterNotOwnedError,
  IconUnknownError,
  SkillOutOfRangeError,
} from '../domain/character.errors';
import {
  Attributes,
  CHARACTER_REPO,
  CharacterReadModel,
  IconId,
  Skills,
} from '../domain/character.ports';
import { CharacterUpdatedEvent } from '../events/character-updated.event';

import { UpdateCharacterCommand } from './update-character.command';

import type { ICharacterRepo } from '../domain/character.ports';

const VALID_ICONS: readonly IconId[] = [
  'lady-of-tears',
  'traveler',
  'messenger',
  'merchant',
  'dancer',
  'gambler',
  'judge',
  'faceless-one',
  'deckhand',
];

function validateAttributes(attrs: Attributes): void {
  for (const [key, val] of Object.entries(attrs)) {
    if (val < 1 || val > 5) {
      throw new AttributeOutOfRangeError(key, val);
    }
  }
}

function validateSkills(skills: Skills): void {
  for (const [key, val] of Object.entries(skills)) {
    if (val < 0 || val > 5) {
      throw new SkillOutOfRangeError(key, val);
    }
  }
}

@CommandHandler(UpdateCharacterCommand)
export class UpdateCharacterHandler
  implements ICommandHandler<UpdateCharacterCommand, CharacterReadModel>
{
  constructor(
    @Inject(CHARACTER_REPO) private readonly repo: ICharacterRepo,
    private readonly eventBus: EventBus,
  ) {}

  async execute(command: UpdateCharacterCommand): Promise<CharacterReadModel> {
    const { characterId, ownerId, dto } = command;

    const existing = await this.repo.findActiveById(characterId);
    if (!existing) throw new CharacterNotFoundError(characterId);
    if (existing.ownerId !== ownerId) throw new CharacterNotOwnedError(characterId);

    // Defence-in-depth validation
    if (dto.name !== undefined) {
      if (!dto.name || dto.name.trim() === '') throw new CharacterNameEmptyError();
      if (dto.name.length > 80) throw new CharacterNameTooLongError();
    }

    if (dto.iconId && !VALID_ICONS.includes(dto.iconId)) {
      throw new IconUnknownError(dto.iconId);
    }

    if (dto.attributes) validateAttributes(dto.attributes);
    if (dto.skills) validateSkills(dto.skills);

    const criticalInjuries = dto.criticalInjuries?.map((inj) => ({
      name: inj.name,
      severity: inj.severity,
      effect: inj.effect,
      acquiredAt: inj.acquiredAt ?? new Date().toISOString(),
    }));

    const updated = await this.repo.update(characterId, {
      ...(dto.name !== undefined ? { name: dto.name.trim() } : {}),
      ...(dto.concept !== undefined ? { concept: dto.concept } : {}),
      ...(dto.iconId !== undefined ? { iconId: dto.iconId } : {}),
      ...(dto.attributes ? { attributes: dto.attributes } : {}),
      ...(dto.skills ? { skills: dto.skills } : {}),
      ...(dto.hp?.current !== undefined ? { hpCurrent: dto.hp.current } : {}),
      ...(dto.mp?.current !== undefined ? { mpCurrent: dto.mp.current } : {}),
      ...(dto.experience !== undefined ? { experience: dto.experience } : {}),
      ...(dto.conditions ? { conditions: dto.conditions } : {}),
      ...(criticalInjuries ? { criticalInjuries } : {}),
      ...(dto.notes !== undefined ? { notes: dto.notes } : {}),
    });

    this.eventBus.publish(new CharacterUpdatedEvent(updated.id, updated.ownerId));

    return updated;
  }
}
