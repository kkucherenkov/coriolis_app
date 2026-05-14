//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item.dart';
import 'package:app_api_client/src/model/upbringing.dart';
import 'package:app_api_client/src/model/mutant_lineage.dart';
import 'package:app_api_client/src/model/character_mp.dart';
import 'package:app_api_client/src/model/talent.dart';
import 'package:app_api_client/src/model/critical_injury.dart';
import 'package:app_api_client/src/model/icon_id.dart';
import 'package:app_api_client/src/model/character_hp.dart';
import 'package:app_api_client/src/model/relationship.dart';
import 'package:app_api_client/src/model/crew_concept.dart';
import 'package:app_api_client/src/model/skills.dart';
import 'package:app_api_client/src/model/attributes.dart';
import 'package:app_api_client/src/model/condition_flags.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/character_encumbrance.dart';
import 'package:app_api_client/src/model/concept.dart';
import 'package:app_api_client/src/model/role.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'character.g.dart';

/// Full character DTO as returned by the v1 API. Server-derived fields (`hp.max`, `mp.max`, `encumbrance.max`) are computed by the RulesEngine on every write and are marked `readOnly`.  Formulas (PRD §5.2, §10): - HP max = STR + AGI - MP max = WIT + EMP - Encumbrance max = STR × 2 
///
/// Properties:
/// * [id] - Opaque character identifier (cuid2)
/// * [ownerId] - Identifier of the owning user (cuid2)
/// * [name] - Character name (1–80 characters)
/// * [concept] 
/// * [role] 
/// * [roleUnmigrated] - Server-side flag, true on rows backfilled by the canon-alignment migration that introduced `Character.role` (T-2026-05-10-010 Block E). The migration assigned each existing character the first canonical role of their amplua and set this flag so the web sheet can prompt the user to confirm or pick a different one. Cleared automatically by the server the first time the user PATCHes `role` to a non-null value (the explicit confirmation path). Always false on characters created after the migration ran. Read-only — clients do not set this; the server owns the lifecycle. 
/// * [iconId] 
/// * [upbringing] - Social stratum the character was raised in. Set at creation and **immutable** — drives the starting attribute / skill point budgets and the initial values of `reputation` and `startingWealth`. 
/// * [origin] - Free-text narrative description of where the character is from (home station, planet, or region). Has no mechanical effect. 
/// * [reputation] - Current social reputation. Initial value is derived from `upbringing` (plebeian=2, stationary=4, aristocrat=6) and may change during play. 
/// * [startingWealth] - The number of birrs (currency) the character started with at creation. Derived from `upbringing` (plebeian=500, stationary=1000, aristocrat=5000). Immutable historical record. 
/// * [birr] - Current spendable birr balance (the character's wallet). Seeded from `startingWealth` when the wizard transitions `status: draft → active` (the forge step). Mutable any time after activation — debited on Bazaar purchases via the items API and credited from session payouts via PATCH. While the character is still a `draft`, the server keeps `birr` in lock-step with `startingWealth` so changing `upbringing` does not strand a stale balance; explicit PATCHes to `birr` on a draft are rejected with `BIRR_DRAFT_IMMUTABLE`. 
/// * [crewConcept] 
/// * [mutant] - Whether this character is a mutant (пасынок) per Coriolis ST3001 ch.4 §Стигмы пасынков. Mutants additionally pick one starting talent of `kind: stigma` from the catalog (any of the three stigmas) through the regular `addTalent` endpoint. Mutable while `status: draft` and immutable once `active` — `MUTANT_IMMUTABLE`. When `true`, `mutantLineage` must be set; when `false`, `mutantLineage` must be `null`. 
/// * [mutantLineage] 
/// * [attributes] 
/// * [skills] 
/// * [hp] 
/// * [mp] 
/// * [encumbrance] 
/// * [experience] - Total XP earned
/// * [conditions] 
/// * [criticalInjuries] 
/// * [talents] 
/// * [relationships] 
/// * [inventory] 
/// * [notes] - Free-form notes (Markdown; soft cap 4096 characters)
/// * [status] - Lifecycle state of the character.  - `draft` — character is a work-in-progress created by the wizard.   Draft characters are excluded from the default character list   (`GET /api/v1/characters`) unless `?includeDrafts=true` is passed. - `active` — character is complete and visible on the dashboard.  Transitioning from `draft` to `active` (forging) is done by sending `PATCH /api/v1/characters/{id}` with `{ \"status\": \"active\" }`. The reverse transition (`active → draft`) is rejected with 422 `INVALID_STATUS_TRANSITION`. 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class Character implements Built<Character, CharacterBuilder> {
  /// Opaque character identifier (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Identifier of the owning user (cuid2)
  @BuiltValueField(wireName: r'ownerId')
  String get ownerId;

  /// Character name (1–80 characters)
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'concept')
  Concept? get concept;
  // enum conceptEnum {  artist,  networker,  fugitive,  negotiator,  operative,  pilot,  pioneer,  preacher,  scientist,  sailor,  soldier,  };

  @BuiltValueField(wireName: r'role')
  Role? get role;
  // enum roleEnum {  companion,  musician,  poet,  analyst,  correspondent,  network-djinn,  criminal,  mystic,  revolutionary,  agitator,  diplomat,  dealer,  assassin,  guard,  spy,  ace,  driver,  trucker,  colonist,  prospector,  scout,  ascetic,  missionary,  prophet,  archaeologist,  medicurg,  technologist,  ship-engineer,  labourer,  loader,  legionnaire,  mercenary,  officer,  };

  /// Server-side flag, true on rows backfilled by the canon-alignment migration that introduced `Character.role` (T-2026-05-10-010 Block E). The migration assigned each existing character the first canonical role of their amplua and set this flag so the web sheet can prompt the user to confirm or pick a different one. Cleared automatically by the server the first time the user PATCHes `role` to a non-null value (the explicit confirmation path). Always false on characters created after the migration ran. Read-only — clients do not set this; the server owns the lifecycle. 
  @BuiltValueField(wireName: r'roleUnmigrated')
  bool? get roleUnmigrated;

  @BuiltValueField(wireName: r'iconId')
  IconId? get iconId;
  // enum iconIdEnum {  lady-of-tears,  traveler,  messenger,  merchant,  dancer,  gambler,  judge,  faceless-one,  deckhand,  };

  /// Social stratum the character was raised in. Set at creation and **immutable** — drives the starting attribute / skill point budgets and the initial values of `reputation` and `startingWealth`. 
  @BuiltValueField(wireName: r'upbringing')
  Upbringing get upbringing;
  // enum upbringingEnum {  plebeian,  stationary,  aristocrat,  };

  /// Free-text narrative description of where the character is from (home station, planet, or region). Has no mechanical effect. 
  @BuiltValueField(wireName: r'origin')
  String? get origin;

  /// Current social reputation. Initial value is derived from `upbringing` (plebeian=2, stationary=4, aristocrat=6) and may change during play. 
  @BuiltValueField(wireName: r'reputation')
  int get reputation;

  /// The number of birrs (currency) the character started with at creation. Derived from `upbringing` (plebeian=500, stationary=1000, aristocrat=5000). Immutable historical record. 
  @BuiltValueField(wireName: r'startingWealth')
  int get startingWealth;

  /// Current spendable birr balance (the character's wallet). Seeded from `startingWealth` when the wizard transitions `status: draft → active` (the forge step). Mutable any time after activation — debited on Bazaar purchases via the items API and credited from session payouts via PATCH. While the character is still a `draft`, the server keeps `birr` in lock-step with `startingWealth` so changing `upbringing` does not strand a stale balance; explicit PATCHes to `birr` on a draft are rejected with `BIRR_DRAFT_IMMUTABLE`. 
  @BuiltValueField(wireName: r'birr')
  int? get birr;

  @BuiltValueField(wireName: r'crewConcept')
  CrewConcept? get crewConcept;
  // enum crewConceptEnum {  free-trader,  mercenary,  explorer,  agents,  pilgrim,  };

  /// Whether this character is a mutant (пасынок) per Coriolis ST3001 ch.4 §Стигмы пасынков. Mutants additionally pick one starting talent of `kind: stigma` from the catalog (any of the three stigmas) through the regular `addTalent` endpoint. Mutable while `status: draft` and immutable once `active` — `MUTANT_IMMUTABLE`. When `true`, `mutantLineage` must be set; when `false`, `mutantLineage` must be `null`. 
  @BuiltValueField(wireName: r'mutant')
  bool get mutant;

  @BuiltValueField(wireName: r'mutantLineage')
  MutantLineage? get mutantLineage;
  // enum mutantLineageEnum {  zirba,  shingura,  nerida,  };

  @BuiltValueField(wireName: r'attributes')
  Attributes get attributes;

  @BuiltValueField(wireName: r'skills')
  Skills get skills;

  @BuiltValueField(wireName: r'hp')
  CharacterHp get hp;

  @BuiltValueField(wireName: r'mp')
  CharacterMp get mp;

  @BuiltValueField(wireName: r'encumbrance')
  CharacterEncumbrance get encumbrance;

  /// Total XP earned
  @BuiltValueField(wireName: r'experience')
  int get experience;

  @BuiltValueField(wireName: r'conditions')
  ConditionFlags get conditions;

  @BuiltValueField(wireName: r'criticalInjuries')
  BuiltList<CriticalInjury> get criticalInjuries;

  @BuiltValueField(wireName: r'talents')
  BuiltList<Talent> get talents;

  @BuiltValueField(wireName: r'relationships')
  BuiltList<Relationship> get relationships;

  @BuiltValueField(wireName: r'inventory')
  BuiltList<Item> get inventory;

  /// Free-form notes (Markdown; soft cap 4096 characters)
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// Lifecycle state of the character.  - `draft` — character is a work-in-progress created by the wizard.   Draft characters are excluded from the default character list   (`GET /api/v1/characters`) unless `?includeDrafts=true` is passed. - `active` — character is complete and visible on the dashboard.  Transitioning from `draft` to `active` (forging) is done by sending `PATCH /api/v1/characters/{id}` with `{ \"status\": \"active\" }`. The reverse transition (`active → draft`) is rejected with 422 `INVALID_STATUS_TRANSITION`. 
  @BuiltValueField(wireName: r'status')
  CharacterStatusEnum get status;
  // enum statusEnum {  draft,  active,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  Character._();

  factory Character([void updates(CharacterBuilder b)]) = _$Character;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CharacterBuilder b) => b
      ..roleUnmigrated = false
      ..mutant = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<Character> get serializer => _$CharacterSerializer();
}

class _$CharacterSerializer implements PrimitiveSerializer<Character> {
  @override
  final Iterable<Type> types = const [Character, _$Character];

  @override
  final String wireName = r'Character';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Character object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'ownerId';
    yield serializers.serialize(
      object.ownerId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'concept';
    yield object.concept == null ? null : serializers.serialize(
      object.concept,
      specifiedType: const FullType.nullable(Concept),
    );
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType.nullable(Role),
      );
    }
    if (object.roleUnmigrated != null) {
      yield r'roleUnmigrated';
      yield serializers.serialize(
        object.roleUnmigrated,
        specifiedType: const FullType(bool),
      );
    }
    yield r'iconId';
    yield object.iconId == null ? null : serializers.serialize(
      object.iconId,
      specifiedType: const FullType.nullable(IconId),
    );
    yield r'upbringing';
    yield serializers.serialize(
      object.upbringing,
      specifiedType: const FullType(Upbringing),
    );
    yield r'origin';
    yield object.origin == null ? null : serializers.serialize(
      object.origin,
      specifiedType: const FullType.nullable(String),
    );
    yield r'reputation';
    yield serializers.serialize(
      object.reputation,
      specifiedType: const FullType(int),
    );
    yield r'startingWealth';
    yield serializers.serialize(
      object.startingWealth,
      specifiedType: const FullType(int),
    );
    if (object.birr != null) {
      yield r'birr';
      yield serializers.serialize(
        object.birr,
        specifiedType: const FullType(int),
      );
    }
    yield r'crewConcept';
    yield object.crewConcept == null ? null : serializers.serialize(
      object.crewConcept,
      specifiedType: const FullType.nullable(CrewConcept),
    );
    yield r'mutant';
    yield serializers.serialize(
      object.mutant,
      specifiedType: const FullType(bool),
    );
    yield r'mutantLineage';
    yield object.mutantLineage == null ? null : serializers.serialize(
      object.mutantLineage,
      specifiedType: const FullType.nullable(MutantLineage),
    );
    yield r'attributes';
    yield serializers.serialize(
      object.attributes,
      specifiedType: const FullType(Attributes),
    );
    yield r'skills';
    yield serializers.serialize(
      object.skills,
      specifiedType: const FullType(Skills),
    );
    yield r'hp';
    yield serializers.serialize(
      object.hp,
      specifiedType: const FullType(CharacterHp),
    );
    yield r'mp';
    yield serializers.serialize(
      object.mp,
      specifiedType: const FullType(CharacterMp),
    );
    yield r'encumbrance';
    yield serializers.serialize(
      object.encumbrance,
      specifiedType: const FullType(CharacterEncumbrance),
    );
    yield r'experience';
    yield serializers.serialize(
      object.experience,
      specifiedType: const FullType(int),
    );
    yield r'conditions';
    yield serializers.serialize(
      object.conditions,
      specifiedType: const FullType(ConditionFlags),
    );
    yield r'criticalInjuries';
    yield serializers.serialize(
      object.criticalInjuries,
      specifiedType: const FullType(BuiltList, [FullType(CriticalInjury)]),
    );
    yield r'talents';
    yield serializers.serialize(
      object.talents,
      specifiedType: const FullType(BuiltList, [FullType(Talent)]),
    );
    yield r'relationships';
    yield serializers.serialize(
      object.relationships,
      specifiedType: const FullType(BuiltList, [FullType(Relationship)]),
    );
    yield r'inventory';
    yield serializers.serialize(
      object.inventory,
      specifiedType: const FullType(BuiltList, [FullType(Item)]),
    );
    yield r'notes';
    yield object.notes == null ? null : serializers.serialize(
      object.notes,
      specifiedType: const FullType.nullable(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(CharacterStatusEnum),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Character object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CharacterBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'ownerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ownerId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'concept':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Concept),
          ) as Concept?;
          if (valueDes == null) continue;
          result.concept = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Role),
          ) as Role?;
          if (valueDes == null) continue;
          result.role = valueDes;
          break;
        case r'roleUnmigrated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.roleUnmigrated = valueDes;
          break;
        case r'iconId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(IconId),
          ) as IconId?;
          if (valueDes == null) continue;
          result.iconId = valueDes;
          break;
        case r'upbringing':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Upbringing),
          ) as Upbringing;
          result.upbringing = valueDes;
          break;
        case r'origin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.origin = valueDes;
          break;
        case r'reputation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.reputation = valueDes;
          break;
        case r'startingWealth':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.startingWealth = valueDes;
          break;
        case r'birr':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.birr = valueDes;
          break;
        case r'crewConcept':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CrewConcept),
          ) as CrewConcept?;
          if (valueDes == null) continue;
          result.crewConcept = valueDes;
          break;
        case r'mutant':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.mutant = valueDes;
          break;
        case r'mutantLineage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MutantLineage),
          ) as MutantLineage?;
          if (valueDes == null) continue;
          result.mutantLineage = valueDes;
          break;
        case r'attributes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Attributes),
          ) as Attributes;
          result.attributes.replace(valueDes);
          break;
        case r'skills':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Skills),
          ) as Skills;
          result.skills.replace(valueDes);
          break;
        case r'hp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CharacterHp),
          ) as CharacterHp;
          result.hp.replace(valueDes);
          break;
        case r'mp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CharacterMp),
          ) as CharacterMp;
          result.mp.replace(valueDes);
          break;
        case r'encumbrance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CharacterEncumbrance),
          ) as CharacterEncumbrance;
          result.encumbrance.replace(valueDes);
          break;
        case r'experience':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.experience = valueDes;
          break;
        case r'conditions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ConditionFlags),
          ) as ConditionFlags;
          result.conditions.replace(valueDes);
          break;
        case r'criticalInjuries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CriticalInjury)]),
          ) as BuiltList<CriticalInjury>;
          result.criticalInjuries.replace(valueDes);
          break;
        case r'talents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Talent)]),
          ) as BuiltList<Talent>;
          result.talents.replace(valueDes);
          break;
        case r'relationships':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Relationship)]),
          ) as BuiltList<Relationship>;
          result.relationships.replace(valueDes);
          break;
        case r'inventory':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Item)]),
          ) as BuiltList<Item>;
          result.inventory.replace(valueDes);
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CharacterStatusEnum),
          ) as CharacterStatusEnum;
          result.status = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Character deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CharacterBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class CharacterStatusEnum extends EnumClass {

  /// Lifecycle state of the character.  - `draft` — character is a work-in-progress created by the wizard.   Draft characters are excluded from the default character list   (`GET /api/v1/characters`) unless `?includeDrafts=true` is passed. - `active` — character is complete and visible on the dashboard.  Transitioning from `draft` to `active` (forging) is done by sending `PATCH /api/v1/characters/{id}` with `{ \"status\": \"active\" }`. The reverse transition (`active → draft`) is rejected with 422 `INVALID_STATUS_TRANSITION`. 
  @BuiltValueEnumConst(wireName: r'draft')
  static const CharacterStatusEnum draft = _$characterStatusEnum_draft;
  /// Lifecycle state of the character.  - `draft` — character is a work-in-progress created by the wizard.   Draft characters are excluded from the default character list   (`GET /api/v1/characters`) unless `?includeDrafts=true` is passed. - `active` — character is complete and visible on the dashboard.  Transitioning from `draft` to `active` (forging) is done by sending `PATCH /api/v1/characters/{id}` with `{ \"status\": \"active\" }`. The reverse transition (`active → draft`) is rejected with 422 `INVALID_STATUS_TRANSITION`. 
  @BuiltValueEnumConst(wireName: r'active')
  static const CharacterStatusEnum active = _$characterStatusEnum_active;

  static Serializer<CharacterStatusEnum> get serializer => _$characterStatusEnumSerializer;

  const CharacterStatusEnum._(String name): super(name);

  static BuiltSet<CharacterStatusEnum> get values => _$characterStatusEnumValues;
  static CharacterStatusEnum valueOf(String name) => _$characterStatusEnumValueOf(name);
}

