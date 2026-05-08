//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/skills.dart';
import 'package:app_api_client/src/model/attributes.dart';
import 'package:app_api_client/src/model/condition_flags.dart';
import 'package:app_api_client/src/model/character_create_hp.dart';
import 'package:app_api_client/src/model/icon_id.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'character_create.g.dart';

/// Payload for `POST /api/v1/characters`. Only `name` is required. Attribute values default to 2 if the `attributes` object is omitted or a key within it is missing. Skill values default to 0.  Read-only fields (`id`, `ownerId`, `hp.max`, `mp.max`, `encumbrance.max`, `encumbrance.current`, `createdAt`, `updatedAt`) must not be included; they are rejected with 400. 
///
/// Properties:
/// * [name] 
/// * [concept] 
/// * [iconId] 
/// * [attributes] 
/// * [skills] 
/// * [hp] 
/// * [mp] 
/// * [experience] 
/// * [conditions] 
/// * [notes] 
@BuiltValue()
abstract class CharacterCreate implements Built<CharacterCreate, CharacterCreateBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'concept')
  String? get concept;

  @BuiltValueField(wireName: r'iconId')
  IconId? get iconId;
  // enum iconIdEnum {  lady-of-tears,  traveler,  messenger,  merchant,  dancer,  gambler,  judge,  faceless-one,  deckhand,  };

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

  CharacterCreate._();

  factory CharacterCreate([void updates(CharacterCreateBuilder b)]) = _$CharacterCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CharacterCreateBuilder b) => b
      ..experience = 0;

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
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.iconId != null) {
      yield r'iconId';
      yield serializers.serialize(
        object.iconId,
        specifiedType: const FullType.nullable(IconId),
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

