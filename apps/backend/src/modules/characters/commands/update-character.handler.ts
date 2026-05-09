import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { UPBRINGING_BUDGETS } from '../../rules-engine';
import {
  AttributeOutOfRangeError,
  CharacterNameEmptyError,
  CharacterNameTooLongError,
  CharacterNotFoundError,
  CharacterNotOwnedError,
  IconUnknownError,
  InvalidStatusTransitionError,
  ReadOnlyFieldError,
  SkillOutOfRangeError,
  UpbringingImmutableError,
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

@CommandHandler(UpdateCharacterCommand)
export class UpdateCharacterHandler implements ICommandHandler<
  UpdateCharacterCommand,
  CharacterReadModel
> {
  constructor(
    @Inject(CHARACTER_REPO) private readonly repo: ICharacterRepo,
    private readonly eventBus: EventBus,
  ) {}

  async execute(command: UpdateCharacterCommand): Promise<CharacterReadModel> {
    const { characterId, ownerId, dto } = command;

    // Belt-and-suspenders: reject attempts to set server-computed read-only
    // derived fields. The OpenAPI spec marks them readOnly:true, but
    // express-openapi-validator may not strip extra nested keys in all versions.
    // PRD §5.2 — hp.max, mp.max, encumbrance.max are always server-computed.
    const rawDto = dto as Record<string, unknown>;
    const rawHp = rawDto['hp'] as Record<string, unknown> | undefined;
    const rawMp = rawDto['mp'] as Record<string, unknown> | undefined;
    const rawEncumbrance = rawDto['encumbrance'] as Record<string, unknown> | undefined;
    if (rawHp && 'max' in rawHp) throw new ReadOnlyFieldError('hp.max');
    if (rawMp && 'max' in rawMp) throw new ReadOnlyFieldError('mp.max');
    if (rawEncumbrance && 'max' in rawEncumbrance) throw new ReadOnlyFieldError('encumbrance.max');
    if (rawEncumbrance && 'current' in rawEncumbrance)
      throw new ReadOnlyFieldError('encumbrance.current');
    // startingWealth is derived from upbringing and frozen at creation.
    if ('startingWealth' in rawDto) throw new ReadOnlyFieldError('startingWealth');

    const existing = await this.repo.findActiveById(characterId);
    if (!existing) throw new CharacterNotFoundError(characterId);
    if (existing.ownerId !== ownerId) throw new CharacterNotOwnedError(characterId);

    // Status-transition guard (ADR 0002): only draft → active is permitted.
    // active → draft is rejected; active → active and draft → draft are no-ops.
    if (
      dto.status !== undefined &&
      dto.status !== existing.status &&
      existing.status === 'active' &&
      dto.status === 'draft'
    ) {
      throw new InvalidStatusTransitionError(existing.status, dto.status);
    }
    // draft → active: allowed — fall through to repo.update

    // Defence-in-depth validation
    if (dto.name !== undefined) {
      if (!dto.name || dto.name.trim() === '') throw new CharacterNameEmptyError();
      if (dto.name.length > 80) throw new CharacterNameTooLongError();
    }

    if (dto.iconId && !VALID_ICONS.has(dto.iconId)) {
      throw new IconUnknownError(dto.iconId);
    }

    if (dto.attributes) validateAttributes(dto.attributes);
    if (dto.skills) validateSkills(dto.skills);

    // Upbringing is mutable while the character is a draft (the wizard) and
    // immutable once forged. Changing it during the draft also resets the
    // derived reputation baseline so the wizard reflects the new budget;
    // startingWealth is left untouched once set.
    let upbringingChange:
      | { upbringing: typeof existing.upbringing; reputation: number }
      | undefined;
    if (dto.upbringing !== undefined && dto.upbringing !== existing.upbringing) {
      if (existing.status !== 'draft') throw new UpbringingImmutableError();
      const baseline = UPBRINGING_BUDGETS[dto.upbringing];
      upbringingChange = {
        upbringing: dto.upbringing,
        reputation: dto.reputation ?? baseline.reputation,
      };
    }

    const criticalInjuries = dto.criticalInjuries?.map((inj) => ({
      name: inj.name,
      severity: inj.severity,
      effect: inj.effect,
      acquiredAt: inj.acquiredAt ?? new Date().toISOString(),
    }));

    const updated = await this.repo.update(characterId, {
      ...(dto.name === undefined ? {} : { name: dto.name.trim() }),
      ...(dto.concept === undefined ? {} : { concept: dto.concept }),
      ...(dto.iconId === undefined ? {} : { iconId: dto.iconId }),
      ...upbringingChange,
      ...(dto.origin === undefined ? {} : { origin: dto.origin }),
      ...(dto.reputation === undefined || upbringingChange ? {} : { reputation: dto.reputation }),
      ...(dto.attributes ? { attributes: dto.attributes } : {}),
      ...(dto.skills ? { skills: dto.skills } : {}),
      ...(dto.hp?.current === undefined ? {} : { hpCurrent: dto.hp.current }),
      ...(dto.mp?.current === undefined ? {} : { mpCurrent: dto.mp.current }),
      ...(dto.experience === undefined ? {} : { experience: dto.experience }),
      ...(dto.conditions ? { conditions: dto.conditions } : {}),
      ...(criticalInjuries ? { criticalInjuries } : {}),
      ...(dto.notes === undefined ? {} : { notes: dto.notes }),
      ...(dto.status === undefined ? {} : { status: dto.status }),
    });

    this.eventBus.publish(new CharacterUpdatedEvent(updated.id, updated.ownerId));

    return updated;
  }
}
