//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_armor.dart';
import 'package:app_api_client/src/model/skills.dart';
import 'package:app_api_client/src/model/attributes.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/npc_mp.dart';
import 'package:app_api_client/src/model/npc_hp.dart';
import 'package:app_api_client/src/model/item_weapon.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'npc.g.dart';

/// Full NPC DTO as returned by the v1 API. NPCs are GM-owned entities designed to populate encounters in the combat tracker (ST3001 ГЛАВА 14). They share the same attribute and skill vocabulary as player characters but carry no lifecycle state — any NPC can be added to any encounter at any time.  `signature` is the NPC's sensor signature score for ship-combat checks (signed integer; 0 is the baseline; negative values make the NPC harder to detect). `keySkillModifier` is a signed integer bonus that the combat tracker adds to the NPC's signature-derived attack or defence pool when computing opposed rolls (ST3001 ГЛАВА 14 \"Key Skill Modifier\"). Both default to 0. 
///
/// Properties:
/// * [id] - Opaque NPC identifier (cuid2)
/// * [ownerId] - Identifier of the owning user (cuid2)
/// * [name] - NPC name (1–120 characters)
/// * [description] - Free-form GM notes or narrative description (Markdown, max 2000 chars)
/// * [attributes] 
/// * [skills] 
/// * [hp] 
/// * [mp] 
/// * [signature] - NPC sensor signature for ship-combat sensor checks (ST3001 ГЛАВА 14). Signed integer; 0 is baseline; negative makes the NPC harder to detect; positive makes them easier. 
/// * [keySkillModifier] - Signed integer bonus applied by the combat tracker to the NPC's attack or defence roll pool when resolving opposed key-skill checks (ST3001 ГЛАВА 14). Positive values give the NPC an advantage; negative values impose a penalty. 
/// * [armor] - Armor items carried by the NPC
/// * [weapons] - Weapons carried by the NPC
/// * [tags] - Free-form GM-side categorisation labels (e.g. \"Pirate\", \"Cyborg\", \"Boss\"). Used for filtering in the NPC list and for encounter-table grouping. Each tag is a 1–40 character string. 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class Npc implements Built<Npc, NpcBuilder> {
  /// Opaque NPC identifier (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Identifier of the owning user (cuid2)
  @BuiltValueField(wireName: r'ownerId')
  String get ownerId;

  /// NPC name (1–120 characters)
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Free-form GM notes or narrative description (Markdown, max 2000 chars)
  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'attributes')
  Attributes get attributes;

  @BuiltValueField(wireName: r'skills')
  Skills get skills;

  @BuiltValueField(wireName: r'hp')
  NpcHp get hp;

  @BuiltValueField(wireName: r'mp')
  NpcMp get mp;

  /// NPC sensor signature for ship-combat sensor checks (ST3001 ГЛАВА 14). Signed integer; 0 is baseline; negative makes the NPC harder to detect; positive makes them easier. 
  @BuiltValueField(wireName: r'signature')
  int get signature;

  /// Signed integer bonus applied by the combat tracker to the NPC's attack or defence roll pool when resolving opposed key-skill checks (ST3001 ГЛАВА 14). Positive values give the NPC an advantage; negative values impose a penalty. 
  @BuiltValueField(wireName: r'keySkillModifier')
  int? get keySkillModifier;

  /// Armor items carried by the NPC
  @BuiltValueField(wireName: r'armor')
  BuiltList<ItemArmor> get armor;

  /// Weapons carried by the NPC
  @BuiltValueField(wireName: r'weapons')
  BuiltList<ItemWeapon> get weapons;

  /// Free-form GM-side categorisation labels (e.g. \"Pirate\", \"Cyborg\", \"Boss\"). Used for filtering in the NPC list and for encounter-table grouping. Each tag is a 1–40 character string. 
  @BuiltValueField(wireName: r'tags')
  BuiltList<String> get tags;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  Npc._();

  factory Npc([void updates(NpcBuilder b)]) = _$Npc;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NpcBuilder b) => b
      ..signature = 0
      ..keySkillModifier = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<Npc> get serializer => _$NpcSerializer();
}

class _$NpcSerializer implements PrimitiveSerializer<Npc> {
  @override
  final Iterable<Type> types = const [Npc, _$Npc];

  @override
  final String wireName = r'Npc';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Npc object, {
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
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
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
      specifiedType: const FullType(NpcHp),
    );
    yield r'mp';
    yield serializers.serialize(
      object.mp,
      specifiedType: const FullType(NpcMp),
    );
    yield r'signature';
    yield serializers.serialize(
      object.signature,
      specifiedType: const FullType(int),
    );
    if (object.keySkillModifier != null) {
      yield r'keySkillModifier';
      yield serializers.serialize(
        object.keySkillModifier,
        specifiedType: const FullType(int),
      );
    }
    yield r'armor';
    yield serializers.serialize(
      object.armor,
      specifiedType: const FullType(BuiltList, [FullType(ItemArmor)]),
    );
    yield r'weapons';
    yield serializers.serialize(
      object.weapons,
      specifiedType: const FullType(BuiltList, [FullType(ItemWeapon)]),
    );
    yield r'tags';
    yield serializers.serialize(
      object.tags,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
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
    Npc object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NpcBuilder result,
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
            specifiedType: const FullType(NpcHp),
          ) as NpcHp;
          result.hp.replace(valueDes);
          break;
        case r'mp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NpcMp),
          ) as NpcMp;
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
  Npc deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NpcBuilder();
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

