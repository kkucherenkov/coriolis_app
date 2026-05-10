/**
 * WHY this file exists:
 * Handles DELETE /api/v1/combatants/{id}.
 *
 * Responsibilities:
 * 1. Load the combatant; 404 if not found.
 * 2. Walk to encounter → game session to verify GM ownership; 404 if not owner.
 * 3. Reject if encounter is NOT in 'setup' (ENCOUNTER_LOCKED_FOR_COMBAT 422).
 *    Per spec: "Only allowed while the encounter is in setup status."
 *    Note: if activeCombatantId === this combatant id, onDelete:SetNull on the
 *    Encounter.activeCombatant relation handles the FK automatically.
 * 4. Delete the combatant row.
 * 5. Publish combat.updated snapshot (non-fatal) — the remaining combatants
 *    after deletion are fetched and published.
 *
 * No Prisma in this file. All I/O via injected ports.
 */
import { Inject, Logger } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { GAME_SESSION_ACCESS } from '../../encounters/domain/game-session-access.ports';
import { ENCOUNTER_REPO } from '../../encounters/domain/encounter.ports';
import { COMBAT_PUBLISHER } from '../../encounters/infra/combat.publisher';
import { COMBATANT_REPO } from '../domain/combatant.ports';
import { CombatantNotFoundError, EncounterLockedForCombatError } from '../domain/combatant.errors';

import { DeleteCombatantCommand } from './delete-combatant.command';

import type { IGameSessionAccess } from '../../encounters/domain/game-session-access.ports';
import type { IEncounterRepo } from '../../encounters/domain/encounter.ports';
import type { ICombatPublisher } from '../../encounters/infra/combat.publisher';
import type { ICombatantRepo } from '../domain/combatant.ports';

@CommandHandler(DeleteCombatantCommand)
export class DeleteCombatantHandler implements ICommandHandler<DeleteCombatantCommand, void> {
  private readonly logger = new Logger(DeleteCombatantHandler.name);

  constructor(
    @Inject(COMBATANT_REPO) private readonly combatantRepo: ICombatantRepo,
    @Inject(ENCOUNTER_REPO) private readonly encounterRepo: IEncounterRepo,
    @Inject(GAME_SESSION_ACCESS) private readonly access: IGameSessionAccess,
    @Inject(COMBAT_PUBLISHER) private readonly combatPublisher: ICombatPublisher,
  ) {}

  async execute(command: DeleteCombatantCommand): Promise<void> {
    const { id, callerId } = command;

    // Load combatant
    const combatant = await this.combatantRepo.findById(id);
    if (!combatant) throw new CombatantNotFoundError(id);

    // Walk to encounter → game session → owner
    const encounter = await this.encounterRepo.findById(combatant.encounterId);
    if (!encounter) throw new CombatantNotFoundError(id);

    const ownerId = await this.access.getOwnerId(encounter.gameSessionId);
    if (ownerId === null || ownerId !== callerId) {
      throw new CombatantNotFoundError(id);
    }

    // Only allowed in 'setup' status
    if (encounter.status !== 'setup') {
      throw new EncounterLockedForCombatError();
    }

    // The Encounter.activeCombatant @relation has onDelete:SetNull, so if
    // activeCombatantId === id, Prisma sets it to null automatically in the same tx.
    await this.combatantRepo.delete(id);

    // Publish combat.updated — non-fatal; DB write is already committed.
    // Fetch the remaining combatants (the deleted one is gone at this point).
    try {
      const remaining = await this.combatantRepo.listByEncounter(encounter.id);
      await this.combatPublisher.publishUpdated(encounter.gameSessionId, encounter, remaining);
    } catch (error) {
      this.logger.error(
        `Failed to publish combat.updated for encounter ${encounter.id}: ${String(error)}`,
      );
    }
  }
}
