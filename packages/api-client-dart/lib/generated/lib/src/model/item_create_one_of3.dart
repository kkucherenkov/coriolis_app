//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_create_one_of3.g.dart';

/// ItemCreateOneOf3
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [bodyPoints] 
/// * [effect] 
@BuiltValue()
abstract class ItemCreateOneOf3 implements Built<ItemCreateOneOf3, ItemCreateOneOf3Builder> {
  @BuiltValueField(wireName: r'type')
  ItemCreateOneOf3TypeEnum get type;
  // enum typeEnum {  CYBERNETIC,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'bodyPoints')
  int get bodyPoints;

  @BuiltValueField(wireName: r'effect')
  String get effect;

  ItemCreateOneOf3._();

  factory ItemCreateOneOf3([void updates(ItemCreateOneOf3Builder b)]) = _$ItemCreateOneOf3;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemCreateOneOf3Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemCreateOneOf3> get serializer => _$ItemCreateOneOf3Serializer();
}

class _$ItemCreateOneOf3Serializer implements PrimitiveSerializer<ItemCreateOneOf3> {
  @override
  final Iterable<Type> types = const [ItemCreateOneOf3, _$ItemCreateOneOf3];

  @override
  final String wireName = r'ItemCreateOneOf3';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemCreateOneOf3 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(ItemCreateOneOf3TypeEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'bodyPoints';
    yield serializers.serialize(
      object.bodyPoints,
      specifiedType: const FullType(int),
    );
    yield r'effect';
    yield serializers.serialize(
      object.effect,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemCreateOneOf3 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemCreateOneOf3Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemCreateOneOf3TypeEnum),
          ) as ItemCreateOneOf3TypeEnum;
          result.type = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'bodyPoints':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.bodyPoints = valueDes;
          break;
        case r'effect':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.effect = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ItemCreateOneOf3 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemCreateOneOf3Builder();
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

class ItemCreateOneOf3TypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'CYBERNETIC')
  static const ItemCreateOneOf3TypeEnum CYBERNETIC = _$itemCreateOneOf3TypeEnum_CYBERNETIC;

  static Serializer<ItemCreateOneOf3TypeEnum> get serializer => _$itemCreateOneOf3TypeEnumSerializer;

  const ItemCreateOneOf3TypeEnum._(String name): super(name);

  static BuiltSet<ItemCreateOneOf3TypeEnum> get values => _$itemCreateOneOf3TypeEnumValues;
  static ItemCreateOneOf3TypeEnum valueOf(String name) => _$itemCreateOneOf3TypeEnumValueOf(name);
}

