import { Inject } from '@nestjs/common';
import { CommandHandler, EventBus, ICommandHandler } from '@nestjs/cqrs';

import { CONCEPT_BY_ROLE, CONCEPT_KEYS, UPBRINGING_BUDGETS } from '../../rules-engine';
import type { Role } from '../../rules-engine';
import {
  AttributeOutOfRangeError,
  CharacterNameEmptyError,
  CharacterNameTooLongError,
  CharacterNotFoundError,
  CharacterNotOwnedError,
  ConceptImmutableError,
  CrewConceptImmutableError,
  IconUnknownError,
  InvalidStatusTransitionError,
  MutantImmutableError,
  MutantLineageForbiddenError,
  MutantLineageRequiredError,
  ReadOnlyFieldError,
  RoleConceptMismatchError,
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
    if (val < 2 || val > 5) {
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

    // Upbringing and concept are mutable only while status === draft. Any
    // change to either recomputes the reputation baseline:
    //   reputation = upbringingBudget.reputation + concept.modifier (or 0)
    // clamped at 0 so a -2 modifier on a 2-rep plebeian doesn't go negative.
    if (
      dto.upbringing !== undefined &&
      dto.upbringing !== existing.upbringing &&
      existing.status !== 'draft'
    )
      throw new UpbringingImmutableError();
    const conceptChanging = dto.concept !== undefined && dto.concept !== existing.concept;
    if (conceptChanging && existing.status !== 'draft') {
      throw new ConceptImmutableError();
    }
    const crewConceptChanging =
      dto.crewConcept !== undefined && dto.crewConcept !== existing.crewConcept;
    if (crewConceptChanging && existing.status !== 'draft') {
      throw new CrewConceptImmutableError();
    }

    // Role validation: if a role is provided, ensure it belongs to the current
    // (or incoming, if concept is also changing) concept.
    // dto.role is an arbitrary string from the wire; cast defensively and guard
    // against unknown values that aren't in CONCEPT_BY_ROLE at runtime.
    if (dto.role !== undefined && dto.role !== null) {
      const role = dto.role as Role;
      const effectiveConcept = conceptChanging ? (dto.concept ?? null) : existing.concept;
      const roleConcept = (CONCEPT_BY_ROLE as Record<string, string | undefined>)[role];
      if (!roleConcept || roleConcept !== effectiveConcept) {
        throw new RoleConceptMismatchError(role, effectiveConcept ?? '(none)');
      }
    }

    // Mutant flag + lineage are mutable only while draft (mirrors crewConcept).
    // The two fields must remain consistent: mutant=true requires a lineage,
    // mutant=false forbids one. We compute the post-update pair and validate.
    const mutantChanging = dto.mutant !== undefined && dto.mutant !== existing.mutant;
    const lineageChanging =
      dto.mutantLineage !== undefined && dto.mutantLineage !== existing.mutantLineage;
    if ((mutantChanging || lineageChanging) && existing.status !== 'draft') {
      throw new MutantImmutableError();
    }
    if (mutantChanging || lineageChanging) {
      const nextMutant = dto.mutant ?? existing.mutant;
      const nextLineage =
        dto.mutantLineage === undefined ? existing.mutantLineage : dto.mutantLineage;
      if (nextMutant && !nextLineage) throw new MutantLineageRequiredError();
      if (!nextMutant && nextLineage) throw new MutantLineageForbiddenError();
    }

    let derivedReputation: number | undefined;
    if (
      (dto.upbringing !== undefined && dto.upbringing !== existing.upbringing) ||
      conceptChanging
    ) {
      const upbringing = dto.upbringing ?? existing.upbringing;
      const concept = conceptChanging ? (dto.concept ?? null) : existing.concept;
      const baseline = UPBRINGING_BUDGETS[upbringing].reputation;
      const modifier = concept ? CONCEPT_KEYS[concept].reputationModifier : 0;
      derivedReputation = Math.max(0, baseline + modifier);
    }

    const criticalInjuries = dto.criticalInjuries?.map((inj) => ({
      name: inj.name,
      severity: inj.severity,
      effect: inj.effect,
      acquiredAt: inj.acquiredAt ?? new Date().toISOString(),
    }));

    // When the user explicitly sets a role, clear the roleUnmigrated flag.
    const roleUpdate: Record<string, unknown> = {};
    if (dto.role !== undefined) {
      roleUpdate['role'] = dto.role;
      if (dto.role !== null) {
        roleUpdate['roleUnmigrated'] = false;
      }
    }

    const updated = await this.repo.update(characterId, {
      ...(dto.name === undefined ? {} : { name: dto.name.trim() }),
      ...(dto.concept === undefined ? {} : { concept: dto.concept }),
      ...roleUpdate,
      ...(dto.iconId === undefined ? {} : { iconId: dto.iconId }),
      ...(dto.upbringing === undefined ? {} : { upbringing: dto.upbringing }),
      ...(dto.origin === undefined ? {} : { origin: dto.origin }),
      ...(dto.crewConcept === undefined ? {} : { crewConcept: dto.crewConcept }),
      ...(dto.mutant === undefined ? {} : { mutant: dto.mutant }),
      ...(dto.mutantLineage === undefined ? {} : { mutantLineage: dto.mutantLineage }),
      ...(derivedReputation === undefined
        ? dto.reputation === undefined
          ? {}
          : { reputation: dto.reputation }
        : { reputation: derivedReputation }),
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
