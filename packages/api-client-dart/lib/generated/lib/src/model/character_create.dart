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
import 'package:app_api_client/src/model/icon_id.dart';
import 'package:app_api_client/src/model/role.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'character_create.g.dart';

/// Payload for `POST /api/v1/characters`. Only `name` and `upbringing` are required. Attribute values default to 2 if the `attributes` object is omitted or a key within it is missing. Skill values default to 0.  The server enforces the upbringing-based budgets at creation time: - sum(attributes) ≤ attribute budget for upbringing - each attribute is between 2 and 4 - sum(skills) ≤ skill budget for upbringing  `reputation` and `startingWealth` are **server-derived** from `upbringing` and must not be set by the client.  Read-only fields (`id`, `ownerId`, `hp.max`, `mp.max`, `encumbrance.max`, `encumbrance.current`, `startingWealth`, `createdAt`, `updatedAt`) must not be included; they are rejected with 400.  Set `status: 'draft'` to create a wizard-in-progress character. Omitting `status` defaults to `'active'`. 
///
/// Properties:
/// * [name] 
/// * [concept] 
/// * [role] 
/// * [iconId] 
/// * [upbringing] 
/// * [origin] 
/// * [crewConcept] 
/// * [mutant] - Whether the character is a mutant (пасынок). When `true`, `mutantLineage` must be supplied; the player then picks one stigma talent from the catalog through the regular `addTalent` endpoint (kind `stigma`). When `false` (default), `mutantLineage` must be `null` or omitted and stigma talents are rejected with `STIGMA_REQUIRES_MUTANT`. 
/// * [mutantLineage] 
/// * [attributes] 
/// * [skills] 
/// * [hp] 
/// * [mp] 
/// * [experience] 
/// * [conditions] 
/// * [notes] 
/// * [status] - Initial lifecycle state. Omit (or set `active`) for normal creation. Set to `draft` when starting the character-creation wizard. 
@BuiltValue()
abstract class CharacterCreate implements Built<CharacterCreate, CharacterCreateBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'concept')
  Concept? get concept;
  // enum conceptEnum {  artist,  networker,  fugitive,  negotiator,  operative,  pilot,  pioneer,  preacher,  scientist,  sailor,  soldier,  };

  @BuiltValueField(wireName: r'role')
  Role? get role;
  // enum roleEnum {  companion,  musician,  poet,  analyst,  correspondent,  network-djinn,  criminal,  mystic,  revolutionary,  agitator,  diplomat,  dealer,  assassin,  guard,  spy,  ace,  driver,  trucker,  colonist,  prospector,  scout,  ascetic,  missionary,  prophet,  archaeologist,  medicurg,  technologist,  ship-engineer,  labourer,  loader,  legionnaire,  mercenary,  officer,  };

  @BuiltValueField(wireName: r'iconId')
  IconId? get iconId;
  // enum iconIdEnum {  lady-of-tears,  traveler,  messenger,  merchant,  dancer,  gambler,  judge,  faceless-one,  deckhand,  };

  @BuiltValueField(wireName: r'upbringing')
  Upbringing get upbringing;
  // enum upbringingEnum {  plebeian,  stationary,  aristocrat,  };

  @BuiltValueField(wireName: r'origin')
  String? get origin;

  @BuiltValueField(wireName: r'crewConcept')
  CrewConcept? get crewConcept;
  // enum crewConceptEnum {  free-trader,  mercenary,  explorer,  agents,  pilgrim,  };

  /// Whether the character is a mutant (пасынок). When `true`, `mutantLineage` must be supplied; the player then picks one stigma talent from the catalog through the regular `addTalent` endpoint (kind `stigma`). When `false` (default), `mutantLineage` must be `null` or omitted and stigma talents are rejected with `STIGMA_REQUIRES_MUTANT`. 
  @BuiltValueField(wireName: r'mutant')
  bool? get mutant;

  @BuiltValueField(wireName: r'mutantLineage')
  MutantLineage? get mutantLineage;
  // enum mutantLineageEnum {  zirba,  shingura,  nerida,  };

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

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// Initial lifecycle state. Omit (or set `active`) for normal creation. Set to `draft` when starting the character-creation wizard. 
  @BuiltValueField(wireName: r'status')
  CharacterCreateStatusEnum? get status;
  // enum statusEnum {  draft,  active,  };

  CharacterCreate._();

  factory CharacterCreate([void updates(CharacterCreateBuilder b)]) = _$CharacterCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CharacterCreateBuilder b) => b
      ..mutant = false
      ..experience = 0
      ..status = CharacterCreateStatusEnum.valueOf('active');

  @BuiltValueSerializer(custom: true)
  static Serializer<CharacterCreate> get serializer => _$CharacterCreateSerializer();
}

class _$CharacterCreateSerializer implements PrimitiveSerializer<CharacterCreate> {
  @override
  final Iterable<Type> types = const [CharacterCreate, _$CharacterCreate];

  @override
  final String wireName = r'CharacterCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CharacterCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
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
    yield r'upbringing';
    yield serializers.serialize(
      object.upbringing,
      specifiedType: const FullType(Upbringing),
    );
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
        specifiedType: const FullType(CharacterCreateStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CharacterCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CharacterCreateBuilder result,
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
            specifiedType: const FullType(CharacterCreateStatusEnum),
          ) as CharacterCreateStatusEnum;
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
  CharacterCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CharacterCreateBuilder();
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

class CharacterCreateStatusEnum extends EnumClass {

  /// Initial lifecycle state. Omit (or set `active`) for normal creation. Set to `draft` when starting the character-creation wizard. 
  @BuiltValueEnumConst(wireName: r'draft')
  static const CharacterCreateStatusEnum draft = _$characterCreateStatusEnum_draft;
  /// Initial lifecycle state. Omit (or set `active`) for normal creation. Set to `draft` when starting the character-creation wizard. 
  @BuiltValueEnumConst(wireName: r'active')
  static const CharacterCreateStatusEnum active = _$characterCreateStatusEnum_active;

  static Serializer<CharacterCreateStatusEnum> get serializer => _$characterCreateStatusEnumSerializer;

  const CharacterCreateStatusEnum._(String name): super(name);

  static BuiltSet<CharacterCreateStatusEnum> get values => _$characterCreateStatusEnumValues;
  static CharacterCreateStatusEnum valueOf(String name) => _$characterCreateStatusEnumValueOf(name);
}

