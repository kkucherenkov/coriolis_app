//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_base.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_armor.g.dart';

/// ItemArmor
///
/// Properties:
/// * [id] - Opaque identifier (cuid2)
/// * [type] 
/// * [name] - Item name
/// * [armorRating] - Armor rating — reduces incoming damage
/// * [weight] - Encumbrance weight in slots
/// * [features] - Feature tags (e.g. \"Vacuum Sealed\", \"Exo-Skeleton\")
/// * [equipped] 
/// * [extraSlotCount] - Extra encumbrance slots this armor grants its wearer when equipped (ST3001 ТАБЛИЦА 6.14 «Дополнительные свойства» column). The wearer's encumbrance limit becomes `STR × 2 + sum(equipped armor extraSlotCount)` per the rules-engine. Canonical values from the printed table: most armors 0; Тяжёлый экзоскафандр / Лёгкая броня / Тяжёлая броня 1; Экзодоспех 2; Тяжёлый экзодоспех 5. The 0..6 envelope leaves one point of headroom for GM-defined exotics. Stacks across multiple equipped pieces (e.g. armour + tactical shield), but only when each piece carries the property — most shields are 0. 
@BuiltValue()
abstract class ItemArmor implements ItemBase, Built<ItemArmor, ItemArmorBuilder> {
  /// Feature tags (e.g. \"Vacuum Sealed\", \"Exo-Skeleton\")
  @BuiltValueField(wireName: r'features')
  BuiltList<String> get features;

  @BuiltValueField(wireName: r'equipped')
  bool get equipped;

  /// Encumbrance weight in slots
  @BuiltValueField(wireName: r'weight')
  num get weight;

  /// Armor rating — reduces incoming damage
  @BuiltValueField(wireName: r'armorRating')
  int get armorRating;

  /// Extra encumbrance slots this armor grants its wearer when equipped (ST3001 ТАБЛИЦА 6.14 «Дополнительные свойства» column). The wearer's encumbrance limit becomes `STR × 2 + sum(equipped armor extraSlotCount)` per the rules-engine. Canonical values from the printed table: most armors 0; Тяжёлый экзоскафандр / Лёгкая броня / Тяжёлая броня 1; Экзодоспех 2; Тяжёлый экзодоспех 5. The 0..6 envelope leaves one point of headroom for GM-defined exotics. Stacks across multiple equipped pieces (e.g. armour + tactical shield), but only when each piece carries the property — most shields are 0. 
  @BuiltValueField(wireName: r'extraSlotCount')
  int? get extraSlotCount;

  ItemArmor._();

  factory ItemArmor([void updates(ItemArmorBuilder b)]) = _$ItemArmor;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemArmorBuilder b) => b
      ..extraSlotCount = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemArmor> get serializer => _$ItemArmorSerializer();
}

class _$ItemArmorSerializer implements PrimitiveSerializer<ItemArmor> {
  @override
  final Iterable<Type> types = const [ItemArmor, _$ItemArmor];

  @override
  final String wireName = r'ItemArmor';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemArmor object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
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
    yield r'armorRating';
    yield serializers.serialize(
      object.armorRating,
      specifiedType: const FullType(int),
    );
    if (object.extraSlotCount != null) {
      yield r'extraSlotCount';
      yield serializers.serialize(
        object.extraSlotCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemArmor object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemArmorBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
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
        case r'armorRating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.armorRating = valueDes;
          break;
        case r'extraSlotCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.extraSlotCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ItemArmor deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemArmorBuilder();
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

class ItemArmorTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ARMOR')
  static const ItemArmorTypeEnum ARMOR = _$itemArmorTypeEnum_ARMOR;

  static Serializer<ItemArmorTypeEnum> get serializer => _$itemArmorTypeEnumSerializer;

  const ItemArmorTypeEnum._(String name): super(name);

  static BuiltSet<ItemArmorTypeEnum> get values => _$itemArmorTypeEnumValues;
  static ItemArmorTypeEnum valueOf(String name) => _$itemArmorTypeEnumValueOf(name);
}

