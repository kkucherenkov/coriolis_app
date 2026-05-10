//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_armor.dart';
import 'package:app_api_client/src/model/skills.dart';
import 'package:app_api_client/src/model/attributes.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/npc_update_hp.dart';
import 'package:app_api_client/src/model/item_weapon.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'npc_update.g.dart';

/// Payload for `PATCH /api/v1/npcs/{id}`. All fields are optional; omitted fields are left unchanged. Supplying `weapons` or `armor` replaces the entire array (put-semantics for nested collections). 
///
/// Properties:
/// * [name] 
/// * [description] 
/// * [attributes] 
/// * [skills] 
/// * [hp] 
/// * [mp] 
/// * [signature] 
/// * [keySkillModifier] 
/// * [armor] 
/// * [weapons] 
/// * [tags] 
@BuiltValue()
abstract class NpcUpdate implements Built<NpcUpdate, NpcUpdateBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'attributes')
  Attributes? get attributes;

  @BuiltValueField(wireName: r'skills')
  Skills? get skills;

  @BuiltValueField(wireName: r'hp')
  NpcUpdateHp? get hp;

  @BuiltValueField(wireName: r'mp')
  NpcUpdateHp? get mp;

  @BuiltValueField(wireName: r'signature')
  int? get signature;

  @BuiltValueField(wireName: r'keySkillModifier')
  int? get keySkillModifier;

  @BuiltValueField(wireName: r'armor')
  BuiltList<ItemArmor>? get armor;

  @BuiltValueField(wireName: r'weapons')
  BuiltList<ItemWeapon>? get weapons;

  @BuiltValueField(wireName: r'tags')
  BuiltList<String>? get tags;

  NpcUpdate._();

  factory NpcUpdate([void updates(NpcUpdateBuilder b)]) = _$NpcUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NpcUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NpcUpdate> get serializer => _$NpcUpdateSerializer();
}

class _$NpcUpdateSerializer implements PrimitiveSerializer<NpcUpdate> {
  @override
  final Iterable<Type> types = const [NpcUpdate, _$NpcUpdate];

  @override
  final String wireName = r'NpcUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NpcUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
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
        specifiedType: const FullType(NpcUpdateHp),
      );
    }
    if (object.mp != null) {
      yield r'mp';
      yield serializers.serialize(
        object.mp,
        specifiedType: const FullType(NpcUpdateHp),
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
    NpcUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NpcUpdateBuilder result,
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
            specifiedType: const FullType(NpcUpdateHp),
          ) as NpcUpdateHp;
          result.hp.replace(valueDes);
          break;
        case r'mp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NpcUpdateHp),
          ) as NpcUpdateHp;
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
  NpcUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NpcUpdateBuilder();
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

