//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_armor.dart';
import 'package:app_api_client/src/model/skills.dart';
import 'package:app_api_client/src/model/attributes.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/npc_create_mp.dart';
import 'package:app_api_client/src/model/npc_create_hp.dart';
import 'package:app_api_client/src/model/item_weapon.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'npc_create.g.dart';

/// Payload for `POST /api/v1/npcs`. Only `name` is required; all other fields are optional. The server seeds sensible defaults for any omitted field so that a stub NPC can be created with a single field. 
///
/// Properties:
/// * [name] - NPC name (1–120 characters)
/// * [description] - Free-form description (Markdown, max 2000 chars)
/// * [attributes] - Attribute block; missing keys default to 2
/// * [skills] - Skill block; missing keys default to 0
/// * [hp] 
/// * [mp] 
/// * [signature] - Sensor signature score; defaults to 0
/// * [keySkillModifier] - Key skill modifier for combat tracker; defaults to 0
/// * [armor] - Armor items; defaults to empty array
/// * [weapons] - Weapons; defaults to empty array
/// * [tags] - Categorisation tags; defaults to empty array
@BuiltValue()
abstract class NpcCreate implements Built<NpcCreate, NpcCreateBuilder> {
  /// NPC name (1–120 characters)
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Free-form description (Markdown, max 2000 chars)
  @BuiltValueField(wireName: r'description')
  String? get description;

  /// Attribute block; missing keys default to 2
  @BuiltValueField(wireName: r'attributes')
  Attributes? get attributes;

  /// Skill block; missing keys default to 0
  @BuiltValueField(wireName: r'skills')
  Skills? get skills;

  @BuiltValueField(wireName: r'hp')
  NpcCreateHp? get hp;

  @BuiltValueField(wireName: r'mp')
  NpcCreateMp? get mp;

  /// Sensor signature score; defaults to 0
  @BuiltValueField(wireName: r'signature')
  int? get signature;

  /// Key skill modifier for combat tracker; defaults to 0
  @BuiltValueField(wireName: r'keySkillModifier')
  int? get keySkillModifier;

  /// Armor items; defaults to empty array
  @BuiltValueField(wireName: r'armor')
  BuiltList<ItemArmor>? get armor;

  /// Weapons; defaults to empty array
  @BuiltValueField(wireName: r'weapons')
  BuiltList<ItemWeapon>? get weapons;

  /// Categorisation tags; defaults to empty array
  @BuiltValueField(wireName: r'tags')
  BuiltList<String>? get tags;

  NpcCreate._();

  factory NpcCreate([void updates(NpcCreateBuilder b)]) = _$NpcCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NpcCreateBuilder b) => b
      ..signature = 0
      ..keySkillModifier = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<NpcCreate> get serializer => _$NpcCreateSerializer();
}

class _$NpcCreateSerializer implements PrimitiveSerializer<NpcCreate> {
  @override
  final Iterable<Type> types = const [NpcCreate, _$NpcCreate];

  @override
  final String wireName = r'NpcCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NpcCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
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
        specifiedType: const FullType(NpcCreateHp),
      );
    }
    if (object.mp != null) {
      yield r'mp';
      yield serializers.serialize(
        object.mp,
        specifiedType: const FullType(NpcCreateMp),
      );
    }
    if (object.signature != null) {
      yield r'signature';
      yield serializers.serialize(
        object.signature,
        specifiedType: const FullType(int),
      );
    }
    if (object.keySkillModifier != null) {
      yield r'keySkillModifier';
      yield serializers.serialize(
        object.keySkillModifier,
        specifiedType: const FullType(int),
      );
    }
    if (object.armor != null) {
      yield r'armor';
      yield serializers.serialize(
        object.armor,
        specifiedType: const FullType(BuiltList, [FullType(ItemArmor)]),
      );
    }
    if (object.weapons != null) {
      yield r'weapons';
      yield serializers.serialize(
        object.weapons,
        specifiedType: const FullType(BuiltList, [FullType(ItemWeapon)]),
      );
    }
    if (object.tags != null) {
      yield r'tags';
      yield serializers.serialize(
        object.tags,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NpcCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NpcCreateBuilder result,
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
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
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
            specifiedType: const FullType(NpcCreateHp),
          ) as NpcCreateHp;
          result.hp.replace(valueDes);
          break;
        case r'mp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NpcCreateMp),
          ) as NpcCreateMp;
          result.mp.replace(valueDes);
          break;
        case r'signature':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.signature = valueDes;
          break;
        case r'keySkillModifier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.keySkillModifier = valueDes;
          break;
        case r'armor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ItemArmor)]),
          ) as BuiltList<ItemArmor>;
          result.armor.replace(valueDes);
          break;
        case r'weapons':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ItemWeapon)]),
          ) as BuiltList<ItemWeapon>;
          result.weapons.replace(valueDes);
          break;
        case r'tags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.tags.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NpcCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NpcCreateBuilder();
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

