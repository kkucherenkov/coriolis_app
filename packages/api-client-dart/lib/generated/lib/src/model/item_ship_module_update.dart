//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/ship_module_slot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_ship_module_update.g.dart';

/// PATCH payload for a SHIP_MODULE item. All fields optional.
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [slot] 
/// * [effect] 
@BuiltValue()
abstract class ItemShipModuleUpdate implements Built<ItemShipModuleUpdate, ItemShipModuleUpdateBuilder> {
  @BuiltValueField(wireName: r'type')
  ItemShipModuleUpdateTypeEnum? get type;
  // enum typeEnum {  SHIP_MODULE,  };

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'slot')
  ShipModuleSlot? get slot;
  // enum slotEnum {  BRIDGE,  REACTOR,  DRIVE,  HOLD,  WEAPON,  TORPEDO,  SENSOR,  COMMS,  HANGAR,  QUARTERS,  MEDICAL,  WORKSHOP,  CHAPEL,  ESCAPE-PODS,  CRYO,  DOCKING,  MINING,  REPAIR,  CONCEALED-HOLD,  PROXY-DECK,  OTHER,  };

  @BuiltValueField(wireName: r'effect')
  String? get effect;

  ItemShipModuleUpdate._();

  factory ItemShipModuleUpdate([void updates(ItemShipModuleUpdateBuilder b)]) = _$ItemShipModuleUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemShipModuleUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemShipModuleUpdate> get serializer => _$ItemShipModuleUpdateSerializer();
}

class _$ItemShipModuleUpdateSerializer implements PrimitiveSerializer<ItemShipModuleUpdate> {
  @override
  final Iterable<Type> types = const [ItemShipModuleUpdate, _$ItemShipModuleUpdate];

  @override
  final String wireName = r'ItemShipModuleUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemShipModuleUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(ItemShipModuleUpdateTypeEnum),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.slot != null) {
      yield r'slot';
      yield serializers.serialize(
        object.slot,
        specifiedType: const FullType(ShipModuleSlot),
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
    ItemShipModuleUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemShipModuleUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemShipModuleUpdateTypeEnum),
          ) as ItemShipModuleUpdateTypeEnum;
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
            specifiedType: const FullType(ShipModuleSlot),
          ) as ShipModuleSlot;
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
  ItemShipModuleUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemShipModuleUpdateBuilder();
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

class ItemShipModuleUpdateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SHIP_MODULE')
  static const ItemShipModuleUpdateTypeEnum SHIP_MODULE = _$itemShipModuleUpdateTypeEnum_SHIP_MODULE;

  static Serializer<ItemShipModuleUpdateTypeEnum> get serializer => _$itemShipModuleUpdateTypeEnumSerializer;

  const ItemShipModuleUpdateTypeEnum._(String name): super(name);

  static BuiltSet<ItemShipModuleUpdateTypeEnum> get values => _$itemShipModuleUpdateTypeEnumValues;
  static ItemShipModuleUpdateTypeEnum valueOf(String name) => _$itemShipModuleUpdateTypeEnumValueOf(name);
}

