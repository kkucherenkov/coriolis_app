//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/crew_concept.dart';
import 'package:app_api_client/src/model/skills.dart';
import 'package:app_api_client/src/model/upbringing.dart';
import 'package:app_api_client/src/model/attributes.dart';
import 'package:app_api_client/src/model/condition_flags.dart';
import 'package:app_api_client/src/model/mutant_lineage.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/character_create_hp.dart';
import 'package:app_api_client/src/model/concept.dart';
import 'package:app_api_client/src/model/critical_injury.dart';
import 'package:app_api_client/src/model/icon_id.dart';
import 'package:app_api_client/src/model/role.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'character_update.g.dart';

/// PATCH payload for `PATCH /api/v1/characters/{id}`. All fields are optional. Read-only fields (`id`, `ownerId`, `hp.max`, `mp.max`, `encumbrance.max`, `encumbrance.current`, `startingWealth`, `createdAt`, `updatedAt`) are rejected with 400 if present.  `upbringing` may be changed **while the character's `status` is `draft`** (the wizard is still in progress). When it is, the server recomputes `reputation` and `startingWealth` from the new upbringing. Once the character has been forged (`status: active`), upbringing becomes immutable and any attempt to set it is rejected with `UPBRINGING_IMMUTABLE`.  Derived stats (`hp.max`, `mp.max`, `encumbrance.max`) are recalculated automatically after each successful write.  **Status transitions:** - `draft → draft` — no-op; the wizard continues editing. - `draft → active` — forges the character (wizard complete).   Send `{ \"status\": \"active\" }` as a standalone PATCH or alongside   other field updates. - `active → draft` — **rejected** with 422 `INVALID_STATUS_TRANSITION`.   Active characters cannot be reverted to draft state. 
///
/// Properties:
/// * [name] 
/// * [concept] 
/// * [role] 
/// * [iconId] 
/// * [upbringing] - Allowed only while `status` is `draft` — used by the wizard to let players reconsider their pick before forging. Once the character is `active`, this field is immutable. 
/// * [origin] 
/// * [crewConcept] 
/// * [mutant] - Allowed only while `status` is `draft`. Toggling on/off while drafting also clears any incompatible stigma talents picked previously. Once the character is `active`, this field is immutable and any attempt to change it is rejected with `MUTANT_IMMUTABLE`. 
/// * [mutantLineage] 
/// * [reputation] - Update the character's current reputation (e.g. after a roleplay event). Initial value is set from `upbringing` at creation time; while the character is a `draft`, changing `upbringing` resets `reputation` to the new upbringing's baseline. 
/// * [birr] - Update the current birr balance (Bazaar purchases, session payouts). Allowed only while `status` is `active`. PATCHes to `birr` on a draft are rejected with `BIRR_DRAFT_IMMUTABLE` — the wizard re-seeds birr from `startingWealth` on the forge transition. 
/// * [attributes] 
/// * [skills] 
/// * [hp] 
/// * [mp] 
/// * [experience] 
/// * [conditions] 
/// * [criticalInjuries] - Replaces the entire critical injuries list when provided. Use the dedicated nested-item pattern (POST/PATCH/DELETE on individual injuries) once that surface is added in a later epic. 
/// * [notes] 
/// * [status] - Lifecycle state transition. Only `draft → active` (forge) is permitted. Attempting `active → draft` returns 422 `INVALID_STATUS_TRANSITION`. 
@BuiltValue()
abstract class CharacterUpdate implements Built<CharacterUpdate, CharacterUpdateBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'concept')
  Concept? get concept;
  // enum conceptEnum {  artist,  networker,  fugitive,  negotiator,  operative,  pilot,  pioneer,  preacher,  scientist,  sailor,  soldier,  };

  @BuiltValueField(wireName: r'role')
  Role? get role;
  // enum roleEnum {  companion,  musician,  poet,  analyst,  correspondent,  network-djinn,  criminal,  mystic,  revolutionary,  agitator,  diplomat,  dealer,  assassin,  guard,  spy,  ace,  driver,  trucker,  colonist,  prospector,  scout,  ascetic,  missionary,  prophet,  archaeologist,  medicurg,  technologist,  ship-engineer,  labourer,  loader,  legionnaire,  mercenary,  officer,  };

  @BuiltValueField(wireName: r'iconId')
  IconId? get iconId;
  // enum iconIdEnum {  lady-of-tears,  traveler,  messenger,  merchant,  dancer,  gambler,  judge,  faceless-one,  deckhand,  };

  /// Allowed only while `status` is `draft` — used by the wizard to let players reconsider their pick before forging. Once the character is `active`, this field is immutable. 
  @BuiltValueField(wireName: r'upbringing')
  Upbringing? get upbringing;
  // enum upbringingEnum {  plebeian,  stationary,  aristocrat,  };

  @BuiltValueField(wireName: r'origin')
  String? get origin;

  @BuiltValueField(wireName: r'crewConcept')
  CrewConcept? get crewConcept;
  // enum crewConceptEnum {  free-trader,  mercenary,  explorer,  agents,  pilgrim,  };

  /// Allowed only while `status` is `draft`. Toggling on/off while drafting also clears any incompatible stigma talents picked previously. Once the character is `active`, this field is immutable and any attempt to change it is rejected with `MUTANT_IMMUTABLE`. 
  @BuiltValueField(wireName: r'mutant')
  bool? get mutant;

  @BuiltValueField(wireName: r'mutantLineage')
  MutantLineage? get mutantLineage;
  // enum mutantLineageEnum {  zirba,  shingura,  nerida,  };

  /// Update the character's current reputation (e.g. after a roleplay event). Initial value is set from `upbringing` at creation time; while the character is a `draft`, changing `upbringing` resets `reputation` to the new upbringing's baseline. 
  @BuiltValueField(wireName: r'reputation')
  int? get reputation;

  /// Update the current birr balance (Bazaar purchases, session payouts). Allowed only while `status` is `active`. PATCHes to `birr` on a draft are rejected with `BIRR_DRAFT_IMMUTABLE` — the wizard re-seeds birr from `startingWealth` on the forge transition. 
  @BuiltValueField(wireName: r'birr')
  int? get birr;

  @BuiltValueField(wireName: r'attributes')
  Attributes? get attributes;

  @BuiltValueField(wireName: r'skills')
  Skills? get skills;

  @BuiltValueField(wireName: r'hp')
  CharacterCreateHp? get hp;

  @BuiltValueField(wireName: r'mp')
  CharacterCreateHp? get mp;

  @BuiltValueField(wireName: r'experience')
  int? get experience;

  @BuiltValueField(wireName: r'conditions')
  ConditionFlags? get conditions;

  /// Replaces the entire critical injuries list when provided. Use the dedicated nested-item pattern (POST/PATCH/DELETE on individual injuries) once that surface is added in a later epic. 
  @BuiltValueField(wireName: r'criticalInjuries')
  BuiltList<CriticalInjury>? get criticalInjuries;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// Lifecycle state transition. Only `draft → active` (forge) is permitted. Attempting `active → draft` returns 422 `INVALID_STATUS_TRANSITION`. 
  @BuiltValueField(wireName: r'status')
  CharacterUpdateStatusEnum? get status;
  // enum statusEnum {  draft,  active,  };

  CharacterUpdate._();

  factory CharacterUpdate([void updates(CharacterUpdateBuilder b)]) = _$CharacterUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CharacterUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CharacterUpdate> get serializer => _$CharacterUpdateSerializer();
}

class _$CharacterUpdateSerializer implements PrimitiveSerializer<CharacterUpdate> {
  @override
  final Iterable<Type> types = const [CharacterUpdate, _$CharacterUpdate];

  @override
  final String wireName = r'CharacterUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CharacterUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.concept != null) {
      yield r'concept';
      yield serializers.serialize(
        object.concept,
        specifiedType: const FullType.nullable(Concept),
      );
    }
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType.nullable(Role),
      );
    }
    if (object.iconId != null) {
      yield r'iconId';
      yield serializers.serialize(
        object.iconId,
        specifiedType: const FullType.nullable(IconId),
      );
    }
    if (object.upbringing != null) {
      yield r'upbringing';
      yield serializers.serialize(
        object.upbringing,
        specifiedType: const FullType(Upbringing),
      );
    }
    if (object.origin != null) {
      yield r'origin';
      yield serializers.serialize(
        object.origin,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.crewConcept != null) {
      yield r'crewConcept';
      yield serializers.serialize(
        object.crewConcept,
        specifiedType: const FullType.nullable(CrewConcept),
      );
    }
    if (object.mutant != null) {
      yield r'mutant';
      yield serializers.serialize(
        object.mutant,
        specifiedType: const FullType(bool),
      );
    }
    if (object.mutantLineage != null) {
      yield r'mutantLineage';
      yield serializers.serialize(
        object.mutantLineage,
        specifiedType: const FullType.nullable(MutantLineage),
      );
    }
    if (object.reputation != null) {
      yield r'reputation';
      yield serializers.serialize(
        object.reputation,
        specifiedType: const FullType(int),
      );
    }
    if (object.birr != null) {
      yield r'birr';
      yield serializers.serialize(
        object.birr,
        specifiedType: const FullType(int),
      );
    }
    if (object.attributes != null) {
      yield r'attributes';
      yield serializers.serialize(
        object.attributes,
        specifiedType: const FullType(Attributes),
      );
    }
    if (object.skills != null) {
      yield r'skills';
      yield serializers.serialize(
        object.skills,
        specifiedType: const FullType(Skills),
      );
    }
    if (object.hp != null) {
      yield r'hp';
      yield serializers.serialize(
        object.hp,
        specifiedType: const FullType(CharacterCreateHp),
      );
    }
    if (object.mp != null) {
      yield r'mp';
      yield serializers.serialize(
        object.mp,
        specifiedType: const FullType(CharacterCreateHp),
      );
    }
    if (object.experience != null) {
      yield r'experience';
      yield serializers.serialize(
        object.experience,
        specifiedType: const FullType(int),
      );
    }
    if (object.conditions != null) {
      yield r'conditions';
      yield serializers.serialize(
        object.conditions,
        specifiedType: const FullType(ConditionFlags),
      );
    }
    if (object.criticalInjuries != null) {
      yield r'criticalInjuries';
      yield serializers.serialize(
        object.criticalInjuries,
        specifiedType: const FullType(BuiltList, [FullType(CriticalInjury)]),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(CharacterUpdateStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CharacterUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CharacterUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'reputation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.reputation = valueDes;
          break;
        case r'birr':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.birr = valueDes;
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
            specifiedType: const FullType(CharacterCreateHp),
          ) as CharacterCreateHp;
          result.hp.replace(valueDes);
          break;
        case r'mp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CharacterCreateHp),
          ) as CharacterCreateHp;
          result.mp.replace(valueDes);
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
            specifiedType: const FullType(CharacterUpdateStatusEnum),
          ) as CharacterUpdateStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CharacterUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CharacterUpdateBuilder();
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

class CharacterUpdateStatusEnum extends EnumClass {

  /// Lifecycle state transition. Only `draft → active` (forge) is permitted. Attempting `active → draft` returns 422 `INVALID_STATUS_TRANSITION`. 
  @BuiltValueEnumConst(wireName: r'draft')
  static const CharacterUpdateStatusEnum draft = _$characterUpdateStatusEnum_draft;
  /// Lifecycle state transition. Only `draft → active` (forge) is permitted. Attempting `active → draft` returns 422 `INVALID_STATUS_TRANSITION`. 
  @BuiltValueEnumConst(wireName: r'active')
  static const CharacterUpdateStatusEnum active = _$characterUpdateStatusEnum_active;

  static Serializer<CharacterUpdateStatusEnum> get serializer => _$characterUpdateStatusEnumSerializer;

  const CharacterUpdateStatusEnum._(String name): super(name);

  static BuiltSet<CharacterUpdateStatusEnum> get values => _$characterUpdateStatusEnumValues;
  static CharacterUpdateStatusEnum valueOf(String name) => _$characterUpdateStatusEnumValueOf(name);
}

