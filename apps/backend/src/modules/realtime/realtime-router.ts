/**
 * WHY this file exists:
 * Single source of truth for Centrifugo channel names and payload envelopes.
 *
 * Before this abstraction, channel-name string templates were duplicated across
 * ChatRealtimePublisher, CentrifugoCombatPublisher, UpdateDpHandler, and
 * RollPushedDpHandler. Any drift between those copies and the AsyncAPI contract
 * would go undetected until a client broke at runtime.
 *
 * RealtimeRouter exposes one typed method per logical publish operation. Each
 * method builds the correct channel name (via the exported channel-name builder
 * constants) and serialises the payload into the shape documented in
 * `packages/specs/asyncapi/centrifugo.yaml`. All publishes are fire-and-forget:
 * errors are caught, logged, and swallowed so that a slow or unreachable
 * Centrifugo instance never rolls back a committed database write.
 *
 * Channel-name builders are exported as plain functions so AsyncAPI contract
 * tests can import them directly without instantiating the injectable.
 */
import { Inject, Injectable, Logger } from '@nestjs/common';

import { CENTRIFUGO_CLIENT, type ICentrifugoClient } from './centrifugo.client';

import type { ChatMessageReadModel } from '../chat/domain/chat.ports';
import type { CombatantReadModel } from '../combatants/domain/combatant.ports';
import type { EncounterReadModel } from '../encounters/domain/encounter.ports';

// ---------------------------------------------------------------------------
// Channel-name builders
// These are pure functions exported for contract tests and documentation.
// They are the ONLY place where channel name patterns are defined.
// They must stay byte-identical to the AsyncAPI centrifugo.yaml addresses.
// ---------------------------------------------------------------------------

/** session.{gameSessionId} — DP / roll / combat events */
export function sessionChannel(gameSessionId: string): string {
  return `session.${gameSessionId}`;
}

/** session.{gameSessionId}.chat — broadcast chat messages */
export function sessionChatChannel(gameSessionId: string): string {
  return `session.${gameSessionId}.chat`;
}

/** session.{gameSessionId}.member.{membershipId} — per-member whispers */
export function sessionMemberChannel(gameSessionId: string, membershipId: string): string {
  return `session.${gameSessionId}.member.${membershipId}`;
}

// ---------------------------------------------------------------------------
// Payload types (discriminated unions matching the AsyncAPI message schemas)
// ---------------------------------------------------------------------------

/** AsyncAPI: DpChanged message payload (sessionChannel) */
export interface DpChangedPayload {
  gameSessionId: string;
  dpCount: number;
  delta: number;
  source: 'gm-manual' | 'roll-push' | 'system';
  at: string;
}

/** AsyncAPI: RollPushed message payload (sessionChannel) */
export interface RollPushedPayload {
  rollId: string;
  characterId: string;
  gameSessionId: string;
  hits: number;
  // FIXME(T-2026-05-20-004): AsyncAPI RollPushed requires `kind` (enum: skill).
  // RollPushedDpHandler currently omits it to preserve the pre-router wire format.
  // A follow-up task should add `kind: 'skill'` here and in the handler, then
  // update the AsyncAPI contract test to assert it is present in the payload.
  kind?: 'skill';
  at: string;
}

/** Mapped combatant shape as defined in AsyncAPI CombatUpdated.combatants[] */
export interface CombatUpdatedCombatant {
  id: string;
  encounterId: string;
  combatantType: string;
  name: string;
  referenceId: string | null;
  initiative: number | null;
  turnOrder: number | null;
  hpCurrent: number;
  hpMax: number;
  statusFlags: string[];
}

/** AsyncAPI: CombatUpdated message payload (sessionChannel) */
export interface CombatUpdatedPayload {
  gameSessionId: string;
  encounterId: string;
  encounter: {
    id: string;
    gameSessionId: string;
    name: string;
    notes: string | null;
    status: string;
    round: number;
    activeCombatantId: string | null;
    createdAt: string;
    updatedAt: string;
  };
  combatants: CombatUpdatedCombatant[];
  at: string;
}

/** AsyncAPI: ChatMessagePosted / ChatMessageEdited payload (chat + member channels) */
export type ChatMessagePayload = ChatMessageReadModel;

/** AsyncAPI: ChatMessageDeleted payload (chat + member channels) */
export interface ChatMessageDeletedPayload {
  id: string;
  gameSessionId: string;
  targetMembershipId: string | null;
  deletedAt: string;
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

/** Maps CombatantReadModel to the AsyncAPI CombatUpdated.combatants[] item. */
function mapCombatant(c: CombatantReadModel): CombatUpdatedCombatant {
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

/**
 * Builds the set of channels for a chat message based on broadcast vs. whisper
 * routing rules (Stream C/7 spec):
 *   - broadcast (targetMembershipId === null) → session.<id>.chat
 *   - whisper → session.<id>.member.<target> + session.<id>.member.<author>
 *     (deduplicated when author === target)
 */
export function buildChatChannels(
  gameSessionId: string,
  authorMembershipId: string | null,
  targetMembershipId: string | null,
): string[] {
  if (targetMembershipId === null) {
    return [sessionChatChannel(gameSessionId)];
  }

  const channels: string[] = [sessionMemberChannel(gameSessionId, targetMembershipId)];
  if (authorMembershipId !== null && authorMembershipId !== targetMembershipId) {
    channels.push(sessionMemberChannel(gameSessionId, authorMembershipId));
  }
  return channels;
}

// ---------------------------------------------------------------------------
// RealtimeRouter
// ---------------------------------------------------------------------------

export const REALTIME_ROUTER = Symbol('REALTIME_ROUTER');

export interface IRealtimeRouter {
  publishDpChanged(payload: DpChangedPayload): Promise<void>;
  publishRollPushed(payload: RollPushedPayload): Promise<void>;
  publishCombatUpdated(
    gameSessionId: string,
    encounter: EncounterReadModel,
    combatants: CombatantReadModel[],
  ): Promise<void>;
  publishChatMessage(
    gameSessionId: string,
    authorMembershipId: string | null,
    targetMembershipId: string | null,
    payload: ChatMessagePayload,
  ): Promise<void>;
  publishChatMessageDeleted(
    gameSessionId: string,
    authorMembershipId: string | null,
    targetMembershipId: string | null,
    payload: ChatMessageDeletedPayload,
  ): Promise<void>;
}

@Injectable()
export class RealtimeRouter implements IRealtimeRouter {
  private readonly logger = new Logger(RealtimeRouter.name);

  constructor(@Inject(CENTRIFUGO_CLIENT) private readonly centrifugo: ICentrifugoClient) {}

  /**
   * Publishes dp.changed to session.{gameSessionId}.
   * Non-fatal: logs on failure, never re-throws.
   */
  async publishDpChanged(payload: DpChangedPayload): Promise<void> {
    const channel = sessionChannel(payload.gameSessionId);
    try {
      await this.centrifugo.publish(channel, payload as unknown as Record<string, unknown>);
    } catch (error) {
      this.logger.error(
        `Failed to publish dp.changed for session ${payload.gameSessionId}: ${String(error)}`,
      );
    }
  }

  /**
   * Publishes roll.pushed to session.{gameSessionId}.
   * Non-fatal: logs on failure, never re-throws.
   */
  async publishRollPushed(payload: RollPushedPayload): Promise<void> {
    const channel = sessionChannel(payload.gameSessionId);
    try {
      await this.centrifugo.publish(channel, payload as unknown as Record<string, unknown>);
    } catch (error) {
      this.logger.error(
        `Failed to publish roll.pushed for session ${payload.gameSessionId} / roll ${payload.rollId}: ${String(error)}`,
      );
    }
  }

  /**
   * Publishes combat.updated to session.{gameSessionId}.
   * Sorts combatants by turnOrder ascending (nulls last) before publishing.
   * Non-fatal: logs on failure, never re-throws.
   */
  async publishCombatUpdated(
    gameSessionId: string,
    encounter: EncounterReadModel,
    combatants: CombatantReadModel[],
  ): Promise<void> {
    const channel = sessionChannel(gameSessionId);

    const ordered = [...combatants].toSorted((a, b) => {
      if (a.turnOrder === null && b.turnOrder === null) return 0;
      if (a.turnOrder === null) return 1;
      if (b.turnOrder === null) return -1;
      return a.turnOrder - b.turnOrder;
    });

    const payload: CombatUpdatedPayload = {
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
    };

    try {
      await this.centrifugo.publish(channel, payload as unknown as Record<string, unknown>);
    } catch (error) {
      this.logger.error(
        `Failed to publish combat.updated for session ${gameSessionId} / encounter ${encounter.id}: ${String(error)}`,
      );
    }
  }

  /**
   * Publishes a chat message (posted or edited) to the appropriate channel(s).
   * Broadcast → session.{id}.chat; whisper → both member channels.
   * Non-fatal: per-channel errors are caught and logged.
   */
  async publishChatMessage(
    gameSessionId: string,
    authorMembershipId: string | null,
    targetMembershipId: string | null,
    payload: ChatMessagePayload,
  ): Promise<void> {
    const channels = buildChatChannels(gameSessionId, authorMembershipId, targetMembershipId);
    const data = payload as unknown as Record<string, unknown>;
    for (const channel of channels) {
      try {
        await this.centrifugo.publish(channel, data);
      } catch (error) {
        this.logger.error(`Failed to publish chat.message to ${channel}: ${String(error)}`);
      }
    }
  }

  /**
   * Publishes a chat-message tombstone (deleted event) to the appropriate channel(s).
   * Routing mirrors publishChatMessage: broadcast → .chat; whisper → member channels.
   * Non-fatal: per-channel errors are caught and logged.
   */
  async publishChatMessageDeleted(
    gameSessionId: string,
    authorMembershipId: string | null,
    targetMembershipId: string | null,
    payload: ChatMessageDeletedPayload,
  ): Promise<void> {
    const channels = buildChatChannels(gameSessionId, authorMembershipId, targetMembershipId);
    const data = payload as unknown as Record<string, unknown>;
    for (const channel of channels) {
      try {
        await this.centrifugo.publish(channel, data);
      } catch (error) {
        this.logger.error(`Failed to publish chat.message.deleted to ${channel}: ${String(error)}`);
      }
    }
  }
}
