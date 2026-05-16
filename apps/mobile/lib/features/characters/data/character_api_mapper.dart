import 'package:app_api_client/app_api_client.dart'
    show
        CriticalInjury,
        Item,
        ItemArmor,
        ItemCybernetic,
        ItemGear,
        ItemOther,
        ItemShipModule,
        ItemWeapon,
        Talent;
import 'package:app_api_client/app_api_client.dart' as api_client show Character;

import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/domain/character_summary.dart';

/// Single source of truth for the wire→domain transform.
///
/// Used by [CharacterRepositoryImpl] for live API responses and by
/// [CachedCharacterRepository] for hydrating cached payloads.
final class CharacterApiMapper {
  const CharacterApiMapper._();

  static Character toDomain(api_client.Character src) => Character(
        id: src.id,
        ownerId: src.ownerId,
        name: src.name,
        // Enum-shaped fields are stored as the Dart-side `EnumClass.name`
        // form (camelCase). The wire form uses kebab-case where applicable
        // (`lady-of-tears`, `network-djinn`) — the EnumClass handles the
        // wire serialisation; the domain only sees the Dart name.
        concept: src.concept?.name,
        role: src.role?.name,
        roleUnmigrated: src.roleUnmigrated ?? false,
        iconId: src.iconId?.name,
        upbringing: src.upbringing.name,
        origin: src.origin,
        reputation: src.reputation,
        startingWealth: src.startingWealth,
        birr: src.birr,
        crewConcept: src.crewConcept?.name,
        mutant: src.mutant,
        mutantLineage: src.mutantLineage?.name,
        status: src.status.name,
        attributes: CharacterAttributes(
          strength: src.attributes.strength,
          agility: src.attributes.agility,
          wits: src.attributes.wits,
          empathy: src.attributes.empathy,
        ),
        skills: CharacterSkills(
          dexterity: src.skills.dexterity,
          force: src.skills.force,
          infiltration: src.skills.infiltration,
          manipulation: src.skills.manipulation,
          meleeCombat: src.skills.meleeCombat,
          observation: src.skills.observation,
          rangedCombat: src.skills.rangedCombat,
          survival: src.skills.survival,
          command: src.skills.command,
          culture: src.skills.culture,
          dataDjinn: src.skills.dataDjinn,
          medicurgy: src.skills.medicurgy,
          mysticPowers: src.skills.mysticPowers,
          pilot: src.skills.pilot,
          science: src.skills.science,
          technology: src.skills.technology,
        ),
        hp: CharacterHp(current: src.hp.current, max: src.hp.max),
        mp: CharacterMp(current: src.mp.current, max: src.mp.max),
        encumbrance: CharacterEncumbrance(
          current: src.encumbrance.current,
          max: src.encumbrance.max,
        ),
        experience: src.experience,
        conditions: CharacterConditions(
          exhausted: src.conditions.exhausted,
          sleepless: src.conditions.sleepless,
          thirsty: src.conditions.thirsty,
          hungry: src.conditions.hungry,
        ),
        criticalInjuries: src.criticalInjuries.map(ciToDomain).toList(),
        talents: src.talents.map(talentToDomain).toList(),
        inventory: src.inventory.map(itemToDomain).toList(),
        notes: src.notes,
        updatedAt: src.updatedAt,
        createdAt: src.createdAt,
      );

  static CharacterSummary toSummary(api_client.Character src) => CharacterSummary(
        id: src.id,
        name: src.name,
        concept: src.concept?.name,
      );

  static DomainCriticalInjury ciToDomain(CriticalInjury ci) =>
      DomainCriticalInjury(
        id: ci.id,
        name: ci.name,
        severity: ci.severity.name,
        effect: ci.effect,
        acquiredAt: ci.acquiredAt,
      );

  static DomainTalent talentToDomain(Talent t) => DomainTalent(
        id: t.id,
        name: t.name,
        description: t.description,
        rank: t.rank,
        acquiredAt: t.acquiredAt,
      );

  static DomainItem itemToDomain(Item item) {
    final raw = item.oneOf.value;
    if (raw is ItemWeapon) {
      return DomainItem(
        id: raw.id,
        type: ItemType.weapon,
        name: raw.name,
        weight: raw.weight,
        equipped: raw.equipped,
        damage: raw.damage,
        range: raw.range.name,
        bonus: raw.bonus,
        crit: raw.crit,
        features: raw.features.toList(),
      );
    }
    if (raw is ItemArmor) {
      return DomainItem(
        id: raw.id,
        type: ItemType.armor,
        name: raw.name,
        weight: raw.weight,
        equipped: raw.equipped,
        armorRating: raw.armorRating,
        features: raw.features.toList(),
      );
    }
    if (raw is ItemGear) {
      return DomainItem(
        id: raw.id,
        type: ItemType.gear,
        name: raw.name,
        weight: raw.weight,
        quantity: raw.quantity,
        notes: raw.notes,
      );
    }
    if (raw is ItemCybernetic) {
      // `bodyPoints` was retired in the ItemCybernetic spec (now tracked
      // via `xpCost`); the domain field stays null until a future mapper
      // surfaces XP cost as a separate first-class column.
      return DomainItem(
        id: raw.id,
        type: ItemType.cybernetic,
        name: raw.name,
        effect: raw.effect,
      );
    }
    if (raw is ItemShipModule) {
      return DomainItem(
        id: raw.id,
        type: ItemType.shipModule,
        name: raw.name,
        effect: raw.effect,
      );
    }
    // ItemOther
    final other = raw as ItemOther;
    return DomainItem(
      id: other.id,
      type: ItemType.other,
      name: other.name,
      weight: other.weight,
      notes: other.notes,
    );
  }
}
