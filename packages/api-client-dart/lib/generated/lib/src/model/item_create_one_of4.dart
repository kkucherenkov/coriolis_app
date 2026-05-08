//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_slot_type.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_create_one_of4.g.dart';

/// ItemCreateOneOf4
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [slot] 
/// * [effect] 
@BuiltValue()
abstract class ItemCreateOneOf4 implements Built<ItemCreateOneOf4, ItemCreateOneOf4Builder> {
  @BuiltValueField(wireName: r'type')
  ItemCreateOneOf4TypeEnum get type;
  // enum typeEnum {  SHIP_MODULE,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'slot')
  ItemSlotType get slot;
  // enum slotEnum {  bridge,  hull,  hold,  weapon,  drive,  sensor,  comms,  };

  @BuiltValueField(wireName: r'effect')
  String get effect;

  ItemCreateOneOf4._();

  factory ItemCreateOneOf4([void updates(ItemCreateOneOf4Builder b)]) = _$ItemCreateOneOf4;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemCreateOneOf4Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemCreateOneOf4> get serializer => _$ItemCreateOneOf4Serializer();
}

class _$ItemCreateOneOf4Serializer implements PrimitiveSerializer<ItemCreateOneOf4> {
  @override
  final Iterable<Type> types = const [ItemCreateOneOf4, _$ItemCreateOneOf4];

  @override
  final String wireName = r'ItemCreateOneOf4';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemCreateOneOf4 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(ItemCreateOneOf4TypeEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(ItemSlotType),
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
    ItemCreateOneOf4 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemCreateOneOf4Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemCreateOneOf4TypeEnum),
          ) as ItemCreateOneOf4TypeEnum;
          result.type = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemSlotType),
          ) as ItemSlotType;
          result.slot = valueDes;
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
  ItemCreateOneOf4 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemCreateOneOf4Builder();
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

class ItemCreateOneOf4TypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SHIP_MODULE')
  static const ItemCreateOneOf4TypeEnum SHIP_MODULE = _$itemCreateOneOf4TypeEnum_SHIP_MODULE;

  static Serializer<ItemCreateOneOf4TypeEnum> get serializer => _$itemCreateOneOf4TypeEnumSerializer;

  const ItemCreateOneOf4TypeEnum._(String name): super(name);

  static BuiltSet<ItemCreateOneOf4TypeEnum> get values => _$itemCreateOneOf4TypeEnumValues;
  static ItemCreateOneOf4TypeEnum valueOf(String name) => _$itemCreateOneOf4TypeEnumValueOf(name);
}

