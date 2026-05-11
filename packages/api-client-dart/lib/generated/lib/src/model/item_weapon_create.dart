//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/item_range_enum.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_weapon_create.g.dart';

/// Create payload for a WEAPON item. No `id` — server-assigned.
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [damage] - Base damage dice
/// * [range] 
/// * [bonus] - Bonus dice added to the attack pool
/// * [crit] - Critical threshold
/// * [weight] - Encumbrance weight in slots (0.5 increments)
/// * [features] - Feature tags (e.g. \"Burst\", \"Explosive\")
/// * [equipped] 
/// * [initiative] - Per-weapon initiative modifier (ST3001 ГЛАВА 6 «Инициатива» column). Canonical printed values 0..+2; accepts −5..+5 for GM flex. Defaults to 0 — most weapons don't carry an initiative bonus. 
@BuiltValue()
abstract class ItemWeaponCreate implements Built<ItemWeaponCreate, ItemWeaponCreateBuilder> {
  @BuiltValueField(wireName: r'type')
  ItemWeaponCreateTypeEnum get type;
  // enum typeEnum {  WEAPON,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  /// Base damage dice
  @BuiltValueField(wireName: r'damage')
  int get damage;

  @BuiltValueField(wireName: r'range')
  ItemRangeEnum get range;
  // enum rangeEnum {  close,  medium,  long,  extreme,  };

  /// Bonus dice added to the attack pool
  @BuiltValueField(wireName: r'bonus')
  int get bonus;

  /// Critical threshold
  @BuiltValueField(wireName: r'crit')
  int get crit;

  /// Encumbrance weight in slots (0.5 increments)
  @BuiltValueField(wireName: r'weight')
  num get weight;

  /// Feature tags (e.g. \"Burst\", \"Explosive\")
  @BuiltValueField(wireName: r'features')
  BuiltList<String> get features;

  @BuiltValueField(wireName: r'equipped')
  bool get equipped;

  /// Per-weapon initiative modifier (ST3001 ГЛАВА 6 «Инициатива» column). Canonical printed values 0..+2; accepts −5..+5 for GM flex. Defaults to 0 — most weapons don't carry an initiative bonus. 
  @BuiltValueField(wireName: r'initiative')
  int? get initiative;

  ItemWeaponCreate._();

  factory ItemWeaponCreate([void updates(ItemWeaponCreateBuilder b)]) = _$ItemWeaponCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemWeaponCreateBuilder b) => b
      ..equipped = false
      ..initiative = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemWeaponCreate> get serializer => _$ItemWeaponCreateSerializer();
}

class _$ItemWeaponCreateSerializer implements PrimitiveSerializer<ItemWeaponCreate> {
  @override
  final Iterable<Type> types = const [ItemWeaponCreate, _$ItemWeaponCreate];

  @override
  final String wireName = r'ItemWeaponCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemWeaponCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(ItemWeaponCreateTypeEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'damage';
    yield serializers.serialize(
      object.damage,
      specifiedType: const FullType(int),
    );
    yield r'range';
    yield serializers.serialize(
      object.range,
      specifiedType: const FullType(ItemRangeEnum),
    );
    yield r'bonus';
    yield serializers.serialize(
      object.bonus,
      specifiedType: const FullType(int),
    );
    yield r'crit';
    yield serializers.serialize(
      object.crit,
      specifiedType: const FullType(int),
    );
    yield r'weight';
    yield serializers.serialize(
      object.weight,
      specifiedType: const FullType(num),
    );
    yield r'features';
    yield serializers.serialize(
      object.features,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'equipped';
    yield serializers.serialize(
      object.equipped,
      specifiedType: const FullType(bool),
    );
    if (object.initiative != null) {
      yield r'initiative';
      yield serializers.serialize(
        object.initiative,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemWeaponCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemWeaponCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemWeaponCreateTypeEnum),
          ) as ItemWeaponCreateTypeEnum;
          result.type = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'damage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.damage = valueDes;
          break;
        case r'range':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemRangeEnum),
          ) as ItemRangeEnum;
          result.range = valueDes;
          break;
        case r'bonus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bonus = valueDes;
          break;
        case r'crit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.crit = valueDes;
          break;
        case r'weight':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.weight = valueDes;
          break;
        case r'features':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.features.replace(valueDes);
          break;
        case r'equipped':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.equipped = valueDes;
          break;
        case r'initiative':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.initiative = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ItemWeaponCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemWeaponCreateBuilder();
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

class ItemWeaponCreateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'WEAPON')
  static const ItemWeaponCreateTypeEnum WEAPON = _$itemWeaponCreateTypeEnum_WEAPON;

  static Serializer<ItemWeaponCreateTypeEnum> get serializer => _$itemWeaponCreateTypeEnumSerializer;

  const ItemWeaponCreateTypeEnum._(String name): super(name);

  static BuiltSet<ItemWeaponCreateTypeEnum> get values => _$itemWeaponCreateTypeEnumValues;
  static ItemWeaponCreateTypeEnum valueOf(String name) => _$itemWeaponCreateTypeEnumValueOf(name);
}

