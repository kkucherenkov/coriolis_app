/**
 * WHY this file exists:
 * Minimal port for reading the source entity (Character or Npc) needed
 * at combatant add-time to build the snapshot. Decouples the AddCombatant
 * handler from PrismaService and from the characters/npcs bounded contexts.
 *
 * The infra adapter queries Prisma directly (scoped SELECT) — it does not
 * import CharacterRepo or NpcRepo to avoid cross-module coupling.
 */

export const SOURCE_LOOKUP = Symbol('SOURCE_LOOKUP');

/** Minimal character shape needed for the PC snapshot. */
export interface SourceCharacter {
  id: string;
  ownerId: string;
  name: string;
  hpCurrent: number;
  /** Derived from attributes.strength + attributes.agility via rules-engine. */
  hpMax: number;
  /** Sum of equipped armor items' armorRating. */
  armor: number;
  /** Always 0 for PCs. */
  signature: number;
  attributes: {
    strength: number;
    agility: number;
    wits: number;
    empathy: number;
  };
  skills: Record<string, number>;
}

/** Minimal NPC shape needed for the NPC snapshot. */
export interface SourceNpc {
  id: string;
  ownerId: string;
  name: string;
  hpCurrent: number;
  hpMax: number;
  /** First equipped armor item's armorRating, or 0. */
  armor: number;
  signature: number;
  attributes: {
    strength: number;
    agility: number;
    wits: number;
    empathy: number;
  };
  skills: Record<string, number>;
}

export interface ISourceLookup {
  findCharacterById(id: string): Promise<SourceCharacter | null>;
  findNpcById(id: string): Promise<SourceNpc | null>;
}
