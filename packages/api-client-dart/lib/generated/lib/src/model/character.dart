//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/relationship.dart';
import 'package:app_api_client/src/model/item.dart';
import 'package:app_api_client/src/model/skills.dart';
import 'package:app_api_client/src/model/attributes.dart';
import 'package:app_api_client/src/model/condition_flags.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/character_encumbrance.dart';
import 'package:app_api_client/src/model/character_mp.dart';
import 'package:app_api_client/src/model/talent.dart';
import 'package:app_api_client/src/model/critical_injury.dart';
import 'package:app_api_client/src/model/icon_id.dart';
import 'package:app_api_client/src/model/character_hp.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'character.g.dart';

/// Full character DTO as returned by the v1 API. Server-derived fields (`hp.max`, `mp.max`, `encumbrance.max`) are computed by the RulesEngine on every write and are marked `readOnly`.  Formulas (PRD §5.2, §10): - HP max = STR + AGI - MP max = WIT + EMP - Encumbrance max = STR × 2 
///
/// Properties:
/// * [id] - Opaque character identifier (cuid2)
/// * [ownerId] - Identifier of the owning user (cuid2)
/// * [name] - Character name (1–80 characters)
/// * [concept] - Short concept phrase — the role the character plays at the table (1–120 chars when non-null)
/// * [iconId] 
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

  /// Short concept phrase — the role the character plays at the table (1–120 chars when non-null)
  @BuiltValueField(wireName: r'concept')
  String? get concept;

  @BuiltValueField(wireName: r'iconId')
  IconId? get iconId;
  // enum iconIdEnum {  lady-of-tears,  traveler,  messenger,  merchant,  dancer,  gambler,  judge,  faceless-one,  deckhand,  };

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

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  Character._();

  factory Character([void updates(CharacterBuilder b)]) = _$Character;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CharacterBuilder b) => b;

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
      specifiedType: const FullType.nullable(String),
    );
    yield r'iconId';
    yield object.iconId == null ? null : serializers.serialize(
      object.iconId,
      specifiedType: const FullType.nullable(IconId),
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.concept = valueDes;
          break;
        case r'iconId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(IconId),
          ) as IconId?;
          if (valueDes == null) continue;
          result.iconId = valueDes;
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

