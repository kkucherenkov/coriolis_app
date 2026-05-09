//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_ship_module_create.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/item_gear_create.dart';
import 'package:app_api_client/src/model/item_weapon_create.dart';
import 'package:app_api_client/src/model/item_cybernetic_create.dart';
import 'package:app_api_client/src/model/item_other_create.dart';
import 'package:app_api_client/src/model/item_armor_create.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'item_create.g.dart';

/// Payload for creating a new item. Same discriminated union as `Item` but without `id` (server-assigned). The `type` discriminator must be present. 
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [damage] - Base damage dice
/// * [range] 
/// * [bonus] - Bonus dice added to the attack pool
/// * [crit] - Critical threshold
/// * [weight] - Encumbrance weight in slots
/// * [features] - Feature tags (e.g. \"Vacuum Sealed\", \"Exo-Skeleton\")
/// * [equipped] 
/// * [armorRating] - Armor rating — reduces incoming damage
/// * [quantity] - Number of units
/// * [notes] - Optional free-text notes
/// * [bodyPoints] - System strain points consumed (0–6)
/// * [effect] - Description of the module's effect and energy use
/// * [slot] 
@BuiltValue()
abstract class ItemCreate implements Built<ItemCreate, ItemCreateBuilder> {
  /// One Of [ItemArmorCreate], [ItemCyberneticCreate], [ItemGearCreate], [ItemOtherCreate], [ItemShipModuleCreate], [ItemWeaponCreate]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'type';

  static const Map<String, Type> discriminatorMapping = {
    r'ARMOR': ItemArmorCreate,
    r'CYBERNETIC': ItemCyberneticCreate,
    r'GEAR': ItemGearCreate,
    r'OTHER': ItemOtherCreate,
    r'SHIP_MODULE': ItemShipModuleCreate,
    r'WEAPON': ItemWeaponCreate,
  };

  ItemCreate._();

  factory ItemCreate([void updates(ItemCreateBuilder b)]) = _$ItemCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemCreate> get serializer => _$ItemCreateSerializer();
}

extension ItemCreateDiscriminatorExt on ItemCreate {
    String? get discriminatorValue {
        if (this is ItemArmorCreate) {
            return r'ARMOR';
        }
        if (this is ItemCyberneticCreate) {
            return r'CYBERNETIC';
        }
        if (this is ItemGearCreate) {
            return r'GEAR';
        }
        if (this is ItemOtherCreate) {
            return r'OTHER';
        }
        if (this is ItemShipModuleCreate) {
            return r'SHIP_MODULE';
        }
        if (this is ItemWeaponCreate) {
            return r'WEAPON';
        }
        return null;
    }
}
extension ItemCreateBuilderDiscriminatorExt on ItemCreateBuilder {
    String? get discriminatorValue {
        if (this is ItemArmorCreateBuilder) {
            return r'ARMOR';
        }
        if (this is ItemCyberneticCreateBuilder) {
            return r'CYBERNETIC';
        }
        if (this is ItemGearCreateBuilder) {
            return r'GEAR';
        }
        if (this is ItemOtherCreateBuilder) {
            return r'OTHER';
        }
        if (this is ItemShipModuleCreateBuilder) {
            return r'SHIP_MODULE';
        }
        if (this is ItemWeaponCreateBuilder) {
            return r'WEAPON';
        }
        return null;
    }
}

class _$ItemCreateSerializer implements PrimitiveSerializer<ItemCreate> {
  @override
  final Iterable<Type> types = const [ItemCreate, _$ItemCreate];

  @override
  final String wireName = r'ItemCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemCreate object) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  ItemCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemCreateBuilder();
    Object? oneOfDataSrc;
    final serializedList = (serialized as Iterable<Object?>).toList();
    final discIndex = serializedList.indexOf(ItemCreate.discriminatorFieldName) + 1;
    final discValue = serializers.deserialize(serializedList[discIndex], specifiedType: FullType(String)) as String;
    oneOfDataSrc = serialized;
    final oneOfTypes = [ItemArmorCreate, ItemCyberneticCreate, ItemGearCreate, ItemOtherCreate, ItemShipModuleCreate, ItemWeaponCreate, ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'ARMOR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemArmorCreate),
        ) as ItemArmorCreate;
        oneOfType = ItemArmorCreate;
        break;
      case r'CYBERNETIC':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemCyberneticCreate),
        ) as ItemCyberneticCreate;
        oneOfType = ItemCyberneticCreate;
        break;
      case r'GEAR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemGearCreate),
        ) as ItemGearCreate;
        oneOfType = ItemGearCreate;
        break;
      case r'OTHER':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemOtherCreate),
        ) as ItemOtherCreate;
        oneOfType = ItemOtherCreate;
        break;
      case r'SHIP_MODULE':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemShipModuleCreate),
        ) as ItemShipModuleCreate;
        oneOfType = ItemShipModuleCreate;
        break;
      case r'WEAPON':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemWeaponCreate),
        ) as ItemWeaponCreate;
        oneOfType = ItemWeaponCreate;
        break;
      default:
        throw UnsupportedError("Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(typeIndex: oneOfTypes.indexOf(oneOfType), types: oneOfTypes, value: oneOfResult);
    return result.build();
  }
}

class ItemCreateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'WEAPON')
  static const ItemCreateTypeEnum WEAPON = _$itemCreateTypeEnum_WEAPON;
  @BuiltValueEnumConst(wireName: r'ARMOR')
  static const ItemCreateTypeEnum ARMOR = _$itemCreateTypeEnum_ARMOR;
  @BuiltValueEnumConst(wireName: r'GEAR')
  static const ItemCreateTypeEnum GEAR = _$itemCreateTypeEnum_GEAR;
  @BuiltValueEnumConst(wireName: r'CYBERNETIC')
  static const ItemCreateTypeEnum CYBERNETIC = _$itemCreateTypeEnum_CYBERNETIC;
  @BuiltValueEnumConst(wireName: r'SHIP_MODULE')
  static const ItemCreateTypeEnum SHIP_MODULE = _$itemCreateTypeEnum_SHIP_MODULE;
  @BuiltValueEnumConst(wireName: r'OTHER')
  static const ItemCreateTypeEnum OTHER = _$itemCreateTypeEnum_OTHER;

  static Serializer<ItemCreateTypeEnum> get serializer => _$itemCreateTypeEnumSerializer;

  const ItemCreateTypeEnum._(String name): super(name);

  static BuiltSet<ItemCreateTypeEnum> get values => _$itemCreateTypeEnumValues;
  static ItemCreateTypeEnum valueOf(String name) => _$itemCreateTypeEnumValueOf(name);
}

