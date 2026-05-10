//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/item_base.dart';
import 'package:built_collection/built_collection.dart';
import 'package:app_api_client/src/model/ship_module_slot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'item_ship_module.g.dart';

/// ItemShipModule
///
/// Properties:
/// * [id] - Opaque identifier (cuid2)
/// * [type] 
/// * [name] - Item name
/// * [slot] 
/// * [effect] - Description of the module's effect and energy use
@BuiltValue()
abstract class ItemShipModule implements ItemBase, Built<ItemShipModule, ItemShipModuleBuilder> {
  /// Description of the module's effect and energy use
  @BuiltValueField(wireName: r'effect')
  String get effect;

  @BuiltValueField(wireName: r'slot')
  ShipModuleSlot get slot;
  // enum slotEnum {  BRIDGE,  REACTOR,  DRIVE,  HOLD,  WEAPON,  TORPEDO,  SENSOR,  COMMS,  HANGAR,  QUARTERS,  MEDICAL,  WORKSHOP,  CHAPEL,  ESCAPE-PODS,  CRYO,  DOCKING,  MINING,  REPAIR,  CONCEALED-HOLD,  PROXY-DECK,  OTHER,  };

  ItemShipModule._();

  factory ItemShipModule([void updates(ItemShipModuleBuilder b)]) = _$ItemShipModule;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItemShipModuleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItemShipModule> get serializer => _$ItemShipModuleSerializer();
}

class _$ItemShipModuleSerializer implements PrimitiveSerializer<ItemShipModule> {
  @override
  final Iterable<Type> types = const [ItemShipModule, _$ItemShipModule];

  @override
  final String wireName = r'ItemShipModule';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItemShipModule object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'effect';
    yield serializers.serialize(
      object.effect,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ItemShipModule object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ItemShipModuleBuilder result,
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
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleSlot),
          ) as ShipModuleSlot;
          result.slot = valueDes;
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
  ItemShipModule deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItemShipModuleBuilder();
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

class ItemShipModuleTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SHIP_MODULE')
  static const ItemShipModuleTypeEnum SHIP_MODULE = _$itemShipModuleTypeEnum_SHIP_MODULE;

  static Serializer<ItemShipModuleTypeEnum> get serializer => _$itemShipModuleTypeEnumSerializer;

  const ItemShipModuleTypeEnum._(String name): super(name);

  static BuiltSet<ItemShipModuleTypeEnum> get values => _$itemShipModuleTypeEnumValues;
  static ItemShipModuleTypeEnum valueOf(String name) => _$itemShipModuleTypeEnumValueOf(name);
}

