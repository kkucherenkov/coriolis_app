import 'package:equatable/equatable.dart';

// ── Value objects ────────────────────────────────────────────────────────────

/// The four primary attributes (1–5 each).
class CharacterAttributes extends Equatable {
  const CharacterAttributes({
    required this.strength,
    required this.agility,
    required this.wits,
    required this.empathy,
  });

  final int strength;
  final int agility;
  final int wits;
  final int empathy;

  CharacterAttributes copyWith({
    int? strength,
    int? agility,
    int? wits,
    int? empathy,
  }) =>
      CharacterAttributes(
        strength: strength ?? this.strength,
        agility: agility ?? this.agility,
        wits: wits ?? this.wits,
        empathy: empathy ?? this.empathy,
      );

  @override
  List<Object?> get props => [strength, agility, wits, empathy];
}

/// The 16 skills (0–5 each), split into general and advanced.
class CharacterSkills extends Equatable {
  const CharacterSkills({
    // General (8)
    required this.dexterity,
    required this.force,
    required this.infiltration,
    required this.manipulation,
    required this.meleeCombat,
    required this.observation,
    required this.rangedCombat,
    required this.survival,
    // Advanced (8)
    required this.command,
    required this.culture,
    required this.dataDjinn,
    required this.medicurgy,
    required this.mysticPowers,
    required this.pilot,
    required this.science,
    required this.technology,
  });

  // General
  final int dexterity;
  final int force;
  final int infiltration;
  final int manipulation;
  final int meleeCombat;
  final int observation;
  final int rangedCombat;
  final int survival;

  // Advanced
  final int command;
  final int culture;
  final int dataDjinn;
  final int medicurgy;
  final int mysticPowers;
  final int pilot;
  final int science;
  final int technology;

  CharacterSkills copyWith({
    int? dexterity,
    int? force,
    int? infiltration,
    int? manipulation,
    int? meleeCombat,
    int? observation,
    int? rangedCombat,
    int? survival,
    int? command,
    int? culture,
    int? dataDjinn,
    int? medicurgy,
    int? mysticPowers,
    int? pilot,
    int? science,
    int? technology,
  }) =>
      CharacterSkills(
        dexterity: dexterity ?? this.dexterity,
        force: force ?? this.force,
        infiltration: infiltration ?? this.infiltration,
        manipulation: manipulation ?? this.manipulation,
        meleeCombat: meleeCombat ?? this.meleeCombat,
        observation: observation ?? this.observation,
        rangedCombat: rangedCombat ?? this.rangedCombat,
        survival: survival ?? this.survival,
        command: command ?? this.command,
        culture: culture ?? this.culture,
        dataDjinn: dataDjinn ?? this.dataDjinn,
        medicurgy: medicurgy ?? this.medicurgy,
        mysticPowers: mysticPowers ?? this.mysticPowers,
        pilot: pilot ?? this.pilot,
        science: science ?? this.science,
        technology: technology ?? this.technology,
      );

  @override
  List<Object?> get props => [
        dexterity, force, infiltration, manipulation,
        meleeCombat, observation, rangedCombat, survival,
        command, culture, dataDjinn, medicurgy,
        mysticPowers, pilot, science, technology,
      ];
}

/// Derived HP pool (current / max).
class CharacterHp extends Equatable {
  const CharacterHp({required this.current, required this.max});
  final int current;
  final int max;
  CharacterHp copyWith({int? current, int? max}) =>
      CharacterHp(current: current ?? this.current, max: max ?? this.max);
  @override
  List<Object?> get props => [current, max];
}

/// Derived MP (Mind Points / Mystic Powers) pool.
class CharacterMp extends Equatable {
  const CharacterMp({required this.current, required this.max});
  final int current;
  final int max;
  CharacterMp copyWith({int? current, int? max}) =>
      CharacterMp(current: current ?? this.current, max: max ?? this.max);
  @override
  List<Object?> get props => [current, max];
}

/// Encumbrance (carried weight in slots).
class CharacterEncumbrance extends Equatable {
  const CharacterEncumbrance({required this.current, required this.max});
  final num current;
  final int max;
  CharacterEncumbrance copyWith({num? current, int? max}) =>
      CharacterEncumbrance(current: current ?? this.current, max: max ?? this.max);
  @override
  List<Object?> get props => [current, max];
}

/// The four standard Coriolis conditions.
class CharacterConditions extends Equatable {
  const CharacterConditions({
    required this.exhausted,
    required this.sleepless,
    required this.thirsty,
    required this.hungry,
  });

  final bool exhausted;
  final bool sleepless;
  final bool thirsty;
  final bool hungry;

  CharacterConditions copyWith({
    bool? exhausted,
    bool? sleepless,
    bool? thirsty,
    bool? hungry,
  }) =>
      CharacterConditions(
        exhausted: exhausted ?? this.exhausted,
        sleepless: sleepless ?? this.sleepless,
        thirsty: thirsty ?? this.thirsty,
        hungry: hungry ?? this.hungry,
      );

  @override
  List<Object?> get props => [exhausted, sleepless, thirsty, hungry];
}

/// A critical injury entry.
class DomainCriticalInjury extends Equatable {
  const DomainCriticalInjury({
    required this.id,
    required this.name,
    required this.severity,
    required this.effect,
    required this.acquiredAt,
  });

  final String id;
  final String name;
  final String severity; // 'light' | 'severe' | 'critical'
  final String effect;
  final DateTime acquiredAt;

  @override
  List<Object?> get props => [id, name, severity, effect, acquiredAt];
}

/// A talent record.
class DomainTalent extends Equatable {
  const DomainTalent({
    required this.id,
    required this.name,
    required this.description,
    required this.rank,
    required this.acquiredAt,
  });

  final String id;
  final String name;
  final String description;
  final int rank;
  final DateTime acquiredAt;

  DomainTalent copyWith({
    String? id,
    String? name,
    String? description,
    int? rank,
    DateTime? acquiredAt,
  }) =>
      DomainTalent(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        rank: rank ?? this.rank,
        acquiredAt: acquiredAt ?? this.acquiredAt,
      );

  @override
  List<Object?> get props => [id, name, description, rank, acquiredAt];
}

/// Item type discriminator — mirrors the OpenAPI `type` field.
enum ItemType { weapon, armor, gear, cybernetic, shipModule, other }

/// A flattened domain item representation covering all 6 types.
///
/// Fields that are not applicable to a given type will be null.
class DomainItem extends Equatable {
  const DomainItem({
    required this.id,
    required this.type,
    required this.name,
    this.weight,
    this.equipped,
    // Weapon
    this.damage,
    this.range,
    this.bonus,
    this.crit,
    this.features,
    // Armor
    this.armorRating,
    // Gear / Other
    this.quantity,
    this.notes,
    // Cybernetic
    this.bodyPoints,
    // ShipModule
    this.effect,
  });

  final String id;
  final ItemType type;
  final String name;
  final num? weight;
  final bool? equipped;
  final int? damage;
  final String? range;
  final int? bonus;
  final int? crit;
  final List<String>? features;
  final int? armorRating;
  final int? quantity;
  final String? notes;
  final int? bodyPoints;
  final String? effect;

  DomainItem copyWith({
    String? id,
    ItemType? type,
    String? name,
    num? weight,
    bool? equipped,
    int? damage,
    String? range,
    int? bonus,
    int? crit,
    List<String>? features,
    int? armorRating,
    int? quantity,
    String? notes,
    int? bodyPoints,
    String? effect,
  }) =>
      DomainItem(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        weight: weight ?? this.weight,
        equipped: equipped ?? this.equipped,
        damage: damage ?? this.damage,
        range: range ?? this.range,
        bonus: bonus ?? this.bonus,
        crit: crit ?? this.crit,
        features: features ?? this.features,
        armorRating: armorRating ?? this.armorRating,
        quantity: quantity ?? this.quantity,
        notes: notes ?? this.notes,
        bodyPoints: bodyPoints ?? this.bodyPoints,
        effect: effect ?? this.effect,
      );

  @override
  List<Object?> get props => [
        id, type, name, weight, equipped, damage, range, bonus, crit,
        features, armorRating, quantity, notes, bodyPoints, effect,
      ];
}

// ── Aggregate ────────────────────────────────────────────────────────────────

/// Domain model for a Coriolis character (full sheet).
///
/// Immutable; built from the `app_api_client` generated `Character` in the
/// data layer. Presentation never imports `app_api_client` types directly.
///
/// Enum-shaped fields ([concept], [iconId], [role], [crewConcept],
/// [upbringing], [mutantLineage], [status]) are stored as their kebab-case
/// wire-string form so the presentation layer never needs to import the
/// generated typed enums.
class Character extends Equatable {
  const Character({
    required this.id,
    required this.ownerId,
    required this.name,
    this.concept,
    this.role,
    this.roleUnmigrated = false,
    this.iconId,
    this.upbringing = 'plebeian',
    this.origin,
    this.reputation = 2,
    this.startingWealth = 500,
    this.birr = 500,
    this.crewConcept,
    this.mutant = false,
    this.mutantLineage,
    this.status = 'active',
    required this.attributes,
    required this.skills,
    required this.hp,
    required this.mp,
    required this.encumbrance,
    required this.experience,
    required this.conditions,
    required this.criticalInjuries,
    required this.talents,
    required this.inventory,
    this.notes,
    required this.updatedAt,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String? concept;
  final String? role;
  final bool roleUnmigrated;
  final String? iconId;
  final String upbringing;
  final String? origin;
  final int reputation;
  final int startingWealth;
  final int birr;
  final String? crewConcept;
  final bool mutant;
  final String? mutantLineage;
  final String status; // 'draft' | 'active'
  final CharacterAttributes attributes;
  final CharacterSkills skills;
  final CharacterHp hp;
  final CharacterMp mp;
  final CharacterEncumbrance encumbrance;
  final int experience;
  final CharacterConditions conditions;
  final List<DomainCriticalInjury> criticalInjuries;
  final List<DomainTalent> talents;
  final List<DomainItem> inventory;
  final String? notes;
  final DateTime updatedAt;
  final DateTime createdAt;

  /// Derive initials for [AppAvatar] rendering.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(1, 2)).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Character copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? concept,
    String? role,
    bool? roleUnmigrated,
    String? iconId,
    String? upbringing,
    String? origin,
    int? reputation,
    int? startingWealth,
    int? birr,
    String? crewConcept,
    bool? mutant,
    String? mutantLineage,
    String? status,
    CharacterAttributes? attributes,
    CharacterSkills? skills,
    CharacterHp? hp,
    CharacterMp? mp,
    CharacterEncumbrance? encumbrance,
    int? experience,
    CharacterConditions? conditions,
    List<DomainCriticalInjury>? criticalInjuries,
    List<DomainTalent>? talents,
    List<DomainItem>? inventory,
    String? notes,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return Character(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      concept: concept ?? this.concept,
      role: role ?? this.role,
      roleUnmigrated: roleUnmigrated ?? this.roleUnmigrated,
      iconId: iconId ?? this.iconId,
      upbringing: upbringing ?? this.upbringing,
      origin: origin ?? this.origin,
      reputation: reputation ?? this.reputation,
      startingWealth: startingWealth ?? this.startingWealth,
      birr: birr ?? this.birr,
      crewConcept: crewConcept ?? this.crewConcept,
      mutant: mutant ?? this.mutant,
      mutantLineage: mutantLineage ?? this.mutantLineage,
      status: status ?? this.status,
      attributes: attributes ?? this.attributes,
      skills: skills ?? this.skills,
      hp: hp ?? this.hp,
      mp: mp ?? this.mp,
      encumbrance: encumbrance ?? this.encumbrance,
      experience: experience ?? this.experience,
      conditions: conditions ?? this.conditions,
      criticalInjuries: criticalInjuries ?? this.criticalInjuries,
      talents: talents ?? this.talents,
      inventory: inventory ?? this.inventory,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, ownerId, name, concept, role, roleUnmigrated, iconId,
        upbringing, origin, reputation, startingWealth, birr,
        crewConcept, mutant, mutantLineage, status,
        attributes, skills, hp, mp,
        encumbrance, experience, conditions, criticalInjuries, talents,
        inventory, notes, updatedAt, createdAt,
      ];
}
