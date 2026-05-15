//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_armor.dart';
import 'package:app_api_client/src/model/item_ship_module.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/item_gear.dart';
import 'package:app_api_client/src/model/item_other.dart';
import 'package:app_api_client/src/model/item_cybernetic.dart';
import 'package:app_api_client/src/model/item_weapon.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'item.g.dart';

/// A discriminated union of all item types. The `type` field determines which variant applies. Generated clients produce a correctly-typed sum type from this schema. 
///
/// Properties:
/// * [id] - Opaque identifier (cuid2)
/// * [type] 
/// * [name] - Item name
/// * [damage] - Base damage dice
/// * [range] 
/// * [bonus] - Bonus dice added to the attack pool
/// * [crit] - Critical threshold (roll this many successes to crit)
/// * [weight] - Encumbrance weight in slots
/// * [features] - Feature tags (e.g. \"Vacuum Sealed\", \"Exo-Skeleton\")
/// * [equipped] 
/// * [initiative] - Per-weapon initiative modifier added to the d6 initiative roll when the wielder uses this weapon (ST3001 ГЛАВА 6 «Инициатива» column on each weapon table; ГЛАВА 5 §«Раунды, ходы и инициатива» — «Некоторые виды оружия могут временно повысить значение твоей инициативы. Воспользовавшись этим преимуществом, ты обязан атаковать оружием, которое его обеспечивает»). Canonical printed values in ГЛАВА 6 are 0..+2; the broader −5..+5 envelope leaves room for GM-defined exotics and house-rule penalties without needing a spec bump. Defaults to 0 — most weapons don't carry an initiative bonus. 
/// * [armorRating] - Armor rating — reduces incoming damage
/// * [extraSlotCount] - Extra encumbrance slots this armor grants its wearer when equipped (ST3001 ТАБЛИЦА 6.14 «Дополнительные свойства» column). The wearer's encumbrance limit becomes `STR × 2 + sum(equipped armor extraSlotCount)` per the rules-engine. Canonical values from the printed table: most armors 0; Тяжёлый экзоскафандр / Лёгкая броня / Тяжёлая броня 1; Экзодоспех 2; Тяжёлый экзодоспех 5. The 0..6 envelope leaves one point of headroom for GM-defined exotics. Stacks across multiple equipped pieces (e.g. armour + tactical shield), but only when each piece carries the property — most shields are 0. 
/// * [quantity] - Number of units
/// * [notes] - Optional free-text notes
/// * [xpCost] - XP spent to acquire this cybernetic implant. Cybernetics count as both equipment and talents (ST3001 ГЛАВА 6 «КИБЕРНЕТИЧЕСКИЕ ИМПЛАНТАТЫ»: «считается и снаряжением, и достоинством, так что на его покупку тебе понадобятся не только бирры, но и пункты опыта»). The canonical acquisition cost is 5 XP per ГЛАВА 4 «Новые достоинства» («Накопив 5 пунктов опыта, персонаж получает возможность обменять их на любое новое достоинство»); the field accepts 0..15 to allow GM concessions (0 for in-game gifts) and high-rank exotics (up to 3 ranks × 5 XP). The implant's birr price lives in the regular `cost` (or wherever ItemBase carries item value) — XP is tracked separately because it draws from the character's XP pool, not their wallet. 
/// * [effect] - Description of the module's effect and energy use
/// * [slot] 
@BuiltValue()
abstract class Item implements Built<Item, ItemBuilder> {
  /// One Of [ItemArmor], [ItemCybernetic], [ItemGear], [ItemOther], [ItemShipModule], [ItemWeapon]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'type';

  static const Map<String, Type> discriminatorMapping = {
    r'ARMOR': ItemArmor,
    r'CYBERNETIC': ItemCybernetic,
    r'GEAR': ItemGear,
    r'OTHER': ItemOther,
    r'SHIP_MODULE': ItemShipModule,
    r'WEAPON': ItemWeapon,
  };

  Item._();

  factory Item([void updates(ItemBuilder b)]) = _$Item;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Item> get serializer => _$ItemSerializer();
}

extension ItemDiscriminatorExt on Item {
    String? get discriminatorValue {
        if (this is ItemArmor) {
            return r'ARMOR';
        }
        if (this is ItemCybernetic) {
            return r'CYBERNETIC';
        }
        if (this is ItemGear) {
            return r'GEAR';
        }
        if (this is ItemOther) {
            return r'OTHER';
        }
        if (this is ItemShipModule) {
            return r'SHIP_MODULE';
        }
        if (this is ItemWeapon) {
            return r'WEAPON';
        }
        return null;
    }
}
extension ItemBuilderDiscriminatorExt on ItemBuilder {
    String? get discriminatorValue {
        if (this is ItemArmorBuilder) {
            return r'ARMOR';
        }
        if (this is ItemCyberneticBuilder) {
            return r'CYBERNETIC';
        }
        if (this is ItemGearBuilder) {
            return r'GEAR';
        }
        if (this is ItemOtherBuilder) {
            return r'OTHER';
        }
        if (this is ItemShipModuleBuilder) {
            return r'SHIP_MODULE';
        }
        if (this is ItemWeaponBuilder) {
            return r'WEAPON';
        }
        return null;
    }
}

class _$ItemSerializer implements PrimitiveSerializer<Item> {
  @override
  final Iterable<Type> types = const [Item, _$Item];

  @override
  final String wireName = r'Item';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Item object) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    Item object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  Item deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemBuilder();
    Object? oneOfDataSrc;
    final serializedList = (serialized as Iterable<Object?>).toList();
    final discIndex = serializedList.indexOf(Item.discriminatorFieldName) + 1;
    final discValue = serializers.deserialize(serializedList[discIndex], specifiedType: FullType(String)) as String;
    oneOfDataSrc = serialized;
    final oneOfTypes = [ItemArmor, ItemCybernetic, ItemGear, ItemOther, ItemShipModule, ItemWeapon, ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'ARMOR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemArmor),
        ) as ItemArmor;
        oneOfType = ItemArmor;
        break;
      case r'CYBERNETIC':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemCybernetic),
        ) as ItemCybernetic;
        oneOfType = ItemCybernetic;
        break;
      case r'GEAR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemGear),
        ) as ItemGear;
        oneOfType = ItemGear;
        break;
      case r'OTHER':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemOther),
        ) as ItemOther;
        oneOfType = ItemOther;
        break;
      case r'SHIP_MODULE':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemShipModule),
        ) as ItemShipModule;
        oneOfType = ItemShipModule;
        break;
      case r'WEAPON':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(ItemWeapon),
        ) as ItemWeapon;
        oneOfType = ItemWeapon;
        break;
      default:
        throw UnsupportedError("Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(typeIndex: oneOfTypes.indexOf(oneOfType), types: oneOfTypes, value: oneOfResult);
    return result.build();
  }
}

class ItemTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'WEAPON')
  static const ItemTypeEnum WEAPON = _$itemTypeEnum_WEAPON;
  @BuiltValueEnumConst(wireName: r'ARMOR')
  static const ItemTypeEnum ARMOR = _$itemTypeEnum_ARMOR;
  @BuiltValueEnumConst(wireName: r'GEAR')
  static const ItemTypeEnum GEAR = _$itemTypeEnum_GEAR;
  @BuiltValueEnumConst(wireName: r'CYBERNETIC')
  static const ItemTypeEnum CYBERNETIC = _$itemTypeEnum_CYBERNETIC;
  @BuiltValueEnumConst(wireName: r'SHIP_MODULE')
  static const ItemTypeEnum SHIP_MODULE = _$itemTypeEnum_SHIP_MODULE;
  @BuiltValueEnumConst(wireName: r'OTHER')
  static const ItemTypeEnum OTHER = _$itemTypeEnum_OTHER;

  static Serializer<ItemTypeEnum> get serializer => _$itemTypeEnumSerializer;

  const ItemTypeEnum._(String name): super(name);

  static BuiltSet<ItemTypeEnum> get values => _$itemTypeEnumValues;
  static ItemTypeEnum valueOf(String name) => _$itemTypeEnumValueOf(name);
}

