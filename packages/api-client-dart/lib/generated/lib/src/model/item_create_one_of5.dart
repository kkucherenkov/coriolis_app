//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_create_one_of5.g.dart';

/// ItemCreateOneOf5
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [weight] 
/// * [notes] 
@BuiltValue()
abstract class ItemCreateOneOf5 implements Built<ItemCreateOneOf5, ItemCreateOneOf5Builder> {
  @BuiltValueField(wireName: r'type')
  ItemCreateOneOf5TypeEnum get type;
  // enum typeEnum {  OTHER,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'weight')
  num get weight;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ItemCreateOneOf5._();

  factory ItemCreateOneOf5([void updates(ItemCreateOneOf5Builder b)]) = _$ItemCreateOneOf5;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemCreateOneOf5Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemCreateOneOf5> get serializer => _$ItemCreateOneOf5Serializer();
}

class _$ItemCreateOneOf5Serializer implements PrimitiveSerializer<ItemCreateOneOf5> {
  @override
  final Iterable<Type> types = const [ItemCreateOneOf5, _$ItemCreateOneOf5];

  @override
  final String wireName = r'ItemCreateOneOf5';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemCreateOneOf5 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(ItemCreateOneOf5TypeEnum),
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
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemCreateOneOf5 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemCreateOneOf5Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemCreateOneOf5TypeEnum),
          ) as ItemCreateOneOf5TypeEnum;
          result.type = valueDes;
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
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ItemCreateOneOf5 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemCreateOneOf5Builder();
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

class ItemCreateOneOf5TypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'OTHER')
  static const ItemCreateOneOf5TypeEnum OTHER = _$itemCreateOneOf5TypeEnum_OTHER;

  static Serializer<ItemCreateOneOf5TypeEnum> get serializer => _$itemCreateOneOf5TypeEnumSerializer;

  const ItemCreateOneOf5TypeEnum._(String name): super(name);

  static BuiltSet<ItemCreateOneOf5TypeEnum> get values => _$itemCreateOneOf5TypeEnumValues;
  static ItemCreateOneOf5TypeEnum valueOf(String name) => _$itemCreateOneOf5TypeEnumValueOf(name);
}

