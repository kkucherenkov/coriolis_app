//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_base.g.dart';

/// Fields common to every item type
///
/// Properties:
/// * [id] - Opaque identifier (cuid2)
/// * [type] - Discriminator — determines which type-specific fields are present
/// * [name] - Item name
@BuiltValue(instantiable: false)
abstract class ItemBase  {
  /// Opaque identifier (cuid2)
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Discriminator — determines which type-specific fields are present
  @BuiltValueField(wireName: r'type')
  String get type;

  /// Item name
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemBase> get serializer => _$ItemBaseSerializer();
}

class _$ItemBaseSerializer implements PrimitiveSerializer<ItemBase> {
  @override
  final Iterable<Type> types = const [ItemBase];

  @override
  final String wireName = r'ItemBase';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemBase object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemBase object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  ItemBase deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($ItemBase)) as $ItemBase;
  }
}

/// a concrete implementation of [ItemBase], since [ItemBase] is not instantiable
@BuiltValue(instantiable: true)
abstract class $ItemBase implements ItemBase, Built<$ItemBase, $ItemBaseBuilder> {
  $ItemBase._();

  factory $ItemBase([void Function($ItemBaseBuilder)? updates]) = _$$ItemBase;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($ItemBaseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$ItemBase> get serializer => _$$ItemBaseSerializer();
}

class _$$ItemBaseSerializer implements PrimitiveSerializer<$ItemBase> {
  @override
  final Iterable<Type> types = const [$ItemBase, _$$ItemBase];

  @override
  final String wireName = r'$ItemBase';

  @override
  Object serialize(
    Serializers serializers,
    $ItemBase object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(ItemBase))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemBaseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $ItemBase deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $ItemBaseBuilder();
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

