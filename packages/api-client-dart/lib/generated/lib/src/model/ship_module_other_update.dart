//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:app_api_client/src/model/ship_module_slot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ship_module_other_update.g.dart';

/// PATCH payload for any other ship module slot type. All fields optional. The `slot` discriminator may not be changed after installation. 
///
/// Properties:
/// * [slot] 
/// * [name] 
/// * [energyUse] 
/// * [notes] 
@BuiltValue()
abstract class ShipModuleOtherUpdate implements Built<ShipModuleOtherUpdate, ShipModuleOtherUpdateBuilder> {
  @BuiltValueField(wireName: r'slot')
  ShipModuleSlot? get slot;
  // enum slotEnum {  BRIDGE,  REACTOR,  DRIVE,  HOLD,  WEAPON,  TORPEDO,  SENSOR,  COMMS,  HANGAR,  QUARTERS,  MEDICAL,  WORKSHOP,  CHAPEL,  ESCAPE-PODS,  CRYO,  DOCKING,  MINING,  REPAIR,  CONCEALED-HOLD,  PROXY-DECK,  OTHER,  };

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'energyUse')
  int? get energyUse;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  ShipModuleOtherUpdate._();

  factory ShipModuleOtherUpdate([void updates(ShipModuleOtherUpdateBuilder b)]) = _$ShipModuleOtherUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShipModuleOtherUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShipModuleOtherUpdate> get serializer => _$ShipModuleOtherUpdateSerializer();
}

class _$ShipModuleOtherUpdateSerializer implements PrimitiveSerializer<ShipModuleOtherUpdate> {
  @override
  final Iterable<Type> types = const [ShipModuleOtherUpdate, _$ShipModuleOtherUpdate];

  @override
  final String wireName = r'ShipModuleOtherUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShipModuleOtherUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.slot != null) {
      yield r'slot';
      yield serializers.serialize(
        object.slot,
        specifiedType: const FullType(ShipModuleSlot),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.energyUse != null) {
      yield r'energyUse';
      yield serializers.serialize(
        object.energyUse,
        specifiedType: const FullType(int),
      );
    }
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
    ShipModuleOtherUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShipModuleOtherUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ShipModuleSlot),
          ) as ShipModuleSlot;
          result.slot = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'energyUse':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.energyUse = valueDes;
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
  ShipModuleOtherUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShipModuleOtherUpdateBuilder();
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

