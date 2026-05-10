//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_cybernetic_update.g.dart';

/// PATCH payload for a CYBERNETIC item. All fields optional.
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [xpCost] 
/// * [effect] 
@BuiltValue()
abstract class ItemCyberneticUpdate implements Built<ItemCyberneticUpdate, ItemCyberneticUpdateBuilder> {
  @BuiltValueField(wireName: r'type')
  ItemCyberneticUpdateTypeEnum? get type;
  // enum typeEnum {  CYBERNETIC,  };

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'xpCost')
  int? get xpCost;

  @BuiltValueField(wireName: r'effect')
  String? get effect;

  ItemCyberneticUpdate._();

  factory ItemCyberneticUpdate([void updates(ItemCyberneticUpdateBuilder b)]) = _$ItemCyberneticUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemCyberneticUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemCyberneticUpdate> get serializer => _$ItemCyberneticUpdateSerializer();
}

class _$ItemCyberneticUpdateSerializer implements PrimitiveSerializer<ItemCyberneticUpdate> {
  @override
  final Iterable<Type> types = const [ItemCyberneticUpdate, _$ItemCyberneticUpdate];

  @override
  final String wireName = r'ItemCyberneticUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemCyberneticUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(ItemCyberneticUpdateTypeEnum),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.xpCost != null) {
      yield r'xpCost';
      yield serializers.serialize(
        object.xpCost,
        specifiedType: const FullType(int),
      );
    }
    if (object.effect != null) {
      yield r'effect';
      yield serializers.serialize(
        object.effect,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemCyberneticUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemCyberneticUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemCyberneticUpdateTypeEnum),
          ) as ItemCyberneticUpdateTypeEnum;
          result.type = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'xpCost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.xpCost = valueDes;
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
  ItemCyberneticUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemCyberneticUpdateBuilder();
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

class ItemCyberneticUpdateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'CYBERNETIC')
  static const ItemCyberneticUpdateTypeEnum CYBERNETIC = _$itemCyberneticUpdateTypeEnum_CYBERNETIC;

  static Serializer<ItemCyberneticUpdateTypeEnum> get serializer => _$itemCyberneticUpdateTypeEnumSerializer;

  const ItemCyberneticUpdateTypeEnum._(String name): super(name);

  static BuiltSet<ItemCyberneticUpdateTypeEnum> get values => _$itemCyberneticUpdateTypeEnumValues;
  static ItemCyberneticUpdateTypeEnum valueOf(String name) => _$itemCyberneticUpdateTypeEnumValueOf(name);
}

