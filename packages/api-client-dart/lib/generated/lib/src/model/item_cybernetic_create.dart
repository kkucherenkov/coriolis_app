//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_cybernetic_create.g.dart';

/// Create payload for a CYBERNETIC item. No `id` — server-assigned.
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [bodyPoints] - System strain points consumed (0–6)
/// * [effect] - Description of the cybernetic's effect
@BuiltValue()
abstract class ItemCyberneticCreate implements Built<ItemCyberneticCreate, ItemCyberneticCreateBuilder> {
  @BuiltValueField(wireName: r'type')
  ItemCyberneticCreateTypeEnum get type;
  // enum typeEnum {  CYBERNETIC,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  /// System strain points consumed (0–6)
  @BuiltValueField(wireName: r'bodyPoints')
  int get bodyPoints;

  /// Description of the cybernetic's effect
  @BuiltValueField(wireName: r'effect')
  String get effect;

  ItemCyberneticCreate._();

  factory ItemCyberneticCreate([void updates(ItemCyberneticCreateBuilder b)]) = _$ItemCyberneticCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemCyberneticCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemCyberneticCreate> get serializer => _$ItemCyberneticCreateSerializer();
}

class _$ItemCyberneticCreateSerializer implements PrimitiveSerializer<ItemCyberneticCreate> {
  @override
  final Iterable<Type> types = const [ItemCyberneticCreate, _$ItemCyberneticCreate];

  @override
  final String wireName = r'ItemCyberneticCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemCyberneticCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(ItemCyberneticCreateTypeEnum),
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
    ItemCyberneticCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemCyberneticCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemCyberneticCreateTypeEnum),
          ) as ItemCyberneticCreateTypeEnum;
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
  ItemCyberneticCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemCyberneticCreateBuilder();
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

class ItemCyberneticCreateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'CYBERNETIC')
  static const ItemCyberneticCreateTypeEnum CYBERNETIC = _$itemCyberneticCreateTypeEnum_CYBERNETIC;

  static Serializer<ItemCyberneticCreateTypeEnum> get serializer => _$itemCyberneticCreateTypeEnumSerializer;

  const ItemCyberneticCreateTypeEnum._(String name): super(name);

  static BuiltSet<ItemCyberneticCreateTypeEnum> get values => _$itemCyberneticCreateTypeEnumValues;
  static ItemCyberneticCreateTypeEnum valueOf(String name) => _$itemCyberneticCreateTypeEnumValueOf(name);
}

