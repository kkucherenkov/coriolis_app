import 'package:app_api_client/app_api_client.dart'
    show
        CharactersApi,
        CharacterCreate,
        CharacterCreateStatusEnum,
        CharacterUpdate,
        CharacterUpdateStatusEnum,
        TalentCreate,
        TalentUpdate,
        ItemCreate,
        ItemUpdate,
        ItemWeaponCreate,
        ItemWeaponCreateTypeEnum,
        ItemArmorCreate,
        ItemArmorCreateTypeEnum,
        ItemGearCreate,
        ItemGearCreateTypeEnum,
        ItemCyberneticCreate,
        ItemCyberneticCreateTypeEnum,
        ItemShipModuleCreate,
        ItemShipModuleCreateTypeEnum,
        ItemShipModuleUpdate,
        ItemShipModuleUpdateTypeEnum,
        ItemOtherCreate,
        ItemOtherCreateTypeEnum,
        ItemWeaponUpdate,
        ItemWeaponUpdateTypeEnum,
        ItemArmorUpdate,
        ItemArmorUpdateTypeEnum,
        ItemGearUpdate,
        ItemGearUpdateTypeEnum,
        ItemCyberneticUpdate,
        ItemCyberneticUpdateTypeEnum,
        ItemOtherUpdate,
        ItemOtherUpdateTypeEnum,
        ItemRangeEnum,
        ShipModuleSlot,
        Attributes,
        Skills,
        ConditionFlags,
        CharacterCreateHp,
        CriticalInjury,
        CriticalInjurySeverity,
        CrewConcept,
        IconId,
        MutantLineage,
        Role,
        Upbringing;
import 'package:app_api_client/app_api_client.dart' as api_client show Concept;

import 'package:coriolis_companion/features/characters/data/character_api_mapper.dart';

import 'package:built_collection/built_collection.dart';
import 'package:one_of/one_of.dart';

import 'package:coriolis_companion/features/characters/domain/character.dart';
import 'package:coriolis_companion/features/characters/domain/character_repository.dart';
import 'package:coriolis_companion/features/characters/domain/character_summary.dart';

/// Adapter bridging [CharactersApi] with the domain [CharacterRepository].
///
/// All API types are contained to this file. The presentation layer uses
/// domain types exclusively.
class CharacterRepositoryImpl implements CharacterRepository {
  const CharacterRepositoryImpl({required CharactersApi api}) : _api = api;

  final CharactersApi _api;

  // ── Mapping: Domain → API ────────────────────────────────────────────────

  static Attributes? _attributesToApi(CharacterAttributes? a) {
    if (a == null) return null;
    return Attributes((b) => b
      ..strength = a.strength
      ..agility = a.agility
      ..wits = a.wits
      ..empathy = a.empathy);
  }

  static Skills? _skillsToApi(CharacterSkills? s) {
    if (s == null) return null;
    return Skills((b) => b
      ..dexterity = s.dexterity
      ..force = s.force
      ..infiltration = s.infiltration
      ..manipulation = s.manipulation
      ..meleeCombat = s.meleeCombat
      ..observation = s.observation
      ..rangedCombat = s.rangedCombat
      ..survival = s.survival
      ..command = s.command
      ..culture = s.culture
      ..dataDjinn = s.dataDjinn
      ..medicurgy = s.medicurgy
      ..mysticPowers = s.mysticPowers
      ..pilot = s.pilot
      ..science = s.science
      ..technology = s.technology);
  }

  static ConditionFlags? _conditionsToApi(CharacterConditions? c) {
    if (c == null) return null;
    return ConditionFlags((b) => b
      ..exhausted = c.exhausted
      ..sleepless = c.sleepless
      ..thirsty = c.thirsty
      ..hungry = c.hungry);
  }

  static CharacterCreateHp? _hpToApi(CharacterHp? hp) {
    if (hp == null) return null;
    return CharacterCreateHp((b) => b..current = hp.current);
  }

  static CharacterCreateHp? _mpToApi(CharacterMp? mp) {
    if (mp == null) return null;
    return CharacterCreateHp((b) => b..current = mp.current);
  }

  // ── CharacterRepository ──────────────────────────────────────────────────

  @override
  Future<List<CharacterSummary>> list({int limit = 20}) async {
    final response = await _api.listCharacters(limit: limit);
    final body = response.data;
    if (body == null) return [];
    return body.items.map(CharacterApiMapper.toSummary).toList();
  }

  @override
  Future<Character> get(String id) async {
    final response = await _api.getCharacter(id: id);
    final body = response.data;
    if (body == null) throw StateError('Empty response for character $id');
    return CharacterApiMapper.toDomain(body);
  }

  @override
  Future<Character> create({
    required String name,
    required String upbringing,
    String? status,
  }) async {
    final payload = CharacterCreate((b) {
      b.name = name;
      b.upbringing = Upbringing.valueOf(upbringing);
      if (status != null) {
        b.status = CharacterCreateStatusEnum.valueOf(status);
      }
    });
    final response = await _api.createCharacter(characterCreate: payload);
    final body = response.data;
    if (body == null) throw StateError('Empty response after create');
    return CharacterApiMapper.toDomain(body);
  }

  @override
  Future<Character> update(
    String id, {
    String? name,
    String? concept,
    String? role,
    String? iconId,
    String? upbringing,
    String? origin,
    String? crewConcept,
    bool? mutant,
    String? mutantLineage,
    int? reputation,
    int? birr,
    CharacterAttributes? attributes,
    CharacterSkills? skills,
    CharacterHp? hp,
    CharacterMp? mp,
    int? experience,
    CharacterConditions? conditions,
    List<DomainCriticalInjury>? criticalInjuries,
    String? notes,
    String? status,
  }) async {
    final payload = CharacterUpdate((b) {
      if (name != null) b.name = name;
      // Domain stores enum-shaped fields as the Dart-side `EnumClass.name`
      // (camelCase). Route every enum field through its `valueOf` to get
      // the typed SDK value.
      if (concept != null) b.concept = api_client.Concept.valueOf(concept);
      if (role != null) b.role = Role.valueOf(role);
      if (iconId != null) b.iconId = IconId.valueOf(iconId);
      if (upbringing != null) b.upbringing = Upbringing.valueOf(upbringing);
      if (origin != null) b.origin = origin;
      if (crewConcept != null) {
        b.crewConcept = CrewConcept.valueOf(crewConcept);
      }
      if (mutant != null) b.mutant = mutant;
      if (mutantLineage != null) {
        b.mutantLineage = MutantLineage.valueOf(mutantLineage);
      }
      if (reputation != null) b.reputation = reputation;
      if (birr != null) b.birr = birr;
      if (experience != null) b.experience = experience;
      if (notes != null) b.notes = notes;
      if (status != null) {
        b.status = CharacterUpdateStatusEnum.valueOf(status);
      }
      final apiAttrs = _attributesToApi(attributes);
      if (apiAttrs != null) b.attributes.replace(apiAttrs);
      final apiSkills = _skillsToApi(skills);
      if (apiSkills != null) b.skills.replace(apiSkills);
      final apiCond = _conditionsToApi(conditions);
      if (apiCond != null) b.conditions.replace(apiCond);
      final apiHp = _hpToApi(hp);
      if (apiHp != null) b.hp.replace(apiHp);
      final apiMp = _mpToApi(mp);
      if (apiMp != null) b.mp.replace(apiMp);
      if (criticalInjuries != null) {
        b.criticalInjuries.replace(
          criticalInjuries.map((ci) => CriticalInjury((cb) => cb
            ..id = ci.id
            ..name = ci.name
            ..severity = CriticalInjurySeverity.valueOf(ci.severity)
            ..effect = ci.effect
            ..acquiredAt = ci.acquiredAt)),
        );
      }
    });
    final response =
        await _api.updateCharacter(id: id, characterUpdate: payload);
    final body = response.data;
    if (body == null) throw StateError('Empty response after update');
    return CharacterApiMapper.toDomain(body);
  }

  @override
  Future<void> delete(String id) async {
    await _api.deleteCharacter(id: id);
  }

  // ── Talents ──────────────────────────────────────────────────────────────

  @override
  Future<DomainTalent> addTalent(
    String characterId, {
    required String name,
    required String description,
    int rank = 1,
  }) async {
    final payload = TalentCreate((b) => b
      ..name = name
      ..description = description
      ..rank = rank);
    final response = await _api.addCharacterTalent(
      id: characterId,
      talentCreate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after addTalent');
    return CharacterApiMapper.talentToDomain(body);
  }

  @override
  Future<DomainTalent> updateTalent(
    String characterId,
    String talentId, {
    String? name,
    String? description,
    int? rank,
  }) async {
    final payload = TalentUpdate((b) {
      if (name != null) b.name = name;
      if (description != null) b.description = description;
      if (rank != null) b.rank = rank;
    });
    final response = await _api.updateTalent(
      id: talentId,
      talentUpdate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after updateTalent');
    return CharacterApiMapper.talentToDomain(body);
  }

  @override
  Future<void> removeTalent(String characterId, String talentId) async {
    await _api.deleteTalent(id: talentId);
  }

  // ── Inventory ────────────────────────────────────────────────────────────

  @override
  Future<DomainItem> addItem(String characterId, DomainItem draft) async {
    final payload = _domainItemToCreate(draft);
    final response = await _api.addCharacterItem(
      id: characterId,
      itemCreate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after addItem');
    return CharacterApiMapper.itemToDomain(body);
  }

  @override
  Future<DomainItem> updateItem(
    String characterId,
    String itemId,
    DomainItem patch,
  ) async {
    final payload = _domainItemToUpdate(patch);
    final response = await _api.updateItem(
      id: itemId,
      itemUpdate: payload,
    );
    final body = response.data;
    if (body == null) throw StateError('Empty response after updateItem');
    return CharacterApiMapper.itemToDomain(body);
  }

  @override
  Future<void> removeItem(String characterId, String itemId) async {
    await _api.deleteItem(id: itemId);
  }

  // ── Internal helpers ─────────────────────────────────────────────────────

  static final _weaponCreateTypes = [
    ItemArmorCreate, ItemCyberneticCreate, ItemGearCreate,
    ItemOtherCreate, ItemShipModuleCreate, ItemWeaponCreate,
  ];
  static final _weaponUpdateTypes = [
    ItemArmorUpdate, ItemCyberneticUpdate, ItemGearUpdate,
    ItemOtherUpdate, ItemShipModuleUpdate, ItemWeaponUpdate,
  ];

  static ItemCreate _domainItemToCreate(DomainItem item) {
    switch (item.type) {
      case ItemType.weapon:
        final raw = ItemWeaponCreate((b) => b
          ..type = ItemWeaponCreateTypeEnum.WEAPON
          ..name = item.name
          ..damage = item.damage ?? 1
          ..range = _parseRange(item.range)
          ..bonus = item.bonus ?? 0
          ..crit = item.crit ?? 1
          ..weight = item.weight ?? 1
          ..equipped = item.equipped ?? false
          ..features.replace(
              BuiltList<String>.from(item.features ?? <String>[])));
        return ItemCreate((b) => b
          ..oneOf = OneOfDynamic(
            typeIndex: _weaponCreateTypes.indexOf(ItemWeaponCreate),
            types: _weaponCreateTypes,
            value: raw,
          ));
      case ItemType.armor:
        final raw = ItemArmorCreate((b) => b
          ..type = ItemArmorCreateTypeEnum.ARMOR
          ..name = item.name
          ..armorRating = item.armorRating ?? 0
          ..weight = item.weight ?? 1
          ..equipped = item.equipped ?? false
          ..features.replace(
              BuiltList<String>.from(item.features ?? <String>[])));
        return ItemCreate((b) => b
          ..oneOf = OneOfDynamic(
            typeIndex: _weaponCreateTypes.indexOf(ItemArmorCreate),
            types: _weaponCreateTypes,
            value: raw,
          ));
      case ItemType.gear:
        final raw = ItemGearCreate((b) => b
          ..type = ItemGearCreateTypeEnum.GEAR
          ..name = item.name
          ..weight = item.weight ?? 1
          ..quantity = item.quantity ?? 1
          ..notes = item.notes);
        return ItemCreate((b) => b
          ..oneOf = OneOfDynamic(
            typeIndex: _weaponCreateTypes.indexOf(ItemGearCreate),
            types: _weaponCreateTypes,
            value: raw,
          ));
      case ItemType.cybernetic:
        // Spec dropped `bodyPoints`; cyberware is XP-priced now. Default
        // to the canonical 5 XP cost (ГЛАВА 4) when the editor hasn't
        // surfaced XP cost yet — accepted range is 0..15.
        final raw = ItemCyberneticCreate((b) => b
          ..type = ItemCyberneticCreateTypeEnum.CYBERNETIC
          ..name = item.name
          ..xpCost = 5
          ..effect = item.effect ?? '');
        return ItemCreate((b) => b
          ..oneOf = OneOfDynamic(
            typeIndex: _weaponCreateTypes.indexOf(ItemCyberneticCreate),
            types: _weaponCreateTypes,
            value: raw,
          ));
      case ItemType.shipModule:
        // Spec renamed the slot enum (`ItemSlotType` → `ShipModuleSlot`)
        // and collapsed values. The character-inventory ItemShipModule
        // doesn't carry a slot in the domain layer, so default to HOLD
        // — the closest semantic match for "ship cargo / generic" slot
        // until a richer mapper lands.
        final raw = ItemShipModuleCreate((b) => b
          ..type = ItemShipModuleCreateTypeEnum.SHIP_MODULE
          ..name = item.name
          ..slot = ShipModuleSlot.HOLD
          ..effect = item.effect ?? '');
        return ItemCreate((b) => b
          ..oneOf = OneOfDynamic(
            typeIndex: _weaponCreateTypes.indexOf(ItemShipModuleCreate),
            types: _weaponCreateTypes,
            value: raw,
          ));
      case ItemType.other:
        final raw = ItemOtherCreate((b) => b
          ..type = ItemOtherCreateTypeEnum.OTHER
          ..name = item.name
          ..weight = item.weight ?? 0
          ..notes = item.notes);
        return ItemCreate((b) => b
          ..oneOf = OneOfDynamic(
            typeIndex: _weaponCreateTypes.indexOf(ItemOtherCreate),
            types: _weaponCreateTypes,
            value: raw,
          ));
    }
  }

  static ItemUpdate _domainItemToUpdate(DomainItem item) {
    switch (item.type) {
      case ItemType.weapon:
        final raw = ItemWeaponUpdate((b) => b
          ..type = ItemWeaponUpdateTypeEnum.WEAPON
          ..name = item.name
          ..damage = item.damage
          ..range = item.range != null ? _parseRange(item.range) : null
          ..bonus = item.bonus
          ..crit = item.crit
          ..weight = item.weight
          ..equipped = item.equipped
          ..features.replace(
              BuiltList<String>.from(item.features ?? <String>[])));
        return ItemUpdate((b) => b
          ..oneOf = OneOfDynamic(
            typeIndex: _weaponUpdateTypes.indexOf(ItemWeaponUpdate),
            types: _weaponUpdateTypes,
            value: raw,
          ));
      case ItemType.armor:
        final raw = ItemArmorUpdate((b) => b
          ..type = ItemArmorUpdateTypeEnum.ARMOR
          ..name = item.name
          ..armorRating = item.armorRating
          ..weight = item.weight
          ..equipped = item.equipped
          ..features.replace(
              BuiltList<String>.from(item.features ?? <String>[])));
        return ItemUpdate((b) => b
          ..oneOf = OneOfDynamic(
            typeIndex: _weaponUpdateTypes.indexOf(ItemArmorUpdate),
            types: _weaponUpdateTypes,
            value: raw,
          ));
      case ItemType.gear:
        final raw = ItemGearUpdate((b) => b
          ..type = ItemGearUpdateTypeEnum.GEAR
          ..name = item.name
          ..weight = item.weight
          ..quantity = item.quantity
          ..notes = item.notes);
        return ItemUpdate((b) => b
          ..oneOf = OneOfDynamic(
            typeIndex: _weaponUpdateTypes.indexOf(ItemGearUpdate),
            types: _weaponUpdateTypes,
            value: raw,
          ));
      case ItemType.cybernetic:
        // bodyPoints retired; xpCost is optional on update so we don't
        // touch it from the mapper. The domain model has no xpCost field
        // yet, so xpCost mutations live with the future Cyberware editor.
        final raw = ItemCyberneticUpdate((b) => b
          ..type = ItemCyberneticUpdateTypeEnum.CYBERNETIC
          ..name = item.name
          ..effect = item.effect);
        return ItemUpdate((b) => b
          ..oneOf = OneOfDynamic(
            typeIndex: _weaponUpdateTypes.indexOf(ItemCyberneticUpdate),
            types: _weaponUpdateTypes,
            value: raw,
          ));
      case ItemType.shipModule:
        final rawSm = ItemShipModuleUpdate((b) => b
          ..type = ItemShipModuleUpdateTypeEnum.SHIP_MODULE
          ..name = item.name
          ..effect = item.effect);
        return ItemUpdate((b) => b
          ..oneOf = OneOfDynamic(
            typeIndex: _weaponUpdateTypes.indexOf(ItemShipModuleUpdate),
            types: _weaponUpdateTypes,
            value: rawSm,
          ));
      case ItemType.other:
        final raw = ItemOtherUpdate((b) => b
          ..type = ItemOtherUpdateTypeEnum.OTHER
          ..name = item.name
          ..weight = item.weight
          ..notes = item.notes);
        return ItemUpdate((b) => b
          ..oneOf = OneOfDynamic(
            typeIndex: _weaponUpdateTypes.indexOf(ItemOtherUpdate),
            types: _weaponUpdateTypes,
            value: raw,
          ));
    }
  }

  /// Maps a wire range string to [ItemRangeEnum].
  ///
  /// The personal-scale range ladder was collapsed from 5 → 4 bands in
  /// the ST3001-faithful migration (`ItemRangeEnum`):
  ///   - `arm` / `near` / `close`     → close   (Ближняя, up to 2 m)
  ///   - `short` / `medium`           → medium  (Средняя, up to 20 m)
  ///   - `long`                       → long    (Дальняя, up to 100 m)
  ///   - `distant` / `extreme`        → extreme (Предельная, up to 1000 m)
  ///
  /// Legacy values surface in old persisted weapon records — translate
  /// them rather than dropping data on the floor.
  static ItemRangeEnum _parseRange(String? range) {
    switch (range) {
      case 'close':
      case 'arm':
      case 'near':
        return ItemRangeEnum.close;
      case 'medium':
      case 'short':
        return ItemRangeEnum.medium;
      case 'long':
        return ItemRangeEnum.long;
      case 'extreme':
      case 'distant':
        return ItemRangeEnum.extreme;
      default:
        return ItemRangeEnum.close;
    }
  }
}
