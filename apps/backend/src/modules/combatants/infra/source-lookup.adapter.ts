/**
 * WHY this file exists:
 * Prisma adapter for ISourceLookup. Fetches only the columns needed to
 * build the combatant snapshot at add-time. Does NOT import CharacterRepo
 * or NpcRepo — it queries Prisma directly with scoped SELECTs, keeping
 * the combatants module independent of the characters and npcs modules.
 *
 * Character.hpMax is derived: strength + agility (rules-engine §5.2).
 * Character.armor is derived: sum of equipped ARMOR items' armorRating.
 * Npc.armor is flat: the first equipped armor item's armorRating (or 0
 * for NPCs that carry no armor). Npc.signature is a flat column.
 */
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../common/prisma/prisma.service';
import { computeHpMax } from '../../rules-engine';

import type { ISourceLookup, SourceCharacter, SourceNpc } from '../domain/source-lookup.ports';

interface PrismaCharacterSnap {
  id: string;
  ownerId: string;
  name: string;
  hpCurrent: number;
  attributes: unknown;
  skills: unknown;
  items: { type: string; data: unknown }[];
}

interface PrismaNpcSnap {
  id: string;
  ownerId: string;
  name: string;
  hpCurrent: number;
  hpMax: number;
  signature: number;
  attributes: unknown;
  skills: unknown;
  armor: unknown;
}

@Injectable()
export class SourceLookupAdapter implements ISourceLookup {
  constructor(private readonly prisma: PrismaService) {}

  async findCharacterById(id: string): Promise<SourceCharacter | null> {
    const row = (await this.prisma.character.findFirst({
      where: { id },
      select: {
        id: true,
        ownerId: true,
        name: true,
        hpCurrent: true,
        attributes: true,
        skills: true,
        items: {
          where: { type: 'ARMOR' },
          select: { type: true, data: true },
        },
      },
    })) as PrismaCharacterSnap | null;

    if (!row) return null;

    const attrs = row.attributes as {
      strength: number;
      agility: number;
      wits: number;
      empathy: number;
    };

    const hpMax = computeHpMax(attrs.strength, attrs.agility);

    // Sum armorRating of equipped armor items
    let armor = 0;
    for (const item of row.items) {
      const data = item.data as { armorRating?: number; equipped?: boolean };
      if (data.equipped !== false && typeof data.armorRating === 'number') {
        armor += data.armorRating;
      }
    }

    return {
      id: row.id,
      ownerId: row.ownerId,
      name: row.name,
      hpCurrent: row.hpCurrent,
      hpMax,
      armor,
      signature: 0,
      attributes: attrs,
      skills: row.skills as Record<string, number>,
    };
  }

  async findNpcById(id: string): Promise<SourceNpc | null> {
    const row = (await this.prisma.npc.findFirst({
      where: { id },
      select: {
        id: true,
        ownerId: true,
        name: true,
        hpCurrent: true,
        hpMax: true,
        signature: true,
        attributes: true,
        skills: true,
        armor: true,
      },
    })) as PrismaNpcSnap | null;

    if (!row) return null;

    // NPC armor is a JSON array of ItemArmor objects
    let armorRating = 0;
    const armorItems = (row.armor ?? []) as { armorRating?: number; equipped?: boolean }[];
    for (const item of armorItems) {
      if (item.equipped !== false && typeof item.armorRating === 'number') {
        armorRating += item.armorRating;
      }
    }

    return {
      id: row.id,
      ownerId: row.ownerId,
      name: row.name,
      hpCurrent: row.hpCurrent,
      hpMax: row.hpMax,
      armor: armorRating,
      signature: row.signature,
      attributes: row.attributes as {
        strength: number;
        agility: number;
        wits: number;
        empathy: number;
      },
      skills: row.skills as Record<string, number>,
    };
  }
}
