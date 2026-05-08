//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_base.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_cybernetic.g.dart';

/// ItemCybernetic
///
/// Properties:
/// * [id] - Opaque identifier (cuid2)
/// * [type] 
/// * [name] - Item name
/// * [bodyPoints] - System strain points consumed (0–6)
/// * [effect] - Description of the cybernetic's effect
@BuiltValue()
abstract class ItemCybernetic implements ItemBase, Built<ItemCybernetic, ItemCyberneticBuilder> {
  /// System strain points consumed (0–6)
  @BuiltValueField(wireName: r'bodyPoints')
  int get bodyPoints;

  /// Description of the cybernetic's effect
  @BuiltValueField(wireName: r'effect')
  String get effect;

  ItemCybernetic._();

  factory ItemCybernetic([void updates(ItemCyberneticBuilder b)]) = _$ItemCybernetic;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemCyberneticBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemCybernetic> get serializer => _$ItemCyberneticSerializer();
}

class _$ItemCyberneticSerializer implements PrimitiveSerializer<ItemCybernetic> {
  @override
  final Iterable<Type> types = const [ItemCybernetic, _$ItemCybernetic];

  @override
  final String wireName = r'ItemCybernetic';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemCybernetic object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
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
    ItemCybernetic object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemCyberneticBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
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
  ItemCybernetic deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemCyberneticBuilder();
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

class ItemCyberneticTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'CYBERNETIC')
  static const ItemCyberneticTypeEnum CYBERNETIC = _$itemCyberneticTypeEnum_CYBERNETIC;

  static Serializer<ItemCyberneticTypeEnum> get serializer => _$itemCyberneticTypeEnumSerializer;

  const ItemCyberneticTypeEnum._(String name): super(name);

  static BuiltSet<ItemCyberneticTypeEnum> get values => _$itemCyberneticTypeEnumValues;
  static ItemCyberneticTypeEnum valueOf(String name) => _$itemCyberneticTypeEnumValueOf(name);
}

