/**
 * WHY this file exists:
 * Handles AssignCrewCommand:
 *   1. Verify ship exists and is owned by caller (404 / 403).
 *   2. Verify character exists and is owned by caller (400 / 403).
 *   3. If the character is already on this ship at the same position → return
 *      the existing slot (idempotent re-assign).
 *   4. If the character is on a different position → clear old slot, fill new
 *      one (move semantics) — but only if the new position is empty.
 *   5. If the new position is already taken by a different character → 400
 *      CREW_POSITION_TAKEN.
 *
 * No Prisma here — only IShipRepo and ICharacterRepo ports.
 */
import { Inject } from '@nestjs/common';
import { CommandHandler, ICommandHandler } from '@nestjs/cqrs';

import { CHARACTER_REPO } from '../../characters/domain/character.ports';
import {
  CharacterNotFoundError,
  CharacterNotOwnedError,
  CrewPositionTakenError,
  ShipNotFoundError,
  ShipNotOwnerError,
} from '../domain/ship.errors';
import { SHIP_REPO } from '../domain/ship.ports';

import { AssignCrewCommand } from './assign-crew.command';

import type { ICharacterRepo } from '../../characters/domain/character.ports';
import type { CrewSlotReadModel, IShipRepo } from '../domain/ship.ports';

@CommandHandler(AssignCrewCommand)
export class AssignCrewHandler implements ICommandHandler<AssignCrewCommand, CrewSlotReadModel> {
  constructor(
    @Inject(SHIP_REPO) private readonly shipRepo: IShipRepo,
    @Inject(CHARACTER_REPO) private readonly charRepo: ICharacterRepo,
  ) {}

  async execute(command: AssignCrewCommand): Promise<CrewSlotReadModel> {
    const { shipId, ownerId, dto } = command;
    const { position, characterId } = dto;

    // --- Ship ownership guard ---
    const ship = await this.shipRepo.findById(shipId);
    if (!ship) throw new ShipNotFoundError(shipId);
    if (ship.ownerId !== ownerId) throw new ShipNotOwnerError(shipId);

    // --- Character existence + ownership guard ---
    const charOwnership = await this.charRepo.findOwnerIdById(characterId);
    if (!charOwnership) throw new CharacterNotFoundError(characterId);
    if (charOwnership.ownerId !== ownerId) throw new CharacterNotOwnedError(characterId);

    // --- Check current state of this character on the ship ---
    const existingSlotForChar = await this.shipRepo.findCrewSlotByCharacter(shipId, characterId);

    if (existingSlotForChar) {
      if (existingSlotForChar.position === position) {
        // Idempotent: same character, same position — return as-is
        return existingSlotForChar;
      }

      // Character is on a different position → move: clear old, fill new.
      // First verify the target position is free.
      const targetSlot = await this.shipRepo.findCrewSlot(shipId, position);
      if (targetSlot?.assignedCharacterId && targetSlot.assignedCharacterId !== characterId) {
        throw new CrewPositionTakenError(position);
      }

      await this.shipRepo.unassignCrewSlot(shipId, characterId);
      return this.shipRepo.assignCrewSlot(shipId, position, characterId);
    }

    // --- Character not yet on ship ---
    const targetSlot = await this.shipRepo.findCrewSlot(shipId, position);
    if (targetSlot?.assignedCharacterId) {
      throw new CrewPositionTakenError(position);
    }

    return this.shipRepo.assignCrewSlot(shipId, position, characterId);
  }
}
