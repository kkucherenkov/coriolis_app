//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_base.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/item_range_enum.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_weapon.g.dart';

/// ItemWeapon
///
/// Properties:
/// * [id] - Opaque identifier (cuid2)
/// * [type] 
/// * [name] - Item name
/// * [damage] - Base damage dice
/// * [range] 
/// * [bonus] - Bonus dice added to the attack pool
/// * [crit] - Critical threshold (roll this many successes to crit)
/// * [weight] - Encumbrance weight in slots (0.5 increments)
/// * [features] - Feature tags (e.g. \"Burst\", \"Explosive\")
/// * [equipped] - Whether the item is currently equipped
@BuiltValue()
abstract class ItemWeapon implements ItemBase, Built<ItemWeapon, ItemWeaponBuilder> {
  /// Base damage dice
  @BuiltValueField(wireName: r'damage')
  int get damage;

  /// Feature tags (e.g. \"Burst\", \"Explosive\")
  @BuiltValueField(wireName: r'features')
  BuiltList<String> get features;

  /// Critical threshold (roll this many successes to crit)
  @BuiltValueField(wireName: r'crit')
  int get crit;

  /// Whether the item is currently equipped
  @BuiltValueField(wireName: r'equipped')
  bool get equipped;

  /// Bonus dice added to the attack pool
  @BuiltValueField(wireName: r'bonus')
  int get bonus;

  @BuiltValueField(wireName: r'range')
  ItemRangeEnum get range;
  // enum rangeEnum {  close,  medium,  long,  extreme,  };

  /// Encumbrance weight in slots (0.5 increments)
  @BuiltValueField(wireName: r'weight')
  num get weight;

  ItemWeapon._();

  factory ItemWeapon([void updates(ItemWeaponBuilder b)]) = _$ItemWeapon;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemWeaponBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemWeapon> get serializer => _$ItemWeaponSerializer();
}

class _$ItemWeaponSerializer implements PrimitiveSerializer<ItemWeapon> {
  @override
  final Iterable<Type> types = const [ItemWeapon, _$ItemWeapon];

  @override
  final String wireName = r'ItemWeapon';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemWeapon object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'damage';
    yield serializers.serialize(
      object.damage,
      specifiedType: const FullType(int),
    );
    yield r'features';
    yield serializers.serialize(
      object.features,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'crit';
    yield serializers.serialize(
      object.crit,
      specifiedType: const FullType(int),
    );
    yield r'equipped';
    yield serializers.serialize(
      object.equipped,
      specifiedType: const FullType(bool),
    );
    yield r'bonus';
    yield serializers.serialize(
      object.bonus,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'range';
    yield serializers.serialize(
      object.range,
      specifiedType: const FullType(ItemRangeEnum),
    );
    yield r'weight';
    yield serializers.serialize(
      object.weight,
      specifiedType: const FullType(num),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemWeapon object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemWeaponBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'damage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.damage = valueDes;
          break;
        case r'features':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.features.replace(valueDes);
          break;
        case r'crit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.crit = valueDes;
          break;
        case r'equipped':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.equipped = valueDes;
          break;
        case r'bonus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bonus = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'range':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemRangeEnum),
          ) as ItemRangeEnum;
          result.range = valueDes;
          break;
        case r'weight':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.weight = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ItemWeapon deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemWeaponBuilder();
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

class ItemWeaponTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'WEAPON')
  static const ItemWeaponTypeEnum WEAPON = _$itemWeaponTypeEnum_WEAPON;

  static Serializer<ItemWeaponTypeEnum> get serializer => _$itemWeaponTypeEnumSerializer;

  const ItemWeaponTypeEnum._(String name): super(name);

  static BuiltSet<ItemWeaponTypeEnum> get values => _$itemWeaponTypeEnumValues;
  static ItemWeaponTypeEnum valueOf(String name) => _$itemWeaponTypeEnumValueOf(name);
}

