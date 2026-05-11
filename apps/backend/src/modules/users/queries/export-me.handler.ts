/**
 * WHY this file exists:
 * Read-side handler for the JSON export. Dispatches each domain-resource
 * list through the QueryBus so the exported shapes match the canonical
 * API read-models one-to-one (computed fields, renamed relations, etc.).
 * ExportRepo is slimmed to user-envelope lookup only.
 *
 * Access checks in ListEncountersHandler / ListCombatantsHandler rely on
 * callerId == ownerId, which holds for all resources in a personal export.
 */
import { Inject } from '@nestjs/common';
import { IQueryHandler, QueryBus, QueryHandler } from '@nestjs/cqrs';

import { ListCharactersQuery } from '../../characters/queries/list-characters.query';
import type { CharacterListResult } from '../../characters/queries/list-characters.handler';
import { ListShipsQuery } from '../../ships/queries/list-ships.query';
import type { ShipListResult } from '../../ships/queries/list-ships.handler';
import { ListNpcsQuery } from '../../npcs/queries/list-npcs.query';
import type { NpcListResult } from '../../npcs/queries/list-npcs.handler';
import { ListGameSessionsQuery } from '../../game-sessions/queries/list-game-sessions.query';
import type { GameSessionListResult } from '../../game-sessions/queries/list-game-sessions.handler';
import { ListEncountersQuery } from '../../encounters/queries/list-encounters.query';
import type { EncounterListResult } from '../../encounters/queries/list-encounters.handler';
import { ListCombatantsQuery } from '../../combatants/queries/list-combatants.query';
import type { CombatantListResult } from '../../combatants/queries/list-combatants.handler';

import { EXPORT_REPO } from '../domain/user.ports';
import { UserNotFoundError } from '../domain/user.errors';

import { ExportMeQuery } from './export-me.query';

import type { IExportRepo, MeExportBundle } from '../domain/user.ports';

/**
 * Maximum number of items per resource type in a single export bundle.
 * Chosen to cover >99.9% of v1 users without paginating. A user hitting
 * this limit will see a truncated bundle — track via a future
 * `exportedTotalCount` field on MeExportBundle if it ever matters.
 */
const EXPORT_LIMIT = 1000;

@QueryHandler(ExportMeQuery)
export class ExportMeHandler implements IQueryHandler<ExportMeQuery, MeExportBundle> {
  constructor(
    @Inject(EXPORT_REPO) private readonly repo: IExportRepo,
    private readonly queryBus: QueryBus,
  ) {}

  async execute(query: ExportMeQuery): Promise<MeExportBundle> {
    const userId = query.userId;

    const user = await this.repo.loadUserFor(userId);
    if (!user) throw new UserNotFoundError(userId);

    const [characters, ships, npcs, sessions] = await Promise.all([
      this.queryBus.execute<ListCharactersQuery, CharacterListResult>(
        new ListCharactersQuery(userId, EXPORT_LIMIT, undefined, true),
      ),
      this.queryBus.execute<ListShipsQuery, ShipListResult>(
        new ListShipsQuery(userId, EXPORT_LIMIT),
      ),
      this.queryBus.execute<ListNpcsQuery, NpcListResult>(new ListNpcsQuery(userId, EXPORT_LIMIT)),
      this.queryBus.execute<ListGameSessionsQuery, GameSessionListResult>(
        new ListGameSessionsQuery(userId, EXPORT_LIMIT),
      ),
    ]);

    // For each session, inline encounters + per-encounter combatants.
    // userId == callerId because the user is always the owner of their own sessions.
    const sessionsWithChildren = await Promise.all(
      sessions.items.map(async (session) => {
        const encounters = await this.queryBus.execute<ListEncountersQuery, EncounterListResult>(
          new ListEncountersQuery(session.id, userId, EXPORT_LIMIT),
        );
        const encountersWithCombatants = await Promise.all(
          encounters.items.map(async (encounter) => {
            const combatants = await this.queryBus.execute<
              ListCombatantsQuery,
              CombatantListResult
            >(new ListCombatantsQuery(encounter.id, userId));
            return { ...encounter, combatants: combatants.items };
          }),
        );
        return { ...session, encounters: encountersWithCombatants };
      }),
    );

    return {
      $schemaVersion: '1',
      exportedAt: new Date().toISOString(),
      user,
      characters: characters.items,
      ships: ships.items,
      npcs: npcs.items,
      gameSessions: sessionsWithChildren,
    };
  }
}
