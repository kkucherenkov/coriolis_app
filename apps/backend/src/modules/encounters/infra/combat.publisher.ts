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
 * Channel construction, combatant mapping, and payload serialisation are
 * delegated to RealtimeRouter (apps/backend/src/modules/realtime/realtime-router.ts)
 * — the single source of truth for all Centrifugo channel names and payload
 * shapes in the backend.
 *
 * Channel: session.{gameSessionId}
 * Payload shape: matches the AsyncAPI CombatUpdated schema (centrifugo.yaml).
 */
import { Injectable } from '@nestjs/common';

import { RealtimeRouter } from '../../realtime/realtime-router';

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

@Injectable()
export class CentrifugoCombatPublisher implements ICombatPublisher {
  constructor(private readonly realtimeRouter: RealtimeRouter) {}

  async publishUpdated(
    gameSessionId: string,
    encounter: EncounterReadModel,
    combatants: CombatantReadModel[],
  ): Promise<void> {
    await this.realtimeRouter.publishCombatUpdated(gameSessionId, encounter, combatants);
  }
}
