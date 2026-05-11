//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_other_update.dart';
import 'package:app_api_client/src/model/item_ship_module_update.dart';
import 'package:app_api_client/src/model/item_cybernetic_update.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/item_gear_update.dart';
import 'package:app_api_client/src/model/item_armor_update.dart';
import 'package:app_api_client/src/model/item_range_enum.dart';
import 'package:app_api_client/src/model/ship_module_slot.dart';
import 'package:app_api_client/src/model/item_weapon_update.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'item_update.g.dart';

/// PATCH payload for updating an item. The `type` discriminator must match the existing item type — changing it returns 400 `ITEM_TYPE_MISMATCH`. All fields are optional. 
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [damage] 
/// * [range] 
/// * [bonus] 
/// * [crit] 
/// * [weight] 
/// * [features] 
/// * [equipped] 
/// * [initiative] - Per-weapon initiative modifier (ST3001 ГЛАВА 6 «Инициатива» column). Accepts −5..+5. Omit to leave unchanged. 
/// * [armorRating] 
/// * [extraSlotCount] - Extra encumbrance slots this armor grants its wearer when equipped (ST3001 ТАБЛИЦА 6.14 «Дополнительные свойства» column). Omit to leave unchanged. 
/// * [quantity] 
/// * [notes] 
/// * [xpCost] 
/// * [effect] 
/// * [slot] 
@BuiltValue()
abstract class ItemUpdate implements Built<ItemUpdate, ItemUpdateBuilder> {
  /// One Of [ItemArmorUpdate], [ItemCyberneticUpdate], [ItemGearUpdate], [ItemOtherUpdate], [ItemShipModuleUpdate], [ItemWeaponUpdate]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'type';

  static const Map<String, Type> discriminatorMapping = {
    r'ARMOR': ItemArmorUpdate,
    r'CYBERNETIC': ItemCyberneticUpdate,
    r'GEAR': ItemGearUpdate,
    r'OTHER': ItemOtherUpdate,
    r'SHIP_MODULE': ItemShipModuleUpdate,
    r'WEAPON': ItemWeaponUpdate,
  };

  ItemUpdate._();

  factory ItemUpdate([void updates(ItemUpdateBuilder b)]) = _$ItemUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemUpdate> get serializer => _$ItemUpdateSerializer();
}

extension ItemUpdateDiscriminatorExt on ItemUpdate {
    String? get discriminatorValue {
        if (this is ItemArmorUpdate) {
            return r'ARMOR';
        }
        if (this is ItemCyberneticUpdate) {
            return r'CYBERNETIC';
        }
        if (this is ItemGearUpdate) {
            return r'GEAR';
        }
        if (this is ItemOtherUpdate) {
            return r'OTHER';
        }
        if (this is ItemShipModuleUpdate) {
            return r'SHIP_MODULE';
        }
        if (this is ItemWeaponUpdate) {
            return r'WEAPON';
        }
        return null;
    }
}
extension ItemUpdateBuilderDiscriminatorExt on ItemUpdateBuilder {
    String? get discriminatorValue {
        if (this is ItemArmorUpdateBuilder) {
            return r'ARMOR';
        }
        if (this is ItemCyberneticUpdateBuilder) {
            return r'CYBERNETIC';
        }
        if (this is ItemGearUpdateBuilder) {
            return r'GEAR';
        }
        if (this is ItemOtherUpdateBuilder) {
            return r'OTHER';
        }
        if (this is ItemShipModuleUpdateBuilder) {
            return r'SHIP_MODULE';
        }
        if (this is ItemWeaponUpdateBuilder) {
            return r'WEAPON';
        }
        return null;
    }
}

class _$ItemUpdateSerializer implements PrimitiveSerializer<ItemUpdate> {
  @override
  final Iterable<Type> types = const [ItemUpdate, _$ItemUpdate];

  @override
  final String wireName = r'ItemUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemUpdate object) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  ItemUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemUpdateBuilder();
    Object? oneOfDataSrc;
    final serializedList = (serialized as Iterable<Object?>).toList();
    final discIndex = serializedList.indexOf(ItemUpdate.discriminatorFieldName) + 1;
    final discValue = serializers.deserialize(serializedList[discIndex], specifiedType: FullType(String)) as String;
    oneOfDataSrc = serialized;
    final oneOfTypes = [ItemArmorUpdate, ItemCyberneticUpdate, ItemGearUpdate, ItemOtherUpdate, ItemShipModuleUpdate, ItemWeaponUpdate, ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'ARMOR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemArmorUpdate),
        ) as ItemArmorUpdate;
        oneOfType = ItemArmorUpdate;
        break;
      case r'CYBERNETIC':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemCyberneticUpdate),
        ) as ItemCyberneticUpdate;
        oneOfType = ItemCyberneticUpdate;
        break;
      case r'GEAR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemGearUpdate),
        ) as ItemGearUpdate;
        oneOfType = ItemGearUpdate;
        break;
      case r'OTHER':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemOtherUpdate),
        ) as ItemOtherUpdate;
        oneOfType = ItemOtherUpdate;
        break;
      case r'SHIP_MODULE':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemShipModuleUpdate),
        ) as ItemShipModuleUpdate;
        oneOfType = ItemShipModuleUpdate;
        break;
      case r'WEAPON':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemWeaponUpdate),
        ) as ItemWeaponUpdate;
        oneOfType = ItemWeaponUpdate;
        break;
      default:
        throw UnsupportedError("Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(typeIndex: oneOfTypes.indexOf(oneOfType), types: oneOfTypes, value: oneOfResult);
    return result.build();
  }
}

class ItemUpdateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'WEAPON')
  static const ItemUpdateTypeEnum WEAPON = _$itemUpdateTypeEnum_WEAPON;
  @BuiltValueEnumConst(wireName: r'ARMOR')
  static const ItemUpdateTypeEnum ARMOR = _$itemUpdateTypeEnum_ARMOR;
  @BuiltValueEnumConst(wireName: r'GEAR')
  static const ItemUpdateTypeEnum GEAR = _$itemUpdateTypeEnum_GEAR;
  @BuiltValueEnumConst(wireName: r'CYBERNETIC')
  static const ItemUpdateTypeEnum CYBERNETIC = _$itemUpdateTypeEnum_CYBERNETIC;
  @BuiltValueEnumConst(wireName: r'SHIP_MODULE')
  static const ItemUpdateTypeEnum SHIP_MODULE = _$itemUpdateTypeEnum_SHIP_MODULE;
  @BuiltValueEnumConst(wireName: r'OTHER')
  static const ItemUpdateTypeEnum OTHER = _$itemUpdateTypeEnum_OTHER;

  static Serializer<ItemUpdateTypeEnum> get serializer => _$itemUpdateTypeEnumSerializer;

  const ItemUpdateTypeEnum._(String name): super(name);

  static BuiltSet<ItemUpdateTypeEnum> get values => _$itemUpdateTypeEnumValues;
  static ItemUpdateTypeEnum valueOf(String name) => _$itemUpdateTypeEnumValueOf(name);
}

