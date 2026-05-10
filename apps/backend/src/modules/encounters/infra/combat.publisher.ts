/**
 * WHY this file exists:
 * CombatPublisher is the port interface + Centrifugo adapter for publishing
 * combat.updated snapshots on the session channel.
 *
 * Every successful encounter / combatant mutation calls publishUpdated AFTER
 * the DB write has committed. Failures are non-fatal: they are caught, logged,
 * and never re-thrown. The DB write is never rolled back because of a publish
 * failure.
 *
 * Channel: session.{gameSessionId}
 * Payload shape: matches the AsyncAPI CombatUpdated schema (centrifugo.yaml
 * lines 165-257). additionalProperties is open per AsyncAPI default, so sending
 * the full CombatantReadModel is fine — the AsyncAPI-required subset is mapped
 * explicitly to satisfy the required[] constraint.
 */
import { Injectable, Logger } from '@nestjs/common';
import { Inject } from '@nestjs/common';

import { CENTRIFUGO_CLIENT } from '../../realtime/centrifugo.client';

import type { ICentrifugoClient } from '../../realtime/centrifugo.client';
import type { EncounterReadModel } from '../domain/encounter.ports';
import type { CombatantReadModel } from '../../combatants/domain/combatant.ports';

// --------------- Port ---------------

export const COMBAT_PUBLISHER = Symbol('COMBAT_PUBLISHER');

export interface ICombatPublisher {
  /**
   * Publishes a combat.updated snapshot to session.{gameSessionId}.
   * Non-fatal: never throws. Logs on failure.
   */
  publishUpdated(
    gameSessionId: string,
    encounter: EncounterReadModel,
    combatants: CombatantReadModel[],
  ): Promise<void>;
}

// --------------- Adapter ---------------

/** Maps CombatantReadModel to the AsyncAPI combatants[] item shape. */
function mapCombatant(c: CombatantReadModel): Record<string, unknown> {
  return {
    id: c.id,
    encounterId: c.encounterId,
    combatantType: c.combatantType,
    name: c.displayName, // AsyncAPI uses "name"; read-model uses "displayName"
    referenceId: c.sourceId, // AsyncAPI uses "referenceId"; read-model uses "sourceId"
    initiative: c.initiative,
    turnOrder: c.turnOrder,
    hpCurrent: c.hpCurrent,
    hpMax: c.hpMax,
    statusFlags: c.statusFlags,
  };
}

@Injectable()
export class CentrifugoCombatPublisher implements ICombatPublisher {
  private readonly logger = new Logger(CentrifugoCombatPublisher.name);

  constructor(@Inject(CENTRIFUGO_CLIENT) private readonly centrifugo: ICentrifugoClient) {}

  async publishUpdated(
    gameSessionId: string,
    encounter: EncounterReadModel,
    combatants: CombatantReadModel[],
  ): Promise<void> {
    // Sort combatants by turnOrder ascending; nulls last (pre-initiative state)
    const ordered = [...combatants].toSorted((a, b) => {
      if (a.turnOrder === null && b.turnOrder === null) return 0;
      if (a.turnOrder === null) return 1;
      if (b.turnOrder === null) return -1;
      return a.turnOrder - b.turnOrder;
    });

    try {
      await this.centrifugo.publish(`session.${gameSessionId}`, {
        gameSessionId,
        encounterId: encounter.id,
        encounter: {
          id: encounter.id,
          gameSessionId: encounter.gameSessionId,
          name: encounter.name,
          notes: encounter.notes,
          status: encounter.status,
          round: encounter.round,
          activeCombatantId: encounter.activeCombatantId,
          createdAt: encounter.createdAt,
          updatedAt: encounter.updatedAt,
        },
        combatants: ordered.map((c) => mapCombatant(c)),
        at: new Date().toISOString(),
      });
    } catch (error) {
      this.logger.error(
        `Failed to publish combat.updated for session ${gameSessionId} / encounter ${encounter.id}: ${String(error)}`,
      );
    }
  }
}
