//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/ship_module_slot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_ship_module_create.g.dart';

/// Create payload for a SHIP_MODULE item. No `id` — server-assigned.
///
/// Properties:
/// * [type] 
/// * [name] 
/// * [slot] 
/// * [effect] - Description of the module's effect and energy use
@BuiltValue()
abstract class ItemShipModuleCreate implements Built<ItemShipModuleCreate, ItemShipModuleCreateBuilder> {
  @BuiltValueField(wireName: r'type')
  ItemShipModuleCreateTypeEnum get type;
  // enum typeEnum {  SHIP_MODULE,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'slot')
  ShipModuleSlot get slot;
  // enum slotEnum {  BRIDGE,  REACTOR,  DRIVE,  HOLD,  WEAPON,  TORPEDO,  SENSOR,  COMMS,  HANGAR,  QUARTERS,  MEDICAL,  WORKSHOP,  CHAPEL,  ESCAPE-PODS,  CRYO,  DOCKING,  MINING,  REPAIR,  CONCEALED-HOLD,  PROXY-DECK,  OTHER,  };

  /// Description of the module's effect and energy use
  @BuiltValueField(wireName: r'effect')
  String get effect;

  ItemShipModuleCreate._();

  factory ItemShipModuleCreate([void updates(ItemShipModuleCreateBuilder b)]) = _$ItemShipModuleCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemShipModuleCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemShipModuleCreate> get serializer => _$ItemShipModuleCreateSerializer();
}

class _$ItemShipModuleCreateSerializer implements PrimitiveSerializer<ItemShipModuleCreate> {
  @override
  final Iterable<Type> types = const [ItemShipModuleCreate, _$ItemShipModuleCreate];

  @override
  final String wireName = r'ItemShipModuleCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemShipModuleCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(ItemShipModuleCreateTypeEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(ShipModuleSlot),
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
    ItemShipModuleCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemShipModuleCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ItemShipModuleCreateTypeEnum),
          ) as ItemShipModuleCreateTypeEnum;
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
  ItemShipModuleCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemShipModuleCreateBuilder();
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

class ItemShipModuleCreateTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SHIP_MODULE')
  static const ItemShipModuleCreateTypeEnum SHIP_MODULE = _$itemShipModuleCreateTypeEnum_SHIP_MODULE;

  static Serializer<ItemShipModuleCreateTypeEnum> get serializer => _$itemShipModuleCreateTypeEnumSerializer;

  const ItemShipModuleCreateTypeEnum._(String name): super(name);

  static BuiltSet<ItemShipModuleCreateTypeEnum> get values => _$itemShipModuleCreateTypeEnumValues;
  static ItemShipModuleCreateTypeEnum valueOf(String name) => _$itemShipModuleCreateTypeEnumValueOf(name);
}

