//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_create_one_of.dart';
import 'package:app_api_client/src/model/item_create_one_of2.dart';
import 'package:app_api_client/src/model/item_create_one_of3.dart';
import 'package:app_api_client/src/model/item_create_one_of1.dart';
import 'package:app_api_client/src/model/model4.dart';
import 'package:app_api_client/src/model/model1.dart';
import 'package:app_api_client/src/model/item_create_one_of4.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/model3.dart';
import 'package:app_api_client/src/model/model2.dart';
import 'package:app_api_client/src/model/item_create_one_of5.dart';
import 'package:app_api_client/src/model/model0.dart';
import 'package:app_api_client/src/model/model5.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'item_create.g.dart';

/// Payload for creating a new item. Same discriminated union as `Item` but without `id` (server-assigned). The `type` discriminator must be present. 
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
/// * [armorRating] 
/// * [quantity] 
/// * [notes] 
/// * [bodyPoints] 
/// * [effect] 
/// * [slot] 
@BuiltValue()
abstract class ItemCreate implements Built<ItemCreate, ItemCreateBuilder> {
  /// One Of [ItemCreateOneOf], [ItemCreateOneOf1], [ItemCreateOneOf2], [ItemCreateOneOf3], [ItemCreateOneOf4], [ItemCreateOneOf5]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'type';

  static const Map<String, Type> discriminatorMapping = {
    r'ARMOR': Model1,
    r'CYBERNETIC': Model3,
    r'GEAR': Model2,
    r'OTHER': Model5,
    r'SHIP_MODULE': Model4,
    r'WEAPON': Model0,
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
        if (this is Model1) {
            return r'ARMOR';
        }
        if (this is Model3) {
            return r'CYBERNETIC';
        }
        if (this is Model2) {
            return r'GEAR';
        }
        if (this is Model5) {
            return r'OTHER';
        }
        if (this is Model4) {
            return r'SHIP_MODULE';
        }
        if (this is Model0) {
            return r'WEAPON';
        }
        return null;
    }
}
extension ItemCreateBuilderDiscriminatorExt on ItemCreateBuilder {
    String? get discriminatorValue {
        if (this is Model1Builder) {
            return r'ARMOR';
        }
        if (this is Model3Builder) {
            return r'CYBERNETIC';
        }
        if (this is Model2Builder) {
            return r'GEAR';
        }
        if (this is Model5Builder) {
            return r'OTHER';
        }
        if (this is Model4Builder) {
            return r'SHIP_MODULE';
        }
        if (this is Model0Builder) {
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
    ItemCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    final oneOfTypes = [Model1, Model3, Model2, Model5, Model4, Model0, ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'ARMOR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model1),
        ) as Model1;
        oneOfType = Model1;
        break;
      case r'CYBERNETIC':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model3),
        ) as Model3;
        oneOfType = Model3;
        break;
      case r'GEAR':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model2),
        ) as Model2;
        oneOfType = Model2;
        break;
      case r'OTHER':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model5),
        ) as Model5;
        oneOfType = Model5;
        break;
      case r'SHIP_MODULE':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model4),
        ) as Model4;
        oneOfType = Model4;
        break;
      case r'WEAPON':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(Model0),
        ) as Model0;
        oneOfType = Model0;
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

