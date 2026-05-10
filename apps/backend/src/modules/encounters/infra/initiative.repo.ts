/**
 * WHY this file exists:
 * Infrastructure adapter for the IInitiativeRepo port.
 * Executes all initiative operations inside a single Prisma transaction
 * so encounter state and combatant rows are always consistent.
 *
 * This is the only file in the encounters bounded context that writes
 * directly to the combatant table — it does so only for the three
 * atomic initiative/turn-advance operations.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';

import type {
  AdvanceTurnData,
  IInitiativeRepo,
  InitiativeRollResult,
  ReorderInitiativeData,
  RollInitiativeData,
} from '../domain/encounter.ports';
import type { CombatantReadModel } from '../../combatants/domain/combatant.ports';

// Minimal select for combatant read model (mirrors CombatantRepo.COMBATANT_SELECT)
const COMBATANT_SELECT = {
  id: true,
  encounterId: true,
  combatantType: true,
  characterId: true,
  npcId: true,
  displayName: true,
  initiative: true,
  turnOrder: true,
  hpCurrent: true,
  hpMax: true,
  armor: true,
  signature: true,
  statusFlags: true,
  notes: true,
  createdAt: true,
  updatedAt: true,
} as const;

interface PrismaCombatantRow {
  id: string;
  encounterId: string;
  combatantType: string;
  characterId: string | null;
  npcId: string | null;
  displayName: string;
  initiative: number | null;
  turnOrder: number | null;
  hpCurrent: number;
  hpMax: number;
  armor: number;
  signature: number;
  statusFlags: string[];
  notes: string | null;
  createdAt: Date;
  updatedAt: Date;
}

function toCombatantReadModel(row: PrismaCombatantRow): CombatantReadModel {
  return {
    id: row.id,
    encounterId: row.encounterId,
    combatantType: row.combatantType.toLowerCase() as 'pc' | 'npc',
    sourceId: row.characterId ?? row.npcId ?? '',
    displayName: row.displayName,
    initiative: row.initiative,
    turnOrder: row.turnOrder,
    hpCurrent: row.hpCurrent,
    hpMax: row.hpMax,
    armor: row.armor,
    signature: row.signature,
    statusFlags: row.statusFlags,
    notes: row.notes,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

@Injectable()
export class InitiativeRepo implements IInitiativeRepo {
  constructor(private readonly prisma: PrismaService) {}

  async rollInitiative(data: RollInitiativeData): Promise<InitiativeRollResult> {
    const rows = await this.prisma.$transaction(async (tx) => {
      // Update each combatant's initiative and turnOrder
      await Promise.all(
        data.combatantPatches.map((patch) =>
          tx.combatant.update({
            where: { id: patch.id },
            data: { initiative: patch.initiative, turnOrder: patch.turnOrder },
          }),
        ),
      );

      // Transition encounter: setup → active, round=1, activeCombatantId
      await tx.encounter.update({
        where: { id: data.encounterId },
        data: {
          status: 'ACTIVE',
          round: 1,
          activeCombatantId: data.activeCombatantId,
        },
      });

      // Return combatants sorted by turnOrder asc
      return tx.combatant.findMany({
        where: { encounterId: data.encounterId },
        select: COMBATANT_SELECT,
        orderBy: [{ turnOrder: 'asc' }, { createdAt: 'asc' }],
      });
    });

    return {
      round: 1,
      combatants: rows.map((r) => toCombatantReadModel(r)),
    };
  }

  async reorderInitiative(data: ReorderInitiativeData): Promise<InitiativeRollResult> {
    const rows = await this.prisma.$transaction(async (tx) => {
      // Reassign turnOrder by position in orderedIds
      await Promise.all(
        data.orderedIds.map((id, index) =>
          tx.combatant.update({
            where: { id },
            data: { turnOrder: index },
          }),
        ),
      );

      // Read encounter to get current round
      const enc = await tx.encounter.findFirst({
        where: { id: data.encounterId },
        select: { round: true },
      });

      const round = enc?.round ?? 1;

      // Return combatants sorted by new turnOrder
      const combatantRows = await tx.combatant.findMany({
        where: { encounterId: data.encounterId },
        select: COMBATANT_SELECT,
        orderBy: [{ turnOrder: 'asc' }, { createdAt: 'asc' }],
      });

      return { round, combatantRows };
    });

    return {
      round: rows.round,
      combatants: rows.combatantRows.map((r) => toCombatantReadModel(r)),
    };
  }

  async advanceTurn(data: AdvanceTurnData): Promise<void> {
    await this.prisma.encounter.update({
      where: { id: data.encounterId },
      data: {
        activeCombatantId: data.activeCombatantId,
        round: data.round,
      },
    });
  }
}
