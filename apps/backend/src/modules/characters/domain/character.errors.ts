/**
 * WHY this file exists:
 * Domain errors are the sole mechanism for signalling business rule violations
 * in the characters bounded context. HttpExceptionFilter maps them to RFC 9457
 * application/problem+json. Clients key off `code` for i18n and retry logic.
 */
import { DomainError } from '../../../common/errors/domain-error';

export class CharacterNotFoundError extends DomainError {
  constructor(id: string) {
    super({
      code: 'CHARACTER_NOT_FOUND',
      status: 404,
      title: 'Character not found',
      detail: `We could not locate character ${id} — it may have set out for the Far Quarter without telling us.`,
    });
  }
}

export class CharacterNotOwnedError extends DomainError {
  constructor(id: string) {
    super({
      code: 'CHARACTER_NOT_OWNED',
      status: 403,
      title: 'Forbidden',
      detail: `Character ${id} does not belong to your crew. Access denied.`,
    });
  }
}

export class CharacterNameEmptyError extends DomainError {
  constructor() {
    super({
      code: 'CHARACTER_NAME_EMPTY',
      status: 400,
      title: 'Validation Error',
      detail: 'Every Companion needs a name — provide between 1 and 80 characters.',
    });
  }
}

export class CharacterNameTooLongError extends DomainError {
  constructor() {
    super({
      code: 'CHARACTER_NAME_TOO_LONG',
      status: 400,
      title: 'Validation Error',
      detail: 'That name is too long for the manifest — keep it to 80 characters or fewer.',
    });
  }
}

export class AttributeOutOfRangeError extends DomainError {
  constructor(attribute: string, value: number) {
    super({
      code: 'ATTRIBUTE_OUT_OF_RANGE',
      status: 422,
      title: 'Validation Error',
      detail: `Attribute '${attribute}' value ${String(value)} falls outside the permitted range (2–5). Check the character rules.`,
    });
  }
}

export class SkillOutOfRangeError extends DomainError {
  constructor(skill: string, value: number) {
    super({
      code: 'SKILL_OUT_OF_RANGE',
      status: 422,
      title: 'Validation Error',
      detail: `Skill '${skill}' value ${String(value)} is not within the permitted range (0–5).`,
    });
  }
}

export class IconUnknownError extends DomainError {
  constructor(iconId: string) {
    super({
      code: 'ICON_UNKNOWN',
      status: 400,
      title: 'Validation Error',
      detail: `'${iconId}' is not one of the Nine Icons recognised in the Third Horizon.`,
    });
  }
}

/**
 * Thrown at character creation when a single attribute is outside the 2..4
 * creation range from Coriolis core book ch.2 ("распределить ... 2..4 пунктов").
 * Block 2 will introduce a per-amplua exception that lifts the cap to 5 for
 * the key attribute.
 */
export class AttributeOutOfCreationRangeError extends DomainError {
  constructor(attribute: string, value: number) {
    super({
      code: 'ATTRIBUTE_OUT_OF_CREATION_RANGE',
      status: 400,
      title: 'Validation Error',
      detail: `Attribute '${attribute}' value ${String(value)} is outside the 2–4 creation range.`,
    });
  }
}

/**
 * Thrown when sum(attributes) exceeds the budget allowed by the chosen
 * upbringing (Coriolis core book ch.2, table 2.2: 15 / 14 / 13 for
 * plebeian / stationary / aristocrat).
 */
export class AttributeBudgetExceededError extends DomainError {
  constructor(spent: number, budget: number, upbringing: string) {
    super({
      code: 'ATTRIBUTE_BUDGET_EXCEEDED',
      status: 400,
      title: 'Validation Error',
      detail: `Attribute total ${String(spent)} exceeds the budget of ${String(budget)} for ${upbringing} upbringing.`,
    });
  }
}

/**
 * Thrown when sum(skills) exceeds the budget allowed by the chosen
 * upbringing (Coriolis core book ch.2, table 2.4: 8 / 10 / 12 for
 * plebeian / stationary / aristocrat).
 */
export class SkillBudgetExceededError extends DomainError {
  constructor(spent: number, budget: number, upbringing: string) {
    super({
      code: 'SKILL_BUDGET_EXCEEDED',
      status: 400,
      title: 'Validation Error',
      detail: `Skill total ${String(spent)} exceeds the budget of ${String(budget)} for ${upbringing} upbringing.`,
    });
  }
}

/**
 * Thrown when an active character's upbringing is changed. Upbringing is
 * malleable while the character is a draft (the wizard) but locks once
 * forged.
 */
export class UpbringingImmutableError extends DomainError {
  constructor() {
    super({
      code: 'UPBRINGING_IMMUTABLE',
      status: 422,
      title: 'Validation Error',
      detail: 'Upbringing cannot be changed once the character has been forged.',
    });
  }
}

/**
 * Thrown when an active character's concept (амплуа) is changed.
 * Mutable while draft; immutable once the character is forged.
 */
export class ConceptImmutableError extends DomainError {
  constructor() {
    super({
      code: 'CONCEPT_IMMUTABLE',
      status: 422,
      title: 'Validation Error',
      detail: 'Concept cannot be changed once the character has been forged.',
    });
  }
}

/**
 * Thrown when an active character's crew concept (амплуа команды) is changed.
 * Mutable while draft; immutable once the character is forged.
 */
export class CrewConceptImmutableError extends DomainError {
  constructor() {
    super({
      code: 'CREW_CONCEPT_IMMUTABLE',
      status: 422,
      title: 'Validation Error',
      detail: 'Crew concept cannot be changed once the character has been forged.',
    });
  }
}

/**
 * Thrown when a PATCH on a draft character tries to set `birr`. The wallet
 * is seeded from `startingWealth` on the draft → active forge transition;
 * while the character is still a draft the upbringing (and therefore the
 * derived starting wealth) is mutable, so any explicit `birr` write would
 * be stranded by the next upbringing change.
 */
export class BirrDraftImmutableError extends DomainError {
  constructor() {
    super({
      code: 'BIRR_DRAFT_IMMUTABLE',
      status: 422,
      title: 'Validation Error',
      detail:
        'Birr balance cannot be set while the character is still a draft. The wallet is seeded from startingWealth on the forge step.',
    });
  }
}

/**
 * Thrown when adding a second talent of a non-`personal` kind to a character.
 * Per Coriolis ch.2 each character has at most one of each crew, iconGift,
 * and stigma talent at character creation; further talents acquired during
 * play are always `personal`.
 */
export class TalentKindDuplicateError extends DomainError {
  constructor(kind: string) {
    super({
      code: 'TALENT_KIND_DUPLICATE',
      status: 400,
      title: 'Validation Error',
      detail: `Character already has a talent of kind ${kind}.`,
    });
  }
}

/**
 * Thrown when `mutant=true` is supplied without a `mutantLineage`. ST3001
 * ch.4 §Стигмы пасынков: every пасынок belongs to one of three родословных
 * (zirba | shingura | nerida) and carries the matching stigma talent.
 */
export class MutantLineageRequiredError extends DomainError {
  constructor() {
    super({
      code: 'MUTANT_LINEAGE_REQUIRED',
      status: 400,
      title: 'Validation Error',
      detail: 'A mutant character must declare a lineage (zirba, shingura, or nerida).',
    });
  }
}

/**
 * Thrown when `mutant=false` is paired with a non-null `mutantLineage`.
 * Lineage is meaningless for non-mutants — keep the two fields aligned.
 */
export class MutantLineageForbiddenError extends DomainError {
  constructor() {
    super({
      code: 'MUTANT_LINEAGE_FORBIDDEN',
      status: 400,
      title: 'Validation Error',
      detail: 'Mutant lineage may only be set when mutant is true.',
    });
  }
}

/**
 * Thrown when an active character's mutant flag (or its lineage) is changed.
 * Mutable while draft; immutable once the character is forged.
 */
export class MutantImmutableError extends DomainError {
  constructor() {
    super({
      code: 'MUTANT_IMMUTABLE',
      status: 422,
      title: 'Validation Error',
      detail: 'Mutant status and lineage cannot be changed once the character has been forged.',
    });
  }
}

/**
 * Thrown when a `kind: stigma` talent is added to a non-mutant character.
 * Stigmas are reserved for пасынки per ST3001 ch.4.
 */
export class StigmaRequiresMutantError extends DomainError {
  constructor() {
    super({
      code: 'STIGMA_REQUIRES_MUTANT',
      status: 400,
      title: 'Validation Error',
      detail: 'A stigma talent may only be added to a mutant character.',
    });
  }
}

/**
 * Thrown when the client attempts to set a server-computed read-only field.
 * Belt-and-suspenders defence on top of the OpenAPI spec's readOnly markers.
 * PRD §5.2: hp.max, mp.max, encumbrance.max are derived — never user-writable.
 */
export class ReadOnlyFieldError extends DomainError {
  constructor(field: string) {
    super({
      code: 'READ_ONLY_FIELD',
      status: 422,
      title: 'Validation Error',
      detail: `Field '${field}' is calculated by the server and cannot be set directly.`,
    });
  }
}

/**
 * Thrown when a role is assigned to a character whose concept does not
 * include that role. Per ГЛАВА 2 «АМПЛУА И РОЛИ» ST3001, each amplua has
 * exactly three canonical roles — any other combination is invalid.
 */
export class RoleConceptMismatchError extends DomainError {
  constructor(role: string, concept: string) {
    super({
      code: 'ROLE_CONCEPT_MISMATCH',
      status: 400,
      title: 'Validation Error',
      detail: `Role '${role}' does not belong to concept '${concept}'.`,
    });
  }
}

/**
 * Thrown when the client attempts an illegal status transition.
 * Only draft → active (forge) is permitted. The reverse (active → draft)
 * is a product rule violation — ADR 0002.
 */
export class InvalidStatusTransitionError extends DomainError {
  constructor(from: string, to: string) {
    super({
      code: 'INVALID_STATUS_TRANSITION',
      status: 422,
      title: 'Invalid Status Transition',
      detail: `Cannot transition character status from '${from}' to '${to}'. Only draft → active is permitted.`,
    });
  }
}
