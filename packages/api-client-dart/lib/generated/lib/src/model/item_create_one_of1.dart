//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_create_one_of1.g.dart';

/// ItemCreateOneOf1
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [armorRating] 
/// * [weight] 
/// * [features] 
/// * [equipped] 
@BuiltValue()
abstract class ItemCreateOneOf1 implements Built<ItemCreateOneOf1, ItemCreateOneOf1Builder> {
  @BuiltValueField(wireName: r'type')
  ItemCreateOneOf1TypeEnum get type;
  // enum typeEnum {  ARMOR,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'armorRating')
  int get armorRating;

  @BuiltValueField(wireName: r'weight')
  num get weight;

  @BuiltValueField(wireName: r'features')
  BuiltList<String> get features;

  @BuiltValueField(wireName: r'equipped')
  bool get equipped;

  ItemCreateOneOf1._();

  factory ItemCreateOneOf1([void updates(ItemCreateOneOf1Builder b)]) = _$ItemCreateOneOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemCreateOneOf1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemCreateOneOf1> get serializer => _$ItemCreateOneOf1Serializer();
}

class _$ItemCreateOneOf1Serializer implements PrimitiveSerializer<ItemCreateOneOf1> {
  @override
  final Iterable<Type> types = const [ItemCreateOneOf1, _$ItemCreateOneOf1];

  @override
  final String wireName = r'ItemCreateOneOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemCreateOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(ItemCreateOneOf1TypeEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'armorRating';
    yield serializers.serialize(
      object.armorRating,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemCreateOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemCreateOneOf1Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemCreateOneOf1TypeEnum),
          ) as ItemCreateOneOf1TypeEnum;
          result.type = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'armorRating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.armorRating = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ItemCreateOneOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemCreateOneOf1Builder();
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

class ItemCreateOneOf1TypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ARMOR')
  static const ItemCreateOneOf1TypeEnum ARMOR = _$itemCreateOneOf1TypeEnum_ARMOR;

  static Serializer<ItemCreateOneOf1TypeEnum> get serializer => _$itemCreateOneOf1TypeEnumSerializer;

  const ItemCreateOneOf1TypeEnum._(String name): super(name);

  static BuiltSet<ItemCreateOneOf1TypeEnum> get values => _$itemCreateOneOf1TypeEnumValues;
  static ItemCreateOneOf1TypeEnum valueOf(String name) => _$itemCreateOneOf1TypeEnumValueOf(name);
}

